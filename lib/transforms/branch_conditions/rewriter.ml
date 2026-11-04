(** Rewrites boolean exprs in terms of flags to be in terms of numerical
    conditions.

    ccmp (conditional compare) instructions require extra work to handle. We
    store ccmp results as if-then-else computations where one branch is
    definitely either Always or Never. This mirrors the ccmp instruction's
    logic, where the four flags are set to a constant if the condition required
    to execute the compare isn't met. From this, we have effectively
    [nzcv = if cond then cond2 else k] where k is a constant. When branching on
    this flag field, we have two cases being whether k does or does not branch
    in the case that cond is false. We can write a branching condition as
    [cond && cond2 || !cond && k] and if we unwrap the logic, we get that if [k]
    is true this is [cond ==> cond2], and if [k] is false [cond && cond2]. *)

open Lang
open Common
open Cfg_analysis

open struct
  let value = function
    | Flags.Diff (e, e') -> Some (Expr.BasilExpr.binexp ~op:`BVSUB e e')
    | Sum (e, e') -> Some (Expr.BasilExpr.applyintrin ~op:`BVADD [ e; e' ])
    | Expr e -> Some e
    | Always -> Some (Expr.BasilExpr.bvconst (Bitvec.one ~size:1))
    | Never -> Some (Expr.BasilExpr.bvconst (Bitvec.zero ~size:1))
    | Ite _ -> None

  let is_lit = function
    | Flags.Always | Never -> true
    | Sum _ | Diff _ | Expr _ | Ite _ -> false

  let zero_of e =
    match Expr.BasilExpr.type_of e with
    | Bitvector size -> Some (Expr.BasilExpr.bvconst (Bitvec.zero ~size))
    | _ -> None
end

(** Replace a condition with its interpretation as an expression *)
let rec condition_expr cond =
  let open Flags in
  let open Expr.BasilExpr in
  match cond with
  | EQ { z } -> eq_expr z
  | CS { c } -> cs_expr c
  | MI { n } -> mi_expr n
  (* | VS c -> failwith "overflow rewrite is complicated" *)
  | HI { c; z } -> hi_expr c z
  | GE { n; v } -> ge_expr n v
  | GT { n; v; z } -> gt_expr n v z
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

(** Handle Ites for conditions of the form [FLAG == 1] *)
and handle_ite_1 f comp =
  let open Flags in
  let open Expr.BasilExpr in
  let open Option.Infix in
  match comp with
  | Ite (cond, c, Always) ->
      let* cond = condition_expr cond in
      let* c = f c in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, Always, c) ->
      let* cond = condition_expr (Not cond) in
      let* c = f c in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, c, Never) ->
      let* cond = condition_expr cond in
      let* c = f c in
      Some (binexp ~op:`AND cond c)
  | Ite (cond, Never, c) ->
      let* cond = condition_expr (Not cond) in
      let* c = f c in
      Some (binexp ~op:`AND cond c)
  | _ -> None

and eq_expr z =
  let open Flags in
  let open Expr.BasilExpr in
  match z with
  | Ite _ -> handle_ite_1 eq_expr z
  | Diff (e, e') -> Some (binexp ~op:`EQ e e')
  | Sum (e, e') -> Some (binexp ~op:`EQ e (unexp ~op:`BVNEG e'))
  | Expr e -> zero_of e |> Option.map (binexp ~op:`EQ e)
  | _ -> None

and cs_expr c =
  let open Flags in
  let open Expr.BasilExpr in
  match c with
  | Ite _ -> handle_ite_1 cs_expr c
  | Diff (e, e') -> Some (binexp ~op:`BVULE e' e)
  | Sum (e, e') -> Some (binexp ~op:`BVULE (unexp ~op:`BVNEG e') e)
  | _ -> None

