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

let assert_atoms n args =
  if List.length args < n then
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
  List.map (function `Atom n -> n | _ -> failwith "expected atom") args

type dsl_st = { prog : Program.t option; line : int }

let init_st = { prog = None; line = 0 }
let get_prog s = Option.get_exn_or "no program loaded" s.prog

let of_cmd st (e : Containers.Sexp.t) =
  let full_cmd = Sexp.to_string e in
  let cmd, args =
    match e with
    | `List [] -> ("skip", [])
    | `List (`Atom cmd :: n) -> (cmd, n)
    | _ -> failwith @@ "bad cmd structure " ^ full_cmd
  in
  Trace_core.with_span ~__FILE__ ~__LINE__ ("runcmd::" ^ cmd) (fun _ ->
      match cmd with
      | "skip" -> st
      | "load-il" -> (
          try
            let fname = List.hd (assert_atoms 1 args) in
            let p = Loader.Loadir.ast_of_fname fname in
            { st with prog = Some p.prog }
          with
          | (Loader.Loadir.ILBParseError _ | Loader.Loadir.LoadError _) as e ->
            let msg = Loader.Loadir.show_ilbparseerror e in
            raise
              (Common.ReplError
                 { msg; __FILE__; __LINE__; __FUNCTION__; cmd = full_cmd }))
      | "list-procs" ->
          let open Program in
          ID.Map.iter
            (fun i _ -> Printf.printf "%s\n" (ID.show i))
            (get_prog st).procs;
          st
      | "list-blocks-il" ->
          let proc = List.hd (assert_atoms 1 args) in
          let id = (get_prog st).proc_names.get_id proc in
          let p = ID.Map.find id (get_prog st).procs in
          print_blocks_topo_fwd stdout p;
          st
      | "write-proc-cfg" ->
          let proc, ofile =
            assert_atoms 2 args |> function
            | [ proc; ofile ] -> (proc, ofile)
            | _ -> failwith "unreachable"
          in
          CCIO.with_out ofile (fun c ->
              let id =
                try (get_prog st).proc_names.get_id proc
                with Not_found ->
                  begin
                    let procs =
                      ID.Map.keys (get_prog st).procs
                      |> Iter.to_string ~sep:"\n" (fun n ->
                          Printf.sprintf "  %s\n" (ID.show n))
                    in
                    raise
                      (Common.ReplError
                         {
                           __LINE__;
                           __FILE__;
                           __FUNCTION__;
                           cmd = "write-proc-cfg";
                           msg =
                             Printf.sprintf
                               "No procedure in program with name %s:%s" proc
                               procs;
                         })
                  end
              in
              let p = ID.Map.find id (get_prog st).procs in
              Viscfg.Dot.output_graph c
                (Procedure.graph p |> Option.get_exn_or "procedure has no graph"));
          st
      | "dump-proc-il" ->
          let proc = List.hd (assert_atoms 1 args) in
          let id = (get_prog st).proc_names.get_id proc in
          let p = ID.Map.find id (get_prog st).procs in
          print_proc stdout p;
          st
      | "write-proc-il" ->
          let proc, ofile =
            assert_atoms 2 args |> function
            | [ proc; ofile ] -> (proc, ofile)
            | _ -> failwith "unreachable"
          in
          CCIO.with_out ofile (fun c ->
              let id = (get_prog st).proc_names.get_id proc in
              let p = ID.Map.find id (get_prog st).procs in
              print_proc c p);
          st
      | "dump-il" ->
          let ofile = List.hd @@ assert_atoms 1 args in
          CCIO.with_out ofile (fun c -> Program.pretty_to_chan c (get_prog st));
          st
      | "interp-out" ->
          let ofile = List.hd @@ assert_atoms 1 args in
          let prog = get_prog st in
          let main =
            ID.Map.find (Option.get_exn_or "no" prog.entry_proc) prog.procs
          in
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
            | Error st ->
                "ERROR STATE " ^ Lang.Interp.IState.show ~show_stack:true st
          in
          CCIO.with_out ofile (fun c -> output_string c ist);
          st
      | "run-transforms" ->
          let args = assert_atoms (List.length args) args in
          let ba = Bincaml.Passes.PassManager.batch_of_list args in
          let prog =
            Some (Bincaml.Passes.PassManager.run_batch ba (get_prog st))
          in
          { st with prog }
      | "run-transform" ->
          let args = assert_atoms 1 args in
          let ba = Bincaml.Passes.PassManager.batch_of_list args in
          let prog =
            Some (Bincaml.Passes.PassManager.run_batch ba (get_prog st))
          in
          { st with prog }
      | "list-passes" ->
          Bincaml.Passes.PassManager.print_passes
          |> Containers_pp.Pretty.to_string ~width:80
          |> print_endline;
          st
      | e -> failwith @@ "not a command : " ^ e)

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
