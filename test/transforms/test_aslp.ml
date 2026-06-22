open Lang
open Common
open Transforms.Aslp

let%expect_test "lift empty" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block (module I) ~address:(Bitvec.zero ~size:64) @@ Iter.empty
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None; stmts = []; succs = ["block_1"] }, "block_1"
      -> { Aslp_state.assume = None; stmts = []; succs = [] }; entry = "block_0";
      exit = "block_1" }
    |}]

let%expect_test "lift: add x1, x2, x3, lsl #4" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.zero ~size:64)
      (Bitvec.of_string "0x8b031041:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None;
           stmts =
           [var var_0:bv64 := R2:bv64; var var_1:bv64 := R3:bv64;
             var R1:bv64 := bvadd(var_0:bv64, bvshl(var_1:bv64, 0x4:bv12))];
           succs = ["block_1"] },
      "block_1" -> { Aslp_state.assume = None; stmts = []; succs = [] };
      entry = "block_0"; exit = "block_1" }
    |}]

let%expect_test "lift 2x: mov x1, #0xabcd" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block (module I) ~address:(Bitvec.zero ~size:64)
    @@ Iter.doubleton
         (Bitvec.of_string "0xd29579a1:bv32")
         (Bitvec.of_string "0xd29579a1:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None; stmts = [var R1:bv64 := 0xabcd:bv64];
           succs = ["block_1"] },
      "block_1" -> { Aslp_state.assume = None; stmts = []; succs = ["block_2"] },
      "block_2"
      -> { Aslp_state.assume = None; stmts = [var R1:bv64 := 0xabcd:bv64];
           succs = ["block_3"] },
      "block_3" -> { Aslp_state.assume = None; stmts = []; succs = [] };
      entry = "block_0"; exit = "block_3" }
    |}]

let%expect_test "lift: b.eq #1024" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.zero ~size:64)
      (Bitvec.of_string "0x54002000:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_state x;
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure f_gen_branch)
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from OfflineASL_pc__Aarch64_branch_conditional_cond.f_aarch64_branch_conditional_cond in file "lib/pc/aarch64_branch_conditional_cond.ml", line 42, characters 16-63
  Called from Transforms__Aslp.lift_opcode.(fun) in file "lib/transforms/aslp/aslp.ml", line 18, characters 6-67
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", lines 69-72, characters 4-42
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
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
