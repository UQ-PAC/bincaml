open Bincaml_util.Common
open Lang

let%expect_test "fold_block" =
  let block =
    {|
memory shared $mem : (bv64 -> bv8);
var $CF: bv1;
var $NF: bv1;
var $R0: bv64;
var $R1: bv64;
var $R30: bv64;
var $VF: bv1;
var $ZF: bv1;
var $_PC: bv64;

prog entry @main_4196260;

proc @main_4196260 () -> ()
[
  block %main_entry [
    $_PC:bv64 := 0x4007c0:bv64;
    $NF:bv1 := 1:bv1;
    $ZF:bv1 := 1:bv1;
    goto(%main_7, %main_11);
  ];
  block %main_3  [
    assert eq($_PC:bv64, 0x4007c0:bv64);
    $R1:bv64 := 0:bv64;
    goto(%main_basil_return_1);
  ];
  block %main_5 [
    $R0:bv64 := 0:bv64;
    goto(%main_3);
  ];
  block %main_7 [
    guard eq($ZF:bv1, 0x1:bv1);
    $R30:bv64 := 1:bv64;
    goto(%main_5);
  ];
  block %main_9  [
    $R0:bv64 := 0:bv64;
    goto(%main_3);
  ];
  block %main_11 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $R0:bv64 := 0:bv64;
    goto(%main_9);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];

    |}
  in
  let lst =
    Loader.Loadir.ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__ block
  in
  let prog = lst.prog in
  let ba = Bincaml.Passes.PassManager.batch_of_list [ "ssa" ] in
  let prog = Bincaml.Passes.PassManager.run_batch ba prog in
  let proc = Program.proc prog (prog.entry_proc |> Option.get_exn_or "fail") in
  let ar = Analysis.Defuse_bool.analyse proc in

  let f =
    Analysis.Defuse_bool.Analysis.D.to_iter ar
    |> Iter.filter (function v, _ ->
        String.ends_with ~suffix:"_out" (Var.name v))
    |> Iter.to_string ~sep:"\n" (fun (k, v) ->
        Printf.sprintf "%s->%s" (Var.name k)
          (Analysis.Defuse_bool.IsZeroLattice.show v))
  in
  print_endline f;
  [%expect
    {|
    R30_out->Top
    NF_out->NonZero
    CF_out->Top
    VF_out->Top
    R0_out->Zero
    R1_out->Zero
    ZF_out->NonZero
    _PC_out->NonZero
    |}]
