open Lang.Common
open Containers

let%expect_test "fold_block" =
  let block =
    {|
   block %main_entry [
      var R31_in:bv64 := 1000:bv64;
      var R0_in:bv64 := 1000:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R0_in:bv64) 32;
      unreachable;
      ]
    |}
  in
  let prog, proc, bl =
    Loader.Loadir.parse_single_block_proc ~proc:"test" block
  in
  CCIO.with_out "b.dot" (fun c ->
      Lang.Viscfg.Dot.fprint_graph (Format.of_chan c)
        (Lang.Procedure.graph proc |> Option.get_exn_or ""));
  let st, _ = Lang.Interp.run_prog prog in
  print_endline (Lang.Interp.IState.show st);
  ();
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  ( "Parse error:  :5\
   \n5 |       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R0_in:bv64) 32;\
   \n                                                        \027[1;31m^^^^^^^^\027[0m\
   \n")
  Raised at Loader__Loadir.protect_parse.parse in file "lib/loadir.ml", line 1152, characters 22-61
  Called from Loader__Loadir.load_single_block_proc in file "lib/loadir.ml", line 1160, characters 14-66
  Called from Expr_eval_expect__Interp.(fun) in file "test/lang/interp.ml", line 16, characters 4-60
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
  |}]
