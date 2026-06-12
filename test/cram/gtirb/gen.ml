

open Containers

let to_rule fname =
  let oname = fname ^ "-initial-gts.expected" in
  let name = fname ^ ".gts" in
  let x = Printf.sprintf {|
        (progn
            (bash "mkdir -p $(dirname %s)")
            (with-stdout-to "%s.gen" (bash "./run.sh %s"))
            (diff "%s" "%s.gen")
        )
  |} oname oname name oname oname
  in
  print_endline x


let preamble = {|
(rule
 (alias runtest)
 (deps
  %{bin:bincaml}
  (source_tree  ../../../examples/gtirb)
  run.sh
  )
 (action
  (no-infer
   (progn
    (bash pwd)
    (bash "mkdir out")
|}



let () =
  print_endline preamble ;
  print_endline "    (concurrent";
  (CCIO.File.walk_l "../../../examples/gtirb/basil"
  |> List.filter_map (function `File, f -> Some f | _ -> None)
  |> List.filter_map (Filename.chop_suffix_opt ~suffix:".gts")
  |> List.sort String.compare
  |> List.iter to_rule );
   print_endline "    )";
   print_endline  "))))"
