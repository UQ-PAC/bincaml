open Bincaml_util.Common
open Lang

exception Parse

let print_proc chan p = Program.output_proc_pretty chan p

let print_blocks_topo_fwd chan p =
  let ids = Procedure.fold_blocks_topo_fwd (fun l id b -> id :: l) [] p in
  let ids_rev = Procedure.fold_blocks_topo_rev (fun l id b -> id :: l) [] p in
  (*assert (List.equal ID.equal ids (List.rev ids));*)
  List.iter
    (fun i ->
      output_string chan (ID.to_string i);
      output_string chan "\n")
    (List.rev ids);
  output_string chan "\n\n";
  List.iter
    (fun i ->
      output_string chan (ID.to_string i);
      output_string chan "\n")
    ids_rev

let assert_atoms =
  let error arg =
    Common.ReplError
      {
        msg =
          Printf.sprintf "expected an atom but got a list: %s"
            (Sexp.to_string arg);
        cmd = "unk";
        __FILE__;
        __FUNCTION__;
        __LINE__;
      }
  in
  List.map (function `Atom n -> n | non_atom -> raise (error non_atom))

let assert_n_atoms n args =
  let atoms = assert_atoms args in
  if List.length atoms < n then
    raise
      (Common.ReplError
         {
           msg =
             Printf.sprintf "expected %d args but got %d" n (List.length args);
           cmd = "unk";
           __FILE__;
           __FUNCTION__;
           __LINE__;
         });
  atoms

type dsl_st = {
  history : Sexp.t list;
  load_st : Loader.Loadir.load_st option;
  line : int;
}

let init_st = { history = []; load_st = None; line = 0 }

let get_prog s =
  s.load_st
  |> Option.map (fun (lst : Loader.Loadir.load_st) -> lst.prog)
  |> Option.get_exn_or "no program loaded"

let set_prog s prog =
  match prog with
  | Some prog ->
      {
        s with
        load_st =
          s.load_st
          |> Option.map (fun (lst : Loader.Loadir.load_st) -> { lst with prog });
      }
  | _ -> s

let file_opt a f =
  match a with Some ofile -> CCIO.with_out ofile f | None -> f stdout

module P = struct
  let string s =
    match s with `Atom a -> a | _ -> failwith "expected string atom"

  let int s =
    match s with
    | `Atom a -> Int.of_string a |> Option.get_exn_or "expected int"
    | _ -> failwith "expected int atom"

  let empty s = match s with `List [] -> () | _ -> failwith "expected empty"

  let singleton a s =
    match s with `List [ l ] -> a l | _ -> failwith "expected pair"

  let pair_opt a b s =
    match s with
    | `List [ l; r ] -> (a l, Some (b r))
    | `List [ l ] -> (a l, None)
    | _ -> failwith "expected at least one arg"

  let opt a s =
    match s with
    | `List [ l ] -> Some (a l)
    | `List [] -> None
    | _ -> failwith "expected pair"

  let pair a b s =
    match s with `List [ l; r ] -> (a l, b r) | _ -> failwith "expected pair"

  let enum vs s =
    let vs = StringMap.of_list vs in
    match s with
    | `Atom e -> StringMap.find e vs
    | _ -> failwith "expected atpom"

  let list f a =
    match a with `List l -> List.map f l | _ -> failwith "expected pair"
end

let dump_il st ofile =
  let ofile = P.(opt string ofile) in
  file_opt ofile (fun c -> Program.pretty_to_chan c (get_prog st));
  st

let dump_boogie st ofile =
  let ofile = P.(opt string ofile) in
  file_opt ofile (fun c -> Backends.Boogie.pretty_to_chan c (get_prog st));
  st

let interp_out st ofile =
  let ofile = P.(opt string ofile) in
  let prog = get_prog st in
  let main = Lang.Program.entry_proc_exn prog in
  let ist =
    match Lang.Interp.test_run_proc ~seed:123456 prog main with
    | Ok (st, rvals) ->
        let state = Lang.Interp.IState.show ~show_stack:false st in
        let params =
          "returned: "
          ^ (Common.StringMap.to_iter rvals
            |> Iter.to_string ~sep:", " (fun (k, v) ->
                k ^ "=" ^ Lang.Ops.AllOps.to_string v))
        in
        params ^ "\n" ^ state
    | Error (st, msg) ->
        "ERROR " ^ msg ^ " after state "
        ^ Lang.Interp.IState.show ~show_stack:true st
  in
  file_opt ofile (fun c -> output_string c ist);
  st

let load_il st args =
  let largs = P.(list string args) in
  try
    List.fold_left
      (fun acc fname ->
        let st = Loader.Loadir.ast_of_fname ?lst:acc.load_st fname in
        { acc with load_st = Some st })
      { st with load_st = None } largs
  with (Loader.Loadir.ILBParseError _ | Loader.Loadir.LoadError _) as e ->
    let msg = Loader.Loadir.show_ilbparseerror e in
    raise
      (Common.ReplError
         {
           msg;
           __FILE__;
           __LINE__;
           __FUNCTION__;
           cmd = "load-il " ^ Sexp.to_string args;
         })

let run_transform st args =
  let args = P.(list string args) in
  let ba = Bincaml.Passes.PassManager.batch_of_list args in
  let prog = Some (Bincaml.Passes.PassManager.run_batch ba (get_prog st)) in
  set_prog st prog

let log_level st args =
  let make_error msg =
    Common.ReplError
      { msg; cmd = "log-level"; __FILE__; __FUNCTION__; __LINE__ }
  in

  let args = P.(list string args) in
  let level, src_names =
    match args with
    | [] -> raise (make_error "Expected at least one argument")
    | level :: rest -> (
        match Result.to_opt @@ Logs.level_of_string level with
        | Some a -> (a, rest)
        | None ->
            raise
              (make_error
                 "Incorrect log level option given, correct options are \
                  [\"info\", \"quiet\", \"app\", \"error\", \"warning\", \
                  \"debug\"]"))
  in
  (match src_names with
  | [] -> Logs.set_level level
  | src_names ->
      let srcs =
        Iter.of_list (Logs.Src.list ())
        |> Iter.map (fun src -> (Logs.Src.name src, src))
        |> Iter.to_hashtbl
      in
      let find name =
        Hashtbl.find_opt srcs name
        |> CCOption.get_lazy (fun () ->
            raise (make_error @@ Printf.sprintf "source %s not found" name))
      in
      List.iter (fun name -> Logs.Src.set_level (find name) level) src_names);
  st

let list_procs st a =
  let open Program in
  Program.procs (get_prog st)
  |> Iter.iter (fun (i, _) -> Printf.printf "%s\n" (ID.show i));
  st

let list_blocks_il st args =
  let proc = P.(singleton string args) in
  let p = Program.get_proc_by_name proc (get_prog st) in
  print_blocks_topo_fwd stdout p;
  st

let run_bash_command st args =
  let l = P.(list string args) |> String.concat " " in
  let ou, err, exit = CCUnix.call ~stdin:(`Str "") "%s" l in
  output_string stderr err;
  output_string stdout ou;
  flush_all ();
  st

let write_proc_cfg st args =
  let proc, ofile = P.(pair string string args) in
  CCIO.with_out ofile (fun c ->
      let p =
        try Program.get_proc_by_name proc (get_prog st)
        with Not_found ->
          begin
            raise
              (Common.ReplError
                 {
                   __LINE__;
                   __FILE__;
                   __FUNCTION__;
                   cmd = "write-proc-cfg";
                   msg =
                     Printf.sprintf "No procedure in program with name %s" proc;
                 })
          end
      in
      Viscfg.Dot.output_graph c
        (Procedure.graph p |> Option.get_exn_or "procedure has no graph"));
  st

let dump_proc_il st args =
  let proc, ofile = P.(pair_opt string string args) in
  file_opt ofile (fun c ->
      let p = Program.get_proc_by_name proc (get_prog st) in
      print_proc c p);
  st

let list_passes st args =
  Bincaml.Passes.PassManager.print_passes
  |> Containers_pp.Pretty.to_string ~width:80
  |> print_endline;
  st

let save_history st fname =
  file_opt
    P.(opt string fname)
    (fun chan ->
      st.history
      |> List.filter (function `List [] -> false | _ -> true)
      |> List.rev
      |> List.to_string ~sep:"\n" Sexp.to_string
      |> output_string chan;
      flush_all ();
      st)

