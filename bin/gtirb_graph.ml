open struct
  module Module = Gtirb_proto.Module.Gtirb.Proto.Module
end

let usage_msg = "gtirb_graph <gtrib_file>"
let input_files = ref []
let anon_fun filename = input_files := filename :: !input_files

let () =
  Arg.parse [] anon_fun usage_msg;

  match !input_files with
  | [ filename ] ->
      let g = Gtirb_frontend.Gtirb.of_file filename in

      Gtirb_frontend.Gtirb_graph.Graph_dot.output_graph
        (open_out (filename ^ ".dot"))
        (Gtirb_frontend.Gtirb_graph.Loader.graph_of_module (List.hd g.modules))
  | _ -> invalid_arg "requires exactly one filename argument"
