(** Pretty-printing of the graph to Dot format. *)

let escape = Printf.sprintf {|%S|}

let pp_to_string pp x =
  let b = Buffer.create 10 in
  let fmt = Format.formatter_of_buffer b in
  Format.pp_set_margin fmt Format.pp_infinity;
  pp fmt x;
  Format.pp_print_flush fmt ();
  Buffer.to_bytes b |> Bytes.unsafe_to_string

include Graph.Graphviz.Dot (struct
  include Graph_internal

  let edge_attributes (_, edge, _) =
    [ `Label (String.escaped (pp_to_string Graph_types.pp_relation edge)) ]

  let default_edge_attributes _ = []
  let get_subgraph _ = None
  let default_vertex_attributes _ = []
  let graph_attributes _ = []
  let vertex_name v = escape (Graph_types.show_vert v)
  let vertex_attributes v = [ `Fontname "Mono" ]
end)
