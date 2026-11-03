open struct
  module Module = Gtirb_proto.Module.Gtirb.Proto.Module
end

let usage_msg = "gtirb_graph <gtrib_file>"
let input_files = ref []
let anon_fun filename = input_files := filename :: !input_files

let () =
  Arg.parse [] anon_fun usage_msg;

  let d = Datalog.Default.db_create () in
  let rel = Gtirb_frontend.Gtirb_graph.Graph_types.function_has_name_rel in
  let fact =
    Datalog.AST.(Atom ("hi", [ Const "asdf" ]))
    |> Datalog.Default.literal_of_ast
  in

  let query =
    Datalog.AST.(Atom ("hi", [ Var "hia" ])) |> Datalog.Default.literal_of_ast
  in
  Datalog.Default.db_add_fact d fact;
  let a = Datalog.Default.Query.ask d [| 0 |] [ query ] in
  Datalog.Default.Query.iter a (function [| x |] ->
      Datalog.Default.pp_term Format.std_formatter x);

  match !input_files with
  | [ filename ] ->
      let g = Gtirb_frontend.Gtirb.of_file filename in

      let graph = Gtirb_frontend.Gtirb_graph.Loader.graph_of_gtirb_ir g in
      Gtirb_frontend.Gtirb_graph.Graph_dot.graph := Some graph;
      graph
      |> Gtirb_frontend.Gtirb_graph.Graph_dot.output_graph
           (open_out (filename ^ ".dot"))
  | _ -> invalid_arg "requires exactly one filename argument"
