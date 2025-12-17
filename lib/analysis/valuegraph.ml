(** This is a def-use graph for a procedure in ssa form. *)

(** - vertices are assignment statements or phis
    - edges are data dependency *)

open Lang
open Lang.Common

module Vertex = struct
  type t = Entry | Return | Stmt of Program.stmt | Phi of Var.t * Var.t list
  [@@deriving ord, eq]

  let hash v =
    match v with
    | Stmt s -> Hash.combine2 251 (Hashtbl.hash s)
    | Phi (l, r) -> Hash.combine2 271 (Hash.list Var.hash r)
    | o -> Hashtbl.hash o
end

module UseDef = Graph.Persistent.Digraph.ConcreteBidirectional (Vertex)
module B = Graph.Builder.P (UseDef)
module MDeps = CCMultiMap.Make (Var) (Vertex)

type defuse = { var_to_use : MDeps.t; var_to_def : MDeps.t }

let vert_defines p =
  Vertex.(
    function
    | Phi (lhs, _) -> Iter.singleton lhs
    | Stmt s -> Stmt.iter_assigned s
    | Entry -> Procedure.formal_in_params p |> StringMap.values
    | Return -> Iter.empty)

let vert_uses p =
  Vertex.(
    function
    | Phi (_, rhs) -> List.to_iter rhs
    | Stmt s -> Stmt.free_vars_iter s
    | Entry -> Iter.empty
    | Return -> Procedure.formal_in_params p |> StringMap.values)

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
    |> Iter.flat_map (fun v -> vert_defines p v |> Iter.map (fun s -> (s, v)))
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
    |> Iter.flat_map (fun v -> vert_uses p v |> Iter.map (fun s -> (s, v)))
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
      vert_defines p vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_use v)
      |> Iter.fold (fun g use -> B.add_edge g vert use) graph
    in
    (* I feel like it shouldn't be neccessary to add the edge in both
       directions, it would probably only occur due to bugs? *)
    let graph =
      vert_uses p vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_def v)
      |> Iter.fold (fun g def -> B.add_edge g def vert) graph
    in
    graph
  in
  def_use_vert |> Iter.fold add_vert UseDef.empty

module M = PatriciaTree.MakeMap (Var)

module Analysis
    (V : Intra_analysis.ValDomain)
    (A : sig
      type edge = UseDef.edge

      val analyse : Program.stmt -> 'a -> 'a
    end) =
struct
  module type Edge = module type of UseDef.E

  module StateDomain = Intra_analysis.MapState (V)

  module State (E : Edge) = struct
    include StateDomain
    include A

    let analyze edge data =
      let v = E.dst edge in
      match v with
      | Vertex.(Phi (lhs, rhs)) ->
          update lhs
            (rhs |> List.fold_left (fun a v -> V.join a (read v data)) V.bottom)
            data
      | Vertex.(Stmt s) -> A.analyse s data
      | _ -> data
  end

  module Fwd = UseDef
  module Rev = Bincaml_util.Reverse_graph.RevG (UseDef)
  module RevTop = Graph.WeakTopological.Make (Rev)
  module FwdTop = Graph.WeakTopological.Make (UseDef)
  module FwdAnalysis = Graph.ChaoticIteration.Make (Fwd) (State (Fwd.E))
  module RevAnalysis = Graph.ChaoticIteration.Make (Rev) (State (Rev.E))

  let analyse_proc_fwd p =
    let g = def_use_graph p in
    FwdAnalysis.recurse g (FwdTop.recursive_scc g Entry)
end
