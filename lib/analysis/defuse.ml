(** This is a def-use graph for a procedure in ssa form. *)

(** - vertices are assignment statements or phis
    - edges are data dependency 
  
  Due to the statement structure, a vertex can have both multiple incoming
  dependencies and multiple outgoing dependencies; hence the weirdness with
  evaluating vertices and pushing the result down the dependency graph, 
  rather than the usual edge evaluation.

  {4 Performance Considerations }

   This first pass still uses ocamlgraph's ChaoticIteration; this will probably
   evaluate everything at least three times(?), and stores the analysis result
   in a map at each vertex. To reduce the cost of this we use a patricia tree,
   this enforces maximal sharing and O(1) comparisons of the graph but probably
   makes the transfer functions more expensive. [fix] has a solver with a
   better strategy which uses an array and tracks taintedness in a bit-vector,
   but does not support widening. Ideally we want a graph wherein a vertex is a
   single variable, but that makes it harder to phrase the transfer function
   for statements which have multiple outgoing dependencies (procedure calls).

   Ideally performance-wise we want to design a solver like that used by fix
   which (1) uses a single mutable array backing state (2) supports widening
   and (3) possibly encodes dependency with references/points-to rather than a
   map-based graph.

    *)

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

module DefUseGraphAnalysis
    (G :
      Util.Reverse_graph.GraphSig
        with type V.t = Vertex.t
        with type t = UseDef.t)
    (V : Intra_analysis.Lattice)
    (A : Intra_analysis.Transfer with type t = Intra_analysis.MapState(V).t) =
struct
  module StateDomain = Intra_analysis.MapState (V)

  module State = struct
    include StateDomain

    type edge = G.edge

    let analyze_vert (v: Vertex.t) data =
      match v with
      | Vertex.(Phi (lhs, rhs)) ->
          update lhs
            (rhs |> List.fold_left (fun a v -> V.join a (read v data)) V.bottom)
            data
      | Vertex.(Stmt s) -> A.transfer s data
      | _ -> data

    let analyze (edge : G.edge) data =
      (* this gets swapped based on graph direction so is always the logical
         successor 
      *)
      analyze_vert (G.E.dst edge) data
  end

  module Topo = Graph.WeakTopological.Make (G)
  module DuAnalysis = Graph.ChaoticIteration.Make (G) (State)

  let analyse root ?(init = fun v -> State.analyze_vert v (StateDomain.bottom)) ~widen_set ~delay_widen
      p =
    let g = def_use_graph p in
    DuAnalysis.recurse g (Topo.recursive_scc g root) init widen_set delay_widen

  let analyse_graph g root ?(init = fun v -> StateDomain.bottom) ~widen_set
      ~delay_widen p =
    DuAnalysis.recurse g (Topo.recursive_scc g root) init widen_set delay_widen
end

module AnalysisFwd
    (V : Intra_analysis.ValueAbstraction)
    (TRF : Intra_analysis.ForwardStmtTransfer with type t = V.t) =
struct
  module TF = Intra_analysis.StateTransferFwd (V) (TRF)
  include DefUseGraphAnalysis (UseDef) (V) (TF)

  (** providing an incorrect function for init can make the analysis unsound, by default
      it executes the vertex with a bot initial state.

      This is the only time the root vertex (Entry) gets processed; the transfer function of the root 
      vertex (Entry) must not depend on an abstract state.
      *)
  let (analyse :
        ?init:(Vertex.t -> State.t) ->
        widen_set:Vertex.t Graph.ChaoticIteration.widening_set ->
        delay_widen:int ->
        Program.proc ->
        State.t DuAnalysis.M.t) =
    analyse Entry
end

module AnalysisRev
    (V : Intra_analysis.ValueAbstraction)
    (TRF : Intra_analysis.ReverseStmtTransfer with type t = V.t) =
struct
  module TF = Intra_analysis.StateTransferRev (V) (TRF)
  include DefUseGraphAnalysis (Util.Reverse_graph.RevG (UseDef)) (V) (TF)

  (** providing an incorrect function for init can make the analysis unsound, by default
      it executes the vertex with a bot initial state.

      This is the only time the root vertex (Return) gets processed; the transfer function of the root 
      vertex (Return) must not depend on an abstract state.
      *)
  let (analyse :
        ?init:(Vertex.t -> State.t) ->
        widen_set:Vertex.t Graph.ChaoticIteration.widening_set ->
        delay_widen:int ->
        Program.proc ->
        State.t DuAnalysis.M.t) =
    analyse Return
end
