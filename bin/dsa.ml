let usage_msg = "dsa.exe <IL_FILE>"
let input_files = ref []
let keep_procs = ref [ "@main" ]
let append_keep_procs x = keep_procs := x :: !keep_procs
let graph_proc = ref "@main"
let anon_fun filename = input_files := filename :: !input_files
let dump_il = ref false

let () =
  Arg.parse
    [
      ("-p", Arg.String append_keep_procs, "Procedure names to keep");
      ("-g", Arg.Set_string graph_proc, "Select graph to dump");
      ("--il", Arg.Set dump_il, "Dump pre-DSA IL instead");
    ]
    anon_fun usage_msg;

  Logs.set_reporter (Logs.format_reporter ());

  match !input_files with
  | [ filename ] ->
      let prog = (Loader.Loadir.ast_of_fname filename).prog in
      let proc = Lang.Program.get_proc_by_name (List.hd !keep_procs) prog in
      let mainid = Lang.Procedure.id proc in
      let prog = Lang.Program.set_entry_proc mainid prog in

      let prog =
        Lang.Program.declarations prog
        |> Iter.fold
             (fun prog (id, decl) ->
               if not (List.mem (Bincaml_util.ID.name id) !keep_procs) then
                 Lang.Program.remove_decl prog decl
               else prog)
             prog
      in
      let prog =
        Bincaml.Passes.PassManager.(run_transform prog aslp_semantics)
      in
      let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
      let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in
      Logs.(set_level (Some Debug));
      if !dump_il then Lang.Program.pretty_to_chan stdout prog
      else begin
        let dsgraph = Analysis.Dsa.dsa prog in
        let _, g =
          Bincaml_util.Common.IDMap.find
            (Lang.Program.get_id_by_name !graph_proc prog)
            dsgraph
        in
        print_endline @@ Analysis.Dsa.dot_string g
      end
  | _ -> invalid_arg "requires exactly one filename argument"
