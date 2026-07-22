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
    each successor node. *)

(* In multiple places that require iterating through program points, we first have an outer loop that iterates over
     Procedure graph vertices, and for vertices with an associated Block edge, we then check the phi nodes of the block, then
     have an inner loop that loops through all statements in the block. *)

(* TODO:
  - Does linear_copy.il have an error? The loop procedure contains f_entry phi nodes for the f procedure.
  - Make this less imperative. I made it close to the book's algorithm at the cost of making it very imperative, and I'm not very happy with how it is
  - Update non-actual instructions at the end of rename similar to the defuse and usedef chains, instead of within set_def and set_use, which should improve performance
  - Expand the Instruction.it type to have a Begin and End type, to represent formal in and out params. We don't change the formal in and out variables,
    but any redefinitions of them locally are changed like normal.

  KNOWN ISSUES:
  - Formal In and Out params are currently unaccounted for. The fix for this is in progress.
  - Calling ssify_prog instead of ssify on a specific variable causes the variable IDs to have larger numbers, indicating that
    split is creating multiple phis for the same variable only when ssify_prog is run, even though there should be no difference
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
      (* Replace_uses is used in 2 places - during line 5 of set_use in rename, to rename a variable, and in line 18 of clean, to replace dead v's with ⊥. 

      In the former case, a possible scenario it is called is line 17 of the main rename function, when set_use is called on the phi nodes of the direct sucessors of a block n.
      In this scenario, we need the block ID of n so that we only update the respective v usages for the block n,
      instead of every rhs v, which may be associated with a completely different block and thus should not be modified.
      However, in the latter case, we do not have to worry about which block ID the rhs phi variable is associated with, and can just replace it with ⊥.

      To make this distinction, we use ?pred_block_id to differentiate between when a check for whether the rhs phi's block id is equal to the ID of block n is needed or not. Otherwise,
      two almost identical functions would be needed.*)
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

    include Procedure.RevG
  end

  module RevDom = Graph.Dominator.Make (Rev)

  module G_Dom = struct
    include Procedure.G

    let empty () = empty
  end

  module Dom = Graph.Dominator.Make_graph (G_Dom)

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
            (fun (all_set, index) phi ->
              let inst =
                Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs
              in
              (InstructionSet.add inst all_set, index + 1))
            (all_insts_set, 0) block.phis
          |> fst
        in
        let stmt_insts =
          Vector.foldi
            (fun index all_set stmt ->
              let inst = Instruction.create_stmt_inst bid index stmt in
              InstructionSet.add inst all_set)
            all_insts_set block.stmts
        in
        InstructionSet.union phi_insts stmt_insts
        |> InstructionSet.union all_insts_set)
      InstructionSet.empty proc
    |> InstructionSet.add (Instruction.create_in_inst proc)
    |> InstructionSet.add (Instruction.create_out_inst proc)

  (** Naive iterator through the procedure to produce def-use and use-def chains
      for a given variable v. Should only be used as a last resort *)
  let get_var_uses_and_defs proc (v : Var.t) =
    let uses, defs =
      Procedure.fold_blocks_topo_fwd
        (fun (uses, defs) bid block ->
          let phi_uses, phi_defs =
            List.fold_left
              (fun (use', def') phi ->
                let inst =
                  Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs
                in
                let pu =
                  if Iter.mem v (Instruction.var_uses inst) then
                    InstructionSet.add inst use'
                  else use'
                in
                let pd =
                  if Iter.mem v (Instruction.var_defines inst) then
                    InstructionSet.add inst def'
                  else def'
                in
                (pu, pd))
              (uses, defs) block.phis
          in
          let stmt_uses, stmt_defs =
            Vector.foldi
              (fun index (use', def') stmt ->
                let inst = Instruction.create_stmt_inst bid index stmt in
                let su =
                  if Iter.mem v (Instruction.var_uses inst) then
                    InstructionSet.add inst use'
                  else use'
                in
                let sd =
                  if Iter.mem v (Instruction.var_defines inst) then
                    InstructionSet.add inst def'
                  else def'
                in
                (su, sd))
              (uses, defs) block.stmts
          in
          ( InstructionSet.union phi_uses stmt_uses,
            InstructionSet.union phi_defs stmt_defs ))
        (InstructionSet.empty, InstructionSet.empty)
        proc
    in
    let uses =
      if StringMap.mem (Var.name v) (Procedure.formal_out_params proc) then
        InstructionSet.add (Instruction.create_in_inst proc) uses
      else uses
    in
    let defs =
      if StringMap.mem (Var.name v) (Procedure.formal_in_params proc) then
        InstructionSet.add (Instruction.create_in_inst proc) defs
      else defs
    in
    (uses, defs)

  (** Gets the second successors of a vertex *)
  let second_successors graph (vert : Dom.vertex) =
    Procedure.G.succ graph vert |> List.concat_map (Procedure.G.succ graph)

  (** Returns true if vertex vert_a dominates vertex vert_b *)
  let vertex_dominates graph dom vert_a vert_b = dom vert_a vert_b

  (** Returns true if instruction a dominates instruction b *)
  let instruction_dominates pred_block_id (graph : Dom.t) dom
      (inst_a : Instruction.t) (inst_b : Instruction.t) =
    match (inst_a, inst_b) with
    | Block_Inst (bid_a, _), Block_Inst (bid_b, Instruction.Phi _)
      when Option.is_some pred_block_id ->
        vertex_dominates graph dom (Procedure.Vert.Begin bid_a)
          (Procedure.Vert.End (Option.get pred_block_id))
    | ( Block_Inst (bid_a, Instruction.Statement stmt_a),
        Block_Inst (bid_b, Instruction.Statement stmt_b) ) ->
        if ID.equal bid_a bid_b then stmt_a.index <= stmt_b.index
        else
          vertex_dominates graph dom (Procedure.Vert.Begin bid_a)
            (Procedure.Vert.Begin bid_b)
    | Block_Inst (bid_a, _), Block_Inst (bid_b, _) ->
        if ID.equal bid_a bid_b then true
        else
          vertex_dominates graph dom (Procedure.Vert.Begin bid_a)
            (Procedure.Vert.Begin bid_b)
    | Formal_In vars, _ | _, Formal_Out vars -> true
    | Formal_Out vars, _ | _, Formal_In vars -> false

  (** Takes the CFG graph and a current vertex and gives the list of immediately
      dominating vertices *)
  let get_dominated_vertices (graph : Dom.t) (vertex : Dom.vertex) idom =
    (* TODO: Keep a cache of this so that we don't recompute vertices *)
    Dom.idom_to_dom_tree graph idom vertex

  let dom_frontier (graph : Dom.t) (vertex : Dom.vertex) idom dom_tree :
      VertexSet.t =
    (* TODO: Keep a cache of this so that we don't recompute vertices *)
    Dom.compute_dom_frontier graph dom_tree idom vertex |> VertexSet.of_list

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
    (* Check if a block uses a given variable before locally defining it, or doesn't define it at all.
       A statement that has a variable on both its left and right hand sides is considered to be using it
       before defining it. *)
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
      let rec check_stmt index =
        if index = Vector.size stmts then true
        else
          let stmt = Vector.get stmts index in
          if VarSet.mem var (Stmt.free_vars stmt) then true
          else if Iter.mem var (Stmt.iter_lvar stmt) then false
          else check_stmt (index + 1)
      in
      (* TODO: Might need to check if the entry block uses a formal_in param *)
      check_stmt 0 || phi_status

    (** Splits the range of the program *)
    let split (v : Var.t) ((i_up : VertexSet.t), (i_down : VertexSet.t)) proc
        (dom_functions : Dom.dom_functions) =
      let cfg : Dom.t =
        match Procedure.graph proc with
        | Some g -> g
        | None -> Procedure.G.empty
      in
      let rev_cfg : RevDom.t =
        match Procedure.graph proc with
        | Some g -> g
        | None -> Procedure.G.empty
      in
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
                    (dom_frontier rev_cfg pred_vert dom_functions.idom
                       dom_functions.dom_tree))
                rev_cfg vert sups
            else
              VertexSet.union sups
                (dom_frontier rev_cfg vert dom_functions.idom
                   dom_functions.dom_tree))
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
                    (dom_functions.dom_frontier succ_vert |> VertexSet.of_list)
                  (* (dom_frontier cfg succ_vert idom dom_tree) *))
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
              if has_undefined_var v block_id proc then
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
                  (* If block.is_branch then insert v <- phi(v) at each *)
                  (* Check if there is already a v <- phi(block_id : v), i.e. check for the branch block *)
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
    (** Creates a fresh version of a variable and adds it to web *)
    let create_v' old_v (info : ssi_info) =
      let v' =
        Procedure.fresh_var ~pure:true ~name:(Var.name old_v) info.proc
          (Var.typ old_v)
      in
      let new_web = VarSet.add v' info.web in
      (Procedure.decl_local info.proc v', { info with web = new_web })

    (** Returns a procedure that has renamed v, and the relative transformed
        non-actual instructions*)
    let rename (v : Var.t) (bot_var : Var.t) (dom_functions : Dom.dom_functions)
        (split_info : ssi_info) =
      (* Stack <- new *)
      let stack : Var.t Stack.t = Stack.create () in

      (* The control flow graph of the current procedure *)
      let cfg =
        match Procedure.graph split_info.proc with
        | Some g -> g
        | None -> Procedure.G.empty
      in

      (* Returns the proc with replaced inst' *)
      let set_def (curr_info : ssi_info) (inst : Instruction.t) =
        match inst with
        | Instruction.Formal_In vars ->
            (* We don't redefine the formal-in parameter, since it gets a bit messy interprocedurally. *)
            let defs' = DefUseMap.add curr_info.defs v inst in
            Stack.push v stack;
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
            Stack.push v' stack;

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

      let set_use ?(og_bid : ID.t option) (curr_info : ssi_info)
          (inst : Instruction.t) =
        (* while Def(stack.peek()) does not dominate inst do *)
        let rec pop_while_not_dominating instruction =
          match Stack.top_opt stack with
          | None -> ()
          | Some v' ->
              (* It's ok to use the outdated defs map here, because we only use the location pointers, not the potentially outdated instruction *)
              let v'_def_instructions = DefUseMap.find curr_info.defs v' in
              if
                List.for_all
                  (fun v'_def ->
                    not
                      (instruction_dominates og_bid cfg dom_functions.dom v'_def
                         instruction))
                  v'_def_instructions
              then (
                (* Stack.pop *)
                ignore (Stack.pop stack);
                pop_while_not_dominating instruction)
        in
        pop_while_not_dominating inst;

        (* v' <- stack.peek() *)
        let v' =
          (* if (StringMap.mem (Var.name v) (Procedure.formal_in_params curr_info.proc)) then v else  *)
          let open Bincaml_util.Unicode in
          Option.value (Stack.top_opt stack) ~default:bot_var
        in

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
          (* We're only looking at Begin nodes : Skip if not Begin *)
          match node with
          | Procedure.Vert.Entry ->
              if
                StringMap.mem (Var.name v)
                  (Procedure.formal_in_params start_info.proc)
              then
                let inst = Instruction.create_in_inst start_info.proc in
                set_def start_info inst
              else start_info
          | Procedure.Vert.Begin block_id ->
              (*
                Our CFG is structured a little differently to the book. Our nodes that we are looping
                on are exclusively Begin nodes, so In(node) is the outgoing edge of the node, which are blocks.

                Since we don't have explicit 'program points' inside of the block we loop through the statements
                inside the block, since it is a precondition that they are ordered in the statement list that all
                blocks contain.

                We could amend this workaround by splitting the procedure into many multiple different blocks during
                Split(), but this is extra work for the same effect.

                So for a node n, In(n) = succ_e n i.e. the immediate block that this 'Begin' corresponds to,
                and for m in direct-successors(n), direct-successors(n) is the second vertex from n, since
                the order is n(Begin) -> n'(End) -> n''(Begin | Return | Exit). 
                In(m) will be the immediate outgoing edge of n'', iff n'' is a Begin. Otherwise stop processing.

                It's a little confusing, but in relation to the original algorithm, 'In(n) is a program block',
                and for my rename implementation, 'n' is referring to a statement in the block.

                However, in order to make the algorithm work, for lines 6-9 then we will need a loop
                that loops through every statement in the statement list of a block in order.
              *)

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
              List.fold_left
                (fun curr_info vert ->
                  match vert with
                  | Procedure.Vert.Begin succ_block_id ->
                      let succ_block =
                        Procedure.find_block curr_info.proc succ_block_id
                      in
                      List.fold_left
                        (fun info' phi ->
                          List.fold_left
                            (fun info'' (ogbid, var) ->
                              (* If E v <- phi(v:l) in In(m) then *)
                              if ID.equal ogbid block_id && Var.equal var v then
                                let inst =
                                  Instruction.create_phi_inst succ_block_id
                                    phi.Block.lhs phi.Block.rhs
                                in
                                (* stack.set_use(v <- v:l) *)
                                set_use ~og_bid:ogbid info'' inst |> fst
                              else info'')
                            info' phi.Block.rhs)
                        curr_info succ_block.phis
                  | _ -> curr_info)
                info_step_three next_vertices
          | _ -> start_info
        in
        List.fold_left visit_begin_node final_info
          (get_dominated_vertices cfg node dom_functions.idom)
      in
      let rename_info = visit_begin_node split_info Procedure.Vert.Entry in

      (* Update a potentially outdated instruction with the instruction in the same location in the given proc.
       For Statements, we simply use the block_id and stmt index to retrieve the relevant statement.
       For Phis, if we are updating the Def-Use chain, then we use the block_id to get the relevant block, then we
       loop on the phi list to find the first one that defines our variable. If we are updating the Use-Def chain, then we
       use the block_id to get the relevant block, and then we loop on the phi list to find the first one that uses our variable.
       Obviously, this is not simple, and is also assuming that a variable can only be used in one phi node. 
       Perhaps appending to the end of the list in Split, and keeping the index in the list would be easier here, though
       it may not be as efficient, and phis are supposed to be unordered. This will need testing to determine which is better. *)
      let update_chain is_def_map oldmap proc =
        DefUseMap.fold oldmap DefUseMap.empty (fun newmap var inst ->
            let inst' =
              match inst with
              | Formal_In vars ->
                  Instruction.Formal_In
                    (proc |> Procedure.formal_in_params |> StringMap.values
                   |> List.of_iter)
              | Formal_Out vars ->
                  Instruction.Formal_Out
                    (proc |> Procedure.formal_out_params |> StringMap.values
                   |> List.of_iter)
              | Block_Inst (block_id, Instruction.Statement stmt) -> (
                  let block = Procedure.get_block proc block_id in
                  match block with
                  | None -> inst
                  | Some b ->
                      let stmt' = Vector.get b.stmts stmt.index in
                      Instruction.create_stmt_inst block_id stmt.index stmt')
              | Block_Inst (block_id, Instruction.Phi phi) -> (
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
                              | true -> Var.equal head.lhs var
                              | false ->
                                  List.exists
                                    (fun (_, v) -> Var.equal var v)
                                    head.rhs
                            in
                            if cond then
                              Instruction.create_phi_inst block_id head.lhs
                                head.rhs
                            else get_phi tail
                      in
                      get_phi b.phis)
            in
            DefUseMap.add newmap var inst')
      in

      let updated_defs = update_chain true rename_info.defs rename_info.proc in
      let updated_uses = update_chain false rename_info.uses rename_info.proc in

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
                  (* Active <- active union Uses(v') *)
                  let var_uses =
                    DefUseMap.find rename_info.uses var
                    |> InstructionSet.of_list
                  in
                  (* Defined <- defined union {v'} *)
                  let single_var = VarSet.add var VarSet.empty in
                  ( InstructionSet.union var_uses active',
                    VarSet.union single_var defined' ))
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

      (* While exists an instruction in active such that instruction.uses - curr_used != {∅} *)
      let rec create_uses_while_loop (curr_active_uses : InstructionSet.t)
          (curr_used : VarSet.t) : VarSet.t =
        let unregistered_use_vars (inst : Instruction.t) =
          VarSet.diff
            (VarSet.inter rename_info.web
               (Instruction.var_uses inst |> VarSet.of_iter))
            curr_used
        in
        let guard (inst : Instruction.t) =
          unregistered_use_vars inst |> VarSet.is_empty |> not
          (* TODO: Having the below commented out code, which is accurate to the book,
          causes an infinite loop for formal_in params. The reason is yet unknown *)
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
                  (* Def(v') *)
                  let var_defs =
                    DefUseMap.find rename_info.defs var
                    |> InstructionSet.of_list
                  in
                  (* {v'} *)
                  let single_var = VarSet.add var VarSet.empty in
                  (* Active <- Active union Def(v')
                     Used <- Used union {v'} *)
                  ( InstructionSet.union var_defs active',
                    VarSet.union single_var used' ))
                vars
                (curr_active_uses, curr_used)
            in
            create_uses_while_loop new_active new_used
      in

      let used = create_uses_while_loop active_uses initial_uses in

      let live = VarSet.inter defined used in

      (* Temporary bandaid fix to prevent errors with formal in and out variables *)
      (* let live = StringMap.fold (fun name var currlive -> VarSet.add var currlive) (Procedure.formal_in_params rename_info.proc) live in
      let live = StringMap.fold (fun name var currlive -> VarSet.add var currlive) (Procedure.formal_out_params rename_info.proc) live in *)

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
                  if
                    VarSet.mem v' rename_info.web && not (VarSet.mem v' live)
                    (* && (not (StringMap.mem (Var.name v') (Procedure.formal_in_params rename_info.proc)))*)
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

  let ssify ?splitting_strategy (v : Var.t) proc dom_functions =
    let pv =
      match splitting_strategy with
      | None ->
          let cfg =
            match Procedure.graph proc with
            | Some g -> g
            | None -> Procedure.G.empty
          in
          create_range_analysis_splitting_strategy proc v cfg
      | Some ss -> ss
    in
    let bot_var =
      Var.create Bincaml_util.Unicode.bot_char (Var.typ v) ~scope:(Var.scope v)
    in
    SplitLiveRange.split v pv proc dom_functions
    |> VariableRenaming.rename v bot_var dom_functions
    |> DeadCodeElim.clean v bot_var

  let ssify_proc ?splitting_strategy (proc : (Var.t, Program.e) Procedure.t) =
    let all_vars = Procedure.local_decls proc in
    let cfg =
      match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
    in
    let dom_functions = Dom.compute_all cfg Procedure.Vert.Entry in
    Var.Decls.fold
      (fun name var p -> ssify var p dom_functions)
      (* (fun name var p -> if not (StringMap.mem name (Procedure.formal_in_params p)) then ssify var p else p) *)
      all_vars proc

  let ssify_prog ?splitting_strategy (prog : Program.t) =
    Program.map_procedures (fun id proc -> ssify_proc proc) prog
end

let%expect_test "test_rename" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main_entry [
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      goto(%main_1, %main_2);
    ];

    block %main_1 
    (
      var v:bv64 := phi(%main_entry -> v:bv64)
    )
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, 69);
      var tmp:bv64 := bvadd(i, 1:bv64);
      goto(%main_return);
    ];

    block %main_2 
    (
      var v:bv64 := phi(%main_entry -> v:bv64)
    )
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      (var v:bv64) := call @OY();
      var v:bv64 := bvadd(v, 420);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var v:bv64 := v:bv64;
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      goto(%main_return);
    ];

    block %main_return
    (
      var v:bv64 := phi(%main_1 -> v:bv64, %main_2_1 -> v:bv64)
    )
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];

    |}
  in
  let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let (info : SSIfy.ssi_info) =
    {
      proc;
      non_actual_insts = SSIfy.InstructionSet.empty;
      defs = SSIfy.DefUseMap.empty;
      uses = SSIfy.DefUseMap.empty;
      web = VarSet.empty;
    }
  in
  let bot_var =
    Var.create Bincaml_util.Unicode.bot_char (Var.typ v) ~scope:(Var.scope v)
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = SSIfy.Dom.compute_all cfg Procedure.Vert.Entry in
  let proc' = SSIfy.VariableRenaming.rename v bot_var dom_functions info in
  Program.output_proc_pretty stdout proc'.proc;
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 ( var v_9:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_9:bv64, 0xa:bv64);
         var v_10:bv64 := bvadd(v_9:bv64, 69);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         (var v_6:bv64=OY_out) := call @OY();
         var v_7:bv64 := bvadd(v_6:bv64, 420);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var v_8:bv64 := v_7:bv64;
         var namnam:bv64 := bvor(v_8:bv64, 0xffffffff:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_1 -> v_10:bv64, %main_2_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "test_SSIFY" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main_entry [
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      var namnam:bv64 := 12345:bv64;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, v);
      var tmp:bv64 := bvadd(i, 1:bv64);
      var i:bv64 := tmp:bv64;
      goto(%main_return, %main_1);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      var nam:bv64 := bvadd(namnam:bv64, v:bv64);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      var v:bv64 := bvadd(v:bv64, namnam);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  (*
  let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "nam" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = SSIfy.Dom.compute_all cfg Procedure.Vert.Entry in

  let proc_split = SSIfy.ssify v proc dom_functions in
  Program.output_proc_pretty stdout proc_split;
  *)
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         var namnam_1:bv64 := 0x3039:bv64;
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var i_3:bv64 := phi(%main_1 -> i_4:bv64, %main_entry -> i:bv64),
         var v_7:bv64 := phi(%main_1 -> v_8:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i_3:bv64, 0x2:bv64);
         var nam_48:bv64 := bvadd(v_7:bv64, 0xa:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, v_7:bv64);
         var tmp_3:bv64 := bvadd(i_3:bv64, 0x1:bv64);
         var i_4:bv64 := tmp_3:bv64;
         goto (%main_return,%main_1);
       ];
       block %main_2 (
         var i_2:bv64 := phi(%main_entry -> i:bv64),
         var v_5:bv64 := phi(%main_entry -> v_2:bv64),
         var namnam_8:bv64 := phi(%main_entry -> namnam_1:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var nam_59:bv64 := bvadd(namnam_8:bv64, v_5:bv64);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam_4:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, namnam_4:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out_4:bv64 := v_4:bv64;
         return;
       ]
    ];
    proc @OX()  -> (OX_out:bv64) {  }


    [ block %OX_entry [ var OX_out_4:bv64 := 0x0:bv64; return; ] ];
    proc @OY()  -> (OY_out:bv64) {  }


    [ block %OY_entry [ var OY_out_1:bv64 := 0x1:bv64; return; ] ];
    prog entry @main;
    |}]

let%expect_test "test_multiple_conditionals" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_3, %main_4);
    ];

    block %main_3
    [
      guard(bvsmod(i:bv64, 2:bv64));
      var v := bvadd(v:bv64, 3:bv64);
      goto(%main_return);
    ];

    block %main_4
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v := bvadd(v:bv64, 4:bv64);
      goto(%main_return);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v:bv64 := bvadd(v:bv64, 1);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  (*
let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = SSIfy.Dom.compute_all cfg Procedure.Vert.Entry in

  let proc_split = SSIfy.ssify v proc dom_functions in
  Program.output_proc_pretty stdout proc_split;
  *)
  (* For some reason, these two calls will cause the v in the first block to be v_28 instead of v_1,
  even though they should only operate on v once.*)
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_28:bv64 := 0; goto (%main_2,%main_1); ];
       block %main_1 (
         var i_3:bv64 := phi(%main_entry -> i:bv64),
         var v_15:bv64 := phi(%main_entry -> v_28:bv64)
       ) [
         guard bvsmod(i_3:bv64, 0x2:bv64);
         var v_7:bv64 := bvadd(v_15:bv64, 2);
         goto (%main_4,%main_3);
       ];
       block %main_3 (
         var i_5:bv64 := phi(%main_1 -> i_3:bv64),
         var v_10:bv64 := phi(%main_1 -> v_7:bv64)
       ) [
         guard bvsmod(i_5:bv64, 0x2:bv64);
         var v_11:bv64 := bvadd(v_10:bv64, 0x3:bv64);
         goto (%main_return);
       ];
       block %main_4 (
         var i_4:bv64 := phi(%main_1 -> i_3:bv64),
         var v_8:bv64 := phi(%main_1 -> v_7:bv64)
       ) [
         guard boolnot(bvsmod(i_4:bv64, 0x2:bv64));
         var v_9:bv64 := bvadd(v_8:bv64, 0x4:bv64);
         goto (%main_return);
       ];
       block %main_2 (
         var i_2:bv64 := phi(%main_entry -> i:bv64),
         var v_4:bv64 := phi(%main_entry -> v_28:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_5:bv64 := bvadd(v_4:bv64, 1);
         goto (%main_return);
       ];
       block %main_return (
         var v_2:bv64 := phi(%main_2 -> v_5:bv64, %main_4 -> v_9:bv64,
            %main_3 -> v_11:bv64)
       ) [
         var v_3:bv64 := bvadd(v_2:bv64, 0x1:bv64);
         var out_16:bv64 := v_3:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_loop_diff_block" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_return);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v:bv64 := bvadd(v:bv64, 1);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v := bvadd(v:bv64, 4:bv64);
      goto(%main_2, %main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_13:bv64 := 0; goto (%main_2,%main_1); ];
       block %main_1 (
         var i_3:bv64 := phi(%main_entry -> i:bv64),
         var v_7:bv64 := phi(%main_entry -> v_13:bv64)
       ) [
         guard bvsmod(i_3:bv64, 0x2:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, 2);
         goto (%main_return);
       ];
       block %main_2 (
         var i_2:bv64 := phi(%main_2_1 -> i_2:bv64, %main_entry -> i:bv64),
         var v_4:bv64 := phi(%main_2_1 -> v_11:bv64, %main_entry -> v_13:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_5:bv64 := bvadd(v_4:bv64, 1);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_11:bv64 := bvadd(v_5:bv64, 0x4:bv64);
         goto (%main_return,%main_2);
       ];
       block %main_return (
         var v_2:bv64 := phi(%main_2_1 -> v_11:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_3:bv64 := bvadd(v_2:bv64, 0x1:bv64);
         var out_4:bv64 := v_3:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_loop_same_block" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_1, %main_return);
    ];

    block %main_return
      [
      guard(boolnot(bvsmod(i, 2:bv64)));
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_6:bv64 := 0; goto (%main_1); ];
       block %main_1 (
         var i_1:bv64 := phi(%main_1 -> i_1:bv64, %main_entry -> i:bv64),
         var v_2:bv64 := phi(%main_1 -> v_3:bv64, %main_entry -> v_6:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var v_3:bv64 := bvadd(v_2:bv64, 2);
         goto (%main_return,%main_1);
       ];
       block %main_return (
         var i_2:bv64 := phi(%main_1 -> i_1:bv64),
         var v_4:bv64 := phi(%main_1 -> v_3:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_5:bv64 := bvadd(v_4:bv64, 0x1:bv64);
         var out_6:bv64 := v_5:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_ssa_multi_deps" =
  let lst =
    Loader.Loadir.ast_of_string
      {|



prog entry @main  { .invariants = ["NoPhis"] } ;

proc @main () -> ()
[
  block %e [
    var v:bv64 := 0;
    goto (%e1, %e2, %e3);
  ];
  block %e1 [
    var v := bvadd(v, 1);
    goto (%e2);
  ];
  block %e2 [
    goto (%e4, %e1);
  ];
  block %e3 [
    var v := bvadd(v, 2);
    goto (%e4, %e1);
  ];

  block %e4 [
    var v := bvadd(v, 2);
    goto (%e5);
  ];

  block %e5 [
    var v:= bvadd(v, 67);
    return ();
  ]
];
|}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main()  -> () {  }


    [
       block %e [ var v_14:bv64 := 0; goto (%e3,%e2,%e1); ];
       block %e1 (
         var v_8:bv64 := phi(%e3 -> v_11:bv64, %e2 -> v_7:bv64, %e -> v_14:bv64)
       ) [ var v_9:bv64 := bvadd(v_8:bv64, 1); goto (%e2); ];
       block %e2 ( var v_7:bv64 := phi(%e1 -> v_9:bv64, %e -> v_14:bv64) ) [
         goto (%e4,%e1);
       ];
       block %e3 ( var v_5:bv64 := phi(%e -> v_14:bv64) ) [
         var v_11:bv64 := bvadd(v_5:bv64, 2);
         goto (%e4,%e1);
       ];
       block %e4 ( var v_2:bv64 := phi(%e3 -> v_11:bv64, %e2 -> v_7:bv64) ) [
         var v_3:bv64 := bvadd(v_2:bv64, 2);
         goto (%e5);
       ];
       block %e5 [ var v_4:bv64 := bvadd(v_3:bv64, 67); return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_ssa_multi_deps_reconstruction" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main()  -> () {  }


  [
    block %e [ 
      var v_1:bv64 := 0;
      var x:bv64 := 2;
      goto (%e3,%e2,%e1);
      ];
     block %e1 (
       var v_2:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64, %e -> v_1:bv64)
     ) [ 
       var x := bvadd(x, 1);
       var v_3:bv64 := bvadd(v_2:bv64, 1); goto (%e2); 
      ];
     block %e2 ( var v_4:bv64 := phi(%e1 -> v_3:bv64, %e -> v_1:bv64) ) [
       var v_5:bv64 := v_4:bv64;
       var x := bvadd(x, 2);
       goto (%e4,%e1);
     ];
     block %e3 ( var v_6:bv64 := phi(%e -> v_1:bv64) ) [
       var v_7:bv64 := bvadd(v_6:bv64, 2);
       goto (%e4,%e1);
     ];
     block %e4 ( var v_8:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64) ) [
       var v_9:bv64 := bvadd(v_8:bv64, 2);
       goto (%e5);
     ];
     block %e5 [ 
       var v_10:bv64 := bvadd(v_9:bv64, 67);
       var x := bvadd(x, 5);
       return; 
     ]
  ];
  |}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main()  -> () {  }


    [
       block %e [ var v_224:bv64 := 0; var x_1:bv64 := 2; goto (%e1,%e2,%e3); ];
       block %e3 (
         var x_8:bv64 := phi(%e -> x_1:bv64),
         var v_174:bv64 := phi(%e -> v_224:bv64)
       ) [ var v_27:bv64 := bvadd(v_174:bv64, 2); goto (%e4,%e1); ];
       block %e2 (
         var x_6:bv64 := phi(%e1 -> x_5:bv64, %e -> x_1:bv64),
         var v_91:bv64 := phi(%e1 -> v_77:bv64, %e -> v_224:bv64)
       ) [
         var v_108:bv64 := v_91:bv64;
         var x_7:bv64 := bvadd(x_6:bv64, 2);
         goto (%e4,%e1);
       ];
       block %e1 (
         var x_4:bv64 := phi(%e -> x_1:bv64, %e2 -> x_7:bv64, %e3 -> x_8:bv64),
         var v_197:bv64 := phi(%e3 -> v_27:bv64, %e2 -> v_108:bv64, %e -> v_224:bv64)
       ) [
         var x_5:bv64 := bvadd(x_4:bv64, 1);
         var v_77:bv64 := bvadd(v_197:bv64, 1);
         goto (%e2);
       ];
       block %e4 (
         var x_2:bv64 := phi(%e2 -> x_7:bv64, %e3 -> x_8:bv64),
         var v_94:bv64 := phi(%e3 -> v_27:bv64, %e2 -> v_108:bv64)
       ) [ var v_72:bv64 := bvadd(v_94:bv64, 2); goto (%e5); ];
       block %e5 [
         var v_64:bv64 := bvadd(v_72:bv64, 67);
         var x_3:bv64 := bvadd(x_2:bv64, 5);
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_v_1" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64)  -> (out:bv64) {  }
    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_7:bv64 := phi(%main_1 -> v_8:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_7:bv64, 0xa:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, v_7:bv64);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return,%main_1);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         var v_1:bv64 := 0x111:bv64;
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, 420);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ];
    ];
    proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v_1" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = SSIfy.Dom.compute_all cfg Procedure.Vert.Entry in

  let proc_split = SSIfy.ssify v proc dom_functions in
  Program.output_proc_pretty stdout proc_split;
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_9:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_7:bv64 := phi(%main_1 -> v_8:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_7:bv64, 0xa:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, v_7:bv64);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return,%main_1);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         var v_11:bv64 := 0x111:bv64;
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, 420);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "test_loop.il" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
      prog entry @main ;

var $R0 : bv64;
var $R1 : bv64;


proc @main () -> () [
  block %entry  [
    $R0 := 0:bv64;
    $R1 := 0:bv64;
    goto (%loop);
  ];
  block %loop [
    goto (%loop_true, %loop_false);
  ];
  block %loop_true [
    guard (bvult($R0, 10:bv64));
    $R1 := bvadd($R1, $R0);
    $R0 := bvadd($R0, 1:bv64);
    goto (%loop);
  ];
  block %loop_false [
    guard (bvuge($R0, 10:bv64));
    return ();
  ];

];

proc @main_local () -> () [
  block %entry  [
    var v0:bv64 := 0:bv64;
    var r1:bv64 := 0:bv64;
    goto (%loop);
  ];
  block %loop [
    goto (%loop_true, %loop_false);
  ];
  block %loop_true [
    guard (bvult(v0, 10:bv64));
    var r1:bv64 := bvadd(r1, v0);
    var v0:bv64 := bvadd(v0, 1:bv64);
    goto (%loop);
  ];
  block %loop_false [
    guard (bvuge(v0, 10:bv64));
    return ();
  ];

];
    |}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    proc @main()  -> () {  }
      modifies $R0:bv64, $R1:bv64
      captures $R0:bv64, $R1:bv64

    [
       block %entry [ $R0:bv64 := 0x0:bv64; $R1:bv64 := 0x0:bv64; goto (%loop); ];
       block %loop [ goto (%loop_false,%loop_true); ];
       block %loop_true [
         guard bvult($R0, 0xa:bv64);
         $R1:bv64 := bvadd($R1, $R0);
         $R0:bv64 := bvadd($R0, 0x1:bv64);
         goto (%loop);
       ];
       block %loop_false [ guard boolnot(bvult($R0, 0xa:bv64)); return; ]
    ];
    proc @main_local()  -> () {  }


    [
       block %entry [
         var v0_1:bv64 := 0x0:bv64;
         var r1_16:bv64 := 0x0:bv64;
         goto (%loop);
       ];
       block %loop (
         var v0_7:bv64 := phi(%loop_true -> v0_10:bv64, %entry -> v0_1:bv64),
         var r1_11:bv64 := phi(%loop_true -> r1_35:bv64, %entry -> r1_16:bv64)
       ) [ goto (%loop_false,%loop_true); ];
       block %loop_true (
         var v0_4:bv64 := phi(%loop -> v0_7:bv64),
         var r1_23:bv64 := phi(%loop -> r1_11:bv64)
       ) [
         guard bvult(v0_4:bv64, 0xa:bv64);
         var r1_35:bv64 := bvadd(r1_23:bv64, v0_4:bv64);
         var v0_10:bv64 := bvadd(v0_4:bv64, 0x1:bv64);
         goto (%loop);
       ];
       block %loop_false ( var v0_3:bv64 := phi(%loop -> v0_7:bv64) ) [
         guard boolnot(bvult(v0_3:bv64, 0xa:bv64));
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_linear_copy.il" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
      prog entry @main;

proc @main(a:bv64, x:bool) -> ()
[
    block %main [
        (var b:bv64) := call @f(a:bv64);
        (var c:bv64, var d:bv64) := call @loop(b:bv64, b:bv64);
        (var e:bv64) := call @cross(d:bv64, bvadd(d:bv64, 1:bv64));
        (var f:bv64 := bvadd(1:bv64, c:bv64), var g:bv64 := bvadd(1:bv64, e:bv64));
        (var y:bool) := call @bool_id(x:bool);
        var z:bool := y:bool;
        return;
    ];
];

proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
        goto (%f_a, %f_b);
    ];
    block %f_a [
        var y_1:bv64 := x;
        goto (%f_c, %f_d);
    ];
    block %f_b [
        (var y_2:bv64, var z:bv64) := call @g(x);
        goto (%f_c, %f_d);
    ];
    block %f_c (
        var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        var w_1:bv64 := y_3:bv64;
        goto (%f_return);
    ];
    block %f_d (
        var y_4:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        (var w_2:bv64, var p:bv64) := call @g(y_4);
        goto (%f_return);
    ];
    block %f_return (
        var w_3:bv64 := phi(%f_c -> w_1:bv64, %f_d -> w_2:bv64)
    ) [
        return (w_3:bv64);
    ];
];

proc @g(x:bv64) -> (o:bv64, p:bv64)
[
    block %g_entry [
        goto (%g_a, %g_b);
    ];
    block %g_a [
        var y_1:bv64 := x;
        goto (%g_return);
    ];
    block %g_b [
        (var y_2:bv64) := call @f(x);
        goto (%g_return);
    ];
    block %g_return (
        var y_3:bv64 := phi(%g_a -> y_1:bv64, %g_b -> y_2:bv64)
    ) [
        return (x:bv64, y_3:bv64);
    ];
];

proc @loop(x:bv64, y:bv64) -> (o:bv64, p:bv64)
[
    block %entry [
        var x_1:bv64 := bvadd(x:bv64, 1:bv64);
        var y_1:bv64 := bvadd(y:bv64, 1:bv64);
        goto(%a, %ret);
    ];
    block %a (
        var x_2:bv64 := phi(%entry -> x_1:bv64, %a -> x_3:bv64),
        var y_2:bv64 := phi(%entry -> y_1:bv64, %a -> y_3:bv64)
    ) [
        var x_3:bv64 := bvadd(x_2:bv64, 1:bv64);
        var y_3:bv64 := y_2;
        goto(%a, %ret);
    ];
    block %ret (
        var x_4:bv64 := phi(%entry -> x_1:bv64, %a -> x_3:bv64),
        var y_4:bv64 := phi(%entry -> y_1:bv64, %a -> y_3:bv64)
    ) [
        (var o:bv64 := x_4:bv64, var p:bv64 := y_4:bv64);
        return;
    ];
];

proc @cross(a:bv64, b:bv64) -> (o:bv64)
[
    block %entry [
        goto(%a, %b);
    ];
    block %a [
        var o_1:bv64 := a:bv64;
        goto(%ret);
    ];
    block %b [
        var o_2:bv64 := bvsub(b:bv64, 1:bv64);
        goto(%ret);
    ];
    block %ret (
        var o_3:bv64 := phi(%a -> o_1:bv64, %b -> o_2:bv64)
    ) [
        return (o_3:bv64);
    ];
];

proc @bool_id(a:bool) -> (o:bool)
[
    block %entry [
        return (a:bool);
    ];
];

    |}
  in
  let program = lst.prog in
  let ssi_prog = SSIfy.ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(a:bv64, x:bool)  -> () {  }


    [
       block %main [
         (var b_2:bv64=o) := call @f(x=a:bv64);
         (var c_1:bv64=o, var d_1:bv64=p) := call @loop(x=b_2:bv64, y=b_2:bv64);
         (var e_3:bv64=o) := call @cross(a=d_1:bv64, b=bvadd(d_1:bv64, 0x1:bv64));
         (var f_1:bv64 := bvadd(0x1:bv64, c_1:bv64),
          var g_1:bv64 := bvadd(0x1:bv64, e_3:bv64));
         (var y_1:bool=o) := call @bool_id(a=x:bool);
         var z_2:bool := y_1:bool;
         return;
       ]
    ];
    proc @f(x:bv64)  -> (o:bv64) {  }


    [
       block %f_entry [ goto (%f_b,%f_a); ];
       block %f_a ( var x_5:bv64 := phi(%f_entry -> x:bv64) ) [
         var y_9:bv64 := x_5:bv64;
         goto (%f_d,%f_c);
       ];
       block %f_b ( var x_4:bv64 := phi(%f_entry -> x:bv64) ) [
         (var y_75:bv64=o, var z_19:bv64=p) := call @g(x=x_4:bv64);
         goto (%f_d,%f_c);
       ];
       block %f_c ( var y_69:bv64 := phi(%f_a -> y_9:bv64, %f_b -> y_75:bv64) ) [
         var w_68:bv64 := y_69:bv64;
         goto (%f_return);
       ];
       block %f_d ( var y_57:bv64 := phi(%f_a -> y_9:bv64, %f_b -> y_75:bv64) ) [
         (var w_42:bv64=o, var p_2:bv64=p) := call @g(x=y_57:bv64);
         goto (%f_return);
       ];
       block %f_return (
         var w_36:bv64 := phi(%f_c -> w_68:bv64, %f_d -> w_42:bv64)
       ) [ var o_1:bv64 := w_36:bv64; return; ]
    ];
    proc @g(x:bv64)  -> (o:bv64, p:bv64) {  }


    [
       block %g_entry [ goto (%g_b,%g_a); ];
       block %g_a ( var x_3:bv64 := phi(%g_entry -> x:bv64) ) [
         var y_9:bv64 := x_3:bv64;
         goto (%g_return);
       ];
       block %g_b ( var x_2:bv64 := phi(%g_entry -> x:bv64) ) [
         (var y_36:bv64=o) := call @f(x=x_2:bv64);
         goto (%g_return);
       ];
       block %g_return (
         var x_1:bv64 := phi(%g_b -> x_2:bv64, %g_a -> x_3:bv64),
         var y_29:bv64 := phi(%g_a -> y_9:bv64, %g_b -> y_36:bv64)
       ) [ (var o_1:bv64 := x_1:bv64, var p_4:bv64 := y_29:bv64); return; ]
    ];
    proc @loop(x:bv64, y:bv64)  -> (o:bv64, p:bv64) {  }


    [
       block %entry [
         var x_41:bv64 := bvadd(x:bv64, 0x1:bv64);
         var y_40:bv64 := bvadd(y:bv64, 0x1:bv64);
         goto (%ret,%a);
       ];
       block %a (
         var x_21:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
         var y_27:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
       ) [
         var x_23:bv64 := bvadd(x_21:bv64, 0x1:bv64);
         var y_24:bv64 := y_27:bv64;
         goto (%ret,%a);
       ];
       block %ret (
         var x_31:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
         var y_17:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
       ) [ (var o_1:bv64 := x_31:bv64, var p_5:bv64 := y_17:bv64); return; ]
    ];
    proc @cross(a:bv64, b:bv64)  -> (o:bv64) {  }


    [
       block %entry [ goto (%b,%a); ];
       block %a ( var a_3:bv64 := phi(%entry -> a:bv64) ) [
         var o_22:bv64 := a_3:bv64;
         goto (%ret);
       ];
       block %b ( var b_2:bv64 := phi(%entry -> b:bv64) ) [
         var o_18:bv64 := bvsub(b_2:bv64, 0x1:bv64);
         goto (%ret);
       ];
       block %ret ( var o_5:bv64 := phi(%a -> o_22:bv64, %b -> o_18:bv64) ) [
         var o_44:bv64 := o_5:bv64;
         return;
       ]
    ];
    proc @bool_id(a:bool)  -> (o:bool) {  }


    [ block %entry [ var o_1:bool := a:bool; return; ] ];
    prog entry @main;
    |}]
