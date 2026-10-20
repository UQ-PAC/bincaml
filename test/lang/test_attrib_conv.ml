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
  @@ Containers_pp.Pretty.to_string ~width:120 (Lang.Attrib.attrib_pretty attrib);

  let parsed =
    Gtirb_frontend.Gtirb_attribs.gtirb_attribs_of_attrib_conv_exn attrib
  in
  print_endline @@ Gtirb_frontend.Gtirb_attribs.show_gtirb_attribs parsed;

  [%expect
    {|
    proc @main()  -> () { }


    [ block %ret [ return; ] ];
    prog entry @main {
      .initial_memory = [
        { .address = 4194872; .bytes = "TODO: bytes encoding"; .name = ".interp"; .readOnly = false; .size = 110; }; ];
      .symbols = {
        .externalFunctions = [ { .name = "_ITM_deregisterTMCloneTable"; .offset = 4325328; };
          { .name = "abort"; .offset = 4325392; }; ];
        .funcEntries = [ { .address = 4195968; .name = "_start"; .size = 480; }; ]; .globalOffsets = [ ];
        .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0; };
          { .address = 4325424; .name = "x"; .size = 64; }; ]; }; };
    {
      .initial_memory = [
        { .address = 4194872; .bytes = "TODO: bytes encoding"; .name = ".interp"; .readOnly = false; .size = 110; }; ];
      .symbols = {
        .externalFunctions = [ { .name = "_ITM_deregisterTMCloneTable"; .offset = 4325328; };
          { .name = "abort"; .offset = 4325392; }; ];
        .funcEntries = [ { .address = 4195968; .name = "_start"; .size = 480; }; ]; .globalOffsets = [ ];
        .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0; };
          { .address = 4325424; .name = "x"; .size = 64; }; ]; }; }
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
    {
      .initial_memory = [
        { .address = 4194872; .bytes = "TODO: bytes encoding"; .name = ".interp";
          .size = 110; }; ];
      .symbols = {
        .globals = [ { .address = 4324824; .name = "_DYNAMIC"; .size = 0; };
          { .address = 4325424; .name = "x"; .size = 64; }; ]; }; }
    |}]


let%expect_test "a" =
  let open Containers_pp in
  let open Containers.Fun.Infix in
  let d = bracket2 "[" (fill nl (List.init 100 (text % string_of_int))) "]" in
  Containers_pp.Pretty.to_format ~width:40 Format.std_formatter d;
  [%expect {|
    [
      0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
      16 17 18 19 20 21 22 23 24 25 26 27 28
      29 30 31 32 33 34 35 36 37 38 39 40 41
      42 43 44 45 46 47 48 49 50 51 52 53 54
      55 56 57 58 59 60 61 62 63 64 65 66 67
      68 69 70 71 72 73 74 75 76 77 78 79 80
      81 82 83 84 85 86 87 88 89 90 91 92 93
      94 95 96 97 98 99
    ]
    |}]

let%expect_test "b" =
  let open Containers_pp in
  let open Containers.Fun.Infix in
  let bracket2 l middle r =
    group( nest 2 (text l ^ sp ^ middle ^ nl ^ text r))
    in


  let d = bracket2 "[" (fill (char ';' ^ nl) (List.init 100 (text % string_of_int))) "]" in
  let keys = fill (char ',' ^ nl) (List.init 3 (fun i -> text (string_of_int i) ^ text " aaaaaaaaaaaaa = ") )in
  let d = bracket2 "{" (keys ^ d ^ keys) "}" in
  Containers_pp.Pretty.to_format ~width:40 Format.std_formatter d;
  [%expect {|
    { 0 aaaaaaaaaaaaa = , 1 aaaaaaaaaaaaa = ,
      2 aaaaaaaaaaaaa = [ 0; 1; 2; 3; 4; 5; 6;
        7; 8; 9; 10; 11; 12; 13; 14; 15; 16;
        17; 18; 19; 20; 21; 22; 23; 24; 25; 26;
        27; 28; 29; 30; 31; 32; 33; 34; 35; 36;
        37; 38; 39; 40; 41; 42; 43; 44; 45; 46;
        47; 48; 49; 50; 51; 52; 53; 54; 55; 56;
        57; 58; 59; 60; 61; 62; 63; 64; 65; 66;
        67; 68; 69; 70; 71; 72; 73; 74; 75; 76;
        77; 78; 79; 80; 81; 82; 83; 84; 85; 86;
        87; 88; 89; 90; 91; 92; 93; 94; 95; 96;
        97; 98; 99
        ]0 aaaaaaaaaaaaa = ,
      1 aaaaaaaaaaaaa = , 2 aaaaaaaaaaaaa =
      }
    |}]
