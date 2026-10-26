open Bincaml_util.Common

let%expect_test "bayat1" =
  let prog = (Loader.Loadir.ast_of_fname "bayat1.il").prog in
  let proc = Lang.Program.get_proc_by_name "@main" prog in
  let mainid = Lang.Procedure.id proc in
  let prog = Lang.Program.set_entry_proc mainid prog in

  let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if not (ID.equal id mainid) then Lang.Program.remove_decl prog decl
           else prog)
         prog
  in
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect
    {|
    (Begin ("%Return", 47))
    (Begin ("%returns", 46))
    (Begin ("%inputs", 45))
    (Begin ("%main_code_7", 44))
    (Begin ("%block_35", 43))
    (Begin ("%block_34", 42))
    (Begin ("%block_33", 41))
    (Begin ("%block_32", 40))
    (Begin ("%block_31", 39))
    (Begin ("%block_30", 38))
    (Begin ("%block_29", 37))
    (Begin ("%block_28", 36))
    (Begin ("%main_code_6", 35))
    (Begin ("%block_27", 34))
    (Begin ("%block_26", 33))
    (Begin ("%block_25", 32))
    (Begin ("%block_24", 31))
    (Begin ("%block_23", 30))
    (Begin ("%block_22", 29))
    (Begin ("%block_21", 28))
    (Begin ("%block_20", 27))
    (Begin ("%block_19", 26))
    (Begin ("%block_18", 25))
    (Begin ("%main_code_5", 24))
    (Begin ("%block_17", 23))
    (Begin ("%block_16", 22))
    (Begin ("%block_15", 21))
    (Begin ("%block_14", 20))
    (Begin ("%block_13", 19))
    (Begin ("%block_12", 18))
    (Begin ("%block_11", 17))
    (Begin ("%block_10", 16))
    (Begin ("%block_9", 15))
    (Begin ("%main_code_4", 14))
    (Begin ("%block_8", 13))
    (Begin ("%block_7", 12))
    (Begin ("%block_6", 11))
    (Begin ("%block_5", 10))
    (Begin ("%block_4", 9))
    (Begin ("%block_3", 8))
    (Begin ("%block_2", 7))
    (Begin ("%block_1", 6))
    (Begin ("%block", 5))
    (Begin ("%ret_4", 4))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_2", 2))
    (Begin ("%main_code_1", 1))
    (Begin ("%main_code", 0))
    proc @main(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1, PSTATE_V_in:bv1, PSTATE_Z_in:bv1, R0_in:bv64,
       R1_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
       -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1, PSTATE_Z_out:bv1,
       R0_out:bv64, R1_out:bv64, R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)
      requires boolor(eq(0x864:bv64, PC_in:bv64))

    [
       block %inputs [
         (var PC:bv64 := PC_in:bv64, var PSTATE_C:bv1 := PSTATE_C_in:bv1,
          var PSTATE_N:bv1 := PSTATE_N_in:bv1, var PSTATE_V:bv1 := PSTATE_V_in:bv1,
          var PSTATE_Z:bv1 := PSTATE_Z_in:bv1, var R0:bv64 := R0_in:bv64, var R1:bv64 := R1_in:bv64,
          var R29:bv64 := R29_in:bv64, var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
         goto (%main_code);
       ];
       block %main_code { .address = 2148; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 2172; .conditional = "true"; .direct = "true";
                   .target = "internal:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Fallthrough" };
               { .address = 2212; .conditional = "true"; .direct = "true";
                   .target = "internal:gFBdrsFTRkSCdIsDFMk6qA"; .type = "Type_Branch" } ] } [
         var PC:bv64 := PC:bv64;
         assume eq(0x864:bv64, PC:bv64);
         goto (%block);
       ];
       block %block { .asm = "stp x29, x30, [sp, #-0x30]!" } [
         var local:bv64 := 0x0:bv64;
         var local:bv64 := SP:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0xffffffffffffffd0:bv64) R29:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64, 0xffffffffffffffd0:bv64),
          0x8:bv64) R30:bv64 64;
         var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffd0:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x868:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "mov x29, sp" } [
         var local_1:bv64 := 0x0:bv64;
         var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x86c:bv64);
         goto (%block_2);
       ];
       block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x1c:bv64) extract(32,0, R0:bv64) 32;
         (var BranchTaken:bool := false, var PC:bv64 := 0x870:bv64);
         goto (%block_3);
       ];
       block %block_3 { .asm = "ldr w0, [sp, #0x1c]" } [
         var local_2:bv32 := 0x0:bv32;
         var local_3:bv32 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x1c:bv64) 32;
         var local_2:bv32 := local_3:bv32;
         var R0:bv64 := zero_extend(32, zero_extend(0, local_2:bv32));
         (var BranchTaken:bool := false, var PC:bv64 := 0x874:bv64);
         goto (%block_4);
       ];
       block %block_4 { .asm = "cmp w0, #0" } [
         var local_4:bv32 := 0x0:bv32;
         var local_5:bv32 := 0x0:bv32;
         var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32,
            bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
            bvadd(bvadd(sign_extend(32, extract(32,0, R0:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64))));
         var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32,
            bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
            bvadd(bvadd(zero_extend(32, extract(32,0, R0:bv64)), 0xffffffff:bv64), 0x1:bv64))));
         var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32),
           0x0:bv32));
         var PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32));
         (var BranchTaken:bool := false, var PC:bv64 := 0x878:bv64);
         goto (%block_5);
       ];
       block %block_5 { .asm = "b.eq #0x2c" } [ goto (%block_7,%block_6); ];
       block %block_6 [
         var PSTATE_Z:bv1 := PSTATE_Z:bv1;
         assume eq(PSTATE_Z:bv1, 0x1:bv1);
         var BranchTaken:bool := true;
         var PC:bv64 := 0x8a4:bv64;
         goto (%block_8);
       ];
       block %block_7 [
         var PSTATE_Z:bv1 := PSTATE_Z:bv1;
         assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
         (var BranchTaken:bool := false, var PC:bv64 := 0x87c:bv64);
         goto (%block_8);
       ];
       block %block_8 [
         var PC:bv64 := if eq(PSTATE_Z:bv1, 0x1:bv1) then 0x8a4:bv64 else 0x87c:bv64;
         goto (%main_code_4);
       ];
       block %main_code_4 [
         var PC:bv64 := PC:bv64;
         assert boolor(eq(0x87c:bv64, PC:bv64), eq(0x8a4:bv64, PC:bv64));
         goto (%main_code_2,%main_code_1);
       ];
       block %main_code_1 { .address = 2212; .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w"; .type = "Type_Fallthrough" } ] } [
         var PC:bv64 := PC:bv64;
         assume eq(0x8a4:bv64, PC:bv64);
         goto (%block_9);
       ];
       block %block_9 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8a8:bv64);
         goto (%block_10);
       ];
       block %block_10 { .asm = "add x0, x0, #0x40" } [
         var local_6:bv64 := 0x0:bv64;
         var local_7:bv64 := 0x0:bv64;
         var local_7:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_7:bv64, 0x40:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8ac:bv64);
         goto (%block_11);
       ];
       block %block_11 { .asm = "add x1, sp, #0x28" } [
         var local_8:bv64 := 0x0:bv64;
         var R1:bv64 := bvadd(SP:bv64, 0x28:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8b0:bv64);
         goto (%block_12);
       ];
       block %block_12 { .asm = "str x1, [x0]" } [
         var local_9:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8b4:bv64);
         goto (%block_13);
       ];
       block %block_13 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8b8:bv64);
         goto (%block_14);
       ];
       block %block_14 { .asm = "add x0, x0, #0x48" } [
         var local_10:bv64 := 0x0:bv64;
         var local_11:bv64 := 0x0:bv64;
         var local_11:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_11:bv64, 0x48:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8bc:bv64);
         goto (%block_15);
       ];
       block %block_15 { .asm = "adrp x1, #0x20000" } [
         var R1:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8c0:bv64);
         goto (%block_16);
       ];
       block %block_16 { .asm = "add x1, x1, #0x40" } [
         var local_12:bv64 := 0x0:bv64;
         var local_13:bv64 := 0x0:bv64;
         var local_13:bv64 := R1:bv64;
         var R1:bv64 := bvadd(local_13:bv64, 0x40:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8c4:bv64);
         goto (%block_17);
       ];
       block %block_17 { .asm = "str x1, [x0]" } [
         var local_14:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8c8:bv64);
         goto (%main_code_5);
       ];
       block %main_code_5 [
         var PC:bv64 := PC:bv64;
         assert boolor(eq(0x8c8:bv64, PC:bv64));
         goto (%main_code_3);
       ];
       block %main_code_2 { .address = 2172; .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w"; .type = "Type_Branch" } ] } [
         var PC:bv64 := PC:bv64;
         assume eq(0x87c:bv64, PC:bv64);
         goto (%block_18);
       ];
       block %block_18 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x880:bv64);
         goto (%block_19);
       ];
       block %block_19 { .asm = "add x0, x0, #0x38" } [
         var local_15:bv64 := 0x0:bv64;
         var local_16:bv64 := 0x0:bv64;
         var local_16:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_16:bv64, 0x38:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x884:bv64);
         goto (%block_20);
       ];
       block %block_20 { .asm = "add x1, sp, #0x2c" } [
         var local_17:bv64 := 0x0:bv64;
         var R1:bv64 := bvadd(SP:bv64, 0x2c:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x888:bv64);
         goto (%block_21);
       ];
       block %block_21 { .asm = "str x1, [x0]" } [
         var local_18:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x88c:bv64);
         goto (%block_22);
       ];
       block %block_22 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x890:bv64);
         goto (%block_23);
       ];
       block %block_23 { .asm = "add x0, x0, #0x48" } [
         var local_19:bv64 := 0x0:bv64;
         var local_20:bv64 := 0x0:bv64;
         var local_20:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_20:bv64, 0x48:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x894:bv64);
         goto (%block_24);
       ];
       block %block_24 { .asm = "adrp x1, #0x20000" } [
         var R1:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x898:bv64);
         goto (%block_25);
       ];
       block %block_25 { .asm = "add x1, x1, #0x38" } [
         var local_21:bv64 := 0x0:bv64;
         var local_22:bv64 := 0x0:bv64;
         var local_22:bv64 := R1:bv64;
         var R1:bv64 := bvadd(local_22:bv64, 0x38:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x89c:bv64);
         goto (%block_26);
       ];
       block %block_26 { .asm = "str x1, [x0]" } [
         var local_23:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8a0:bv64);
         goto (%block_27);
       ];
       block %block_27 { .asm = "b #0x28" } [
         var BranchTaken:bool := true;
         var PC:bv64 := 0x8c8:bv64;
         goto (%main_code_6);
       ];
       block %main_code_6 [
         var PC:bv64 := PC:bv64;
         assert boolor(eq(0x8c8:bv64, PC:bv64));
         goto (%main_code_3);
       ];
       block %main_code_3 { .address = 2248; .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
           .succ = [ { .conditional = "false"; .direct = "false"; .target = "proxy:1B4yLqLSTR620oRfmWqVdg";
                   .type = "Type_Return" } ] } [
         var PC:bv64 := PC:bv64;
         assume eq(0x8c8:bv64, PC:bv64);
         goto (%block_28);
       ];
       block %block_28 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8cc:bv64);
         goto (%block_29);
       ];
       block %block_29 { .asm = "add x0, x0, #0x50" } [
         var local_24:bv64 := 0x0:bv64;
         var local_25:bv64 := 0x0:bv64;
         var local_25:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_25:bv64, 0x50:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8d0:bv64);
         goto (%block_30);
       ];
       block %block_30 { .asm = "adrp x1, #0x20000" } [
         var R1:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8d4:bv64);
         goto (%block_31);
       ];
       block %block_31 { .asm = "add x1, x1, #0x58" } [
         var local_26:bv64 := 0x0:bv64;
         var local_27:bv64 := 0x0:bv64;
         var local_27:bv64 := R1:bv64;
         var R1:bv64 := bvadd(local_27:bv64, 0x58:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8d8:bv64);
         goto (%block_32);
       ];
       block %block_32 { .asm = "str x1, [x0]" } [
         var local_28:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8dc:bv64);
         goto (%block_33);
       ];
       block %block_33 { .asm = "mov w0, #0" } [
         var R0:bv64 := 0x0:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x8e0:bv64);
         goto (%block_34);
       ];
       block %block_34 { .asm = "ldp x29, x30, [sp], #0x30" } [
         var local_29:bv64 := 0x0:bv64;
         var local_29:bv64 := SP:bv64;
         var local_30:bv64 := 0x0:bv64;
         var local_31:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
         var local_30:bv64 := local_31:bv64;
         var local_32:bv64 := 0x0:bv64;
         var local_33:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
         var local_32:bv64 := local_33:bv64;
         var R29:bv64 := local_30:bv64;
         var R30:bv64 := local_32:bv64;
         var SP:bv64 := bvadd(local_29:bv64, 0x30:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x8e4:bv64);
         goto (%block_35);
       ];
       block %block_35 { .asm = "ret " } [
         var local_34:bv64 := 0x0:bv64;
         var BTypeNext:bv2 := 0x0:bv2;
         var BranchTaken:bool := true;
         var PC:bv64 := R30:bv64;
         goto (%main_code_7);
       ];
       block %main_code_7 [ assert false; goto (%ret_4); ];
       block %ret_4 [ goto (%returns); ];
       block %returns [
         (var PC_out:bv64 := PC:bv64, var PSTATE_C_out:bv1 := PSTATE_C:bv1,
          var PSTATE_N_out:bv1 := PSTATE_N:bv1, var PSTATE_V_out:bv1 := PSTATE_V:bv1,
          var PSTATE_Z_out:bv1 := PSTATE_Z:bv1, var R0_out:bv64 := R0:bv64, var R1_out:bv64 := R1:bv64,
          var R29_out:bv64 := R29:bv64, var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
         goto (%Return);
       ];
       block %Return [
         (var PC_out:bv64 := PC_out:bv64, var PSTATE_C_out:bv1 := PSTATE_C_out:bv1,
          var PSTATE_N_out:bv1 := PSTATE_N_out:bv1, var PSTATE_V_out:bv1 := PSTATE_V_out:bv1,
          var PSTATE_Z_out:bv1 := PSTATE_Z_out:bv1, var R0_out:bv64 := R0_out:bv64,
          var R1_out:bv64 := R1_out:bv64, var R29_out:bv64 := R29_out:bv64,
          var R30_out:bv64 := R30_out:bv64, var SP_out:bv64 := SP_out:bv64);
         return;
       ]
    ]
    (Begin ("%block_8", 13))
    (Begin ("%block_8", 13))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    (Begin ("%block_8", 13))
    (Begin ("%block_8", 13))
    (Begin ("%main_code_3", 3))
    (Begin ("%main_code_3", 3))
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node0"[label="node0 S \nStack(@main) |{<0>[-48, -41]|<1>[-40, -33]|<2>[-20, -17]|<3>[-8, 3]}"];
      "node3"[label="node3 UO \nPar(@main_R0_in:bv64)\nLoaded(local_39:bv32) |{<4>Top}"];
      "node5"[label="node5 G \nGlobal |{<5>[131128, 131143]|<6>[131144, 131151]|<7>[131152, 131159]|<8>[131160, 131167]}"];
      "node6"[label="node6 U \nPar(@main_R29_in:bv64)\nLoaded(local_53:bv64) |{<9>[0, 7]}"];
      "node7"[label="node7 U \nPar(@main_R30_in:bv64)\nLoaded(local_56:bv64) |{<10>[0, 7]}"];
      "node0":2 -> "node3":4
      "node5":7 -> "node5":8
      "node0":0 -> "node6":9
      "node5":5 -> "node0":3
      "node5":6 -> "node5":5
      "node0":1 -> "node7":10
    }
    |}]

