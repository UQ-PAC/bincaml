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
         [var var_0:bv64 := 0x0:bv64; var var_0:bv64 := $R2;
           var var_1:bv64 := 0x0:bv64; var var_1:bv64 := $R3;
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
  [%expect
    {|
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
  [%expect
    {|
    (Leaf
       { Aslp_state.assume = true;
         stmts =
         [var var_0:bv64 := 0x0:bv64; var var_0:bv64 := $R2;
           var var_1:bv64 := 0x0:bv64; var var_1:bv64 := $R3;
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
  let prog =
    lst.prog
    |> Program.map_procedures (fun _ ->
        Procedure.map_blocks_nondet (apply_stmt_addresses_from_block % snd))
    |> transform_program
  in
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
       block %block { .address = 0x400808:bv64; .asm = "stp x29, x30, [sp, #-0x20]!" } [
         var var:bv64 := 0x0:bv64;
         var var:bv64 := $SP;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
          0xffffffffffffffe0:bv64) $R29 8;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
           0xffffffffffffffe0:bv64), 0x8:bv64) $R30 8;
         $SP:bv64 := bvadd(var:bv64, 0xffffffffffffffe0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0x40080c:bv64);
         goto (%block_1);
       ];
       block %block_1 { .address = 0x40080c:bv64; .asm = "mov x29, sp" } [
         var var_1:bv64 := 0x0:bv64;
         $R29:bv64 := bvadd($SP, 0x0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0x400810:bv64);
         goto (%block_2);
       ];
       block %block_2 { .address = 0x400810:bv64; .asm = "str w0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) extract(-32,0, $R0) 4;
         (var BranchTaken:bool := false, $PC:bv64 := 0x400814:bv64);
         goto (%block_3);
       ];
       block %block_3 { .address = 0x400814:bv64; .asm = "str x1, [sp, #0x10]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x10:bv64) $R1 8;
         (var BranchTaken:bool := false, $PC:bv64 := 0x400818:bv64);
         goto (%block_4);
       ];
       block %block_4 { .address = 0x400818:bv64; .asm = "ldrsw x0, [sp, #0x1c]" } [
         var var_2:bv32 := 0x0:bv32;
         $mem:(bv64->bv8) := load le var_3:bv4 bvadd($SP, 0x1c:bv64) 4;
         var var_2:bv32 := var_3:bv4;
         $R0:bv64 := zero_extend(0, sign_extend(32, var_2:bv32));
         (var BranchTaken:bool := false, $PC:bv64 := 0x40081c:bv64);
         goto (%block_5);
       ];
       block %block_5 { .address = 0x40081c:bv64; .asm = "bl #0xffffffffffffff68" } [
         $R30:bv64 := 0x400820:bv64;
         var BranchTaken:bool := true;
         $PC:bv64 := 0x400784:bv64;
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    var $R1:bv64;
    var $SP:bv64;
    var $R29:bv64;
    var $R30:bv64;
    var $R0:bv64;
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
  let prog =
    lst.prog
    |> Program.map_procedures (fun _ ->
        Procedure.map_blocks_nondet (apply_stmt_addresses_from_block % snd))
    |> transform_program
  in
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
       block %block { .address = 0x4007dc:bv64; .asm = "b.lt #0x10" } [
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
       block %block_3 [
         $PC:bv64 := if boolnot(eq($PSTATE_N, $PSTATE_V)) then 0x4007ec:bv64 else 0x4007e0:bv64;
         assert boolor(eq(0x4007fc:bv64, $PC), eq(0x4007e0:bv64, $PC));
         goto (%Sqrt_code_3,%Sqrt_code);
       ];
       block %Sqrt_code [ assume eq(0x4007e0:bv64, $PC); goto (%ret); ];
       block %Sqrt_code_3 [ assume eq(0x4007fc:bv64, $PC); goto (%ret); ];
       block %ret [ return; ]
    ];
    var $PSTATE_N:bv1;
    var $PSTATE_V:bv1;
    prog entry @Sqrt;
    |}]

let%expect_test "aslp integration should leave unsupporteds" =
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
    call @_aarch64_eval(0xd4000021:bv32) { .asm = "svc 1"; .address = 0x400808:bv64 };
    call @_aarch64_eval(0xaa1f03ff:bv32) { .asm = "mov xzr, xzr"; .address = 0x40080c:bv64 };
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
         call @_aarch64_eval(0xd4000021:bv32) { .address = 0x400808:bv64;
             .asm = "svc 1"; .error = "Failure(\"unsupported\")" };
         goto (%block);
       ];
       block %block { .address = 0x40080c:bv64; .asm = "mov xzr, xzr" } [
         var var:bv64 := 0x0:bv64;
         var var_1:bv64 := 0x0:bv64;
         (var BranchTaken:bool := false, $PC:bv64 := 0x400810:bv64);
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    prog entry @main;
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
    prog entry @main;
    |}]
