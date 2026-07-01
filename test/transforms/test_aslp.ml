open Lang
open Common
open Transforms.Aslp

let%expect_test "lift empty" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block (module I) ~address:(Bitvec.of_int ~size:64 0x2000) []
  in
  List.iter (print_endline % Aslp_state.show_aslp_diamond) x;
  [%expect {| |}]

let%expect_test "lift: add x1, x2, x3, lsl #4" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.of_int ~size:64 0x2000)
      (Bitvec.of_string "0x8b031041:bv32")
  in
  List.iter (print_endline % Aslp_state.show_aslp_diamond) [ x ];
  [%expect
    {|
    (Leaf
       { Aslp_state.assume = true;
         stmts =
         [var var_0:bv64 := $R2; var var_1:bv64 := $R3;
           $R1:bv64 := bvadd(var_0:bv64, bvshl(var_1:bv64, 0x4:bv12));
           (var BranchTaken:bool := false, $PC:bv64 := 0x2004:bv64)];
         pc_assign = (Some 0x2004:bv64) })
    |}]

let%expect_test "lift 2x: mov x1, #0xabcd" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block
      (module I)
      ~address:(Bitvec.of_int ~size:64 0x2000)
      [ Bitvec.of_string "0xd29579a1:bv32"; Bitvec.of_string "0xd29579a1:bv32" ]
  in
  List.iter (print_endline % Aslp_state.show_aslp_diamond) x;
  [%expect
    {|
    (Leaf
       { Aslp_state.assume = true;
         stmts =
         [$R1:bv64 := 0xabcd:bv64;
           (var BranchTaken:bool := false, $PC:bv64 := 0x2004:bv64)];
         pc_assign = (Some 0x2004:bv64) })
    (Leaf
       { Aslp_state.assume = true;
         stmts =
         [$R1:bv64 := 0xabcd:bv64;
           (var BranchTaken:bool := false, $PC:bv64 := 0x2008:bv64)];
         pc_assign = (Some 0x2008:bv64) })
    |}]

let%expect_test "lift: b.eq #1024" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.of_int ~size:64 0x2000)
      (Bitvec.of_string "0x54002000:bv32")
  in
  print_endline @@ Aslp_state.show_aslp_diamond x;
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", line 63, characters 4-34
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.f_switch_context in file "lib/transforms/aslp/bincaml_ibi_make.ml", line 71, characters 4-29
  Called from OfflineASL_pc__Aarch64_branch_conditional_cond.f_aarch64_branch_conditional_cond in file "lib/pc/aarch64_branch_conditional_cond.ml", line 43, characters 2-48
  Called from Transforms__Aslp.lift_opcode.(fun) in file "lib/transforms/aslp/aslp.ml", line 27, characters 6-67
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", lines 65-68, characters 4-42
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
  |}]

let%expect_test "lift: b #16" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_opcode
      (module I)
      ~address:(Bitvec.of_int ~size:64 0x2000)
      (Bitvec.of_string "0x8b031041:bv32")
  in
  List.iter (print_endline % Aslp_state.show_aslp_diamond) [ x ];
  [%expect
    {|
    (Leaf
       { Aslp_state.assume = true;
         stmts =
         [var var_0:bv64 := $R2; var var_1:bv64 := $R3;
           $R1:bv64 := bvadd(var_0:bv64, bvshl(var_1:bv64, 0x4:bv12));
           (var BranchTaken:bool := false, $PC:bv64 := 0x2004:bv64)];
         pc_assign = (Some 0x2004:bv64) })
    |}]

let%expect_test "aslp integration basic" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);
var $PC:bv64;
prog entry @main;

proc @main()  -> () {  }
  requires boolor(eq(0x400808:bv64, $PC))
