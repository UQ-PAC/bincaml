open Bincaml_util.Common
open Lang
open Lang.Common
open Containers
(* Should probably be Procedure.G. Check if so for rename, and how hard a refactor would be *)



  (* let phi_to_def (joined_phis : (Var.t * (IDSet.elt * Var.t) list) VarMap.t) =
    VarMap.values joined_phis
    |> Iter.map (function lhs, rhs -> Block.{ lhs; rhs })
    |> Iter.to_list *)



(* Def(v) is the instruction v is defined in
   Uses(v) is the set of instructions using v
   Obtained using def_use_maps proc and var_to_use map or var_to_def map
*)

(**
 I_up is Defs is Procedure.local_decls
 I_out is the successors of the conditional statements
 Uses is custom
 CFG is Procedure.G

 Conditional if Stmt is Instr_Assume for Out(Conds)

  G.map_vertex(v |> succ)

  For is_join, check count of pred. Do length of G.pred vertex

  ocamlgraph.compute_dom_frontier on Procedure.RevG for pDF

  Defs(v) do get_local_decls of procedure and filter.

  For branches, check count of succ

  Out(pDF+(e)) where e is pred of current node do succ on e
  Similarly In(DF+(e)) is pred of e

  Iterate over vertices, if end of join block then add phi, if start of branch block then add sigma

    Splitting Strategy is Defs_down Union Out(Conds)_down
*)

(**
Current assumptions:
  Using dataflow_graph.DFGraph for CFG
  Each node is a Dataflow_graph.Vertex
  Sigma nodes will be implemented as Phi nodes

Unknown:
  How to represent a Var.Bottom
  How to replace the old instruction with the new instruction without using Procedure.map
  How to set Def(v') and Uses(v') globally - currently just local to the function
  What nodes are vs vertices


  How to use Procedure.G
  How to replace Block edges in Procedure.G. Remove and add?


Maybe:
  Each vertex is a program point, each edge is either a block or goto.
  Gotos are singular: A branch will have multiple outgoing edges that are gotos
  Is_join and is_branch if it has multiple in/outgoing edges that are gotos
  In(vertex) is pred and Out(ver)




Right now, the program creates a new instruction that uses v' and adds it to the local
defs/uses MDeps map.

Defs() can be a map from variables to indexes. The indexes are the index of the statement in the statement list.
Variant between Phi or Statement. It will be a multimap that i make locally.

Will have to create a new Procedure with the replaced statement each time
Will have to use Block.map for phis and Stmt.map inside of that.

Procedure.map_blocks_topo_fwd (fun (bid, block) ->
  Block.map
    ~phi:(function that checks if phi is equal to oldphi and replaces with newphi)
    (Stmt.map respective map stuff)
    block
  )
  proc

*)

