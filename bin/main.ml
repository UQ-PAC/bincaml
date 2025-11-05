open Containers
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
  let p = Ocaml_of_basil.Loadir.ast_of_fname fname in
  let procs prog =
    let open Program in
    Lang.ID.Map.iter (fun i _ -> Printf.printf "%s\n" (ID.show i)) prog.procs
  in
  procs p.prog

let procs_cmd =
  let doc = "list program print procedures " in
  let info = Cmd.info "procs" ~version:"alpha" ~doc in
  Cmd.v info Term.(const list_procs $ fname)

let dump_proc fname proc =
  let p = Ocaml_of_basil.Loadir.ast_of_fname fname in
  let id = p.prog.proc_names.get_id proc in
  let p = Lang.ID.Map.find id p.prog.procs in
  print_proc stdout p

let print_cfg fname proc =
  let prg = Ocaml_of_basil.Loadir.ast_of_fname fname in
  let id = prg.prog.proc_names.get_id proc in
  let _ = Lang.ID.Map.find id prg.prog.procs in
  (*Lang.Livevars.print_live_vars_dot Format.std_formatter p ; *)
  (*Lang.Livevars.print_dse_dot Format.std_formatter p; *)
  CCUnix.with_out "before.il" ~f:(fun c ->
      Lang.ID.Map.iter (fun i p -> print_proc c p) prg.prog.procs);
  Lang.ID.Map.iter
    (fun i p -> Transforms.Livevars.DSE.sane_transform p)
    prg.prog.procs;
  CCUnix.with_out "after.il" ~f:(fun c ->
      Lang.ID.Map.iter (fun i p -> print_proc c p) prg.prog.procs)

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
  let _ =
    CCIO.with_in fname (fun c ->
        let iter = CCIO.read_lines_iter c in
        Iter.fold (fun acc l -> Script.of_str acc l) st iter)
  in
  ()

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
  let doc = "obasil" in
  Cmd.group (Cmd.info "info" ~version:"%%VERSION%%" ~doc)
  @@ [ procs_cmd; dump_proc_cmd; print_cfg_cmd; script_cmd ]

let main () =
  Trace.set_process_name "main";
  Trace.set_thread_name "t1";
  exit (Cmd.eval cmd)

let () = Trace_tef.with_setup ~out:(`File "trace.json") () @@ fun () -> main ()
