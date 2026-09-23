open Lang
open Common

open struct
  let equiv_exp e1 e2 = Expr.BasilExpr.(equal (drop_attrib e1) (drop_attrib e2))
end

module FlagTypes = struct
  type 'a gen_cond =
    | EQ of { z : 'a }
    | CS of { c : 'a }
    | MI of { n : 'a }
    | VS of { v : 'a }
    | HI of { c : 'a; z : 'a }
    | GE of { n : 'a; v : 'a }
    | GT of { n : 'a; v : 'a; z : 'a }
    | AL
    | Not of 'a gen_cond
    | Top  (** Unknown condition type *)
  [@@deriving show { with_path = false }, eq, ord]

  type computation =
    | Sum of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 + e2 *)
    | Diff of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 - e2 *)
    | Expr of Expr.BasilExpr.t  (** The result of evaluating an expr *)
    | Always
    | Never
    | Ite of cond * computation * computation
  [@@deriving eq, ord, show { with_path = false }]

  and cond = computation gen_cond [@@deriving show { with_path = false }]
  (** A type of condition as described in
      https://support.arm.com/documentation/ddi0487/mc/-Part-C-The-AArch64-Instruction-Set/-Chapter-C1-The-A64-Instruction-Set/-C1-2-Structure-of-the-A64-assembler-language/-C1-2-4-Condition-code?lang=en

      We track one computation for each flag read, noting that sometimes not all
      flags will be computed in the same way. *)

  and t =
    | Const of computation
    | V of computation  (** Overflow from computation *)
    | C of computation  (** Carry from computation *)
    | Z of computation  (** When computation is zero *)
    | N of computation  (** When computation is negative *)
  [@@deriving eq, ord, show { with_path = false }]
end

include FlagTypes

let rec equiv_computations c c' =
  let open Expr.BasilExpr in
  match (c, c') with
  | Sum (e1, e2), Sum (e1', e2') | Diff (e1, e2), Diff (e1', e2') ->
      equiv_exp e1 e1' && equiv_exp e2 e2'
  | Expr e, Expr e' -> equiv_exp e e'
  | Ite (co1, c1, c1'), Ite (co2, c2, c2') ->
      equiv_cond co1 co2 && equiv_computations c1 c2
      && equiv_computations c1' c2'
  | Always, Always | Never, Never -> true
  | (Sum _ | Diff _ | Expr _ | Ite _ | Always | Never), _ -> false

and equiv_cond co co' = equal_gen_cond equiv_computations co co'

let rec comp_contains_var v = function
  | Sum (e1, e2) | Diff (e1, e2) ->
      VarSet.mem v (Expr.BasilExpr.free_vars e1)
      || VarSet.mem v (Expr.BasilExpr.free_vars e2)
  | Expr e -> VarSet.mem v (Expr.BasilExpr.free_vars e)
  | Ite (_, c1, c2) -> comp_contains_var v c1 || comp_contains_var v c2
  | Never | Always -> false

(** Determine whether [v] exists in an expression in [f] *)
let contains_var v f =
  match f with V c | C c | Z c | N c | Const c -> comp_contains_var v c

let extract_overflow_cary arg1 arg2 =
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

module FlagLattice = struct
  include Analysis.Lattice_types.FlatLattice (struct
    include FlagTypes

    let name = "flag"
  end)

  module E = Lang.Expr.BasilExpr

  let eval_const op =
    match op with
    | `Bitvector k when Bitvec.equal k (Bitvec.zero ~size:1) -> V (Const Never)
    | `Bitvector k when Bitvec.equal k (Bitvec.one ~size:1) -> V (Const Always)
    | _ -> Top

  let eval_unop _ _ = Top
  let eval_binop _ _ _ = Top
  let eval_intrin _ _ = Top

  let contains_var v x =
    match x with Top -> false | Bot -> false | V f -> contains_var v f
end

module FlagEval = Analysis.Intra_analysis.EvalExpr (FlagLattice)
module FlagMap = Analysis.Intra_analysis.MapState (FlagLattice)

(** Extracts a condition from a boolean expression *)
let rec extract_condition m e : cond =
  let open Expr.AbstractExpr in
  match e with
  | BinaryExpr { op = `EQ; arg1; arg2 } -> (
      (* evaluate arg1 and arg2, if they are of the right form keep *)
      let arg1 = FlagEval.eval (flip FlagMap.read m) arg1 in
      let arg2 = FlagEval.eval (flip FlagMap.read m) arg2 in
      match (arg1, arg2) with
      | V (Z z), V (Const Always) -> EQ { z }
      | V (C c), V (Const Always) -> CS { c }
      | V (N n), V (Const Always) -> MI { n }
      | V (V v), V (Const Always) -> VS { v }
      | V (N n), V (V v | Const v) -> GE { n; v }
      | V (Const Always), V (Const Always) -> AL
      | V (Const Never), V (Const Always) -> Not AL
      | _ -> Top)
  | ApplyIntrin
      {
        op = `AND;
        args =
          [
            Expr.BasilExpr.E (BinaryExpr { op = `EQ; arg1 = a; arg2 = b });
            E (BinaryExpr { op = `EQ; arg1 = c; arg2 = d });
          ];
      } -> (
      (* there has to be a better way .......... *)
      let a = FlagEval.eval (flip FlagMap.read m) a in
      let b = FlagEval.eval (flip FlagMap.read m) b in
      let c = FlagEval.eval (flip FlagMap.read m) c in
      let d = FlagEval.eval (flip FlagMap.read m) d in
      match (a, b, c, d) with
      | V (C c | Const c), V (Const Always), V (Z z), V (Const Never) ->
          HI { c; z }
      | V (N n), V (V v | Const v), V (Z z), V (Const Never) -> GT { n; v; z }
      | _ -> Top)
  | UnaryExpr { op = `BoolNOT; arg } -> (
      match extract_condition m (Expr.BasilExpr.unfix arg) with
      | Not c -> c
      | c -> Not c)
  | _ -> Top
