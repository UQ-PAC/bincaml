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
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Invalid_argument "result is Error _")
  Raised at Stdlib.invalid_arg in file "stdlib.ml", line 30, characters 20-45
  Called from Stdlib__Result.get_ok in file "result.ml" (inlined), line 21, characters 45-76
  Called from Transforms__Aslp__Aslp_state.ensure_forwarded_pc in file "lib/transforms/aslp/aslp_state.ml", line 205, characters 13-67
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.get_ir in file "lib/transforms/aslp/bincaml_ibi_make.ml", lines 96-98, characters 8-41
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", lines 18-21, characters 4-42
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
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
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Invalid_argument "result is Error _")
  Raised at Stdlib.invalid_arg in file "stdlib.ml", line 30, characters 20-45
  Called from Stdlib__Result.get_ok in file "result.ml" (inlined), line 21, characters 45-76
  Called from Transforms__Aslp__Aslp_state.ensure_forwarded_pc in file "lib/transforms/aslp/aslp_state.ml", line 205, characters 13-67
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.get_ir in file "lib/transforms/aslp/bincaml_ibi_make.ml", lines 96-98, characters 8-41
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Stdlib__List.mapi in file "list.ml", line 96, characters 15-21
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", lines 44-47, characters 4-80
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
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
  [%expect {|
    Diamond {
      pred = (Leaf { Aslp_state.assume = true; stmts = []; pc_assign = None });
      left =
      (Leaf
         { Aslp_state.assume = eq($PSTATE_Z, 0x1:bv1);
           stmts = [var BranchTaken:bool := true; $PC:bv64 := 0x2400:bv64];
           pc_assign = (Some 0x2400:bv64) });
      right =
      (Leaf
         { Aslp_state.assume = boolnot(eq($PSTATE_Z, 0x1:bv1));
           stmts = [(var BranchTaken:bool := false, $PC:bv64 := 0x2004:bv64)];
           pc_assign = (Some 0x2004:bv64) });
      value =
      { Aslp_state.assume = true;
        stmts =
        [$PC:bv64 := if eq($PSTATE_Z, 0x1:bv1) then 0x2400:bv64 else 0x2004:bv64];
        pc_assign =
        (Some if eq($PSTATE_Z, 0x1:bv1) then 0x2400:bv64 else 0x2004:bv64) }}
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
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Invalid_argument "result is Error _")
  Raised at Stdlib.invalid_arg in file "stdlib.ml", line 30, characters 20-45
  Called from Stdlib__Result.get_ok in file "result.ml" (inlined), line 21, characters 45-76
  Called from Transforms__Aslp__Aslp_state.ensure_forwarded_pc in file "lib/transforms/aslp/aslp_state.ml", line 205, characters 13-67
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.get_ir in file "lib/transforms/aslp/bincaml_ibi_make.ml", lines 96-98, characters 8-41
  Called from Stdlib__Fun.protect in file "fun.ml", line 34, characters 8-15
  Re-raised at Stdlib__Fun.protect in file "fun.ml", line 39, characters 6-52
  Called from Test_aslp.(fun) in file "test/transforms/test_aslp.ml", lines 98-101, characters 4-42
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
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
         call @_aarch64_eval(0xa9be7bfd:bv32) { .asm = "stp x29, x30, [sp, #-0x20]!";
             .error = "Invalid_argument(\"result is Error _\")" };
         call @_aarch64_eval(0x910003fd:bv32) { .asm = "mov x29, sp";
             .error = "Invalid_argument(\"result is Error _\")" };
         call @_aarch64_eval(0xb9001fe0:bv32) { .asm = "str w0, [sp, #0x1c]";
             .error = "Invalid_argument(\"result is Error _\")" };
         call @_aarch64_eval(0xf9000be1:bv32) { .asm = "str x1, [sp, #0x10]";
             .error = "Invalid_argument(\"result is Error _\")" };
         call @_aarch64_eval(0xb9801fe0:bv32) { .asm = "ldrsw x0, [sp, #0x1c]";
             .error = "Invalid_argument(\"result is Error _\")" };
         call @_aarch64_eval(0x97ffffda:bv32) { .asm = "bl #0xffffffffffffff68";
             .error = "Invalid_argument(\"result is Error _\")" };
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
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
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
  [%expect
    {|
    var observable $mem:(bv64->bv8);
    var $PC:bv64;
    proc @Sqrt()  -> () {  }
      captures $PC:bv64

    [
       block %Sqrt_code_4 { .address = 4196316 } [
         assume eq(0x4007dc:bv64, $PC);
         goto (%block);
       ];
       block %block { .asm = "b.lt #0x10" } [
         guard true;
         goto (%block_2,%block_1);
       ];
       block %block_1 [
         guard boolnot(eq($PSTATE_N, $PSTATE_V));
         var BranchTaken:bool := true;
         $PC:bv64 := 0x4007ec:bv64;
         goto (%block_3);
       ];
       block %block_2 [
         guard boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
         (var BranchTaken:bool := false, $PC:bv64 := 0x4007e0:bv64);
         goto (%block_3);
       ];
       block %block_3 { .address = 0x4007e0:bv64 } [
         guard true;
         $PC:bv64 := if boolnot(eq($PSTATE_N, $PSTATE_V)) then 0x4007ec:bv64 else 0x4007e0:bv64;
         assert boolor(eq(0x4007fc:bv64, $PC), eq(0x4007e0:bv64, $PC));
         goto (%Sqrt_code_3,%Sqrt_code);
       ];
       block %Sqrt_code [ assume eq(0x4007e0:bv64, $PC); goto (%ret); ];
       block %Sqrt_code_3 [ assume eq(0x4007fc:bv64, $PC); goto (%ret); ];
       block %ret [ return; ]
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
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
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
    prog entry @Sqrt;
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
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
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
