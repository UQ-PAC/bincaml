
Run on basic irreducible loop example

  $ bincaml script basicssa.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  bincaml: [WARNING] Invariants not satisfied during 'intra-dead-store-elim'. Needs [NoPhis] but only have [].
  (run-transforms simple-params)
  (run-transforms simple-ssa)
  (dump-il after.il)
  (load-il after.il)
  bincaml: [WARNING] global undeclared CF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared NF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared R1_3. assuming mutable unshared
  bincaml: [WARNING] global undeclared R29_4. assuming mutable unshared
  bincaml: [WARNING] global undeclared R31_4. assuming mutable unshared
  bincaml: [WARNING] global undeclared VF_5. assuming mutable unshared
  bincaml: [WARNING] global undeclared ZF_8. assuming mutable unshared
  (dump-il after_reparsed.il)
  (load-il ../../examples/sqrt.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  bincaml: [WARNING] Invariants not satisfied during 'intra-dead-store-elim'. Needs [NoPhis] but only have [].
  (run-transforms simple-params)
  (interp-out before_loop.txt)
  (run-transforms simple-ssa)
  (interp-out after_loop.txt)
  (load-il ../../examples/x-output.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  bincaml: [WARNING] Invariants not satisfied during 'intra-dead-store-elim'. Needs [NoPhis] but only have [].
  (interp-out before_conds.txt)
  (run-transforms simple-ssa)
  bincaml: [WARNING] Invariants not satisfied during 'simple-ssa'. Needs [Params] but only have [].
  (interp-out after_conds.txt)
  (load-il ssa-multi-deps.il)
  (run-transforms remove-unreachable-block cf-expressions intra-dead-store-elim)
  (dump-il ssa-multi-before.il)
  (run-transforms ssa)
  (dump-il ssa-multi-after.il)

  $ cat before.il
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  var $CF:bv1;
  var $NF:bv1;
  var $R0:bv64;
  var $R1:bv64;
  var $R29:bv64;
  var $R30:bv64;
  var $R31:bv64;
  var $VF:bv1;
  var $ZF:bv1;
  proc @main_1876()  -> () { .address = 1876; .name = "main";
      .returnBlock = "main_basil_return_1" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
    captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  
  [
     block %main_entry [
       var #4:bv64 := bvadd($R31, 0xffffffffffffffe0:bv64) { .label = "%0000035a" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4:bv64 $R29 64 { .label = "%00000360" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4:bv64, 0x8:bv64) $R30 64 { .label = "%00000366" };
       $R31:bv64 := #4:bv64 { .label = "%0000036a" };
       $R29:bv64 := $R31 { .label = "%00000370" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31, 0x1c:bv64) extract(32,0, $R0) 32 { .label = "%00000378" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31, 0x10:bv64) $R1 64 { .label = "%00000380" };
       $R0:bv64 := 0x20000:bv64 { .label = "%00000385" };
       $R0:bv64 := bvadd($R0, 0x3c:bv64) { .label = "%0000038b" };
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0 0x0:bv32 32 { .label = "%00000392" };
       $R0:bv64 := 0x20000:bv64 { .label = "%00000397" };
       $R0:bv64 := bvadd($R0, 0x40:bv64) { .label = "%0000039d" };
       var load18:bv32 := load le $mem:(bv64->bv8) $R0 32 { .label = "%000003a4$0" };
       $R0:bv64 := zero_extend(32, load18:bv32) { .label = "%000003a4$1" };
       $R0:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, $R0))) { .label = "%000003aa" };
       var #5:bv32 := bvadd(extract(32,0, $R0), 0xffffffff:bv32) { .label = "%000003b0" };
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0)), 0x0:bv33)))) { .label = "%000003b5" };
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0)), 0x100000000:bv33)))) { .label = "%000003ba" };
       $ZF:bv1 := booltobv1(eq(bvadd(#5:bv32, 0x1:bv32), 0x0:bv32)) { .label = "%000003be" };
       $NF:bv1 := extract(32,31, bvadd(#5:bv32, 0x1:bv32)) { .label = "%000003c2" };
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
       $R0:bv64 := 0x0:bv64 { .label = "%00000416" };
       $R0:bv64 := bvadd($R0, 0x820:bv64) { .label = "%0000041c" };
       $R30:bv64 := 0x7a0:bv64 { .label = "%00000421" };
       call @puts_1584();
       goto (%main_3);
     ];
     block %main_3 [
       $R0:bv64 := 0x20000:bv64 { .label = "%00000428" };
       $R0:bv64 := bvadd($R0, 0x3c:bv64) { .label = "%0000042e" };
       var load19:bv32 := load le $mem:(bv64->bv8) $R0 32 { .label = "%00000435$0" };
       $R0:bv64 := zero_extend(32, load19:bv32) { .label = "%00000435$1" };
       $R1:bv64 := zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)) { .label = "%0000043b" };
       $R0:bv64 := 0x20000:bv64 { .label = "%00000440" };
       $R0:bv64 := bvadd($R0, 0x3c:bv64) { .label = "%00000446" };
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0 extract(32,0, $R1) 32 { .label = "%0000044e" };
       goto (%main_19);
     ];
     block %main_19 [
       $R0:bv64 := 0x0:bv64 { .label = "%000003d0" };
       $R0:bv64 := bvadd($R0, 0x820:bv64) { .label = "%000003d6" };
       $R30:bv64 := 0x7d0:bv64 { .label = "%000003db" };
       call @puts_1584();
       goto (%main_17);
     ];
     block %main_17 [
       $R0:bv64 := 0x20000:bv64 { .label = "%000003e3" };
       $R0:bv64 := bvadd($R0, 0x3c:bv64) { .label = "%000003e9" };
       var load20:bv32 := load le $mem:(bv64->bv8) $R0 32 { .label = "%000003f0$0" };
       $R0:bv64 := zero_extend(32, load20:bv32) { .label = "%000003f0$1" };
       var #6:bv32 := bvadd(extract(32,0, $R0), 0xfffffffa:bv32) { .label = "%000003f6" };
       $VF:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, $R0)), 0x1fffffffb:bv33)))) { .label = "%000003fb" };
       $CF:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, $R0)), 0xfffffffb:bv33)))) { .label = "%00000400" };
       $ZF:bv1 := booltobv1(eq(bvadd(#6:bv32, 0x1:bv32), 0x0:bv32)) { .label = "%00000404" };
       $NF:bv1 := extract(32,31, bvadd(#6:bv32, 0x1:bv32)) { .label = "%00000408" };
       goto (%main_15,%main_9);
     ];
     block %main_9 [
       guard neq(bvnot(booltobv1(eq($ZF, 0x1:bv1))), 0x0:bv1);
       goto (%main_7);
     ];
     block %main_7 [ goto (%main_5); ];
     block %main_15 [
       guard eq(bvnot(booltobv1(eq($ZF, 0x1:bv1))), 0x0:bv1);
       $R0:bv64 := 0x0:bv64 { .label = "%00000459" };
       $R0:bv64 := bvadd($R0, 0x828:bv64) { .label = "%0000045f" };
       $R30:bv64 := 0x7f4:bv64 { .label = "%00000464" };
       call @puts_1584();
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       $R0:bv64 := 0x0:bv64 { .label = "%0000046b" };
       var load21:bv64 := load le $stack:(bv64->bv8) $R31 64 { .label = "%00000472$0" };
       $R29:bv64 := load21:bv64 { .label = "%00000472$1" };
       var load22:bv64 := load le $stack:(bv64->bv8) bvadd($R31, 0x8:bv64) 64 { .label = "%00000477$0" };
       $R30:bv64 := load22:bv64 { .label = "%00000477$1" };
       $R31:bv64 := bvadd($R31, 0x20:bv64) { .label = "%0000047b" };
       goto (%main_basil_return_1);
     ];
     block %main_basil_return_1 [ return; ]
  ];
  proc @puts_1584()  -> () { .address = 1584; .name = "puts" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
    captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
      $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ;
  prog entry @main_1876;

  $ cat after.il
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
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
       var #4_1:bv64 := bvsub(R31_1:bv64, 0x20:bv64) { .label = "%0000035a" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) #4_1:bv64 R29_1:bv64 64 { .label = "%00000360" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(#4_1:bv64, 0x8:bv64) R30_1:bv64 64 { .label = "%00000366" };
       var R31_2:bv64 := #4_1:bv64 { .label = "%0000036a" };
       var R29_2:bv64 := R31_2:bv64 { .label = "%00000370" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2:bv64, 0x1c:bv64) extract(32,0, R0_1:bv64) 32 { .label = "%00000378" };
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_2:bv64, 0x10:bv64) R1_1:bv64 64 { .label = "%00000380" };
       var R0_2:bv64 := 0x20000:bv64 { .label = "%00000385" };
       var R0_3:bv64 := bvadd(R0_2:bv64, 0x3c:bv64) { .label = "%0000038b" };
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_3:bv64 0x0:bv32 32 { .label = "%00000392" };
       var R0_4:bv64 := 0x20000:bv64 { .label = "%00000397" };
       var R0_5:bv64 := bvadd(R0_4:bv64, 0x40:bv64) { .label = "%0000039d" };
       var load18_1:bv32 := load le $mem:(bv64->bv8) R0_5:bv64 32 { .label = "%000003a4$0" };
       var R0_6:bv64 := zero_extend(32, load18_1:bv32) { .label = "%000003a4$1" };
       var R0_7:bv64 := zero_extend(32, bvconcat(0x0:bv31, extract(1,0, R0_6:bv64))) { .label = "%000003aa" };
       var #5_1:bv32 := bvadd(extract(32,0, R0_7:bv64), 0xffffffff:bv32) { .label = "%000003b0" };
       var VF_2:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          sign_extend(1, extract(32,0, R0_7:bv64))))) { .label = "%000003b5" };
       var CF_2:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#5_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_7:bv64)), 0x100000000:bv33)))) { .label = "%000003ba" };
       var ZF_2:bv1 := booltobv1(eq(bvadd(#5_1:bv32, 0x1:bv32), 0x0:bv32)) { .label = "%000003be" };
       var NF_2:bv1 := extract(32,31, bvadd(#5_1:bv32, 0x1:bv32)) { .label = "%000003c2" };
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
       var R0_14:bv64 := 0x0:bv64 { .label = "%00000416" };
       var R0_15:bv64 := bvadd(R0_14:bv64, 0x820:bv64) { .label = "%0000041c" };
       var R30_4:bv64 := 0x7a0:bv64 { .label = "%00000421" };
       (var CF_7:bv1=CF_out, var NF_7:bv1=NF_out, var R0_16:bv64=R0_out,
          var R1_5:bv64=R1_out, var R29_6:bv64=R29_out, var R30_5:bv64=R30_out,
          var R31_6:bv64=R31_out, var VF_7:bv1=VF_out, var ZF_10:bv1=ZF_out) := call @puts_1584(CF_in=CF_6:bv1,
          NF_in=NF_6:bv1, R0_in=R0_15:bv64, R1_in=R1_4:bv64, R29_in=R29_5:bv64,
          R30_in=R30_4:bv64, R31_in=R31_5:bv64, VF_in=VF_6:bv1, ZF_in=ZF_9:bv1);
       goto (%main_3);
     ];
     block %main_3 [
       var R0_17:bv64 := 0x20000:bv64 { .label = "%00000428" };
       var R0_18:bv64 := bvadd(R0_17:bv64, 0x3c:bv64) { .label = "%0000042e" };
       var load19_1:bv32 := load le $mem:(bv64->bv8) R0_18:bv64 32 { .label = "%00000435$0" };
       var R0_19:bv64 := zero_extend(32, load19_1:bv32) { .label = "%00000435$1" };
       var R1_6:bv64 := zero_extend(32, bvadd(extract(32,0, R0_19:bv64), 0x1:bv32)) { .label = "%0000043b" };
       var R0_20:bv64 := 0x20000:bv64 { .label = "%00000440" };
       var R0_21:bv64 := bvadd(R0_20:bv64, 0x3c:bv64) { .label = "%00000446" };
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) R0_21:bv64 extract(32,0, R1_6:bv64) 32 { .label = "%0000044e" };
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
       var R0_8:bv64 := 0x0:bv64 { .label = "%000003d0" };
       var R0_9:bv64 := bvadd(R0_8:bv64, 0x820:bv64) { .label = "%000003d6" };
       var R30_2:bv64 := 0x7d0:bv64 { .label = "%000003db" };
       (var CF_4:bv1=CF_out, var NF_4:bv1=NF_out, var R0_10:bv64=R0_out,
          var R1_3:bv64=R1_out, var R29_4:bv64=R29_out, var R30_3:bv64=R30_out,
          var R31_4:bv64=R31_out, var VF_4:bv1=VF_out, var ZF_6:bv1=ZF_out) := call @puts_1584(CF_in=CF_3:bv1,
          NF_in=NF_3:bv1, R0_in=R0_9:bv64, R1_in=R1_2:bv64, R29_in=R29_3:bv64,
          R30_in=R30_2:bv64, R31_in=R31_3:bv64, VF_in=VF_3:bv1, ZF_in=ZF_5:bv1);
       goto (%main_17);
     ];
     block %main_17 [
       var R0_11:bv64 := 0x20000:bv64 { .label = "%000003e3" };
       var R0_12:bv64 := bvadd(R0_11:bv64, 0x3c:bv64) { .label = "%000003e9" };
       var load20_1:bv32 := load le $mem:(bv64->bv8) R0_12:bv64 32 { .label = "%000003f0$0" };
       var R0_13:bv64 := zero_extend(32, load20_1:bv32) { .label = "%000003f0$1" };
       var #6_1:bv32 := bvadd(extract(32,0, R0_13:bv64), 0xfffffffa:bv32) { .label = "%000003f6" };
       var VF_5:bv1 := bvnot(booltobv1(eq(sign_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(sign_extend(1, extract(32,0, R0_13:bv64)), 0x1fffffffb:bv33)))) { .label = "%000003fb" };
       var CF_5:bv1 := bvnot(booltobv1(eq(zero_extend(1, bvadd(#6_1:bv32, 0x1:bv32)),
          bvadd(zero_extend(1, extract(32,0, R0_13:bv64)), 0xfffffffb:bv33)))) { .label = "%00000400" };
       var ZF_7:bv1 := booltobv1(eq(bvadd(#6_1:bv32, 0x1:bv32), 0x0:bv32)) { .label = "%00000404" };
       var NF_5:bv1 := extract(32,31, bvadd(#6_1:bv32, 0x1:bv32)) { .label = "%00000408" };
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
       var R0_22:bv64 := 0x0:bv64 { .label = "%00000459" };
       var R0_23:bv64 := bvadd(R0_22:bv64, 0x828:bv64) { .label = "%0000045f" };
       var R30_6:bv64 := 0x7f4:bv64 { .label = "%00000464" };
       (var CF_8:bv1=CF_out, var NF_8:bv1=NF_out, var R0_24:bv64=R0_out,
          var R1_7:bv64=R1_out, var R29_7:bv64=R29_out, var R30_7:bv64=R30_out,
          var R31_7:bv64=R31_out, var VF_8:bv1=VF_out, var ZF_12:bv1=ZF_out) := call @puts_1584(CF_in=CF_5:bv1,
          NF_in=NF_5:bv1, R0_in=R0_23:bv64, R1_in=R1_3:bv64, R29_in=R29_4:bv64,
          R30_in=R30_6:bv64, R31_in=R31_4:bv64, VF_in=VF_5:bv1, ZF_in=ZF_11:bv1);
       goto (%main_13);
     ];
     block %main_13 [ goto (%main_11); ];
     block %main_11 [
       var R0_25:bv64 := 0x0:bv64 { .label = "%0000046b" };
       var load21_1:bv64 := load le $stack:(bv64->bv8) R31_7:bv64 64 { .label = "%00000472$0" };
       var R29_8:bv64 := load21_1:bv64 { .label = "%00000472$1" };
       var load22_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_7:bv64, 0x8:bv64) 64 { .label = "%00000477$0" };
       var R30_8:bv64 := load22_1:bv64 { .label = "%00000477$1" };
       var R31_8:bv64 := bvadd(R31_7:bv64, 0x20:bv64) { .label = "%0000047b" };
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
  prog entry @main_1876;

  $ diff after.il after_reparsed.il

The interpreter should give the same output for both

  $ diff  before_loop.txt after_loop.txt


Similar example fixing up  a file already in DSA form

  $ diff  before_conds.txt after_conds.txt


Multiple loops dependencies of loops etc are handled correctly

  $ diff ssa-multi-before.il ssa-multi-after.il
  1,4c1,2
  < var $R0:bv64;
  < proc @main()  -> () {  }
  <   modifies $R0:bv64
  <   captures $R0:bv64
  ---
  > proc @main(R0_in:bv64)  -> (R0_out:bv64) {  }
  >   
  6a5
  >    block %inputs [ var R0_1:bv64 := R0_in:bv64; goto (%e); ];
  8,11c7,15
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
