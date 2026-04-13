(** Destructs SSA phi nodes into assignments, placed into newly-created blocks
    preceding the phi node's location. *)

open Lang.Common
open Lang
open Containers
module G = Procedure.G

(** [phis_from_src src phis] filters the given phi list to only the variable
    assignments applicable when entering the phi block from [src].

    The returned list is a list of tuples of [(src_variable, tgt_variable)]. *)
let phis_from_src src =
  List.filter_map (fun (phi : 'var Block.phi) ->
      match List.assoc_opt ~eq:ID.equal src phi.rhs with
      | Some rhs -> Some (phi.lhs, rhs)
      | None -> None)

type phi_edge = {
  src : ID.t;  (** ID of the source block for this phi edge. *)
  tgt : ID.t;  (** ID of the target block for this phi edge. *)
  phi_assignments : (Var.t * Var.t) list;
      (** Assignments to be made within this phi edge. *)
}
(** An intermediate value for the information needed to create a "phi edge"
    between two blocks. A phi edge is made up of two jumps with a new block of
    assignments in the middle:
    {v src -> phi_assignments -> tgt v} *)

let identify_needed_phi_edges (graph : G.t) : phi_edge Iter.t =
  let block_of_id : ID.t -> (Var.t, Expr.BasilExpr.t) Block.t =
    let cache = CCCache.lru ~eq:ID.equal ~hash:ID.hash 128 in
    CCCache.with_cache cache @@ fun id ->
    let _, e, _ = G.find_edge graph (Begin id) (End id) in
    match e with Block b -> b | Jump -> raise Not_found
  in

  Iter.from_iter (Fun.flip G.iter_edges_e graph)
  |> Iter.filter_map (function
    | Procedure.Vert.End src, Procedure.Edge.Jump, Procedure.Vert.Begin tgt -> (
        match block_of_id tgt with
        | { phis = []; stmts } -> None
        | { phis; stmts } ->
            Some { src; tgt; phi_assignments = phis_from_src src phis })
    | _ -> None)

let add_phi_edges procedure (phis : phi_edge Iter.t) =
  phis
  |> Iter.fold
       (fun graph { src; tgt; phi_assignments } ->
         let stmt =
           Stmt.Instr_Assign
             (phi_assignments
             |> List.map (fun (lhs, rhs) ->
                 (lhs, Expr.BasilExpr.E (RVar { attrib = None; id = rhs }))))
         in
         (* TODO: propagate assumes? *)
         (* TODO: alternatively, do we just use some kind of conditional inside the target block?????? *)
         let procedure, intermediate_block =
           Procedure.fresh_block procedure
             ~name:(ID.name tgt ^ "phis")
             ~stmts:[ stmt ] ~successors:[ tgt ] ()
         in
         Procedure.add_goto ~from:src ~targets:[ tgt ] procedure)
       procedure

let remove_phis_from_blocks =
  Procedure.map_graph (fun g ->
      Iter.from_iter (Fun.flip G.iter_edges_e g)
      |> Iter.fold
           (fun g edge ->
             match edge with
             | src, Procedure.Edge.Block { phis = _ :: _; stmts }, tgt ->
                 let g = G.remove_edge_e g edge in
                 G.add_edge_e g
                   (src, Procedure.Edge.Block { phis = []; stmts }, tgt)
             | _ -> g)
           g)

let dsa (proc : Program.proc) =
  match Procedure.graph proc with
  | Some g ->
      identify_needed_phi_edges g
      |> add_phi_edges proc |> remove_phis_from_blocks
  | None -> proc
