open Lang
open Common

let%expect_test "aslp basic" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $PC:bv64;
prog entry @main;

proc @main()  -> () {  }
  requires boolor(eq(0x400808:bv64, $PC))
[
  block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
      .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
              .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
    assume eq(0x400808:bv64, $PC);
    assert false { .opcode = "0xa9be7bfd" };
    assert false { .opcode = "0x910003fd" };
    assert false { .opcode = "0xb9001fe0" };
    assert false { .opcode = "0xf9000be1" };
    assert false { .opcode = "0xb9801fe0" };
    assert false { .opcode = "0x97ffffda" };
    assert boolor(eq(0x400784:bv64, $PC));
    goto (%ret_1);
  ];
  block %ret_1 [ return; ]
];
    |}
  in
  let prog = lst.prog in
  let _proc = Lang.Program.entry_proc_exn prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $PC:bv64;
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x400808:bv64, $PC))

    [
       block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                   .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
         assume eq(0x400808:bv64, $PC);
         assert false { .opcode = "0xa9be7bfd" };
         assert false { .opcode = "0x910003fd" };
         assert false { .opcode = "0xb9001fe0" };
         assert false { .opcode = "0xf9000be1" };
         assert false { .opcode = "0xb9801fe0" };
         assert false { .opcode = "0x97ffffda" };
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    prog entry @main;
    |}]
