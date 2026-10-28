(** Pretty-printing of the graph to Dot format. *)

include Dependencies.Graph.Graphviz.Dot (struct
  include Graph_internal

  let edge_attributes (_, edge, _) = [ `Label (Graph_types.show_relation edge) ]
  let default_edge_attributes _ = []
  let get_subgraph _ = None
  let default_vertex_attributes _ = []
  let graph_attributes _ = []
  let vertex_name v = "\"" ^ String.escaped (Graph_types.show_vert v) ^ "\""
  let vertex_attributes v = [ `Fontname "Mono" ]
end)
