open Containers

let preamble =
  {|
(rule
 (alias runtest)
 (package %PACKAGE%)
 (deps %DEPS% %INPUT%)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to %OUT% (run %ACTION%)))
    (diff? %EXPECT% %OUT%)
)))

|}

let usage_msg = "util_expect -action \"bincaml load-ir ARG\" <file1> [<file2>]"
let input_files = ref []
let action = ref ""
let package = ref "bincaml"
let deps = ref "%{bin:bincaml}"
let anon_fun filename = input_files := filename :: !input_files

let to_rule fname =
  let expected = fname ^ ".expected" in
  let output = fname ^ ".out" in
  let action = String.replace ~which:`All ~by:fname ~sub:"ARG" !action in
  print_endline "";
  preamble
  |> String.replace ~which:`All ~by:fname ~sub:"%INPUT%"
  |> String.replace ~which:`All ~by:!deps ~sub:"%DEPS%"
  |> String.replace ~which:`All ~by:expected ~sub:"%EXPECT%"
  |> String.replace ~which:`All ~by:output ~sub:"%OUT%"
  |> String.replace ~which:`All ~by:action ~sub:"%ACTION%"
  |> String.replace ~which:`All ~by:!package ~sub:"%PACKAGE%"
  |> print_endline

let speclist =
  [
    ("-action", Arg.Set_string action, "Set output file name");
    ("-package", Arg.Set_string package, "Set package");
    ("-deps", Arg.Set_string package, "Set extra deps");
  ]
  |> Arg.align

let () =
  let () = Arg.parse speclist anon_fun usage_msg in
  if String.equal !action "" then begin
    Arg.usage speclist "gen_expect error: -action must be provided.";
    exit 1
  end;
  List.iter to_rule !input_files
