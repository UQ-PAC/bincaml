(** Intraprocedural dataflow analyses on a SSA-form dataflow graph (similar to a def-use graph)*)

(** 

  - vertices are assignment statements or phis
  - edges are data dependency  (directed from dependency to dependee)
  
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


(** {1 Building dataflow graphs for procedures }*)

module Vertex = struct
  (** Vertices in the intraprocedural dataflow graph represent executable statements or phi nodes.*)


  type t = Entry | Return | Stmt of Program.stmt | Phi of Var.t * Var.t list
  [@@deriving ord, eq]

  let hash v =
    match v with
    | Stmt s -> Hash.combine2 251 (Hashtbl.hash s)
    | Phi (l, r) -> Hash.combine2 271 (Hash.list Var.hash r)
    | o -> Hashtbl.hash o

let defines p =
    function
    | Phi (lhs, _) -> Iter.singleton lhs
    | Stmt s -> Stmt.iter_assigned s
    | Entry -> Procedure.formal_in_params p |> StringMap.values
    | Return -> Iter.empty

let uses p =
    function
    | Phi (_, rhs) -> List.to_iter rhs
    | Stmt s -> Stmt.free_vars_iter s
    | Entry -> Iter.empty
    | Return -> Procedure.formal_in_params p |> StringMap.values

end

(** Ocamlgraph dataflow graph *)
module DFGraph = Graph.Persistent.Digraph.ConcreteBidirectional (Vertex)

(** Ocamlgraph builder for dfgraph *)
module DFGBuilder = Graph.Builder.P (DFGraph)

module MDeps = CCMultiMap.Make (Var) (Vertex)

(** Dataflow graph as maps from variables to the verices which use or define
    them resp.*)
type defuse = { var_to_use : MDeps.t; var_to_def : MDeps.t }

(** Return a persistent iterator of dfgraph vertices for a procedure.

    This is an approximated program representation for abstract semantics which
    assumes phi nodes compute the union of incoming states.

    possible future work: encode the reachability of definitions a la TV paper
    to make phis precise conditionals.
  *)
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

(** return the vertex dependency maps {! defuse} for a procedure *)
let def_use_maps ?(require_full_ssa = false) ?def_use p =
  let def_use_vert = Option.get_or ~default:(def_use_vert p) def_use in
  let to_def =
    def_use_vert
    |> Iter.flat_map (fun v -> Vertex.defines p v |> Iter.map (fun s -> (s, v)))
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
    |> Iter.flat_map (fun v -> Vertex.uses p v |> Iter.map (fun s -> (s, v)))
    |> MDeps.of_iter
  in
  { var_to_use = to_use; var_to_def = to_def }

(** Return a {! DFGraph.t} representing the dataflow.
    Vertices are phi nodes or program statements, edges are directed
    from definitions to their uses. *)
let create p =
  let def_use_vert = def_use_vert p in
  let to_use, to_def =
    def_use_maps ~def_use:def_use_vert p |> function
    | { var_to_use; var_to_def } -> (var_to_use, var_to_def)
  in
  let add_vert graph vert =
    let graph = DFGBuilder.add_vertex graph vert in
    let graph =
      Vertex.defines p vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_use v)
      |> Iter.fold (fun g use -> DFGBuilder.add_edge g vert use) graph
    in
    (* I feel like it shouldn't be neccessary to add the edge in both
       directions, it would probably only occur due to bugs? *)
    let graph =
      Vertex.uses p vert
      |> Iter.flat_map (fun v -> MDeps.find_iter to_def v)
      |> Iter.fold (fun g def -> DFGBuilder.add_edge g def vert) graph
    in
    graph
  in
  def_use_vert |> Iter.fold add_vert DFGraph.empty

(** {1 Value-analysis of dataflow graphs }*)

open struct 

(** Dataflow analysis that is parametric in analysis direction, via functor argument {G}
    which may present either a forwards or backwards view of the graph. *)
module DataflowAnalysis
    (G :
      Bincaml_util.Reverse_graph.GraphSig
        with type V.t = Vertex.t
        with type t = DFGraph.t)
    (V : Intra_analysis.Lattice)
    (A : Intra_analysis.Transfer with type t = Intra_analysis.MapState(V).t) =
struct
  module StateDomain = struct 
    include Intra_analysis.MapState (V)

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
         successor (dataflow dependee)
      *)
      analyze_vert (G.E.dst edge) data
  end

  module Topo = Graph.WeakTopological.Make (G)
  module DFGChaoticIter = Graph.ChaoticIteration.Make (G) (StateDomain)

  (** compute def-use graph for an SSA-form procedure 
      and run a dataflow analysis over it, returning a single abstract state
      relating all program variables to an abstract value. *)
  let analyse root ?(init = fun v -> StateDomain.analyze_vert v (StateDomain.bottom)) ~widen_set ~delay_widen
      (p: [ `DFG of DFGraph.t | `Proc of Program.proc ]) =
    let g = match p with `Proc p -> create p | `DFG g -> g in
    DFGChaoticIter.recurse g (Topo.recursive_scc g root) init widen_set delay_widen

end
end

(** forwards dataflow analysis over dfg *)
module AnalysisFwd
    (V : Intra_analysis.ValueAbstraction)
    (TRF : Intra_analysis.ForwardStmtTransfer with type t = V.t) =
struct
  module TF = Intra_analysis.StateTransferFwd (V) (TRF)
  module A = DataflowAnalysis(DFGraph) (V) (TF)

  (** 
      Construct DFGraph and run dataflow analysis.

      providing an incorrect function for init can make the analysis unsound, by default
      it executes the vertex with a bot initial state.

      This is the only time the root vertex (Entry) gets processed; the transfer function of the root 
      vertex ([Entry]) must not depend on an abstract state.
      *)
  let (analyse :
        ?init:(Vertex.t -> A.StateDomain.t) ->
        widen_set:Vertex.t Graph.ChaoticIteration.widening_set ->
        delay_widen:int ->
        [ `DFG of DFGraph.t | `Proc of Program.proc ]
    ->
        A.StateDomain.t A.DFGChaoticIter.M.t) =
    A.analyse Entry
end

(** Backwards dataflow analysis over DFG *)
module AnalysisRev
    (V : Intra_analysis.ValueAbstraction)
    (TRF : Intra_analysis.ReverseStmtTransfer with type t = V.t) =
struct
  module TF = Intra_analysis.StateTransferRev (V) (TRF)
  module A = DataflowAnalysis(Bincaml_util.Reverse_graph.RevG (DFGraph)) (V) (TF)

  (** 
      Construct DFGraph and run dataflow analysis.

      Providing an incorrect function for init can make the analysis unsound, by default
      it executes the vertex with a bot initial state.

      This is the only time the root vertex ([Return]) gets processed; the transfer function of the root 
      vertex ([Return]) must not depend on an abstract state.
      *)
  let (analyse :
        ?init:(Vertex.t -> A.StateDomain.t) ->
        widen_set:Vertex.t Graph.ChaoticIteration.widening_set ->
        delay_widen:int ->
        [ `DFG of DFGraph.t | `Proc of Program.proc ]
    ->
        A.StateDomain.t A.DFGChaoticIter.M.t) =
    A.analyse Return
end
