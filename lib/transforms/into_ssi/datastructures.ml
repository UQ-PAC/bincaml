open Bincaml_util.Common
open Lang
open Lang.Common
open Containers

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

  let create_phi_inst block_id lhs rhs = Block_Inst (block_id, Phi { lhs; rhs })

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
module RevDom = Graph.Dominator.Make_graph (Procedure.RevG)

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
    Procedure.fold_blocks_topo_fwd (fun (uses, defs) bid block -> let phi_uses,
    phi_defs = List.fold_left (fun (use', def') phi -> let inst =
    Instruction.create_phi_inst bid phi.Block.lhs phi.Block.rhs in let pu = if
    Iter.mem v (Instruction.var_uses inst) then InstructionSet.add inst use'
    else use' in let pd = if Iter.mem v (Instruction.var_defines inst) then
    InstructionSet.add inst def' else def' in (pu, pd)) (uses, defs) block.phis
    in let stmt_uses, stmt_defs = Vector.foldi (fun index (use', def') stmt ->
    let inst = Instruction.create_stmt_inst bid index stmt in let su = if
    Iter.mem v (Instruction.var_uses inst) then InstructionSet.add inst use'
    else use' in let sd = if Iter.mem v (Instruction.var_defines inst) then
    InstructionSet.add inst def' else def' in (su, sd)) (uses, defs) block.stmts
    in ( InstructionSet.union phi_uses stmt_uses, InstructionSet.union phi_defs
    stmt_defs )) (InstructionSet.empty, InstructionSet.empty) proc in let uses =
    if StringMap.mem (Var.name v) (Procedure.formal_out_params proc) then
    InstructionSet.add (Instruction.create_in_inst proc) uses else uses in let
    defs = if StringMap.mem (Var.name v) (Procedure.formal_in_params proc) then
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
let add_phi proc (block_id : ID.t) (var : Var.t) (pred_block_ids : ID.t list) =
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

(** Adds a parallel copy of the variable var to the block with block_id in proc.
    Returns the new proc and the parallel copy instruction *)
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
        "Impossible - the type between old and new instruction was different, \
         or tried to change the in and out parameters"
(* Shouldn't occur *)
