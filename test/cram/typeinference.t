  $ bincaml script ./typeinference.sexp 2> /dev/null
  Parameters for the function has a type mismatch: type of ptradd(R31_7, bvadd(0x20:bv64)) != type of R31_8:bv64 (bv64 </= ptr(rec1017972628 of {"field0": (bv64, 0)} 64, rec1017972628 of {"field0": (bv64, 0)} 64)) at statement 2 in %main_11
  $ cat after-type-inference-loops.il
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  type ptr(⊤, rec1017972628 of {"field0": (bv64, 0)} 64);
  type ptr(bv64, bv64);
  type ptr(bv64, bv64);
  type ptr(rec1017972628 of {"field0": (bv64, 0)} 64, rec1017972628 of {"field0": (bv64, 0)} 64);
  type rec1017972628 of {"field0": (bv64, 0)} 64;
  type rec210884686 of {"field131132": (bv32, 131132)} 32;
  type rec317173895 of {"field8": (bv64, 8)} 64;
  type rec475212457 of {"field0": (bv32, 0)} 64;
  type rec627472003 of {"field131136": (bv32, 131136)} 32;
  prog entry @main_1876;
  proc @main_1876(R0_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, R31_in:bv64)
     -> (CF_out:bv1, NF_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64,
     R30_out:bv64, R31_out:bv64, VF_out:bv1, ZF_out:bv1) { .address = 1876;
      .name = "main"; .returnBlock = "main_basil_return_1" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  
  [
     block %inputs [ goto (%main_entry); ];
     block %main_entry [
       var #4_1:ptr(bv64, bv64) := bvadd(R31_in, 0xffffffffffffffe0:bv64);
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4_1 R29_in 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) ptradd(#4_1,
        bvadd(0x8:bv64)) R30_in 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) ptradd(#4_1,
        bvadd(0x1c:bv64)) extract(32,0, R0_in) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) ptradd(#4_1,
        bvadd(0x10:bv64)) R1_in 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x2003c:bv64 0x0:bv32 32;
       var load18_1:bv32 := load le $mem:(bv64->bv8) 0x20040:bv64 32;
       var R0_6:bv64 := zero_extend(32, load18_1);
       var R0_7:rec475212457 of {"field0": (bv32, 0)} 64 := zero_extend(32,
       bvconcat(0x0:bv31, extract(1,0, R0_6)));
       var #5_1:bv32 := bvadd(R0_7.field0, 0xffffffff:bv32);
       var VF_2:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5_1, 0x1:bv32)),
          sign_extend(1, R0_7.field0))));
       var CF_2:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5_1, 0x1:bv32)),
          bvadd(zero_extend(1, R0_7.field0), 0x100000000:bv33))));
       var ZF_2:bv1 := booltobv1(eq(bvadd(#5_1, 0x1:bv32), 0x0:bv32));
       var NF_2:bv1 := extract(32,31, bvadd(#5_1, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       guard neq(booltobv1(eq(ZF_2, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       guard eq(booltobv1(eq(ZF_2, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 (
       var CF_6:bv1 := phi(%main_25 -> CF_2:bv1, %main_7 -> CF_5:bv1),
       var NF_6:bv1 := phi(%main_25 -> NF_2:bv1, %main_7 -> NF_5:bv1),
       var R1_4:bv64 := phi(%main_25 -> R1_in:bv64, %main_7 -> R1_3:bv64),
       var R29_5:ptr(bv64, bv64) := phi(%main_25 -> #4_1:ptr(bv64, bv64),
          %main_7 -> R29_4:ptr(bv64, bv64)),
       var R31_5:ptr(bv64, bv64) := phi(%main_25 -> #4_1:ptr(bv64, bv64),
          %main_7 -> R31_4:ptr(bv64, bv64)),
       var VF_6:bv1 := phi(%main_25 -> VF_2:bv1, %main_7 -> VF_5:bv1),
       var ZF_9:bv1 := phi(%main_25 -> ZF_2:bv1, %main_7 -> ZF_7:bv1)
     ) [
       (var CF_7:bv1=CF_out, var NF_7:bv1=NF_out, var R0_16:bv64=R0_out,
          var R1_5:bv64=R1_out, var R29_6:ptr(bv64, bv64)=R29_out,
          var R30_5:bv64=R30_out, var R31_6:ptr(bv64, bv64)=R31_out,
          var VF_7:bv1=VF_out, var ZF_10:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_6, NF_in=NF_6, R0_in=0x820:bv64, R1_in=R1_4,
          R29_in=R29_5, R30_in=0x7a0:bv64, R31_in=R31_5, VF_in=VF_6, ZF_in=ZF_9);
       goto (%main_3);
     ];
     block %main_3 [
       var load19_1:bv32 := load le $mem:(bv64->bv8) 0x2003c:bv64 32;
       var R0_19:bv64 := zero_extend(32, load19_1);
       var R1_6:bv64 := zero_extend(32, bvadd(extract(32,0, R0_19), 0x1:bv32));
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x2003c:bv64 extract(32,0, R1_6) 32;
       goto (%main_19);
     ];
     block %main_19 (
       var CF_3:bv1 := phi(%main_3 -> CF_7:bv1, %main_21 -> CF_2:bv1),
       var NF_3:bv1 := phi(%main_3 -> NF_7:bv1, %main_21 -> NF_2:bv1),
       var R1_2:bv64 := phi(%main_3 -> R1_6:bv64, %main_21 -> R1_in:bv64),
       var R29_3:ptr(bv64, bv64) := phi(%main_3 -> R29_6:ptr(bv64, bv64),
          %main_21 -> #4_1:ptr(bv64, bv64)),
       var R31_3:ptr(bv64, bv64) := phi(%main_3 -> R31_6:ptr(bv64, bv64),
          %main_21 -> #4_1:ptr(bv64, bv64)),
       var VF_3:bv1 := phi(%main_3 -> VF_7:bv1, %main_21 -> VF_2:bv1),
       var ZF_5:bv1 := phi(%main_3 -> ZF_10:bv1, %main_21 -> ZF_2:bv1)
     ) [
       (var CF_4:bv1=CF_out, var NF_4:bv1=NF_out, var R0_10:bv64=R0_out,
          var R1_3:bv64=R1_out, var R29_4:ptr(bv64, bv64)=R29_out,
          var R30_3:bv64=R30_out, var R31_4:ptr(bv64, bv64)=R31_out,
          var VF_4:bv1=VF_out, var ZF_6:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_3, NF_in=NF_3, R0_in=0x820:bv64, R1_in=R1_2,
          R29_in=R29_3, R30_in=0x7d0:bv64, R31_in=R31_3, VF_in=VF_3, ZF_in=ZF_5);
       goto (%main_17);
     ];
     block %main_17 [
       var load20_1:bv32 := load le $mem:(bv64->bv8) 0x2003c:bv64 32;
       var R0_13:bv64 := zero_extend(32, load20_1);
       var #6_1:bv32 := bvadd(extract(32,0, R0_13), 0xfffffffa:bv32);
       var VF_5:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6_1, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, R0_13)), 0x1fffffffb:bv33))));
       var CF_5:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6_1, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_13)), 0xfffffffb:bv33))));
       var ZF_7:bv1 := booltobv1(eq(bvadd(#6_1, 0x1:bv32), 0x0:bv32));
       var NF_5:bv1 := extract(32,31, bvadd(#6_1, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       guard neq(bvnot(booltobv1(eq(ZF_7, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       guard eq(bvnot(booltobv1(eq(ZF_7, 0x1:bv1))), 0x0:bv1);
       (var CF_8:bv1=CF_out, var NF_8:bv1=NF_out, var R0_24:bv64=R0_out,
          var R1_7:bv64=R1_out, var R29_7:bv64=R29_out, var R30_7:bv64=R30_out,
          var R31_7:ptr(rec1017972628 of {"field0": (bv64, 0)} 64, rec1017972628 of {"field0": (bv64, 0)} 64)=R31_out,
          var VF_8:bv1=VF_out, var ZF_12:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_5, NF_in=NF_5, R0_in=0x828:bv64, R1_in=R1_3,
          R29_in=R29_4, R30_in=0x7f4:bv64, R31_in=R31_4, VF_in=VF_5, ZF_in=ZF_7);
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       var load21_1:bv64 := load le $stack:(bv64->bv8) R31_7 64;
       var load22_1:bv64 := load le $stack:(bv64->bv8) ptradd(R31_7, bvadd(0x8:bv64)) 64;
       var R31_8:bv64 := ptradd(R31_7, bvadd(0x20:bv64));
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ goto (%returns); ];
     block %returns [
       (var CF_out:bv1 := CF_8, var NF_out:bv1 := NF_8, var R0_out:bv64 := 0x0:bv64,
        var R1_out:bv64 := R1_7, var R29_out:bv64 := load21_1,
        var R30_out:bv64 := load22_1, var R31_out:bv64 := R31_8,
        var VF_out:bv1 := VF_8, var ZF_out:bv1 := ZF_12);
       return;
     ]
  ];
  proc @puts_1584(CF_in:bv1, NF_in:bv1, R0_in:bv64, R1_in:bv64,
     R29_in:ptr(bv64, bv64), R30_in:bv64, R31_in:ptr(bv64, bv64), VF_in:bv1,
     ZF_in:bv1)
     -> (CF_out:bv1, NF_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64,
     R30_out:bv64, R31_out:ptr(⊤, rec1017972628 of {"field0": (bv64, 0)} 64),
     VF_out:bv1, ZF_out:bv1) { .address = 1584; .name = "puts" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ;
