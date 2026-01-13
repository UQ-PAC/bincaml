(** Intraprocedural dataflow analyses on a SSA-form dataflow graph (similar to a
    def-use graph)*)

(** - vertices are assignment statements or phis
    - edges are data dependency (directed from dependency to dependee)

    Due to the statement structure, a vertex can have both multiple incoming
    dependencies and multiple outgoing dependencies; hence the weirdness with
    evaluating vertices and pushing the result down the dependency graph, rather
    than the usual edge evaluation.

    {4 Performance Considerations}

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
    map-based graph. *)

open Lang
open Lang.Common

(** {1 Building dataflow graphs for procedures}*)
open struct
  let dbg_print f = ()
end

module Vertex = struct
  (** Vertices in the intraprocedural dataflow graph represent executable
      statements or phi nodes.*)

  type t = Entry | Return | Stmt of Program.stmt | Phi of Var.t * Var.t list
  [@@deriving ord, eq, show { with_path = false }]

  let hash v =
    match v with
    | Stmt s -> Hash.combine2 251 (Hashtbl.hash s)
    | Phi (l, r) -> Hash.combine2 271 (Hash.list Var.hash r)
    | o -> Hashtbl.hash o

  let defines p = function
    | Phi (lhs, _) -> Iter.singleton lhs
    | Stmt s -> Stmt.iter_assigned s
    | Entry -> Procedure.formal_in_params p |> StringMap.values
    | Return -> Iter.empty

  let uses p = function
    | Phi (_, rhs) -> List.to_iter rhs
    | Stmt s -> Stmt.free_vars_iter s
    | Entry -> Iter.empty
    | Return -> Procedure.formal_out_params p |> StringMap.values
end

module DFGraph = Graph.Persistent.Digraph.ConcreteBidirectional (Vertex)
(** Ocamlgraph dataflow graph *)

open struct
  module DFGBuilder = Graph.Builder.P (DFGraph)
  (** Ocamlgraph builder for dfgraph *)
end

module MDeps = CCMultiMap.Make (Var) (Vertex)

type defuse = { var_to_use : MDeps.t; var_to_def : MDeps.t }
(** Dataflow graph as maps from variables to the verices which use or define
    them resp.*)

(** Return a persistent iterator of dfgraph vertices for a procedure.

    This is an approximated program representation for abstract semantics which
    assumes phi nodes compute the union of incoming states.

    possible future work: encode the reachability of definitions a la TV paper
    to make phis precise conditionals. *)
let get_dfg_vertices p =
  Block.(
    Procedure.iter_blocks_topo_fwd p
    |> Iter.flat_map (fun (id, (b : Program.bloc)) ->
        let phi_def_use =
          List.to_iter b.phis
          |> Iter.map (function { lhs; rhs } ->
              Vertex.Phi (lhs, List.map snd rhs))
        in
        let block_def_use =
          Block.stmts_iter b
          |> Iter.flat_map (function
            | Stmt.Instr_Assign assigns ->
                List.to_iter assigns
                |> Iter.map (fun (lhs, rhs) ->
                    Vertex.Stmt (Stmt.Instr_Assign [ (lhs, rhs) ]))
            | stmt -> Iter.singleton @@ Vertex.Stmt stmt)
        in
        Iter.append phi_def_use block_def_use))
  |> Iter.persistent

(** return the vertex dependency maps {! defuse} for a procedure *)
let def_use_maps ?(require_full_ssa = false) ?def_use p =
  let def_use_vert = Option.get_or ~default:(get_dfg_vertices p) def_use in
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

(** Return a {! DFGraph.t} representing the dataflow. Vertices are phi nodes or
    program statements, edges are directed from definitions to their uses. *)
let create p =
  let make_graph () =
    let def_use_vert = get_dfg_vertices p in
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
    let def_use_vert =
      Iter.append def_use_vert (Iter.of_list [ Vertex.Entry; Vertex.Return ])
    in
    let graph = def_use_vert |> Iter.fold add_vert DFGraph.empty in
    (* topological order only visits vertices dominated by the root, hence this
     hack to get it to include
     constant assignments *)
    let graph =
      def_use_vert
      |> Iter.fold
           (fun g v ->
             if Iter.is_empty (Vertex.uses p v) then
               DFGBuilder.add_edge g Vertex.Entry v
             else g)
           graph
    in
    graph
  in
  (p, lazy (make_graph ()))

type graph

