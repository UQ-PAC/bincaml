(** Basic intra-expression algebraic simplifications *)

open Util.Common
open Lang
open Expr
open Ops

let algebraic_simplifications
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  let keep a = Some (fix (fst a)) in
  match e with
  | ApplyIntrin (`BVConcat, (ApplyIntrin (`BVConcat, al), _) :: tl) ->
      Some
        (fix (ApplyIntrin (`BVConcat, al @ List.map (fun i -> fix (fst i)) tl)))
  | BinaryExpr (`BVADD, a, (Constant (`Bitvector i), _)) when is_zero i ->
      keep a
  | BinaryExpr (`BVSUB, a, (Constant (`Bitvector i), _)) when is_zero i ->
      keep a
  | BinaryExpr (`BVMUL, a, (Constant (`Bitvector i), _))
    when equal i @@ of_int ~size:(size i) 1 ->
      keep a
  | BinaryExpr (`BVAND, a, (Constant (`Bitvector i), _)) when is_zero i ->
      Some (bvconst (zero ~size:(size i)))
  | BinaryExpr (`BVAND, a, (Constant (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      keep a
  | BinaryExpr (`BVOR, a, (Constant (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      Some (bvconst @@ ones ~size:(size i))
  | BinaryExpr (`BVOR, a, (Constant (`Bitvector i), _)) when is_zero i -> keep a
  | UnaryExpr (`ZeroExtend 0, a) -> keep a
  | UnaryExpr (`SignExtend 0, a) -> keep a
  | UnaryExpr (`Extract (hi, 0), (a, Bitvector sz)) when hi = sz -> Some (fix a)
  | UnaryExpr (`BVNOT, (UnaryExpr (`BVNOT, a), _)) -> Some a
  | UnaryExpr (`BoolNOT, (UnaryExpr (`BoolNOT, a), _)) -> Some a
  | _ -> None

let alg_simp_rewriter e =
  let partial_eval_expr e =
    BasilExpr.rewrite ~rw_fun:Lang.Expr_eval.partial_eval_alg e
  in
  BasilExpr.rewrite_typed_two algebraic_simplifications (partial_eval_expr e)
