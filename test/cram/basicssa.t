
Run on basic irreducible loop example

  $ bincaml script basicssa.sexp
  ()
  ()
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  (run-transforms simple-params)
  (run-transforms simple-ssa)
  (dump-il after.il)
  (load-il after.il)
  wellformedness:non-equal variables with same name: { Var.V.name = "R1_1"; typ = bv64; scope = Var.LocalVar } { Var.V.name = "R1_1"; typ = bv64; scope = Var.LocalConst }
  (dump-il after_reparsed.il)
  ()
  ()
  ()
  ()
  (load-il ../../examples/sqrt.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  (run-transforms simple-params)
  (interp-out before_loop.txt)
  (run-transforms simple-ssa)
  (interp-out after_loop.txt)
  ()
  ()
  (load-il ../../examples/x-output.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  (interp-out before_conds.txt)
  (run-transforms simple-ssa)
  (interp-out after_conds.txt)
  ()
  ()
  ()
  ()
  (load-il ssa-multi-deps.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  (dump-il ssa-multi-before.il)
  (run-transforms ssa)
  (dump-il ssa-multi-after.il)
  ()

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
       var #4:bv64 := bvadd($R31, 0xffffffffffffffe0:bv64);
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4 $R29 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4, 0x8:bv64) $R30 64;
       $R31:bv64 := #4;
       $R29:bv64 := $R31;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31, 0x1c:bv64) extract(32,0, $R0) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31, 0x10:bv64) $R1 64;
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0 0x0:bv32 32;
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0, 0x40:bv64);
       var load18:bv32 := load le $mem:(bv64->bv8) $R0 32;
       $R0:bv64 := zero_extend(32, load18);
       $R0:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, $R0)));
       var #5:bv32 := bvadd(extract(32,0, $R0), 0xffffffff:bv32);
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0)), 0x0:bv33))));
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0)), 0x100000000:bv33))));
       $ZF:bv1 := booltobv1(eq(bvadd(#5, 0x1:bv32), 0x0:bv32));
       $NF:bv1 := extract(32,31, bvadd(#5, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       guard neq(booltobv1(eq($ZF, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       guard eq(booltobv1(eq($ZF, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 [
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0, 0x820:bv64);
       $R30:bv64 := 0x7a0:bv64;
       call @puts_1584();
       goto (%main_3);
     ];
     block %main_3 [
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0, 0x3c:bv64);
       var load19:bv32 := load le $mem:(bv64->bv8) $R0 32;
       $R0:bv64 := zero_extend(32, load19);
       $R1:bv64 := zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32));
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0 extract(32,0, $R1) 32;
       goto (%main_19);
     ];
     block %main_19 [
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0, 0x820:bv64);
       $R30:bv64 := 0x7d0:bv64;
       call @puts_1584();
       goto (%main_17);
     ];
     block %main_17 [
       $R0:bv64 := 0x20000:bv64;
       $R0:bv64 := bvadd($R0, 0x3c:bv64);
       var load20:bv32 := load le $mem:(bv64->bv8) $R0 32;
       $R0:bv64 := zero_extend(32, load20);
       var #6:bv32 := bvadd(extract(32,0, $R0), 0xfffffffa:bv32);
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0)), 0x1fffffffb:bv33))));
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0)), 0xfffffffb:bv33))));
       $ZF:bv1 := booltobv1(eq(bvadd(#6, 0x1:bv32), 0x0:bv32));
       $NF:bv1 := extract(32,31, bvadd(#6, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       guard neq(bvnot(booltobv1(eq($ZF, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       guard eq(bvnot(booltobv1(eq($ZF, 0x1:bv1))), 0x0:bv1);
       $R0:bv64 := 0x0:bv64;
       $R0:bv64 := bvadd($R0, 0x828:bv64);
       $R30:bv64 := 0x7f4:bv64;
       call @puts_1584();
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       $R0:bv64 := 0x0:bv64;
       var load21:bv64 := load le $stack:(bv64->bv8) $R31 64;
       $R29:bv64 := load21;
       var load22:bv64 := load le $stack:(bv64->bv8) bvadd($R31, 0x8:bv64) 64;
       $R30:bv64 := load22;
       $R31:bv64 := bvadd($R31, 0x20:bv64);
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
       (let CF_1:bv1 := CF_in, let NF_1:bv1 := NF_in, let R0_1:bv64 := R0_in,
        let R1_1:bv64 := R1_in, let R29_1:bv64 := R29_in, let R30_1:bv64 := R30_in,
        let R31_1:bv64 := R31_in, let VF_1:bv1 := VF_in, let ZF_1:bv1 := ZF_in);
       goto (%main_entry);
     ];
     block %main_entry [
       let #4_1:bv64 := bvadd(R31_1, 0xffffffffffffffe0:bv64);
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4_1 R29_1 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4_1, 0x8:bv64) R30_1 64;
       let R31_2:bv64 := #4_1;
       let R29_2:bv64 := R31_2;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2, 0x1c:bv64) extract(32,0, R0_1) 32;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2, 0x10:bv64) R1_1 64;
       let R0_2:bv64 := 0x20000:bv64;
       let R0_3:bv64 := bvadd(R0_2, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_3 0x0:bv32 32;
       let R0_4:bv64 := 0x20000:bv64;
       let R0_5:bv64 := bvadd(R0_4, 0x40:bv64);
       let load18_1:bv32 := load le $mem:(bv64->bv8) R0_5 32;
       let R0_6:bv64 := zero_extend(32, load18_1);
       let R0_7:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, R0_6)));
       let #5_1:bv32 := bvadd(extract(32,0, R0_7), 0xffffffff:bv32);
       let VF_2:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5_1, 0x1:bv32)),
          sign_extend(1, extract(32,0, R0_7)))));
       let CF_2:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5_1, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_7)), 0x100000000:bv33))));
       let ZF_2:bv1 := booltobv1(eq(bvadd(#5_1, 0x1:bv32), 0x0:bv32));
       let NF_2:bv1 := extract(32,31, bvadd(#5_1, 0x1:bv32));
       goto (%main_27,%main_23);
     ];
     block %main_23 [
       let ZF_4:bv1 := ZF_2;
       guard neq(booltobv1(eq(ZF_4, 0x1:bv1)), 0x0:bv1);
       goto (%main_21);
     ];
     block %main_21 [ goto (%main_19); ];
     block %main_27 [
       let ZF_3:bv1 := ZF_2;
       guard eq(booltobv1(eq(ZF_3, 0x1:bv1)), 0x0:bv1);
       goto (%main_25);
     ];
     block %main_25 [ goto (%main_5); ];
     block %main_5 (
       let CF_6:bv1 := phi(%main_25 -> CF_2:bv1, %main_7 -> CF_5:bv1),
       let NF_6:bv1 := phi(%main_25 -> NF_2:bv1, %main_7 -> NF_5:bv1),
       let R1_4:bv64 := phi(%main_25 -> R1_1:bv64, %main_7 -> R1_3:bv64),
       let R29_5:bv64 := phi(%main_25 -> R29_2:bv64, %main_7 -> R29_4:bv64),
       let R31_5:bv64 := phi(%main_25 -> R31_2:bv64, %main_7 -> R31_4:bv64),
       let VF_6:bv1 := phi(%main_25 -> VF_2:bv1, %main_7 -> VF_5:bv1),
       let ZF_9:bv1 := phi(%main_25 -> ZF_3:bv1, %main_7 -> ZF_8:bv1)
     ) [
       let R0_14:bv64 := 0x0:bv64;
       let R0_15:bv64 := bvadd(R0_14, 0x820:bv64);
       let R30_4:bv64 := 0x7a0:bv64;
       (let CF_7:bv1=CF_out, let NF_7:bv1=NF_out, let R0_16:bv64=R0_out,
          let R1_5:bv64=R1_out, let R29_6:bv64=R29_out, let R30_5:bv64=R30_out,
          let R31_6:bv64=R31_out, let VF_7:bv1=VF_out, let ZF_10:bv1=ZF_out) := call @puts_1584(CF_in=CF_6,
          NF_in=NF_6, R0_in=R0_15, R1_in=R1_4, R29_in=R29_5, R30_in=R30_4,
          R31_in=R31_5, VF_in=VF_6, ZF_in=ZF_9);
       goto (%main_3);
     ];
     block %main_3 [
       let R0_17:bv64 := 0x20000:bv64;
       let R0_18:bv64 := bvadd(R0_17, 0x3c:bv64);
       let load19_1:bv32 := load le $mem:(bv64->bv8) R0_18 32;
       let R0_19:bv64 := zero_extend(32, load19_1);
       let R1_6:bv64 := zero_extend(32, bvadd(extract(32,0, R0_19), 0x1:bv32));
       let R0_20:bv64 := 0x20000:bv64;
       let R0_21:bv64 := bvadd(R0_20, 0x3c:bv64);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_21 extract(32,0, R1_6) 32;
       goto (%main_19);
     ];
     block %main_19 (
       let CF_3:bv1 := phi(%main_3 -> CF_7:bv1, %main_21 -> CF_2:bv1),
       let NF_3:bv1 := phi(%main_3 -> NF_7:bv1, %main_21 -> NF_2:bv1),
       let R1_2:bv64 := phi(%main_3 -> R1_6:bv64, %main_21 -> R1_1:bv64),
       let R29_3:bv64 := phi(%main_3 -> R29_6:bv64, %main_21 -> R29_2:bv64),
       let R31_3:bv64 := phi(%main_3 -> R31_6:bv64, %main_21 -> R31_2:bv64),
       let VF_3:bv1 := phi(%main_3 -> VF_7:bv1, %main_21 -> VF_2:bv1),
       let ZF_5:bv1 := phi(%main_3 -> ZF_10:bv1, %main_21 -> ZF_4:bv1)
     ) [
       let R0_8:bv64 := 0x0:bv64;
       let R0_9:bv64 := bvadd(R0_8, 0x820:bv64);
       let R30_2:bv64 := 0x7d0:bv64;
       (let CF_4:bv1=CF_out, let NF_4:bv1=NF_out, let R0_10:bv64=R0_out,
          let R1_3:bv64=R1_out, let R29_4:bv64=R29_out, let R30_3:bv64=R30_out,
          let R31_4:bv64=R31_out, let VF_4:bv1=VF_out, let ZF_6:bv1=ZF_out) := call @puts_1584(CF_in=CF_3,
          NF_in=NF_3, R0_in=R0_9, R1_in=R1_2, R29_in=R29_3, R30_in=R30_2,
          R31_in=R31_3, VF_in=VF_3, ZF_in=ZF_5);
       goto (%main_17);
     ];
     block %main_17 [
       let R0_11:bv64 := 0x20000:bv64;
       let R0_12:bv64 := bvadd(R0_11, 0x3c:bv64);
       let load20_1:bv32 := load le $mem:(bv64->bv8) R0_12 32;
       let R0_13:bv64 := zero_extend(32, load20_1);
       let #6_1:bv32 := bvadd(extract(32,0, R0_13), 0xfffffffa:bv32);
       let VF_5:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6_1, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, R0_13)), 0x1fffffffb:bv33))));
       let CF_5:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6_1, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_13)), 0xfffffffb:bv33))));
       let ZF_7:bv1 := booltobv1(eq(bvadd(#6_1, 0x1:bv32), 0x0:bv32));
       let NF_5:bv1 := extract(32,31, bvadd(#6_1, 0x1:bv32));
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       let ZF_8:bv1 := ZF_7;
       guard neq(bvnot(booltobv1(eq(ZF_8, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       let ZF_11:bv1 := ZF_7;
       guard eq(bvnot(booltobv1(eq(ZF_11, 0x1:bv1))), 0x0:bv1);
       let R0_22:bv64 := 0x0:bv64;
       let R0_23:bv64 := bvadd(R0_22, 0x828:bv64);
       let R30_6:bv64 := 0x7f4:bv64;
       (let CF_8:bv1=CF_out, let NF_8:bv1=NF_out, let R0_24:bv64=R0_out,
          let R1_7:bv64=R1_out, let R29_7:bv64=R29_out, let R30_7:bv64=R30_out,
          let R31_7:bv64=R31_out, let VF_8:bv1=VF_out, let ZF_12:bv1=ZF_out) := call @puts_1584(CF_in=CF_5,
          NF_in=NF_5, R0_in=R0_23, R1_in=R1_3, R29_in=R29_4, R30_in=R30_6,
          R31_in=R31_4, VF_in=VF_5, ZF_in=ZF_11);
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       let R0_25:bv64 := 0x0:bv64;
       let load21_1:bv64 := load le $stack:(bv64->bv8) R31_7 64;
       let R29_8:bv64 := load21_1;
       let load22_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_7, 0x8:bv64) 64;
       let R30_8:bv64 := load22_1;
       let R31_8:bv64 := bvadd(R31_7, 0x20:bv64);
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ goto (%returns); ];
     block %returns [
       (let CF_out:bv1 := CF_8, let NF_out:bv1 := NF_8, let R0_out:bv64 := R0_25,
        let R1_out:bv64 := R1_7, let R29_out:bv64 := R29_8,
        let R30_out:bv64 := R30_8, let R31_out:bv64 := R31_8, let VF_out:bv1 := VF_8,
        let ZF_out:bv1 := ZF_12);
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
  162,163c162,163
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  [1]

The interpreter should give the same output for both

  $ diff  before_loop.txt after_loop.txt


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
  >    block %inputs [ let R0_1:bv64 := R0_in; goto (%e); ];
  9,12c8,16
  <    block %e1 [ $R0:bv64 := 0x1:bv64; goto (%e2); ];
  <    block %e2 [ goto (%e4,%e1); ];
  <    block %e3 [ $R0:bv64 := 0x3:bv64; goto (%e4,%e1); ];
  <    block %e4 [ return; ]
  ---
  >    block %e1 [ let R0_3:bv64 := 0x1:bv64; goto (%e2); ];
  >    block %e2 ( let R0_4:bv64 := phi(%e1 -> R0_3:bv64, %e -> R0_1:bv64) ) [
  >      goto (%e4,%e1);
  >    ];
  >    block %e3 [ let R0_2:bv64 := 0x3:bv64; goto (%e4,%e1); ];
  >    block %e4 (
  >      let R0_5:bv64 := phi(%e2 -> R0_4:bv64, %e3 -> R0_2:bv64, %e2 -> R0_4:bv64)
  >    ) [ goto (%returns); ];
  >    block %returns [ let R0_out:bv64 := R0_5; return; ]
  [1]