open struct
  type graph = Program.proc * DFGraph.t lazy_t
end

module DFGDotPrinter = Graph.Graphviz.Dot (struct
  include DFGraph

  let default_vertex_attributes v = []
  let graph_attributes g = []

  let vertex_name v =
    Vertex.(
      match v with
      | Entry -> "e"
      | Return -> "r"
      | Stmt _ -> "stmt" ^ Int.to_string @@ Vertex.hash v
      | Phi _ -> "phi" ^ Int.to_string @@ Vertex.hash v)

  let get_subgraph v = None
  let default_edge_attributes e = []
  let edge_attributes e = []

  let vertex_attributes v =
    let n = Vertex.show v in
    [ `Shape `Box; `Fontname "Mono"; `Label n ]
end)

(** {1 Value-analysis of dataflow graphs}*)

(** Type of a dataflow analysis domain: this needs at minimum a view of variable
    state, lattice order, and transfer function *)
module type DFAnalysis = sig
  include Lattice_types.StateAbstraction with type key_t = Var.t
  include Lattice_types.Domain with type t := t
end

open struct
  (** Dataflow analysis that is parametric in analysis direction, via functor
      argument {! G} which may present either a forwards or backwards view of
      the graph. *)
  module DataflowAnalysis
      (G :
        Bincaml_util.Reverse_graph.GraphSig
          with type V.t = Vertex.t
          with type t = DFGraph.t)
      (D : DFAnalysis) =
  struct
    module Domain = struct
      include D

      type edge = G.edge

      let analyze_vert (v : Vertex.t) data =
        dbg_print (D.show data);
        dbg_print ("eval " ^ Vertex.show v);
        let r =
          match v with
          | Vertex.(Phi (lhs, rhs)) ->
              D.update lhs
                (rhs
                |> List.fold_left
                     (fun a v -> D.V.join a (D.read v data))
                     D.V.bottom)
                data
          | Vertex.(Stmt s) -> D.transfer data s
          | _ -> data
        in
        dbg_print @@ D.show r;
        r

      let analyze (edge : G.edge) data =
        (* this gets swapped based on graph direction so is always the logical
         predecessor (dataflow dependency)
      *)
        analyze_vert (G.E.src edge) data
    end

    module Topo = Graph.WeakTopological.Make (G)
    module DFGChaoticIter = Graph.ChaoticIteration.Make (G) (Domain)

    (** Run a dataflow analysis over it, returning a single abstract state
        relating all program variables to an abstract value.

        If dataflow graph [g] is not provided, compute the dfg for an SSA-form
        procedure *)
    let analyse root ~init ~widen_set ~delay_widen g =
      let scc = Topo.recursive_scc g root in
      let f_init v = init in
      DFGChaoticIter.recurse g scc f_init widen_set delay_widen
  end
end

module type AnalysisType = sig
  module D : DFAnalysis

  val analyse :
    widen_set:Vertex.t Graph.ChaoticIteration.widening_set ->
    delay_widen:int ->
    graph ->
    D.t
  (** Construct run dataflow analysis over a {!DFGraph.t}. *)
end

(** Backwards dataflow analysis over DFG *)
module AnalysisRev (D : DFAnalysis) = struct
  module D = D
  module A = DataflowAnalysis (Bincaml_util.Reverse_graph.RevG (DFGraph)) (D)

  (** Construct run dataflow analysis over a {!DFGraph.t}. *)
  let analyse ~widen_set ~delay_widen (g : graph) : D.t =
    A.DFGChaoticIter.M.find_opt Entry
    @@ A.analyse Return
         ~init:(D.init (fst g))
         ~widen_set ~delay_widen
         (Lazy.force (snd g))
    |> Option.get_exn_or "entry not reachable from return"
end

(** Forwards dataflow analysis over dfg *)
module AnalysisFwd (AD : DFAnalysis) = struct
  (*module TF = Intra_analysis.StateTransferFwd (V) (TRF)*)
  module A = DataflowAnalysis (DFGraph) (AD)
  module D = AD

  type t = D.t

  (** Construct run dataflow analysis over a {!DFGraph.t}. *)
  let analyse ~widen_set ~delay_widen g : AD.t =
    A.DFGChaoticIter.M.find_opt Return
      (A.analyse Entry
         ~init:(AD.init (fst g))
         ~widen_set ~delay_widen
         (Lazy.force (snd g)))
    |> Option.get_exn_or "error: return not reachable from entry"
end
