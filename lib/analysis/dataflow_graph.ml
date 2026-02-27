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

let debug = ref false
let log_debug f = if !debug then print_endline (f ()) else ()

(** {1 Building dataflow graphs for procedures}*)

module Vertex = struct
  (** Vertices in the intraprocedural dataflow graph represent executable
      statements or phi nodes.*)

  type vt =
    | Entry
    | Return
    | Stmt of bool * Program.stmt
    | Phi of { lhs : Var.t; rhs : Var.t list; widen_point : bool }
  [@@deriving ord, eq, show { with_path = false }]

  type t = int * vt [@@deriving ord, eq, show { with_path = false }]
  (** first element of pair used to store the priority *)

  let to_int = fst

  let hash v =
    match v with
    | i, Stmt (_, s) -> Hash.combine3 251 i (Hashtbl.hash s)
    | i, Phi { lhs; rhs } ->
        Hash.combine4 271 i (Var.hash lhs) (Hash.list Var.hash rhs)
    | o -> Hashtbl.hash o

  let defines p = function
    | i, Phi { lhs } -> Iter.singleton lhs
    | i, Stmt (_, (Instr_Assume _ as s)) -> Stmt.free_vars_iter s
    | i, Stmt (_, (Instr_Assert _ as s)) -> Stmt.free_vars_iter s
    | i, Stmt (_, s) -> Stmt.iter_assigned s
    | i, Entry ->
        Iter.append
          (List.to_iter (Procedure.specification p).captures_globs)
          (Procedure.formal_in_params p |> StringMap.values)
    | i, Return -> Iter.empty

  let uses p = function
    | i, Phi { rhs } -> List.to_iter rhs
    | i, Stmt (_, s) -> Stmt.free_vars_iter s
    | i, Entry -> Iter.empty
    | i, Return ->
        Iter.append
          (List.to_iter (Procedure.specification p).modifies_globs)
          (Procedure.formal_out_params p |> StringMap.values)
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

(** Return a persistent iterator of dfgraph vertices for a procedure, first elem
    of pair is the weaktopo index of the block used as a priority. This is using
    control flow topo sort an approximation of the DFG topo sort.

    This is an approximated program representation for abstract semantics which
    assumes phi nodes compute the union of incoming states.

    possible future work: encode the reachability of definitions a la TV paper
    to make phis precise conditionals. *)
let get_dfg_vertices ~(direction : [ `Forwards | `Backwards ]) p :
    Vertex.t Iter.t =
  let block_index = ref 0 in
  let is_header header = match header with `Header -> true | _ -> false in

  let iter =
    match direction with
    | `Forwards -> Procedure.iter_blocks_topo_fwd_headers
    | `Backwards -> Procedure.iter_blocks_topo_rev_headers
  in

  let first =
    Vertex.(
      match direction with `Forwards -> (0, Entry) | `Backwards -> (0, Return))
  in
  let last =
    Vertex.(
      match direction with
      | `Forwards -> (Int.max_int, Return)
      | `Backwards -> (Int.max_int, Entry))
  in

  Block.(
    iter p
    |> Iter.flat_map (fun (id, header, (b : Program.bloc)) ->
        block_index := !block_index + 1;
        let phi_def_use =
          List.to_iter b.phis
          |> Iter.map (function { lhs; rhs } ->
              block_index := !block_index + 1;
              ( !block_index,
                Vertex.Phi
                  {
                    lhs;
                    rhs = List.map snd rhs;
                    widen_point = is_header header;
                    (* apply widening based on wto; may not make sense backwards  *)
                  } ))
        in
        let block_def_use =
          Block.stmts_iter b
          |> Iter.flat_map (function
            | Stmt.Instr_Assign assigns ->
                List.to_iter assigns
                |> Iter.map (fun (lhs, rhs) ->
                    block_index := !block_index + 1;
                    ( !block_index,
                      Vertex.Stmt
                        (is_header header, Stmt.Instr_Assign [ (lhs, rhs) ]) ))
            | stmt ->
                block_index := !block_index + 1;
                Iter.singleton
                  (!block_index, Vertex.Stmt (is_header header, stmt)))
        in
        Iter.append phi_def_use block_def_use))
  |> Iter.append (Iter.of_list [ first; last ])
  |> Iter.persistent

(** Reverses the index on everything *)
let reverse_dfg_vertices_priority def_use =
  let max =
    def_use
    |> Iter.filter (function _, Vertex.Return -> false | _ -> true)
    |> Iter.max ~lt:(fun a b -> match (a, b) with (i, _), (j, _) -> i < j)
    |> Option.map fst |> Option.get_or ~default:0
  in
  let max = max + 1 in
  let def_use =
    Iter.map
      (function
        | _, Vertex.Return -> (0, Vertex.Return) | v, vt -> (max - v, vt))
      def_use
  in
  def_use

(** return the vertex dependency maps {! defuse} for a procedure *)
let def_use_maps ?(require_full_ssa = false) ?def_use p =
  let def_use_vert =
    Option.get_or ~default:(get_dfg_vertices ~direction:`Forwards p) def_use
  in
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

