(** Basic intra-expression algebraic simplifications *)

open Bincaml_util.Common
open Expr
open Ops

let normalise_bool e =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  let e = AbstractExpr.map fst e in
  match e with
  | BinaryExpr { op = `IMPLIES; arg1; arg2 } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`OR
           [ fix arg1; BasilExpr.boolnot (fix arg2) ])
  | UnaryExpr { op = `BoolNOT; arg = UnaryExpr { op = `BoolNOT; arg } } ->
      replace [%here] arg
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `AND; args } } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`OR (List.map BasilExpr.boolnot args))
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `OR; args } } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`AND (List.map BasilExpr.boolnot args))
  | _ -> None

let simplify_concat
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  match e with
  | ApplyIntrin { op = `BVConcat; args = (arg1, Bitvector 1) :: tl }
    when List.for_all (BasilExpr.equal (fix arg1)) (List.map (fst %> fix) tl) ->
      let count = List.length tl in
      replace [%here] (BasilExpr.sign_extend ~n_prefix_bits:count (fix arg1))
  | ApplyIntrin
      {
        op = `BVConcat;
        args =
          (UnaryExpr { op = `SignExtend ext; arg = arg1 }, Bitvector n)
          :: ((UnaryExpr { op = `Extract _; arg = v }, Bitvector 1) as arg2)
          :: tl;
      }
    when List.for_all
           (BasilExpr.equal (fix @@ fst arg2))
           (List.map (fst %> fix) tl) ->
      let count = n + List.length tl in
      replace [%here]
        (BasilExpr.sign_extend ~n_prefix_bits:count (fix @@ fst arg2))
  | UnaryExpr
      { op = `Extract (1, 0); arg = BinaryExpr { op = `BVLSHR; arg1; arg2 }, _ }
    ->
      let rshift =
        match unfix arg2 with
        | Constant { const = `Bitvector a } -> Z.to_int @@ Bitvec.value a
        | _ -> failwith ""
      in
      replace [%here]
        (BasilExpr.extract ~hi_excl:(rshift + 1) ~lo_incl:rshift arg1)
  | _ -> None

let to_steady equal f x =
  let rec loop x =
    let n = f x in
    if equal n x then n else loop n
  in
  loop x

let simp_concat_fix e =
  to_steady BasilExpr.equal (BasilExpr.rewrite_typed_two simplify_concat) e

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
  let keep here a = replace here (fix (orig_e a)) in
  let to_s (v, t) = (v, AbstractExpr.simple_view v, t) in
  let s = AbstractExpr.simple_view (AbstractExpr.map to_s e) in
  match s with
  | Intrin (`BVConcat, (_, Intrin (`BVConcat, al), _) :: tl) ->
      replace [%here]
        (fix_s (Intrin (`BVConcat, al @ List.map (orig_e %> fix) tl)))
  | Binary (`BVADD, a, (_, C (`Bitvector i), _)) when is_zero i ->
      keep [%here] a
  | Binary (`BVSUB, a, (_, C (`Bitvector i), _)) when is_zero i ->
      keep [%here] a
  | Binary (`BVMUL, a, (_, C (`Bitvector i), _))
    when equal i @@ of_int ~size:(size i) 1 ->
      keep [%here] a
  | Binary (`BVAND, a, (_, C (`Bitvector i), _)) when is_zero i ->
      replace [%here] (bvconst (zero ~size:(size i)))
  | Binary (`BVAND, a, (_, C (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      keep [%here] a
  | Binary (`BVOR, a, (_, C (`Bitvector i), _))
    when equal i (ones ~size:(size i)) ->
      replace [%here] (bvconst @@ ones ~size:(size i))
  | Binary (`BVOR, a, (_, C (`Bitvector i), _)) when is_zero i -> keep [%here] a
  | Unary (`ZeroExtend 0, a) -> keep [%here] a
  | Unary (`SignExtend 0, a) -> keep [%here] a
  | Unary (`Extract (hi, 0), ((_, _, Bitvector sz) as a)) when hi = sz ->
      keep [%here] a
  | Unary (`BVNOT, (_, Unary (`BVNOT, a), _)) -> replace [%here] a
  | Unary (`BoolNOT, (_, Unary (`BoolNOT, a), _)) -> replace [%here] a
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

let sequence (a : 'a -> BasilExpr.rewrite) (b : 'a -> BasilExpr.rewrite) e =
  match a e with None -> b e | e -> e

let alg_simp_rewriter ?visit e =
  let partial_eval_expr e =
    BasilExpr.rewrite ?visit ~rw_fun:Expr_eval.partial_eval_alg e
  in
  let open Option.Infix in
  e
  |> ( to_steady BasilExpr.equal @@ fun e ->
       e |> partial_eval_expr |> simp_concat_fix )
  |> BasilExpr.rewrite_typed_two ?visit
       (sequence simplify_concat algebraic_simplifications)

let normalise e =
  let e = alg_simp_rewriter e in
  BasilExpr.rewrite_typed_two normalise_bool e

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
