open Lang
open Common
module E = Expr.ExprHashCons

(* constant value type; todo: expand and unify with value type used by partial evaluator *)
module VT = struct
  type t = BV of Bitvec.t | I of Z.t | Bool of bool [@@deriving eq, ord, show]

  let to_const = function
    | BV i -> Expr.BasilExpr.bvconst i
    | Bool i -> Expr.BasilExpr.boolconst i
    | I i -> Expr.BasilExpr.intconst i
end

module Value = struct
  type op = Ops.AllOps.([ const | unary | binary | intrin | lambda ])

  let equal_op a b = Equal.poly a b

  type 'a t =
    | E of
        (Expr.ExprHashCons.t
        [@printer fun fmt e -> fprintf fmt "%s" (Expr.ExprHashCons.show_dbg e)])
    | Vr of
        (Var.t UnionFind.elem
        [@equal fun a b -> UnionFind.eq a b]
        [@printer
          fun fmt e -> fprintf fmt "%s" (UnionFind.get e |> Var.to_string)])
    | Val of VT.t
    | Poison
  [@@deriving map, fold, eq, show]

  let show a = show (fun _ _ -> ()) a
  let pp a = pp (fun _ _ -> ()) a

  type cell = tc Fix.HashCons.cell
  and tc = V of cell t [@@unboxed]

  module Inner = struct
    type t = tc

    let equal a b = match (a, b) with V a, V b -> equal Fix.HashCons.equal a b
    let hash (e : t) = Hash.poly e
  end
end