let%expect_test "bayat2" =
  let prog = (Loader.Loadir.ast_of_fname "bayat2.il").prog in
  let proc = Lang.Program.get_proc_by_name "@main" prog in
  let mainid = Lang.Procedure.id proc in
  let prog = Lang.Program.set_entry_proc mainid prog in

  let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if not (ID.equal id mainid) then Lang.Program.remove_decl prog decl
           else prog)
         prog
  in
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect
    {|
    (Begin ("%Return", 19))
    (Begin ("%returns", 18))
    (Begin ("%inputs", 17))
    (Begin ("%main_code_1", 16))
    (Begin ("%block_13", 15))
    (Begin ("%block_12", 14))
    (Begin ("%block_11", 13))
    (Begin ("%block_10", 12))
    (Begin ("%block_9", 11))
    (Begin ("%block_8", 10))
    (Begin ("%block_7", 9))
    (Begin ("%block_6", 8))
    (Begin ("%block_5", 7))
    (Begin ("%block_4", 6))
    (Begin ("%block_3", 5))
    (Begin ("%block_2", 4))
    (Begin ("%block_1", 3))
    (Begin ("%block", 2))
    (Begin ("%ret", 1))
    (Begin ("%main_code", 0))
    proc @main(PC_in:bv64, R0_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
       -> (PC_out:bv64, R0_out:bv64, R1_out:bv64, R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)
      requires boolor(eq(0x864:bv64, PC_in:bv64))

    [
       block %inputs [
         (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64, var R1:bv64 := R1_in:bv64,
          var R29:bv64 := R29_in:bv64, var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
         goto (%main_code);
       ];
       block %main_code { .address = 2148; .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
           .succ = [ { .conditional = "false"; .direct = "false"; .target = "proxy:1p7HOmDGQpyP3TVpJTH35g";
                   .type = "Type_Return" } ] } [
         var PC:bv64 := PC:bv64;
         assume eq(0x864:bv64, PC:bv64);
         goto (%block);
       ];
       block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
         var local:bv64 := 0x0:bv64;
         var local:bv64 := SP:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0xffffffffffffffe0:bv64) R29:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64, 0xffffffffffffffe0:bv64),
          0x8:bv64) R30:bv64 64;
         var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffe0:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x868:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "mov x29, sp" } [
         var local_1:bv64 := 0x0:bv64;
         var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x86c:bv64);
         goto (%block_2);
       ];
       block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x1c:bv64) extract(32,0, R0:bv64) 32;
         (var BranchTaken:bool := false, var PC:bv64 := 0x870:bv64);
         goto (%block_3);
       ];
       block %block_3 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x874:bv64);
         goto (%block_4);
       ];
       block %block_4 { .asm = "add x0, x0, #0x68" } [
         var local_2:bv64 := 0x0:bv64;
         var local_3:bv64 := 0x0:bv64;
         var local_3:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_3:bv64, 0x68:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x878:bv64);
         goto (%block_5);
       ];
       block %block_5 { .asm = "adrp x1, #0x20000" } [
         var R1:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x87c:bv64);
         goto (%block_6);
       ];
       block %block_6 { .asm = "add x1, x1, #0x60" } [
         var local_4:bv64 := 0x0:bv64;
         var local_5:bv64 := 0x0:bv64;
         var local_5:bv64 := R1:bv64;
         var R1:bv64 := bvadd(local_5:bv64, 0x60:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x880:bv64);
         goto (%block_7);
       ];
       block %block_7 { .asm = "str x1, [x0]" } [
         var local_6:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x884:bv64);
         goto (%block_8);
       ];
       block %block_8 { .asm = "adrp x0, #0x20000" } [
         var R0:bv64 := 0x20000:bv64;
         (var BranchTaken:bool := false, var PC:bv64 := 0x888:bv64);
         goto (%block_9);
       ];
       block %block_9 { .asm = "add x0, x0, #0x30" } [
         var local_7:bv64 := 0x0:bv64;
         var local_8:bv64 := 0x0:bv64;
         var local_8:bv64 := R0:bv64;
         var R0:bv64 := bvadd(local_8:bv64, 0x30:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x88c:bv64);
         goto (%block_10);
       ];
       block %block_10 { .asm = "ldrsw x1, [sp, #0x1c]" } [
         var local_9:bv32 := 0x0:bv32;
         var local_10:bv32 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x1c:bv64) 32;
         var local_9:bv32 := local_10:bv32;
         var R1:bv64 := zero_extend(0, sign_extend(32, local_9:bv32));
         (var BranchTaken:bool := false, var PC:bv64 := 0x890:bv64);
         goto (%block_11);
       ];
       block %block_11 { .asm = "ldr w0, [x0, x1, lsl #2]" } [
         var local_11:bv64 := 0x0:bv64;
         var local_11:bv64 := R1:bv64;
         var local_12:bv64 := 0x0:bv64;
         var local_12:bv64 := R0:bv64;
         var local_13:bv32 := 0x0:bv32;
         var local_14:bv32 := load le $mem:(bv64->bv8) bvadd(local_12:bv64,
          bvconcat(extract(62,0, local_11:bv64), 0x0:bv2)) 32;
         var local_13:bv32 := local_14:bv32;
         var R0:bv64 := zero_extend(32, zero_extend(0, local_13:bv32));
         (var BranchTaken:bool := false, var PC:bv64 := 0x894:bv64);
         goto (%block_12);
       ];
       block %block_12 { .asm = "ldp x29, x30, [sp], #0x20" } [
         var local_15:bv64 := 0x0:bv64;
         var local_15:bv64 := SP:bv64;
         var local_16:bv64 := 0x0:bv64;
         var local_17:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
         var local_16:bv64 := local_17:bv64;
         var local_18:bv64 := 0x0:bv64;
         var local_19:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
         var local_18:bv64 := local_19:bv64;
         var R29:bv64 := local_16:bv64;
         var R30:bv64 := local_18:bv64;
         var SP:bv64 := bvadd(local_15:bv64, 0x20:bv64);
         (var BranchTaken:bool := false, var PC:bv64 := 0x898:bv64);
         goto (%block_13);
       ];
       block %block_13 { .asm = "ret " } [
         var local_20:bv64 := 0x0:bv64;
         var BTypeNext:bv2 := 0x0:bv2;
         var BranchTaken:bool := true;
         var PC:bv64 := R30:bv64;
         goto (%main_code_1);
       ];
       block %main_code_1 [ assert false; goto (%ret); ];
       block %ret [ goto (%returns); ];
       block %returns [
         (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64, var R1_out:bv64 := R1:bv64,
          var R29_out:bv64 := R29:bv64, var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
         goto (%Return);
       ];
       block %Return [
         (var PC_out:bv64 := PC_out:bv64, var R0_out:bv64 := R0_out:bv64, var R1_out:bv64 := R1_out:bv64,
          var R29_out:bv64 := R29_out:bv64, var R30_out:bv64 := R30_out:bv64,
          var SP_out:bv64 := SP_out:bv64);
         return;
       ]
    ]
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node8"[label="node8 S \nStack(@main) |{<0>[-32, -25]|<1>[-24, -17]|<2>[-4, -1]}"];
      "node11"[label="node11 UO \nPar(@main_R0_in:bv64)\nLoaded(local_35:bv32) |{<3>Top}"];
      "node12"[label="node12 G \nGlobal |{<4>[131168, 131175]|<5>[131176, 131183]}"];
      "node14"[label="node14 U \nLoaded(local_42:bv32) |{<6>[0, 3]}"];
      "node15"[label="node15 U \nPar(@main_R29_in:bv64)\nLoaded(local_47:bv64) |{<7>[0, 7]}"];
      "node16"[label="node16 U \nPar(@main_R30_in:bv64)\nLoaded(local_50:bv64) |{<8>[0, 7]}"];
      "node8":2 -> "node11":3
      "node8":0 -> "node15":7
      "node12":5 -> "node12":4
      "node11":3 -> "node14":6
      "node8":1 -> "node16":8
    }
    |}]

