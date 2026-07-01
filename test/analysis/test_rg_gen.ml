open Bincaml_util.Common
open Lang
open Expr
open Analysis.Rg_gen

let prog_str =
{|
prog entry @dummy;

memory shared $x: bv32;

proc @dummy () -> ()
[
  block %entry [ goto(%ret); ];
  block %ret [ return (); ]
];

proc @t1 () -> ()
[
  block %entry [
    assume eq($x, 0);
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
    assume eq($x, 1);
    $x := bvadd($x, 0x2:bv32);
    goto(%ret);
  ];
  block %ret [
    return ();
  ]
];
|}

let simple () =
  let ast = Loader.Loadir.ast_of_string prog_str in
  let program = ast.prog in
  let entry_id = Procedure.id @@ Program.entry_proc_exn program in
  let threads = Lang.Program.procs program
    (* get a list of all program procedures that are not the entry proc *)
    |> Iter.fold (fun acc (id, proc) -> if (ID.equal id entry_id) then acc else proc :: acc) []
  in
  let module I = ConditionalWritesDomain(InterferenceWrappedIntervalDomain) in
  let module Generator = RelyGuaranteeGenerator(I) in
  let guars = Generator.generate_rg_conditions threads in
  guars |> List.iter (fun (proc, guar) ->
    print_endline @@ ID.name (Procedure.id proc) ^ ":";
    print_endline @@ I.show guar ^ "\n"
  )

let tests = [
  ("simple", simple)
]
|> List.map (fun (n, t) -> Alcotest.test_case n `Quick t)
|> fun cases -> [ ("rg_gen", cases) ]
