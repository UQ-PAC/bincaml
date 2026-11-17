(** Pretty-printing of the graph to Dot format. *)

open Graph.Graphviz.DotAttributes

let sanitise =
  String.map (function
    | c when CCChar.is_letter_ascii c || CCChar.is_digit_ascii c -> c
    | _ -> '_')

let quote = Printf.sprintf {|%S|}
let escape = String.escaped

(** Module parameter type of {!Graph.Graphviz.Dot}. *)
module type DotSig = sig
  open Graph.Graphviz

  type t

  module V : sig
    type t
  end

  module E : sig
    type t

    val src : t -> V.t
    val dst : t -> V.t
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

(** Default implementations for some {!Graph.Graphviz.Dot} parameter functions,
    returning empty for various DOT attributes. *)
module DotDefaults = struct
  let graph_attributes = []
  let default_vertex_attributes _ = []
  let default_edge_attributes _ = []
  let vertex_attributes _ = []
  let get_subgraph _ = None
  let edge_attributes _ = []
end

(** A module for {!Graph.Graphviz.Dot} where the graph itself is available
    alongside the vertices and edges.

    This allows for the vertex and edge rendering functions to inspect other
    parts of the graph. *)
module DotGraphWithSelf (G : DotSig) :
  DotSig with type V.t = G.V.t * G.t and type E.t = G.E.t * G.t and type t = G.t =
struct
  type t = G.t

  module V = struct
    type nonrec t = G.V.t * G.t
  end

  module E = struct
    type nonrec t = G.E.t * G.t

    let src (x, extra) = (G.E.src x, extra)
    let dst (x, extra) = (G.E.dst x, extra)
  end

  let iter_vertex k gr = G.iter_vertex (fun x -> k (x, gr)) gr
  let iter_edges_e k gr = G.iter_edges_e (fun x -> k (x, gr)) gr
  let graph_attributes = G.graph_attributes
  let default_vertex_attributes = G.default_vertex_attributes
  let default_edge_attributes = G.default_edge_attributes
  let vertex_name (x, _) = G.vertex_name x
  let vertex_attributes (x, _) = G.vertex_attributes x
  let get_subgraph (x, _) = G.get_subgraph x
  let edge_attributes (x, _) = G.edge_attributes x
end

include Graph.Graphviz.Dot (struct
  include DotGraphWithSelf (struct
    include Graph_internal
    include DotDefaults

    let edge_attributes (_, edge, _) =
      [ `Label (escape (Graph_types.show_relation edge)) ]

    let graph_attributes _ = [ `Rankdir `LeftToRight ]
    let vertex_name v = quote (Graph_types.show_vert v)
    let vertex_attributes v = [ `Fontname "Mono"; `Label "" ]
  end)

  let get_subgraph (v, g) =
    match
      Graph_query.function_of_block g v
      |> Option.map (Graph_query.function_name g)
      |> Option.map (Graph_query.self_data g)
    with
    | Some (Symbol_data { name }) ->
        Some
          {
            sg_name = sanitise name;
            sg_attributes = [ `Label name; `Fontsize 16 ];
            sg_parent = None;
          }
    | _ | (exception _) -> None
end)
