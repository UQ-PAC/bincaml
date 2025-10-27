open Cmdliner
open Lang.Prog

let check fname =
  let p = Ocaml_of_basil.Loadir.ast_of_fname fname in
  ID.Map.iter
    (fun _ (p : Procedure.t) ->
      Lang.Livevars.print_live_vars_dot Format.std_formatter p)
    p.prog.procs

let fname =
  let doc = "Input file name (filename.il)" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FNAME" ~doc)

let check_f = Term.(const check $ fname)

let cmd =
  let doc = "obasil" in
  let info = Cmd.info "obasil" ~version:"alpha" ~doc in
  Cmd.v info check_f

let rec test_print_1 ~(depth : int) () =
  Format.open_hvbox 2;

  Format.print_string "asd";
  Format.print_string "(";
  Format.print_cut ();

  Format.print_string "larg,";
  Format.print_space ();

  if depth > 0 then begin
    let depth = depth - 1 in
    test_print_1 ~depth ();
    Format.print_string ",";
    Format.print_space ();
  end;

  Format.print_string "larg";
  Format.print_string ")";

  Format.close_box ()


let main () =
  Format.set_margin 80;
  Format.set_max_indent 79;
  test_print_1 ~depth:100 ();
  Format.print_newline ();
  exit (Cmd.eval cmd)
let () = main ()