let cmds_list =
  [
    ("skip", (fun a b -> a), "", "Do nothing");
    ("load-il", load_il, "<filename1> <filename2> ...", "load il files");
    ("list-procs", list_procs, "", "List procedures in program");
    ("dump-il", dump_il, "?file", "Write IL to file or stdout");
    ("dump-boogie", dump_boogie, "?file", "Write Boogie to file or stdout");
    ( "interp-out",
      interp_out,
      "?file",
      "Interpreter and write final state to stdout or file" );
    ( "run-transform",
      run_transform,
      "<t1> <t2> ...",
      "run IL transforms in sequnce" );
    ("list-passes", list_passes, "", "List transform passes");
    ( "run-transforms",
      run_transform,
      "<t1> <t2> ...",
      "run IL transforms in sequnce" );
    ("log-level", log_level, "<level> <sources list>", "set log level");
    ( "list-blocs-il",
      list_blocks_il,
      "<procedure>",
      "list blocks in a procedure" );
    ( "write-proc-cfg",
      write_proc_cfg,
      "<proc> ?file",
      "Write dot cfg of <proc> to file or stdout" );
    ("dump-history", save_history, "file.sexp", "Print the IL of a proc");
    ("dump-proc-il", dump_proc_il, "procname", "Print the IL of a proc");
    ("!", run_bash_command, "", "run bash command");
    ("help", (fun a b -> a), "", "print help message");
  ]

