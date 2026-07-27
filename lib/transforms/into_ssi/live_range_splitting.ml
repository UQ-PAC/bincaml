open Bincaml_util.Common
open Lang
open Lang.Common
open Containers
open Datastructures

(** Returns i_up and i_down, where both are lists of cfg vertices. i_up is
    empty, and i_down is a list of Procedure.Vert.End vertices, for both blocks
    that contain multiple successor edges, and blocks that contain var in
    Block.assigned_vars_iter *)
let create_range_analysis_splitting_strategy proc (var : Var.t) cfg :
    VertexSet.t * VertexSet.t =
  Procedure.G.fold_vertex
    (fun (vert : Dom.vertex) (i_up, i_down) ->
      match vert with
      | Procedure.Vert.End block_id ->
          let block = Procedure.find_block proc block_id in
          let tmp =
            if Iter.mem var (Block.assigned_vars_iter block) then
              (i_up, VertexSet.add vert i_down)
            else (i_up, i_down)
          in
          if Procedure.G.succ cfg vert |> List.length > 1 then
            Procedure.G.fold_succ
              (fun succ_vert (up, down) -> (up, VertexSet.add succ_vert down))
              cfg vert tmp
          else tmp
      | _ -> (i_up, i_down))
    cfg
    (VertexSet.empty, VertexSet.empty)

