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
    | Vr of Var.t
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

(*
module Rec = Bincaml_util.Recursionscheme.Recursion (Value)
 *)

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

    module Memo = Fix.Memoize.ForHashedType (Consed)

    let fix_impl = Memo.memoize (fun (v : Consed.t) -> UnionFind.make v)
    let fix e = fix_impl (Consed.fix e)
    let unfix e = UnionFind.find e |> UnionFind.get |> Consed.unfix
    let find = UnionFind.find
    let of_var v = fix @@ Value.Vr v

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

let of_expr (module P : S) e =
  let e = Expr.ExprHashCons.of_expr e in
  Expr.ExprHashCons.unfix e |> function
  | RVar { id } -> Some (P.of_var id)
  | Constant { const } -> P.of_const const
  | o -> Some (P.fix (E e))

let partial_eval_expr (module P : S) e =
  let read_var v =
    P.of_var v |> P.unfix |> function
    | Val v -> Some (VT.to_const v)
    | _ -> None
  in
  let e = Expr.BasilExpr.substitute read_var e in
  Expr_eval.partial_eval_expr e

let eval_expr (module P : S) e =
  partial_eval_expr (module P : S) e |> of_expr (module P)

let extract_expr (module P : S) e =
  let e = partial_eval_expr (module P) e in
  of_expr (module P) e
  |> Option.map P.unfix
  |> ( function
  | Some (Value.Vr v) -> None
  | Some (Value.Val v) -> Some (VT.to_const v)
  | _ -> None )
  |> Option.get_or ~default:e

let merge_fn a b =
  Logs.debug (fun m -> m "unify %a %a" Value.pp a Value.pp b);
  match (a, b) with
  | Value.Poison, _ | _, Value.Poison -> Value.Poison
  | Val i, Val j -> if not @@ VT.equal i j then Poison else Val i
  | Val i, _ | _, Val i -> Val i
  | Vr i, _ | _, Vr i -> Vr i
  | a, b -> a

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
    Stmt.map ~f_lvar:P.of_var ~f_rvar:P.of_var ~f_expr:(of_expr (module P)) stmt
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
  Logs.debug (fun m -> m "%s" (Analysis.Dataflow_graph.Vertex.show v));
  match snd v with
  | Entry | Return -> None
  | Stmt (widen, stmt) -> analyse_stmt (module S) stmt
  | Phi { lhs; rhs; widen_point } -> analyse_phi (module S) lhs rhs

let extract_var (module P : S) e =
  P.of_var e |> P.unfix |> function Value.Vr v -> v | _ -> e

let replace_phi (module P : S) (phi : Var.t Block.phi) =
  let extract_var = extract_var (module P) in
  let lhs = extract_var phi.lhs in
  let rhs = List.map (Pair.map_snd extract_var) phi.rhs in
  Some Block.{ lhs; rhs }

let phi_redundant (phi : Var.t Block.phi) =
  List.for_all (snd %> Var.equal phi.lhs) phi.rhs

let transform_proc (module P : S) =
  let extract_var = extract_var (module P) in
  let extract_expr = extract_expr (module P) in
  Procedure.map_blocks_nondet (fun (id, b) ->
      let b =
        b
        |> Block.map ~phi:Fun.id
             (Stmt.map ~f_lvar:Fun.id ~f_rvar:extract_var ~f_expr:extract_expr)
      in
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
  let value =
    Option.get_exn_or "non-value?"
    @@ of_expr (module P) (Expr.BasilExpr.boolconst true)
  in
  let a = P.of_var v in
  let d = P.merge merge_fn a value in
  let b = P.of_var v in
  let c = P.of_var (Var.create "c" Boolean) in
  let d = P.merge merge_fn a c in
  let d = P.merge merge_fn c b in
  let rvar = Expr.BasilExpr.rvar v in
  let e = P.find @@ Option.get_exn_or "" @@ of_expr (module P) rvar in
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