let add_help_cmd cmds =
  let open Containers_pp in
  let help st arg =
    let text =
      List.map
        (fun (name, _, args, help) ->
          text name ^+ text args ^+ text " : " ^+ nest 4 (text help))
        cmds
      |> append_nl
      |> Containers_pp.Pretty.to_string ~width:80
    in
    Logs.app (fun m -> m "%s" text);
    st
  in
  List.map (function "help", _, a, b -> ("help", help, a, b) | o -> o) cmds
  |> List.map (function c, f, _, _ -> (c, f))
  |> StringMap.of_list

let default_cmds = add_help_cmd cmds_list

let of_cmd ?(cmds = default_cmds) ?(echo_cmd = true) st
    (i_command : Containers.Sexp.t) =
  let full_cmd = Sexp.to_string i_command in
  (match i_command with
  | `List [] -> ()
  | _ when echo_cmd -> Logs.app (fun m -> m "%s" full_cmd)
  | _ -> ());

  let cmd, args =
    match i_command with
    | `List [] -> ("skip", `List [])
    | `List (`Atom cmd :: n) -> (cmd, `List n)
    | _ -> failwith @@ "bad cmd structure " ^ full_cmd
  in
  Trace_core.with_span ~__FILE__ ~__LINE__ ("runcmd::" ^ cmd) (fun _ ->
      match StringMap.find_opt cmd cmds with
      | Some f ->
          let st = f st args in
          { st with history = i_command :: st.history }
      | None -> failwith @@ "not a command : " ^ cmd)

let of_channel ?st c =
  let st = Option.get_or ~default:init_st st in
  let i =
    Sexp.parse_chan_list c |> function Ok e -> e | Error e -> failwith e
  in
  List.fold_left of_cmd st i

let of_chan_2 channel =
  try
    let lbuf = Lexing.from_channel channel in
    let s = Sexp.Decoder.of_lexbuf lbuf in
    let st = ref init_st in
    while
      let sexp = Sexp.Decoder.next s in
      match sexp with
      | Yield sexp -> (
          try
            st := of_cmd !st sexp;
            true
          with err ->
            Logs.debug (fun m -> m "%s" (Printexc.get_backtrace ()));
            failwith (Printexc.to_string err))
      | Fail msg -> failwith ("Syntax error: " ^ msg)
      | End -> false
    do
      ()
    done;

    Ok ()
  with Common.ReplError { __LINE__; __FILE__; __FUNCTION__; msg; cmd } ->
    let n =
      Printf.sprintf "Error in %s: %s at %s %s:%d" cmd
        (Containers_pp.Term_color.color `Red (Containers_pp.text msg)
        |> Containers_pp.Pretty.to_string ~width:80)
        __FUNCTION__ __FILE__ __LINE__
    in
    Error n

let of_str st (e : string) =
  let str_comment =
    try String.index_from e 0 ';' with Not_found -> String.length e
  in
  let st = { st with line = st.line + 1 } in
  let e = String.sub e 0 str_comment in
  let s = match e with "" -> Ok (`List []) | e -> CCSexp.parse_string e in
  let s =
    match s with
    | Ok e -> e
    | Error err ->
        let msg = "failed to parse " ^ e ^ ": " ^ err in
        raise
          (Common.ReplError
             { msg; __FILE__; __LINE__; __FUNCTION__; cmd = "parse" })
  in
  of_cmd st s
