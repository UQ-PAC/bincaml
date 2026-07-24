open Lang
open Lang.Common
open Expr

let transform_block (prog : Program.t) (proc : Program.proc)
    ((bid, block) : IDSet.elt * Program.bloc) : Program.bloc =
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

let transform_proc (prog : Program.t) (pid : IDSet.elt) (proc : Program.proc) :
    Program.proc =
  Procedure.map_blocks_nondet (transform_block prog proc) proc

let transform (prog : Program.t) : Program.t =
  Program.map_procedures (transform_proc prog) prog
