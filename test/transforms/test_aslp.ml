open Lang
open Common
open Transforms.Aslp

let%expect_test "lift empty" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block (module I) ~address:(Bitvec.zero ~size:64) @@ Iter.empty
  in
  print_endline @@ Aslp_state.show_aslp_diamond x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None;
           stmts =
           [($PC:bv64 := bvadd($PC, 0x4:bv32), var BranchTaken:bool := false)];
           succs = []; has_pc_assign = true };
      entry = "block_0"; exit = "block_0" }
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
  print_endline @@ Aslp_state.show_aslp_diamond x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None;
           stmts =
           [var var_0:bv64 := $R2; var var_1:bv64 := $R3;
             $R1:bv64 := bvadd(var_0:bv64, bvshl(var_1:bv64, 0x4:bv12));
             ($PC:bv64 := bvadd($PC, 0x4:bv32), var BranchTaken:bool := false)];
           succs = []; has_pc_assign = true };
      entry = "block_0"; exit = "block_0" }
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
  print_endline @@ Aslp_state.show_aslp_diamond x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None;
           stmts =
           [$R1:bv64 := 0xabcd:bv64;
             ($PC:bv64 := bvadd($PC, 0x4:bv32), var BranchTaken:bool := false)];
           succs = ["block_1"]; has_pc_assign = true },
      "block_1"
      -> { Aslp_state.assume = None;
           stmts =
           [$R1:bv64 := 0xabcd:bv64;
             ($PC:bv64 := bvadd($PC, 0x4:bv32), var BranchTaken:bool := false)];
           succs = []; has_pc_assign = true };
      entry = "block_0"; exit = "block_1" }
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
  print_endline @@ Aslp_state.show_aslp_diamond x;
  [%expect
    {|
    { Aslp_state.blocks = "block_0"
      -> { Aslp_state.assume = None; stmts = []; succs = ["block_1"; "block_2"];
           has_pc_assign = false },
      "block_1"
      -> { Aslp_state.assume = (Some eq($PSTATE_Z, 0x1:bv1));
           stmts = [var BranchTaken:bool := true; $PC:bv64 := 0x400:bv64];
           succs = ["block_3"]; has_pc_assign = true },
      "block_2"
      -> { Aslp_state.assume = (Some boolnot(eq($PSTATE_Z, 0x1:bv1)));
           stmts =
           [($PC:bv64 := bvadd($PC, 0x4:bv32), var BranchTaken:bool := false)];
           succs = ["block_3"]; has_pc_assign = true },
      "block_3"
      -> { Aslp_state.assume = None; stmts = []; succs = []; has_pc_assign = true
           };
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
