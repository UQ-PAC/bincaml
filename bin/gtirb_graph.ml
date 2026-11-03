open struct
  module Module = Gtirb_proto.Module.Gtirb.Proto.Module
end

let usage_msg = "gtirb_graph <gtrib_file>"
let input_files = ref []
let anon_fun filename = input_files := filename :: !input_files

let () =
  Arg.parse [] anon_fun usage_msg;

  let d = Datalog_caml_interface.Logic.DB.create () in
  let rel = Gtirb_frontend.Gtirb_graph.Graph_types.function_has_name_rel in
  let fact =
    Datalog_caml_interface.Rel2.make rel
      (Gtirb_frontend.UUID.of_string "a")
      (Gtirb_frontend.UUID.of_string "a")
  in
  Datalog_caml_interface.Logic.DB.add_fact d fact;
  Datalog_caml_interface.Logic.(
    ask ~oc:true d
      (Datalog_caml_interface.Rel2.apply rel (T.mk_var 0) (T.mk_var 0)))
  |> List.iter (fun x ->
      Datalog_caml_interface.Logic.T.fmt Format.std_formatter x);

  match !input_files with
  | [ filename ] ->
      let g = Gtirb_frontend.Gtirb.of_file filename in

      let graph = Gtirb_frontend.Gtirb_graph.Loader.graph_of_gtirb_ir g in
      Gtirb_frontend.Gtirb_graph.Graph_dot.graph := Some graph;
      graph
      |> Gtirb_frontend.Gtirb_graph.Graph_dot.output_graph
           (open_out (filename ^ ".dot"))
  | _ -> invalid_arg "requires exactly one filename argument"
