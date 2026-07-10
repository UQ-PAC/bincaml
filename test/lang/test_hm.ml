open Lang
open Common
open Hm.Inference

let%expect_test "return type of function" =
  let open Types in
  let args = [ Bitvector 64 ] in
  let ft = Map (Bitvector 64, Map (Bitvector 64, Bitvector 64)) in
  Printf.printf "function type: %s\n" (Types.to_string ft);
  let _, ort = Types.uncurry ft in
  Printf.printf "uncurry ret type: %s\n" (Types.to_string ort);
  Format.force_newline ();
  Format.printf "%s%a%a" "partially apply bv64: " (Result.pp Types.pp)
    (type_applied ft args) Format.newline ();
  Format.printf "%s%a%a" "type error: " (Result.pp Types.pp)
    (type_applied ft [ Bitvector 24 ])
    Format.newline ();
  [%expect
    {|
    function type: ((bv64)->(bv64->bv64))
    uncurry ret type: bv64

    partially apply bv64: ok((bv64->bv64))
    type error: error(type_error: 64 <> 24)
    |}]