module SimpleSolver = struct
  module WL = Worklist.Make (Vertex)

  let deps ~assume_ssi (dir : [ `Backwards | `Forwards ]) p lookup v =
    (* this is hacky to support ssi without proper sigma nodes in the IR; we should add them to block 
       type probably *)
    let all_deps =
      let defines (v : Vertex.t) =
        match v with
        | (_, Stmt (_, Instr_Assert _) | _, Stmt (_, Instr_Assume _))
          when not assume_ssi ->
            Iter.empty
        | _ -> Vertex.defines p v
      in

      match (v, dir) with
      | _, `Forwards ->
          defines v
          |> Iter.filter (Var.is_global %> not)
             (* don't add globals as not subject to ssa form *)
          |> Iter.flat_map (fun v -> MDeps.find_iter lookup.var_to_use v)
          (* get every statement that is dependent on the defined *)
      | _, `Backwards ->
          Vertex.uses p v
          |> Iter.filter (Var.is_global %> not)
             (* don't add globals as not subject to ssa form *)
          |> Iter.flat_map (fun v -> MDeps.find_iter lookup.var_to_def v)
      (* get every statement that defines the variable used *)
    in
    let is_assert =
      Vertex.(
        function
        | i, Stmt (_, Instr_Assert _) | i, Stmt (_, Instr_Assume _) -> true
        | _ -> false)
    in
    match v with
    | (i, _) as s when is_assert s ->
        (* only include lower-priority (lexically later) assertions/or assumes : attempt break cycles *)
        Iter.filter (fun nv -> not @@ (is_assert nv && fst nv >= i)) all_deps
    | _ -> all_deps

  type vm = (Vertex.t, Int.t) Hashtbl.t

  let fixpoint_proc ?(widen_threshold = 50)
      (module WL : Worklist.IFace with type elt = Vertex.t) transfer initial p
      deps (def_use : Vertex.t Iter.t) =
    let lookup = def_use_maps ~def_use p in
    let worklist = WL.create () in
    (* we need to add all as not everything is a successor of entry; *)
    WL.add_iter worklist def_use;

    let visited = Hashtbl.create (Iter.length def_use) in

    let need_widen v =
      match v with
      | _, Vertex.Phi { widen_point = true }
      | _, Vertex.Stmt (true, Stmt.Instr_Assume _)
      | _, Vertex.Stmt (true, Stmt.Instr_Assert _) ->
          let vl = Hashtbl.find_opt visited v |> Option.get_or ~default:0 in
          Hashtbl.replace visited v (vl + 1);
          vl + 1 > widen_threshold
      | _ -> false
    in

    let state = ref initial in
    while WL.non_empty worklist do
      let s = WL.pop worklist in
      let widen = need_widen s in
      let state' = transfer ~widen !state s in
      log_debug (fun () -> Vertex.show s);
      match state' with
      | Some st ->
          state := st;
          let d = deps p lookup s in
          log_debug (fun () -> "next: " ^ Iter.to_string Vertex.show d);
          WL.add_iter worklist d
      | None -> ()
    done;
    log_debug (fun () ->
        Hashtbl.to_iter visited
        |> Iter.to_string ~sep:"\n" (function k, v ->
            Int.to_string v ^ " " ^ Vertex.show k));
    !state

  let fixpoint_fwd ~transfer ~initial ?(assume_ssi = true) ?widen_threshold p =
    let def_use = get_dfg_vertices ~direction:`Forwards p in
    fixpoint_proc
      (module WL)
      transfer initial ?widen_threshold p
      (deps ~assume_ssi `Forwards)
      def_use

  let fixpoint_rev ~transfer ~initial ?(assume_ssi = true) ?widen_threshold p =
    let def_use = get_dfg_vertices ~direction:`Backwards p in
    fixpoint_proc
      (module WL)
      transfer initial p
      (deps ~assume_ssi `Backwards)
      ?widen_threshold def_use
