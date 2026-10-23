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
  Lang.Program.pretty_to_chan stdout prog;
  [%expect
    {|
    var observable $mem:(bv64->bv8);
    proc @main(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1, PSTATE_V_in:bv1,
       PSTATE_Z_in:bv1, R0_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
       -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1,
       PSTATE_Z_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64, R30_out:bv64,
       SP_out:bv64) {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)
      requires boolor(eq(0x864:bv64, PC_in:bv64))

    [
       block %inputs [
         (var PC_1:bv64 := PC_in:bv64, var PSTATE_C_1:bv1 := PSTATE_C_in:bv1,
          var PSTATE_N_1:bv1 := PSTATE_N_in:bv1, var PSTATE_V_1:bv1 := PSTATE_V_in:bv1,
          var PSTATE_Z_1:bv1 := PSTATE_Z_in:bv1, var R0_1:bv64 := R0_in:bv64,
          var R1_1:bv64 := R1_in:bv64, var R29_1:bv64 := R29_in:bv64,
          var R30_1:bv64 := R30_in:bv64, var SP_1:bv64 := SP_in:bv64);
         goto (%main_code);
       ];
       block %main_code { .address = 2148; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 2172; .conditional = "true"; .direct = "true";
                   .target = "internal:rlVqjjqoR6uHwOYvPCS15g";
                   .type = "Type_Fallthrough" };
               { .address = 2212; .conditional = "true"; .direct = "true";
                   .target = "internal:gFBdrsFTRkSCdIsDFMk6qA"; .type = "Type_Branch" } ] } [
         var PC_2:bv64 := PC_1:bv64;
         assume eq(0x864:bv64, PC_2:bv64);
         goto (%block);
       ];
       block %block { .asm = "stp x29, x30, [sp, #-0x30]!" } [
         var local_35:bv64 := 0x0:bv64;
         var local_36:bv64 := SP_1:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP_1:bv64,
          0xffffffffffffffd0:bv64) R29_1:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP_1:bv64,
           0xffffffffffffffd0:bv64), 0x8:bv64) R30_1:bv64 64;
         var SP_2:bv64 := bvadd(local_36:bv64, 0xffffffffffffffd0:bv64);
         (var BranchTaken:bool := false, var PC_3:bv64 := 0x868:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "mov x29, sp" } [
         var local_37:bv64 := 0x0:bv64;
         var R29_2:bv64 := bvadd(SP_2:bv64, 0x0:bv64);
         (var BranchTaken_1:bool := false, var PC_4:bv64 := 0x86c:bv64);
         goto (%block_2);
       ];
       block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP_2:bv64, 0x1c:bv64) extract(32,0, R0_1:bv64) 32;
         (var BranchTaken_2:bool := false, var PC_5:bv64 := 0x870:bv64);
         goto (%block_3);
       ];
       block %block_3 { .asm = "ldr w0, [sp, #0x1c]" } [
         var local_38:bv32 := 0x0:bv32;
         var local_39:bv32 := load le $mem:(bv64->bv8) bvadd(SP_2:bv64, 0x1c:bv64) 32;
         var local_40:bv32 := local_39:bv32;
         var R0_2:bv64 := zero_extend(32, zero_extend(0, local_40:bv32));
         (var BranchTaken_3:bool := false, var PC_6:bv64 := 0x874:bv64);
         goto (%block_4);
       ];
       block %block_4 { .asm = "cmp w0, #0" } [
         var local_41:bv32 := 0x0:bv32;
         var local_42:bv32 := 0x0:bv32;
         var PSTATE_V_2:bv1 := bvnot(booltobv1(eq(sign_extend(32,
            bvadd(bvadd(extract(32,0, R0_2:bv64), 0xffffffff:bv32), 0x1:bv32)),
            bvadd(bvadd(sign_extend(32, extract(32,0, R0_2:bv64)),
              0xffffffffffffffff:bv64), 0x1:bv64))));
         var PSTATE_C_2:bv1 := bvnot(booltobv1(eq(zero_extend(32,
            bvadd(bvadd(extract(32,0, R0_2:bv64), 0xffffffff:bv32), 0x1:bv32)),
            bvadd(bvadd(zero_extend(32, extract(32,0, R0_2:bv64)), 0xffffffff:bv64),
             0x1:bv64))));
         var PSTATE_Z_2:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, R0_2:bv64),
             0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
         var PSTATE_N_2:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, R0_2:bv64),
           0xffffffff:bv32), 0x1:bv32));
         (var BranchTaken_4:bool := false, var PC_7:bv64 := 0x878:bv64);
         goto (%block_5);
       ];
       block %block_5 { .asm = "b.eq #0x2c" } [ goto (%block_7,%block_6); ];
       block %block_6 [
         var PSTATE_Z_5:bv1 := PSTATE_Z_2:bv1;
         assume eq(PSTATE_Z_5:bv1, 0x1:bv1);
         var BranchTaken_33:bool := true;
         var PC_45:bv64 := 0x8a4:bv64;
         goto (%block_8);
       ];
       block %block_7 [
         var PSTATE_Z_4:bv1 := PSTATE_Z_2:bv1;
         assume boolnot(eq(PSTATE_Z_4:bv1, 0x1:bv1));
         (var BranchTaken_32:bool := false, var PC_44:bv64 := 0x87c:bv64);
         goto (%block_8);
       ];
       block %block_8 (
         var PSTATE_Z_3:bv1 := phi(%block_7 -> PSTATE_Z_4:bv1,
            %block_6 -> PSTATE_Z_5:bv1),
         var PC_8:bv64 := phi(%block_7 -> PC_44:bv64, %block_6 -> PC_45:bv64)
       ) [
         var PC_9:bv64 := if eq(PSTATE_Z_3:bv1, 0x1:bv1) then 0x8a4:bv64 else 0x87c:bv64;
         goto (%main_code_4);
       ];
       block %main_code_4 [
         var PC_10:bv64 := PC_9:bv64;
         assert boolor(eq(0x87c:bv64, PC_10:bv64), eq(0x8a4:bv64, PC_10:bv64));
         goto (%main_code_2,%main_code_1);
       ];
       block %main_code_1 { .address = 2212; .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w";
                   .type = "Type_Fallthrough" } ] } [
         var PC_33:bv64 := PC_10:bv64;
         assume eq(0x8a4:bv64, PC_33:bv64);
         goto (%block_9);
       ];
       block %block_9 { .asm = "adrp x0, #0x20000" } [
         var R0_11:bv64 := 0x20000:bv64;
         (var BranchTaken_23:bool := false, var PC_34:bv64 := 0x8a8:bv64);
         goto (%block_10);
       ];
       block %block_10 { .asm = "add x0, x0, #0x40" } [
         var local_71:bv64 := 0x0:bv64;
         var local_72:bv64 := 0x0:bv64;
         var local_73:bv64 := R0_11:bv64;
         var R0_12:bv64 := bvadd(local_73:bv64, 0x40:bv64);
         (var BranchTaken_24:bool := false, var PC_35:bv64 := 0x8ac:bv64);
         goto (%block_11);
       ];
       block %block_11 { .asm = "add x1, sp, #0x28" } [
         var local_74:bv64 := 0x0:bv64;
         var R1_8:bv64 := bvadd(SP_2:bv64, 0x28:bv64);
         (var BranchTaken_25:bool := false, var PC_36:bv64 := 0x8b0:bv64);
         goto (%block_12);
       ];
       block %block_12 { .asm = "str x1, [x0]" } [
         var local_75:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0_12:bv64, 0x0:bv64) R1_8:bv64 64;
         (var BranchTaken_26:bool := false, var PC_37:bv64 := 0x8b4:bv64);
         goto (%block_13);
       ];
       block %block_13 { .asm = "adrp x0, #0x20000" } [
         var R0_13:bv64 := 0x20000:bv64;
         (var BranchTaken_27:bool := false, var PC_38:bv64 := 0x8b8:bv64);
         goto (%block_14);
       ];
       block %block_14 { .asm = "add x0, x0, #0x48" } [
         var local_76:bv64 := 0x0:bv64;
         var local_77:bv64 := 0x0:bv64;
         var local_78:bv64 := R0_13:bv64;
         var R0_14:bv64 := bvadd(local_78:bv64, 0x48:bv64);
         (var BranchTaken_28:bool := false, var PC_39:bv64 := 0x8bc:bv64);
         goto (%block_15);
       ];
       block %block_15 { .asm = "adrp x1, #0x20000" } [
         var R1_9:bv64 := 0x20000:bv64;
         (var BranchTaken_29:bool := false, var PC_40:bv64 := 0x8c0:bv64);
         goto (%block_16);
       ];
       block %block_16 { .asm = "add x1, x1, #0x40" } [
         var local_79:bv64 := 0x0:bv64;
         var local_80:bv64 := 0x0:bv64;
         var local_81:bv64 := R1_9:bv64;
         var R1_10:bv64 := bvadd(local_81:bv64, 0x40:bv64);
         (var BranchTaken_30:bool := false, var PC_41:bv64 := 0x8c4:bv64);
         goto (%block_17);
       ];
       block %block_17 { .asm = "str x1, [x0]" } [
         var local_82:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0_14:bv64, 0x0:bv64) R1_10:bv64 64;
         (var BranchTaken_31:bool := false, var PC_42:bv64 := 0x8c8:bv64);
         goto (%main_code_5);
       ];
       block %main_code_5 [
         var PC_43:bv64 := PC_42:bv64;
         assert boolor(eq(0x8c8:bv64, PC_43:bv64));
         goto (%main_code_3);
       ];
       block %main_code_2 { .address = 2172; .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w"; .type = "Type_Branch" } ] } [
         var PC_21:bv64 := PC_10:bv64;
         assume eq(0x87c:bv64, PC_21:bv64);
         goto (%block_18);
       ];
       block %block_18 { .asm = "adrp x0, #0x20000" } [
         var R0_7:bv64 := 0x20000:bv64;
         (var BranchTaken_13:bool := false, var PC_22:bv64 := 0x880:bv64);
         goto (%block_19);
       ];
       block %block_19 { .asm = "add x0, x0, #0x38" } [
         var local_59:bv64 := 0x0:bv64;
         var local_60:bv64 := 0x0:bv64;
         var local_61:bv64 := R0_7:bv64;
         var R0_8:bv64 := bvadd(local_61:bv64, 0x38:bv64);
         (var BranchTaken_14:bool := false, var PC_23:bv64 := 0x884:bv64);
         goto (%block_20);
       ];
       block %block_20 { .asm = "add x1, sp, #0x2c" } [
         var local_62:bv64 := 0x0:bv64;
         var R1_5:bv64 := bvadd(SP_2:bv64, 0x2c:bv64);
         (var BranchTaken_15:bool := false, var PC_24:bv64 := 0x888:bv64);
         goto (%block_21);
       ];
       block %block_21 { .asm = "str x1, [x0]" } [
         var local_63:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0_8:bv64, 0x0:bv64) R1_5:bv64 64;
         (var BranchTaken_16:bool := false, var PC_25:bv64 := 0x88c:bv64);
         goto (%block_22);
       ];
       block %block_22 { .asm = "adrp x0, #0x20000" } [
         var R0_9:bv64 := 0x20000:bv64;
         (var BranchTaken_17:bool := false, var PC_26:bv64 := 0x890:bv64);
         goto (%block_23);
       ];
       block %block_23 { .asm = "add x0, x0, #0x48" } [
         var local_64:bv64 := 0x0:bv64;
         var local_65:bv64 := 0x0:bv64;
         var local_66:bv64 := R0_9:bv64;
         var R0_10:bv64 := bvadd(local_66:bv64, 0x48:bv64);
         (var BranchTaken_18:bool := false, var PC_27:bv64 := 0x894:bv64);
         goto (%block_24);
       ];
       block %block_24 { .asm = "adrp x1, #0x20000" } [
         var R1_6:bv64 := 0x20000:bv64;
         (var BranchTaken_19:bool := false, var PC_28:bv64 := 0x898:bv64);
         goto (%block_25);
       ];
       block %block_25 { .asm = "add x1, x1, #0x38" } [
         var local_67:bv64 := 0x0:bv64;
         var local_68:bv64 := 0x0:bv64;
         var local_69:bv64 := R1_6:bv64;
         var R1_7:bv64 := bvadd(local_69:bv64, 0x38:bv64);
         (var BranchTaken_20:bool := false, var PC_29:bv64 := 0x89c:bv64);
         goto (%block_26);
       ];
       block %block_26 { .asm = "str x1, [x0]" } [
         var local_70:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0_10:bv64, 0x0:bv64) R1_7:bv64 64;
         (var BranchTaken_21:bool := false, var PC_30:bv64 := 0x8a0:bv64);
         goto (%block_27);
       ];
       block %block_27 { .asm = "b #0x28" } [
         var BranchTaken_22:bool := true;
         var PC_31:bv64 := 0x8c8:bv64;
         goto (%main_code_6);
       ];
       block %main_code_6 [
         var PC_32:bv64 := PC_31:bv64;
         assert boolor(eq(0x8c8:bv64, PC_32:bv64));
         goto (%main_code_3);
       ];
       block %main_code_3 { .address = 2248; .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
           .succ = [ { .conditional = "false"; .direct = "false";
                   .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } (
         var R1_2:bv64 := phi(%main_code_6 -> R1_7:bv64, %main_code_5 -> R1_10:bv64),
         var R0_3:bv64 := phi(%main_code_6 -> R0_10:bv64, %main_code_5 -> R0_14:bv64),
         var PC_11:bv64 := phi(%main_code_6 -> PC_32:bv64, %main_code_5 -> PC_43:bv64)
       ) [
         var PC_12:bv64 := PC_11:bv64;
         assume eq(0x8c8:bv64, PC_12:bv64);
         goto (%block_28);
       ];
       block %block_28 { .asm = "adrp x0, #0x20000" } [
         var R0_4:bv64 := 0x20000:bv64;
         (var BranchTaken_5:bool := false, var PC_13:bv64 := 0x8cc:bv64);
         goto (%block_29);
       ];
       block %block_29 { .asm = "add x0, x0, #0x50" } [
         var local_43:bv64 := 0x0:bv64;
         var local_44:bv64 := 0x0:bv64;
         var local_45:bv64 := R0_4:bv64;
         var R0_5:bv64 := bvadd(local_45:bv64, 0x50:bv64);
         (var BranchTaken_6:bool := false, var PC_14:bv64 := 0x8d0:bv64);
         goto (%block_30);
       ];
       block %block_30 { .asm = "adrp x1, #0x20000" } [
         var R1_3:bv64 := 0x20000:bv64;
         (var BranchTaken_7:bool := false, var PC_15:bv64 := 0x8d4:bv64);
         goto (%block_31);
       ];
       block %block_31 { .asm = "add x1, x1, #0x58" } [
         var local_46:bv64 := 0x0:bv64;
         var local_47:bv64 := 0x0:bv64;
         var local_48:bv64 := R1_3:bv64;
         var R1_4:bv64 := bvadd(local_48:bv64, 0x58:bv64);
         (var BranchTaken_8:bool := false, var PC_16:bv64 := 0x8d8:bv64);
         goto (%block_32);
       ];
       block %block_32 { .asm = "str x1, [x0]" } [
         var local_49:bv64 := 0x0:bv64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0_5:bv64, 0x0:bv64) R1_4:bv64 64;
         (var BranchTaken_9:bool := false, var PC_17:bv64 := 0x8dc:bv64);
         goto (%block_33);
       ];
       block %block_33 { .asm = "mov w0, #0" } [
         var R0_6:bv64 := 0x0:bv64;
         (var BranchTaken_10:bool := false, var PC_18:bv64 := 0x8e0:bv64);
         goto (%block_34);
       ];
       block %block_34 { .asm = "ldp x29, x30, [sp], #0x30" } [
         var local_50:bv64 := 0x0:bv64;
         var local_51:bv64 := SP_2:bv64;
         var local_52:bv64 := 0x0:bv64;
         var local_53:bv64 := load le $mem:(bv64->bv8) SP_2:bv64 64;
         var local_54:bv64 := local_53:bv64;
         var local_55:bv64 := 0x0:bv64;
         var local_56:bv64 := load le $mem:(bv64->bv8) bvadd(SP_2:bv64, 0x8:bv64) 64;
         var local_57:bv64 := local_56:bv64;
         var R29_3:bv64 := local_54:bv64;
         var R30_2:bv64 := local_57:bv64;
         var SP_3:bv64 := bvadd(local_51:bv64, 0x30:bv64);
         (var BranchTaken_11:bool := false, var PC_19:bv64 := 0x8e4:bv64);
         goto (%block_35);
       ];
       block %block_35 { .asm = "ret " } [
         var local_58:bv64 := 0x0:bv64;
         var BTypeNext:bv2 := 0x0:bv2;
         var BranchTaken_12:bool := true;
         var PC_20:bv64 := R30_2:bv64;
         goto (%main_code_7);
       ];
       block %main_code_7 [ assert false; goto (%ret_4); ];
       block %ret_4 [ goto (%returns); ];
       block %returns [
         (var PC_out_1:bv64 := PC_20:bv64, var PSTATE_C_out_1:bv1 := PSTATE_C_2:bv1,
          var PSTATE_N_out_1:bv1 := PSTATE_N_2:bv1,
          var PSTATE_V_out_1:bv1 := PSTATE_V_2:bv1,
          var PSTATE_Z_out_1:bv1 := PSTATE_Z_3:bv1, var R0_out_1:bv64 := R0_6:bv64,
          var R1_out_1:bv64 := R1_4:bv64, var R29_out_1:bv64 := R29_3:bv64,
          var R30_out_1:bv64 := R30_2:bv64, var SP_out_1:bv64 := SP_3:bv64);
         goto (%Return);
       ];
       block %Return [
         (var PC_out:bv64 := PC_out_1:bv64, var PSTATE_C_out:bv1 := PSTATE_C_out_1:bv1,
          var PSTATE_N_out:bv1 := PSTATE_N_out_1:bv1,
          var PSTATE_V_out:bv1 := PSTATE_V_out_1:bv1,
          var PSTATE_Z_out:bv1 := PSTATE_Z_out_1:bv1, var R0_out:bv64 := R0_out_1:bv64,
          var R1_out:bv64 := R1_out_1:bv64, var R29_out:bv64 := R29_out_1:bv64,
          var R30_out:bv64 := R30_out_1:bv64, var SP_out:bv64 := SP_out_1:bv64);
         return;
       ]
    ];
    prog entry @main { .initial_memory = [ { .address = 0;
                .bytes = "A#\000\000\000aeabi_feature_and_bits\000\001\000\000\000\001\000\002\000";
                .name = ".ARM.attributes"; .read_only = true; .size = 36 };
            { .address = 568;
                .bytes = [ "H4sIAAAAAAAA/wFuAJH/L25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliL2xkLWxpbnV4LWFhcmNoNjQuc28uMQA6rjEIbgAAAA==" ];
                .name = ".interp"; .read_only = true; .size = 110 };
            { .address = 680;
                .bytes = "\003\000\000\000\t\000\000\000\006\000\000\000\b\000\000\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\005\000\000\000\004\000\000\000";
                .name = ".hash"; .read_only = true; .size = 56 };
            { .address = 736;
                .bytes = "\001\000\000\000\001\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
                .name = ".gnu.hash"; .read_only = true; .size = 28 };
            { .address = 768;
                .bytes = [ "H4sIAAAAAAAA/wHYACf/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMACgCYBgAAAAAAAAAAAAAAAAAAAAAAAAMAFwAgAAIAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAAAAAAAAAAAAAAAAEwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAEwAAACIAAAAAAAAAAAAAAAAAAAAAAAAALwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAIgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAPgEAACAAAAAAAAAAAAAAAAAAAAAAAAAAXSa/DdgAAAA=" ];
                .name = ".dynsym"; .read_only = true; .size = 216 };
            { .address = 984;
                .bytes = [ "H4sIAAAAAAAA/wFYAaf+AF9fbGliY19zdGFydF9tYWluAF9fY3hhX2ZpbmFsaXplAGFib3J0AGxpYmMuc28uNgBHTElCQ18yLjE3AEdMSUJDXzIuMzQAL25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliOi9uaXgvc3RvcmUvbGd3cTB6eWhzZjB2eGcyMHI1ajJnMW13cnJyc3lncWctYWFyY2g2NC11bmtub3duLWxpbnV4LWdudS1nY2MtMTUuMy4wLWxpYi9hYXJjaDY0LXVua25vd24tbGludXgtZ251L2xpYgBfSVRNX2RlcmVnaXN0ZXJUTUNsb25lVGFibGUAX19nbW9uX3N0YXJ0X18AX0lUTV9yZWdpc3RlclRNQ2xvbmVUYWJsZQCwqp3YWAEAAA==" ];
                .name = ".dynstr"; .read_only = true; .size = 344 };
            { .address = 1328;
                .bytes = "\000\000\000\000\000\000\002\000\000\000\003\000\000\000\003\000\000\000";
                .name = ".gnu.version"; .read_only = true; .size = 18 };
            { .address = 1352;
                .bytes = "\001\000\002\000(\000\000\000\016\000\000\000\000\000\000\000\151\145\150\006\000\000\003\0002\000\000\000\016\000\000\000\180\145\150\006\000\000\002\000=\000\000\000\000\000\000\000";
                .name = ".gnu.version_r"; .read_only = true; .size = 48 };
            { .address = 1400;
                .bytes = [ "H4sIAAAAAAAA/wHAAD//qP0BAAAAAAADBAAAAAAAAGAIAAAAAAAAsP0BAAAAAAADBAAAAAAAAAwIAAAAAAAA2P8BAAAAAAADBAAAAAAAAGQIAAAAAAAAKAACAAAAAAADBAAAAAAAACgAAgAAAAAAwP8BAAAAAAABBAAABAAAAAAAAAAAAAAAyP8BAAAAAAABBAAABQAAAAAAAAAAAAAA0P8BAAAAAAABBAAABgAAAAAAAAAAAAAA4P8BAAAAAAABBAAACAAAAAAAAAAAAAAAOZNqkMAAAAA=" ];
                .name = ".rela.dyn"; .read_only = true; .size = 192 };
            { .address = 1592;
                .bytes = [ "H4sIAAAAAAAA/wFgAJ//AAACAAAAAAACBAAAAwAAAAAAAAAAAAAACAACAAAAAAACBAAABQAAAAAAAAAAAAAAEAACAAAAAAACBAAABgAAAAAAAAAAAAAAGAACAAAAAAACBAAABwAAAAAAAAAAAAAAjr0A5WAAAAA=" ];
                .name = ".rela.plt"; .read_only = true; .size = 96 };
            { .address = 1688;
                .bytes = "?#\003\213\253{\191\169\253\003\000\1454\000\000\148\253{\193\168\191#\003\213\192\003_\214";
                .name = ".init"; .read_only = true; .size = 28 };
            { .address = 1728;
                .bytes = [ "H4sIAAAAAAAA/wFgAJ//8Hu/qfAAAPAR/kf5EOI/kSACH9YfIAPVHyAD1R8gA9UQAQCQEQJA+RACAJEgAh/WEAEAkBEGQPkQIgCRIAIf1hABAJARCkD5EEIAkSACH9YQAQCQEQ5A+RBiAJEgAh/WsQNY4GAAAAA=" ];
                .name = ".plt"; .read_only = true; .size = 96 };
            { .address = 1856;
                .bytes = [ "H4sIAAAAAAAA/wGoAVf+XyQD1R0AgNIeAIDS5QMAquEDQPniIwCR5gMAkeAAAPAA7Ef5AwCA0gQAgNLd//+X6P//l+AAAPAA6Ef5QAAAtOD//xfAA1/WHyAD1R8gA9UfIAPVHyAD1R8gA9UfIAPVAAEAkADAAJEBAQCQIcAAkT8AAOvAAABU4QAA8CHgR/lhAAC08AMBqgACH9bAA1/WAAEAkADAAJEBAQCQIcAAkSEAAMsi/H/TQQyBiyH8QZPBAAC04gAA8ELwR/liAAC08AMCqgACH9bAA1/W/Xu+qf0DAJHzCwD5EwEAkGDCQDlAAQA34AAA8ADkR/mAAAC0AAEAkAAUQPmu//+X2f//lyAAgFJgwgA58wtA+f17wqjAA1/WHyAD1R8gA9UfIAPV3P//F/17van9AwCR4B8AueAfQLkfAABxYAEAVAABAJAA4ACR4bMAkQEAAPkAAQCQACABkQEBAJAh4ACRAQAA+QoAABQAAQCQAAABkeGjAJEBAAD5AAEAkAAgAZEBAQCQIQABkQEAAPkAAQCQAEABkQEBAJAhYAGRAQAA+QAAgFL9e8OowANf1n8+49yoAQAA" ];
                .name = ".text"; .read_only = true; .size = 424 };
            { .address = 2280;
                .bytes = "?#\003\213\253{\191\169\253\003\000\145\253{\193\168\191#\003\213\192\003_\214";
                .name = ".fini"; .read_only = true; .size = 24 };
            { .address = 2304; .bytes = "\001\000\002\000"; .name = ".rodata";
                .read_only = true; .size = 4 };
            { .address = 2308;
                .bytes = "\001\027\003;8\000\000\000\006\000\000\000<\254\255\255P\000\000\000\156\254\255\255d\000\000\000\204\254\255\255x\000\000\000\b\255\255\255\140\000\000\000\\\255\255\255\176\000\000\000`\255\255\255\196\000\000\000";
                .name = ".eh_frame_hdr"; .read_only = true; .size = 60 };
            { .address = 2368;
                .bytes = [ "H4sIAAAAAAAA/wGsAFP/EAAAAAAAAAABelIABHgeARsMHwAQAAAAGAAAAOT9//80AAAAAEEHHhAAAAAsAAAAMP7//zAAAAAAAAAAEAAAAEAAAABM/v//PAAAAAAAAAAgAAAAVAAAAHT+//9IAAAAAEEOIJ0EngNCkwJO3t3TDgAAAAAQAAAAeAAAAKT+//8EAAAAAAAAABwAAACMAAAAlP7//4QAAAAAQQ4wnQaeBV/e3Q4AAAAAAAAAAInyb96sAAAA" ];
                .name = ".eh_frame"; .read_only = true; .size = 172 };
            { .address = 2540;
                .bytes = "\004\000\000\000\016\000\000\000\001\000\000\000GNU\000\000\000\000\000\003\000\000\000\n\000\000\000\000\000\000\000";
                .name = ".note.ABI-tag"; .read_only = true; .size = 32 };
            { .address = 130472; .bytes = "`\b\000\000\000\000\000\000";
                .name = ".init_array"; .size = 8 };
            { .address = 130480; .bytes = "\012\b\000\000\000\000\000\000";
                .name = ".fini_array"; .size = 8 };
            { .address = 130488;
                .bytes = [ "H4sIAAAAAAAA/wEAAv/9AQAAAAAAAAAoAAAAAAAAAB0AAAAAAAAASAAAAAAAAAAMAAAAAAAAAJgGAAAAAAAADQAAAAAAAADoCAAAAAAAABkAAAAAAAAAqP0BAAAAAAAbAAAAAAAAAAgAAAAAAAAAGgAAAAAAAACw/QEAAAAAABwAAAAAAAAACAAAAAAAAAAEAAAAAAAAAKgCAAAAAAAA9f7/bwAAAADgAgAAAAAAAAUAAAAAAAAA2AMAAAAAAAAGAAAAAAAAAAADAAAAAAAACgAAAAAAAABYAQAAAAAAAAsAAAAAAAAAGAAAAAAAAAAVAAAAAAAAAAAAAAAAAAAAAwAAAAAAAADo/wEAAAAAAAIAAAAAAAAAYAAAAAAAAAAUAAAAAAAAAAcAAAAAAAAAFwAAAAAAAAA4BgAAAAAAAAcAAAAAAAAAeAUAAAAAAAAIAAAAAAAAAMAAAAAAAAAACQAAAAAAAAAYAAAAAAAAAPv//28AAAAAAAAACAAAAAD+//9vAAAAAEgFAAAAAAAA////bwAAAAABAAAAAAAAAPD//28AAAAAMAUAAAAAAAD5//9vAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB5OAtTAAIAAA==" ];
                .name = ".dynamic"; .size = 512 };
            { .address = 131000;
                .bytes = "\184\253\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000d\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
                .name = ".got"; .size = 48 };
            { .address = 131048;
                .bytes = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000";
                .name = ".got.plt"; .size = 56 };
            { .address = 131104;
                .bytes = "\000\000\000\000\000\000\000\000(\000\002\000\000\000\000\000";
                .name = ".data"; .size = 16 };
            { .address = 131120; .bytes = ""; .name = ".bss"; .size = 48 } ];
        .invariants = [ "SSA"; "Params"; "GtirbArm" ] };
    |}];
  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect {|
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node0"[label="node0 U \nPar(@main_\{ Var.V.name = \"SP_in\"; typ = bv64; scope = Var.LocalVar \}) |{<0>[-48, -41]|<1>[-40, -33]|<2>[-20, -17]|<3>[-8, 3]}"];
      "node3"[label="node3 UO \nPar(@main_\{ Var.V.name = \"R0_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_39) |{<4>Top}"];
      "node5"[label="node5 U \nPar(@main_\{ Var.V.name = \"R29_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_53) |{<5>[0, 7]}"];
      "node6"[label="node6 U \nPar(@main_\{ Var.V.name = \"R30_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_56) |{<6>[0, 7]}"];
      "node0":2 -> "node3":4
      "node0":0 -> "node5":5
      "node0":1 -> "node6":6
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
  Lang.Program.pretty_to_chan stdout prog;
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in
  [%expect
    {|
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x864:bv64, $PC))

    [
       block %main_code { .address = 2148; .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
           .succ = [ { .conditional = "false"; .direct = "false";
                   .target = "proxy:1p7HOmDGQpyP3TVpJTH35g"; .type = "Type_Return" } ] } [
         assume eq(0x864:bv64, $PC);
         call @_aarch64_eval(0xa9be7bfd:bv32, 0x864:bv64) { .asm = "stp x29, x30, [sp, #-0x20]!" };
         call @_aarch64_eval(0x910003fd:bv32, 0x868:bv64) { .asm = "mov x29, sp" };
         call @_aarch64_eval(0xb9001fe0:bv32, 0x86c:bv64) { .asm = "str w0, [sp, #0x1c]" };
         call @_aarch64_eval(0x90000100:bv32, 0x870:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x9101a000:bv32, 0x874:bv64) { .asm = "add x0, x0, #0x68" };
         call @_aarch64_eval(0x90000101:bv32, 0x878:bv64) { .asm = "adrp x1, #0x20000" };
         call @_aarch64_eval(0x91018021:bv32, 0x87c:bv64) { .asm = "add x1, x1, #0x60" };
         call @_aarch64_eval(0xf9000001:bv32, 0x880:bv64) { .asm = "str x1, [x0]" };
         call @_aarch64_eval(0x90000100:bv32, 0x884:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x9100c000:bv32, 0x888:bv64) { .asm = "add x0, x0, #0x30" };
         call @_aarch64_eval(0xb9801fe1:bv32, 0x88c:bv64) { .asm = "ldrsw x1, [sp, #0x1c]" };
         call @_aarch64_eval(0xb8617800:bv32, 0x890:bv64) { .asm = "ldr w0, [x0, x1, lsl #2]" };
         call @_aarch64_eval(0xa8c27bfd:bv32, 0x894:bv64) { .asm = "ldp x29, x30, [sp], #0x20" };
         call @_aarch64_eval(0xd65f03c0:bv32, 0x898:bv64) { .asm = "ret " };
         assert false;
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main { .initial_memory = [ { .address = 0;
                .bytes = "A#\000\000\000aeabi_feature_and_bits\000\001\000\000\000\001\000\002\000";
                .name = ".ARM.attributes"; .read_only = true; .size = 36 };
            { .address = 568;
                .bytes = [ "H4sIAAAAAAAA/wFuAJH/L25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliL2xkLWxpbnV4LWFhcmNoNjQuc28uMQA6rjEIbgAAAA==" ];
                .name = ".interp"; .read_only = true; .size = 110 };
            { .address = 680;
                .bytes = "\003\000\000\000\t\000\000\000\006\000\000\000\b\000\000\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\005\000\000\000\004\000\000\000";
                .name = ".hash"; .read_only = true; .size = 56 };
            { .address = 736;
                .bytes = "\001\000\000\000\001\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
                .name = ".gnu.hash"; .read_only = true; .size = 28 };
            { .address = 768;
                .bytes = [ "H4sIAAAAAAAA/wHYACf/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMACgCYBgAAAAAAAAAAAAAAAAAAAAAAAAMAFwAgAAIAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAAAAAAAAAAAAAAAAEwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAEwAAACIAAAAAAAAAAAAAAAAAAAAAAAAALwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAIgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAPgEAACAAAAAAAAAAAAAAAAAAAAAAAAAAXSa/DdgAAAA=" ];
                .name = ".dynsym"; .read_only = true; .size = 216 };
            { .address = 984;
                .bytes = [ "H4sIAAAAAAAA/wFYAaf+AF9fbGliY19zdGFydF9tYWluAF9fY3hhX2ZpbmFsaXplAGFib3J0AGxpYmMuc28uNgBHTElCQ18yLjE3AEdMSUJDXzIuMzQAL25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliOi9uaXgvc3RvcmUvbGd3cTB6eWhzZjB2eGcyMHI1ajJnMW13cnJyc3lncWctYWFyY2g2NC11bmtub3duLWxpbnV4LWdudS1nY2MtMTUuMy4wLWxpYi9hYXJjaDY0LXVua25vd24tbGludXgtZ251L2xpYgBfSVRNX2RlcmVnaXN0ZXJUTUNsb25lVGFibGUAX19nbW9uX3N0YXJ0X18AX0lUTV9yZWdpc3RlclRNQ2xvbmVUYWJsZQCwqp3YWAEAAA==" ];
                .name = ".dynstr"; .read_only = true; .size = 344 };
            { .address = 1328;
                .bytes = "\000\000\000\000\000\000\002\000\000\000\003\000\000\000\003\000\000\000";
                .name = ".gnu.version"; .read_only = true; .size = 18 };
            { .address = 1352;
                .bytes = "\001\000\002\000(\000\000\000\016\000\000\000\000\000\000\000\151\145\150\006\000\000\003\0002\000\000\000\016\000\000\000\180\145\150\006\000\000\002\000=\000\000\000\000\000\000\000";
                .name = ".gnu.version_r"; .read_only = true; .size = 48 };
            { .address = 1400;
                .bytes = [ "H4sIAAAAAAAA/wHAAD//qP0BAAAAAAADBAAAAAAAAGAIAAAAAAAAsP0BAAAAAAADBAAAAAAAAAwIAAAAAAAA2P8BAAAAAAADBAAAAAAAAGQIAAAAAAAAKAACAAAAAAADBAAAAAAAACgAAgAAAAAAwP8BAAAAAAABBAAABAAAAAAAAAAAAAAAyP8BAAAAAAABBAAABQAAAAAAAAAAAAAA0P8BAAAAAAABBAAABgAAAAAAAAAAAAAA4P8BAAAAAAABBAAACAAAAAAAAAAAAAAAOZNqkMAAAAA=" ];
                .name = ".rela.dyn"; .read_only = true; .size = 192 };
            { .address = 1592;
                .bytes = [ "H4sIAAAAAAAA/wFgAJ//AAACAAAAAAACBAAAAwAAAAAAAAAAAAAACAACAAAAAAACBAAABQAAAAAAAAAAAAAAEAACAAAAAAACBAAABgAAAAAAAAAAAAAAGAACAAAAAAACBAAABwAAAAAAAAAAAAAAjr0A5WAAAAA=" ];
                .name = ".rela.plt"; .read_only = true; .size = 96 };
            { .address = 1688;
                .bytes = "?#\003\213\253{\191\169\253\003\000\1454\000\000\148\253{\193\168\191#\003\213\192\003_\214";
                .name = ".init"; .read_only = true; .size = 28 };
            { .address = 1728;
                .bytes = [ "H4sIAAAAAAAA/wFgAJ//8Hu/qfAAAPAR/kf5EOI/kSACH9YfIAPVHyAD1R8gA9UQAQCQEQJA+RACAJEgAh/WEAEAkBEGQPkQIgCRIAIf1hABAJARCkD5EEIAkSACH9YQAQCQEQ5A+RBiAJEgAh/WsQNY4GAAAAA=" ];
                .name = ".plt"; .read_only = true; .size = 96 };
            { .address = 1856;
                .bytes = [ "H4sIAAAAAAAA/wFcAaP+XyQD1R0AgNIeAIDS5QMAquEDQPniIwCR5gMAkeAAAPAA7Ef5AwCA0gQAgNLd//+X6P//l+AAAPAA6Ef5QAAAtOD//xfAA1/WHyAD1R8gA9UfIAPVHyAD1R8gA9UfIAPVAAEAkABgAZEBAQCQIWABkT8AAOvAAABU4QAA8CHgR/lhAAC08AMBqgACH9bAA1/WAAEAkABgAZEBAQCQIWABkSEAAMsi/H/TQQyBiyH8QZPBAAC04gAA8ELwR/liAAC08AMCqgACH9bAA1/W/Xu+qf0DAJHzCwD5EwEAkGBiQTlAAQA34AAA8ADkR/mAAAC0AAEAkAAUQPmu//+X2f//lyAAgFJgYgE58wtA+f17wqjAA1/WHyAD1R8gA9UfIAPV3P//F/17vqn9AwCR4B8AuQABAJAAoAGRAQEAkCGAAZEBAAD5AAEAkADAAJHhH4C5AHhhuP17wqjAA1/WMctUcVwBAAA=" ];
                .name = ".text"; .read_only = true; .size = 348 };
            { .address = 2204;
                .bytes = "?#\003\213\253{\191\169\253\003\000\145\253{\193\168\191#\003\213\192\003_\214";
                .name = ".fini"; .read_only = true; .size = 24 };
            { .address = 2228; .bytes = "\001\000\002\000"; .name = ".rodata";
                .read_only = true; .size = 4 };
            { .address = 2232;
                .bytes = "\001\027\003;<\000\000\000\006\000\000\000\136\254\255\255T\000\000\000\232\254\255\255h\000\000\000\024\255\255\255|\000\000\000T\255\255\255\144\000\000\000\168\255\255\255\180\000\000\000\172\255\255\255\200\000\000\000";
                .name = ".eh_frame_hdr"; .read_only = true; .size = 60 };
            { .address = 2296;
                .bytes = [ "H4sIAAAAAAAA/wGsAFP/EAAAAAAAAAABelIABHgeARsMHwAQAAAAGAAAACz+//80AAAAAEEHHhAAAAAsAAAAeP7//zAAAAAAAAAAEAAAAEAAAACU/v//PAAAAAAAAAAgAAAAVAAAALz+//9IAAAAAEEOIJ0EngNCkwJO3t3TDgAAAAAQAAAAeAAAAOz+//8EAAAAAAAAABwAAACMAAAA3P7//zgAAAAAQQ4gnQSeA0ze3Q4AAAAAAAAAAAtGFausAAAA" ];
                .name = ".eh_frame"; .read_only = true; .size = 172 };
            { .address = 2468;
                .bytes = "\004\000\000\000\016\000\000\000\001\000\000\000GNU\000\000\000\000\000\003\000\000\000\n\000\000\000\000\000\000\000";
                .name = ".note.ABI-tag"; .read_only = true; .size = 32 };
            { .address = 130472; .bytes = "`\b\000\000\000\000\000\000";
                .name = ".init_array"; .size = 8 };
            { .address = 130480; .bytes = "\012\b\000\000\000\000\000\000";
                .name = ".fini_array"; .size = 8 };
            { .address = 130488;
                .bytes = [ "H4sIAAAAAAAA/wEAAv/9AQAAAAAAAAAoAAAAAAAAAB0AAAAAAAAASAAAAAAAAAAMAAAAAAAAAJgGAAAAAAAADQAAAAAAAACcCAAAAAAAABkAAAAAAAAAqP0BAAAAAAAbAAAAAAAAAAgAAAAAAAAAGgAAAAAAAACw/QEAAAAAABwAAAAAAAAACAAAAAAAAAAEAAAAAAAAAKgCAAAAAAAA9f7/bwAAAADgAgAAAAAAAAUAAAAAAAAA2AMAAAAAAAAGAAAAAAAAAAADAAAAAAAACgAAAAAAAABYAQAAAAAAAAsAAAAAAAAAGAAAAAAAAAAVAAAAAAAAAAAAAAAAAAAAAwAAAAAAAADo/wEAAAAAAAIAAAAAAAAAYAAAAAAAAAAUAAAAAAAAAAcAAAAAAAAAFwAAAAAAAAA4BgAAAAAAAAcAAAAAAAAAeAUAAAAAAAAIAAAAAAAAAMAAAAAAAAAACQAAAAAAAAAYAAAAAAAAAPv//28AAAAAAAAACAAAAAD+//9vAAAAAEgFAAAAAAAA////bwAAAAABAAAAAAAAAPD//28AAAAAMAUAAAAAAAD5//9vAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGaC/LAAIAAA==" ];
                .name = ".dynamic"; .size = 512 };
            { .address = 131000;
                .bytes = "\184\253\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000d\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
                .name = ".got"; .size = 48 };
            { .address = 131048;
                .bytes = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000\192\006\000\000\000\000\000\000";
                .name = ".got.plt"; .size = 56 };
            { .address = 131104;
                .bytes = "\000\000\000\000\000\000\000\000(\000\002\000\000\000\000\000\000\000\000\000\001\000\000\000\002\000\000\000\003\000\000\000\004\000\000\000\005\000\000\000\006\000\000\000\007\000\000\000\b\000\000\000\t\000\000\000";
                .name = ".data"; .size = 56 };
            { .address = 131160; .bytes = ""; .name = ".bss"; .size = 24 } ];
        .invariants = [ "GtirbArm" ] };
    |}];
  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect {|
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node7"[label="node7 U \nPar(@main_\{ Var.V.name = \"SP_in\"; typ = bv64; scope = Var.LocalVar \}) |{<0>[-32, -25]|<1>[-24, -17]|<2>[-4, -1]}"];
      "node10"[label="node10 UO \nPar(@main_\{ Var.V.name = \"R0_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_35) |{<3>Top}"];
      "node12"[label="node12 U \nLoaded(local_42) |{<4>[0, 3]}"];
      "node13"[label="node13 U \nPar(@main_\{ Var.V.name = \"R29_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_47) |{<5>[0, 7]}"];
      "node14"[label="node14 U \nPar(@main_\{ Var.V.name = \"R30_in\"; typ = bv64; scope = Var.LocalVar \})\nLoaded(local_50) |{<6>[0, 7]}"];
      "node7":2 -> "node10":3
      "node7":0 -> "node13":5
      "node10":3 -> "node12":4
      "node7":1 -> "node14":6
    }
    |}]
