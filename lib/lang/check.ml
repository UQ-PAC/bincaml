open Common
open Procedure

exception IRWellformed of string

let src =
  Logs.Src.create ~doc:("IR invariant checks: " ^ __FILE__) "wellformedness"

module Logs = (val Logs.src_log src : Logs.LOG)

let formal_params p =
  let c =
    Procedure.formal_in_params p
    |> StringMap.for_all (fun k v -> String.equal (Var.name v) k)
    && Procedure.formal_out_params p
       |> StringMap.for_all (fun k v -> String.equal (Var.name v) k)
  in
  if not c then
    raise (IRWellformed "formal parameter name differs from variable")

let sigil_ok v =
  let s = Var.name v |> String.take 1 in
  if Var.is_local v && String.equal s "$" then
    raise
    @@ IRWellformed
         ("local " ^ Var.to_string v ^ "should not have global sigil $");
  if Var.is_global v && (not @@ String.equal s "$") then
    raise
    @@ IRWellformed ("global " ^ Var.to_string v ^ " should have global sigil $");
  ()

let variables_wf p =
  let ref_vars = ref StringMap.empty in
  let ref_var v =
    match StringMap.find_opt (Var.name v) !ref_vars with
    | Some v' ->
        if not (Var.equal v' v) then
          raise
            (IRWellformed
               ("non-equal variables with same name: " ^ Var.show v ^ " "
              ^ Var.show v'))
    | _ -> ref_vars := StringMap.add (Var.name v) v !ref_vars
  in
  let spec = Procedure.specification p in
  let var_is_ok n =
    sigil_ok n;
    ref_var n;
    (if Var.is_local n then
       try ignore @@ Procedure.lookup_local_decl p (Var.name n)
       with Not_found ->
         raise
           (IRWellformed
              ("local " ^ Var.to_string n ^ " is not declared in "
              ^ ID.to_string (Procedure.id p))));
    if
      Var.is_global n
      && (not @@ List.exists (fun v -> Var.equal v n) spec.captures_globs)
    then
      raise
        (IRWellformed
           ("global " ^ Var.to_string n ^ " is not in capture list of "
           ^ (Procedure.id p |> ID.to_string)))
  in

  let m = ref VarSet.empty in
  let write v =
    if Var.is_local v && Var.is_const v then
      if VarSet.mem v !m then
        raise
          (IRWellformed
             ("constant local written more than once: " ^ Var.to_string v))
      else m := VarSet.add v !m
  in
  let check_lvar v =
    (*sigil_ok v;*)
    write v;
    if Var.is_local v then var_is_ok v
    else if not @@ List.exists (fun e -> Var.equal v e) spec.modifies_globs then (
      Logs.debug (fun m ->
          m "%s"
            (Procedure.pretty Var.pretty Var.pretty Expr.BasilExpr.pretty p
            |> Containers_pp.Pretty.to_string ~width:80));
      raise
        (IRWellformed
           ("written global " ^ Var.to_string v ^ " is not in modifies list of "
           ^ (Procedure.id p |> ID.to_string))))
    else ()
  in
  let check e = Expr.BasilExpr.free_vars_iter e |> Iter.iter var_is_ok in
  List.iter check spec.requires;
  List.iter check spec.ensures;
  List.iter check spec.rely;
  List.iter check spec.guarantee;
  Procedure.iter_blocks p (fun (_, b) ->
      Block.read_vars_iter b |> Iter.iter var_is_ok);
  Procedure.iter_blocks p (fun (_, b) ->
      Block.assigned_vars_iter b |> Iter.iter check_lvar)

let wf_checks p =
  try
    formal_params p;
    variables_wf p
  with IRWellformed e -> Logs.err (fun m -> m "%s" e)
