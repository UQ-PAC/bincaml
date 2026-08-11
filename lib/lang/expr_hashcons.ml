
open Common
open Containers
open Ops
open Expr


module HashExprFix = struct
  open BasilExpr
  include Ops.AllOps
  module Var = Var

  type nonrec 'e abstract_expr = 'e abstract_expr
  type var = Var.t
  type 'a cell = 'a Fix.HashCons.cell

  let equal_cell _ a b = Fix.HashCons.equal a b
  let compare_cell _ a b = Fix.HashCons.compare a b

  type t = expr_node_v cell

  and expr_node_v =
    | E of (const, Var.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
  [@@deriving eq, ord]

  module HashExpr = struct
    type t = expr_node_v

    let hash e : int =
      match e with
      | E e ->
          let e = AbstractExpr.drop_attrib e in
          let h = Hash.poly in
          AbstractExpr.hash h Var.hash h h h Hashtbl.hash Fix.HashCons.hash e

    let equal (i : t) (j : t) : bool =
      match (i, j) with
      | E i', E j' ->
          AbstractExpr.equal equal_const Var.equal equal_unary equal_binary
            equal_intrin Types.equal Fix.HashCons.equal
            (AbstractExpr.drop_attrib i')
            (AbstractExpr.drop_attrib j')
  end

  type typ = Types.t

  let top_typ = Types.Top

  module H = Fix.HashCons.ForHashedType (HashExpr)

  let fix i = H.make (E i)
  let unfix i = match Fix.HashCons.data i with E i -> i
end


(** Special Exprs *)
module ExprHashCons = struct
  include HashExprFix
  include Make (HashExprFix)

  let of_expr e =
    let alg e = fix (AbstractExpr.drop_attrib e) in
    BasilExpr.cata alg e

  let show_dbg (e : t) =
    let i = Fix.HashCons.id e in
    let h = Fix.HashCons.hash e in
    let ihash = Hashtbl.hash e in
    let full =
      unfix e
      |> BasilExpr.show_abstract (fun f e ->
          Format.fprintf f "%d" @@ Fix.HashCons.id e)
    in
    let t = cata BasilExpr.fix e |> BasilExpr.to_string_annot in
    Printf.sprintf "%d:%d:%d=%s==%s" i h ihash t full

  (*

  let cata_memo (alg : 'a abstract_expr -> 'a) =
    let g r t = AbstractExpr.map r (unfix t) |> alg in
    Memoiser.fix g

  (** memoised rewriter; will likely be slower than without memoisation unless
      there is significant sharing*)
  let rewrite_memo = rewrite ~cata:cata_memo

  (** memoised typed rewriter; will likely be slower than without memoisation
      unless there is significant sharing*)
  let rewrite_typed_memo = rewrite_typed ~cata:cata_memo

  (** memoised typed rewriter that unfolds an extre levels of each subexpr; will
      likely be slower than without memoisation unless there is significant
      sharing*)
  let rewrite_typed_two_memo = rewrite_typed_two ~cata:cata_memo
  *)
end

module IVarFix = struct
  include AllOps

  module Var = struct
    include Int

    let show v = Int.to_string v
  end

  type var = Int.t

  type t = expr_node_v

  and expr_node_v =
    | E of (const, Int.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  type typ = Types.t

  let top_typ = Types.Top
  let fix i = E i
  let unfix i = match i with E i -> i
end

module ExprIntVar = Make (IVarFix)

