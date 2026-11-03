open struct
  module Module = Gtirb_proto.Module.Gtirb.Proto.Module
end

let usage_msg = "gtirb_graph <gtrib_file>"
let input_files = ref []
let anon_fun filename = input_files := filename :: !input_files

let () =
  Arg.parse [] anon_fun usage_msg;

  let lexbuf =
    Lexing.from_string
      {|
      hi(A) :- src(A).
      src(boop).
      src(asddf_A).
|}
  in
  let clauses = Datalog.Parser.parse_file Datalog.Lexer.token lexbuf in

  let d = Datalog.Default.db_create () in
  let query =
    Datalog.AST.(Atom ("hi", [ Var "hia" ])) |> Datalog.Default.literal_of_ast
  in
  clauses
  |> List.map Datalog.Default.clause_of_ast
  |> List.iter (Datalog.Default.db_add d);
  print_endline "matches:";
  let a =
    Datalog.Default.db_match d query (fun x ->
        Datalog.Default.pp_literal Format.std_formatter x)
  in
  Format.print_flush ();
  print_endline "\nclauses:";
  Datalog.Default.db_fold
    (fun () -> Format.printf "%a\n" Datalog.Default.pp_clause)
    () d;

  match !input_files with
  | [ filename ] ->
      let g = Gtirb_frontend.Gtirb.of_file filename in

      let graph = Gtirb_frontend.Gtirb_graph.Loader.graph_of_gtirb_ir g in
      Gtirb_frontend.Gtirb_graph.Graph_dot.graph := Some graph;
      graph
      |> Gtirb_frontend.Gtirb_graph.Graph_dot.output_graph
           (open_out (filename ^ ".dot"))
  | _ -> invalid_arg "requires exactly one filename argument"
