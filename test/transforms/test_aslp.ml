open Lang
open Common
open Transforms.Aslp

let%expect_test "lift empty" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  let x =
    lift_code_block (module I) ~address:(Bitvec.of_int ~size:64 0x2000)
    @@ Iter.empty
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
    lift_code_block (module I) ~address:(Bitvec.of_int ~size:64 0x2000)
    @@ Iter.doubleton
         (Bitvec.of_string "0xd29579a1:bv32")
         (Bitvec.of_string "0xd29579a1:bv32")
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
      { Aslp_state.assume = true; stmts = [];
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
  block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
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
  let memory () =
    Program.get_decl_by_name "$mem" lst.prog |> function
    | Some (Variable { binding }) -> binding
    | _ -> failwith "no memory"
  in
  let prog =
    lst.prog
    |> Program.map_procedures (fun _ proc ->
        Procedure.iter_blocks proc
        |> Iter.fold
             (fun proc (bid, b) -> transform_block ~memory ~proc bid b)
             proc)
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
       block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                   .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
         assume eq(0x400808:bv64, $PC);
         goto (%block);
       ];
       block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
         var var:bv64 := $SP_EL0;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP_EL0,
          0xffffffffffffffe0:bv64) $R29 8;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP_EL0,
           0xffffffffffffffe0:bv64), 0x8:bv64) $R30 8;
         $SP_EL0:bv64 := bvadd(var:bv64, 0xffffffffffffffe0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0xb00004:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "mov x29, sp" } [
         $R29:bv64 := bvadd($SP_EL0, 0x0:bv64);
         (var BranchTaken:bool := false, $PC:bv64 := 0xb00008:bv64);
         goto (%block_2);
       ];
       block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP_EL0, 0x1c:bv64) extract(-32,0, $R0) 4;
         (var BranchTaken:bool := false, $PC:bv64 := 0xb0000c:bv64);
         goto (%block_3);
       ];
       block %block_3 { .asm = "str x1, [sp, #0x10]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP_EL0, 0x10:bv64) $R1 8;
         (var BranchTaken:bool := false, $PC:bv64 := 0xb00010:bv64);
         goto (%block_4);
       ];
       block %block_4 { .asm = "ldrsw x0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := load le var_3:bv4 bvadd($SP_EL0, 0x1c:bv64) 4;
         var var_2:bv32 := var_3:bv4;
         $R0:bv64 := zero_extend(0, sign_extend(32, var_2:bv32));
         (var BranchTaken:bool := false, $PC:bv64 := 0xb00014:bv64);
         goto (%block_5);
       ];
       block %block_5 { .asm = "bl #0xffffffffffffff68" } [
         $R30:bv64 := 0xb00018:bv64;
         var BranchTaken:bool := true;
         $PC:bv64 := 0xafff7c:bv64;
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    prog entry @main;
    |}]
