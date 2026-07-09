open Bincaml_util.Common

let simpletest () = ()


let tests =
  [
    ("simpletest", simpletest);
  ]
  |> List.map (fun (n, t) -> Alcotest.test_case n `Quick t)
  |> fun cases -> [ ("highest_live_bit", cases) ]
