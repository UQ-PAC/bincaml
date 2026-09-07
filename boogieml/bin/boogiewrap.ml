open Containers
open Boogieml

let () =
  let a = Sys.argv |> Array.to_list |> List.tl |> String.concat " " in
  format_result Format.stdout (run_boogie a)
