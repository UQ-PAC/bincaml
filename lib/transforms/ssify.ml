open Bincaml_util.Common
open Lang
open Lang.Common
open Containers

(** Naive implementation of a 3-part algorithm to construct an SSI
    representation of a program.

    Based on chapter 13.2 from "SSA-based Compiler Design"
    (https://doi.org/10.1007/978-3-030-80515-9)

    First splits the program by inserting phi nodes and parallel copies, then
    renames each occurence of a variable, then removes uneccessary added
    instructions containing dead variables on their left or right hand sides.

    Sigma instructions of a branch node are implemented by placing a phi node on
    each successor node.

    In multiple places that require iterating through program points, we first
    have an outer loop that iterates over Procedure graph vertices, and for
    vertices with an associated Block Begin edge, we then check the phi nodes of
    the block, then have an inner loop that loops through all statements in the
    block.*)

(* TODO:
  - Update non-actual instructions at the end of rename similar to the defuse
    and usedef chains, instead of within set_def and set_use, which should
    improve performance

  KNOWN ISSUES: - Slow, particularly during rename.  - Procedures with multiple
  return points have an error with assigning to the formal-out param(s) -
  examples/linear_copy.il has an error. The loop procedure contains f_entry phi
  nodes for the f procedure.

  RELATIVELY UNTESTED: - Global variables - Procedures that have late uses of
  formal-in variables

*)

module SSIfy = struct
  (** Represents the instruction, i.e. Phi or Statement *)
  module Instruction = struct
    (** The instruction, which is either a Phi or a Statement *)
    type it =
      | Phi of Var.t Block.phi
      | Statement of { index : int; statement : Program.stmt }
    [@@deriving ord, eq, show { with_path = false }]

    (** A pair between the block id and the instruction *)
    type t =
      | Block_Inst of ID.t * it
      (* TODO: Using Var.t StringMap.t causes an error with show *)
      | Formal_In of Var.t list
      | Formal_Out of Var.t list
    [@@deriving ord, eq, show { with_path = false }]

    let get_block_id (inst : t) =
      match inst with Block_Inst (id, it) -> Some id | _ -> None

    (** Get an iter of the variables defined by the instruction *)
    let var_defines = function
      | Block_Inst (_, Phi { lhs; rhs }) -> Iter.singleton lhs
      | Block_Inst (_, Statement { index; statement }) ->
          Stmt.iter_assigned statement
      | Formal_In vars -> Iter.of_list vars
      | Formal_Out vars -> Iter.empty

    (** Get an iter of the variables used by the instruction *)
    let var_uses = function
      | Block_Inst (_, Phi { rhs }) -> List.to_iter rhs |> Iter.map snd
      | Block_Inst (_, Statement { statement }) -> Stmt.free_vars_iter statement
      | Formal_In vars -> Iter.empty
      | Formal_Out vars -> Iter.of_list vars

    let create_phi_inst block_id lhs rhs =
      Block_Inst (block_id, Phi { lhs; rhs })

    let create_stmt_inst block_id index statement =
      Block_Inst (block_id, Statement { index; statement })

    let create_in_inst (proc : (Var.t, Program.e) Procedure.t) =
      Formal_In
        (Procedure.formal_in_params proc |> StringMap.values |> List.of_iter)

    let create_out_inst (proc : (Var.t, Program.e) Procedure.t) =
      Formal_Out
        (Procedure.formal_out_params proc |> StringMap.values |> List.of_iter)

    (** Replace the definitions of v by v' *)
    let replace_defs v v' (inst : t) : t =
      match inst with
      | Block_Inst (block_id, Phi { lhs; rhs }) ->
          Block_Inst
            (block_id, Phi { lhs = (if Var.equal lhs v then v' else lhs); rhs })
      | Block_Inst (block_id, Statement { index; statement = stmt }) ->
          let stmt' =
            Stmt.map
              ~f_lvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
              ~f_expr:id ~f_rvar:id stmt
          in
          Block_Inst (block_id, Statement { index; statement = stmt' })
      (* TODO: Check if this should change at all *)
      | Formal_In vars ->
          Formal_In
            (List.map (fun var -> if Var.equal v var then v' else var) vars)
      | Formal_Out vars -> Formal_Out vars

    let replace_expr_rvar v v' =
      let open Expr.BasilExpr in
      rewrite_typed (function
        | RVar { id; attrib } when Var.equal id v -> Some (rvar ~attrib v')
        | _ -> None)

    (** Replace the uses of v by v' *)
    let replace_uses ?pred_block_id v v' (inst : t) : t =
      (* Replace_uses is used in 2 places - during line 5 of set_use in rename,
      to rename a variable, and in line 18 of clean, to replace dead v's with ⊥.

      In the former case, a possible scenario it is called is line 17 of the
      main rename function, when set_use is called on the phi nodes of the
      direct sucessors of a block n.  In this scenario, we need the block ID of
      n so that we only update the respective v usages for the block n, instead
      of every rhs v, which may be associated with a completely different block
      and thus should not be modified.  However, in the latter case, we do not
      have to worry about which block ID the rhs phi variable is associated
      with, and can just replace it with ⊥.

      To make this distinction, we use ?pred_block_id to differentiate between
      when a check for whether the rhs phi's block id is equal to the ID of
      block n is needed or not. Otherwise, two almost identical functions would
      be needed.*)
      match inst with
      | Block_Inst (block_id, Phi { lhs; rhs }) ->
          let rhs' =
            List.map
              (fun (bid, var) ->
                match pred_block_id with
                | Some og_bid ->
                    if ID.equal og_bid bid && Var.equal var v then (bid, v')
                    else (bid, var)
                | None -> if Var.equal var v then (bid, v') else (bid, var))
              rhs
          in
          Block_Inst (block_id, Phi { lhs; rhs = rhs' })
      | Block_Inst (block_id, Statement old_stmt) ->
          let stmt' =
            Stmt.map ~f_lvar:id ~f_expr:(replace_expr_rvar v v')
              ~f_rvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
              old_stmt.statement
          in
          Block_Inst
            (block_id, Statement { index = old_stmt.index; statement = stmt' })
      | Formal_In vars -> Formal_In vars
      | Formal_Out vars ->
          Formal_Out
            (List.map (fun var -> if Var.equal v var then v' else var) vars)
  end

  module VertexSet = CCSet.Make (Procedure.Vert)
  module InstructionSet = CCSet.Make (Instruction)

  module Rev = struct
    include Procedure.G

    let succ = pred
    let empty () = empty

    include Procedure.RevG
  end

  module RevDom = Graph.Dominator.Make_graph (Rev)

  module G_Dom = struct
    include Procedure.G

    let empty () = empty
  end

  module Dom = Graph.Dominator.Make_graph (G_Dom)
  (** Contains dominator functions for a procedure graph *)

  module DefUseMap = CCMultiMap.Make (Var) (Instruction)
  (** Map from Var to (BlockID, Instruction) *)

  type ssi_info = {
    proc : (Var.t, Program.e) Procedure.t;
    non_actual_insts : InstructionSet.t;
    defs : DefUseMap.t;
    uses : DefUseMap.t;
    web : VarSet.t;
  }

  (** Return a set of all instructions in a procedure *)
  let get_all_instructions proc =
    Procedure.fold_blocks_topo_fwd
      (fun all_insts_set bid block ->
        let phi_insts =
          List.fold_left
            (fun all_set phi ->
              let inst =
                Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs
              in
              InstructionSet.add inst all_set)
            all_insts_set block.phis
        in
        let stmt_insts =
          Vector.foldi
            (fun index all_set stmt ->
              let inst = Instruction.create_stmt_inst bid index stmt in
              InstructionSet.add inst all_set)
            phi_insts block.stmts
        in
        stmt_insts)
      InstructionSet.empty proc
    |> InstructionSet.add (Instruction.create_in_inst proc)
    |> InstructionSet.add (Instruction.create_out_inst proc)

  (** Naive iterator through the procedure to produce def-use and use-def chains
      for a given variable v. Should only be used as a last resort let
      get_var_uses_and_defs proc (v : Var.t) = let uses, defs =
      Procedure.fold_blocks_topo_fwd (fun (uses, defs) bid block -> let
      phi_uses, phi_defs = List.fold_left (fun (use', def') phi -> let inst =
      Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs in let pu = if
      Iter.mem v (Instruction.var_uses inst) then InstructionSet.add inst use'
      else use' in let pd = if Iter.mem v (Instruction.var_defines inst) then
      InstructionSet.add inst def' else def' in (pu, pd)) (uses, defs)
      block.phis in let stmt_uses, stmt_defs = Vector.foldi (fun index (use',
      def') stmt -> let inst = Instruction.create_stmt_inst bid index stmt in
      let su = if Iter.mem v (Instruction.var_uses inst) then InstructionSet.add
      inst use' else use' in let sd = if Iter.mem v (Instruction.var_defines
      inst) then InstructionSet.add inst def' else def' in (su, sd)) (uses,
      defs) block.stmts in ( InstructionSet.union phi_uses stmt_uses,
      InstructionSet.union phi_defs stmt_defs )) (InstructionSet.empty,
      InstructionSet.empty) proc in let uses = if StringMap.mem (Var.name v)
      (Procedure.formal_out_params proc) then InstructionSet.add
      (Instruction.create_in_inst proc) uses else uses in let defs = if
      StringMap.mem (Var.name v) (Procedure.formal_in_params proc) then
      InstructionSet.add (Instruction.create_in_inst proc) defs else defs in
      (uses, defs) *)

  (** Gets the second successors of a vertex *)
  let second_successors graph (vert : Dom.vertex) =
    Procedure.G.succ graph vert
    |> List.to_iter
    |> Iter.flat_map_l (Procedure.G.succ graph)

  (** Returns true if instruction a dominates instruction b *)
  let instruction_dominates pred_block_id dom (inst_a : Instruction.t)
      (inst_b : Instruction.t) =
    match (inst_a, inst_b) with
    | Block_Inst (bid_a, _), Block_Inst (bid_b, Instruction.Phi _)
      when Option.is_some pred_block_id ->
        dom (Procedure.Vert.Begin bid_a)
          (Procedure.Vert.End (Option.get pred_block_id))
    | ( Block_Inst (bid_a, Instruction.Statement stmt_a),
        Block_Inst (bid_b, Instruction.Statement stmt_b) ) ->
        if ID.equal bid_a bid_b then stmt_a.index <= stmt_b.index
        else dom (Procedure.Vert.Begin bid_a) (Procedure.Vert.Begin bid_b)
    | Block_Inst (bid_a, _), Block_Inst (bid_b, _) ->
        if ID.equal bid_a bid_b then true
        else dom (Procedure.Vert.Begin bid_a) (Procedure.Vert.Begin bid_b)
    | Formal_In vars, _ | _, Formal_Out vars -> true
    | Formal_Out vars, _ | _, Formal_In vars -> false

  (** Adds a new phi for variable var from associated predecessor blocks with
      pred_block_ids to the block associated with block_id in the procedure proc
  *)
  let add_phi proc (block_id : ID.t) (var : Var.t) (pred_block_ids : ID.t list)
      =
    let block_to_add_phi_to = Procedure.find_block proc block_id in
    let new_rhs = List.map (fun pred_id -> (pred_id, var)) pred_block_ids in
    let new_phi : Var.t Block.phi = { lhs = var; rhs = new_rhs } in
    let new_inst = Instruction.create_phi_inst block_id var new_rhs in
    let new_proc =
      Procedure.modify_block proc block_id (fun block ->
          Block.map
            ~phi:(fun phi_list -> new_phi :: phi_list)
            Fun.id block_to_add_phi_to)
    in
    (new_proc, new_inst)

  (** Adds a parallel copy of the variable var to the block with block_id in
      proc. Returns the new proc and the parallel copy instruction *)
  let add_copy_instruction proc (block_id : ID.t) (var : Var.t) =
    let copy_stmt =
      Stmt.Instr_Assign
        { al = [ (var, Expr.BasilExpr.rvar var) ]; attrib = Attrib.empty }
    in
    let new_proc =
      Procedure.modify_block proc block_id (fun block ->
          Block.prepend_stmts block [ copy_stmt ])
    in
    let new_inst = Instruction.create_stmt_inst block_id 0 copy_stmt in
    (new_proc, new_inst)

  (* Returns i_up and i_down, where both are lists of cfg vertices. i_up is
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

  (** Replaces the old instruction inst with the new inst' that has updated
      variables. *)
  let replace_instruction inst inst' curr_proc =
    match (inst, inst') with
    | ( Instruction.Block_Inst (block_id, Instruction.Phi old_phi),
        Instruction.Block_Inst (_, Instruction.Phi new_phi) ) ->
        Procedure.modify_block curr_proc block_id (fun block ->
            Block.map
              ~phi:
                (List.map (fun phi ->
                     if Block.equal_phi Var.equal old_phi phi then new_phi
                     else phi))
              Fun.id block)
    | ( Instruction.Block_Inst (block_id, Instruction.Statement old_stmt),
        Instruction.Block_Inst (_, Instruction.Statement new_stmt) ) ->
        Procedure.modify_block curr_proc block_id (fun block ->
            Block.fmap_stmts_copy
              (fun stmts -> Vector.set stmts old_stmt.index new_stmt.statement)
              block)
    | _ ->
        failwith
          "Impossible - the type between old and new instruction was \
           different, or tried to change the in and out parameters"
  (* Shouldn't occur *)

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
                    (rev_dom_functions.dom_frontier pred_vert
                    |> VertexSet.of_list))
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

  (** Renames variable definitions and usages, and builds a def-use and use-def
      chain*)
  module VariableRenaming = struct
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
            {
              curr_info with
              proc = proc';
              non_actual_insts = nai';
              defs = defs';
            }
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
                  (instruction_dominates og_bid dom_functions.dom inst'
                     instruction)
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

            ( {
                curr_info with
                proc = proc';
                non_actual_insts = nai';
                uses = uses';
              },
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
                    let inst =
                      Instruction.create_stmt_inst block_id index stmt
                    in
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
          |> List.rev
             (* Add/Remove |> List.rev here if you want a different order*))
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
          | `Defs, Formal_Out vars ->
              inst (* TODO: Stop the map from adding this*)
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
                              List.exists
                                (fun (_, v) -> Var.equal var v)
                                head.rhs
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
  end

  (** Eliminates dead and undefined code, for instructions added by split
      involving the current variable being split *)
  module DeadCodeElim = struct
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

      (* While exists an instruction in active such that the intersection of web and instruction.defs - curr_defined != {∅}*)
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
                      (DefUseMap.find rename_info.uses var
                      |> InstructionSet.of_list)
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
              Iter.append
                (Instruction.var_defines inst)
                (Instruction.var_uses inst)
              |> VarSet.of_iter
            in

            (* For each v' operand of inst | v' !in live *)
            let proc_step_one, inst_step_one =
              VarSet.fold
                (fun v' (proc', inst') ->
                  if VarSet.mem v' rename_info.web && not (VarSet.mem v' live)
                  then
                    (* Replace v' by ⊥ *)
                    let replaced_inst =
                      Instruction.replace_defs v' bot_var inst'
                      |> Instruction.replace_uses v' bot_var
                    in
                    ( replace_instruction inst' replaced_inst proc',
                      replaced_inst )
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
                  let modified_block =
                    { unmodified_block with phis = new_phis }
                  in
                  Procedure.update_block proc_step_one block_id modified_block
              | Block_Inst (block_id, Instruction.Statement bot_stmt) ->
                  let unmodified_block =
                    Procedure.find_block proc_step_one block_id
                  in
                  let modified_stmts = Vector.create () in
                  Vector.append modified_stmts unmodified_block.stmts;
                  Vector.remove_and_shift modified_stmts bot_stmt.index;
                  let modified_block =
                    {
                      unmodified_block with
                      stmts = Vector.freeze modified_stmts;
                    }
                  in
                  Procedure.update_block proc_step_one block_id modified_block
              (* Should not be editing the formal in or out params *)
              | _ -> proc_step_one
            else proc_step_one
          else curr_proc)
        rename_info.non_actual_insts rename_info.proc
  end

  (** Perform SSIfy on a specific variable in a specific procedure *)
  let ssify ?splitting_strategy (v : Var.t) proc cfg rev_cfg dom_functions
      rev_dom_functions =
    let pv =
      match splitting_strategy with
      | None -> create_range_analysis_splitting_strategy proc v cfg
      | Some ss -> ss
    in
    let bot_var =
      Var.create Bincaml_util.Unicode.bot_char (Var.typ v) ~scope:(Var.scope v)
    in
    (* We pass the same cfg into split and rename, which should be ok, since the only
    operation on the cfg in rename is to get the second successors of a vertex, which is
    unchanged from split because we do not add or remove any vertices. *)
    SplitLiveRange.split v pv proc cfg rev_cfg dom_functions rev_dom_functions
    |> VariableRenaming.rename v bot_var cfg dom_functions
    |> DeadCodeElim.clean v bot_var

  (** Perform SSIfy on a procedure *)
  let ssify_proc ?splitting_strategy (og_vars : Var.t Var.Decls.t)
      (proc : (Var.t, Program.e) Procedure.t) =
    match Procedure.graph proc with
    | None -> proc
    | Some cfg ->
        let dom_functions = Dom.compute_all cfg Procedure.Vert.Entry in
        let rev_cfg : RevDom.t =
          cfg (* TODO: Work out how to properly create a reverse cfg. *)
        in
        (* TODO: Using Procedure.Vert.Return here is probably incorrect when there are multiple returns *)
        let rev_dom_functions = Dom.compute_all rev_cfg Procedure.Vert.Return in
        Var.Decls.fold
          (fun name var p ->
            ssify ?splitting_strategy var p cfg rev_cfg dom_functions
              rev_dom_functions)
          og_vars proc

  (** Perform SSIfy on a program *)
  let ssify_prog ?splitting_strategy (prog : Program.t) =
    Program.map_procedures
      (fun id proc ->
        let og_vars = Var.Decls.copy (Procedure.local_decls proc) in
        ssify_proc ?splitting_strategy og_vars proc)
      prog

  (** Perform SSIfy on a specific variable with a specific name in a specific
      procedure *)
  let ssify_name ?splitting_strategy (v_name : String.t) proc cfg rev_cfg
      dom_functions rev_dom_functions =
    match Procedure.lookup_local_decl proc v_name with
    | Some v ->
        ssify ?splitting_strategy v proc cfg rev_cfg dom_functions
          rev_dom_functions
    | None -> proc

  (** Perform SSIfy on a process for the variable with the given name *)
  let ssify_proc_var_name ?splitting_strategy (og_vars : Var.t Var.Decls.t)
      (v_name : String.t) (proc : (Var.t, Program.e) Procedure.t) =
    match Procedure.graph proc with
    | None -> proc
    | Some cfg ->
        let dom_functions = Dom.compute_all cfg Procedure.Vert.Entry in
        let rev_cfg : RevDom.t =
          cfg (* TODO: Work out how to properly create a reverse cfg. *)
        in
        (* TODO: Using Procedure.Vert.Return here is probably incorrect when there are multiple returns *)
        let rev_dom_functions = Dom.compute_all rev_cfg Procedure.Vert.Return in
        if Var.Decls.mem og_vars v_name then
          ssify_name ?splitting_strategy v_name proc cfg rev_cfg dom_functions
            rev_dom_functions
        else proc

  (** Perform SSIfy on a program for the variable with the given name *)
  let ssify_prog_var_name ?splitting_strategy (v_name : String.t)
      (prog : Program.t) =
    Program.map_procedures
      (fun id proc ->
        let og_vars = Var.Decls.copy (Procedure.local_decls proc) in
        ssify_proc_var_name ?splitting_strategy og_vars v_name proc)
      prog
end
