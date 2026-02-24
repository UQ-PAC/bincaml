open Analysis.Gamma_domain
open Bincaml_util.Common

let intra_results proc = Analysis.analyse proc

let print_intra_results res =
  Analysis.A.M.find Procedure.Vert.Return res |> Domain.show |> print_endline

let%expect_test "loop" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);

prog entry @main;

proc @main () -> ()
[
    block %main_entry [
        goto(%main_1, %main_2);
    ];
    block %main_1 [
        $x:bv64 := bvadd($x:bv64, $a:bv64);
        goto(%main_return);
    ];
    block %main_2 [
        $x:bv64 := bvadd($x:bv64, $b:bv64);
        goto(%main_entry, %main_return);
    ];
    block %main_return [
        return();
    ];
];
    |}
  in
  let prog = lst.prog in
  let main =
    prog.entry_proc |> Option.get_exn_or "No entry proc" |> Program.proc prog
  in
  let intra = intra_results main in
  print_intra_results intra;
  [%expect {| ($x->{$x,$a,$b}, $a->{$a}, $b->{$b}, _->⊥) |}]
