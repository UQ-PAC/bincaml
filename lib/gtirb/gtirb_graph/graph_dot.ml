(** Pretty-printing of the graph to Dot format. *)

open Graph.Graphviz.DotAttributes

let sanitise =
  String.map (function
    | c when CCChar.is_letter_ascii c || CCChar.is_digit_ascii c -> c
    | _ -> '_')

let quote = Printf.sprintf {|%S|}
let escape = String.escaped
let graph = ref None

include Graph.Graphviz.Dot (struct
  let edge_attributes (_, edge, _) =
    [ `Label (escape (Graph_types.show_relation edge)) ]

  let default_edge_attributes _ = []

  let get_subgraph v =
    match !graph with
    | None -> None
    | Some g -> (
        match
          Graph_query.function_of_block g v
          |> Option.map (Graph_query.function_name g)
          |> Option.map (Graph_query.self_data g)
        with
        | Some (Symbol_data { name }) ->
            Some
              { sg_name = sanitise name; sg_attributes = []; sg_parent = None }
        | _ | (exception _) -> None)

  let default_vertex_attributes _ = []
  let graph_attributes _ = []
  let vertex_name v = quote (Graph_types.show_vert v)
  let vertex_attributes v = [ `Fontname "Mono" ]

  include Graph_internal
end)
