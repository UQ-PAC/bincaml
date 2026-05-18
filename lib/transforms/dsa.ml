(** Destructs SSA phi nodes into dynamic single assignment statements, placed
    into newly-created blocks preceding the phi node's location. *)

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

type dsa_block = {
  src : ID.t;  (** ID of the source block for this phi edge. *)
  tgt : ID.t;  (** ID of the target block for this phi edge. *)
  phi_assignments : (Var.t * Var.t) list;
      (** Assignments to be made within this phi edge. *)
}
[@@deriving show]
(** An intermediate value for the information needed to create a DSA block, to
    be placed between two existing block. Within the DSA block, we perform
    assignments which emulate the old phi variables in the [tgt] block. *)

let identify_needed_dsa_blocks (graph : G.t) : dsa_block Iter.t =
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

(** Adds new blocks and edges according to the given {!phi_edge} list, with
    DSA-style assignments performed in the new intermediate block. At the same
    time, removes old direct edges from [src] to [tgt]. *)
let replace_phis_with_dsa_blocks procedure (phis : dsa_block Iter.t) =
  Iter.fold
    (fun procedure { src; tgt; phi_assignments } ->
      let phi_assign =
        Stmt.Instr_Assign
          (phi_assignments
          |> List.map (fun (lhs, rhs) ->
              ( lhs,
                Expr.BasilExpr.fix
                  (RVar { attrib = Attrib.empty; id = rhs; typ = Var.typ rhs })
              )))
      in
      let procedure, intermediate_block =
        Procedure.fresh_block procedure
          ~name:(ID.name tgt ^ "__phi")
          ~stmts:[ phi_assign ] ~successors:[ tgt ] ()
      in
      let procedure =
        Procedure.add_goto ~from:src ~targets:[ intermediate_block ] procedure
      in
      Procedure.modify_succs procedure src ~remove:[ tgt ] ~add:[])
    procedure phis

(** Removes phi nodes from blocks. These are no longer needed after DSA blocks
    are inserted. *)
let remove_phis_from_blocks =
  Procedure.map_graph (fun g ->
      Iter.from_iter (Fun.flip G.iter_edges_e g)
      |> Iter.fold
           (fun g edge ->
             match edge with
             | beg, Procedure.Edge.Block { phis = _ :: _; stmts }, nd ->
                 let g = G.remove_edge_e g edge in
                 G.add_edge_e g
                   (beg, Procedure.Edge.Block { phis = []; stmts }, nd)
             | _ -> g)
           g)

(** Lowers the phi nodes of procedure into {i dynamic single assignment} form.
*)
let dsa (proc : Program.proc) =
  match Procedure.graph proc with
  | Some g ->
      g |> identify_needed_dsa_blocks
      |> replace_phis_with_dsa_blocks proc
      |> remove_phis_from_blocks
  | None -> proc
