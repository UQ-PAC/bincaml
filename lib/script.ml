open Bincaml_util.Common
open Lang

exception Parse

module SexpLoc = struct
  type t = Sexp.t
  type loc = Pp_loc.Position.t * Pp_loc.Position.t

  let make_loc =
    Some
      (fun a b s ->
        ( Pp_loc.Position.of_line_col (fst a) (snd a),
          Pp_loc.Position.of_line_col (fst b) (snd b) ))

  let atom x = `Atom x
  let list x = `List x
  let atom_with_loc ~loc:_ s = `Atom s
  let list_with_loc ~loc:_ l = `List l

  let match_ x ~atom ~list =
    match x with `Atom x -> atom x | `List l -> list l
end

module Sexp = Sexp.Make (SexpLoc)

type errpos = { pos : SexpLoc.loc list; inp : Pp_loc.Input.t }

let errpos_to_error_loc ?fname { inp; pos } =
  let name = Option.get_or ~default:"script" fname in
  let pos = List.map (fun (a, b) -> Errors.PPPosition (a, b)) pos in
  Errors.OtherFile { input = inp; locations = pos; name }

exception ReplError of { msg : string; cmd : string; loc : errpos option }

let print_repl_error = function
  | ReplError { msg; cmd; loc = None } ->
      Printf.sprintf "%s: %s" cmd
        (Containers_pp.Term_color.color `Red (Containers_pp.text msg)
        |> Containers_pp.Pretty.to_string ~width:80)
  | ReplError { msg; cmd; loc = Some loc } ->
      let exab fmt loc = Pp_loc.pp ~input:loc.inp fmt loc.pos in
      let msg =
        Printf.sprintf "%s: %s" cmd
          (Containers_pp.Term_color.color `Red (Containers_pp.text msg)
          |> Containers_pp.Pretty.to_string ~width:80)
      in
      let s =
        Format.asprintf "%s%a%a" msg Format.pp_force_newline () exab loc
      in
      s
  | _ -> failwith ""

let conv_repl_error f =
  Errors.protect_with_info
    (function
      | ReplError { msg; cmd; loc = None } ->
          Some (Errors.error (msg ^ " in cmd (" ^ cmd ^ ")") Error)
      | ReplError { msg; cmd; loc = Some pos } ->
          let here = errpos_to_error_loc pos in
          Some (Errors.error ~here (msg ^ " in cmd (" ^ cmd ^ ")") Unhandled)
      | o -> None)
    f

let printer () =
  Printexc.register_printer (function
    | ReplError _ as e -> Some (print_repl_error e)
    | _ -> None)

let () = printer ()
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

type dsl_st = {
  history : Sexp.t list;
  load_st : Loader.Loadir.load_st option;
  source_files : string list; (* if there is a single exact source file *)
  line : int;
  user_cmds : (string * Sexp.t) StringMap.t;
}