end

(** Return a {! DFGraph.t} representing the dataflow. Vertices are phi nodes or
    program statements, edges are directed from definitions to their uses. *)
let create p =
  let make_graph () =
    let def_use_vert = get_dfg_vertices ~direction:`Forwards p in
    let to_use, to_def =
      def_use_maps ~def_use:def_use_vert p |> function
      | { var_to_use; var_to_def } -> (var_to_use, var_to_def)
    in
    let def_use_vert = def_use_vert in
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
    let graph = def_use_vert |> Iter.fold add_vert DFGraph.empty in
    (* topological order only visits vertices dominated by the root, hence this
     hack to get it to include
     constant assignments *)
    let graph =
      def_use_vert
      |> Iter.fold
           (fun g v ->
             if Iter.is_empty (Vertex.uses p v) then
               DFGBuilder.add_edge g (0, Vertex.Entry) v
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
      | i, Entry -> "e"
      | i, Return -> "r"
      | i, Stmt _ -> "stmt" ^ Int.to_string @@ Vertex.hash v
      | i, Phi _ -> "phi" ^ Int.to_string @@ Vertex.hash v)

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
  include Lattice_types.StateDomain with type t := t with type key_t = Var.t
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

      (** Analysis function specificatlly for the flow insensitive fixed point,
          hence incorporates joins etc. *)
      let analyze_vert_intra ~widen data (v : Vertex.t) =
        let r =
          match snd v with
          | Vertex.(Phi { lhs; rhs }) ->
              let join = if widen then V.widening else V.join in
              let olhs = D.read lhs data in
              let nlhs =
                rhs
                |> List.fold_left
                     (fun a v -> V.join a (D.read v data))
                     D.V.bottom
              in
              let v = join olhs nlhs in
              if not (D.V.equal olhs v) then Some (update lhs v data) else None
          | Vertex.(Stmt (_, stmt)) ->
              let read v = D.read v data in
              let s' =
                D.transfer_state read stmt
                |> Iter.filter_map (fun (v, s) ->
                    let vv = read v in
                    let s = if widen then V.widening vv s else s in
                    if V.equal vv s then None else Some (v, s))
              in
              if Iter.is_empty s' then None
              else (
                log_debug (fun () ->
                    Iter.to_string
                      (function k, vvv -> Var.to_string k ^ "->" ^ V.show vvv)
                      s');
                Some (s' |> Iter.fold (fun acc (k, v) -> update k v acc) data))
          | Entry -> None
          | Return -> None
        in
        r

      let analyze_vert (v : Vertex.t) data =
        Option.get_or ~default:data (analyze_vert_intra ~widen:false data v)

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

  val flow_insensitive : Program.proc -> D.t
end

(** Backwards dataflow analysis over DFG *)
module AnalysisRev (D : DFAnalysis) = struct
  module D = D
  module A = DataflowAnalysis (Bincaml_util.Reverse_graph.RevG (DFGraph)) (D)

  (** Construct run dataflow analysis over a {!DFGraph.t}. *)
  let analyse ~widen_set ~delay_widen (g : graph) : D.t =
    A.DFGChaoticIter.M.find_opt (0, Entry)
    @@ A.analyse (0, Return)
         ~init:(D.init (fst g))
         ~widen_set ~delay_widen
         (Lazy.force (snd g))
    |> Option.get_exn_or "entry not reachable from return"

  let flow_insensitive p =
    SimpleSolver.fixpoint_rev ~initial:(D.init p)
      ~transfer:A.Domain.analyze_vert_intra p
end

(** Forwards dataflow analysis over dfg *)
module AnalysisFwd (AD : DFAnalysis) = struct
  (*module TF = Intra_analysis.StateTransferFwd (V) (TRF)*)
  module A = DataflowAnalysis (DFGraph) (AD)
  module D = AD

  type t = D.t

  (** Construct run dataflow analysis over a {!DFGraph.t}. *)
  let analyse ~widen_set ~delay_widen g : AD.t =
    A.DFGChaoticIter.M.find_opt (Int.max_int, Return)
      (A.analyse (0, Entry)
         ~init:(AD.init (fst g))
         ~widen_set ~delay_widen
         (Lazy.force (snd g)))
    |> Option.get_exn_or "error: return not reachable from entry"

  let flow_insensitive p =
    SimpleSolver.fixpoint_fwd ~initial:(AD.init p)
      ~transfer:A.Domain.analyze_vert_intra p
end

(** Simple way to get started with forwards analysis on def-use graph *)
module EasyForwardAnalysisPack (V : sig
  include Lattice_types.TypedValueAbstraction with module E = Expr.BasilExpr

  val top : t
end) =
struct
  module SV = Intra_analysis.MapState (V)
  module Eval = Intra_analysis.EvalStmt (V)

  module Domain = struct
    let top_val = V.top

    include SV

    let init p =
      let vs = Lang.Procedure.formal_in_params p |> StringMap.values in
      vs
      |> Iter.map (fun v -> (v, top_val))
      |> Iter.fold (fun m (v, d) -> SV.update v d m) SV.bottom

    let transfer_state read stmt =
      let stmt = Eval.stmt_eval_fwd read stmt in
      match stmt with
      | Lang.Stmt.Instr_Assign ls -> List.to_iter ls
      | Lang.Stmt.Instr_Assert _ -> Iter.empty
      | Lang.Stmt.Instr_Assume _ -> Iter.empty
      | Lang.Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
          Iter.singleton (lhs, rhs)
      | Lang.Stmt.Instr_Store { lhs; value; addr = Scalar } ->
          Iter.singleton (lhs, value)
      | Lang.Stmt.Instr_Load { lhs } -> Iter.singleton (lhs, top_val)
      | Lang.Stmt.Instr_Store { lhs } -> Iter.singleton (lhs, top_val)
      | Lang.Stmt.Instr_IntrinCall { lhs } ->
          StringMap.values lhs |> Iter.map (fun v -> (v, top_val))
      | Lang.Stmt.Instr_Call { lhs } ->
          StringMap.values lhs |> Iter.map (fun v -> (v, top_val))
      | Lang.Stmt.Instr_IndirectCall _ -> Iter.empty
  end

  module Analysis = AnalysisFwd (Domain)

  let analyse (p : Lang.Program.proc) =
    let g = create p in
    Analysis.analyse ~widen_set:Graph.ChaoticIteration.FromWto ~delay_widen:0 g
end
