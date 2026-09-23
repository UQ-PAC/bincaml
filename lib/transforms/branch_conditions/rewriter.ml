(** Rewrites boolean exprs in terms of flags to be in terms of numerical
    conditions. *)

open Lang
open Common
open Cfg_analysis

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
  e |> Flags.extract_condition m |> condition_expr |> Expr.BasilExpr.replace_opt

(** Rewrite an expression's branch conditions in terms of flag analysis results
*)
let rewrite_expr (m : Flags.FlagMap.t) e =
  Expr.BasilExpr.rewrite_down ~rw_fun:(rw m) e