let%expect_test "lattner1" =
  let prog = (Loader.Loadir.ast_of_fname "lattner1.il").prog in

  let proc_names = [ "@createnode"; "@splitclone"; "@processlist" ] in
  let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if List.mem (ID.name id) proc_names then prog
           else Lang.Program.remove_decl prog decl)
         prog
  in

  Lang.Program.pretty_to_chan stdout prog;

  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog =
    Bincaml.Passes.PassManager.(run_transform prog lift_intrinsics_aarch64)
  in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in

  List.iter
    (fun name ->
      let _, g = IDMap.find (Lang.Program.get_id_by_name name prog) dsgraph in
      print_endline @@ name;
      print_endline @@ Analysis.Dsa.dot_string g;
      print_endline "")
    proc_names;
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  Not_found
  Raised at Stdlib__Map.Make.find in file "map.ml", line 141, characters 10-25
  Called from Lang__Program.proc in file "lib/lang/program.ml", line 138, characters 2-36
  Called from Lang__Spec_modifies.solve.local_rw in file "lib/lang/spec_modifies.ml", line 31, characters 12-31
  Called from Fix__Core.Make.lfp.LFP.solve in file "src/Core.ml", line 233, characters 21-37
  Called from Fix__Core.Make.lfp.LFP.node_for in file "src/Core.ml", line 307, characters 4-14
  Called from Fix__Core.Make.lfp.LFP.solve.request in file "src/Core.ml", line 220, characters 20-30
  Called from Lang__Spec_modifies.solve.local_rw.(fun) in file "lib/lang/spec_modifies.ml", line 47, characters 55-74
  Called from Iter.filter_map.(fun) in file "src/Iter.ml", line 148, characters 12-15
  Called from CCVector.iter in file "src/core/CCVector.ml" (inlined), line 369, characters 4-30
  Called from CCVector.to_iter in file "src/core/CCVector.ml" (inlined), line 610, characters 18-26
  Called from Lang__Block.stmts_iter in file "lib/lang/block.ml", line 84, characters 19-41
  Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
  Called from Stdlib__Option.map in file "option.ml", line 24, characters 57-62
  Called from Lang__Procedure.fold_blocks_topo_fwd_headers.f in file "lib/lang/procedure.ml", line 549, characters 8-48
  Called from Stdlib__List.fold_left in file "list.ml", line 125, characters 24-34
  Called from Lang__Spec_modifies.solve.local_rw in file "lib/lang/spec_modifies.ml", lines 35-52, characters 10-13
  Called from Fix__Core.Make.lfp.LFP.solve in file "src/Core.ml", line 233, characters 21-37
  Called from Fix__Core.Make.lfp.LFP.node_for in file "src/Core.ml", line 307, characters 4-14
  Called from Fix__Core.Make.lfp.LFP.get in file "src/Core.ml", line 325, characters 15-25
  Called from Lang__Spec_modifies.set_modsets.(fun) in file "lib/lang/spec_modifies.ml", line 65, characters 26-33
  Called from Lang__Program.map_procedures.(fun) in file "lib/lang/program.ml", line 133, characters 63-77
  Called from Bincaml_util__Indexed_list.Make.mapi.f in file "lib/util/indexed_list.ml", line 205, characters 23-32
  Called from Bincaml_util__Indexed_list.Make.update.(fun) in file "lib/util/indexed_list.ml", line 141, characters 19-22
  Called from Stdlib__Map.Make.update in file "map.ml", line 287, characters 18-28
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Bincaml_util__Indexed_list.Make.update in file "lib/util/indexed_list.ml", lines 139-146, characters 6-13
  Called from Iter.foldi.(fun) in file "src/Iter.ml", line 84, characters 11-22
  Called from CCFQueue.to_iter in file "src/data/CCFQueue.ml", lines 267-269, characters 4-12
  Called from Iter.foldi in file "src/Iter.ml", lines 83-85, characters 2-13
  Called from Lang__Program.map_procedures in file "lib/lang/program.ml", lines 131-134, characters 6-17
  Called from Bincaml__Passes.PassManager.run_transform.(fun) in file "lib/passes.ml", line 617, characters 16-20
  Called from Dsa_tests__Inline.(fun) in file "test/dsa/inline.ml", line 671, characters 41-74
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  proc @createnode()  -> () {  }
    captures $PC:bv64
    requires boolor(eq(0x8e4:bv64, $PC))

  [
     block %createnode_code { .address = 2276;
         .gtirb_block = "c/WxqFxXSHWNzwaD8KmaZw";
         .succ = [ { .address = 1904; .conditional = "false"; .direct = "true";
                 .target = "stmts:tXIOhSQ+R1WA/9VL5+6KQQ"; .type = "Type_Call" } ] } [
       assume eq(0x8e4:bv64, $PC);
       call @_aarch64_eval(0xa9bd7bfd:bv32, 0x8e4:bv64) { .asm = "stp x29, x30, [sp, #-0x30]!" };
       call @_aarch64_eval(0x910003fd:bv32, 0x8e8:bv64) { .asm = "mov x29, sp" };
       call @_aarch64_eval(0xf9000fe0:bv32, 0x8ec:bv64) { .asm = "str x0, [sp, #0x18]" };
       call @_aarch64_eval(0xd2800200:bv32, 0x8f0:bv64) { .asm = "mov x0, #0x10" };
       call @_aarch64_eval(0x97ffff9f:bv32, 0x8f4:bv64) { .asm = "bl #0xfffffffffffffe7c" };
       assert boolor(eq(0x770:bv64, $PC));
       goto (%createnode_ext_2);
     ];
     block %createnode_ext_2 [
       assume eq(0x770:bv64, $PC);
       call @FUN_770();
       assert boolor(eq(0x8f8:bv64, $PC));
       goto (%createnode_code_1);
     ];
     block %createnode_code_1 { .address = 2296;
         .gtirb_block = "lrKKe+miRjSnSiaG164qMA";
         .succ = [ { .address = 2480; .conditional = "false"; .direct = "true";
                 .target = "external:9oceKFiPSN69RSkX65b7GQ"; .type = "Type_Return" };
             { .address = 2420; .conditional = "false"; .direct = "true";
                 .target = "external:pao7tNGFTG2/wwL2A6BKrQ"; .type = "Type_Return" } ] } [
       assume eq(0x8f8:bv64, $PC);
       call @_aarch64_eval(0xf90017e0:bv32, 0x8f8:bv64) { .asm = "str x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0x8fc:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400fe1:bv32, 0x900:bv64) { .asm = "ldr x1, [sp, #0x18]" };
       call @_aarch64_eval(0xf9000401:bv32, 0x904:bv64) { .asm = "str x1, [x0, #8]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0x908:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xa8c37bfd:bv32, 0x90c:bv64) { .asm = "ldp x29, x30, [sp], #0x30" };
       call @_aarch64_eval(0xd65f03c0:bv32, 0x910:bv64) { .asm = "ret " };
       assert boolor(eq(0x9b0:bv64, $PC), eq(0x974:bv64, $PC));
       goto (%ret_2,%ret_1);
     ];
     block %ret_1 [ return; ];
     block %ret_2 [ return; ]
  ];
  proc @processlist()  -> () {  }
    captures $PC:bv64
    requires boolor(eq(0x9e4:bv64, $PC))

  [
     block %processlist_code_8 { .address = 2532;
         .gtirb_block = "0LRsc3xvSnmWSGdUG3zWQA";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "stmts:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x9e4:bv64, $PC);
       call @_aarch64_eval(0xa9bc7bfd:bv32, 0x9e4:bv64) { .asm = "stp x29, x30, [sp, #-0x40]!" };
       call @_aarch64_eval(0x910003fd:bv32, 0x9e8:bv64) { .asm = "mov x29, sp" };
       call @_aarch64_eval(0xf9000fe0:bv32, 0x9ec:bv64) { .asm = "str x0, [sp, #0x18]" };
       call @_aarch64_eval(0x9100a3e1:bv32, 0x9f0:bv64) { .asm = "add x1, sp, #0x28" };
       call @_aarch64_eval(0x9100c3e0:bv32, 0x9f4:bv64) { .asm = "add x0, sp, #0x30" };
       call @_aarch64_eval(0xaa0103e2:bv32, 0x9f8:bv64) { .asm = "mov x2, x1" };
       call @_aarch64_eval(0xaa0003e1:bv32, 0x9fc:bv64) { .asm = "mov x1, x0" };
       call @_aarch64_eval(0xf9400fe0:bv32, 0xa00:bv64) { .asm = "ldr x0, [sp, #0x18]" };
       call @_aarch64_eval(0x97ffffc4:bv32, 0xa04:bv64) { .asm = "bl #0xffffffffffffff10" };
       assert boolor(eq(0x914:bv64, $PC));
       goto (%processlist_ext_1);
     ];
     block %processlist_ext_1 [
       assume eq(0x914:bv64, $PC);
       call @splitclone();
       assert boolor(eq(0xa08:bv64, $PC));
       goto (%processlist_code_2);
     ];
     block %processlist_code_2 { .address = 2568;
         .gtirb_block = "Nc5WfkQBRwahCMMkX4LB9A";
         .succ = [ { .address = 2600; .conditional = "false"; .direct = "true";
                 .target = "internal:Tk0jY0ehQLuBFrbkab7gag"; .type = "Type_Branch" } ] } [
       assume eq(0xa08:bv64, $PC);
       call @_aarch64_eval(0x14000008:bv32, 0xa08:bv64) { .asm = "b #0x20" };
       assert boolor(eq(0xa28:bv64, $PC));
       goto (%processlist_code_4);
     ];
     block %processlist_code_4 { .address = 2600;
         .gtirb_block = "Tk0jY0ehQLuBFrbkab7gag";
         .succ = [ { .address = 2572; .conditional = "true"; .direct = "true";
                 .target = "internal:VbaiJkWGQ4ukB7rQdAOUrw"; .type = "Type_Branch" };
             { .address = 2612; .conditional = "true"; .direct = "true";
                 .target = "internal:P5G7bTtwQ5KzfyzEb1rceA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa28:bv64, $PC);
       call @_aarch64_eval(0xf9401be0:bv32, 0xa28:bv64) { .asm = "ldr x0, [sp, #0x30]" };
       call @_aarch64_eval(0xf100001f:bv32, 0xa2c:bv64) { .asm = "cmp x0, #0" };
       call @_aarch64_eval(0x54fffee1:bv32, 0xa30:bv64) { .asm = "b.ne #0xffffffffffffffdc" };
       assert boolor(eq(0xa0c:bv64, $PC), eq(0xa34:bv64, $PC));
       goto (%processlist_code_5,%processlist_code_3);
     ];
     block %processlist_code_3 { .address = 2612;
         .gtirb_block = "P5G7bTtwQ5KzfyzEb1rceA";
         .succ = [ { .address = 2644; .conditional = "false"; .direct = "true";
                 .target = "internal:L48C5LViSEOx7RJ+UdllRQ"; .type = "Type_Branch" } ] } [
       assume eq(0xa34:bv64, $PC);
       call @_aarch64_eval(0x14000008:bv32, 0xa34:bv64) { .asm = "b #0x20" };
       assert boolor(eq(0xa54:bv64, $PC));
       goto (%processlist_code_1);
     ];
     block %processlist_code_5 { .address = 2572;
         .gtirb_block = "VbaiJkWGQ4ukB7rQdAOUrw";
         .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
                 .target = "stmts:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Call" } ] } [
       assume eq(0xa0c:bv64, $PC);
       call @_aarch64_eval(0xf9401be0:bv32, 0xa0c:bv64) { .asm = "ldr x0, [sp, #0x30]" };
       call @_aarch64_eval(0xf9400000:bv32, 0xa10:bv64) { .asm = "ldr x0, [x0]" };
       call @_aarch64_eval(0xf9001fe0:bv32, 0xa14:bv64) { .asm = "str x0, [sp, #0x38]" };
       call @_aarch64_eval(0xf9401be0:bv32, 0xa18:bv64) { .asm = "ldr x0, [sp, #0x30]" };
       call @_aarch64_eval(0x97ffff61:bv32, 0xa1c:bv64) { .asm = "bl #0xfffffffffffffd84" };
       assert boolor(eq(0x7a0:bv64, $PC));
       goto (%processlist_ext);
     ];
     block %processlist_code_1 { .address = 2644;
         .gtirb_block = "L48C5LViSEOx7RJ+UdllRQ";
         .succ = [ { .address = 2616; .conditional = "true"; .direct = "true";
                 .target = "internal:u7bJ/kNaSgSa1iIFXxesQw"; .type = "Type_Branch" };
             { .address = 2656; .conditional = "true"; .direct = "true";
                 .target = "internal:XRX9EXFkQgWL1KMW/G8EHQ";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa54:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32, 0xa54:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf100001f:bv32, 0xa58:bv64) { .asm = "cmp x0, #0" };
       call @_aarch64_eval(0x54fffee1:bv32, 0xa5c:bv64) { .asm = "b.ne #0xffffffffffffffdc" };
       assert boolor(eq(0xa38:bv64, $PC), eq(0xa60:bv64, $PC));
       goto (%processlist_code_7,%processlist_code_6);
     ];
     block %processlist_code_6 { .address = 2656;
         .gtirb_block = "XRX9EXFkQgWL1KMW/G8EHQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0xa60:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32, 0xa60:bv64) { .asm = "nop " };
       call @_aarch64_eval(0xd503201f:bv32, 0xa64:bv64) { .asm = "nop " };
       call @_aarch64_eval(0xa8c47bfd:bv32, 0xa68:bv64) { .asm = "ldp x29, x30, [sp], #0x40" };
       call @_aarch64_eval(0xd65f03c0:bv32, 0xa6c:bv64) { .asm = "ret " };
       assert false;
       goto (%ret_8);
     ];
     block %ret_8 [ return; ];
     block %processlist_code_7 { .address = 2616;
         .gtirb_block = "u7bJ/kNaSgSa1iIFXxesQw";
         .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
                 .target = "stmts:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Call" } ] } [
       assume eq(0xa38:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32, 0xa38:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400000:bv32, 0xa3c:bv64) { .asm = "ldr x0, [x0]" };
       call @_aarch64_eval(0xf9001fe0:bv32, 0xa40:bv64) { .asm = "str x0, [sp, #0x38]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0xa44:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0x97ffff56:bv32, 0xa48:bv64) { .asm = "bl #0xfffffffffffffd58" };
       assert boolor(eq(0x7a0:bv64, $PC));
       goto (%processlist_ext);
     ];
     block %processlist_ext [
       assume eq(0x7a0:bv64, $PC);
       call @FUN_7a0();
       assert boolor(eq(0xa20:bv64, $PC), eq(0xa4c:bv64, $PC));
       goto (%processlist_code_9,%processlist_code);
     ];
     block %processlist_code { .address = 2636;
         .gtirb_block = "FuGyG5p3Q2ycp9qxOC2b6Q";
         .succ = [ { .address = 2644; .conditional = "false"; .direct = "true";
                 .target = "internal:L48C5LViSEOx7RJ+UdllRQ";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa4c:bv64, $PC);
       call @_aarch64_eval(0xf9401fe0:bv32, 0xa4c:bv64) { .asm = "ldr x0, [sp, #0x38]" };
       call @_aarch64_eval(0xf90017e0:bv32, 0xa50:bv64) { .asm = "str x0, [sp, #0x28]" };
       assert boolor(eq(0xa54:bv64, $PC));
       goto (%processlist_code_1);
     ];
     block %processlist_code_9 { .address = 2592;
         .gtirb_block = "3JEWNpsjRGmkoycWQqb04Q";
         .succ = [ { .address = 2600; .conditional = "false"; .direct = "true";
                 .target = "internal:Tk0jY0ehQLuBFrbkab7gag";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa20:bv64, $PC);
       call @_aarch64_eval(0xf9401fe0:bv32, 0xa20:bv64) { .asm = "ldr x0, [sp, #0x38]" };
       call @_aarch64_eval(0xf9001be0:bv32, 0xa24:bv64) { .asm = "str x0, [sp, #0x30]" };
       assert boolor(eq(0xa28:bv64, $PC));
       goto (%processlist_code_4);
     ]
  ];
  proc @splitclone()  -> () {  }
    captures $PC:bv64
    requires boolor(eq(0x914:bv64, $PC))

  [
     block %splitclone_code_3 { .address = 2324;
         .gtirb_block = "U8BozksvTwaykuzNC4dZRQ";
         .succ = [ { .address = 2384; .conditional = "true"; .direct = "true";
                 .target = "internal:5jlZESzjQ4a4yO3+e1nyHQ"; .type = "Type_Branch" };
             { .address = 2524; .target = "internal:WTjM+CpMSlaCQoaCOxiagA" };
             { .address = 2464; .target = "internal:QIZPtsaTQjiAsr+paN6ljw" };
             { .address = 2356; .conditional = "true"; .direct = "true";
                 .target = "internal:H7LPJaZbQvWx+VL+kBk//Q";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x914:bv64, $PC);
       call @_aarch64_eval(0xa9bd7bfd:bv32, 0x914:bv64) { .asm = "stp x29, x30, [sp, #-0x30]!" };
       call @_aarch64_eval(0x910003fd:bv32, 0x918:bv64) { .asm = "mov x29, sp" };
       call @_aarch64_eval(0xf90017e0:bv32, 0x91c:bv64) { .asm = "str x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf90013e1:bv32, 0x920:bv64) { .asm = "str x1, [sp, #0x20]" };
       call @_aarch64_eval(0xf9000fe2:bv32, 0x924:bv64) { .asm = "str x2, [sp, #0x18]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0x928:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf100001f:bv32, 0x92c:bv64) { .asm = "cmp x0, #0" };
       call @_aarch64_eval(0x54000101:bv32, 0x930:bv64) { .asm = "b.ne #0x20" };
       assert boolor(eq(0x950:bv64, $PC), eq(0x9dc:bv64, $PC), eq(0x9a0:bv64, $PC),
        eq(0x934:bv64, $PC));
       goto (%splitclone_code_7,%splitclone_code_4,%splitclone_code_2,%splitclone_code);
     ];
     block %splitclone_code { .address = 2356;
         .gtirb_block = "H7LPJaZbQvWx+VL+kBk//Q";
         .succ = [ { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Branch" } ] } [
       assume eq(0x934:bv64, $PC);
       call @_aarch64_eval(0xf9400fe0:bv32, 0x934:bv64) { .asm = "ldr x0, [sp, #0x18]" };
       call @_aarch64_eval(0xf900001f:bv32, 0x938:bv64) { .asm = "str xzr, [x0]" };
       call @_aarch64_eval(0xf9400fe0:bv32, 0x93c:bv64) { .asm = "ldr x0, [sp, #0x18]" };
       call @_aarch64_eval(0xf9400001:bv32, 0x940:bv64) { .asm = "ldr x1, [x0]" };
       call @_aarch64_eval(0xf94013e0:bv32, 0x944:bv64) { .asm = "ldr x0, [sp, #0x20]" };
       call @_aarch64_eval(0xf9000001:bv32, 0x948:bv64) { .asm = "str x1, [x0]" };
       call @_aarch64_eval(0x14000024:bv32, 0x94c:bv64) { .asm = "b #0x90" };
       assert boolor(eq(0x9dc:bv64, $PC));
       goto (%splitclone_code_4);
     ];
     block %splitclone_code_2 { .address = 2464;
         .gtirb_block = "QIZPtsaTQjiAsr+paN6ljw";
         .succ = [ { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Branch" } ] } [
       assume eq(0x9a0:bv64, $PC);
       call @_aarch64_eval(0x1400000f:bv32, 0x9a0:bv64) { .asm = "b #0x3c" };
       assert boolor(eq(0x9dc:bv64, $PC));
       goto (%splitclone_code_4);
     ];
     block %splitclone_code_4 { .address = 2524;
         .gtirb_block = "WTjM+CpMSlaCQoaCOxiagA";
         .succ = [ { .address = 2568; .conditional = "false"; .direct = "true";
                 .target = "external:Nc5WfkQBRwahCMMkX4LB9A"; .type = "Type_Return" };
             { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Return" };
             { .address = 2464; .conditional = "false"; .direct = "true";
                 .target = "internal:QIZPtsaTQjiAsr+paN6ljw"; .type = "Type_Return" } ] } [
       assume eq(0x9dc:bv64, $PC);
       call @_aarch64_eval(0xa8c37bfd:bv32, 0x9dc:bv64) { .asm = "ldp x29, x30, [sp], #0x30" };
       call @_aarch64_eval(0xd65f03c0:bv32, 0x9e0:bv64) { .asm = "ret " };
       assert boolor(eq(0xa08:bv64, $PC), eq(0x9dc:bv64, $PC), eq(0x9a0:bv64, $PC));
       goto (%ret_9,%ret_8,%ret_7);
     ];
     block %ret_7 [ return; ];
     block %ret_8 [ return; ];
     block %ret_9 [ return; ];
     block %splitclone_code_7 { .address = 2384;
         .gtirb_block = "5jlZESzjQ4a4yO3+e1nyHQ";
         .succ = [ { .address = 2468; .conditional = "true"; .direct = "true";
                 .target = "internal:vIU4IpBoQ7iHGSsu/mSe3g"; .type = "Type_Branch" };
             { .address = 2408; .conditional = "true"; .direct = "true";
                 .target = "internal:I2aaHzp+TUWUl9oP4OxUPg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x950:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32, 0x950:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400400:bv32, 0x954:bv64) { .asm = "ldr x0, [x0, #8]" };
       call @_aarch64_eval(0xb9400000:bv32, 0x958:bv64) { .asm = "ldr w0, [x0]" };
       call @_aarch64_eval(0x12000000:bv32, 0x95c:bv64) { .asm = "and w0, w0, #1" };
       call @_aarch64_eval(0x7100001f:bv32, 0x960:bv64) { .asm = "cmp w0, #0" };
       call @_aarch64_eval(0x54000200:bv32, 0x964:bv64) { .asm = "b.eq #0x40" };
       assert boolor(eq(0x9a4:bv64, $PC), eq(0x968:bv64, $PC));
       goto (%splitclone_code_6,%splitclone_code_1);
     ];
     block %splitclone_code_1 { .address = 2408;
         .gtirb_block = "I2aaHzp+TUWUl9oP4OxUPg";
         .succ = [ { .address = 2276; .conditional = "false"; .direct = "true";
                 .target = "stmts:c/WxqFxXSHWNzwaD8KmaZw"; .type = "Type_Call" } ] } [
       assume eq(0x968:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32, 0x968:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400400:bv32, 0x96c:bv64) { .asm = "ldr x0, [x0, #8]" };
       call @_aarch64_eval(0x97ffffdd:bv32, 0x970:bv64) { .asm = "bl #0xffffffffffffff74" };
       assert boolor(eq(0x8e4:bv64, $PC));
       goto (%splitclone_ext_1);
     ];
     block %splitclone_code_6 { .address = 2468;
         .gtirb_block = "vIU4IpBoQ7iHGSsu/mSe3g";
         .succ = [ { .address = 2276; .conditional = "false"; .direct = "true";
                 .target = "stmts:c/WxqFxXSHWNzwaD8KmaZw"; .type = "Type_Call" } ] } [
       assume eq(0x9a4:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32, 0x9a4:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400400:bv32, 0x9a8:bv64) { .asm = "ldr x0, [x0, #8]" };
       call @_aarch64_eval(0x97ffffce:bv32, 0x9ac:bv64) { .asm = "bl #0xffffffffffffff38" };
       assert boolor(eq(0x8e4:bv64, $PC));
       goto (%splitclone_ext_1);
     ];
     block %splitclone_ext_1 [
       assume eq(0x8e4:bv64, $PC);
       call @createnode();
       assert boolor(eq(0x9b0:bv64, $PC), eq(0x974:bv64, $PC));
       goto (%splitclone_code_8,%splitclone_code_5);
     ];
     block %splitclone_code_5 { .address = 2420;
         .gtirb_block = "pao7tNGFTG2/wwL2A6BKrQ";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "internal:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x974:bv64, $PC);
       call @_aarch64_eval(0xaa0003e1:bv32, 0x974:bv64) { .asm = "mov x1, x0" };
       call @_aarch64_eval(0xf94013e0:bv32, 0x978:bv64) { .asm = "ldr x0, [sp, #0x20]" };
       call @_aarch64_eval(0xf9000001:bv32, 0x97c:bv64) { .asm = "str x1, [x0]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0x980:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400003:bv32, 0x984:bv64) { .asm = "ldr x3, [x0]" };
       call @_aarch64_eval(0xf94013e0:bv32, 0x988:bv64) { .asm = "ldr x0, [sp, #0x20]" };
       call @_aarch64_eval(0xf9400000:bv32, 0x98c:bv64) { .asm = "ldr x0, [x0]" };
       call @_aarch64_eval(0xf9400fe2:bv32, 0x990:bv64) { .asm = "ldr x2, [sp, #0x18]" };
       call @_aarch64_eval(0xaa0003e1:bv32, 0x994:bv64) { .asm = "mov x1, x0" };
       call @_aarch64_eval(0xaa0303e0:bv32, 0x998:bv64) { .asm = "mov x0, x3" };
       call @_aarch64_eval(0x97ffffde:bv32, 0x99c:bv64) { .asm = "bl #0xffffffffffffff78" };
       assert boolor(eq(0x914:bv64, $PC));
       goto (%splitclone_code_3);
     ];
     block %splitclone_code_8 { .address = 2480;
         .gtirb_block = "9oceKFiPSN69RSkX65b7GQ";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "internal:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x9b0:bv64, $PC);
       call @_aarch64_eval(0xaa0003e1:bv32, 0x9b0:bv64) { .asm = "mov x1, x0" };
       call @_aarch64_eval(0xf9400fe0:bv32, 0x9b4:bv64) { .asm = "ldr x0, [sp, #0x18]" };
       call @_aarch64_eval(0xf9000001:bv32, 0x9b8:bv64) { .asm = "str x1, [x0]" };
       call @_aarch64_eval(0xf94017e0:bv32, 0x9bc:bv64) { .asm = "ldr x0, [sp, #0x28]" };
       call @_aarch64_eval(0xf9400003:bv32, 0x9c0:bv64) { .asm = "ldr x3, [x0]" };
       call @_aarch64_eval(0xf9400fe0:bv32, 0x9c4:bv64) { .asm = "ldr x0, [sp, #0x18]" };
       call @_aarch64_eval(0xf9400000:bv32, 0x9c8:bv64) { .asm = "ldr x0, [x0]" };
       call @_aarch64_eval(0xaa0003e2:bv32, 0x9cc:bv64) { .asm = "mov x2, x0" };
       call @_aarch64_eval(0xf94013e1:bv32, 0x9d0:bv64) { .asm = "ldr x1, [sp, #0x20]" };
       call @_aarch64_eval(0xaa0303e0:bv32, 0x9d4:bv64) { .asm = "mov x0, x3" };
       call @_aarch64_eval(0x97ffffcf:bv32, 0x9d8:bv64) { .asm = "bl #0xffffffffffffff3c" };
       assert boolor(eq(0x914:bv64, $PC));
       goto (%splitclone_code_3);
     ]
  ];
  prog entry @_start { .initial_memory = [ { .address = 0;
              .bytes = "A#\000\000\000aeabi_feature_and_bits\000\001\000\000\000\001\000\002\000";
              .name = ".ARM.attributes"; .read_only = true; .size = 36 };
          { .address = 568;
              .bytes = [ "H4sIAAAAAAAA/wFuAJH/L25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliL2xkLWxpbnV4LWFhcmNoNjQuc28uMQA6rjEIbgAAAA==" ];
              .name = ".interp"; .read_only = true; .size = 110 };
          { .address = 680;
              .bytes = "\003\000\000\000\011\000\000\000\007\000\000\000\n\000\000\000\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\005\000\000\000\000\000\000\000\006\000\000\000\004\000\000\000\t\000\000\000";
              .name = ".hash"; .read_only = true; .size = 64 };
          { .address = 744;
              .bytes = "\001\000\000\000\001\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
              .name = ".gnu.hash"; .read_only = true; .size = 28 };
          { .address = 776;
              .bytes = [ "H4sIAAAAAAAA/wEIAff+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMACgAQBwAAAAAAAAAAAAAAAAAAAAAAAAMAFwAwAAIAAAAAAAAAAAAAAAAADQAAABIAAAAAAAAAAAAAAAAAAAAAAAAAHwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAHwAAACIAAAAAAAAAAAAAAAAAAAAAAAAABgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAOwEAACAAAAAAAAAAAAAAAAAAAAAAAAAALgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAAAAAAAAAAAAAAAASgEAACAAAAAAAAAAAAAAAAAAAAAAAAAAFQpBtwgBAAA=" ];
              .name = ".dynsym"; .read_only = true; .size = 264 };
          { .address = 1040;
              .bytes = [ "H4sIAAAAAAAA/wFkAZv+AGZyZWUAbWFsbG9jAF9fbGliY19zdGFydF9tYWluAF9fY3hhX2ZpbmFsaXplAGFib3J0AGxpYmMuc28uNgBHTElCQ18yLjE3AEdMSUJDXzIuMzQAL25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliOi9uaXgvc3RvcmUvbGd3cTB6eWhzZjB2eGcyMHI1ajJnMW13cnJyc3lncWctYWFyY2g2NC11bmtub3duLWxpbnV4LWdudS1nY2MtMTUuMy4wLWxpYi9hYXJjaDY0LXVua25vd24tbGludXgtZ251L2xpYgBfSVRNX2RlcmVnaXN0ZXJUTUNsb25lVGFibGUAX19nbW9uX3N0YXJ0X18AX0lUTV9yZWdpc3RlclRNQ2xvbmVUYWJsZQCIWUk9ZAEAAA==" ];
              .name = ".dynstr"; .read_only = true; .size = 356 };
          { .address = 1396;
              .bytes = "\000\000\000\000\000\000\002\000\000\000\003\000\003\000\000\000\003\000\003\000\000\000";
              .name = ".gnu.version"; .read_only = true; .size = 22 };
          { .address = 1424;
              .bytes = "\001\000\002\0004\000\000\000\016\000\000\000\000\000\000\000\151\145\150\006\000\000\003\000>\000\000\000\016\000\000\000\180\145\150\006\000\000\002\000I\000\000\000\000\000\000\000";
              .name = ".gnu.version_r"; .read_only = true; .size = 48 };
          { .address = 1472;
              .bytes = [ "H4sIAAAAAAAA/wHAAD//qP0BAAAAAAADBAAAAAAAAOAIAAAAAAAAsP0BAAAAAAADBAAAAAAAAIwIAAAAAAAA2P8BAAAAAAADBAAAAAAAAHAKAAAAAAAAOAACAAAAAAADBAAAAAAAADgAAgAAAAAAwP8BAAAAAAABBAAABAAAAAAAAAAAAAAAyP8BAAAAAAABBAAABQAAAAAAAAAAAAAA0P8BAAAAAAABBAAABwAAAAAAAAAAAAAA4P8BAAAAAAABBAAACgAAAAAAAAAAAAAAQgFGTsAAAAA=" ];
              .name = ".rela.dyn"; .read_only = true; .size = 192 };
          { .address = 1664;
              .bytes = [ "H4sIAAAAAAAA/wGQAG//AAACAAAAAAACBAAAAwAAAAAAAAAAAAAACAACAAAAAAACBAAABQAAAAAAAAAAAAAAEAACAAAAAAACBAAABgAAAAAAAAAAAAAAGAACAAAAAAACBAAABwAAAAAAAAAAAAAAIAACAAAAAAACBAAACAAAAAAAAAAAAAAAKAACAAAAAAACBAAACQAAAAAAAAAAAAAA+1ZZqJAAAAA=" ];
              .name = ".rela.plt"; .read_only = true; .size = 144 };
          { .address = 1808;
              .bytes = "?#\003\213\253{\191\169\253\003\000\1456\000\000\148\253{\193\168\191#\003\213\192\003_\214";
              .name = ".init"; .read_only = true; .size = 28 };
          { .address = 1840;
              .bytes = [ "H4sIAAAAAAAA/wGAAH//8Hu/qfAAAPAR/kf5EOI/kSACH9YfIAPVHyAD1R8gA9UQAQCQEQJA+RACAJEgAh/WEAEAkBEGQPkQIgCRIAIf1hABAJARCkD5EEIAkSACH9YQAQCQEQ5A+RBiAJEgAh/WEAEAkBESQPkQggCRIAIf1hABAJARFkD5EKIAkSACH9YwvoyYgAAAAA==" ];
              .name = ".plt"; .read_only = true; .size = 128 };
          { .address = 1984;
              .bytes = [ "H4sIAAAAAAAA/wHEAjv9XyQD1R0AgNIeAIDS5QMAquEDQPniIwCR5gMAkeAAAPAA7Ef5AwCA0gQAgNLZ//+X6P//l+AAAPAA6Ef5QAAAtOD//xfAA1/WHyAD1R8gA9UfIAPVHyAD1R8gA9UfIAPVAAEAkAAAAZEBAQCQIQABkT8AAOvAAABU4QAA8CHgR/lhAAC08AMBqgACH9bAA1/WAAEAkAAAAZEBAQCQIQABkSEAAMsi/H/TQQyBiyH8QZPBAAC04gAA8ELwR/liAAC08AMCqgACH9bAA1/W/Xu+qf0DAJHzCwD5EwEAkGACQTlAAQA34AAA8ADkR/mAAAC0AAEAkAAcQPmq//+X2f//lyAAgFJgAgE58wtA+f17wqjAA1/WHyAD1R8gA9UfIAPV3P//F/17van9AwCR4A8A+QACgNKf//+X4BcA+eAXQPnhD0D5AQQA+eAXQPn9e8OowANf1v17van9AwCR4BcA+eETAPniDwD54BdA+R8AAPEBAQBU4A9A+R8AAPngD0D5AQBA+eATQPkBAAD5JAAAFOAXQPkABED5AABAuQAAABIfAABxAAIAVOAXQPkABED53f//l+EDAKrgE0D5AQAA+eAXQPkDAED54BNA+QAAQPniD0D54QMAquADA6re//+XDwAAFOAXQPkABED5zv//l+EDAKrgD0D5AQAA+eAXQPkDAED54A9A+QAAQPniAwCq4RNA+eADA6rP//+X/XvDqMADX9b9e7yp/QMAkeAPAPnhowCR4MMAkeIDAarhAwCq4A9A+cT//5cIAAAU4BtA+QAAQPngHwD54BtA+WH//5fgH0D54BsA+eAbQPkfAADx4f7/VAgAABTgF0D5AABA+eAfAPngF0D5Vv//l+AfQPngFwD54BdA+R8AAPHh/v9UHyAD1R8gA9X9e8SowANf1v17v6n9AwCRAACAUv17wajAA1/WjSxVfMQCAAA=" ];
              .name = ".text"; .read_only = true; .size = 708 };
          { .address = 2692;
              .bytes = "?#\003\213\253{\191\169\253\003\000\145\253{\193\168\191#\003\213\192\003_\214";
              .name = ".fini"; .read_only = true; .size = 24 };
          { .address = 2716; .bytes = "\001\000\002\000"; .name = ".rodata";
              .read_only = true; .size = 4 };
          { .address = 2720;
              .bytes = [ "H4sIAAAAAAAA/wFUAKv/ARsDO1QAAAAJAAAAIP3//2wAAACA/f//gAAAALD9//+UAAAA7P3//6gAAABA/v//zAAAAET+///gAAAAdP7//wABAABE////IAEAAND///9AAQAAppmyHFQAAAA=" ];
              .name = ".eh_frame_hdr"; .read_only = true; .size = 84 };
          { .address = 2808;
              .bytes = [ "H4sIAAAAAAAA/wEMAfP+EAAAAAAAAAABelIABHgeARsMHwAQAAAAGAAAAKz8//80AAAAAEEHHhAAAAAsAAAA+Pz//zAAAAAAAAAAEAAAAEAAAAAU/f//PAAAAAAAAAAgAAAAVAAAADz9//9IAAAAAEEOIJ0EngNCkwJO3t3TDgAAAAAQAAAAeAAAAGz9//8EAAAAAAAAABwAAACMAAAAXP3//zAAAAAAQQ4wnQaeBUre3Q4AAAAAHAAAAKwAAABs/f//0AAAAABBDjCdBp4Fct7dDgAAAAAcAAAAzAAAABz+//+MAAAAAEEOQJ0Ingdh3t0OAAAAABwAAADsAAAAiP7//xQAAAAAQQ4QnQKeAUPe3Q4AAAAAAAAAAASF1OcMAQAA" ];
              .name = ".eh_frame"; .read_only = true; .size = 268 };
          { .address = 3076;
              .bytes = "\004\000\000\000\016\000\000\000\001\000\000\000GNU\000\000\000\000\000\003\000\000\000\n\000\000\000\000\000\000\000";
              .name = ".note.ABI-tag"; .read_only = true; .size = 32 };
          { .address = 130472; .bytes = "\224\b\000\000\000\000\000\000";
              .name = ".init_array"; .size = 8 };
          { .address = 130480; .bytes = "\140\b\000\000\000\000\000\000";
              .name = ".fini_array"; .size = 8 };
          { .address = 130488;
              .bytes = [ "H4sIAAAAAAAA/wEAAv/9AQAAAAAAAAA0AAAAAAAAAB0AAAAAAAAAVAAAAAAAAAAMAAAAAAAAABAHAAAAAAAADQAAAAAAAACECgAAAAAAABkAAAAAAAAAqP0BAAAAAAAbAAAAAAAAAAgAAAAAAAAAGgAAAAAAAACw/QEAAAAAABwAAAAAAAAACAAAAAAAAAAEAAAAAAAAAKgCAAAAAAAA9f7/bwAAAADoAgAAAAAAAAUAAAAAAAAAEAQAAAAAAAAGAAAAAAAAAAgDAAAAAAAACgAAAAAAAABkAQAAAAAAAAsAAAAAAAAAGAAAAAAAAAAVAAAAAAAAAAAAAAAAAAAAAwAAAAAAAADo/wEAAAAAAAIAAAAAAAAAkAAAAAAAAAAUAAAAAAAAAAcAAAAAAAAAFwAAAAAAAACABgAAAAAAAAcAAAAAAAAAwAUAAAAAAAAIAAAAAAAAAMAAAAAAAAAACQAAAAAAAAAYAAAAAAAAAPv//28AAAAAAAAACAAAAAD+//9vAAAAAJAFAAAAAAAA////bwAAAAABAAAAAAAAAPD//28AAAAAdAUAAAAAAAD5//9vAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD9SkqTAAIAAA==" ];
              .name = ".dynamic"; .size = 512 };
          { .address = 131000;
              .bytes = "\184\253\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000p\n\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
              .name = ".got"; .size = 48 };
          { .address = 131048;
              .bytes = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\000";
              .name = ".got.plt"; .size = 72 };
          { .address = 131120;
              .bytes = "\000\000\000\000\000\000\000\0008\000\002\000\000\000\000\000";
              .name = ".data"; .size = 16 };
          { .address = 131136; .bytes = ""; .name = ".bss"; .size = 8 } ];
      .invariants = [ "GtirbArm" ] };
  |}]