and mi_expr n =
  let open Flags in
  let open Expr.BasilExpr in
  let open Option.Infix in
  match n with
  | Ite _ -> handle_ite_1 mi_expr n
  | e ->
      let* e = value n in
      zero_of e |> Option.map (binexp ~op:`BVSLT e)

and hi_expr c z =
  let open Flags in
  let open Expr.BasilExpr in
  let open Option.Infix in
  match (c, z) with
  | Ite (cond, c, Always), Ite (cond', c', Never) when equiv_cond cond cond' ->
      let* cond = condition_expr cond in
      let* c = hi_expr c c' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, Always, c), Ite (cond', Never, c') when equiv_cond cond cond' ->
      let* cond = condition_expr (Not cond) in
      let* c = hi_expr c c' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, c, o), Ite (cond', c', o')
    when equiv_cond cond cond' && is_lit o && is_lit o' ->
      let* cond = condition_expr cond in
      let* c = hi_expr c c' in
      Some (binexp ~op:`AND cond c)
  | Ite (cond, o, c), Ite (cond', o', c')
    when equiv_cond cond cond' && is_lit o && is_lit o' ->
      let* cond = condition_expr (Not cond) in
      let* c = hi_expr c c' in
      Some (binexp ~op:`AND cond c)
  | Diff (e, e'), z when equiv_computations c z -> Some (binexp ~op:`BVULT e' e)
  | Sum (e, e'), z when equiv_computations c z ->
      Some (binexp ~op:`BVULT (unexp ~op:`BVNEG e') e)
  | Never, Expr e -> Some (boolconst false)
  | Always, Expr e ->
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVULT zero e)
  | _ -> None

and ge_expr n v =
  let open Flags in
  let open Expr.BasilExpr in
  let open Option.Infix in
  match (n, v) with
  | Ite (cond, c, Always), Ite (cond', c', Always)
  | Ite (cond, c, Never), Ite (cond', c', Never)
    when equiv_cond cond cond' ->
      let* cond = condition_expr cond in
      let* c = ge_expr c c' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, Always, c), Ite (cond', Always, c')
  | Ite (cond, Never, c), Ite (cond', Never, c')
    when equiv_cond cond cond' ->
      let* cond = condition_expr (Not cond) in
      let* c = ge_expr c c' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, c, o), Ite (cond', c', o')
    when equiv_cond cond cond' && is_lit o && is_lit o' ->
      let* cond = condition_expr cond in
      let* c = ge_expr c c' in
      Some (binexp ~op:`AND cond c)
  | Ite (cond, o, c), Ite (cond', o', c')
    when equiv_cond cond cond' && is_lit o && is_lit o' ->
      let* cond = condition_expr (Not cond) in
      let* c = ge_expr c c' in
      Some (binexp ~op:`AND cond c)
  | Diff (e, e'), v when equiv_computations n v -> Some (binexp ~op:`BVSLE e' e)
  | Sum (e, e'), v when equiv_computations n v ->
      Some (binexp ~op:`BVSLE (unexp ~op:`BVNEG e') e)
  | n, Never ->
      let* e = value n in
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVSLE zero e)
  | _ -> None

and gt_expr n v z =
  let open Flags in
  let open Expr.BasilExpr in
  let open Option.Infix in
  match (n, v, z) with
  | Ite (cond, c, Always), Ite (cond', c', Always), Ite (cond'', c'', Never)
  | Ite (cond, c, Never), Ite (cond', c', Never), Ite (cond'', c'', Never)
    when equiv_cond cond cond' && equiv_cond cond cond'' ->
      let* cond = condition_expr cond in
      let* c = gt_expr c c' c'' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, Always, c), Ite (cond', Always, c'), Ite (cond'', Never, c'')
  | Ite (cond, Never, c), Ite (cond', Never, c'), Ite (cond'', Never, c'')
    when equiv_cond cond cond' && equiv_cond cond cond'' ->
      let* cond = condition_expr (Not cond) in
      let* c = gt_expr c c' c'' in
      Some (binexp ~op:`IMPLIES cond c)
  | Ite (cond, c, o), Ite (cond', c', o'), Ite (cond'', c'', o'')
    when equiv_cond cond cond' && equiv_cond cond cond'' && is_lit o
         && is_lit o' && is_lit o'' ->
      let* cond = condition_expr cond in
      let* c = gt_expr c c' c'' in
      Some (binexp ~op:`AND cond c)
  | Ite (cond, o, c), Ite (cond', o', c'), Ite (cond'', o'', c'')
    when equiv_cond cond cond' && equiv_cond cond cond'' && is_lit o
         && is_lit o' && is_lit o'' ->
      let* cond = condition_expr (Not cond) in
      let* c = gt_expr c c' c'' in
      Some (binexp ~op:`AND cond c)
  | Diff (e, e'), v, z when equiv_computations n v && equiv_computations n z ->
      Some (binexp ~op:`BVSLT e' e)
  | Sum (e, e'), v, z when equiv_computations n v && equiv_computations n z ->
      Some (binexp ~op:`BVSLT (unexp ~op:`BVNEG e') e)
  | n, Never, z when equiv_computations n z ->
      let* e = value n in
      zero_of e |> Option.map (fun zero -> binexp ~op:`BVSLT zero e)
  | _ -> None

let rw m e =
  let open Expr.BasilExpr in
  e |> Flags.extract_condition m |> condition_expr |> Expr.BasilExpr.replace_opt

(** Rewrite an expression's branch conditions in terms of flag analysis results
*)
let rewrite_expr (m : Flags.FlagMap.t) e =
  Expr.BasilExpr.rewrite_down ~rw_fun:(rw m) e