[
      block %main_code { .address = 0x400808; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
      .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
              .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
    assume eq(0x400808:bv64, $PC);
    call @_aarch64_eval(0xa9be7bfd:bv32) { .asm = "stp x29, x30, [sp, #-0x20]!" };
    call @_aarch64_eval(0x910003fd:bv32) { .asm = "mov x29, sp" };
    call @_aarch64_eval(0xb9001fe0:bv32) { .asm = "str w0, [sp, #0x1c]" };
    call @_aarch64_eval(0xf9000be1:bv32) { .asm = "str x1, [sp, #0x10]" };
    call @_aarch64_eval(0xb9801fe0:bv32) { .asm = "ldrsw x0, [sp, #0x1c]" };
    call @_aarch64_eval(0x97ffffda:bv32) { .asm = "bl #0xffffffffffffff68" };
    assert boolor(eq(0x400784:bv64, $PC));
    goto (%ret_1);
  ];
  block %ret_1 [ return; ]
];
    |}
  in
  let prog = transform_program lst.prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var observable $mem:(bv64->bv8);
    var $PC:bv64;
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x400808:bv64, $PC))

    [
       block %main_code { .address = 4196360; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                   .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
         assume eq(0x400808:bv64, $PC);
         goto (%block);
       ];
       block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
         guard true;
         var var:bv64 := $SP;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
          0xffffffffffffffe0:bv64) $R29 8;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
           0xffffffffffffffe0:bv64), 0x8:bv64) $R30 8;
         $SP:bv64 := bvadd(var:bv64, 0xffffffffffffffe0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0x40080c:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "mov x29, sp" } [
         guard true;
         $R29:bv64 := bvadd($SP, 0x0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0x400810:bv64);
         goto (%block_2);
       ];
       block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
         guard true;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) extract(-32,0, $R0) 4;
         (var BranchTaken:bool := false, $PC:bv64 := 0x400814:bv64);
         goto (%block_3);
       ];
       block %block_3 { .asm = "str x1, [sp, #0x10]" } [
         guard true;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x10:bv64) $R1 8;
         (var BranchTaken:bool := false, $PC:bv64 := 0x400818:bv64);
         goto (%block_4);
       ];
       block %block_4 { .asm = "ldrsw x0, [sp, #0x1c]" } [
         guard true;
         $mem:(bv64->bv8) := load le var_3:bv4 bvadd($SP, 0x1c:bv64) 4;
         var var_2:bv32 := var_3:bv4;
         $R0:bv64 := zero_extend(0, sign_extend(32, var_2:bv32));
         (var BranchTaken:bool := false, $PC:bv64 := 0x40081c:bv64);
         goto (%block_5);
       ];
       block %block_5 { .asm = "bl #0xffffffffffffff68" } [
         guard true;
         $R30:bv64 := 0x400820:bv64;
         var BranchTaken:bool := true;
         $PC:bv64 := 0x400784:bv64;
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    var $SP:bv64;
    var $R0:bv64;
    var $R1:bv64;
    var $R2:bv64;
    var $R3:bv64;
    var $R4:bv64;
    var $R5:bv64;
    var $R6:bv64;
    var $R7:bv64;
    var $R8:bv64;
    var $R9:bv64;
    var $R10:bv64;
    var $R11:bv64;
    var $R12:bv64;
    var $R13:bv64;
    var $R14:bv64;
    var $R15:bv64;
    var $R16:bv64;
    var $R17:bv64;
    var $R18:bv64;
    var $R19:bv64;
    var $R20:bv64;
    var $R21:bv64;
    var $R22:bv64;
    var $R23:bv64;
    var $R24:bv64;
    var $R25:bv64;
    var $R26:bv64;
    var $R27:bv64;
    var $R28:bv64;
    var $R29:bv64;
    var $R30:bv64;
    var $Z0:bv128;
    var $Z1:bv128;
    var $Z2:bv128;
    var $Z3:bv128;
    var $Z4:bv128;
    var $Z5:bv128;
    var $Z6:bv128;
    var $Z7:bv128;
    var $Z8:bv128;
    var $Z9:bv128;
    var $Z10:bv128;
    var $Z11:bv128;
    var $Z12:bv128;
    var $Z13:bv128;
    var $Z14:bv128;
    var $Z15:bv128;
    var $Z16:bv128;
    var $Z17:bv128;
    var $Z18:bv128;
    var $Z19:bv128;
    var $Z20:bv128;
    var $Z21:bv128;
    var $Z22:bv128;
    var $Z23:bv128;
    var $Z24:bv128;
    var $Z25:bv128;
    var $Z26:bv128;
    var $Z27:bv128;
    var $Z28:bv128;
    var $Z29:bv128;
    var $Z30:bv128;
    var $FPSR:bv64;
    var $FPCR:bv64;
    var $PSTATE_C:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_V:bv1;
    var $PSTATE_N:bv1;
    var $PSTATE_A:bv1;
    var $PSTATE_D:bv1;
    var $PSTATE_DIT:bv1;
    var $PSTATE_F:bv1;
    var $PSTATE_I:bv1;
    var $PSTATE_PAN:bv1;
    var $PSTATE_SP:bv1;
    var $PSTATE_SSBS:bv1;
    var $PSTATE_TCO:bv1;
    var $PSTATE_UAO:bv1;
    var $PSTATE_BTYPE:bv1;
    var $ExclusiveLocal:bool;
    prog entry @main;
    |}]

let%expect_test "aslp integration with branching" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);
var $PC:bv64;
prog entry @Sqrt;

