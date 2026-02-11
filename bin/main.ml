open Bincaml_util.Common
open Lang
open Cmdliner
open Cmdliner.Term.Syntax

let () = Printexc.record_backtrace true

let fname =
  let doc = "Input file name (filename.il)" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FNAME" ~doc)

let proc =
  let doc = "proc to output" and docv = "PROC" in
  Arg.(value & opt string "" & info [ "p"; "proc" ] ~doc ~docv)

let print_proc chan p = Program.output_proc_pretty chan p

let list_procs fname =
  let p = Loader.Loadir.ast_of_fname fname in
  let procs prog =
    let open Program in
    ID.Map.iter (fun i _ -> Printf.printf "%s\n" (ID.show i)) prog.procs
  in
  procs p.prog;
  Ok ()

let procs_cmd =
  let doc = "list program print procedures " in
  let info = Cmd.info "procs" ~version:"alpha" ~doc in
  Cmd.v info Term.(const list_procs $ fname)

let dump_proc fname proc =
  try
    let p = Loader.Loadir.ast_of_fname fname in
    let id = p.prog.proc_names.get_id proc in
    let p = ID.Map.find id p.prog.procs in
    print_proc stdout p;
    Ok ()
  with
  | (Loader.Loadir.ILBParseError _ | Loader.Loadir.LoadError _) as e ->
      Error (Loader.Loadir.show_ilbparseerror e)
  | Not_found -> Error ("no procedure \"" ^ proc ^ "\" in " ^ fname)

let print_cfg fname proc =
  let prg = Loader.Loadir.ast_of_fname fname in
  let id = prg.prog.proc_names.get_id proc in
  let _ = ID.Map.find id prg.prog.procs in
  Ok ()
(*Lang.Livevars.print_live_vars_dot Format.std_formatter p ; *)
(*Lang.Livevars.print_dse_dot Format.std_formatter p; *)

let print_cfg_cmd =
  let doc = "print dot CFG for graph" in
  let info = Cmd.info "dump-cfg" ~version:"alpha" ~doc in
  Cmd.v info Term.(const print_cfg $ fname $ proc)

let dump_proc_cmd =
  let doc = "print il for procedure" in
  let info = Cmd.info "dump-il" ~version:"alpha" ~doc in
  Cmd.v info Term.(const dump_proc $ fname $ proc)

let run_script fname =
  let st = Script.init_st in
  let r =
    CCIO.with_in fname (fun c ->
        let iter = CCIO.read_lines_iter c in
        try
          let _ = Iter.fold (fun acc l -> Script.of_str acc l) st iter in
          Ok ()
        with
        | Common.ReplError { __LINE__; __FILE__; __FUNCTION__; msg; cmd } ->
          let n =
            Printf.sprintf "Error in %s: %s at %s %s:%d" cmd
              (Containers_pp.Term_color.color `Red (Containers_pp.text msg)
              |> Containers_pp.Pretty.to_string ~width:80)
              __FUNCTION__ __FILE__ __LINE__
          in
          Error n)
  in
  r

(*
let callgraph_cmd =
  let doc = "print dot callgraph for prog" in
  let info = Cmd.info "dump-callgraph" ~version:"alpha" ~doc in
  Cmd.v info Term.(const print_callgraph $ fname)
  *)

let script_cmd =
  let doc = "run script" in
  let info = Cmd.info "script" ~version:"alpha" ~doc in
  Cmd.v info Term.(const run_script $ fname)

let cmd =
  let doc = "bincaml" in
  Cmd.group (Cmd.info "bincaml" ~version:"%%VERSION%%" ~doc)
  @@ [ procs_cmd; dump_proc_cmd; print_cfg_cmd; script_cmd ]

let main () =
  Trace_core.set_process_name "main";
  Trace_core.set_thread_name "t1";
  exit (Cmd.eval_result cmd)

let () = Trace_tef.with_setup ~out:(`File "trace.json") () @@ fun () -> main ()
