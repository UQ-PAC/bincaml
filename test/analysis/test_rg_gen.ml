open Bincaml_util.Common
open Lang
open Expr

(*
let prog_str =
{|
prog entry @dummy;

memory shared $x: bv32;

proc @dummy () -> ()
[
  block %entry [];
  block %ret [ return (); ]
];

proc @t1 () -> ()
[
  block %entry [
    $x := bvadd($x, 0x1:bv32);
    goto(%ret);
  ];
  block %ret [
    return ();
  ]
];

proc @t2 () -> ()
[
  block %entry [
    $x := bvadd($x, 0x2:bv32);
    goto(%ret);
  ];
  block %ret [
    return ();
  ]
];
|}
in
let ast = Loader.Loadir.ast_of_string prog_str in
let program = ast.prog in
let entry_id = Procedure.id @@ Program.entry_proc_exn program in
let threads = Lang.Program.procs program |> Iter.filter (fun (id, _) -> not @@ ID.equal id entry_id) in

let tests = [
  ("simple", simple)
]
|> List.map (fun (n, t) -> Alcotest.test_case n `Quick t)
|> fun cases -> [ ("rg_gen", cases) ] *)
