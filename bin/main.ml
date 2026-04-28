open Bincaml_util.Common
open Bincaml_util.Logger
open Lang
open Cmdliner
open Cmdliner.Term.Syntax
open Bincaml

let () = Printexc.record_backtrace true
let () = Script.printer ()

let kittyimg dotfile =
  CCIO.File.with_temp ~prefix:"bincaml_repl_cfg" ~suffix:".png" (fun pngfile ->
      let pngfile = ".png" in
      let cols = Option.get_or ~default:10 @@ Terminal_size.get_columns () in
      let _ =
        Sys.command (Printf.sprintf "dot %s  -Tpng -o %s" dotfile pngfile)
      in
      let img = Stb_image.load ~channels:4 pngfile in
      match img with
      | Ok img ->
          let b = Kittyimg.string_of_bytes_ba img.Stb_image.data in
          print_newline ();
          Kittyimg.send_image ~w:img.Stb_image.width ~h:img.Stb_image.height
            ~format:`RGBA
            ~mode:(`Display (Kittyimg.display_opts ~cstretch:cols ()))
            b;
          print_newline ()
      | Error (`Msg e) -> failwith ("svg failure" ^ e))

let display_proc_cfg st proc =
  let proc = Script.P.(singleton string proc) in
  let proc = Script.get_proc st proc in
  CCIO.File.with_temp ~prefix:"graph" ~suffix:".dot" (fun dot ->
      CCIO.with_out dot (fun dot ->
          Viscfg.Dot.output_graph dot proc;
          flush dot);
      kittyimg dot;
      st)

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

let echo_cmd =
  let doc = "Have repl echo each command back" and docv = "ECHO_CMD" in
  Arg.(value & flag & info [ "e"; "echo" ] ~doc ~docv)

(** Runs the [inner] function with an input channel. The input channel is from
    opening the given [fname], or stdin if [fname] is [-]. *)
let with_in_or_stdin fname inner =
  match fname with "-" -> inner stdin | fname -> CCIO.with_in fname inner

exception Exit

let repl ~verb ~echo_cmd =
  let cmds =
    Script.cmds_list
    @ [
        ( "clear",
          (fun st c ->
            LNoise.clear_screen ();
            st),
          "",
          "clear screen" );
        ("exit", (fun st c -> raise_notrace Exit), "", "exit");
        ( "run-script",
          (fun st c ->
            let fname = Script.P.(singleton string c) in
            CCIO.with_in fname (fun c ->
                try Script.of_chan_2 ~fname ~st c
                with Script.ReplError _ as exn ->
                  print_endline @@ Script.print_repl_error exn;
                  st)),
          "fname.sexp",
          "Interpret a script" );
        ( "display-proc-cfg",
          display_proc_cfg,
          "<proc> ?file",
          "Write dot cfg of <proc> to file or stdout" );
      ]
  in

  let cmds_m = cmds |> Script.add_help_cmd in

  let completions_from_list ls prefix =
    List.to_iter ls |> Iter.filter (fun i -> String.starts_with ~prefix i)
  in

  let iter_of_gen g =
    let rec iter_gen f g =
      match g () with
      | Some n ->
          f n;
          iter_gen f g
      | None -> ()
    in
    Iter.from_iter (fun f -> iter_gen f g)
  in

  let complete_filename prefix =
    let path, fname =
      match CCIO.File.is_directory prefix with
      | true -> (prefix, "")
      | (exception Sys_error _) | false ->
          (Filename.dirname prefix, Filename.basename prefix)
    in
    let files = iter_of_gen (CCIO.File.read_dir path) in
    files
    |> Iter.flat_map (function
      | n when String.starts_with ~prefix:fname n ->
          Iter.singleton @@ Filename.concat path n
      | n when String.starts_with ~prefix:fname n ->
          Iter.singleton @@ Filename.concat path n
      | _ -> Iter.empty)
  in

  let cmds_completion =
    cmds
    |> List.map (function (a, _, _, _) as cmd -> (a, cmd))
    |> StringMap.of_list
  in

  let hints_callback cmd =
    let cmd = String.trim cmd in
    StringMap.find_opt cmd cmds_completion
    |> Option.map (function _, _, c, _ -> (c, LNoise.Blue, true))
  in
  LNoise.set_hints_callback hints_callback;

  let _ = LNoise.history_load ~filename:".bincaml_repl_history" in

  let opt_len = function Some _ -> 1 | _ -> 0 in

  let completions_state = ref None in
  let completions_callback str completions =
    let last ns =
      List.rev ns |> List.head_opt |> function
      | Some (`Atom n) -> Some n
      | _ -> None
    in
    let proc_list =
      lazy
        (Option.bind !completions_state Script.(fun s -> s.load_st)
        |> Option.to_iter
        |> Iter.flat_map (fun p ->
            Program.procs Loader.Loadir.(p.prog)
            |> Iter.map (fst %> ID.to_string))
        |> Iter.to_list)
    in
    let str = Sexp.parse_string_list str in
    match str with
    | Error e -> ()
    | Ok [ `Atom "log-level"; `Atom level ] ->
        completions_from_list
          [ "quiet"; "info"; "app"; "error"; "warning"; "debug" ]
          level
        |> Iter.iter (fun c ->
            LNoise.add_completion completions @@ "log-level " ^ c)
    | Ok [ (`Atom "dump-proc-il" as c); `Atom proc ]
    | Ok [ (`Atom "list-blocks-il" as c); `Atom proc ]
    | Ok [ (`Atom "display-proc-cfg" as c); `Atom proc ]
    | Ok [ (`Atom "dump-proc-cfg" as c); `Atom proc ] ->
        completions_from_list (Lazy.force proc_list) proc
        |> Iter.map (fun s -> Sexp.to_string c ^ " " ^ s)
        |> Iter.iter (LNoise.add_completion completions)
    | Ok (`Atom "load-il" :: fnames as l)
    | Ok (`Atom "run-script" :: fnames as l)
    | Ok (`Atom "dump-il" :: fnames as l)
    | Ok (`Atom "interp-out" :: fnames as l)
    | Ok (`Atom "write-proc-cfg" :: fnames as l)
    | Ok (`Atom "dump-proc-il" :: fnames as l)
    | Ok (`Atom "dump-boogie" :: fnames as l) ->
        let c = last fnames in
        let l =
          List.take (List.length l - opt_len c) l
          |> List.to_string ~sep:" " CCSexp.to_string
        in
        (match c with Some n -> Iter.singleton n | None -> Iter.empty)
        |> Iter.flat_map complete_filename
        |> Iter.map (fun s -> l ^ " " ^ s)
        |> Iter.iter (LNoise.add_completion completions)
    | Ok (`Atom "run-transforms" :: transforms as l)
    | Ok (`Atom "run-transform" :: transforms as l) ->
        let c = last transforms in
        let l =
          List.take (List.length l - opt_len c) l
          |> List.to_string ~sep:" " CCSexp.to_string
        in
        let tx_list =
          Bincaml.Passes.PassManager.(passes |> List.map (fun x -> x.name))
        in
        (match c with Some n -> Iter.singleton n | None -> Iter.singleton "")
        |> Iter.flat_map (completions_from_list tx_list)
        |> Iter.map (fun s -> l ^ " " ^ s)
        |> Iter.iter (LNoise.add_completion completions)
    | Ok [ `Atom cmd ] ->
        Iter.filter (String.starts_with ~prefix:cmd) (StringMap.keys cmds_m)
        |> Iter.iter (fun s -> LNoise.add_completion completions (s ^ " "))
    | _ -> ()
  in
  LNoise.set_completion_callback completions_callback;

  LNoise.catch_break true;
  if verb then Logs.set_level (Some Logs.Debug);
  try
    LNoise.set_multiline true;
    let st = ref Script.init_st in
    while
      completions_state := Some !st;
      try
        begin
          let line = LNoise.linenoise "bcml ~> " in
          let sexp =
            line |> Option.map (fun line -> Sexp.parse_string_list line)
          in
          match sexp with
          | Some (Ok sexp) -> (
              let _ = LNoise.history_add (Option.get_exn_or "" line) in
              try
                st := Script.of_cmd ~cmds:cmds_m ~echo_cmd !st (`List sexp);
                true
              with
              | Exit -> false
              | err ->
                  Logs.app (fun m -> m "%s" (Printexc.to_string err));
                  Logs.debug (fun m -> m "%s" (Printexc.get_backtrace ()));
                  true)
          | Some (Error msg) ->
              Logs.app (fun m -> m "Syntax error: %s" msg);
              true
          | None -> false
        end
      with Sys.Break -> true
    do
      ()
    done;
    let _ = LNoise.history_save ~filename:".bincaml_repl_history" in

    Ok ()
  with e -> Error (Printexc.to_string e)

let run_script ~verb fname =
  if verb then Logs.set_level (Some Logs.Debug);
  with_in_or_stdin fname @@ fun chan ->
  try
    let _ = Script.of_chan_2 chan in
    Ok ()
  with e -> Error (Printexc.to_string e)

(*
let callgraph_cmd =
  let doc = "print dot callgraph for prog" in
  let info = Cmd.info "dump-callgraph" ~version:"alpha" ~doc in
  Cmd.v info Term.(const print_callgraph $ fname)
  *)

let repl_cmd =
  let doc = "run repl" in
  let info = Cmd.info "repl" ~version:"alpha" ~doc in
  Cmd.make info
  @@ let+ verb and+ echo_cmd in
     repl ~verb ~echo_cmd

let script_cmd =
  let doc = "run script" in
  let info = Cmd.info "script" ~version:"alpha" ~doc in
  Cmd.make info
  @@ let+ verb and+ fname in
     run_script ~verb fname

let cmd =
  let doc = "bincaml" in
  Cmd.group (Cmd.info "bincaml" ~version:"%%VERSION%%" ~doc)
  @@ [ script_cmd; repl_cmd ]

let main () =
  Trace_core.set_process_name "main";
  Trace_core.set_thread_name "t1";
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs.format_reporter ());
  exit (Cmd.eval_result cmd)

let () = Trace_tef.with_setup ~out:(`File "trace.json") () @@ fun () -> main ()
