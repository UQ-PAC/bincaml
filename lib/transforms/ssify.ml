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

type t = 
  | Bottom
  | Var of Var.t


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


module Aaa = Graph.Dominator.Make

module SSIfy = struct 

  (* Represents the instruction, i.e. Phi or Statement *)
  module Instruction = struct

    type it =
      | Phi of Var.t Block.phi
      | Statement of { index:int ; statement:Program.stmt }
    [@@deriving ord, eq, show { with_path = false }]
    
    (* ID.t will be the ID of the block *)
    type t = ID.t * it [@@deriving ord, eq, show { with_path = false }]

    let defines = function
      | Phi { lhs ; rhs } -> Iter.singleton lhs
      (* | Statement { index ; statement = (Instr_Assume _) as s} -> Stmt.free_vars_iter s
      | Statement { index ; statement = (Instr_Assert _) as s} -> Stmt.free_vars_iter s *)
      | Statement { index ; statement} -> Stmt.iter_assigned statement

    let uses = function
      | Phi { rhs } -> List.to_iter rhs |> Iter.map snd
      | Statement { statement } -> Stmt.free_vars_iter statement
  end

  (* Procedure.G.compute_dom_front *)

  (* Map from Var to (BlockID, Instruction) *)
  module DefUseMap = CCMultiMap.Make (Var) (Instruction)

  module VariableRenaming = struct

  (* 'Global' def and use maps *)
  let defs : DefUseMap.t ref = ref DefUseMap.empty
  let uses : DefUseMap.t ref = ref DefUseMap.empty

  (* List of tuples, where tuples are (old_v, new_v) *)
  (* TODO: This is a placeholder, there is definitely a better structure for this *)
  let new_renames : (Var.t * Var.t) list ref = ref []

  let create_v' old_v proc =
    (let v' = Procedure.fresh_var ~pure:true ~name:(Var.name old_v) proc (Var.typ old_v) in
    new_renames := (old_v, v') :: !new_renames;
    v') 


  module Dom = Graph.Dominator.Make (Procedure.G)

  (* Returns a procedure that has renamed v *)
  let rename2 (v: Var.t) proc =
    let stack : Var.t Stack.t = Stack.create() in
    let cfg = Procedure.graph in

    (* Returns the proc with replaced inst' *)
    let set_def (inst : Instruction.t) = 
      (* Let v' be a fresh version of v *)
      let v' = create_v' v proc in

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
      Stack.push v' stack;

      (* Return the updated procedure that contains the updated inst' *)
      let proc' =
        match inst, inst' with
        | (block_id, Instruction.Phi old_phi),
          (_, Instruction.Phi new_phi) ->
            Procedure.modify_block proc block_id (fun block ->
              Block.map ~phi:(List.map (fun phi ->
                      if Block.equal_phi Var.equal old_phi phi then new_phi else phi
                      )) Fun.id block
            )
        | (block_id, Instruction.Statement old_stmt),
          (_, Instruction.Statement new_stmt) -> 
            Procedure.modify_block proc block_id (fun block ->
              Block.map ~phi:Fun.id 
            (* TODO: See if we can compare statement indexes as well. I don't think it's possible with Block.map. 
              Maybe use Block.fmap_stmts_copy*)
            (fun stmt -> 
              if Stmt.equal Var.equal Var.equal Expr.BasilExpr.equal (old_stmt.statement) stmt then 
                new_stmt.statement else stmt) block)
        | _ -> proc (* Shouldn't occur *)
      in
      proc'
    

    in
    Printf.printf "NAM"


  let rename (v: Var.t) proc =
    let nam = Procedure.graph proc in
    let proc_graph = create proc |> snd |> Lazy.force in
    let defusemap = def_use_maps proc in
    let defs = ref defusemap.var_to_def in
    let uses = ref defusemap.var_to_use in
    let stack : Var.t Stack.t = Stack.create () in
    let nodes = get_dfg_vertices ~direction:`Forwards proc in

    (* let defs = ref VarMap.empty in *)

    let new_renames = ref [] in

    let create_v' old_v = 
      let v' = Procedure.fresh_var ~pure:true ~name:(Var.name old_v) proc (Var.typ old_v) in
      new_renames := (old_v, v') :: !new_renames;
      v'
    in

    (* TODO: See if we need to also use add_vertex and add_edge, etc to proc_graph *)
    let set_def (inst : Vertex.t) =
      let v' = create_v' v in

      (* How to replace v by v' in inst statically and set Def(v') = inst ???? *)
      let inst' =
        match inst with 
        | (priority, Vertex.Stmt (b, stmt)) -> 
            let stmt' = Stmt.map ~f_lvar:(fun oldv -> if Var.equal oldv v then v' else oldv) 
                                 ~f_expr:id ~f_rvar:id stmt in
            (priority, Vertex.Stmt (b, stmt'))
        | (priority, Vertex.Phi {lhs ; rhs ; widen_point }) ->
            (priority, Vertex.Phi {lhs = if Var.equal lhs v then v' else lhs ; rhs ; widen_point})
        | vertex -> vertex
      in
      (* Not sure how to do line 3 - replace lhs_vars in-place without mapping over Program to create a new one*)
      defs := MDeps.add !defs v' inst'; (* Adds v' -> inst' to the defs table. I don't think this does it globally... *)
      Stack.push v' stack;
    in

    let set_use (inst : Vertex.t) =
      (* Vertex dominates other vertex if it's priority (first value) is smaller *)
      (* while (MDeps.find !defs (Stack.top stack) |> List.hd |> fst) >= (fst inst) do *)
      let rec pop_while_not_dominating inst =
        match Stack.top_opt stack with
        | None -> ()
        | Some var ->
          if List.for_all (fun x -> fst x < fst inst) (MDeps.find !defs var) then
            (
              ignore (Stack.pop stack);
              pop_while_not_dominating inst
            )
      in 
      
      (* v' <- stack.peek *)
      (* Figure out how to make this (0, Vertex.Entry) *)
      let v' = let open Bincaml_util.Unicode in Option.value (Stack.top_opt stack) ~default:(Var.create bot_char (Var.typ v) ~scope:(Var.scope v))
      in

      let expr_transform_alg =
        let open Expr.BasilExpr in
        rewrite_typed (function
          | RVar { id ; attrib } when Var.equal id v -> (
            Some (rvar ~attrib:attrib v')
          )
          | _ -> None
        )
      in
      
      (* Replace the uses of v by v' in inst *)
      let inst' =
        match inst with
        | (priority, Vertex.Stmt (b, stmt)) ->
            let stmt' = Stmt.map ~f_lvar:id 
                                 ~f_expr:(expr_transform_alg) 
                                 ~f_rvar:(fun oldv -> if Var.equal oldv v then v' else oldv)
                                 stmt in
            (priority, Vertex.Stmt (b, stmt'))
        | (priority, Vertex.Phi { lhs ; rhs ; widen_point}) ->
            (priority, Vertex.Phi { lhs = lhs ;
                                   rhs = List.map (fun var -> if Var.equal var v then v' else var) rhs ;
                                   widen_point})
        | x -> x
        in
      
      pop_while_not_dominating inst;
      (* if v' != Bot then add inst to Uses(v') *)
        (* Assuming that MDeps.add automatically does union *)
      if String.equal (Var.name v') "Bottom" then () else uses := MDeps.add !uses v' inst'
    in

    (* Neiher Vertex.t Iter.t nor DFGraph iterate on nodes, they both iterate on vertices... *)
    Iter.iter (fun (node: Vertex.t) -> 
      let in_n = DFGraph.pred proc_graph node in
      let out_n = DFGraph.succ proc_graph node in
      (* Problem is that these are supposed to be points after the instructions, but this
      gets the instructions after the instruction*)

      (* If inst is a phi node containing v in In(n) then *)
      (match node with
      | (_, Vertex.Phi { lhs ; rhs ; widen_point }) when List.mem node in_n -> 
          if Var.equal lhs v then set_def node
      | _ -> ())
      ;

      (* For each instr u in n that uses v do set_use(u)
      Right now nodes are actually a single vertex, so can't really do a loop..
      TODO: Find out what nodes are represented as
      *)
      (
        match node with
                                                      (* Maybe use iter_rexpr instead? *)
        | (_, Vertex.Stmt (_, stmt)) when VarSet.mem v (Stmt.free_vars stmt) -> 
          set_use node
        | _ -> ()
      )
      ;

      (* If exists instruction d in n that defines v (lvar) then *)
      (
        match node with 
        | (_, Vertex.Stmt (_, stmt)) when Iter.exists (fun x -> Var.equal x v) (Stmt.iter_lvar stmt) ->
          set_def node
        | _ -> ()
      )
      ;

      (* Might not need to do sigma node checking *)

      (* Right now, out_n is the same as direct-successors(n) i think *)
      (* I think that nodes need to be blocks instead of vertices, since this might not work currently... *)

      (* foreach m in direct-successors(n) do *)
      List.iter (fun m -> 
        let in_m = DFGraph.pred proc_graph m in
        List.iter (fun m_node ->
          match m_node with 
            | (_, Vertex.Phi {lhs ; rhs ; widen_point}) when List.mem ~eq:(Var.equal) v rhs ->
                set_use m_node
            | _ -> ()
          ) in_m
        ) out_n
    )
      
    nodes

            end


  (* Procedure.fresh_var ~pure:true ~name:(Var.name v) (Var.typ v) *) (* Maybe ~name:((Var.name v) ^ (string_of_int incrementer)) ?*)
  (* Vertex.t represents the program points *)
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

let%expect_test "test3_basic_call_phi" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main [
      (var v:bv64) := call @OX();
      goto(%main_1, %main_2);
    ];

    block %main_1 [
      guard(bvsmod(i, 2:bv64));
      var tmp:bv64 := bvadd(i, 1:bv64);
      var v:bv64 := bvadd(v, 69);
      goto(%main_return);
    ];

    block %main_2 [
      guard(boolnot(bvsmod(i, 2:bv64)));
      (var v:bv64) := call @OY();
      var v:bv64 := bvadd(v, 420);
      goto(%main_return);
    ];

    block %main_return
    (
      var v:bv64 := phi(%main_1 -> v:bv64, %main_2 -> v:bv64)
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
  Program.pretty_to_chan stdout program;
  [%expect
    {| 
    |}]