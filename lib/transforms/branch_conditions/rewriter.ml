(** Rewrites boolean exprs in terms of flags to be in terms of numerical
    conditions. *)

open Lang
open Common
open Cfg_analysis

(** A type of condition as described in
    https://support.arm.com/documentation/ddi0487/mc/-Part-C-The-AArch64-Instruction-Set/-Chapter-C1-The-A64-Instruction-Set/-C1-2-Structure-of-the-A64-assembler-language/-C1-2-4-Condition-code?lang=en

    We track one computation for each flag read, noting that sometimes not all
    flags will be computed in the same way. *)
type t =
  | EQ of { z : Flags.computation }
  | CS of { c : Flags.computation }
  | MI of { n : Flags.computation }
  | VS of { v : Flags.computation }
  | HI of { c : Flags.computation; z : Flags.computation }
  | GE of { n : Flags.computation; v : Flags.computation }
  | GT of {
      n : Flags.computation;
      v : Flags.computation;
      z : Flags.computation;
    }
  | AL
  | Not of t
  | Top  (** Unknown condition type *)
[@@deriving show { with_path = false }, ord, eq]

(** Extracts a condition from a boolean expression *)
let rec extract_condition m e : t =
  let open Flags in
  let open Expr.AbstractExpr in
  match e with
  | BinaryExpr { op = `EQ; arg1; arg2 } -> (
      (* evaluate arg1 and arg2, if they are of the right form keep *)
      let arg1 = Eval.eval (flip FlagDomain.read m) arg1 in
      let arg2 = Eval.eval (flip FlagDomain.read m) arg2 in
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
      let a = Eval.eval (flip FlagDomain.read m) a in
      let b = Eval.eval (flip FlagDomain.read m) b in
      let c = Eval.eval (flip FlagDomain.read m) c in
      let d = Eval.eval (flip FlagDomain.read m) d in
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

(** Replace a condition with its interpretation as an expression *)
let rec condition_expr cond =
  let open Flags in
  let open Expr.BasilExpr in
  let value = function
    | Diff (e, e') -> binexp ~op:`BVSUB e e'
    | Sum (e, e') -> applyintrin ~op:`BVADD [ e; e' ]
    | Expr e -> e
    | Always -> bvconst (Bitvec.one ~size:1)
    | Never -> bvconst (Bitvec.zero ~size:1)
  in
  let zero_of e =
    match type_of e with
    | Bitvector size -> Some (bvconst (Bitvec.zero ~size))
    | _ -> None
  in
  match cond with
  | EQ { z = Diff (e, e') } -> Some (binexp ~op:`EQ e e')
  | EQ { z = Sum (e, e') } -> Some (binexp ~op:`EQ e (unexp ~op:`BVNEG e'))
  | EQ { z = Expr e } -> zero_of e |> Option.map (binexp ~op:`EQ e)
  | CS { c = Diff (e, e') } -> Some (binexp ~op:`BVULE e' e)
  | CS { c = Sum (e, e') } -> Some (binexp ~op:`BVULE (unexp ~op:`BVNEG e') e)
  | MI { n } ->
      let e = value n in
      zero_of e |> Option.map (binexp ~op:`BVSLT e)
  (* | VS c -> failwith "overflow rewrite is complicated" *)
  | HI { c = Diff (e, e') as c; z } when equiv_computations c z ->
      Some (binexp ~op:`BVULT e' e)
  | HI { c = Sum (e, e') as c; z } when equiv_computations c z ->
      Some (binexp ~op:`BVULT (unexp ~op:`BVNEG e') e)
  | HI { c = Never; z = Expr e } -> Some (boolconst false)
  | HI { c = Always; z = Expr e } ->
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVULT zero e)
  | GE { n = Diff (e, e') as c; v } when equiv_computations c v ->
      Some (binexp ~op:`BVSLE e' e)
  | GE { n = Sum (e, e') as c; v } when equiv_computations c v ->
      Some (binexp ~op:`BVSLE (unexp ~op:`BVNEG e') e)
  | GE { n; v = Never } ->
      let e = value n in
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVSLE zero e)
  | GT { n = Diff (e, e') as n; v; z }
    when equiv_computations n v && equiv_computations n z ->
      Some (binexp ~op:`BVSLT e' e)
  | GT { n = Sum (e, e') as n; v; z }
    when equiv_computations n v && equiv_computations n z ->
      Some (binexp ~op:`BVSLT (unexp ~op:`BVNEG e') e)
  | GT { n; v = Never; z } when equiv_computations n z ->
      let e = value n in
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVSLT zero e)
  | AL -> Some (boolconst true)
  | Not cond -> (
      let open Expr.AbstractExpr in
      match condition_expr cond with
      | Some (E (BinaryExpr { op = `BVULE; arg1; arg2 })) ->
          Some (binexp ~op:`BVULT arg2 arg1)
      | Some (E (BinaryExpr { op = `BVULT; arg1; arg2 })) ->
          Some (binexp ~op:`BVULE arg2 arg1)
      | Some (E (BinaryExpr { op = `BVSLE; arg1; arg2 })) ->
          Some (binexp ~op:`BVSLT arg2 arg1)
      | Some (E (BinaryExpr { op = `BVSLT; arg1; arg2 })) ->
          Some (binexp ~op:`BVSLE arg2 arg1)
      | Some (E (Constant { const = `Bool b })) -> Some (boolconst (not b))
      | Some e -> Some (Expr.BasilExpr.boolnot e)
      | None -> None)
  | _ -> None

let rw m e =
  let open Expr.BasilExpr in
  e |> extract_condition m |> condition_expr |> Expr.BasilExpr.replace_opt

(** Rewrite an expression's branch conditions in terms of flag analysis results
*)
let rewrite_expr (m : FlagDomain.t) e =
  Expr.BasilExpr.rewrite_down ~rw_fun:(rw m) e
