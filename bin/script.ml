open Containers
open Lang

exception Parse

let print_proc chan p = Program.output_proc_pretty chan p

let assert_atoms n args =
  assert (List.length args = n);
  List.map (function `Atom n -> n | _ -> failwith "expected atom") args

type dsl_st = { prog : Program.t option }

let init_st = { prog = None }
let get_prog s = Option.get_exn_or "no program loaded" s.prog

let of_cmd st (e : Containers.Sexp.t) =
  let cmd, args =
    match e with
    | `List [] -> ("skip", [])
    | `List (`Atom cmd :: n) -> (cmd, n)
    | _ -> failwith "bad cmd structure"
  in
  match cmd with
  | "skip" -> st
  | "load-il" ->
      let fname = List.hd (assert_atoms 1 args) in
      let p = Ocaml_of_basil.Loadir.ast_of_fname fname in
      { prog = Some p.prog }
  | "list-procs" ->
      let open Program in
      Lang.ID.Map.iter
        (fun i _ -> Printf.printf "%s\n" (ID.show i))
        (get_prog st).procs;
      st
  | "dump-proc-il" ->
      let proc = List.hd (assert_atoms 1 args) in
      let id = (get_prog st).proc_names.get_id proc in
      let p = Lang.ID.Map.find id (get_prog st).procs in
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
          let p = Lang.ID.Map.find id (get_prog st).procs in
          print_proc c p);
      st
  | "write-il" ->
      let ofile = List.hd @@ assert_atoms 1 args in
      CCIO.with_out ofile (fun c -> Program.pretty_to_chan c (get_prog st));
      st
  | "run-transforms" ->
      let args = assert_atoms (List.length args) args in
      let ba = Ocaml_of_basil.Passes.PassManager.batch_of_list args in
      Ocaml_of_basil.Passes.PassManager.run_batch ba (get_prog st);
      st
  | "run-transform" ->
      let args = assert_atoms 1 args in
      let ba = Ocaml_of_basil.Passes.PassManager.batch_of_list args in
      Ocaml_of_basil.Passes.PassManager.run_batch ba (get_prog st);
      st
  | e -> failwith @@ "not a command : " ^ e

let of_str st (e : string) =
  let str_comment =
    try String.index_from e 0 ';' with Not_found -> String.length e
  in
  let e = String.sub e 0 str_comment in
  let s = match e with "" -> Ok (`List []) | e -> CCSexp.parse_string e in
  let s =
    match s with
    | Ok e -> e
    | Error err ->
        let m = "failed to parse " ^ e ^ ": " ^ err in
        failwith m
  in
  of_cmd st s
