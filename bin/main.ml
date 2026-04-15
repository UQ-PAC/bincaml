open Bincaml_util.Common
open Bincaml_util.Logger
open Lang
open Cmdliner
open Cmdliner.Term.Syntax

let () = Printexc.record_backtrace true

let fname =
  let doc = "Input file name (e.g., filename.il or - for stdin)" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FNAME" ~doc)

let proc =
  let doc = "proc to output" and docv = "PROC" in
  Arg.(value & opt string "" & info [ "p"; "proc" ] ~doc ~docv)

let print_proc chan p = Program.output_proc_pretty chan p

let verb =
  let doc = "set log level to debug" and docv = "VERBOSE" in
  Arg.(value & flag & info [ "v"; "verbose" ] ~doc ~docv)

(** Runs the [inner] function with an input channel. The input channel is from
    opening the given [fname], or stdin if [fname] is [-]. *)
let with_in_or_stdin fname inner =
  match fname with "-" -> inner stdin | fname -> CCIO.with_in fname inner

let run_script ~verb fname =
  if verb then Logs.set_level (Some Logs.Debug);
  let st = Script.init_st in
  with_in_or_stdin fname @@ fun chan ->
  let iter = CCIO.read_lines_iter chan in
  try
    let _ = Iter.fold (fun acc l -> Script.of_str acc l) st iter in
    Ok ()
  with Common.ReplError { __LINE__; __FILE__; __FUNCTION__; msg; cmd } ->
    let n =
      Printf.sprintf "Error in %s: %s at %s %s:%d" cmd
        (Containers_pp.Term_color.color `Red (Containers_pp.text msg)
        |> Containers_pp.Pretty.to_string ~width:80)
        __FUNCTION__ __FILE__ __LINE__
    in
    Error n

(*
let callgraph_cmd =
  let doc = "print dot callgraph for prog" in
  let info = Cmd.info "dump-callgraph" ~version:"alpha" ~doc in
  Cmd.v info Term.(const print_callgraph $ fname)
  *)

let script_cmd =
  let doc = "run script" in
  let info = Cmd.info "script" ~version:"alpha" ~doc in
  Cmd.make info
  @@ let+ verb = verb and+ fname = fname in
     run_script ~verb fname

let cmd =
  let doc = "bincaml" in
  Cmd.group (Cmd.info "bincaml" ~version:"%%VERSION%%" ~doc) @@ [ script_cmd ]

let main () =
  Trace_core.set_process_name "main";
  Trace_core.set_thread_name "t1";
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs.format_reporter ());
  exit (Cmd.eval_result cmd)

let () = Trace_tef.with_setup ~out:(`File "trace.json") () @@ fun () -> main ()
