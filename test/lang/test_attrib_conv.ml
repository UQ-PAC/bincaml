let%expect_test "attrib to adt" =
  let ast =
    Loader.Loadir.ast_of_string
      {|
proc @main() -> () [ block %ret [ return; ] ];

prog entry @main {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x41ffd0 };
      { .name = "abort"; .offset = 0x420010 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x41fdd8; .size = 0x0 };
      { .name = "x"; .address = 0x420030; .size = 0x40 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x400680; .size = 0x1e0 };
    ];
    .globalOffsets = [  ]
  };
  .initial_memory = [
  {
    .name = ".interp";
    .address = 0x400238;
    .size = 0x6e;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/y3KSxKDIAwA0F4oRDuIXAdthQwx+AMZT68L1++hUMX9SNsfy0V06thGtnZZi+4lsL8m280lyEAOPNMwgnPb";
      "GIyGLFHSKcAkuYKXDF+lGzAGn4b8e+Htak+q/dy2zzwDbgAAAA=="
    ]
  };
]
} ; |}
  in
  let prog = ast.prog in

  let attrib = `Assoc (Lang.Program.attrib prog) in

  Lang.Program.pretty_to_chan stdout prog;
  print_endline "";
  print_endline @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Attrib.attrib_pretty attrib);

  let parsed = Gtirb_frontend.Gtirb_attribs.gtirb_attribs_of_attrib_conv_exn attrib in
  print_endline @@Gtirb_frontend.Gtirb_attribs.show_gtirb_attribs parsed;

  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  ( "Missing record field: symbols. Got: { .initial_memory = [ { .address = 4194872;\
   \n            .bytes = [ \"H4sIAAAAAAAA/y3KSxKDIAwA0F4oRDuIXAdthQwx+AMZT68L1++hUMX9SNsfy0V06thGtnZZi+4lsL8m280lyEAOPNMwgnPb\";\
   \n                \"GIyGLFHSKcAkuYKXDF+lGzAGn4b8e+Htak+q/dy2zzwDbgAAAA==\" ];\
   \n            .name = \".interp\"; .readOnly = false; .size = 110 } ];\
   \n    .symbols = { .externalFunctions = [ { .name = \"_ITM_deregisterTMCloneTable\";\
   \n                .offset = 4325328 }; { .name = \"abort\"; .offset = 4325392 } ];\
   \n        .funcEntries = [ { .address = 4195968; .name = \"_start\"; .size = 480 } ];\
   \n        .globalOffsets = [  ];\
   \n        .globals = [ { .address = 4324824; .name = \"_DYNAMIC\"; .size = 0 };\
   \n            { .address = 4325424; .name = \"x\"; .size = 64 } ] } }")
  Raised at Ppx_protocol_driver.Make.wrap in file "drivers/generic/ppx_protocol_driver.ml", line 111, characters 43-77
  Called from Test_expr_eval_expect__Test_attrib_conv.(fun) in file "test/lang/test_attrib_conv.ml", line 44, characters 15-83
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  proc @main()  -> () {  }


  [ block %ret [ return; ] ];
  prog entry @main;
  { .initial_memory = [ { .address = 4194872;
              .bytes = [ "H4sIAAAAAAAA/y3KSxKDIAwA0F4oRDuIXAdthQwx+AMZT68L1++hUMX9SNsfy0V06thGtnZZi+4lsL8m280lyEAOPNMwgnPb";
                  "GIyGLFHSKcAkuYKXDF+lGzAGn4b8e+Htak+q/dy2zzwDbgAAAA==" ];
              .name = ".interp"; .readOnly = false; .size = 110 } ];
      .symbols = { .externalFunctions = [ { .name = "_ITM_deregisterTMCloneTable";
                  .offset = 4325328 }; { .name = "abort"; .offset = 4325392 } ];
          .funcEntries = [ { .address = 4195968; .name = "_start"; .size = 480 } ];
          .globalOffsets = [  ];
          .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0 };
              { .address = 4325424; .name = "x"; .size = 64 } ] } }
  |}]
