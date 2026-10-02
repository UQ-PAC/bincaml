(** Eliminates dead and undefined code, for instructions added by split
    involving the current variable being split *)

open Bincaml_util.Common
open Lang
open Lang.Common
open Containers
open Datastructures

(** Builds the defined and used sets to be used in cleanup *)
let clean (v : Var.t) (bot_var : Var.t) rename_info =
  let all_insts = get_all_instructions rename_info.proc in
  let actual_insts =
    InstructionSet.diff all_insts rename_info.non_actual_insts
  in

  (* active <- inst|inst actual instruction and web ∩ inst.defs != null *)
  let active_defs =
    InstructionSet.filter
      (fun inst ->
        VarSet.inter rename_info.web
          (Instruction.var_defines inst |> VarSet.of_iter)
        |> VarSet.is_empty |> not)
      actual_insts
  in

  (* defines <- {∅} *)
  let initial_defined = VarSet.empty in

  (* While exists an instruction in active such that the intersection of web
    and instruction.defs - curr_defined != {∅}*)
  let rec create_defined_while_loop (curr_active_defs : InstructionSet.t)
      (curr_defined : VarSet.t) : VarSet.t =
    let unregistered_def_vars (inst : Instruction.t) =
      VarSet.diff
        (VarSet.inter rename_info.web
           (Instruction.var_defines inst |> VarSet.of_iter))
        curr_defined
    in
    let guard (inst : Instruction.t) =
      unregistered_def_vars inst |> VarSet.is_empty |> not
    in
    match Seq.find guard (InstructionSet.to_seq curr_active_defs) with
    | None -> curr_defined
    | Some inst ->
        let vars = inst |> unregistered_def_vars in
        (* Foreach v' elem (web ∩ inst.defs - curr_defined)*)
        let new_active, new_defs =
          VarSet.fold
            (fun var (active', defined') ->
              (* Active <- active ∪ Uses(v') *)
              ( InstructionSet.union
                  (DefUseMap.find rename_info.uses var |> InstructionSet.of_list)
                  active',
                (* Defined <- defined ∪ {v'} *)
                VarSet.add var defined' ))
            vars
            (curr_active_defs, curr_defined)
        in
        create_defined_while_loop new_active new_defs
  in
  let defined = create_defined_while_loop active_defs initial_defined in

  (* uses <- {∅} *)
  let initial_uses = VarSet.empty in
  (* active <- {inst | inst actual instruction and web ∩ inst.defs != {∅} *)
  let active_uses =
    InstructionSet.filter
      (fun inst ->
        VarSet.inter rename_info.web
          (Instruction.var_uses inst |> VarSet.of_iter)
        |> VarSet.is_empty |> not)
      actual_insts
  in

  (* While exists an instruction in active such that the intersection of web and instruction.uses - curr_used != {∅} *)
  let rec create_used_while_loop (curr_active_uses : InstructionSet.t)
      (curr_used : VarSet.t) : VarSet.t =
    let unregistered_use_vars (inst : Instruction.t) =
      VarSet.diff
        (VarSet.inter rename_info.web
           (Instruction.var_uses inst |> VarSet.of_iter))
        curr_used
    in
    let guard (inst : Instruction.t) =
      unregistered_use_vars inst |> VarSet.is_empty |> not
      (* The below code is accurate to the book, but causes an infinite loop. This appears
          to be a typo in the book. *)
      (* VarSet.diff
            (Instruction.var_uses inst |> VarSet.of_iter)
            curr_used
          |> VarSet.is_empty |> not *)
    in
    match Seq.find guard (InstructionSet.to_seq curr_active_uses) with
    | None -> curr_used
    | Some inst ->
        let vars = unregistered_use_vars inst in
        (* Foreach v' elem (web ∩ inst.uses - curr_used) *)
        let new_active, new_used =
          VarSet.fold
            (fun var (active', used') ->
              (* active <- active ∪ Def(v') *)
              ( InstructionSet.add
                  (DefUseMap.find rename_info.defs var |> List.hd)
                  active',
                (* used <- used ∪ {v'} *)
                VarSet.add var used' ))
            vars
            (curr_active_uses, curr_used)
        in
        create_used_while_loop new_active new_used
  in

  let used = create_used_while_loop active_uses initial_uses in

  let live = VarSet.inter defined used in

  (* Foreach non actual instruction E Def(web) do *)
  InstructionSet.fold
    (fun (inst : Instruction.t) curr_proc ->
      let inst_is_def_of_web =
        inst |> Instruction.var_defines |> VarSet.of_iter
        |> VarSet.inter rename_info.web
        |> VarSet.is_empty |> not
      in
      if inst_is_def_of_web then
        (* Instruction is part of Def(web) *)
        let all_vars =
          Iter.append (Instruction.var_defines inst) (Instruction.var_uses inst)
          |> VarSet.of_iter
        in

        (* For each v' operand of inst | v' !in live *)
        let proc_step_one, inst_step_one =
          VarSet.fold
            (fun v' (proc', inst') ->
              if VarSet.mem v' rename_info.web && not (VarSet.mem v' live) then
                (* Replace v' by ⊥ *)
                let replaced_inst =
                  Instruction.replace_defs v' bot_var inst'
                  |> Instruction.replace_uses v' bot_var
                in
                (replace_instruction inst' replaced_inst proc', replaced_inst)
              else (proc', inst'))
            all_vars (curr_proc, inst)
        in

        let just_bot_char = VarSet.empty |> VarSet.add bot_var in
        (* If inst.defs = {⊥} or inst.uses = {⊥} *)
        if
          Instruction.var_defines inst_step_one
          |> VarSet.of_iter |> VarSet.equal just_bot_char
          || Instruction.var_uses inst_step_one
             |> VarSet.of_iter |> VarSet.equal just_bot_char
        then
          (* Remove inst *)
          match inst_step_one with
          | Block_Inst (block_id, Instruction.Phi bot_phi) ->
              let unmodified_block =
                Procedure.find_block proc_step_one block_id
              in
              let new_phis =
                List.filter
                  (fun phi -> Block.equal_phi Var.equal phi bot_phi |> not)
                  unmodified_block.phis
              in
              let modified_block = { unmodified_block with phis = new_phis } in
              Procedure.update_block proc_step_one block_id modified_block
          | Block_Inst (block_id, Instruction.Statement bot_stmt) ->
              let unmodified_block =
                Procedure.find_block proc_step_one block_id
              in
              let modified_stmts = Vector.create () in
              Vector.append modified_stmts unmodified_block.stmts;
              Vector.remove_and_shift modified_stmts bot_stmt.index;
              let modified_block =
                { unmodified_block with stmts = Vector.freeze modified_stmts }
              in
              Procedure.update_block proc_step_one block_id modified_block
          (* Should not be editing the formal in or out params *)
          | _ -> proc_step_one
        else proc_step_one
      else curr_proc)
    rename_info.non_actual_insts rename_info.proc