module SSIfy = struct
  (* TODO: reduce usage of ref *)

  (* Represents the instruction, i.e. Phi or Statement *)
  module Instruction = struct

    type it =
      | Phi of Var.t Block.phi
      | Statement of { index:int ; statement:Program.stmt }
    [@@deriving ord, eq, show { with_path = false }]
    
    (* ID.t will be the ID of the block *)
    type t = ID.t * it [@@deriving ord, eq, show { with_path = false }]

    let var_defines = function
      | Phi { lhs ; rhs } -> Iter.singleton lhs
      (* | Statement { index ; statement = (Instr_Assume _) as s} -> Stmt.free_vars_iter s
      | Statement { index ; statement = (Instr_Assert _) as s} -> Stmt.free_vars_iter s *)
      | Statement { index ; statement} -> Stmt.iter_assigned statement

    let var_uses = function
      | Phi { rhs } -> List.to_iter rhs |> Iter.map snd
      | Statement { statement } -> Stmt.free_vars_iter statement

    let create_phi_inst block_id lhs rhs = (block_id, Phi { lhs ; rhs })
    let create_stmt_inst block_id index statement = (block_id, Statement { index ; statement })
  end

  (* Procedure.G.compute_dom_front *)
  module Dom = Graph.Dominator.Make (Procedure.G)

  (* Map from Var to (BlockID, Instruction) *)
  module DefUseMap = CCMultiMap.Make (Var) (Instruction)

  (* 'Global' def and use maps *)
  let defs : DefUseMap.t ref = ref DefUseMap.empty
  let uses : DefUseMap.t ref = ref DefUseMap.empty

  (* List of new_v *)
  (* TODO: This is a placeholder, there is definitely a better structure for this *)
  let new_renames : (Var.t) list ref = ref []

  (* Gets the second successors *)
  let second_successors graph (vert : Dom.vertex) = Procedure.G.succ graph vert |> List.concat_map (Procedure.G.succ graph)      

  (* If we need more stuff, use compute_all cfg Vert.Entry,
  but for now I only need dom
  compute_all is part of Make_graph, which I can't figure out how to instantiate
  *)

  (* Returns true if the beginning of the block with ID bid_a dominates 
    beginning of block with ID bid_b *)
  let block_dominates graph bid_a bid_b =
    let idom = Dom.compute_idom graph Procedure.Vert.Entry in
    let dom = Dom.idom_to_dom idom in
    dom (Procedure.Vert.Begin bid_a) (Procedure.Vert.Begin bid_b)

  (* Returns true if instruction a dominates instruction b *)
  let instruction_dominates (graph : Dom.t) (inst_a : Instruction.t) (inst_b : Instruction.t) =
    let bid_a = fst inst_a in
    let bid_b = fst inst_b in
    if ID.equal bid_a bid_b then (
      (* Same block: check if statement index is smaller (earlier) than the other *)
      match inst_a, inst_b with
      | (_, Instruction.Statement stmt_a), (_, Instruction.Statement stmt_b) ->
          stmt_a.index <= stmt_b.index
      | _ -> true
    )
    else
      block_dominates graph bid_a bid_b

  (* Takes the CFG graph and a current vertex and gives the list of immediately dominating vertices *)
  let get_dominated_vertices (graph : Dom.t) =
    let idom = Dom.compute_idom graph Procedure.Vert.Entry in
    Dom.idom_to_dom_tree graph idom

  let dom_frontier (graph : Dom.t) (vertex : Dom.vertex) : Dom.vertex list = 
    let idom = Dom.compute_idom graph Procedure.Vert.Entry in
    let dom_tree = Dom.idom_to_dom_tree graph idom in 
    Dom.compute_dom_frontier graph dom_tree idom vertex

  let add_phi proc (block_id : ID.t) (var : Var.t) (pred_block_ids : ID.t list) =
    let block_to_add_phi_to = Procedure.find_block proc block_id in
    let new_rhs = List.map (fun pred_id -> (pred_id, var)) pred_block_ids in
    let new_phi : Var.t Block.phi = { lhs = var ; rhs = new_rhs } in
    Procedure.modify_block proc block_id (fun block ->
      Block.map ~phi:(fun phi_list -> new_phi :: phi_list) Fun.id block_to_add_phi_to)

  (* Returns a block. You can use this for Procedure.update_block *)
  let add_copy_instruction proc (block_id : ID.t) (var : Var.t) =
    let block = Procedure.find_block proc block_id in
    let rvar = Expr.BasilExpr.rvar var in
    let new_al = [(var, rvar)] in
    let copy_stmt = [Stmt.Instr_Assign { al = new_al ; attrib = Attrib.empty }] in
    Block.prepend_stmts block copy_stmt
    (*
    You can also do
    let new_proc = modify_block proc block_id (fun block -> 
      let copy_stmt = [Stmt.Instr_assign { al = [(var, Expr.BasilExpr.rvar var)] ; attrib = Attrib.empty }] in
      Block.prepend_stmts block copy_stmt)
    
    But that would require you to have var.
    *)

  (* Returns i_up, i_down, where both are lists of cfg vertices
  i_up is a list of Procedure.Vert.Entry vertices, for blocks that contain multiple predecessor edges
  i_down is a list of Procedure.Vert.End vertices, for both blocks that contian multiple successor edges, and blocks
  that contain var in Block.assigned_vars_iter *)
  let create_range_analysis_splitting_strategy proc (var : Var.t) = 
    let cfg = match Procedure.graph proc with 
        | Some g -> g | None -> Procedure.G.empty
    in
    Procedure.G.fold_vertex (fun (vert : Dom.vertex) (i_up, i_down) -> 
      match vert with
      | Procedure.Vert.Begin block_id ->
        if Procedure.get_blocks_pred proc vert |> List.length |> (>) 1 then
          (vert :: i_up, i_down)
        else
          (i_up, i_down)
      | Procedure.Vert.End block_id ->
        let block = Procedure.find_block proc block_id in
        if (Procedure.get_blocks_succ proc vert |> List.length |> (>) 1) && (Iter.mem var (Block.assigned_vars_iter block)) then
          (i_up, vert :: i_down)
        else
          (i_up, i_down)
      | _ -> (i_up, i_down)

    ) cfg (List.empty, List.empty)

    (* First step of SSI conversion - insertion of phi and sigma nodes *)
    (* TODO: make i_up and i_down list of VERTICES, not list of blocks - make i_up list of begin vertices, i_down list of end vertices *)
    let split variable i_up i_down graph = 
        (* Marks blocks reachable by going backwards *)
        (* Join blocks have phi nodes inserted, else parallel copy *)
        let s_up = [] in
            (* Checks whether a program point is a join node by checking the number of predecessors *)
            let is_join (block : Procedure.Vert.t) =
                if Procedure.get_blocks_pred graph block |> List.length > 1 then true else false in
                    let split_up i = if is_join i then s_up @ (i 
                        |> Procedure.get_blocks_pred graph 
                        |> List.map (dom_frontier graph dom_tree idom)
                        |> List.map (Procedure.get_blocks_pred graph))
                    else s_up @ (dom_frontier graph dom_tree idom i |> List.map (Procedure.get_blocks_pred graph)) in
        List.map split_up i_up
        
        (* Marks blocks reachable by going forwards *)
        (* Branch blocks have sigma nodes inserted, else parallel copy *)
        let s_down = [] in
            let is_branch (block : Procedure.Vert.t) = 
                if Procedure.get_blocks_succ graph block |> List.length > 1 then true else false in
                    let split_down i = if is_branch i then s_down :: (i 
                        |> Procedure.get_blocks_succ graph 
                        |> List.map compute_dom_frontier
                        |> List.map (Procedure.get_blocks_succ graph) 
                        else s_down :: compute_dom_frontier i in 
        List.map split_down (s_up :: defs variable :: i_down) in
        
        (* Traverse marked blocks, insert appropriate instruction *)
        let s = i_up :: i_down :: s_up :: s_down in
        let insert i = 
            let contains_def vert var = 
                match vert with
            | Procedure.G.Vert.Begin succ_id -> Procedure.find_block succ_id |>
                |> Block.assigned_vars_iter 
                |> Iter.to_list 
                |> List.mem var in
            | Procedure.G.Vert.End pred_id -> Procedure.find_block pred_id |> 
                |> Block.assigned_vars_iter 
                |> Iter.to_list 
                |> List.mem var in
            | _ -> () in

        if !contains_def i variable then 
            match i.t with 
        | Procedure.Vert.Begin -> if is_join i then insert_sigma i variable in
        | Procedure.Vert.End -> if is_branch then insert_phi i variable in
        | _ -> insert_copy variable in
        List.map insert s in


    (* Third step - dead and undefined code elimination *)
    let clean variable =
        (* Renamed variables come from rename *)
        let web = VarSet.of_list SSIfy.VariableRenaming.new_renames in
        let defined = [] in
        
        (* Get all instructions from the CFG *)
        let instructions = List.map Block.stmts_iter Procedure.blocks_to_list |> List.flatten in
        (* Filter instructions to get only instructions that define variables in web *)
        (* We get the assigned variables for the instructions, then convert to set, then check if web intersect assigned_vars is empty*)
        let filter_def_instr instr = if VarSet.is_empty (VarSet.inter (Stmt.assigned instr) web) then false else true
        let active_def = List.filter_map (function | Stmt.Instr_Assign attrib al -> Some attrib al | _ -> None ) instructions |> List.filter filter_def_instr |> VarSet.of_list in
        let add_def v' = 
            active_def = VarSet.union active_def SSIfy.VariableRenaming.uses v';
            defined = VarSet.union defined v' in                 

        while !VarSet.is_empty (VarSet.diff active_def defined) do
            List.map add_def 
            (VarSet.to_list 
            (VarSet.diff 
            (VarSet.inter web 
                (List.filter_map 
                    (function | Stmt.Instr_Assign attrib al -> Some attrib al | _ -> None ) instructions )
                    |> List.filter filter_def_instr instructions 
                    |> List.map Stmt.assigned 
                    |> List.flatten 
                    |> VarSet.of_list)))
    
        let used = [] in
        let filter_used_instr instr = 
            if VarSet.is_empty 
                (Stmt.iter_rexpr instr 
                |> Iter.map (function `Expr e -> e | `Var v -> Expr.BasilExpr.rvar v)
                |> List.flatten 
                |> VarSet.of_list 
                |> VarSet.inter web) 
            then false else true

        let active_used = instructions |> List.filter filter_used_instr |> VarSet.of_list in
        let add_used v' =
            active = VarSet.union active_used SSIfy.VariableRenaming.defs v';
            used = VarSet.union used v' in

        while !VarSet.is_empty (VarSet.diff active_used used) do
            List.map add_used 
                VarSet.diff 
                (instructions |> List.map Stmt.iter_rexpr 
                |> Iter.map (function `Expr e -> e | `Var v -> Expr.BasilExpr.rvar v)
                |> List.flatten 
                |> VarSet.of_list 
                |> VarSet.inter web) used |> VarSet.to_list
        
        let live = VarSet.inter defined used in

end


  module VariableRenaming = struct
  
    let create_v' old_v proc =
      let v' = Procedure.fresh_var ~pure:true ~name:(Var.name old_v) proc (Var.typ old_v) in
      new_renames := (v') :: !new_renames;
      Procedure.decl_local proc v'

    (* Returns a procedure that has renamed v *)
    let rename (v: Var.t) proc =
      (* Stack <- new *)
      let stack : Var.t Stack.t = Stack.create() in
      
      (* The control flow graph of the current procedure *)
      let cfg = match Procedure.graph proc with 
        | Some g -> g | None -> Procedure.G.empty
      in

      (* Replaces the old instruction with the new inst' that has updated variables. *)
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
      in

      (* Returns the proc with replaced inst' *)
      let set_def curr_proc (inst : Instruction.t) = 
        (* Let v' be a fresh version of v *)
        let v' = create_v' v curr_proc in

        (* Replace the defs of v by v' in inst *)
        let (inst' : Instruction.t) =
          match inst with
          | (block_id, Instruction.Phi { lhs ; rhs } ) -> 
              (block_id, Instruction.Phi { lhs = if Var.equal lhs v then v' else lhs ; rhs})
          | (block_id, Instruction.Statement { index ; statement = stmt }) ->
              let stmt' = Stmt.map ~f_lvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
                                   ~f_expr:id ~f_rvar:id stmt in
              (block_id, Instruction.Statement { index ; statement = stmt' }) 
        in

        (* Set Def(v') = inst' *)
        defs := DefUseMap.add !defs v' inst';

        (* stack.push(v') *)
        Stack.push v' stack;

        (* Return the updated procedure that contains the updated inst' *)
        let proc' = replace_instruction inst inst' curr_proc
        in
        proc'
      in
      
      let set_use curr_proc (inst : Instruction.t) (og_bid : ID.t) = 
        (* while Def(stack.peek()) does not dominate inst do *)
        let rec pop_while_not_dominating instruction =
          match Stack.top_opt stack with
          | None -> ()
          | Some v' ->
            let v'_def_instructions = DefUseMap.find !defs v' 
            in
            if List.for_all (fun v'_def -> 
                  not (instruction_dominates cfg (v'_def) (instruction))
                ) v'_def_instructions then (
              ignore (Stack.pop stack);
              pop_while_not_dominating instruction
            )
        in

        (* v' <- stack.peek() *)
        let v' = let open Bincaml_util.Unicode in Option.value (Stack.top_opt stack) ~default:(Var.create bot_char (Var.typ v) ~scope:(Var.scope v))
        in

        let expr_transform_alg =
          let open Expr.BasilExpr in 
          rewrite_typed (function
          | RVar { id ; attrib } when Var.equal id v -> Some (rvar ~attrib:attrib v')
          | _ -> None)
        in

        (* Replace the uses of v by v' in inst *)
        let inst' = 
          match inst with
          | (block_id, Instruction.Phi { lhs ; rhs }) ->
            (* Only replace the rhs var that is for the 'current' block
              Remember that set_use is called for the successor the the current block
            *)
            let rhs' = List.map (fun (bid, var) -> if ID.equal og_bid bid && Var.equal var v then (bid, v') else (bid, var)) rhs in
            (block_id, Instruction.Phi { lhs = lhs ; rhs = rhs'})
          | (block_id, Instruction.Statement old_stmt) -> 
            let stmt' = Stmt.map ~f_lvar:id
                                ~f_expr:(expr_transform_alg)
                                ~f_rvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
                                old_stmt.statement 
            in
            (block_id, Instruction.Statement {index = old_stmt.index ; statement = stmt'})
        in
        pop_while_not_dominating inst;
        if String.equal (Var.name v') Bincaml_util.Unicode.bot_char then
          ()
        else
          uses := DefUseMap.add !uses v' inst'
        ;

        let proc' = replace_instruction inst inst' curr_proc in
        proc', inst'
      in

      (* foreach CFG node n in dominance order do *)
      let rec visit_begin_node start_proc (node : Dom.vertex) = 
        let final_proc =
        (* We're only looking at Begin nodes : Skip if not Begin *)
        match node with
        | Procedure.Vert.Begin block_id -> (
          (**
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
          let block = Procedure.find_block start_proc block_id in


          (* If exists Phi node with lhs matching v in In(node) then *)
          (* TODO: See if this should be just an if statement for a single phi instead of a loop. Probably not,
            but I'm not a fan of using fold_left everywhere *)
          let proc_step_one = List.fold_left (fun curr_proc phi ->
            if Var.equal phi.Block.lhs v then let inst = Instruction.create_phi_inst block_id phi.lhs phi.rhs in
            set_def curr_proc inst
          else
            curr_proc
            ) start_proc block.phis in

          (* foreach instruction u in n that uses v do *)
          let proc_step_three = Vector.foldi (fun index curr_proc stmt ->   
            let inst = Instruction.create_stmt_inst block_id index stmt in
            let proc_step_two, updated_inst1 =
              (* An instruction that uses v*)
              if VarSet.mem v (Stmt.free_vars stmt) then
                set_use curr_proc inst block_id
              else
                curr_proc, inst
            in
            (* If exists instruction d in n that defines v then *)
            if Iter.mem v (Stmt.iter_lvar stmt) then
              set_def proc_step_two updated_inst1
            else
              proc_step_two
            ) proc_step_one block.stmts
          in

          let next_vertices = second_successors cfg node in
          let final_proc = List.fold_left (fun curr_proc vert -> 
            match vert with
            | Procedure.Vert.Begin succ_block_id -> 
              let succ_block = Procedure.find_block curr_proc succ_block_id in
              List.fold_left (fun proc' phi ->
                List.fold_left (fun proc'' (ogbid, var) -> 
                  if ID.equal ogbid block_id && Var.equal var v then
                    let inst = Instruction.create_phi_inst succ_block_id phi.Block.lhs phi.Block.rhs in
                    set_use proc' inst ogbid |> fst
                  else
                    proc'') proc' phi.Block.rhs
              ) curr_proc succ_block.phis
            | _ -> curr_proc
            ) proc_step_three next_vertices in
          final_proc
        )
        | _ -> start_proc
        in 
        List.fold_left visit_begin_node final_proc (get_dominated_vertices cfg node)
      in
      visit_begin_node proc Procedure.Vert.Entry
  end

  (* module DeadCodeElim = struct
    let clean variable renamed_vars = 
    let web = renamed_vars in
    let defined = [] in
    
    let instructions = List.map Block.stmts_iter Procedure.blocks_to_list |> List.flatten
    let active = List.filter_map (function | Stmt.Instr_Assign attrib al -> Some attrib al | _ -> None ) active 
                 |> Stmt.iter_lvar |> Iter.to_list |> 
  end *)

  let ssify (v: Var.t) pv =
    let split var splitting_strategy =
      Printf.printf "split"
    in
    let rename var =
      Printf.printf "rename"
    in
    let clean var =
      Printf.printf "clean"
    in
    split v pv; rename v; clean v;
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
  let proc' = SSIfy.VariableRenaming.rename v proc in
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

