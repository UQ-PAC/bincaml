open struct
  module DSGraph = Dsgraph
  module NodeFlags = Node_flags
end

open Bincaml_util.Common

(** {1 Helper functions} *)

let sanitise =
  String.map (function
    | '-' -> 'm'
    | c when CCChar.is_letter_ascii c || CCChar.is_digit_ascii c -> c
    | _ -> '_')

let quote = Printf.sprintf {|%S|}
let escape = String.escaped

(** {1 Ocamlgraph-compatible representation of DSGraph} *)

module Dsgraph_ocamlgraph = struct
  type extra = {
    prefix : string option;
    sym_bases_in_nodes : Sva.SymBase.t list IDMap.t;
  }
  (** Extra information which is passed alongside each vertex and edge to use
      when generating DOT attributes. *)

  type t = DSGraph.t * extra

  let of_dsgraph ?proc_id graph =
    let prefix = Option.map ID.show proc_id
    and sym_bases_in_nodes = DSGraph.sym_bases_in_nodes graph in
    (graph, { prefix; sym_bases_in_nodes })

  module V = struct
    type t = DSGraph.cell * extra
  end

  module E = struct
    type t = DSGraph.cell * DSGraph.cell * extra

    let src (a, _, ex) = (a, ex)
    let dst (_, a, ex) = (a, ex)
  end

  let iter_vertex k (gr, extra) =
    DSGraph.distinct_nodes gr |> List.to_iter
    |> Iter.flat_map_l DSGraph.cells
    |> Iter.map (fun v -> (v, extra))
    |> Iter.iter k

  let iter_edges_e k gr =
    Fun.flip iter_vertex gr
    |> Iter.flat_map (fun (src, extra) ->
        match !src with
        | DSGraph.Cell { pointees } ->
            pointees |> List.to_iter |> Iter.map (fun dst -> (src, dst, extra))
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

let show_sym_bases (bases : Sva.SymBase.t list) =
  List.to_iter bases |> Iter.map Sva.SymBase.show

(** {1 Ocamlgraph Dot instantiation} *)

module Dsgraph_ocamlgraph_dot = struct
  include Dsgraph_ocamlgraph

  (** Returns the [(node_idx, cell_idx)] of the given vertex. The cell index is
      used to reference the field number in the DOT graph. *)
  let vertex_indices cell =
    let cell = DSGraph.find_cell cell in
    let parent_node = DSGraph.node_of cell in
    let node_index = ID.index (DSGraph.node_id parent_node)
    and cell_index =
      DSGraph.cells parent_node |> List.map DSGraph.find_cell
      |> List.find_index (CCEqual.physical cell)
      |> Option.get_exn_or "cell not in its own parent?!"
    in
    (node_index, cell_index)

  (** When using record nodes, by default, the Dot emitter will repeat the node
      declaration for each field in the record, and the entire field list is
      repeated at each declaration.

      To avoid that repetition, this is a {b hack} that filters the
      {!Dsgraph_ocamlgraph.iter_vertex} to only return the first cell of each
      record node. *)
  let iter_vertex k gr =
    Fun.flip iter_vertex gr
    |> Iter.filter (fun (v, _) -> 0 = snd (vertex_indices v))
    |> Iter.iter k

  let graph_attributes g = [ `Rankdir `LeftToRight ]
  let default_vertex_attributes g = []

  (** Vertex "name" must be unique in a particular DOT file. Our graph's
      "vertices" are cells, so this includes the record field number. *)
  let vertex_name (cell, _) =
    let node, cell = vertex_indices cell in
    Printf.sprintf "node%d:%d" node cell

  let vertex_attributes (cell, { sym_bases_in_nodes }) =
    let parent_node = DSGraph.node_of cell in
    let parent_str = show_node parent_node in

    let sym_base_strs =
      IDMap.find_opt (DSGraph.node_id parent_node) sym_bases_in_nodes
      |> Option.map_or ~default:Iter.empty show_sym_bases
      |> Iter.intersperse "\\n"
    in

    let cell_strs =
      DSGraph.cells parent_node |> Iter.of_list
      |> Iter.map show_cell_interval
      |> Iter.zip_i
      |> Iter.map (fun (i, s) -> [ "<"; string_of_int i; ">"; s ])
      |> Iter.intersperse [ "|" ] |> Iter.flat_map_l Fun.id
    in

    let parts =
      Iter.append_l
        [
          Iter.doubleton parent_str "\\n";
          sym_base_strs;
          Iter.doubleton "|" "{";
          cell_strs;
          Iter.singleton "}";
        ]
    in
    [ `Label (Iter.concat_str parts); `Shape `Record ]

  let get_subgraph _ = None
  let default_edge_attributes _ = []
  let edge_attributes _ = []
end

include Graph.Graphviz.Dot (Dsgraph_ocamlgraph_dot)

let dot_string g =
  let b = Buffer.create 10 in
  let fmt = Format.formatter_of_buffer b in
  Format.pp_set_margin fmt Format.pp_infinity;
  fprint_graph fmt (Dsgraph_ocamlgraph.of_dsgraph g);
  Format.pp_print_flush fmt ();
  Buffer.to_bytes b |> Bytes.unsafe_to_string
