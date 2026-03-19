
Run on basic irreducible loop example

  $ bincaml script basicssa.sexp

  $ cat before.il
  var $CF:bv1;
  var $NF:bv1;
  var $R0:bv64;
  var $R1:bv64;
  var $R29:bv64;
  var $R30:bv64;
  var $R31:bv64;
  var $VF:bv1;
  var $ZF:bv1;
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  prog entry @main_1876;
  proc @main_1876()  -> () { .address = 1876; .name = "main";
      .returnBlock = "main_basil_return_1" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
    captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  
  [
     block %main_entry [
       var #4:bv64 := bvadd($R31:bv64, 0xffffffffffffffe0:bv64);
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4:bv64 $R29:bv64 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4:bv64, 0x8:bv64) $R30:bv64 64;
       $R31:bv64 := #4:bv64;
       $R29:bv64 := $R31:bv64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x1c:bv64) extract(32,0, $R0:bv64) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R1:bv64 64;
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 0x0:bv32 32;
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x40:bv64);
       var load18:bv32 := load le $mem:(bv64->bv8) $R0:bv64 32;
       $R0:bv64 := zero_extend(32, load18:bv32);
       $R0:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, $R0:bv64)));
       var #5:bv32 := bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32);
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0:bv64)), 0x0:bv33))));
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0:bv64)), 0x100000000:bv33))));
       $ZF:bv1 := booltobv1(eq(bvadd(#5:bv32, 0x1:bv32), 0x0:bv32));
       $NF:bv1 := extract(32,31, bvadd(#5:bv32, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       guard neq(booltobv1(eq($ZF:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       guard eq(booltobv1(eq($ZF:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 [
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x820:bv64);
       $R30:bv64 := 0x7a0:bv64;
       
       call @puts_1584();
       goto (%main_3);
     ];
     block %main_3 [
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x3c:bv64);
       var load19:bv32 := load le $mem:(bv64->bv8) $R0:bv64 32;
       $R0:bv64 := zero_extend(32, load19:bv32);
       $R1:bv64 := zero_extend(32, bvadd(extract(32,0, $R0:bv64), 0x1:bv32));
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(32,0, $R1:bv64) 32;
       goto (%main_19);
     ];
     block %main_19 [
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x820:bv64);
       $R30:bv64 := 0x7d0:bv64;
       
       call @puts_1584();
       goto (%main_17);
     ];
     block %main_17 [
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x3c:bv64);
       var load20:bv32 := load le $mem:(bv64->bv8) $R0:bv64 32;
       $R0:bv64 := zero_extend(32, load20:bv32);
       var #6:bv32 := bvadd(extract(32,0, $R0:bv64), 0xfffffffa:bv32);
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0:bv64)), 0x1fffffffb:bv33))));
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0:bv64)), 0xfffffffb:bv33))));
       $ZF:bv1 := booltobv1(eq(bvadd(#6:bv32, 0x1:bv32), 0x0:bv32));
       $NF:bv1 := extract(32,31, bvadd(#6:bv32, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       guard neq(bvnot(booltobv1(eq($ZF:bv1, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       guard eq(bvnot(booltobv1(eq($ZF:bv1, 0x1:bv1))), 0x0:bv1);
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0:bv64, 0x828:bv64);
       $R30:bv64 := 0x7f4:bv64;
       
       call @puts_1584();
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       $R0:bv64 := 0x0:bv64;
       var load21:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
       $R29:bv64 := load21:bv64;
       var load22:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64, 0x8:bv64) 64;
       $R30:bv64 := load22:bv64;
       $R31:bv64 := bvadd($R31:bv64, 0x20:bv64);
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ nop; return; ]
  ];
  proc @puts_1584()  -> () { .address = 1584; .name = "puts" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
    captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ;

  $ cat after.il
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  prog entry @main_1876;
  proc @main_1876(CF_in:bv1, NF_in:bv1, R0_in:bv64, R1_in:bv64, R29_in:bv64,
     R30_in:bv64, R31_in:bv64, VF_in:bv1, ZF_in:bv1)
     -> (CF_out:bv1, NF_out:bv1, R0_out:bv64, R1_out:bv64, R29_out:bv64,
     R30_out:bv64, R31_out:bv64, VF_out:bv1, ZF_out:bv1) { .address = 1876;
      .name = "main"; .returnBlock = "main_basil_return_1" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  
  [
     block %inputs [
       (var CF_1:bv1 := CF_in:bv1, var NF_1:bv1 := NF_in:bv1,
        var R0_1:bv64 := R0_in:bv64, var R1_1:bv64 := R1_in:bv64,
        var R29_1:bv64 := R29_in:bv64, var R30_1:bv64 := R30_in:bv64,
        var R31_1:bv64 := R31_in:bv64, var VF_1:bv1 := VF_in:bv1,
        var ZF_1:bv1 := ZF_in:bv1);
       goto (%main_entry);
     ];
     block %main_entry [
       var #4_1:bv64 := bvadd(R31_1:bv64, 0xffffffffffffffe0:bv64);
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4_1:bv64 R29_1:bv64 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4_1:bv64, 0x8:bv64) R30_1:bv64 64;
       var R31_2:bv64 := #4_1:bv64;
       var R29_2:bv64 := R31_2:bv64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2:bv64, 0x1c:bv64) extract(32,0, R0_1:bv64) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2:bv64, 0x10:bv64) R1_1:bv64 64;
       var R0_2:bv64 := 0x20000:bv64;
       var R0_3:bv64 := bvadd(R0_2:bv64, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_3:bv64 0x0:bv32 32;
       var R0_4:bv64 := 0x20000:bv64;
       var R0_5:bv64 := bvadd(R0_4:bv64, 0x40:bv64);
       var load18_1:bv32 := load le $mem:(bv64->bv8) R0_5:bv64 32;
       var R0_6:bv64 := zero_extend(32, load18_1:bv32);
       var R0_7:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, R0_6:bv64)));
       var #5_1:bv32 := bvadd(extract(32,0, R0_7:bv64), 0xffffffff:bv32);
       var VF_2:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          sign_extend(1, extract(32,0, R0_7:bv64)))));
       var CF_2:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_7:bv64)), 0x100000000:bv33))));
       var ZF_2:bv1 := booltobv1(eq(bvadd(#5_1:bv32, 0x1:bv32), 0x0:bv32));
       var NF_2:bv1 := extract(32,31, bvadd(#5_1:bv32, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       var ZF_4:bv1 := ZF_2:bv1;
       guard neq(booltobv1(eq(ZF_4:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       var ZF_3:bv1 := ZF_2:bv1;
       guard eq(booltobv1(eq(ZF_3:bv1, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 (
       var CF_6:bv1 := phi(%main_25 -> CF_2:bv1, %main_7 -> CF_5:bv1),
       var NF_6:bv1 := phi(%main_25 -> NF_2:bv1, %main_7 -> NF_5:bv1),
       var R1_4:bv64 := phi(%main_25 -> R1_1:bv64, %main_7 -> R1_3:bv64),
       var R29_5:bv64 := phi(%main_25 -> R29_2:bv64, %main_7 -> R29_4:bv64),
       var R31_5:bv64 := phi(%main_25 -> R31_2:bv64, %main_7 -> R31_4:bv64),
       var VF_6:bv1 := phi(%main_25 -> VF_2:bv1, %main_7 -> VF_5:bv1),
       var ZF_9:bv1 := phi(%main_25 -> ZF_3:bv1, %main_7 -> ZF_8:bv1)
     ) [
       var R0_14:bv64 := 0x0:bv64;
       var R0_15:bv64 := bvadd(R0_14:bv64, 0x820:bv64);
       var R30_4:bv64 := 0x7a0:bv64;
       (var CF_7:bv1=CF_out, var NF_7:bv1=NF_out, var R0_16:bv64=R0_out,
          var R1_5:bv64=R1_out, var R29_6:bv64=R29_out, var R30_5:bv64=R30_out,
          var R31_6:bv64=R31_out, var VF_7:bv1=VF_out, var ZF_10:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_6:bv1, NF_in=NF_6:bv1, R0_in=R0_15:bv64,
          R1_in=R1_4:bv64, R29_in=R29_5:bv64, R30_in=R30_4:bv64, R31_in=R31_5:bv64,
          VF_in=VF_6:bv1, ZF_in=ZF_9:bv1);
       goto (%main_3);
     ];
     block %main_3 [
       var R0_17:bv64 := 0x20000:bv64;
       var R0_18:bv64 := bvadd(R0_17:bv64, 0x3c:bv64);
       var load19_1:bv32 := load le $mem:(bv64->bv8) R0_18:bv64 32;
       var R0_19:bv64 := zero_extend(32, load19_1:bv32);
       var R1_6:bv64 := zero_extend(32, bvadd(extract(32,0, R0_19:bv64), 0x1:bv32));
       var R0_20:bv64 := 0x20000:bv64;
       var R0_21:bv64 := bvadd(R0_20:bv64, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_21:bv64 extract(32,0, R1_6:bv64) 32;
       goto (%main_19);
     ];
     block %main_19 (
       var CF_3:bv1 := phi(%main_3 -> CF_7:bv1, %main_21 -> CF_2:bv1),
       var NF_3:bv1 := phi(%main_3 -> NF_7:bv1, %main_21 -> NF_2:bv1),
       var R1_2:bv64 := phi(%main_3 -> R1_6:bv64, %main_21 -> R1_1:bv64),
       var R29_3:bv64 := phi(%main_3 -> R29_6:bv64, %main_21 -> R29_2:bv64),
       var R31_3:bv64 := phi(%main_3 -> R31_6:bv64, %main_21 -> R31_2:bv64),
       var VF_3:bv1 := phi(%main_3 -> VF_7:bv1, %main_21 -> VF_2:bv1),
       var ZF_5:bv1 := phi(%main_3 -> ZF_10:bv1, %main_21 -> ZF_4:bv1)
     ) [
       var R0_8:bv64 := 0x0:bv64;
       var R0_9:bv64 := bvadd(R0_8:bv64, 0x820:bv64);
       var R30_2:bv64 := 0x7d0:bv64;
       (var CF_4:bv1=CF_out, var NF_4:bv1=NF_out, var R0_10:bv64=R0_out,
          var R1_3:bv64=R1_out, var R29_4:bv64=R29_out, var R30_3:bv64=R30_out,
          var R31_4:bv64=R31_out, var VF_4:bv1=VF_out, var ZF_6:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_3:bv1, NF_in=NF_3:bv1, R0_in=R0_9:bv64,
          R1_in=R1_2:bv64, R29_in=R29_3:bv64, R30_in=R30_2:bv64, R31_in=R31_3:bv64,
          VF_in=VF_3:bv1, ZF_in=ZF_5:bv1);
       goto (%main_17);
     ];
     block %main_17 [
       var R0_11:bv64 := 0x20000:bv64;
       var R0_12:bv64 := bvadd(R0_11:bv64, 0x3c:bv64);
       var load20_1:bv32 := load le $mem:(bv64->bv8) R0_12:bv64 32;
       var R0_13:bv64 := zero_extend(32, load20_1:bv32);
       var #6_1:bv32 := bvadd(extract(32,0, R0_13:bv64), 0xfffffffa:bv32);
       var VF_5:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, R0_13:bv64)), 0x1fffffffb:bv33))));
       var CF_5:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_13:bv64)), 0xfffffffb:bv33))));
       var ZF_7:bv1 := booltobv1(eq(bvadd(#6_1:bv32, 0x1:bv32), 0x0:bv32));
       var NF_5:bv1 := extract(32,31, bvadd(#6_1:bv32, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       var ZF_8:bv1 := ZF_7:bv1;
       guard neq(bvnot(booltobv1(eq(ZF_8:bv1, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       var ZF_11:bv1 := ZF_7:bv1;
       guard eq(bvnot(booltobv1(eq(ZF_11:bv1, 0x1:bv1))), 0x0:bv1);
       var R0_22:bv64 := 0x0:bv64;
       var R0_23:bv64 := bvadd(R0_22:bv64, 0x828:bv64);
       var R30_6:bv64 := 0x7f4:bv64;
       (var CF_8:bv1=CF_out, var NF_8:bv1=NF_out, var R0_24:bv64=R0_out,
          var R1_7:bv64=R1_out, var R29_7:bv64=R29_out, var R30_7:bv64=R30_out,
          var R31_7:bv64=R31_out, var VF_8:bv1=VF_out, var ZF_12:bv1=ZF_out) := 
       call @puts_1584(CF_in=CF_5:bv1, NF_in=NF_5:bv1, R0_in=R0_23:bv64,
          R1_in=R1_3:bv64, R29_in=R29_4:bv64, R30_in=R30_6:bv64, R31_in=R31_4:bv64,
          VF_in=VF_5:bv1, ZF_in=ZF_11:bv1);
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       var R0_25:bv64 := 0x0:bv64;
       var load21_1:bv64 := load le $stack:(bv64->bv8) R31_7:bv64 64;
       var R29_8:bv64 := load21_1:bv64;
       var load22_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_7:bv64, 0x8:bv64) 64;
       var R30_8:bv64 := load22_1:bv64;
       var R31_8:bv64 := bvadd(R31_7:bv64, 0x20:bv64);
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ goto (%returns); ];
     block %returns [
       (var CF_out:bv1 := CF_8:bv1, var NF_out:bv1 := NF_8:bv1,
        var R0_out:bv64 := R0_25:bv64, var R1_out:bv64 := R1_7:bv64,
        var R29_out:bv64 := R29_8:bv64, var R30_out:bv64 := R30_8:bv64,
        var R31_out:bv64 := R31_8:bv64, var VF_out:bv1 := VF_8:bv1,
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

  $ diff after.il after_reparsed.il
  9,10c9,10
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  168,169c168,169
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  [1]

The interpreter should give the same output for both

  $ diff  before_loop.txt after_loop.txt
  1c1
  < ERROR Fuel exhausted after state PC= @main_1876::(Begin ("%main_3", 1))
  ---
  > ERROR Fuel exhausted after state PC= @main_1876::(Begin ("%main_15", 7))
  5,7c5,13
  < #4:bv64=c516b319eaea80b1, load18:bv32=716544d0, #5:bv32=ffffffff, load19:bv32=47286984, load20:bv32=8f06ed26, #6:bv32=8f06ed20, CF_in:bv1=1, NF_in:bv1=0, R0_in:bv64=168cf99f2bba1642,
  < R1_in:bv64=1dd311ffb53a0fa5, R29_in:bv64=59f5c541556e3967, R30_in:bv64=790c70b8d72959a3, R31_in:bv64=c516b319eaea80d1, VF_in:bv1=1, ZF_in:bv1=0, CF:bv1=0, NF:bv1=1, R0:bv64=2003c,
  < R1:bv64=64a234bd2341a601, R29:bv64=5f652401ead160ee, R30:bv64=c61e9a93d3f7ed50, R31:bv64=2bf7713c8dcec628, VF:bv1=1, ZF:bv1=1
  ---
  > CF_in:bv1=1, NF_in:bv1=0, R0_in:bv64=168cf99f2bba1642, R1_in:bv64=1dd311ffb53a0fa5, R29_in:bv64=59f5c541556e3967, R30_in:bv64=790c70b8d72959a3, R31_in:bv64=c516b319eaea80d1, VF_in:bv1=1, ZF_in:bv1=0,
  > CF_1:bv1=1, NF_1:bv1=0, R0_1:bv64=168cf99f2bba1642, R1_1:bv64=1dd311ffb53a0fa5, R29_1:bv64=59f5c541556e3967, R30_1:bv64=790c70b8d72959a3, R31_1:bv64=c516b319eaea80d1, VF_1:bv1=1, ZF_1:bv1=0,
  > #4_1:bv64=c516b319eaea80b1, R31_2:bv64=c516b319eaea80b1, R29_2:bv64=c516b319eaea80b1, R0_2:bv64=20000, R0_3:bv64=2003c, R0_4:bv64=20000, R0_5:bv64=20040, load18_1:bv32=716544d0, R0_6:bv64=716544d0,
  > R0_7:bv64=0, #5_1:bv32=ffffffff, VF_2:bv1=0, CF_2:bv1=1, ZF_2:bv1=1, NF_2:bv1=0, ZF_4:bv1=1, ZF_5:bv1=0, VF_3:bv1=1, R31_3:bv64=b8b4ea2c1ae399e3, R29_3:bv64=803dc94f8b9a8598, R1_2:bv64=c16b6801,
  > NF_3:bv1=1, CF_3:bv1=0, R0_8:bv64=0, R0_9:bv64=820, R30_2:bv64=7d0, CF_4:bv1=1, NF_4:bv1=1, R0_10:bv64=b275518b6e216ce7, R1_3:bv64=bb58b263b8e3d6ec, R29_4:bv64=770f716623b4d0d1,
  > R30_3:bv64=e4d55f13bdffeaf9, R31_4:bv64=a085484122a56955, VF_4:bv1=1, ZF_6:bv1=1, R0_11:bv64=20000, R0_12:bv64=2003c, load20_1:bv32=abc3410, R0_13:bv64=abc3410, #6_1:bv32=abc340a, VF_5:bv1=0, CF_5:bv1=1,
  > ZF_7:bv1=0, NF_5:bv1=0, ZF_8:bv1=0, ZF_9:bv1=0, VF_6:bv1=0, R31_5:bv64=cd5f02f1a3c65f06, R29_5:bv64=e1c9e62d1b8b5264, R1_4:bv64=e07651f7a5fd9c68, NF_6:bv1=1, CF_6:bv1=1, R0_14:bv64=0, R0_15:bv64=820,
  > R30_4:bv64=7a0, CF_7:bv1=0, NF_7:bv1=1, R0_16:bv64=66a70cbfc78e1733, R1_5:bv64=18cb1096fe4d085b, R29_6:bv64=803dc94f8b9a8598, R30_5:bv64=d31a3ae064f33ce1, R31_6:bv64=b8b4ea2c1ae399e3, VF_7:bv1=1,
  > ZF_10:bv1=0, R0_17:bv64=20000, R0_18:bv64=2003c, load19_1:bv32=c16b6800, R0_19:bv64=c16b6800, R1_6:bv64=c16b6801, R0_20:bv64=20000, R0_21:bv64=2003c, ZF_11:bv1=0
  10,209c16
  < trace: Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x94a116999de2a72b:bv64);
  <         `Bitvector (0xbe444ac3f7f10cab:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xa6d732693611768e:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x47286985:bv64); `Bitvector (0x8f455351f271b8cc:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0xbf430b309a51f4b6:bv64);
  <         `Bitvector (0x0:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x47286985:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xb78ceabcfafb236c:bv64);
  <         `Bitvector (0x39e48bde95cf812e:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x72afc4c4a0f0168f:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x7b8f15f:bv64); `Bitvector (0xebe4c78ecbad6e19:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x6cd7a71796ee2eb8:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x7b8f15f:bv32)}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xdc065c3ad5bedbb8:bv64);
  <         `Bitvector (0xb273470fa7975e16:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xc95865d3f95163e6:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x16c77d67:bv64); `Bitvector (0xf6b0586d1aa1a357:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x4f829fc3c983d461:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x16c77d67:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xfbd1efeb32a4f:bv64); `Bitvector (0xa1dea653469169d0:bv64);
  <         `Bitvector (0x7a0:bv64); `Bitvector (0x19786b96d5def8c4:bv64);
  <         `Bitvector (0x0:bv1); `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xe3c1f0d5:bv64); `Bitvector (0x973095a239f96329:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x8556ccede3a5a789:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0xe3c1f0d5:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x1ef28fb17a613031:bv64);
  <         `Bitvector (0xd51a57d457f72640:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x9fca6d3af3d1b6e4:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xa81b004a:bv64); `Bitvector (0xaac323e9b6dbda30:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0xf4e99c0da66e356:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0xa81b004a:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x2bf77bb447717599:bv64);
  <         `Bitvector (0xaea4d3d06d27e747:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xf17f7cb9937fb8de:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x98af8316:bv64); `Bitvector (0x586bef2c24c74cae:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0xed03f393b5ac3b1c:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x98af8316:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x9f6a989a08b50c90:bv64);
  <         `Bitvector (0x464d8d4e4a5c9a27:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x9ac8c1126c4e27fc:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xc8439fe:bv64); `Bitvector (0x6c2b6be1e282b2e3:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0xe10555ed38479ab:bv64);
  <         `Bitvector (0x0:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0xc8439fe:bv32)}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xe9723e635be38216:bv64);
  <         `Bitvector (0x7a8b829edb13440:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xf6b81ce374c71a3d:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x2c65bfb8:bv64); `Bitvector (0xde5708426d31d2e3:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0xc2eaffc6f25550e:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x2c65bfb8:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xd4bb031500163a5d:bv64);
  <         `Bitvector (0xefa4903a70a9a9b7:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xcec85a6c713eaf1e:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xb4202113:bv64); `Bitvector (0xcb20b18258bc8cb0:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x540b62f25ddcfa01:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0xb4202113:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xbddc8ac137998dfa:bv64);
  <         `Bitvector (0x6adc7714a7a672a9:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x26a879754ffeec3d:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x4a18d414:bv64); `Bitvector (0x41e4baddfa13f282:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x846d9cac16c136fd:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x4a18d414:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xbcb6d94a0d18ac79:bv64);
  <         `Bitvector (0xcfbb4ac54c1a1ee1:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x9155ccd94a83573c:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x6700c5ff:bv64); `Bitvector (0x8f6be99d612f21fc:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x447fc8263061bb64:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x6700c5ff:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xb62fff9fe45877d4:bv64);
  <         `Bitvector (0x381d23fa300b63a6:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xdeacb646442d7f5e:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x1c7eb591:bv64); `Bitvector (0xe00d73b7fdceb283:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x6112b8eab14e917e:bv64);
  <         `Bitvector (0x0:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x1c7eb591:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x1b3d2d643245387b:bv64);
  <         `Bitvector (0x52bd2d6abc73734:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xa6c659f7be80b0e6:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x63d93850:bv64); `Bitvector (0x6d03005a598d80f9:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x9989c74f9706f1e9:bv64);
  <         `Bitvector (0x0:bv1); `Bitvector (0x0:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x63d93850:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x682034b958b22172:bv64);
  <         `Bitvector (0xc5ae42108c7d3692:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0x14bc8f9aa9f4660c:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x0:bv1); `Bitvector (0x1:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0x2eeb23b4:bv64); `Bitvector (0xa36489bca368781b:bv64);
  <         `Bitvector (0x7d0:bv64); `Bitvector (0x3007f0bdedf939e4:bv64);
  <         `Bitvector (0x1:bv1); `Bitvector (0x1:bv1)]}; Store {mem = "$mem"; addr = `Bitvector (0x2003c:bv64);   value = `Bitvector (0x2eeb23b4:bv32)};
  <     Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  <     Call {procid = ("@puts_1584", 1);
  <       args =
  <       [`Bitvector (0x1:bv1); `Bitvector (0x0:bv1); `Bitvector (0x820:bv64);
  <         `Bitvector (0xbb58b263b8e3d6ec:bv64);
  <         `Bitvector (0x770f716623b4d0d1:bv64); `Bitvector (0x7a0:bv64);
  <         `Bitvector (0xa085484122a56955:bv64); `Bitvector (0x0:bv1);
  <         `Bitvector (0x0:bv1)]}; Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  ---
  > trace: Load {mem = "$mem"; addr = `Bitvector (0x2003c:bv64)};
  5364c5171,5236
  < Mem $mem:(bv64->bv8)   Mem $stack:(bv64->bv8) 
  \ No newline at end of file
  ---
  > Mem $mem:(bv64->bv8)
  > page at 20000
  > 000: 9ace 46fb 2213 1b52 6e31 3c54 e87f 335d  ..F."..Rn1<T..3]
  > 010: 64da b8fb e7d0 67b7 e2b9 1815 347e 0bba  d.....g.....4~..
  > 020: 7244 ded8 f26f b2fa 2a74 ef06 8cec 102e  rD...o..*t......
  > 030: a610 b5bf ac9b 58ca 27ad de77 1034 bc0a  ......X.'..w.4..
  > 040: feea 6fc7 968b cd0b e078 80e6 13f3 6f7d  ..o......x....o}
  > 050: 7043 8551 2cc7 38ee f545 a13c 5d93 08fb  pC.Q,.8..E.<]...
  > 060: bf12 de06 5137 7f4d b34e ee28 8c3f f02a  ....Q7.M.N.(.?.*
  > 070: dbfd 2404 51ec 466b 6628 bfc0 e5da ed43  ..$.Q.Fkf(.....C
  > 080: 51e1 d260 c548 4604 1302 c59d fb95 0053  Q..`.HF........S
  > 090: 603d d045 d515 6be2 a950 4454 6754 963d  `=.E..k..PDTgT.=
  > 0a0: bb79 098a 5c4a 0ef2 0a63 8607 334d e072  .y..\J...c..3M.r
  > 0b0: 797a e17d 99d2 8ccb 4c85 c38a 4cbd 5dc3  yz.}....L...L.].
  > 0c0: 8180 1acb cfe7 e25e f403 efd0 9528 463a  .......^.....(F:
  > 0d0: 3c80 6e3c a1d1 e237 aacb 46a0 b7a8 8190  <.n<...7..F.....
  > 0e0: 42b1 ec6b 7349 cafa 95ab 29d4 9ea6 b434  B..ksI....)....4
  > 0f0: a5bc a023 19b4 7d6c 308f 7dd4 359e 7550  ...#..}l0.}.5.uP
  > 100: 2211 3e6d 505b df47 6764 64cb 45c5 62d5  ".>mP[.Ggdd.E.b.
  > 110: 8ef9 da8b 39a5 25fc 3d6b 823f bdfb a4d0  ....9.%.=k.?....
  > 120: c71e a0c6 8d32 211a e079 5f25 aa45 cb46  .....2!..y_%.E.F
  > 130: bf05 621e f581 ea9b 28bd b09d 589e c65d  ..b.....(...X..]
  > 140: 6492 e2ea 4316 752e 29da 5809 2e14 6e0a  d...C.u.).X...n.
  > 150: fa50 252e 31d8 5954 5ae7 e4ff 8dfb bf25  .P%.1.YTZ......%
  > 160: feaa 427d 3fb5 866d ecec 9cda d550 87e9  ..B}?..m.....P..
  > 170: 7aed 57ce a089 032b 5957 c937 38bc 982e  z.W....+YW.78...
  > 180: db4c 8c81 c1a6 12da b713 43b2 ce3e 59b5  .L........C..>Y.
  > 190: 0275 6dc5 af28 2065 4fbc 3836 6e5b b92f  .um..( eO.86n[./
  > 1a0: 2713 6643 7035 0e2a d11e 51ca 6598 6ade  '.fCp5.*..Q.e.j.
  > 1b0: a9bb 0e6d a914 a5d3 1b73 2e75 2bd5 5aae  ...m.....s.u+.Z.
  > 1c0: 7f78 4cbd fa8b b292 2dbf 8501 321a 2f54  .xL.....-...2./T
  > 1d0: 5bed aef7 0595 740e 7f3b 87b8 eccd 8fb6  [.....t..;......
  > 1e0: 3214 8dfc f6e1 e670 853d e196 e8b5 4fb1  2......p.=....O.
  > 1f0: 1ded 16d5 93b7 3827 4609 983e 3be1 d94c  ......8'F..>;..L
  > 200: 15bd 7ecf ecbc 23a0 b696 5481 34b5 b851  ..~...#...T.4..Q
  > 210: 16b7 aa11 5400 a17d f2b9 8cb0 ebde ce0d  ....T..}........
  > 220: 9524 7858 d61a b655 cdcc dcae 7b3a 70e1  .$xX...U....{:p.
  > 230: ce9a 7726 9b62 200a 1898 2ef1 1e63 e60f  ..w&.b ......c..
  > 240: c245 e9a8 a271 58a5 0ac5 5a81 f344 3c0e  .E...qX...Z..D<.
  > 250: 66dd d64e 5526 d11f 51be feb9 870f 03e4  f..NU&..Q.......
  > 260: 7338 e9d9 eec3 fe8e 3aa2 40fb 413f ef83  s8......:.@.A?..
  > 270: 33a1 6dc4 c62b a0be a7a7 7d1e 645f 23e5  3.m..+....}.d_#.
  > 280: 5a29 dc25 2624 abda c1ba 6f73 f07a a91e  Z).%&$....os.z..
  > 290: 3552 a340 959a 921d 7c98 d22c d199 0c5b  5R.@....|..,...[
  > 2a0: eb74 c628 4e4e 7b88 aa42 7644 acc2 c015  .t.(NN{..BvD....
  > 2b0: c1af 8228 8de7 9fcc 0f5c 45ed 9da2 48f8  ...(.....\E...H.
  > 2c0: 5d62 f345 bb14 2f83 6740 0fae b708 48a7  ]b.E../.g@....H.
  > 2d0: ff60 d8b6 9998 a9fb bb67 9a16 8f1f 29b3  .`.......g....).
  > 2e0: 7bfd ad19 e76b 751d c381 128e 6784 9056  {....ku.....g..V
  > 2f0: 57dc 04a2 83b5 403d 2074 4f2e d22d 9cd4  W.....@= tO..-..
  > 300: 22cb 314b 74ce d053 509a a1ff 72ec b458  ".1Kt..SP...r..X
  > 310: 5bdd 058f 6390 1c31 055d e09f ce14 d197  [...c..1.]......
  > 320: 87e6 1d66 4777 c947 ba4e ab3b bba9 dd68  ...fGw.G.N.;...h
  > 330: d983 8142 0d38 8219 444f 79e0 6bd9 e63b  ...B.8..DOy.k..;
  > 340: a89f ff70 93d3 3bc5 3773 4a12 0402 db83  ...p..;.7sJ.....
  > 350: ed80 707b 3c48 a7a8 0597 f0bd 3fa6 4117  ..p{<H......?.A.
  > 360: 0213 bf58 d2e8 6ea0 680c 9033 8683 866a  ...X..n.h..3...j
  > 370: 2947 6593 32b6 b7b4 88e4 9e11 1b3a eedf  )Ge.2........:..
  > 380: a30f eede 662b cb3a bee8 f679 1f35 8486  ....f+.:...y.5..
  > 390: 826e 5c37 5571 1c40 5b81 28ca f4f2 282f  .n\7Uq.@[.(...(/
  > 3a0: cde8 6d88 e799 f8b8 705f 6cce e085 e417  ..m.....p_l.....
  > 3b0: 24de 328c c5c4 777d 43f4 9ced 2e3d 2f1e  $.2...w}C....=/.
  > 3c0: f564 bbee 5cc9 44ac e5a8 b39d 15ed 465e  .d..\.D.......F^
  > 3d0: 7f07 48a8 8eb5 8bdc 774f 5e96 3087 8a5f  ..H.....wO^.0.._
  > 3e0: 3cb4 46e5 77cd 8e66 a7fa 504b 1cf9 6f1f  <.F.w..f..PK..o.
  > 3f0: c826 1ac5 2acd 4bad 451d b389 a134 178e  .&..*.K.E....4..  Mem $stack:(bv64->bv8) 
  \ No newline at end of file
  [1]



Similar example fixing up  a file already in DSA form

  $ diff  before_conds.txt after_conds.txt


Multiple loops dependencies of loops etc are handled correctly

  $ diff ssa-multi-before.il ssa-multi-after.il
  1d0
  < var $R0:bv64;
  3,5c2,3
  < proc @main()  -> () {  }
  <   modifies $R0:bv64
  <   captures $R0:bv64
  ---
  > proc @main(R0_in:bv64)  -> (R0_out:bv64) {  }
  >   
  7a6
  >    block %inputs [ var R0_1:bv64 := R0_in:bv64; goto (%e); ];
  9,12c8,16
  <    block %e1 [ $R0:bv64 := 0x1:bv64; goto (%e2); ];
  <    block %e2 [ goto (%e4,%e1); ];
  <    block %e3 [ $R0:bv64 := 0x3:bv64; goto (%e4,%e1); ];
  <    block %e4 [ return; ]
  ---
  >    block %e1 [ var R0_3:bv64 := 0x1:bv64; goto (%e2); ];
  >    block %e2 ( var R0_4:bv64 := phi(%e1 -> R0_3:bv64, %e -> R0_1:bv64) ) [
  >      goto (%e4,%e1);
  >    ];
  >    block %e3 [ var R0_2:bv64 := 0x3:bv64; goto (%e4,%e1); ];
  >    block %e4 (
  >      var R0_5:bv64 := phi(%e2 -> R0_4:bv64, %e3 -> R0_2:bv64, %e2 -> R0_4:bv64)
  >    ) [ goto (%returns); ];
  >    block %returns [ var R0_out:bv64 := R0_5:bv64; return; ]
  [1]
