(** Pretty-printing of the graph to Dot format. *)

include Dependencies.Graph.Graphviz.Dot (struct
  include Graph.Internal

  let edge_attributes _ = [ `Label "hi" ]
  let default_edge_attributes _ = []
  let get_subgraph _ = None
  let default_vertex_attributes _ = []
  let graph_attributes _ = []
  let vertex_name = Types.show_vert
  let vertex_attributes v = [ `Fontname "Mono" ]
end)
