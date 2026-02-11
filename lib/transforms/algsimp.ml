(** Basic intra-expression algebraic simplifications *)

open Bincaml_util.Common
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
  | ApplyIntrin
      {
        op = `BVConcat;
        args = (ApplyIntrin { op = `BVConcat; args = al }, _) :: tl;
      } ->
      Some (BasilExpr.concatl @@ al @ List.map (fun i -> fix (fst i)) tl)
  | BinaryExpr
      { op = `BVADD; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when is_zero i ->
      keep arg1
  | BinaryExpr
      { op = `BVSUB; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when is_zero i ->
      keep arg1
  | BinaryExpr
      { op = `BVMUL; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when equal i @@ of_int ~size:(size i) 1 ->
      keep arg1
  | BinaryExpr { op = `BVAND; arg2 = Constant { const = `Bitvector i }, _ }
    when is_zero i ->
      Some (bvconst (zero ~size:(size i)))
  | BinaryExpr { op = `BVAND; arg1 = Constant { const = `Bitvector i }, _ }
    when is_zero i ->
      Some (bvconst (zero ~size:(size i)))
  | BinaryExpr
      { op = `BVAND; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when equal i (ones ~size:(size i)) ->
      keep arg1
  | BinaryExpr
      { op = `BVAND; arg2; arg1 = Constant { const = `Bitvector i }, _ }
    when equal i (ones ~size:(size i)) ->
      keep arg2
  | BinaryExpr { op = `BVOR; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when equal i (ones ~size:(size i)) ->
      Some (bvconst @@ ones ~size:(size i))
  | BinaryExpr { op = `BVOR; arg1; arg2 = Constant { const = `Bitvector i }, _ }
    when is_zero i ->
      keep arg1
  | UnaryExpr { op = `ZeroExtend 0; arg } -> keep arg
  | UnaryExpr { op = `SignExtend 0; arg } -> keep arg
  | UnaryExpr { op = `Extract (hi, 0); arg = a, Bitvector sz } when hi = sz ->
      Some (fix a)
  | UnaryExpr { op = `BVNOT; arg = UnaryExpr { op = `BVNOT; arg }, _ } ->
      Some arg
  | UnaryExpr { op = `BoolNOT; arg = UnaryExpr { op = `BoolNOT; arg }, _ } ->
      Some arg
  | _ -> None

let alg_simp_rewriter e =
  let partial_eval_expr e =
    BasilExpr.rewrite ~rw_fun:Lang.Expr_eval.partial_eval_alg e
  in
  BasilExpr.rewrite_typed_two algebraic_simplifications (partial_eval_expr e)