module Pack =
functor
  ()
  ->
  struct
    module Consed = struct
      module H = Fix.HashCons.ForHashedType (Value.Inner)

      type 'a expr = 'a Value.t
      type t = Value.cell

      let map_expr = Value.map
      let fix (i : 'a expr) : t = H.make (Value.V i)
      let unfix (i : t) : 'a expr = match Fix.HashCons.data i with V i -> i
      let hash = Fix.HashCons.hash
      let equal = Fix.HashCons.equal
    end

    module Vars = Fix.Memoize.ForHashedType (Var)

    let make_var = Vars.memoize (fun (v : Var.t) -> UnionFind.make v)

    module Memo = Fix.Memoize.ForHashedType (Consed)

    let fix_impl = Memo.memoize (fun (v : Consed.t) -> UnionFind.make v)
    let fix e = fix_impl (Consed.fix e)
    let unfix e = UnionFind.find e |> UnionFind.get |> Consed.unfix
    let find = UnionFind.find
    let of_var v = fix @@ Value.Vr (UnionFind.find @@ make_var v)
    let find_var v = UnionFind.find (make_var v) |> UnionFind.get

    let merge merge_fn a b =
      let unwrap e = Consed.unfix e in
      let merge_fn a b = Consed.fix @@ merge_fn (unwrap a) (unwrap b) in
      find @@ UnionFind.merge merge_fn a b

    let equal a b = UnionFind.eq a b
    let compare a b = Fix.HashCons.compare (UnionFind.get a) (UnionFind.get b)

    let of_const (o : Ops.AllOps.const) =
      match o with
      | `Bool i -> Some (find @@ fix (Val (Bool i)))
      | `Integer i -> Some (find @@ fix (Val (I i)))
      | `Bitvector i -> Some (find @@ fix (Val (BV i)))
      | _ -> None

    let gen = Fix.Gensym.make ()
  end

module type S = module type of Pack ()

let merge_vars v1 v2 =
  (* hack to prioritise params in 'extraction' *)
  let priority v =
    if String.ends_with ~suffix:"_in" (Var.name v) then 2
    else if String.ends_with ~suffix:"_out" (Var.name v) then 0
    else 1
  in
  if priority v1 > priority v2 then v1 else v2

let merge_vars v1 v2 = UnionFind.merge merge_vars v1 v2

let of_hc_expr (module P : S) e =
  Expr.ExprHashCons.unfix e |> function
  | RVar { id } -> UnionFind.find @@ P.of_var id
  | Constant { const } -> (
      match P.of_const const with Some c -> c | None -> P.find @@ P.fix (E e))
  | o -> P.find @@ P.fix (E e)

let of_expr (module P : S) e =
  e |> Expr.ExprHashCons.of_expr |> of_hc_expr (module P)

let partial_eval_expr (module P : S) e =
  let read_var v =
    P.of_var v |> P.unfix |> function
    | Val v -> Some (VT.to_const v)
    | _ -> None
  in
  let e = Expr.BasilExpr.substitute read_var e in
  Algsimp.normalise @@ Expr_eval.partial_eval_expr e

let eval_expr (module P : S) e =
  let sub_vars =
    Expr.BasilExpr.cata (function
      | RVar ({ id } as r) ->
          let id = P.find_var id in
          Expr.ExprHashCons.fix (RVar { r with id })
      | o -> Expr.ExprHashCons.fix o)
  in
  let evaled = partial_eval_expr (module P : S) e |> of_expr (module P) in
  evaled

let to_hc_expr (module P : S) e =
  P.unfix e |> function
  | Value.Vr v ->
      Some
        (Expr.ExprHashCons.Constructors.rvar
           (UnionFind.find v |> UnionFind.get))
  | Value.Val v -> Some (Expr.ExprHashCons.of_expr @@ VT.to_const v)
  | E e -> Some e
  | Poison -> None

let extract_expr (module P : S) e =
  let e = partial_eval_expr (module P) e in
  of_expr (module P) e
  |> P.unfix
  |> ( function
  | Value.Vr v -> Some (Expr.BasilExpr.rvar (UnionFind.find v |> UnionFind.get))
  | Value.Val v -> Some (VT.to_const v)
  | E e -> Some (Expr.ExprHashCons.to_expr e)
  | _ -> None )
  |> Option.get_or ~default:e |> Expr_eval.partial_eval_expr

let count_subexpr (e : Expr.ExprHashCons.t) =
  Expr.ExprHashCons.cata
    Expr.AbstractExpr.(
      function RVar _ -> 3 | Constant _ -> 1 | e -> fold ( + ) 2 e)
    e

let merge_fn a b =
  (*Logs.debug (fun m -> m "unify %a %a" Value.pp a Value.pp b);*)
  match (a, b) with
  | Value.Vr i, Value.Vr j -> Value.Vr (merge_vars i j)
  | Value.Poison, _ | _, Value.Poison -> Value.Poison
  | Val i, Val j -> if not @@ VT.equal i j then Poison else Val i
  | Val i, _ | _, Val i -> Val i
  | E i, E j ->
      let l = count_subexpr i and r = count_subexpr j in
      if l < r then E i else E j
  | E i, _ | _, E i -> E i

let rec simplify (module P : S) (e : Expr.ExprHashCons.t) =
  let of_expr e =
    Expr.ExprHashCons.unfix e |> function
    | RVar { id } -> UnionFind.find @@ P.of_var id
    | Constant { const } -> (
        match P.of_const const with
        | Some c -> c
        | None -> P.find @@ P.fix (E e))
    | o -> P.find @@ P.fix (E e)
  in
  let to_hc = Expr.ExprHashCons.of_expr in
  let true_v = Expr.BasilExpr.boolconst true |> to_hc in
  let false_v = Expr.BasilExpr.boolconst false |> to_hc in
  let binexp ~op arg1 arg2 =
    Expr.ExprHashCons.Constructors.binexp ~op arg1 arg2
  in
  let unexp ~op arg1 = Expr.ExprHashCons.Constructors.unexp ~op arg1 in
  let intrin ~op args = Expr.ExprHashCons.Constructors.applyintrin ~op args in

  let equal e i = P.equal (of_expr e) (of_expr i) in
  let simplify = simplify (module P) in
  let expr = e in
  let expr =
    of_expr e |> P.find
    |> to_hc_expr (module P)
    |> Option.get_or ~default:expr
    |> Expr.ExprHashCons.unfix
  in
  let result =
    match expr with
    | Expr.AbstractExpr.BinaryExpr { op = `EQ; arg1; arg2 } ->
        let arg1 = simplify arg1 in
        let arg2 = simplify arg2 in
        if equal arg1 arg2 then true_v else binexp ~op:`EQ arg1 arg2
    | Expr.AbstractExpr.BinaryExpr { op = (`BVULE | `BVSLE) as op; arg1; arg2 }
      ->
        let arg1 = simplify arg1 in
        let arg2 = simplify arg2 in
        if equal arg1 arg2 then true_v else binexp ~op arg1 arg2
    | Expr.AbstractExpr.ApplyIntrin { op = `AND; args } ->
        let args = List.map simplify args in
        if List.for_all (equal true_v) args then true_v
        else if List.exists (equal false_v) args then false_v
        else intrin ~op:`AND args
    | Expr.AbstractExpr.ApplyIntrin { op = `OR; args } ->
        let args = List.map simplify args in
        if List.exists (equal true_v) args then true_v else intrin ~op:`AND args
    | o -> Expr.ExprHashCons.fix @@ Expr.AbstractExpr.map simplify o
  in
  let _ = P.merge merge_fn (of_expr e) (of_expr result) in
  result

let analyse_expr (module P : S) e =
  partial_eval_expr (module P) e
  |> Expr.ExprHashCons.of_expr
  |> simplify (module P)
  |> of_hc_expr (module P)
  |> fun o -> Some o

let analyse_phi (module P : S) lhs rhs =
  let lhs = P.of_var lhs in
  let rhs = List.map P.of_var rhs in
  match rhs with
  | [ h ] ->
      ignore (P.merge merge_fn h lhs);
      Some ()
  | h :: tl ->
      if List.for_all (P.equal h) tl then
        if not (P.equal lhs h) then (
          ignore (P.merge merge_fn h lhs);
          Some ())
        else None
      else None
  | _ -> None

let analyse_stmt (module P : S) stmt =
  let s =
    Stmt.map ~f_lvar:P.of_var ~f_rvar:P.of_var
      ~f_expr:(analyse_expr (module P))
      stmt
  in
  let did_anything = ref false in
  let cond_unif = function
    | a, Some b ->
        ignore @@ P.merge merge_fn a b;
        if not @@ P.equal a b then (
          ignore @@ P.merge merge_fn a b;
          did_anything := true)
        else ()
    | _ -> ()
  in
  (match s with Stmt.Instr_Assign { al } -> List.iter cond_unif al | _ -> ());
  if !did_anything then Some () else None

let analyse_stmt (module S : S) ~widen st (v : Analysis.Dataflow_graph.Vertex.t)
    =
    (*Logs.debug (fun m -> m "%s" (Analysis.Dataflow_graph.Vertex.show v));*)
  match snd v with
  | Entry | Return -> None
  | Stmt (widen, stmt) -> analyse_stmt (module S) stmt
  | Phi { lhs; rhs; widen_point } -> analyse_phi (module S) lhs rhs

let extract_var (module P : S) e =
  P.of_var e |> P.unfix |> function
  | Value.Vr v -> UnionFind.get @@ UnionFind.find v
  | _ -> e

let replace_phi (module P : S) (phi : Var.t Block.phi) =
  let extract_var = extract_var (module P) in
  let lhs = extract_var phi.lhs in
  let rhs = List.map (Pair.map_snd extract_var) phi.rhs in
  Some Block.{ lhs; rhs }

let phi_redundant (phi : Var.t Block.phi) =
  List.for_all (snd %> Var.equal phi.lhs) phi.rhs

let assigns_redundant assigns =
  let equal (v, e) =
    Expr.BasilExpr.unfix e |> function
    | RVar { id } -> Var.equal v id
    | _ -> false
  in
  let assigns = List.filter (not % equal) assigns in
  assigns

let filter_stmt stmt =
  match stmt with
  | Stmt.Instr_Assign { al; attrib } ->
      begin match assigns_redundant al with
      | [] -> None
      | al -> Some (Stmt.Instr_Assign { al; attrib })
      end
  | o -> Some o

let transform_proc (module P : S) =
  let extract_var = extract_var (module P) in
  let extract_expr = extract_expr (module P) in
  Procedure.map_blocks_nondet (fun (id, b) ->
      let b =
        b
        |> Block.map ~phi:Fun.id
             (Stmt.map ~f_lvar:extract_var ~f_rvar:extract_var
                ~f_expr:extract_expr)
      in
      Vector.filter_map_in_place filter_stmt b.stmts;
      { b with phis = List.filter (not % phi_redundant) b.phis })

let analyse_proc p =
  let module P = Pack () in
  Analysis.Dataflow_graph.SimpleSolver.fixpoint_fwd
    ~transfer:(analyse_stmt (module P))
    ~initial:() p;
  transform_proc (module P) p

let%expect_test "blah" =
  let module P = Pack () in
  let v = Var.create "blah" Boolean in
  let a = P.of_var v in
  let b = P.of_var v in
  if P.equal a b then print_endline "ok"

let%expect_test "blah2" =
  let module P = Pack () in
  let v = Var.create "blah" Boolean in
  let a = P.of_var v in
  let b = P.of_var v in
  let c = P.of_var (Var.create "c" Boolean) in
  let d = P.merge merge_fn a b in
  if P.equal d a then print_endline "ok"

let%expect_test "blah2" =
  let module P = Pack () in
  let v = Var.create "blah" Boolean in
  let value = of_expr (module P) (Expr.BasilExpr.boolconst true) in
  let a = P.of_var v in
  let d = P.merge merge_fn a value in
  let b = P.of_var v in
  let c = P.of_var (Var.create "c" Boolean) in
  let d = P.merge merge_fn a c in
  let d = P.merge merge_fn c b in
  let rvar = Expr.BasilExpr.rvar v in
  let e = P.find @@ of_expr (module P) rvar in
  let nv = P.of_var (Var.create "blah" Boolean) in
  let nnv = P.of_var v in
  if P.equal d a then print_endline "ok";
  print_endline (Expr.BasilExpr.to_string @@ extract_expr (module P) rvar);
  print_endline (Value.show @@ P.unfix e);
  print_endline (Value.show @@ P.unfix value);
  print_endline (Value.show @@ P.unfix b);
  print_endline (Value.show @@ P.unfix nv);
  print_endline (Value.show @@ P.unfix nnv)

let%expect_test "vars" =
  let a = Var.create "a" Boolean in
  let b = Var.create "a" Boolean in
  assert (Var.to_int a = Var.to_int b)
