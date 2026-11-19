open Lang
open Common

(* constant value type; todo: expand and unify with value type used by partial evaluator *)
module VT = struct
  type t = BV of Bitvec.t | I of Z.t | Bool of bool [@@deriving eq, ord]

  let to_const = function
    | BV i -> Expr.BasilExpr.bvconst i
    | Bool i -> Expr.BasilExpr.boolconst i
    | I i -> Expr.BasilExpr.intconst i
end

module Value = struct
  type op = Ops.AllOps.([ const | unary | binary | intrin | lambda ])

  let equal_op a b = Equal.poly a b

  type 'a t = E of op * 'a list | Vr of Var.t | Val of VT.t | Poison
  [@@deriving map, fold, eq]

  type cell = tc UnionFind.elem Fix.HashCons.cell
  and tc = V of cell t [@@unboxed]

  module Inner = struct
    type t = tc UnionFind.elem

    let equal a b =
      match (UnionFind.get a, UnionFind.get b) with
      | V a, V b -> equal Fix.HashCons.equal a b

    let hash (e : t) =
      match UnionFind.get e with
      | V e ->
          fold (fun a b -> Hash.pair Fun.id Fun.id (a, Fix.HashCons.hash b)) 7 e
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

      let fix (i : 'a expr) : t =
        H.make @@ UnionFind.find @@ UnionFind.make (Value.V i)

      let unfix (i : t) : 'a expr =
        match Fix.HashCons.data i |> UnionFind.find |> UnionFind.get with
        | V i -> i

      let union a b =
        H.make @@ UnionFind.union (Fix.HashCons.data a) (Fix.HashCons.data b)
    end

    module Recursion = Bincaml_util.Recursionscheme.Recursion (Consed)
    include Consed
    include Recursion

    let find = Fix.HashCons.data %> UnionFind.find %> H.make
    let of_var v = find @@ fix @@ Vr v

    let merge merge_fn a b =
      let unwrap = function Value.V a -> a in
      let merge_fn a b = Value.V (merge_fn (unwrap a) (unwrap b)) in
      find @@ H.make
      @@ UnionFind.merge merge_fn (Fix.HashCons.data a) (Fix.HashCons.data b)

    let equal a b =
      UnionFind.eq (Fix.HashCons.data @@ find a) (Fix.HashCons.data @@ find b)

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
  Expr.BasilExpr.unfix e |> function
  | RVar { id } -> Some (P.of_var id)
  | Constant { const } -> P.of_const const
  | _ -> None

let partial_eval_expr (module P : S) e =
  let read_var v =
    P.of_var v |> P.find |> P.unfix |> function
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
  | Some (Value.Vr v) -> Some (Expr.BasilExpr.rvar v)
  | Some (Value.Val v) -> Some (VT.to_const v)
  | _ -> None )
  |> Option.get_or ~default:e

let merge_fn a b =
  match (a, b) with
  | Value.Poison, _ | _, Value.Poison -> Value.Poison
  | Val i, Val j -> if not @@ VT.equal i j then Poison else Val i
  | Val i, Vr _ | Vr _, Val i -> Val i
  | Vr i, _ | _, Vr i -> Vr i
  | (E (op, args) as l), (E (op', args') as r) ->
      if List.length args < List.length args' then l else r
  | a, b -> a

let analyse_phi (module P : S) lhs rhs =
  let lhs = P.of_var lhs in
  let rhs = List.map P.of_var rhs in
  match rhs with
  | [ h ] ->
      ignore (P.merge merge_fn h lhs);
      Some ()
  | h :: tl ->
      if List.for_all (P.equal h) tl then (
        ignore (P.merge merge_fn h lhs);
        Some ())
      else None
  | _ -> None

let analyse_stmt (module P : S) stmt =
  let s =
    Stmt.map ~f_lvar:P.of_var ~f_rvar:P.of_var ~f_expr:(of_expr (module P)) stmt
  in
  let did_anything = ref false in
  let cond_unif = function
    | a, Some b ->
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
             (Stmt.map ~f_lvar:extract_var ~f_rvar:extract_var
                ~f_expr:extract_expr)
      in
      { b with phis = List.filter (not % phi_redundant) b.phis })

let analyse_proc p =
  let module S = Pack () in
  let _ =
    Analysis.Dataflow_graph.SimpleSolver.fixpoint_fwd
      ~transfer:(analyse_stmt (module S))
      ~initial:() p
  in
  transform_proc (module S) p
