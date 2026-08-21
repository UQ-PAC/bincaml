(** Renames variable definitions and usages, and builds a def-use and use-def
    chain*)

open Bincaml_util.Common
open Lang
open Lang.Common
open Containers
open Datastructures

(** Creates a fresh version of a variable, declares it and adds it to web *)
let create_v' old_v (info : ssi_info) =
  let v' =
    Procedure.fresh_var ~pure:true ~name:(Var.name old_v) info.proc
      (Var.typ old_v)
  in
  let new_web = VarSet.add v' info.web in
  (Procedure.decl_local info.proc v', { info with web = new_web })

(** Returns a procedure that has renamed v, and the relative transformed
    non-actual instructions*)
let rename (v : Var.t) (bot_var : Var.t) (cfg : Dom.t)
    (dom_functions : Dom.dom_functions) (split_info : ssi_info) =
  (* Stack <- new *)
  let stack : (Var.t * Instruction.t) Stack.t = Stack.create () in

  (* Returns the ssi_info with replaced inst' *)
  let set_def (curr_info : ssi_info) (inst : Instruction.t) =
    match inst with
    | Instruction.Formal_In vars ->
        (* We don't redefine the formal-in parameter, since it gets a bit
            messy interprocedurally. *)
        let defs' = DefUseMap.add curr_info.defs v inst in
        Stack.push (v, inst) stack;
        let web' = VarSet.add v curr_info.web in
        { curr_info with defs = defs'; web = web' }
    | _ ->
        (* Let v' be a fresh version of v *)
        let v', curr_info = create_v' v curr_info in

        (* Replace the defs of v by v' in inst *)
        let (inst' : Instruction.t) = Instruction.replace_defs v v' inst in

        (* Set Def(v') = inst' *)
        let defs' = DefUseMap.add curr_info.defs v' inst' in

        (* stack.push(v') *)
        Stack.push (v', inst') stack;

        let proc' = replace_instruction inst inst' curr_info.proc in
        let nai' =
          InstructionSet.map
            (fun old_nai_inst ->
              if Instruction.equal inst old_nai_inst then inst'
              else old_nai_inst)
            curr_info.non_actual_insts
        in
        { curr_info with proc = proc'; non_actual_insts = nai'; defs = defs' }
  in

  (* We have an optional og_bid here to differentiate between when set_use is
      called on a statement, and when it is called on a phi node located in the
      sucessor m to the current node n. In the latter case, we need the block id of n to
      know which variable in the rhs of a phi we want to edit. *)
  let set_use ?(og_bid : ID.t option) (curr_info : ssi_info)
      (inst : Instruction.t) =
    (* while Def(stack.peek()) does not dominate inst do *)
    let rec pop_while_not_dominating instruction =
      match Stack.top_opt stack with
      | None -> ()
      | Some (v', inst') ->
          (* This is assuming that we have constructed set_def correctly, so that all
              variables only have one definition instruction. If not, then we are in trouble *)
          if
            not
              (instruction_dominates og_bid dom_functions.dom inst' instruction)
          then (
            ignore (Stack.pop stack);
            pop_while_not_dominating instruction)
    in
    pop_while_not_dominating inst;

    (* v' <- stack.peek() *)
    let v' =
      Option.value (Stack.top_opt stack) ~default:(bot_var, inst) |> fst
    in

    match inst with
    | Instruction.Formal_Out vars ->
        (* Produces a copy to the unaltered formal-out variable using the
             version of the formal-out variable at the top of the stack *)
        let copy_stmt =
          Stmt.Instr_Assign
            { al = [ (v, Expr.BasilExpr.rvar v') ]; attrib = Attrib.empty }
        in
        let new_proc =
          Procedure.modify_block curr_info.proc (Option.get og_bid)
            (fun block -> Block.append_stmts block [ copy_stmt ])
        in
        ({ curr_info with proc = new_proc }, inst)
    | _ ->
        (* Replace the uses of v by v' in inst *)
        let inst' =
          if Option.is_some og_bid then
            Instruction.replace_uses ~pred_block_id:(Option.get og_bid) v v'
              inst
          else Instruction.replace_uses v v' inst
        in

        (* If v' != ⊥ then set Uses(v') = Uses(v') ∪ inst' *)
        let uses' =
          if String.equal (Var.name v') Bincaml_util.Unicode.bot_char then
            curr_info.uses
          else DefUseMap.add curr_info.uses v' inst'
        in

        let proc' = replace_instruction inst inst' curr_info.proc in
        let nai' =
          InstructionSet.map
            (fun old_nai_inst ->
              if Instruction.equal inst old_nai_inst then inst'
              else old_nai_inst)
            curr_info.non_actual_insts
        in

        ( { curr_info with proc = proc'; non_actual_insts = nai'; uses = uses' },
          inst' )
  in

  (* foreach CFG node n in dominance order do *)
  let rec visit_begin_node (start_info : ssi_info) (node : Dom.vertex) =
    let (final_info : ssi_info) =
      match node with
      | Procedure.Vert.Return ->
          if
            StringMap.values (Procedure.formal_out_params start_info.proc)
            |> Iter.exists (Var.equal v)
          then
            let inst = Instruction.create_out_inst start_info.proc in

            (* Assuming that all return vertices have a single End block
                predecessor *)
            let return_block_id =
              Procedure.get_blocks_pred start_info.proc node |> List.hd
            in
            (* copy_out_param start_info return_block_id inst *)
            set_use ~og_bid:return_block_id start_info inst |> fst
          else start_info
      | Procedure.Vert.Entry ->
          if
            StringMap.values (Procedure.formal_in_params start_info.proc)
            |> Iter.exists (Var.equal v)
          then
            let inst = Instruction.create_in_inst start_info.proc in
            set_def start_info inst
          else start_info
      | Procedure.Vert.Begin block_id ->
          (* Our CFG is structured a little differently to the book. Our
                nodes that we are looping on are exclusively Begin nodes, so
                In(node) is the outgoing edge of the node, which are blocks.

                Since we don't have explicit 'program points' inside of the
                block we loop through the statements inside the block, since it
                is a precondition that they are ordered in the statement list
                that all blocks contain.

                We could amend this workaround by splitting the procedure into
                many multiple different blocks during Split(), but this is extra
                work for the same effect.

                So for a node n, In(n) = succ_e n i.e. the immediate block that
                this 'Begin' corresponds to, and for m in direct-successors(n),
                direct-successors(n) is the second vertex from n, since the
                order is n(Begin) -> n'(End) -> n''(Begin | Return | Exit).
                In(m) will be the immediate outgoing edge of n'', iff n'' is a
                Begin. Otherwise stop processing.

                It's a little confusing, but in relation to the original
                algorithm, 'In(n) is a program block', and for my rename
                implementation, 'n' is referring to a statement in the block.

                However, in order to make the algorithm work, for lines 6-9 then
                we will need a loop that loops through every statement in the
                statement list of a block in order.

                Additionally, for line 16 of the algorithm, where we check the
                phi nodes of a program point 'm' - which in our representation
                is a Begin vertex - that is a direct successor to 'n', in order
                to significantly  save time, within the call to set_use on line
                17, for 'inst', we use the End vertex that is a predecessor to
                'm', so that we correctly check the domination of
                Def(stack.peek()) against 'inst' without needing to  expensively
                re-compute an idom function for the Begin vertex of 'n'. The End
                vertex for the predecessor of  'm' should be the same vertex for
                the block 'n'.  *)

          (* Assuming that all Begin vertices always have a single outgoing Block edge *)
          let block = Procedure.find_block start_info.proc block_id in

          (* If exists Phi node with lhs matching v in In(node) then *)
          let info_step_one =
            List.fold_left
              (fun curr_info phi ->
                if Var.equal phi.Block.lhs v then
                  let inst =
                    Instruction.create_phi_inst block_id phi.lhs phi.rhs
                  in
                  set_def curr_info inst
                else curr_info)
              start_info block.phis
          in

          (* foreach instruction u in n that uses v do *)
          let info_step_three =
            Vector.foldi
              (fun index curr_info stmt ->
                let inst = Instruction.create_stmt_inst block_id index stmt in
                let info_step_two, updated_inst =
                  (* An instruction that uses v*)
                  if VarSet.mem v (Stmt.free_vars stmt) then
                    set_use curr_info inst
                  else (curr_info, inst)
                in
                (* If exists instruction d in n that defines v then *)
                if Iter.mem v (Stmt.iter_lvar stmt) then
                  set_def info_step_two updated_inst
                else info_step_two)
              info_step_one block.stmts
          in

          let next_vertices = second_successors cfg node in
          (* Foreach m in direct-successors(n) do *)
          next_vertices
          |> Iter.fold
               (fun curr_info vert ->
                 match vert with
                 | Procedure.Vert.Begin succ_block_id ->
                     let succ_block =
                       Procedure.find_block curr_info.proc succ_block_id
                     in

                     (* Assuming that a phi will only have at most one matching
                      id-var pair for our current block and variable v *)
                     List.fold_left
                       (fun info' phi ->
                         match
                           List.find_opt
                             (fun (ogbid, var) ->
                               (* If E v <- phi(v:l) in In(m) then *)
                               ID.equal ogbid block_id && Var.equal var v)
                             phi.Block.rhs
                         with
                         | Some (ogbid, var) ->
                             (* info' *)
                             let inst =
                               Instruction.create_phi_inst succ_block_id
                                 phi.Block.lhs phi.Block.rhs
                             in
                             (* In order to avoid
                              recomputing idom for each vertex, we compare the
                              current vertex to the predecessor of the block
                              with the phi node, (which should just be the End
                              of the current block, so this code can definitely
                              be simplified and tidied up) *)
                             (* stack.set_use(v <- v:l) *)
                             set_use ~og_bid:ogbid info' inst |> fst
                         | None -> info')
                       curr_info succ_block.phis
                 | _ -> curr_info)
               info_step_three
      | _ -> start_info
    in
    List.fold_left visit_begin_node final_info
      (dom_functions.dom_tree node
      |> List.rev (* Add/Remove |> List.rev here if you want a different order*)
      )
  in
  let rename_info = visit_begin_node split_info Procedure.Vert.Entry in

  (* Update a potentially outdated instruction with the instruction in the
       same location in the given proc.  For Statements, we simply use the
       block_id and stmt index to retrieve the relevant statement.  For Phis, if
       we are updating the Def-Use chain, then we use the block_id to get the
       relevant block, then we loop on the phi list to find the first one that
       defines our variable. If we are updating the Use-Def chain, then we use
       the block_id to get the relevant block, and then we loop on the phi list
       to find the first one that uses our variable.  Obviously, this is not
       simple, and is also assuming that a variable can only be used in one phi
       node.  Perhaps appending to the end of the list in Split, and keeping the
       index in the list would be easier here, though it may not be as
       efficient, and phis are supposed to be unordered. This will need testing
       to determine which is better. *)
  let update_insn is_def_map proc =
   fun newmap var inst ->
    let inst' =
      match (is_def_map, inst) with
      | `Defs, Instruction.Formal_In vars ->
          Instruction.Formal_In
            (proc |> Procedure.formal_in_params |> StringMap.values
           |> List.of_iter)
      | `Uses, Instruction.Formal_In vars -> inst
      | `Defs, Formal_Out vars -> inst (* TODO: Stop the map from adding this*)
      | `Uses, Formal_Out vars ->
          Instruction.Formal_Out
            (proc |> Procedure.formal_out_params |> StringMap.values
           |> List.of_iter)
      | _, Block_Inst (block_id, Instruction.Statement stmt) -> (
          let block = Procedure.get_block proc block_id in
          match block with
          | None -> inst
          | Some b ->
              let stmt' = Vector.get b.stmts stmt.index in
              Instruction.create_stmt_inst block_id stmt.index stmt')
      | _, Block_Inst (block_id, Instruction.Phi phi) -> (
          let block = Procedure.get_block proc block_id in
          match block with
          | None -> inst
          | Some b ->
              let rec get_phi (phi_list : Var.t Block.phi list) =
                match phi_list with
                | [] -> inst
                | head :: tail ->
                    let cond =
                      match is_def_map with
                      | `Defs -> Var.equal head.lhs var
                      | `Uses ->
                          List.exists (fun (_, v) -> Var.equal var v) head.rhs
                    in
                    if cond then
                      Instruction.create_phi_inst block_id head.lhs head.rhs
                    else get_phi tail
              in
              get_phi b.phis)
    in
    DefUseMap.add newmap var inst'
  in
  let update_chain is_def_map oldmap proc =
    DefUseMap.fold oldmap DefUseMap.empty (update_insn is_def_map proc)
  in

  let updated_defs = update_chain `Defs rename_info.defs rename_info.proc in
  let updated_uses = update_chain `Uses rename_info.uses rename_info.proc in

  { rename_info with defs = updated_defs; uses = updated_uses }
