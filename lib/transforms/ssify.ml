open Bincaml_util.Common
open Lang
open Lang.Common
open Containers

(** Naive implementation of a 3-part algorithm to construct an SSI representation of a program. 
    
    Based on chapter 13.2 from "SSA-based Compiler Design" (https://doi.org/10.1007/978-3-030-80515-9)

    First splits the program by inserting phi nodes and parallel copies, then renames each occurence of
    a variable, then removes uneccessary added instructions containing dead variables on their left or 
    right hand sides.

    Sigma instructions of a branch node are implemented by placing a phi node on each successor node.
    *)

(* TODO:
  - Create a main function that repeatedly does SSIfy on all variables in all procedures

  KNOWN ISSUES:
  - Null pointer analysis splitting strategy does not seem to be generated correctly (somehow)
*)

module SSIfy = struct
  (** Represents the instruction, i.e. Phi or Statement *)
  module Instruction = struct

    (** The instruction, which is either a Phi or a Statement *)
    type it =
      | Phi of Var.t Block.phi
      | Statement of { index:int ; statement:Program.stmt }
    [@@deriving ord, eq, show { with_path = false }]
    
    (** A pair between the block id and the instruction *)
    type t = ID.t * it [@@deriving ord, eq, show { with_path = false }]

    let get_block_id (inst : t) = fst inst

    (** Get an iter of the variables defined by the instruction *)
    let var_defines = function
      | Phi { lhs ; rhs } -> Iter.singleton lhs
      | Statement { index ; statement} -> Stmt.iter_assigned statement

    (** Get an iter of the variables used by the instruction *)
    let var_uses = function
      | Phi { rhs } -> List.to_iter rhs |> Iter.map snd
      | Statement { statement } -> Stmt.free_vars_iter statement

    let create_phi_inst block_id lhs rhs = (block_id, Phi { lhs ; rhs })
    let create_stmt_inst block_id index statement = (block_id, Statement { index ; statement })

    (** Replace the definitions of v by v' *)
    let replace_defs v v' (inst : t) : t = match inst with 
      | (block_id, Phi { lhs ; rhs } ) -> 
          (block_id, Phi { lhs = if Var.equal lhs v then v' else lhs ; rhs})
      | (block_id, Statement { index ; statement = stmt }) ->
          let stmt' = Stmt.map ~f_lvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
                                ~f_expr:id ~f_rvar:id stmt in
          (block_id, Statement { index ; statement = stmt' })
    
    (** Replace the uses of v by v' *)
    let replace_uses ?pred_block_id v v' (inst : t) : t =
      let expr_transform_alg =
        let open Expr.BasilExpr in 
        rewrite_typed (function
        | RVar { id ; attrib } when Var.equal id v -> Some (rvar ~attrib:attrib v')
        | _ -> None)
      in

      let (og_bid: ID.t), has_og_bid = match pred_block_id with
        | Some bid -> bid, true
        | None -> ID.fresh ~name:"⊥" (ID.make_gen ()) (), false (* TODO: I have no idea how this works, but it shouldn't matter cause we never use og_bid in this case*)
      in

      match inst with
      | (block_id, Phi { lhs ; rhs }) ->
        let rhs' = List.map (fun (bid, var) -> 
          if has_og_bid then (
            if ID.equal og_bid bid && Var.equal var v then (
              (bid, v') 
            ) else (
              (bid, var)
            )
          ) else (
            if Var.equal var v then (
              bid, v'
            ) else (
              bid, var
            )
          ) 
        ) rhs in
        (block_id, Phi { lhs = lhs ; rhs = rhs'})
      | (block_id, Statement old_stmt) -> 
        let stmt' = Stmt.map ~f_lvar:id
                             ~f_expr:(expr_transform_alg)
                             ~f_rvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
                             old_stmt.statement 
        in
        (block_id, Statement {index = old_stmt.index ; statement = stmt'})
  

  end

  module VertexSet = CCSet.Make (Procedure.Vert)

  module InstructionSet = CCSet.Make (Instruction)

  module Rev = struct
    include Procedure.G
    let succ = pred
    include Procedure.RevG
  end 
  
  module RevDom = Graph.Dominator.Make (Rev)

  module Dom = Graph.Dominator.Make (Procedure.G)

  (** Map from Var to (BlockID, Instruction) *)
  module DefUseMap = CCMultiMap.Make (Var) (Instruction)

  type ssi_info = { proc:((Var.t, Program.e) Procedure.t) ; non_actual_insts:(InstructionSet.t) ; defs:DefUseMap.t ; uses:DefUseMap.t ; web:VarSet.t }
  
  (** Return a set of all phi and statement instructions in a procedure *)
  let get_all_instructions proc =
    Procedure.fold_blocks_topo_fwd (fun all_insts_set bid block -> 
      (* let new_phi_count = (List.length block.phis) - (BidMap.find bid original_phi_count_map) in *)
      let phi_insts = 
        List.fold_left (fun (all_set, index) phi -> 
          (* if index < new_phi_count then (all_set, index + 1) else ( *)
          let inst = Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs
          in InstructionSet.add inst all_set, index + 1
          (* ) *)
        ) (all_insts_set, 0) block.phis |> fst
      in
      let stmt_insts =
        Vector.foldi (fun index all_set stmt -> 
          let inst = Instruction.create_stmt_inst bid index stmt in
          InstructionSet.add inst all_set
        ) all_insts_set block.stmts
      in
      InstructionSet.union phi_insts stmt_insts |> InstructionSet.union all_insts_set
    ) InstructionSet.empty proc

  (** Naively iterate through the procedure to produce def-use and use-def chains for a given variable v *)
  let get_var_uses_and_defs proc (v : Var.t) = 
    Procedure.fold_blocks_topo_fwd (fun (uses, defs) bid block ->
      let (phi_uses, phi_defs) = 
        List.fold_left (fun (use', def') phi ->
          let inst = Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs in
          let pu = if Iter.mem v (Instruction.var_uses (snd inst)) then InstructionSet.add inst use' else use' in
          let pd = if Iter.mem v (Instruction.var_defines (snd inst)) then InstructionSet.add inst def' else def' in
          (pu, pd)
        ) (uses, defs) block.phis
      in
      let (stmt_uses, stmt_defs) = 
      Vector.foldi (fun index (use', def') stmt ->
        let inst = Instruction.create_stmt_inst bid index stmt in
        let su = if Iter.mem v (Instruction.var_uses (snd inst)) then InstructionSet.add inst use' else use' in
        let sd = if Iter.mem v (Instruction.var_defines (snd inst)) then InstructionSet.add inst def' else def' in
        (su, sd)
      ) (uses, defs) block.stmts
      in
      (InstructionSet.union phi_uses stmt_uses, InstructionSet.union phi_defs stmt_defs)
    ) (InstructionSet.empty, InstructionSet.empty) proc

  (** Gets the second successors *)
  let second_successors graph (vert : Dom.vertex) = Procedure.G.succ graph vert |> List.concat_map (Procedure.G.succ graph)      

  (** Returns true if the beginning of the block with ID bid_a dominates beginning of block with ID bid_b *)
  let block_dominates graph bid_a bid_b =
    let idom = Dom.compute_idom graph (Procedure.Vert.Begin bid_a) in (* TODO: Using the entry node here causes neither of the 2 blocks to dominate eachother, which is odd. Check the Dominator documentation*)
    let dom = Dom.idom_to_dom idom in
    dom (Procedure.Vert.Begin bid_a) (Procedure.Vert.Begin bid_b)

  (** Returns true if instruction a dominates instruction b *)
  let instruction_dominates (graph : Dom.t) (inst_a : Instruction.t) (inst_b : Instruction.t) =
    let bid_a = fst inst_a in
    let bid_b = fst inst_b in
    if ID.equal bid_a bid_b then (
      (* Same block: check if statement index is smaller (earlier) than the other *)
      match inst_a, inst_b with
      | (_, Instruction.Statement stmt_a), (_, Instruction.Statement stmt_b) -> stmt_a.index <= stmt_b.index
      | _ -> true
    )
    else
      block_dominates graph bid_a bid_b 

  (** Takes the CFG graph and a current vertex and gives the list of immediately dominating vertices *)
  let get_dominated_vertices (graph : Dom.t) (vertex : Dom.vertex) =
    let idom = Dom.compute_idom graph Procedure.Vert.Entry in (* TODO: Have a strong feeling this should be vertex instead of Entry, but using vertex causes an infinite loop somehow(?) *)
    Dom.idom_to_dom_tree graph idom vertex

  let dom_frontier (graph : Dom.t) (vertex : Dom.vertex) : VertexSet.t = 
    let idom = Dom.compute_idom graph Procedure.Vert.Entry in
    let dom_tree = Dom.idom_to_dom_tree graph idom in 
    let df = 
    Dom.compute_dom_frontier graph dom_tree idom vertex
    |> VertexSet.of_list
    in df

  (** Adds a new phi for variable var from associated predecessor blocks with pred_block_ids to the block associated with block_id in the procedure proc *)
  let add_phi proc (block_id : ID.t) (var : Var.t) (pred_block_ids : ID.t list) =
    let block_to_add_phi_to = Procedure.find_block proc block_id in
    let new_rhs = List.map (fun pred_id -> (pred_id, var)) pred_block_ids in
    let new_phi : Var.t Block.phi = { lhs = var ; rhs = new_rhs } in
    let new_inst = Instruction.create_phi_inst block_id var new_rhs in
    let new_proc =
    Procedure.modify_block proc block_id (fun block ->
      Block.map ~phi:(fun phi_list -> new_phi :: phi_list) Fun.id block_to_add_phi_to)
    in
    new_proc, new_inst

  (** Adds a parallel copy of the variable var to the block with block_id in proc. Returns the new proc and the parallel copy instruction *)
  let add_copy_instruction proc (block_id : ID.t) (var : Var.t) =
    let copy_stmt = Stmt.Instr_Assign { al = [(var, Expr.BasilExpr.rvar var)] ; attrib = Attrib.empty } in
    let new_proc = Procedure.modify_block proc block_id (fun block -> Block.prepend_stmts block [copy_stmt]) in
    let new_inst = Instruction.create_stmt_inst block_id 0 copy_stmt in
    new_proc, new_inst

  (** Returns i_up and i_down, where both are lists of cfg vertices
  i_up is empty
  i_down is a list of Procedure.Vert.End vertices, for both blocks that contain multiple successor edges, and blocks
  that contain var in Block.assigned_vars_iter *)
  let create_range_analysis_splitting_strategy proc (var : Var.t) cfg : VertexSet.t * VertexSet.t = 
    Procedure.G.fold_vertex (fun (vert : Dom.vertex) (i_up, i_down) -> 
      match vert with
      | Procedure.Vert.End block_id ->
        let block = Procedure.find_block proc block_id in
        let tmp = if (Iter.mem var (Block.assigned_vars_iter block)) then (i_up, VertexSet.add vert i_down) else (i_up, i_down) in
        if (Procedure.G.succ cfg vert |> List.length > 1) then
          Procedure.G.fold_succ (fun succ_vert (up, down) -> (up, VertexSet.add succ_vert down)) cfg vert tmp
        else
          tmp
      | _ -> (i_up, i_down)
    ) cfg (VertexSet.empty, VertexSet.empty)

  let create_constant_propagation_splitting_strategy proc (var : Var.t) cfg : VertexSet.t * VertexSet.t =
    Procedure.G.fold_vertex (fun (vert : Dom.vertex) (i_up, i_down) ->
      match vert with 
      | Procedure.Vert.End block_id -> 
        let block = Procedure.find_block proc block_id in
        if Iter.mem var (Block.assigned_vars_iter block) then (i_up, VertexSet.add vert i_down) else (i_up, i_down)
      | _ -> (i_up, i_down)
      ) cfg (VertexSet.empty, VertexSet.empty)

  let get_uses_down proc var cfg =
    Procedure.G.fold_vertex (fun (vert : Dom.vertex) (i_up, i_down) ->
      match vert with 
      | Procedure.Vert.End block_id -> 
        let block = Procedure.find_block proc block_id in
        if Iter.mem var (Block.read_vars_iter block) then (i_up, VertexSet.add vert i_down) else (i_up, i_down)
      | _ -> (i_up, i_down)
    ) cfg (VertexSet.empty, VertexSet.empty)

  let create_null_pointer_splitting_strategy proc (var : Var.t) cfg : VertexSet.t * VertexSet.t =
    Procedure.G.fold_vertex (fun (vert : Dom.vertex) (i_up, i_down) ->
      match vert with 
      | Procedure.Vert.End block_id -> 
        let block = Procedure.find_block proc block_id in
        if (Iter.mem var (Block.assigned_vars_iter block) || Iter.mem var (Block.read_vars_iter block)) then (i_up, VertexSet.add vert i_down) else (i_up, i_down)
      | _ -> (i_up, i_down)
    ) cfg (VertexSet.empty, VertexSet.empty)

  let all_vertices cfg = Procedure.G.fold_vertex (fun vert verts -> vert :: verts) cfg [] |> List.rev

  (** Replaces the old instruction inst with the new inst' that has updated variables. *)
  let replace_instruction inst inst' curr_proc =
    match inst, inst' with
      | (block_id, Instruction.Phi old_phi),
        (_, Instruction.Phi new_phi) ->
          Procedure.modify_block curr_proc block_id (fun block ->
            Block.map ~phi:(List.map (fun phi ->
                    if Block.equal_phi Var.equal old_phi phi then new_phi else phi
                    )) Fun.id block
          )
      | (block_id, Instruction.Statement old_stmt),
        (_, Instruction.Statement new_stmt) -> 
          Procedure.modify_block curr_proc block_id (fun block ->
            Block.fmap_stmts_copy (fun stmts -> Vector.set stmts old_stmt.index new_stmt.statement) block
          )
      | _ -> failwith "Impossible - the type between old and new instruction was different" (* Shouldn't occur *)
  

  (** First step of SSI conversion - insertion of phi and sigma nodes *)
  module SplitLiveRange = struct
    (* Returns a updated procedure and set of non-actual instructions *)
    let insert_instructions (v : Var.t) (s_combined : VertexSet.t) proc = 
      let cfg = match Procedure.graph proc with | Some g -> g | None -> Procedure.G.empty in
      let is_join vertex = (match vertex with | Procedure.Vert.Begin block_id -> if Procedure.G.pred cfg vertex |> List.length > 1 then true else false | _ -> false) in
      let is_branch vertex = (match vertex with | Procedure.Vert.End block_id -> if Procedure.G.succ cfg vertex |> List.length > 1 then true else false | _ -> false) in
      let is_branch_successor vertex = (
        match vertex with 
        | Procedure.Vert.Begin block_id -> 
          let pred_verts = Procedure.G.pred cfg vertex in
          let rec check_preds (pred_list : Dom.vertex list) =
            match pred_list with
            | [] -> false
            | pred_vert :: tail ->
              if is_branch pred_vert then true else check_preds tail
            in
            check_preds pred_verts
        | _ -> false
        ) in

      let block_phi_rhs_already_contains (block : Procedure.Edge.block) (var : Var.t) (pred_block_id : ID.t) = 
        let phis = block.phis in
        let rec check_phi_rhs_for_var (phi_list : Var.t Block.phi list) =
          match phi_list with
          | [] -> false
          | phi :: tail -> 
            if List.mem (pred_block_id, var) phi.rhs then true else check_phi_rhs_for_var tail
        in
        check_phi_rhs_for_var phis
      in

      (** Check if a block uses a given variable before locally defining it, or doesn't define it at all *)
      let has_undefined_var (var : Var.t) (block_id : ID.t) proc =
        let block = Procedure.find_block proc block_id in
        (* TODO: Make this a recursive function similar to the function above *)
        let phi_status = List.fold_left (fun b phi -> 
          List.fold_left (fun b (bid, var') -> 
            if ID.equal bid block_id && Var.equal var var' then false
            else if Var.equal var var' then true
            else false
          ) false phi.Block.rhs) false block.phis in 
        let stmts = block.stmts in
        let rec check_stmt (index) =
          if index = (Vector.size stmts) then 
            true
          else
            let stmt = Vector.get stmts index in
            if VarSet.mem var (Stmt.free_vars stmt) then true
            else if Iter.mem var (Stmt.iter_lvar stmt) then false
            else check_stmt (index + 1)
        in
        (check_stmt 0) || phi_status
      in
 
      let proc_and_nai_set =
        VertexSet.fold (fun vert (curr_info)  -> 
          match vert with
          | Procedure.Vert.Begin block_id | Procedure.Vert.End block_id -> 
            let block = Procedure.find_block curr_info.proc block_id in
            if has_undefined_var v block_id proc then
              (* If block does not already contain any definition of v then *)
              if is_join vert then (
                (* If block.is_join then insert v <- phi([v..v]) in the block *)
                let pred_block_ids = Procedure.get_blocks_pred curr_info.proc vert in
                let (proc_with_phi, phi_inst) = add_phi curr_info.proc block_id v pred_block_ids in
                ({curr_info with proc = proc_with_phi ; non_actual_insts = InstructionSet.add phi_inst curr_info.non_actual_insts})
              ) else (
                if is_branch_successor vert then (
                  (* If block.is_branch then insert v <- phi(v) at each *)
                  (* Check if there is already a v <- phi(block_id : v)*)
                  let pred_block_ids = Procedure.get_blocks_pred curr_info.proc vert in
                  List.fold_left (fun (info') pred_id ->
                    (* If i.is_branch then insert phi(v <- v) at successor block*)
                    if is_branch (Procedure.Vert.End (pred_id)) && block_phi_rhs_already_contains block v pred_id then 
                      (info')
                    else (
                      let (proc_with_phi, phi_inst) = add_phi info'.proc block_id v [pred_id] in
                      ({info' with proc = proc_with_phi ; non_actual_insts = InstructionSet.add phi_inst info'.non_actual_insts})
                    )
                  ) (curr_info) pred_block_ids
                ) else (
                  if not (Iter.mem v (Block.assigned_vars_iter block)) then (
                    (* Insert a copy into the block *)
                    let (proc_with_copy, copy_inst) = add_copy_instruction curr_info.proc block_id v in
                    ({curr_info with proc = proc_with_copy ; non_actual_insts = InstructionSet.add copy_inst curr_info.non_actual_insts}) )
                  else (
                    curr_info
                  )
                )
              )
            else
              (curr_info) 
          | _ -> (curr_info) 
        ) s_combined ({ proc = proc ; non_actual_insts = InstructionSet.empty ; defs = DefUseMap.empty ; uses = DefUseMap.empty ; web = VarSet.empty}) 
      in proc_and_nai_set

    (** A version that is a little more accurate to the book's algorithm *)
    let insert_instructions_version2 (v : Var.t) (s_combined : VertexSet.t) proc : ('a, 'b) Procedure.t * InstructionSet.t = 
      let cfg = match Procedure.graph proc with | Some g -> g | None -> Procedure.G.empty in
      let is_join vertex = (match vertex with | Procedure.Vert.Begin block_id -> if Procedure.G.pred cfg vertex |> List.length > 1 then true else false | _ -> false) in
      let is_branch vertex = (match vertex with | Procedure.Vert.End block_id -> if Procedure.G.succ cfg vertex |> List.length > 1 then true else false | _ -> false) in

      let block_phi_rhs_already_contains (block : Procedure.Edge.block) (var : Var.t) (pred_block_id : ID.t) = 
        let phis = block.phis in
        let rec check_phi_rhs_for_var (phi_list : Var.t Block.phi list) =
          match phi_list with
          | [] -> false
          | phi :: tail -> 
            if List.mem (pred_block_id, var) phi.rhs then true else check_phi_rhs_for_var tail
        in
        check_phi_rhs_for_var phis
      in

      (** Check if a block uses a given variable before locally defining it, or doesn't define it at all *)
      let has_undefined_var (var : Var.t) (block_id : ID.t) proc =
        let block = Procedure.find_block proc block_id in
        let phi_status = List.fold_left (fun b phi -> 
          List.fold_left (fun b (bid, var') -> 
            if ID.equal bid block_id && Var.equal var var' then false
            else if Var.equal var var' then true
            else false
          ) false phi.Block.rhs) false block.phis in 
        let stmts = block.stmts in
        let rec check_stmt (index) =
          if index = (Vector.size stmts) then 
            true
          else
            let stmt = Vector.get stmts index in
            if VarSet.mem var (Stmt.free_vars stmt) then true
            else if Iter.mem var (Stmt.iter_lvar stmt) then false
            else check_stmt (index + 1)
        in
        (check_stmt 0) || phi_status
      in
 
      let proc_and_list =
        VertexSet.fold (fun vert (curr_proc, non_actual_insts) -> 
          match vert with
          | Procedure.Vert.Begin block_id | Procedure.Vert.End block_id -> 
            let block = Procedure.find_block curr_proc block_id in

            let (proc1, nai1) = if is_join vert then (
              if has_undefined_var v block_id proc then (
                let pred_block_ids = Procedure.get_blocks_pred curr_proc vert in
                let (proc_with_phi, phi_inst) = add_phi curr_proc block_id v pred_block_ids in
                (proc_with_phi, InstructionSet.add phi_inst non_actual_insts)
              ) else (
                (curr_proc, non_actual_insts)
              )
            ) else (
              (curr_proc, non_actual_insts)
            )
            in

            (* Ok to seperate the algorithm's if branches because it is 
              impossible for a vertex to be both a join and a branch anyway - at least to my knowledge *)
            let (proc2, nai2) = (if is_branch vert then (
              let succ_block_ids = Procedure.get_blocks_succ proc1 vert in
              List.fold_left (fun (proc', insts') succ_id ->
                if has_undefined_var v succ_id proc' then (
                  let succ_block = Procedure.find_block proc' succ_id in
                  if block_phi_rhs_already_contains succ_block v block_id then (proc', insts')
                  else 
                    let (proc_with_phi, phi_inst) = add_phi proc' succ_id v [block_id] in
                    (proc_with_phi, InstructionSet.add phi_inst insts')
                ) else (proc', insts')
              ) (proc1, nai1) succ_block_ids
            ) else ((proc1, nai1)))
            in

            if not (Iter.mem v (Block.assigned_vars_iter block)) then
              let (proc_with_copy, copy_inst) = add_copy_instruction proc2 block_id v in
              (proc_with_copy, InstructionSet.add copy_inst nai2)
            else
              (proc2, nai2) 
          | _ -> (curr_proc, non_actual_insts) 
        ) s_combined (proc, InstructionSet.empty)
      in proc_and_list

    (** Splits the range of the program *)
    let split (v : Var.t) ((i_up : VertexSet.t), (i_down : VertexSet.t)) proc =
      let cfg : Dom.t = match Procedure.graph proc with | Some g -> g | None -> Procedure.G.empty in
      let rev_cfg : RevDom.t = match Procedure.graph proc with | Some g -> g | None -> Procedure.G.empty in
      let is_join vertex = (match vertex with | Procedure.Vert.Begin block_id -> if Procedure.G.pred cfg vertex |> List.length > 1 then true else false | _ -> false) in
      let is_branch vertex = (match vertex with | Procedure.Vert.End block_id -> if Procedure.G.succ cfg vertex |> List.length > 1 then true else false | _ -> false) in
      
      (* Determine all the Begin vertices where the associated block defines v *)
      let defs_of_v : VertexSet.t = Procedure.G.fold_vertex (fun vert dovs ->
        match vert with 
        | Procedure.Vert.Begin bid ->
          let block = Procedure.find_block proc bid in
          if Iter.mem v (Block.assigned_vars_iter block) then (
            VertexSet.add vert dovs
          ) else (
            dovs
          )
        | _ -> dovs
      ) cfg VertexSet.empty
      in

      (* For each i E I_up *)
      let s_up = VertexSet.fold (fun vert sups -> 
        (* If i.is_join then *)
        if is_join vert then (
          (* Foreach edge E incoming_edges(i) do *)
          Procedure.G.fold_pred (fun pred_vert sups' ->
            VertexSet.union sups' (dom_frontier rev_cfg pred_vert)
          ) rev_cfg vert sups
        ) else (
          VertexSet.union sups (dom_frontier rev_cfg vert)
        )
      ) (i_up) (VertexSet.empty)
      in

      (* For each i E i_down *)
      let s_down = VertexSet.fold (fun vert sdown -> 
        (* If i.is_branch then *)
        if is_branch vert then (
          (* Foreach edge E outgoing_edges(i) do *)
          Procedure.G.fold_succ (fun succ_vert sdown' ->
            VertexSet.union sdown' (dom_frontier cfg succ_vert)
          ) cfg vert sdown
        ) else (
          VertexSet.union sdown (dom_frontier cfg vert)
        )
      ) (VertexSet.union s_up defs_of_v |> VertexSet.union i_down) (VertexSet.empty)
      in 

      let s_combined = VertexSet.union i_up i_down |> VertexSet.union s_up |> VertexSet.union s_down in
      insert_instructions v s_combined proc
  end

  (** Renames variable definitions and usages, and builds a def-use and use-def chain*)
  module VariableRenaming = struct
  
    (** Creates a fresh version of a variable and adds it to web *)
    let create_v' old_v (info:ssi_info) =
      let v' = Procedure.fresh_var ~pure:true ~name:(Var.name old_v) info.proc (Var.typ old_v) in
      let new_web = VarSet.add v' info.web in
      Procedure.decl_local info.proc v', {info with web = new_web}

    (** Returns a procedure that has renamed v, and the relative transformed non-actual instructions*)
    let rename (v: Var.t) (split_info : ssi_info) =
      (* Stack <- new *)
      let stack : Var.t Stack.t = Stack.create() in
      
      (* The control flow graph of the current procedure *)
      let cfg = match Procedure.graph split_info.proc with 
        | Some g -> g | None -> Procedure.G.empty
      in

      (* Returns the proc with replaced inst' *)
      (* let set_def curr_proc (inst : Instruction.t) (non_actual_insts : InstructionSet.t) (defs : DefUseMap.t) (uses : DefUseMap.t) =  *)
      let set_def (curr_info : ssi_info) (inst : Instruction.t) = 
        (* Let v' be a fresh version of v *)
        let v', curr_info = create_v' v curr_info in

        (* Replace the defs of v by v' in inst *)
        let (inst' : Instruction.t) = Instruction.replace_defs v v' inst
        in

        (* Set Def(v') = inst' *)
        let defs' = DefUseMap.add curr_info.defs v' inst' in

        (* stack.push(v') *)
        Stack.push v' stack;

        let proc' = replace_instruction inst inst' curr_info.proc in
        let nai' = InstructionSet.map (
          fun old_nai_inst -> if Instruction.equal inst old_nai_inst then inst' else old_nai_inst
        ) curr_info.non_actual_insts in
        {curr_info with proc = proc' ; non_actual_insts = nai' ; defs = defs' }
      in
      
      (* let set_use curr_proc (inst : Instruction.t) (og_bid : ID.t) (non_actual_insts : InstructionSet.t) (defs : DefUseMap.t) (uses : DefUseMap.t) =  *)
      let set_use (curr_info : ssi_info) (inst : Instruction.t) (og_bid : ID.t) =
        (* while Def(stack.peek()) does not dominate inst do *)
        let rec pop_while_not_dominating instruction =
          match Stack.top_opt stack with
          | None -> ()
          | Some v' ->
            (* It's ok to use the outdated defs map here, because we only use the location pointers, not the potentially outdated instruction *)
            let v'_def_instructions = DefUseMap.find curr_info.defs v' 
            in
            if List.for_all (fun v'_def -> 
                not (instruction_dominates cfg (v'_def) (instruction))
              ) v'_def_instructions then (
              ignore (Stack.pop stack);
              pop_while_not_dominating instruction
              )
        in
        pop_while_not_dominating inst;

        (* v' <- stack.peek() *)
        let v' = let open Bincaml_util.Unicode in Option.value (Stack.top_opt stack) ~default:(Var.create bot_char (Var.typ v) ~scope:(Var.scope v)) in

        let inst' = Instruction.replace_uses ~pred_block_id:og_bid v v' inst 
        in

        (* If v' != ⊥ then set Uses(v') = Uses(v') ∪ inst' *) 
        let uses' = if String.equal (Var.name v') Bincaml_util.Unicode.bot_char then curr_info.uses else DefUseMap.add curr_info.uses v' inst' in

        let proc' = replace_instruction inst inst' curr_info.proc in
        let nai' = InstructionSet.map (fun old_nai_inst -> if Instruction.equal inst old_nai_inst then inst' else old_nai_inst) curr_info.non_actual_insts in

        {curr_info with proc = proc' ; non_actual_insts = nai' ; uses = uses'}, inst'
      in

      (* foreach CFG node n in dominance order do *)
      let rec visit_begin_node (start_info : ssi_info) (node : Dom.vertex) = 
        let (final_info : ssi_info) =
        (* We're only looking at Begin nodes : Skip if not Begin *)
        match node with
        | Procedure.Vert.Begin block_id -> (
          (*
          IMPORTANT:
          Our CFG is structured a little differently to the book. Our nodes that we are looping
          on are exclusively Begin nodes, so In(node) is the outgoing edge of the node.

          Since we don't have explicit 'program points' inside of the block we loop through the statements
          inside the block, since it is a precondition that they are ordered in the statement list that all
          blocks contain.

          We can amend this workaround by splitting the procedure into many multiple different blocks during
          Split(), but this is extra work for the same effect.

          So for a node n, In(n) = succ_e n i.e. the immediate block that this 'Begin' corresponds to,
          and for m in direct-successors(n), direct-successors(n) is the second vertex from n, since
          the order is n(Begin) -> n'(End) -> n''(Begin | Return | Exit). 
          In(m) will be the immediate outgoing edge of n'', iff n'' is a Begin. Otherwise stop processing.

          It's a little confusing, but in relation to the original algorithm, 'n' and 'In(n)' both refer to
          the same program block. And for my rename implementation, 'n' is referring to a statement in the block.

          However, in order to make the algorithm work, for lines 6-9 then we will need a loop
          that loops through every statement in the statement list of a block in order.
          *)

          (* Assuming that all Begin vertices always have a single outgoing Block edge *)
          let block = Procedure.find_block start_info.proc block_id in


          (* If exists Phi node with lhs matching v in In(node) then *)
          let info_step_one = List.fold_left (fun (curr_info) phi ->
            if Var.equal phi.Block.lhs v then (
              let inst = Instruction.create_phi_inst block_id phi.lhs phi.rhs in
              set_def curr_info inst
            ) else (
              curr_info
            )
          ) (start_info) block.phis in

          (* foreach instruction u in n that uses v do *)
          let info_step_three = Vector.foldi (fun index (curr_info) stmt ->   
            let inst = Instruction.create_stmt_inst block_id index stmt in
            let info_step_two, updated_inst =
              (* An instruction that uses v*)
              if VarSet.mem v (Stmt.free_vars stmt) then
                set_use curr_info inst block_id 
              else
                curr_info, inst
            in
            (* If exists instruction d in n that defines v then *)
            if Iter.mem v (Stmt.iter_lvar stmt) then
              set_def info_step_two updated_inst
            else 
              info_step_two
            ) (info_step_one) block.stmts
          in

          let next_vertices = second_successors cfg node in
          (* Foreach m in direct-successors(n) do *)
          let final_info = List.fold_left (fun (curr_info) vert -> 
            match vert with
            | Procedure.Vert.Begin succ_block_id -> (
              let succ_block = Procedure.find_block curr_info.proc succ_block_id in
              List.fold_left (fun (info') phi ->
                List.fold_left (fun (info'') (ogbid, var) -> 
                  (* If E v <- phi(v:l) in In(m) then *)
                  if ID.equal ogbid block_id && Var.equal var v then
                    let inst = Instruction.create_phi_inst succ_block_id phi.Block.lhs phi.Block.rhs in
                    (* stack.set_use(v <- v:l) *)
                    let info4, inst4 = set_use info'' inst ogbid
                    in
                  info4
                  else
                    info'') (info') phi.Block.rhs
              ) (curr_info) succ_block.phis)
            | _ -> curr_info
            ) (info_step_three) next_vertices in
          final_info
        )
        | _ -> start_info
        in
        List.fold_left visit_begin_node (final_info) (get_dominated_vertices cfg node)
      in
      let rename_info = visit_begin_node (split_info) Procedure.Vert.Entry in
        
    (* Update a potentially outdated instruction with the instruction in the same location in the given proc.
       For Statements, we simply use the block_id and stmt index to retrieve the relevant statement.
       For Phis, if we are updating the Def-Use chain, then we use the block_id to get the relevant block, then we
       loop on the phi list to find the first one that defines our variable. If we are updating the Use-Def chain, then we
       use the block_id to get the relevant block, then we loop on the phi list to find the first one that uses our variable.
       Obviously, this is not simple, and is also assuming that a variable can only be used in one phi node. 
       Perhaps appending to the end of the list in Split, and keeping the index in the list would be easier here, though
       it may not be as efficient. This will need testing to determine which is better. *)

      let update_chain is_def_map oldmap proc =
        DefUseMap.fold oldmap DefUseMap.empty (fun newmap var inst -> 
        let inst' = match inst with
        | (block_id, Instruction.Statement stmt) -> (
          let block = Procedure.get_block proc block_id in 
          match block with
          | None -> (inst)
          | Some b -> (let stmt' = Vector.get b.stmts stmt.index in Instruction.create_stmt_inst block_id stmt.index stmt')
          )
        | (block_id, Instruction.Phi phi) -> (
          let block = Procedure.get_block proc block_id in
          match block with
          | None -> (inst)
          | Some b -> (
            let rec get_def_phi (phi_list : Var.t Block.phi list) =
              match phi_list with
              | [] -> inst
              | head :: tail -> 
                let cond = (
                  match is_def_map with
                  | true -> Var.equal head.lhs var 
                  | false -> List.mem ~eq:Var.equal var (List.map (fun (_, v) -> v) head.rhs)
                ) in
                if cond then (Instruction.create_phi_inst block_id head.lhs head.rhs) else (get_def_phi tail)
            in
            get_def_phi b.phis
          )
        )
        in
        DefUseMap.add newmap var inst'
      )
      in

      let updated_defs = update_chain true rename_info.defs rename_info.proc in
      let updated_uses = update_chain false rename_info.uses rename_info.proc in

      { rename_info with defs = updated_defs ; uses = updated_uses }
  end

  (** Eliminates dead and undefined code, for instructions added by split involving the current variable being split *)
  module DeadCodeElim = struct
    let cleanup (live : VarSet.t) (v : Var.t) (rename_info : ssi_info) =
      let bot_var = let open Bincaml_util.Unicode in Var.create bot_char (Var.typ v) ~scope:(Var.scope v) in

      (* Foreach non actual instruction E Def(web) do *)
      InstructionSet.fold (fun (inst : Instruction.t) curr_proc -> 
        let instruction = snd inst in 
        let inst_is_def_of_web = instruction |> Instruction.var_defines |> VarSet.of_iter |> VarSet.inter rename_info.web |> VarSet.is_empty |> not  in
        if inst_is_def_of_web then (
          let all_vars = Iter.append (Instruction.var_defines instruction) (Instruction.var_uses instruction) |> VarSet.of_iter in 

          (* For each v' operand of inst | v' !E live *)
          let proc_step_one, inst_step_one = VarSet.fold (fun v' (proc', inst') ->
            if VarSet.mem v' rename_info.web  && (not (VarSet.mem v' live)) then (
              (* Replace v' by ⊥ *)
              let replaced_inst = Instruction.replace_defs v' bot_var inst' |> Instruction.replace_uses v' bot_var
              in
              replace_instruction inst' replaced_inst proc', replaced_inst
            ) else (
              proc', inst'
            ) 
          ) all_vars (curr_proc, inst)
          in 
          
          let just_bot_char = VarSet.empty |> VarSet.add bot_var in 
          (* If inst.defs = {⊥} or inst.uses = {⊥} *)
          if Instruction.var_defines (snd inst_step_one) |> VarSet.of_iter |> VarSet.equal just_bot_char 
            || Instruction.var_uses  (snd inst_step_one) |> VarSet.of_iter |> VarSet.equal just_bot_char then (
            (* Remove inst *)
            match inst_step_one with
            | (block_id, Instruction.Phi bot_phi) -> 
              let unmodified_block = Procedure.find_block proc_step_one block_id in
              let unmodified_phis = unmodified_block.phis in
              let new_phis = List.filter (fun phi -> 
                Block.equal_phi Var.equal phi bot_phi |> not
              ) unmodified_phis in
              let modified_block = {unmodified_block with phis = new_phis} in
              Procedure.update_block proc_step_one block_id modified_block
            | (block_id, Instruction.Statement bot_stmt) -> 
              let unmodified_block = Procedure.find_block proc_step_one block_id in
              let modified_stmts = Vector.create () in 
              Vector.append modified_stmts unmodified_block.stmts;
              Vector.remove_and_shift modified_stmts bot_stmt.index;
              let modified_block = {unmodified_block with stmts = Vector.freeze modified_stmts} in
              Procedure.update_block proc_step_one block_id modified_block
            ) else (
              proc_step_one
            )
        ) else (
          curr_proc
        )
      ) rename_info.non_actual_insts rename_info.proc 
      
    (** Builds the defined and used sets to be used in cleanup *)
    let clean (v : Var.t) rename_info =
      let all_insts = get_all_instructions rename_info.proc in 
      let actual_insts = InstructionSet.diff all_insts rename_info.non_actual_insts in

      (* active <- inst|inst actual instruction and web ∩ inst.defs != null *)
      let active_defs = InstructionSet.filter (fun inst ->
        VarSet.inter rename_info.web (Instruction.var_defines (snd inst) |> VarSet.of_iter) |> VarSet.is_empty |> not 
      ) actual_insts in

      (* defines <- {∅} *)
      let initial_defined = VarSet.empty in 
    
      (* While exists an instruction in active such that the intersection of web and instruction.defs - curr_defined != {∅}*)
      let rec create_defined_while_loop (curr_active_defs : InstructionSet.t) (curr_defined : VarSet.t) : VarSet.t =
        let unregistered_def_vars (inst : Instruction.t) = 
          VarSet.diff (VarSet.inter rename_info.web (Instruction.var_defines (snd inst) |> VarSet.of_iter)) curr_defined
        in
        let guard (inst : Instruction.t) =  
          unregistered_def_vars inst |> VarSet.is_empty |> not
        in
        match Seq.find guard (InstructionSet.to_seq curr_active_defs) with
        | None -> curr_defined
        | Some inst -> (
          let vars = inst |> unregistered_def_vars in
          (* Foreach v' elem (web ∩ inst.defs - curr_defined)*)
          let new_active, new_defs = VarSet.fold (fun var (active', defined') -> 
            (* Active <- active union Uses(v') *)
            let var_uses = DefUseMap.find rename_info.uses var |> InstructionSet.of_list in
            (* Defined <- defined union {v'} *)
            let single_var = VarSet.add var VarSet.empty in
            (InstructionSet.union var_uses active', VarSet.union single_var defined')
          ) vars (curr_active_defs, curr_defined )
          in
          create_defined_while_loop new_active new_defs
        )
      in
      let defined = create_defined_while_loop active_defs initial_defined in

      (* uses <- {∅} *)
      let initial_uses = VarSet.empty in
      (* active <- {inst | inst actual instruction and web ∩ inst.defs != {∅} *)
      let active_uses = InstructionSet.filter (fun inst ->
        VarSet.inter rename_info.web (Instruction.var_uses (snd inst) |> VarSet.of_iter) |> VarSet.is_empty |> not
      ) actual_insts 
      in

      (* While exists an instruction in active such that instruction.uses - curr_used != {∅} *)
      let rec create_uses_while_loop (curr_active_uses : InstructionSet.t) (curr_used : VarSet.t) : VarSet.t =
        let unregistered_use_vars (inst : Instruction.t) = 
          VarSet.diff  (VarSet.inter rename_info.web (Instruction.var_uses (snd inst) |> VarSet.of_iter)) curr_used
        in
        let guard (inst : Instruction.t) =  
          unregistered_use_vars inst
          |> VarSet.is_empty |> not
        in
        match Seq.find guard (InstructionSet.to_seq curr_active_uses) with
        | None -> curr_used
        | Some inst -> ( let vars = unregistered_use_vars inst in
          (* Foreach v' elem (web ∩ inst.uses - curr_used) *)
          let new_active, new_used = VarSet.fold (fun var (active', used') -> 
            (* Active <- active union Def(v') *)
            let var_defs = DefUseMap.find rename_info.defs var |> InstructionSet.of_list in
            (* Used <- used union {v'} *)
            let single_var = VarSet.add var VarSet.empty in
            (InstructionSet.union var_defs active', VarSet.union single_var used')
          ) vars (curr_active_uses, curr_used )
          in
          create_uses_while_loop new_active new_used)
      in

      let used = create_uses_while_loop active_uses initial_uses in
      let live = VarSet.inter defined used in
      cleanup live v rename_info
  end

  let ssify ?splitting_strategy (v: Var.t) proc =
    let cfg = match Procedure.graph proc with 
        | Some g -> g | None -> Procedure.G.empty
    in
    let pv = match splitting_strategy with
    | None -> create_range_analysis_splitting_strategy proc v cfg 
    | Some ss -> ss
    in
    let split_info = SplitLiveRange.split v pv proc in
    let rename_info = VariableRenaming.rename v split_info in
    let clean_proc = DeadCodeElim.clean v rename_info in
    clean_proc
end
    
(*let%expect_test "test_rename" =
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
  let proc' = SSIfy.VariableRenaming.rename v (proc SSIfy.InstructionSet.empty) |> fst in
  Program.output_proc_pretty stdout proc';
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 ( var v_3:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, 69);
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
         var v_9:bv64 := phi(%main_1 -> v_4:bv64, %main_2_1 -> v_8:bv64)
       ) [
         var v_10:bv64 := bvadd(v_9:bv64, 0x1:bv64);
         var out:bv64 := v_10:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "test_insert_instructions_during_split" =
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
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, 69);
      var tmp:bv64 := bvadd(i, 1:bv64);
      goto(%main_return);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      (var v:bv64=OY_out) := call @OY();
      var v:bv64 := bvadd(v:bv64, 420);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
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
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let cfg = match Procedure.graph proc with | Some g -> g | None -> Procedure.G.empty in
  let vertices = Procedure.G.fold_vertex (fun vert verts -> vert :: verts) cfg [] |> List.rev in
  let proc', nai' = SSIfy.SplitLiveRange.insert_instructions_version2 v (SSIfy.VertexSet.of_list vertices) proc  in
  let proc_rename = SSIfy.VariableRenaming.rename v proc' nai' |> fst in
  Program.output_proc_pretty stdout proc';
  Printf.printf "\n\n -----------\n RENAME \n ---------\n\n";
    Program.output_proc_pretty stdout proc_rename;

  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v:bv64 := 0x0:bv64;
         (var v:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 ( var v:bv64 := phi(%main_entry -> v:bv64) ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v:bv64, 0xa:bv64);
         var v:bv64 := bvadd(v:bv64, 69);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return);
       ];
       block %main_2 [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         (var v:bv64=OY_out) := call @OY();
         var v:bv64 := bvadd(v:bv64, 420);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var v:bv64 := v:bv64;
         var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v:bv64 := phi(%main_2_1 -> v:bv64, %main_1 -> v:bv64)
       ) [ var v:bv64 := bvadd(v:bv64, 0x1:bv64); var out:bv64 := v:bv64; return; ]
    ]

     -----------
     RENAME
     ---------

    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 ( var v_3:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, 69);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return);
       ];
       block %main_2 [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         (var v_5:bv64=OY_out) := call @OY();
         var v_6:bv64 := bvadd(v_5:bv64, 420);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var v_7:bv64 := v_6:bv64;
         var namnam:bv64 := bvor(v_7:bv64, 0xffffffff:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_8:bv64 := phi(%main_2_1 -> v_7:bv64, %main_1 -> v_4:bv64)
       ) [
         var v_9:bv64 := bvadd(v_8:bv64, 0x1:bv64);
         var out:bv64 := v_9:bv64;
         return;
       ]
    ]
    |}]*)
  
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
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, v);
      var tmp:bv64 := bvadd(i, 1:bv64);
      goto(%main_return, %main_1);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      var v:bv64 := bvadd(v:bv64, 420);
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
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let proc_split = SSIfy.ssify v proc in
    Program.output_proc_pretty stdout proc_split;

  [%expect
    {|
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
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let proc_split = SSIfy.ssify v proc in
    Program.output_proc_pretty stdout proc_split;

[%expect {|
  proc @main(i:bv64)  -> (out:bv64) {  }


  [
     block %main_entry [ var v_1:bv64 := 0; goto (%main_2,%main_1); ];
     block %main_1 ( var v_6:bv64 := phi(%main_entry -> v_1:bv64) ) [
       guard bvsmod(i:bv64, 0x2:bv64);
       var v_7:bv64 := bvadd(v_6:bv64, 2);
       goto (%main_4,%main_3);
     ];
     block %main_3 ( var v_10:bv64 := phi(%main_1 -> v_7:bv64) ) [
       guard bvsmod(i:bv64, 0x2:bv64);
       var v_11:bv64 := bvadd(v_10:bv64, 0x3:bv64);
       goto (%main_return);
     ];
     block %main_4 ( var v_8:bv64 := phi(%main_1 -> v_7:bv64) ) [
       guard boolnot(bvsmod(i:bv64, 0x2:bv64));
       var v_9:bv64 := bvadd(v_8:bv64, 0x4:bv64);
       goto (%main_return);
     ];
     block %main_2 ( var v_4:bv64 := phi(%main_entry -> v_1:bv64) ) [
       guard boolnot(bvsmod(i:bv64, 0x2:bv64));
       var v_5:bv64 := bvadd(v_4:bv64, 1);
       goto (%main_return);
     ];
     block %main_return (
       var v_2:bv64 := phi(%main_2 -> v_5:bv64, %main_4 -> v_9:bv64,
          %main_3 -> v_11:bv64)
     ) [
       var v_3:bv64 := bvadd(v_2:bv64, 0x1:bv64);
       var out:bv64 := v_3:bv64;
       return;
     ]
  ]
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
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let proc_split = SSIfy.ssify v proc in
    Program.output_proc_pretty stdout proc_split;
[%expect {|
  proc @main(i:bv64)  -> (out:bv64) {  }


  [
     block %main_entry [ var v_1:bv64 := 0; goto (%main_2,%main_1); ];
     block %main_1 ( var v_7:bv64 := phi(%main_entry -> v_1:bv64) ) [
       guard bvsmod(i:bv64, 0x2:bv64);
       var v_8:bv64 := bvadd(v_7:bv64, 2);
       goto (%main_return);
     ];
     block %main_2 (
       var v_4:bv64 := phi(%main_2_1 -> v_6:bv64, %main_entry -> v_1:bv64)
     ) [
       guard boolnot(bvsmod(i:bv64, 0x2:bv64));
       var v_5:bv64 := bvadd(v_4:bv64, 1);
       goto (%main_2_1);
     ];
     block %main_2_1 [
       guard boolnot(bvsmod(i:bv64, 0x2:bv64));
       var v_6:bv64 := bvadd(v_5:bv64, 0x4:bv64);
       goto (%main_return,%main_2);
     ];
     block %main_return (
       var v_2:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
     ) [
       var v_3:bv64 := bvadd(v_2:bv64, 0x1:bv64);
       var out:bv64 := v_3:bv64;
       return;
     ]
  ]
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
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let proc_split = SSIfy.ssify v proc in
    Program.output_proc_pretty stdout proc_split;
[%expect {|
  proc @main(i:bv64)  -> (out:bv64) {  }


  [
     block %main_entry [ var v_1:bv64 := 0; goto (%main_1); ];
     block %main_1 (
       var v_2:bv64 := phi(%main_1 -> v_3:bv64, %main_entry -> v_1:bv64)
     ) [
       guard bvsmod(i:bv64, 0x2:bv64);
       var v_3:bv64 := bvadd(v_2:bv64, 2);
       goto (%main_return,%main_1);
     ];
     block %main_return ( var v_4:bv64 := phi(%main_1 -> v_3:bv64) ) [
       guard boolnot(bvsmod(i:bv64, 0x2:bv64));
       var v_5:bv64 := bvadd(v_4:bv64, 0x1:bv64);
       var out:bv64 := v_5:bv64;
       return;
     ]
  ]
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
let proc = Program.entry_proc_exn program in
let v =
  match Procedure.lookup_local_decl proc "v" with
  | Some v -> v  | None -> failwith "Bleh"
in
let proc_split = SSIfy.ssify v proc in
  Program.output_proc_pretty stdout proc_split;
[%expect {|
  proc @main()  -> () {  }


  [
     block %e [ var v_1:bv64 := 0; goto (%e3,%e2,%e1); ];
     block %e1 (
       var v_8:bv64 := phi(%e3 -> v_6:bv64, %e2 -> v_7:bv64, %e -> v_1:bv64)
     ) [ var v_9:bv64 := bvadd(v_8:bv64, 1); goto (%e2); ];
     block %e2 ( var v_7:bv64 := phi(%e1 -> v_9:bv64, %e -> v_1:bv64) ) [
       goto (%e4,%e1);
     ];
     block %e3 ( var v_5:bv64 := phi(%e -> v_1:bv64) ) [
       var v_6:bv64 := bvadd(v_5:bv64, 2);
       goto (%e4,%e1);
     ];
     block %e4 ( var v_2:bv64 := phi(%e3 -> v_6:bv64, %e2 -> v_7:bv64) ) [
       var v_3:bv64 := bvadd(v_2:bv64, 2);
       goto (%e5);
     ];
     block %e5 [ var v_4:bv64 := bvadd(v_3:bv64, 67); return; ]
  ]
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
  let proc_split = SSIfy.ssify v proc in
    Program.output_proc_pretty stdout proc_split;

  [%expect
    {|
    AAAAAAAAAAAA
    (("%main_1", 0),
     (Phi
        { Block.lhs = v_12:bv64;
          rhs = [(("%main_entry", 1), v_9:bv64); (("%main_1", 0), v_12:bv64)] }))
    (
    ("%main_1", 0),
    (Phi
       { Block.lhs = ⊥:bv64;
         rhs = [(("%main_entry", 1), ⊥:bv64); (("%main_1", 0), ⊥:bv64)] }))
    AAAAAAAAAAAA
    (
    ("%main_return", 4),
    (Phi
       { Block.lhs = v_10:bv64;
         rhs = [(("%main_2_1", 2), v_11:bv64); (("%main_1", 0), v_12:bv64)] }))
    (
    ("%main_return", 4),
    (Phi
       { Block.lhs = ⊥:bv64;
         rhs = [(("%main_2_1", 2), ⊥:bv64); (("%main_1", 0), ⊥:bv64)] }))
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_9:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_12:bv64 := phi(%main_entry -> ⊥:bv64, %main_1 -> v_12:bv64),
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
         var ⊥:bv64 := phi(%main_2_1 -> v_11:bv64, %main_1 -> v_12:bv64),
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ]
    ]
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
let proc = Program.entry_proc_exn program in
let v =
  match Procedure.lookup_local_decl proc "x" with
  | Some v -> v  | None -> failwith "Bleh"
in
let proc_split = SSIfy.ssify v proc in
  Program.output_proc_pretty stdout proc_split;
[%expect {|
  proc @main()  -> () {  } 


  [
     block %e [ var v_1:bv64 := 0; var x_1:bv64 := 2; goto (%e1,%e2,%e3); ];
     block %e3 (
       var x_2:bv64 := phi(%e -> x_1:bv64),
       var v_6:bv64 := phi(%e -> v_1:bv64)
     ) [ var v_7:bv64 := bvadd(v_6:bv64, 2); goto (%e4,%e1); ];
     block %e2 (
       var x_3:bv64 := phi(%e1 -> x_6:bv64, %e -> x_1:bv64),
       var v_4:bv64 := phi(%e1 -> v_3:bv64, %e -> v_1:bv64)
     ) [
       var v_5:bv64 := v_4:bv64;
       var x_4:bv64 := bvadd(x_3:bv64, 2);
       goto (%e4,%e1);
     ];
     block %e1 (
       var x_5:bv64 := phi(%e -> x_1:bv64, %e2 -> x_4:bv64, %e3 -> x_2:bv64),
       var v_2:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64, %e -> v_1:bv64)
     ) [
       var x_6:bv64 := bvadd(x_5:bv64, 1);
       var v_3:bv64 := bvadd(v_2:bv64, 1);
       goto (%e2);
     ];
     block %e4 (
       var x_7:bv64 := phi(%e2 -> x_4:bv64, %e3 -> x_2:bv64),
       var v_8:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64)
     ) [ var v_9:bv64 := bvadd(v_8:bv64, 2); goto (%e5); ];
     block %e5 [
       var v_10:bv64 := bvadd(v_9:bv64, 67);
       var x_8:bv64 := bvadd(x_7:bv64, 5);
       return;
     ]
  ]
  |}]
