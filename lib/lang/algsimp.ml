(** Basic intra-expression algebraic simplifications *)

open Bincaml_util.Common
open Expr
open Ops

let normalise_bool
    (e : BasilExpr.t BasilExpr.abstract_expr BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  match e with
  | BinaryExpr { op = `IMPLIES; arg1; arg2 } ->
      Some
        (BasilExpr.applyintrin ~op:`OR
           [ fix arg1; BasilExpr.boolnot (fix arg2) ])
  | UnaryExpr { op = `BoolNOT; arg = UnaryExpr { op = `BoolNOT; arg } } ->
      Some arg
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `AND; args } } ->
      Some (BasilExpr.applyintrin ~op:`OR (List.map BasilExpr.boolnot args))
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `OR; args } } ->
      Some (BasilExpr.applyintrin ~op:`AND (List.map BasilExpr.boolnot args))
  | _ -> None

let algebraic_simplifications
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  (* trying to make views of abstract exprs simpler; but avoid disacarding the attribs.
     There's probably too much to think about still with writing rewriters like this. 

     We can build this into fold_with_type/rewrite_typed I guess.
   *)
  let orig_e (a, b, c) = a in

  (* orig expr, simplified view, expr type *)
  let fix_s e = fix (AbstractExpr.of_simple_view e) in
  let keep a = Some (fix (orig_e a)) in
  let to_s (v, t) = (v, AbstractExpr.simple_view v, t) in
  let s = AbstractExpr.simple_view (AbstractExpr.map to_s e) in
  match s with
  | Intrin (`BVConcat, (_, Intrin (`BVConcat, al), _) :: tl) ->
      Some (fix_s (Intrin (`BVConcat, al @ List.map (orig_e %> fix) tl)))
  | Binary (`BVADD, a, (_, C (`Bitvector i), _)) when is_zero i -> keep a
  | Binary (`BVSUB, a, (_, C (`Bitvector i), _)) when is_zero i -> keep a
  | Binary (`BVMUL, a, (_, C (`Bitvector i), _))
    when equal i @@ of_int ~size:(size i) 1 ->
      keep a
  | Binary (`BVAND, a, (_, C (`Bitvector i), _)) when is_zero i ->
      Some (bvconst (zero ~size:(size i)))
  | Binary (`BVAND, a, (_, C (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      keep a
  | Binary (`BVOR, a, (_, C (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      Some (bvconst @@ ones ~size:(size i))
  | Binary (`BVOR, a, (_, C (`Bitvector i), _)) when is_zero i -> keep a
  | Unary (`ZeroExtend 0, a) -> keep a
  | Unary (`SignExtend 0, a) -> keep a
  | Unary (`Extract (hi, 0), ((_, _, Bitvector sz) as a)) when hi = sz -> keep a
  | Unary (`BVNOT, (_, Unary (`BVNOT, a), _)) -> Some a
  | Unary (`BoolNOT, (_, Unary (`BoolNOT, a), _)) -> Some a
  | _ -> None

(*
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

type 'e rewriter_expr = {
  orig : 'e BasilExpr.abstract_expr BasilExpr.abstract_expr;
  typ : Types.t;
  e :
    ( BasilExpr.const,
      BasilExpr.var,
      BasilExpr.unary,
      BasilExpr.binary,
      BasilExpr.intrin,
      ( BasilExpr.const,
        BasilExpr.var,
        BasilExpr.unary,
        BasilExpr.binary,
        BasilExpr.intrin,
        'e )
      AbstractExpr.simple )
    AbstractExpr.simple;
}
*)

let alg_simp_rewriter e =
  let partial_eval_expr e =
    BasilExpr.rewrite ~rw_fun:Expr_eval.partial_eval_alg e
  in
  BasilExpr.rewrite_typed_two algebraic_simplifications (partial_eval_expr e)

let normalise e =
  let e = alg_simp_rewriter e in
  BasilExpr.rewrite_two normalise_bool e

let%expect_test "normalise" =
  let e =
    BasilExpr.boolnot @@ BasilExpr.boolnot @@ BasilExpr.boolnot
    @@ BasilExpr.applyintrin ~op:`AND
         [
           BasilExpr.boolnot
             (BasilExpr.boolnot (BasilExpr.rvar (Var.create "b" Boolean)));
           BasilExpr.rvar (Var.create "a" Boolean);
         ]
  in
  print_endline (BasilExpr.to_string e);
  let e = normalise e in
  print_endline (BasilExpr.to_string e);
  [%expect
    {|
    boolnot(boolnot(boolnot(booland(boolnot(boolnot(b:bool)), a:bool))))
    boolor(boolnot(b:bool), boolnot(a:bool))
    |}]
