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

  Lang.Program.pretty_to_chan stdout prog;
  ();
  [%expect
    {|
    proc @main()  -> () {  }


    [ block %ret [ return; ] ];
    prog entry @main;
    |}]
