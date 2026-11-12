open struct
  module DSGraph = Dsgraph
  module NodeFlags = Node_flags
end

open Bincaml_util.Common

(** {1 Ocamlgraph-compatible representation of DSGraph} *)

module Dsgraph_ocamlgraph = struct
  type t = {
    proc_id : ID.t option;
    graph : DSGraph.t;
    sym_bases_in_nodes : Sva.SymBase.t list IDMap.t;
  }

  let of_dsgraph ?proc_id graph =
    { proc_id; graph; sym_bases_in_nodes = DSGraph.sym_bases_in_nodes graph }

  module V = struct
    type t = DSGraph.cell
  end

  module E = struct
    type t = DSGraph.cell * DSGraph.cell

    let src = fst
    let dst = snd
  end

  let iter_vertex k { graph } =
    DSGraph.distinct_nodes graph
    |> List.to_iter
    |> Iter.flat_map_l DSGraph.cells
    |> Iter.iter k

  let iter_edges_e k gr =
    Fun.flip iter_vertex gr
    |> Iter.flat_map (fun src ->
        match !src with
        | DSGraph.Cell { pointees } ->
            pointees |> List.to_iter |> Iter.map (fun dst -> (src, dst))
        | _ -> failwith "non-terminal cell")
    |> Iter.iter k
end

(** {1 Printing parts of the nodes} *)

let show_cell_interval (cell : DSGraph.cell) =
  let interval = DSGraph.offsets cell in
  let wd =
    match interval with
    | Interval (lo, hi) -> Z.(to_string (hi - lo + ~$1))
    | _ -> "?"
  in
  Printf.sprintf "%s:%sB" (Interval.show interval) wd

(** Shows a minimal node header ({i without} symbolic bases or contained cell
    intervals). *)
let show_node (node : DSGraph.node) =
  Printf.sprintf "node%d %s"
    (ID.index (DSGraph.node_id node))
    (NodeFlags.show (DSGraph.flags node))

let show_sym_bases =
  CCCache.with_cache (CCCache.lru ~eq:CCEqual.physical 1000)
  @@ fun (bases : Sva.SymBase.t list) ->
  List.to_iter bases |> Iter.map Sva.SymBase.show |> Iter.intersperse ", "
  |> Iter.concat_str

(** {1 Ocamlgraph Dot instantiation} *)

module type Dot_sig = sig
  open Graph.Graphviz

  type t

  module V : sig
    type t
  end

  module E : sig
    type t
  end

  val iter_vertex : (V.t -> unit) -> t -> unit
  val iter_edges_e : (E.t -> unit) -> t -> unit
  val graph_attributes : t -> DotAttributes.graph list
  val default_vertex_attributes : t -> DotAttributes.vertex list
  val vertex_name : V.t -> string
  val vertex_attributes : V.t -> DotAttributes.vertex list
  val get_subgraph : V.t -> DotAttributes.subgraph option
  val default_edge_attributes : t -> DotAttributes.edge list
  val edge_attributes : E.t -> DotAttributes.edge list
end

module Automatic_vertex_ids
    (X : Dot_sig)
    (Compare : sig
      val equal_vertex : X.V.t -> X.V.t -> bool
      val hash_vertex : X.V.t -> int
      val equal_edge : X.E.t -> X.E.t -> bool
      val hash_edge : X.E.t -> int
    end) =
struct

  open Compare

  let vertex_name =
let n = int
    CCCache.with_cache (CCCache.unbounded ~eq:equal_vertex ~hash:hash_vertex 100) @@
    fun v ->



end

module Dsgraph_ocamlgraph_dot = struct
  include Dsgraph_ocamlgraph

  let graph_attributes g = []
  let default_vertex_attributes g = []
  let vertex_name = show_cell_interval
  let vertex_attributes _ = []
  let get_subgraph _ = None
  let default_edge_attributes _ = []
  let edge_attributes _ = []
end

include Graph.Graphviz.Dot (Dsgraph_ocamlgraph_dot)

let dot_string g =
  let b = Buffer.create 10 in
  let fmt = Format.formatter_of_buffer b in
  fprint_graph fmt (Dsgraph_ocamlgraph.of_dsgraph g);
  Format.pp_print_flush fmt ();
  Buffer.to_bytes b |> Bytes.unsafe_to_string