(** First step of SSI conversion - insertion of phi and sigma nodes *)
module SplitLiveRange = struct
  (* Check if a block uses a given variable before locally defining it, or
       doesn't define it at all.  A statement that has a variable on both its
       left and right hand sides is considered to be using it before defining
       it. *)
  let has_undefined_var (var : Var.t) (block_id : ID.t) proc =
    let block = Procedure.find_block proc block_id in
    let phi_status =
      List.exists
        (fun phi ->
          List.exists
            (fun (bid, var') ->
              Var.equal var var' && not (ID.equal bid block_id))
            phi.Block.rhs)
        block.phis
    in
    let stmts = block.stmts in
    let size = Vector.size stmts in
    let rec check_stmt index =
      if index = size then true
      else
        let stmt = Vector.get stmts index in
        if VarSet.mem var (Stmt.free_vars stmt) then true
        else if Iter.mem var (Stmt.iter_lvar stmt) then false
        else check_stmt (index + 1)
    in
    (* TODO: Might need to check if the entry block uses a formal_in param *)
    check_stmt 0 || phi_status

  (** Splits the range of the program *)
  let split (v : Var.t) ((i_up : VertexSet.t), (i_down : VertexSet.t))
      (proc : (Var.t, Program.e) Procedure.t) (cfg : Dom.t) (rev_cfg : Dom.t)
      (dom_functions : Dom.dom_functions)
      (rev_dom_functions : Dom.dom_functions) =
    let is_join vertex =
      match vertex with
      | Procedure.Vert.Begin block_id ->
          Procedure.G.pred cfg vertex |> List.length > 1
      | _ -> false
    in
    let is_branch vertex =
      match vertex with
      | Procedure.Vert.End block_id ->
          Procedure.G.succ cfg vertex |> List.length > 1
      | _ -> false
    in
    let is_branch_successor vertex =
      match vertex with
      | Procedure.Vert.Begin block_id ->
          Procedure.G.pred cfg vertex |> List.exists is_branch
      | _ -> false
    in

    (* Determine all the Begin vertices where the associated block defines v *)
    let defs_of_v : VertexSet.t =
      let begin_vertices =
        Procedure.G.fold_vertex
          (fun vert dovs ->
            match vert with
            | Procedure.Vert.Begin bid ->
                let block = Procedure.find_block proc bid in
                if Iter.mem v (Block.assigned_vars_iter block) then
                  VertexSet.add vert dovs
                else dovs
            | _ -> dovs)
          cfg VertexSet.empty
      in
      if StringMap.mem (Var.name v) (Procedure.formal_in_params proc) then
        begin_vertices |> VertexSet.add Procedure.Vert.Entry
      else begin_vertices
    in

    (* For each i E I_up *)
    let s_up =
      VertexSet.fold
        (fun vert sups ->
          (* If i.is_join then *)
          if is_join vert then
            (* Foreach edge E incoming_edges(i) do *)
            Procedure.G.fold_pred
              (fun pred_vert sups' ->
                VertexSet.union sups'
                  (rev_dom_functions.dom_frontier pred_vert |> VertexSet.of_list))
              rev_cfg vert sups
          else
            VertexSet.union sups
              (rev_dom_functions.dom_frontier vert |> VertexSet.of_list))
        i_up VertexSet.empty
    in

    (* For each i E i_down *)
    let s_down =
      VertexSet.fold
        (fun vert sdown ->
          (* If i.is_branch then *)
          if is_branch vert then
            (* Foreach edge E outgoing_edges(i) do *)
            Procedure.G.fold_succ
              (fun succ_vert sdown' ->
                VertexSet.union sdown'
                  (dom_functions.dom_frontier succ_vert |> VertexSet.of_list))
              cfg vert sdown
          else
            VertexSet.union sdown
              (dom_functions.dom_frontier vert |> VertexSet.of_list))
        (VertexSet.union s_up defs_of_v |> VertexSet.union i_down)
        VertexSet.empty
    in

    let s_combined =
      VertexSet.union i_up i_down
      |> VertexSet.union s_up |> VertexSet.union s_down
    in

    VertexSet.fold
      (fun vert curr_info ->
        match vert with
        | Procedure.Vert.Begin block_id | Procedure.Vert.End block_id ->
            let block = Procedure.find_block curr_info.proc block_id in
            if has_undefined_var v block_id curr_info.proc then
              (* If block does not already contain any definition of v then *)
              if is_join vert then
                (* If block.is_join then insert v <- phi([v..v]) in the block *)
                let pred_block_ids =
                  Procedure.get_blocks_pred curr_info.proc vert
                in
                let proc_with_phi, phi_inst =
                  add_phi curr_info.proc block_id v pred_block_ids
                in
                {
                  curr_info with
                  proc = proc_with_phi;
                  non_actual_insts =
                    InstructionSet.add phi_inst curr_info.non_actual_insts;
                }
              else if is_branch_successor vert then
                (*
                  Check if there is already a v <- phi(block_id : v), i.e. check
                  for the branch block *)
                (* If block.is_branch then insert v <- phi(v) at each *)
                let pred_block_ids =
                  Procedure.get_blocks_pred curr_info.proc vert
                in
                List.fold_left
                  (fun info' pred_id ->
                    (* If i.is_branch then insert phi(v <- v) at successor block*)
                    if
                      is_branch (Procedure.Vert.End pred_id)
                      && List.exists
                           (fun (phi : Var.t Block.phi) ->
                             List.mem (pred_id, v) phi.rhs)
                           block.phis
                    then info'
                    else
                      let proc_with_phi, phi_inst =
                        add_phi info'.proc block_id v [ pred_id ]
                      in
                      {
                        info' with
                        proc = proc_with_phi;
                        non_actual_insts =
                          InstructionSet.add phi_inst info'.non_actual_insts;
                      })
                  curr_info pred_block_ids
              else if not (Iter.mem v (Block.assigned_vars_iter block)) then
                (* Insert a copy v := v into the block *)
                let proc_with_copy, copy_inst =
                  add_copy_instruction curr_info.proc block_id v
                in
                {
                  curr_info with
                  proc = proc_with_copy;
                  non_actual_insts =
                    InstructionSet.add copy_inst curr_info.non_actual_insts;
                }
              else curr_info
            else curr_info
        (* TODO: Might need to accommodate for Vert.Entry here. *)
        | _ -> curr_info)
      s_combined
      {
        proc;
        non_actual_insts = InstructionSet.empty;
        defs = DefUseMap.empty;
        uses = DefUseMap.empty;
        web = VarSet.empty;
      }
end
