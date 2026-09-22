open Lang
open Common

open struct
  let equiv_exp e1 e2 = Expr.BasilExpr.(equal (drop_attrib e1) (drop_attrib e2))
end

type computation =
  | Sum of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 + e2 *)
  | Diff of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 - e2 *)
  | Expr of Expr.BasilExpr.t  (** The result of evaluating an expr *)
  | Always
  | Never
[@@deriving eq, ord, show { with_path = false }]

type t =
  | Const of computation
  | V of computation  (** Overflow from computation *)
  | C of computation  (** Carry from computation *)
  | Z of computation  (** When computation is zero *)
  | N of computation  (** When computation is negative *)
[@@deriving eq, ord, show { with_path = false }]

let equiv_computations c c' =
  let open Expr.BasilExpr in
  match (c, c') with
  | Sum (e1, e2), Sum (e1', e2') | Diff (e1, e2), Diff (e1', e2') ->
      equiv_exp e1 e1' && equiv_exp e2 e2'
  | Expr e, Expr e' -> equiv_exp e e'
  | Always, Always | Never, Never -> true
  | (Sum _ | Diff _ | Expr _ | Always | Never), _ -> false

(** Determine whether [v] exists in an expression in [f] *)
let contains_var v f =
  match f with
  | V c | C c | Z c | N c | Const c -> (
      match c with
      | Sum (e1, e2) | Diff (e1, e2) ->
          VarSet.mem v (Expr.BasilExpr.free_vars e1)
          || VarSet.mem v (Expr.BasilExpr.free_vars e2)
      | Expr e -> VarSet.mem v (Expr.BasilExpr.free_vars e)
      | Never | Always -> false)

let extract_overflow_cary arg1 arg2 =
  let open Types in
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let sext_eq extension bv1 bv2 =
    Bitvec.(equal (sign_extend ~extension bv1) bv2)
  in
  let zext_eq extension bv1 bv2 =
    Bitvec.(equal (zero_extend ~extension bv1) bv2)
  in
  let is_one bv = Bitvec.(equal bv (one ~size:(size bv))) in
  match (unfix3 arg1, unfix3 arg2) with
  | ( UnaryExpr
        {
          op = `SignExtend s1;
          arg =
            ApplyIntrin
              { op = `BVADD; args = [ a; Constant { const = `Bitvector bv1 } ] };
        },
      ApplyIntrin
        {
          op = `BVADD;
          args =
            [
              UnaryExpr { op = `SignExtend s2; arg = c };
              Constant { const = `Bitvector bv2 };
            ];
        } )
    when s1 = s2 && s1 > 0 && equiv_exp (fix a) (fix c) && sext_eq s1 bv1 bv2 ->
      if Bitvec.is_negative bv1 then
        Some (V (Diff (fix a, bvconst (Bitvec.neg bv1))))
      else Some (V (Sum (fix a, bvconst bv1)))
  | ( UnaryExpr
        {
          op = `SignExtend s1;
          arg = ApplyIntrin { op = `BVADD; args = [ a; b ] };
        },
      ApplyIntrin
        {
          op = `BVADD;
          args =
            [
              UnaryExpr { op = `SignExtend s2; arg = c };
              UnaryExpr { op = `SignExtend s3; arg = d };
            ];
        } )
    when s1 = s2 && s2 = s3 && s1 > 0
         && equiv_exp (fix a) (fix c)
         && equiv_exp (fix b) (fix d) ->
      Some (V (Sum (fix a, fix b)))
  | ( UnaryExpr
        {
          op = `SignExtend s1;
          arg = BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b };
        },
      BinaryExpr
        {
          op = `BVSUB;
          arg1 = UnaryExpr { op = `SignExtend s2; arg = c };
          arg2 = UnaryExpr { op = `SignExtend s3; arg = d };
        } )
    when s1 = s2 && s2 = s3 && s1 > 0
         && equiv_exp (fix a) (fix c)
         && equiv_exp (fix b) (fix d) ->
      Some (V (Diff (fix a, fix b)))
  | ( UnaryExpr
        {
          op = `ZeroExtend z1;
          arg =
            ApplyIntrin
              { op = `BVADD; args = [ a; Constant { const = `Bitvector bv1 } ] };
        },
      ApplyIntrin
        {
          op = `BVADD;
          args =
            [
              UnaryExpr { op = `ZeroExtend z2; arg = c };
              Constant { const = `Bitvector bv2 };
            ];
        } )
    when z1 = z2 && z1 > 0 && equiv_exp (fix a) (fix c) && zext_eq z1 bv1 bv2 ->
      if Bitvec.is_negative bv1 then
        Some (C (Diff (fix a, bvconst (Bitvec.neg bv1))))
      else Some (C (Sum (fix a, bvconst bv1)))
  | ( UnaryExpr
        {
          op = `ZeroExtend z1;
          arg = ApplyIntrin { op = `BVADD; args = [ a; b ] };
        },
      ApplyIntrin
        {
          op = `BVADD;
          args =
            [
              UnaryExpr { op = `ZeroExtend z2; arg = c };
              UnaryExpr { op = `ZeroExtend z3; arg = d };
            ];
        } )
    when z1 = z2 && z2 = z3 && z1 > 0
         && equiv_exp (fix a) (fix c)
         && equiv_exp (fix b) (fix d) ->
      Some (C (Sum (fix a, fix b)))
  | ( UnaryExpr
        {
          op = `ZeroExtend z1;
          arg = BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b };
        },
      ApplyIntrin
        {
          op = `BVADD;
          args =
            [
              UnaryExpr { op = `ZeroExtend z2; arg = c };
              UnaryExpr
                {
                  op = `ZeroExtend z3;
                  arg = UnaryExpr { op = `BVNOT; arg = d };
                };
              Constant { const = `Bitvector bv };
            ];
        } )
    when z1 = z2 && z2 = z3 && z1 > 0
         && equiv_exp (fix a) (fix c)
         && equiv_exp (fix b) d
         && is_one bv ->
      Some (C (Diff (fix a, fix b)))
  | _ -> None

let extract_expr arg =
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  match unfix2 arg with
  | ApplyIntrin
      { op = `BVADD; args = [ a; Constant { const = `Bitvector bv } ] } ->
      if Bitvec.is_negative bv then Diff (fix a, bvconst (Bitvec.neg bv))
      else Sum (fix a, bvconst bv)
  | ApplyIntrin { op = `BVADD; args = [ a; b ] } -> Sum (fix a, fix b)
  | BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b } -> Diff (fix a, fix b)
  | a -> Expr (fix2 a)

let extract_semantics e =
  let e = Algsimp.normalise e in
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  match unfix3 e with
  | Constant { const = `Bitvector k } when Bitvec.equal k (Bitvec.zero ~size:1)
    ->
      Some (Const Never)
  | Constant { const = `Bitvector k } when Bitvec.equal k (Bitvec.one ~size:1)
    ->
      Some (Const Always)
  | UnaryExpr
      {
        op = `BVNOT;
        arg =
          UnaryExpr
            { op = `BOOLTOBV1; arg = BinaryExpr { op = `EQ; arg1; arg2 } };
      } ->
      extract_overflow_cary arg1 arg2
  | UnaryExpr
      {
        op = `BOOLTOBV1;
        arg =
          BinaryExpr
            { op = `EQ; arg1; arg2 = Constant { const = `Bitvector bv } };
      }
    when Bitvec.is_zero bv ->
      Some (Z (extract_expr (fix arg1)))
  | UnaryExpr { op = `Extract (e1, e2); arg }
    when e1 = e2 + 1
         && Option.equal ( = ) (Types.bit_width @@ type_of (fix2 arg)) (Some e1)
    ->
      Some (N (extract_expr (fix2 arg)))
  | _ -> None