let init_st =
  {
    history = [];
    load_st = None;
    line = 0;
    user_cmds = StringMap.empty;
    source_files = [];
  }

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
  file_opt ofile (fun c ->
      let prog =
        Some
          (Passes.PassManager.run_transform (get_prog st)
             (Passes.PassManager.dump_boogie c))
      in
      set_prog st prog)

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
          ^ (StringMap.to_iter rvals
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

let chc_dump_clauses st args =
  let ofile = P.(singleton string args) in
  Transforms.Chc_infer.dump_to_file (get_prog st) ofile;
  st

let load_il st args =
  let largs = P.(list string args) in
  let cmd = "load-il " ^ Sexp.to_string args in
  Errors.(update_error (push_message @@ error_message cmd Errors.InputError))
    (fun () ->
      Errors.wrap_error (fun () ->
          List.fold_left
            (fun acc fname ->
              let st = Loader.Loadir.ast_of_fname ?lst:acc.load_st fname in
              {
                acc with
                load_st = Some st;
                source_files = fname :: acc.source_files;
              })
            { st with load_st = None } largs))

let run_transform st args =
  let args = P.(list string args) in
  let ba = Passes.PassManager.batch_of_list args in
  let prog = Some (Passes.PassManager.run_batch ba (get_prog st)) in
  set_prog st prog

let log_level st args =
  let make_error msg = ReplError { msg; cmd = "log-level"; loc = None } in

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
  |> Iter.iter (fun (i, _) -> print_endline (ID.show i));
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

let get_proc st proc =
  let proc =
    match Procedure.graph @@ Program.get_proc_by_name proc (get_prog st) with
    | Some e -> e
    | None | (exception Not_found) -> begin
        raise
          (ReplError
             {
               loc = None;
               cmd = "";
               msg = Printf.sprintf "No procedure in program with name %s" proc;
             })
      end
  in
  proc

let dump_proc_il st args =
  let proc, ofile = P.(pair_opt string string args) in
  file_opt ofile (fun c ->
      let p = Program.get_proc_by_name proc (get_prog st) in
      print_proc c p);
  st

let list_passes st args =
  Passes.PassManager.print_passes
  |> Containers_pp.Pretty.to_string ~width:80
  |> print_endline;
  st

let def_cmd st d =
  let name, doc, defn =
    match d with
    | `List [ `Atom n; `Atom doc; defn ] -> (n, doc, defn)
    | _ -> failwith "Illeal structure"
  in
  let defn : Sexp.t = defn in
  { st with user_cmds = StringMap.add name (doc, defn) st.user_cmds }

let write_proc_cfg st args =
  let proc, ofile = P.(pair_opt string string args) in
  let proc = get_proc st proc in
  file_opt ofile (fun c -> Viscfg.Dot.output_graph c proc);
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

let load_gtirb st fname =
  let gtirb, a = P.pair_opt P.string P.string fname in
  file_opt a (fun chan ->
      let p = Gtirb_frontend.load_gtirb_prog gtirb in
      let p =
        match p with
        | Ok e ->
            let e = Program.set_attrib Invariants.(to_attrib [ GtirbArm ]) e in
            Loader.Loadir.(
              Some
                { prog = e; curr_proc = None; params_order = Hashtbl.create 0 })
        | _ -> None
      in
      { st with load_st = p })

let dbg_gtirb st fname =
  let gtirb, a = P.pair_opt P.string P.string fname in
  file_opt a (fun chan ->
      let p = Gtirb_frontend.load_gtirb_gfir gtirb in
      p |> Option.to_iter
      |> Iter.flat_map Gtirb_frontend.UUIDMap.to_iter
      |> Iter.map snd
      |> Iter.iter (fun (p : Gtirb_frontend.Gfir.temp_proc) ->
          print_endline p.name;
          Gtirb_frontend.(Gfir.D.output_graph chan p.cfg)));
  st

let cmds_list =
  [
    ("skip", (fun a b -> a), "", "Do nothing");
    ("load-il", load_il, "<filename1> <filename2> ...", "load il files");
    ("gtirb", dbg_gtirb, "in.gtirb output_file?", "Gtirb debug");
    ("load-gtirb", load_gtirb, "in.gtirb output_file?", "Load gtirb file");
    ("defcmd", def_cmd, "<name> <definition>", "define a command alias");
    ("list-procs", list_procs, "", "List procedures in program");
    ("dump-il", dump_il, "?file", "Write IL to file or stdout");
    ("dump-boogie", dump_boogie, "?file", "Write Boogie to file or stdout");
    ( "chc-dump-clauses",
      chc_dump_clauses,
      "<file>",
      "Encode the program as CHCs and write the SMT-LIB clauses to a file" );
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
    ( "dump-proc-cfg",
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
    let cmds =
      List.map (fun (name, _, args, help) -> (name, args, help)) cmds
    in
    let user_cmds =
      StringMap.to_list st.user_cmds
      |> List.map (function name, (doc, _) -> (name, "", doc))
    in
    let text =
      List.map
        (fun (name, args, help) ->
          text name ^+ text args ^+ text " : " ^+ nest 4 (text help))
        (cmds @ user_cmds)
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

let protect_with_input { source_files } f =
  match source_files with
  | [ inp ] -> Errors.update_error (Errors.add_input ~input_file:inp) f
  | _ ->
      (* there is not a singular source file *)
      f ()

let rec of_cmd ?(cmds = default_cmds) ?(echo_cmd = true) st
    (i_command : Containers.Sexp.t) =
  protect_with_input st @@ fun () ->
  match i_command with
  | `List (`Atom "progn" :: rest) ->
      List.fold_left (of_cmd ~cmds ~echo_cmd) st rest
  | o -> atom_cmd ~cmds ~echo_cmd st o

and atom_cmd ?(cmds = default_cmds) ?(echo_cmd = true) st
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
    | `List [ `List (`Atom cmd :: n) ] -> (cmd, `List n)
    | _ ->
        raise (ReplError { msg = "bad command."; loc = None; cmd = full_cmd })
  in
  Trace_core.with_span ~__FILE__ ~__LINE__ ("runcmd::" ^ cmd) (fun _ ->
      match StringMap.find_opt cmd st.user_cmds with
      | Some e -> of_cmd ~cmds ~echo_cmd st (snd e)
      | None -> (
          match StringMap.find_opt cmd cmds with
          | Some f ->
              let st = f st args in
              let st = { st with history = i_command :: st.history } in
              st
          | None -> Errors.raise_error "not a command." Error))

let of_channel ?st c =
  let st = Option.get_or ~default:init_st st in
  let i =
    Sexp.parse_chan_list c |> function Ok e -> e | Error e -> failwith e
  in
  List.fold_left of_cmd st i

let of_chan_2 ?fname ?st channel =
  conv_repl_error @@ fun () ->
  let lbuf = Lexing.from_channel ~with_positions:true channel in
  let s = Sexp.Decoder.of_lexbuf lbuf in
  let st = ref (Option.get_or ~default:init_st st) in
  let fname = Option.filter Sys.file_exists fname in
  let inp =
    fname
    |> Option.map Pp_loc.Input.file
    |> Option.get_or ~default:(Pp_loc.Input.in_channel channel)
  in
  while
    let sexp = Sexp.Decoder.next s in
    let e : Sexp.loc option = Sexp.Decoder.last_loc s in
    let loc =
      match (e, fname) with
      | Some e, Some _ -> Some { pos = [ e ]; inp }
      | _ -> None
    in
    let here = Option.map (errpos_to_error_loc ?fname) loc in
    match sexp with
    | Yield sexp ->
        let f () =
          st := of_cmd !st sexp;
          true
        in
        Errors.protect_with_info
          (function
            | ReplError { msg; cmd; loc = None } ->
                Some (Errors.error ?here (msg ^ " in cmd " ^ cmd) Error)
            | err -> Some (Errors.error_of_exn ?here err))
          f
    | Fail msg -> raise (ReplError { msg; loc; cmd = "" })
    | End -> false
  do
    ()
  done;
  !st

let of_str st (e : string) =
  conv_repl_error @@ fun () ->
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
        raise (ReplError { msg; loc = None; cmd = "parse" })
  in
  of_cmd st s
