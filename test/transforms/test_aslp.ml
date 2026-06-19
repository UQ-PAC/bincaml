open Lang
open Common
open Transforms.Aslp

let%expect_test "lift empty" =
  let bincaml_aslp_state = ref (Aslp_state.empty_lifter_state ()) in
  let module I = Bincaml_IBI (struct
    let bincaml_lifter_state = bincaml_aslp_state
  end) in
  let x =
    lift_code_block (module I) ~address:(Bitvec.zero ~size:64) @@ Iter.empty
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp.Aslp_state.blocks = "block_0"
      -> { Aslp.Aslp_state.assume = None; stmts = []; succs = ["block_1"] },
      "block_1" -> { Aslp.Aslp_state.assume = None; stmts = []; succs = [] };
      entry = "block_0"; exit = "block_1" }
    |}]

let%expect_test "lift: add x1, x2, x3, lsl #4" =
  let bincaml_aslp_state = ref (Aslp_state.empty_lifter_state ()) in
  let module I = Bincaml_IBI (struct
    let bincaml_lifter_state = bincaml_aslp_state
  end) in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.zero ~size:64)
      (Bitvec.of_string "0x8b031041:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp.Aslp_state.blocks = "block_0"
      -> { Aslp.Aslp_state.assume = None;
           stmts =
           [var var_0:bv64 := v__R2:bv64; var var_1:bv64 := v__R3:bv64;
             var v__R1:bv64 := bvadd(var_0:bv64, bvshl(var_1:bv64, 0x4:bv12))];
           succs = ["block_1"] },
      "block_1" -> { Aslp.Aslp_state.assume = None; stmts = []; succs = [] };
      entry = "block_0"; exit = "block_1" }
    |}]

let%expect_test "lift 2x: mov x1, #0xabcd" =
  let bincaml_aslp_state = ref (Aslp_state.empty_lifter_state ()) in
  let module I = Bincaml_IBI (struct
    let bincaml_lifter_state = bincaml_aslp_state
  end) in
  let x =
    lift_code_block (module I) ~address:(Bitvec.zero ~size:64)
    @@ Iter.doubleton
         (Bitvec.of_string "0xd29579a1:bv32")
         (Bitvec.of_string "0xd29579a1:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp.Aslp_state.blocks = "block_0"
      -> { Aslp.Aslp_state.assume = None;
           stmts = [var v__R1:bv64 := 0xabcd:bv64]; succs = ["block_1"] },
      "block_1"
      -> { Aslp.Aslp_state.assume = None; stmts = []; succs = ["block_2"] },
      "block_2"
      -> { Aslp.Aslp_state.assume = None;
           stmts = [var v__R1:bv64 := 0xabcd:bv64]; succs = ["block_3"] },
      "block_3" -> { Aslp.Aslp_state.assume = None; stmts = []; succs = [] };
      entry = "block_0"; exit = "block_3" }
    |}]

let%expect_test "aslp integration basic" =
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