proc @Sqrt()  -> () {  }
[
  block %Sqrt_code_4 { .address = 0x4007dc; } [
    assume eq(0x4007dc:bv64, $PC);
    call @_aarch64_eval(0x5400008b:bv32) { .asm = "b.lt #0x10" };
    assert boolor(eq(0x4007fc:bv64, $PC), eq(0x4007e0:bv64, $PC));
    goto (%Sqrt_code_3,%Sqrt_code);
  ];
  block %Sqrt_code [
    assume eq(0x4007e0:bv64, $PC);
    goto (%ret);
  ];
  block %Sqrt_code_3 [
    assume eq(0x4007fc:bv64, $PC);
    goto (%ret);
  ];
  block %ret [ return; ]
];
    |}
  in
  let prog = transform_program lst.prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", line 63, characters 4-34
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.f_switch_context in file "lib/transforms/aslp/bincaml_ibi_make.ml", line 71, characters 4-29
  Called from OfflineASL_pc__Aarch64_branch_conditional_cond.f_aarch64_branch_conditional_cond in file "lib/pc/aarch64_branch_conditional_cond.ml", line 43, characters 2-48
  Called from Transforms__Aslp.lift_opcode.(fun) in file "lib/transforms/aslp/aslp.ml", line 27, characters 6-67
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Stdlib__List.mapi in file "list.ml", line 93, characters 15-21
  Called from Transforms__Aslp.transform_block in file "lib/transforms/aslp/aslp.ml", line 172, characters 19-62
  Called from Iter.fold.(fun) in file "src/Iter.ml", line 77, characters 23-31
  Called from Stdlib__Set.Make.iter in file "set.ml", line 379, characters 35-38
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 20-25
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 10-18
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 10-18
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 10-18
  Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
  Called from Lang__Program.map_procedures.(fun) in file "lib/lang/program.ml", line 136, characters 63-77
  Called from Stdlib__Map.Make.mapi in file "map.ml", line 321, characters 19-24
  Called from Stdlib__Map.Make.mapi in file "map.ml", line 322, characters 19-27
  Called from Stdlib__Map.Make.mapi in file "map.ml", line 322, characters 19-27
  Called from Lang__Program.map_procedures in file "lib/lang/program.ml", lines 134-137, characters 6-17
  Called from Transforms__Aslp.transform_program in file "lib/transforms/aslp/aslp.ml", lines 234-235, characters 2-76
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", line 314, characters 13-39
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
  |}]

let%expect_test "aslp integration with no aarch64_eval intrins" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);
var $PC:bv64;
prog entry @main;

proc @main()  -> () {  }
  requires boolor(eq(0x400808:bv64, $PC))
[
      block %main_code { .address = 0x400808; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
      .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
              .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
    assume eq(0x400808:bv64, $PC);
    // call @_aarch64_eval(0x54002000:bv32) { .asm = "b.eq #1024" };
    assert boolor(eq(0x400784:bv64, $PC));
    goto (%ret_1);
  ];
      block %ret_1 [ return; ]
];
    |}
  in
  let prog = transform_program lst.prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var observable $mem:(bv64->bv8);
    var $PC:bv64;
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x400808:bv64, $PC))

    [
       block %main_code { .address = 4196360; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                   .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
         assume eq(0x400808:bv64, $PC);
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    var $SP:bv64;
    var $R0:bv64;
    var $R1:bv64;
    var $R2:bv64;
    var $R3:bv64;
    var $R4:bv64;
    var $R5:bv64;
    var $R6:bv64;
    var $R7:bv64;
    var $R8:bv64;
    var $R9:bv64;
    var $R10:bv64;
    var $R11:bv64;
    var $R12:bv64;
    var $R13:bv64;
    var $R14:bv64;
    var $R15:bv64;
    var $R16:bv64;
    var $R17:bv64;
    var $R18:bv64;
    var $R19:bv64;
    var $R20:bv64;
    var $R21:bv64;
    var $R22:bv64;
    var $R23:bv64;
    var $R24:bv64;
    var $R25:bv64;
    var $R26:bv64;
    var $R27:bv64;
    var $R28:bv64;
    var $R29:bv64;
    var $R30:bv64;
    var $Z0:bv128;
    var $Z1:bv128;
    var $Z2:bv128;
    var $Z3:bv128;
    var $Z4:bv128;
    var $Z5:bv128;
    var $Z6:bv128;
    var $Z7:bv128;
    var $Z8:bv128;
    var $Z9:bv128;
    var $Z10:bv128;
    var $Z11:bv128;
    var $Z12:bv128;
    var $Z13:bv128;
    var $Z14:bv128;
    var $Z15:bv128;
    var $Z16:bv128;
    var $Z17:bv128;
    var $Z18:bv128;
    var $Z19:bv128;
    var $Z20:bv128;
    var $Z21:bv128;
    var $Z22:bv128;
    var $Z23:bv128;
    var $Z24:bv128;
    var $Z25:bv128;
    var $Z26:bv128;
    var $Z27:bv128;
    var $Z28:bv128;
    var $Z29:bv128;
    var $Z30:bv128;
    var $FPSR:bv64;
    var $FPCR:bv64;
    var $PSTATE_C:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_V:bv1;
    var $PSTATE_N:bv1;
    var $PSTATE_A:bv1;
    var $PSTATE_D:bv1;
    var $PSTATE_DIT:bv1;
    var $PSTATE_F:bv1;
    var $PSTATE_I:bv1;
    var $PSTATE_PAN:bv1;
    var $PSTATE_SP:bv1;
    var $PSTATE_SSBS:bv1;
    var $PSTATE_TCO:bv1;
    var $PSTATE_UAO:bv1;
    var $PSTATE_BTYPE:bv1;
    var $ExclusiveLocal:bool;
    prog entry @main;
    |}]
