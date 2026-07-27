open Lang
open Lang.Common
open Expr

(* This transformation inlines procedure summaries.
   This means three things:
   1. All procedure requires will be replaced with assumes at the top
      of the procedures entry block.
   2. All procedure ensures will be replaced with asserts at the end of
      the procedures return block.
   3. Any procedure call will have assert statements added before
      for the requires, and assumes added after for the ensures.
   It will also clear all procedure specification ensures/requires.
*)

let transform_block (prog : Program.t) (proc : Program.proc)
    ((bid, block) : IDSet.elt * Program.bloc) : Program.bloc =
  (* Inline summaries around any procedure call. *)
  let block =
    Block.flat_map ~phi:Common.id
      ( List.to_iter % function
        | Stmt.Instr_Call { attrib; lhs; procid; args } as stmt ->
            let subst_var varmap expression =
              BasilExpr.substitute
                (fun v ->
                  StringMap.get (Var.name v) varmap |> Option.map BasilExpr.rvar)
                expression
            in
            let subst_expr varmap expression =
              BasilExpr.substitute
                (fun v -> StringMap.get (Var.name v) varmap)
                expression
            in
            let call_proc = Program.proc prog procid in
            let spec = Procedure.specification call_proc in
            let requires =
              spec.requires
              |> List.map (fun e ->
                  Stmt.Instr_Assert
                    { attrib = StringMap.empty; body = subst_expr args e })
            in
            let ensures =
              spec.ensures
              |> List.map (fun e ->
                  Stmt.Instr_Assume
                    {
                      attrib = StringMap.empty;
                      body = subst_var lhs @@ subst_expr args e;
                      branch = false;
                    })
            in
            requires @ [ stmt ] @ ensures
        | other -> [ other ] )
      block
  in

  let entry_id = Procedure.get_blocks_succ proc Entry in
  let return_id = Procedure.get_blocks_pred proc Return in

  (* Add requires to entry block. *)
  let spec = Procedure.specification proc in
  let block =
    if match List.head_opt entry_id with Some bid -> true | _ -> false then
      Block.prepend_stmts block
        (List.map
           (fun e ->
             Stmt.Instr_Assume
               { attrib = StringMap.empty; body = e; branch = false })
           spec.requires)
    else block
  in

  (* Add ensures to return block. *)
  if match List.head_opt return_id with Some bid -> true | _ -> false then
    Block.append_stmts block
      (List.map
         (fun e -> Stmt.Instr_Assert { attrib = StringMap.empty; body = e })
         spec.ensures)
  else block

let transform_proc (prog : Program.t) (pid : IDSet.elt) (proc : Program.proc) :
    Program.proc =
  Procedure.map_blocks_nondet (transform_block prog proc) proc

let transform (prog : Program.t) : Program.t =
  Program.map_procedures (transform_proc prog) prog
  |> Program.map_procedures (fun id proc ->
      let spec = Procedure.specification proc in
      Procedure.set_specification proc { spec with ensures = []; requires = [] })
