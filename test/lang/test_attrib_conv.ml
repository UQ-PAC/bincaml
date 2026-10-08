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
    .bytes = "TODO: bytes encoding";
  };
]
} ; |}
  in
  let prog = ast.prog in
  let attrib = `Assoc (Lang.Program.attrib prog) in

  Lang.Program.pretty_to_chan stdout prog;
  print_endline "";
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Attrib.attrib_pretty attrib);

  let parsed =
    Gtirb_frontend.Gtirb_attribs.gtirb_attribs_of_attrib_conv_exn attrib
  in
  print_endline @@ Gtirb_frontend.Gtirb_attribs.show_gtirb_attribs parsed;

  [%expect
    {|
    proc @main()  -> () {  }


    [ block %ret [ return; ] ];
    prog entry @main;
    { .initial_memory = [ { .address = 4194872; .bytes = "TODO: bytes encoding";
                .name = ".interp"; .readOnly = false; .size = 110 } ];
        .symbols = { .externalFunctions = [ { .name = "_ITM_deregisterTMCloneTable";
                    .offset = 4325328 }; { .name = "abort"; .offset = 4325392 } ];
            .funcEntries = [ { .address = 4195968; .name = "_start"; .size = 480 } ];
            .globalOffsets = [  ];
            .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0 };
                { .address = 4325424; .name = "x"; .size = 64 } ] } }
    { Gtirb_attribs.symbols =
      { Gtirb_attribs.external_functions = [];
        globals =
        [{ Gtirb_attribs.name = "_DYNAMIC"; address = 4324824L; size = 0L };
          { Gtirb_attribs.name = "x"; address = 4325424L; size = 64L }];
        func_entries = []; global_offsets = [] };
      initial_memory =
      [{ Gtirb_attribs.name = ".interp"; address = 4194872L; size = 110L;
         read_only = false; bytes = "TODO: bytes encoding" }
        ]
      }
    |}]

let%expect_test "adt to attrib" =
  let parsed =
    {
      Gtirb_frontend.Gtirb_attribs.symbols =
        {
          external_functions = [];
          globals =
            [
              { name = "_DYNAMIC"; address = 4324824L; size = 0L };
              { name = "x"; address = 4325424L; size = 64L };
            ];
          func_entries = [];
          global_offsets = [];
        };
      initial_memory =
        [
          {
            name = ".interp";
            address = 4194872L;
            size = 110L;
            read_only = false;
            bytes = "TODO: bytes encoding";
          };
        ];
    }
  in

  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80
  @@ Lang.Attrib.attrib_pretty
  @@ Gtirb_frontend.Gtirb_attribs.gtirb_attribs_to_attrib_conv parsed;
  [%expect
    {|
    { .initial_memory = [ { .address = 4194872; .bytes = "TODO: bytes encoding";
                .name = ".interp"; .size = 110 } ];
        .symbols = { .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0 };
                { .address = 4325424; .name = "x"; .size = 64 } ] } }
    |}]
