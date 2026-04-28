  $ bincaml script ./typeinference.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transforms ssa)
  (run-transforms cf-expressions)
  (run-transforms simplify)
  (run-transforms type-check)
  (run-transforms type-inference)
  bincaml: [ERROR] non-equal variables with same name: { Var.V.name = "R0_6"; typ = bv64; scope = Var.LocalVar } { Var.V.name = "R0_6"; typ = rec653825801 of {"field0": (bv1, 0)} 64;
    scope = Var.LocalVar }
  (run-transforms type-check)
  bincaml: [ERROR] non-equal variables with same name: { Var.V.name = "R0_6"; typ = bv64; scope = Var.LocalVar } { Var.V.name = "R0_6"; typ = rec653825801 of {"field0": (bv1, 0)} 64;
    scope = Var.LocalVar }
  (dump-il after-type-inference-loops.il)
  (load-il after-type-inference-loops.il)
  bincaml: [WARNING] global undeclared CF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared NF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared R1_3. assuming mutable unshared
  bincaml: [WARNING] global undeclared VF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared ZF_7. assuming mutable unshared
  $ cat after-type-inference-loops.il
  type rec1033140799 of {"field131132": (bv32, 131132)} 32;
  type rec129270769 of {"field-24": (rec655598698 of {"field-24": (bv64, -24)} 64, -24)} 64;
  type rec219118263 of {"field0": (bv32, 0)} 64;
  type rec25896807 of {"field131132": (rec1033140799 of {"field131132": (bv32, 131132)} 32, 131132)} 32;
  type rec415299809 of {"field-4": (rec395040688 of {"field-4": (bv32, -4)} 32, -4)} 32;
  type rec609987531 of {"field-32": (bv64, -32)} 64;
  type rec653825801 of {"field0": (bv1, 0)} 64;
  type rec655598698 of {"field-24": (bv64, -24)} 64;
  type rec788165488 of {"field-16": (rec340476297 of {"field-16": (bv64, -16)} 64, -16)} 64;
  type rec913263426 of {"field-32": (rec609987531 of {"field-32": (bv64, -32)} 64, -32)} 64;
  type rec995080098 of {"field131136": (bv32, 131136)} 32;
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  proc @main_1876(R0_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, R31_in:bv64)
     -> (CF_out:bv1, NF_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64,
     R30_out:bv64, R31_out:bv64, VF_out:bv1, ZF_out:bv1) { .address = 1876;
      .name = "main"; .returnBlock = "main_basil_return_1" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  
  [
     block %inputs [ goto (%main_entry); ];
     block %main_entry [
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64,
        0x20:bv64) R29_in:bv64 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64,
        0x18:bv64) R30_in:bv64 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x4:bv64) (R0_in:rec219118263 of {"field0": (bv32, 0)} 64.field0) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64,
        0x10:bv64) R1_in:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x2003c:bv64 0x0:bv32 32;
       var load18_1:bv32 := load le $mem:(bv64->bv8) 0x20040:bv64 32;
       var R0_6:bv64 := zero_extend(32, load18_1:bv32);
       var R0_7:bv64 := zero_extend(32,
       bvconcat(0x0:bv31, (R0_6:rec653825801 of {"field0": (bv1, 0)} 64.field0)));
       var #5_1:bv32 := bvadd((R0_7:rec219118263 of {"field0": (bv32, 0)} 64.field0),
        0xffffffff:bv32);
       var VF_2:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          sign_extend(1, (R0_7:rec219118263 of {"field0": (bv32, 0)} 64.field0)))));
       var CF_2:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1,
           (R0_7:rec219118263 of {"field0": (bv32, 0)} 64.field0)), 0x100000000:bv33))));
       var ZF_2:bv1 := booltobv1(eq(bvadd(#5_1:bv32, 0x1:bv32), 0x0:bv32));
       var NF_2:bv1 := extract(32,31, bvadd(#5_1:bv32, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       guard neq(booltobv1(eq(ZF_2:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       guard eq(booltobv1(eq(ZF_2:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 (
       var CF_6:bv1 := phi(%main_25 -> CF_2:bv1, %main_7 -> CF_5:bv1),
       var NF_6:bv1 := phi(%main_25 -> NF_2:bv1, %main_7 -> NF_5:bv1),
       var R1_4:bv64 := phi(%main_25 -> R1_in:bv64, %main_7 -> R1_3:bv64),
       var VF_6:bv1 := phi(%main_25 -> VF_2:bv1, %main_7 -> VF_5:bv1),
       var ZF_9:bv1 := phi(%main_25 -> ZF_2:bv1, %main_7 -> ZF_7:bv1)
     ) [
       (var CF_7:bv1=CF_out, var NF_7:bv1=NF_out, var R0_16:bv64=R0_out,
          var R1_5:bv64=R1_out, var R29_6:bv64=R29_out, var R30_5:bv64=R30_out,
          var R31_6:bv64=R31_out, var VF_7:bv1=VF_out, var ZF_10:bv1=ZF_out) := call @puts_1584(CF_in=CF_6:bv1,
          NF_in=NF_6:bv1, R0_in=0x820:bv64, R1_in=R1_4:bv64,
          R29_in=bvsub(R31_in:bv64, 0x20:bv64), R30_in=0x7a0:bv64,
          R31_in=bvsub(R31_in:bv64, 0x20:bv64), VF_in=VF_6:bv1, ZF_in=ZF_9:bv1);
       goto (%main_3);
     ];
     block %main_3 [
       var load19_1:bv32 := load le $mem:(bv64->bv8) 0x2003c:bv64 32;
       var R0_19:bv64 := zero_extend(32, load19_1:bv32);
       var R1_6:bv64 := zero_extend(32,
       bvadd((R0_19:rec219118263 of {"field0": (bv32, 0)} 64.field0), 0x1:bv32));
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x2003c:bv64 (R1_6:rec219118263 of {"field0": (bv32, 0)} 64.field0) 32;
       goto (%main_19);
     ];
     block %main_19 (
       var CF_3:bv1 := phi(%main_3 -> CF_7:bv1, %main_21 -> CF_2:bv1),
       var NF_3:bv1 := phi(%main_3 -> NF_7:bv1, %main_21 -> NF_2:bv1),
       var R1_2:bv64 := phi(%main_3 -> R1_6:rec219118263 of {"field0": (bv32, 0)} 64,
          %main_21 -> R1_in:bv64),
       var VF_3:bv1 := phi(%main_3 -> VF_7:bv1, %main_21 -> VF_2:bv1),
       var ZF_5:bv1 := phi(%main_3 -> ZF_10:bv1, %main_21 -> ZF_2:bv1)
     ) [
       (var CF_4:bv1=CF_out, var NF_4:bv1=NF_out, var R0_10:bv64=R0_out,
          var R1_3:bv64=R1_out, var R29_4:bv64=R29_out, var R30_3:bv64=R30_out,
          var R31_4:bv64=R31_out, var VF_4:bv1=VF_out, var ZF_6:bv1=ZF_out) := call @puts_1584(CF_in=CF_3:bv1,
          NF_in=NF_3:bv1, R0_in=0x820:bv64,
          R1_in=R1_2:rec219118263 of {"field0": (bv32, 0)} 64,
          R29_in=bvsub(R31_in:bv64, 0x20:bv64), R30_in=0x7d0:bv64,
          R31_in=bvsub(R31_in:bv64, 0x20:bv64), VF_in=VF_3:bv1, ZF_in=ZF_5:bv1);
       goto (%main_17);
     ];
     block %main_17 [
       var load20_1:bv32 := load le $mem:(bv64->bv8) 0x2003c:bv64 32;
       var R0_13:bv64 := zero_extend(32, load20_1:bv32);
       var #6_1:bv32 := bvadd((R0_13:rec219118263 of {"field0": (bv32, 0)} 64.field0),
        0xfffffffa:bv32);
       var VF_5:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(sign_extend(1,
           (R0_13:rec219118263 of {"field0": (bv32, 0)} 64.field0)),
           0x1fffffffb:bv33))));
       var CF_5:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1,
           (R0_13:rec219118263 of {"field0": (bv32, 0)} 64.field0)), 0xfffffffb:bv33))));
       var ZF_7:bv1 := booltobv1(eq(bvadd(#6_1:bv32, 0x1:bv32), 0x0:bv32));
       var NF_5:bv1 := extract(32,31, bvadd(#6_1:bv32, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       guard neq(bvnot(booltobv1(eq(ZF_7:bv1, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       guard eq(bvnot(booltobv1(eq(ZF_7:bv1, 0x1:bv1))), 0x0:bv1);
       (var CF_8:bv1=CF_out, var NF_8:bv1=NF_out, var R0_24:bv64=R0_out,
          var R1_7:bv64=R1_out, var R29_7:bv64=R29_out, var R30_7:bv64=R30_out,
          var R31_7:bv64=R31_out, var VF_8:bv1=VF_out, var ZF_12:bv1=ZF_out) := call @puts_1584(CF_in=CF_5:bv1,
          NF_in=NF_5:bv1, R0_in=0x828:bv64, R1_in=R1_3:bv64,
          R29_in=bvsub(R31_in:bv64, 0x20:bv64), R30_in=0x7f4:bv64,
          R31_in=bvsub(R31_in:bv64, 0x20:bv64), VF_in=VF_5:bv1, ZF_in=ZF_7:bv1);
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       var load21_1:bv64 := load le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x20:bv64) 64;
       var load22_1:bv64 := load le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x18:bv64) 64;
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ goto (%returns); ];
     block %returns [
       (var CF_out:bv1 := CF_8:bv1, var NF_out:bv1 := NF_8:bv1,
        var R0_out:bv64 := 0x0:bv64, var R1_out:bv64 := R1_7:bv64,
        var R29_out:bv64 := load21_1:bv64, var R30_out:bv64 := load22_1:bv64,
        var R31_out:bv64 := R31_in:bv64, var VF_out:bv1 := VF_8:bv1,
        var ZF_out:bv1 := ZF_12:bv1);
       return;
     ]
  ];
  proc @puts_1584(CF_in:bv1, NF_in:bv1, R0_in:bv64, R1_in:bv64, R29_in:bv64,
     R30_in:bv64, R31_in:bv64, VF_in:bv1, ZF_in:bv1)
     -> (CF_out:bv1, NF_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64,
     R30_out:bv64, R31_out:bv64, VF_out:bv1, ZF_out:bv1) { .address = 1584;
      .name = "puts" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ;
  prog entry @main_1876;
