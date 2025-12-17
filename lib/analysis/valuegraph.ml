(** This is a def-use graph for a procedure in ssa form. *)

(** - vertices are assignment statements or phis
    - edges are data dependency *)

open Lang
open Lang.Common

module Vertex = struct
  type t = Stmt of Program.stmt | Phi of Var.t * Var.t list
  [@@deriving ord, eq]

  let hash v =
    match v with
    | Stmt s -> Hash.combine2 251 (Hashtbl.hash s)
    | Phi (l, r) -> Hash.combine2 271 (Hash.list Var.hash r)
end

module G = Graph.Persistent.Digraph.ConcreteBidirectional (Vertex)
module B = Graph.Builder.P (G)
module MDeps = CCMultiMap.Make (Var) (Vertex)

type defuse = { var_to_use : MDeps.t; var_to_def : MDeps.t }

let vert_defines =
  Vertex.(
    function
    | Phi (lhs, _) -> Iter.singleton lhs
    | Stmt s -> Stmt.iter_assigned s)

let vert_uses =
  Vertex.(
    function
    | Phi (_, rhs) -> List.to_iter rhs
    | Stmt s -> Stmt.free_vars_iter s)

let def_use_vert p =
  Block.(
    Procedure.iter_blocks_topo_fwd p
    |> Iter.flat_map (fun (id, (b : Program.bloc)) ->
        let phi_def_use =
          List.to_iter b.phis
          |> Iter.map (function { lhs; rhs } ->
              Vertex.Phi (lhs, List.map snd rhs))
        in
        let block_def_use =
          Block.stmts_iter b |> Iter.map (fun stmt -> Vertex.Stmt stmt)
        in
        Iter.append phi_def_use block_def_use))
  |> Iter.persistent

let def_use_maps ?(require_full_ssa = false) ?def_use p =
  let def_use_vert = Option.get_or ~default:(def_use_vert p) def_use in
  let to_def =
    def_use_vert
    |> Iter.flat_map (fun v -> vert_defines v |> Iter.map (fun s -> (s, v)))
    |> MDeps.of_iter
  in
  if require_full_ssa then
    (* we let memory appear in the value graph with havoc semantics so allow
       skipping this assertion *)
    assert (
      MDeps.keys to_def
      |> Iter.map (MDeps.count to_def)
      |> Iter.for_all (fun i -> i <= 1));
  let to_use =
    def_use_vert
    |> Iter.flat_map (fun v -> vert_uses v |> Iter.map (fun s -> (s, v)))
    |> MDeps.of_iter
  in
  { var_to_use = to_use; var_to_def = to_def }

let def_use_graph p =
  let def_use_vert = def_use_vert p in
  let to_use, to_def =
    def_use_maps ~def_use:def_use_vert p |> function
    | { var_to_use; var_to_def } -> (var_to_use, var_to_def)
  in
  let add_vert graph vert =
    let graph = B.add_vertex graph vert in
    let graph =
      vert_defines vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_use v)
      |> Iter.fold (fun g use -> B.add_edge g vert use) graph
    in
    (* I feel like it shouldn't be neccessary to add the edge in both
       directions, it would probably only occur due to bugs? *)
    let graph =
      vert_uses vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_def v)
      |> Iter.fold (fun g def -> B.add_edge g def vert) graph
    in
    graph
  in
  def_use_vert |> Iter.fold add_vert G.empty
