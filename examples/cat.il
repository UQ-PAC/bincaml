var $BTypeNext:bv2;
var $CF:bv1;
var $NF:bv1;
var $R0:bv64;
var $R1:bv64;
var $R10:bv64;
var $R11:bv64;
var $R12:bv64;
var $R16:bv64;
var $R17:bv64;
var $R19:bv64;
var $R2:bv64;
var $R20:bv64;
var $R21:bv64;
var $R22:bv64;
var $R23:bv64;
var $R24:bv64;
var $R25:bv64;
var $R26:bv64;
var $R27:bv64;
var $R29:bv64;
var $R3:bv64;
var $R30:bv64;
var $R31:bv64;
var $R4:bv64;
var $R5:bv64;
var $R6:bv64;
var $R7:bv64;
var $R8:bv64;
var $R9:bv64;
var $VF:bv1;
var $Z0:bv128;
var $Z1:bv128;
var $Z16:bv128;
var $Z2:bv128;
var $Z3:bv128;
var $Z4:bv128;
var $Z5:bv128;
var $Z6:bv128;
var $Z7:bv128;
var $ZF:bv1;
var $_PC:bv64;
var $__BranchTaken:bv1;
var observable $mem:(bv64->bv8);
var $stack:(bv64->bv8);
prog entry @main_4197696;
proc @main_4197696()  -> () { .address = 4197696; .name = "main";
    .returnBlock = "main_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x400d40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %main_entry [
      assert eq($_PC:bv64, 0x400d40:bv64);
      $_PC:bv64 := 0x400d40:bv64;
      assert eq($_PC:bv64, 0x400d40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197696_bv64:bv64 := 0x0:bv64;
      var var1_4197696_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xfffffffffffffff0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xfffffffffffffff0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4197696_bv64:bv64, 0xfffffffffffffff0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197700_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $R30:bv64 := 0x400d4c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400f40:bv64;
      
      call @p9main_4198208();
      goto (%main_basil_return_1);
   ];
   block %main_basil_return_1 [ nop; return; ]
];
proc @getpid()  -> () { .name = "getpid" }
  
;
proc @exit()  -> () { .name = "exit" }
  
;
proc @exitcode_4198816()  -> () { .address = 4198816; .name = "exitcode";
    .returnBlock = "exitcode_basil_return_1" }
  modifies $BTypeNext:bv2, $R0:bv64, $_PC:bv64, $__BranchTaken:bv1;
  captures $BTypeNext:bv2, $R0:bv64, $R30:bv64, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x4011a0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %exitcode_entry [
      assert eq($_PC:bv64, 0x4011a0:bv64);
      $_PC:bv64 := 0x4011a0:bv64;
      assert eq($_PC:bv64, 0x4011a0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      var var1_4198820_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%exitcode_basil_return_1);
   ];
   block %exitcode_basil_return_1 [ nop; return; ]
];
proc @exits_4198688()  -> () { .address = 4198688; .name = "exits";
    .returnBlock = "exits_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401120:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %exits_entry [
      var R30_begin_exits_4198688:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x401120:bv64);
      $_PC:bv64 := 0x401120:bv64;
      assert eq($_PC:bv64, 0x401120:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198688_bv64:bv64 := 0x0:bv64;
      var var1_4198688_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4198688_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198692_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198704_bv64:bv64 := 0x0:bv64;
      var var2_4198704_bv64:bv64 := 0x0:bv64;
      var var2_4198704_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4198704_bv64:bv64, 0x410:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198708_bv64:bv64 := 0x0:bv64;
      var var2_4198708_bv64:bv64 := 0x0:bv64;
      var var2_4198708_bv64:bv64 := $R19:bv64;
      $R20:bv64 := bvadd(var2_4198708_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198712_bv64:bv64 := 0x0:bv64;
      var var2_4198712_bv64:bv64 := 0x0:bv64;
      var var2_4198712_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4198712_bv64:bv64, 0x208:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198720_bv64:bv64 := 0x0:bv64;
      var var1_4198720_bv64:bv64 := 0x0:bv64;
      var var2_4198720_bv64:bv64 := 0x0:bv64;
      var var2_4198720_bv64:bv64 := $R0:bv64;
      $R22:bv64 := bvor(var1_4198720_bv64:bv64,
       bvshl(var2_4198720_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x401148:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c20:bv64;
      goto (%FUN_400c20_entry_93);
   ];
   block %FUN_400c20_entry_93 [
      var R30_begin_FUN_400c20_4197408_13:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c20:bv64);
      $_PC:bv64 := 0x400c20:bv64;
      assert eq($_PC:bv64, 0x400c20:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197412_bv64_14:bv64 := 0x0:bv64;
      var var1_4197412_bv64_14:bv64 := $R16:bv64;
      var var2_4197412_bv64_15:bv64 := 0x0:bv64;
      var var2_4197412_bv64_15:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197412_bv64_14:bv64,
       0x40:bv64) 64;
      $R17:bv64 := var2_4197412_bv64_15:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197416_bv64_16:bv64 := 0x0:bv64;
      var var2_4197416_bv64_17:bv64 := 0x0:bv64;
      var var2_4197416_bv64_17:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197416_bv64_17:bv64, 0x40:bv64);
      var var1_4197420_bv64_18:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c20_4197408_13:bv64);
      
      call @getpid();
      goto (%FUN_400c20_basil_return_1_94);
   ];
   block %FUN_400c20_basil_return_1_94 [ goto (%_inlineret_5); ];
   block %_inlineret_5 [ goto (%exits_45); ];
   block %exits_45 [
      assert eq($_PC:bv64, 0x401148:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198728_bv32:bv32 := 0x0:bv32;
      var var1_4198728_bv32:bv32 := 0x0:bv32;
      var var2_4198728_bv32:bv32 := 0x0:bv32;
      var var2_4198728_bv32:bv32 := extract(32,0, $R0:bv64);
      $R21:bv64 := zero_extend(32,
      bvor(var1_4198728_bv32:bv32, bvshl(var2_4198728_bv32:bv32, 0x0:bv32)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401154:bv64;
      goto (%exits_43);
   ];
   block %exits_43 [
      assert eq($_PC:bv64, 0x401154:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198740_bv64:bv64 := 0x0:bv64;
      var var1_4198740_bv64:bv64 := $R19:bv64;
      var var2_4198740_bv64:bv64 := 0x0:bv64;
      var var2_4198740_bv64:bv64 := load le $mem:(bv64->bv8) var1_4198740_bv64:bv64 64;
      $R1:bv64 := var2_4198740_bv64:bv64;
      goto (%exits_41,%exits_31);
   ];
   block %exits_31 [
      guard eq($R1:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401170:bv64;
      goto (%exits_29);
   ];
   block %exits_41 [
      guard boolnot(eq($R1:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40115c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198748_bv64:bv64 := 0x0:bv64;
      var var1_4198748_bv64:bv64 := $R19:bv64;
      var var2_4198748_bv32:bv32 := 0x0:bv32;
      var var2_4198748_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4198748_bv64:bv64,
       0x8:bv64) 32;
      $R2:bv64 := zero_extend(32, var2_4198748_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198752_bv32:bv32 := 0x0:bv32;
      var var2_4198752_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64),
           bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64),
           bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64),
          bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        bvnot(bvshl(extract(32,0, $R21:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%exits_39);
   ];
   block %exits_39 [ goto (%exits_37,%exits_33); ];
   block %exits_33 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401170:bv64;
      goto (%exits_29);
   ];
   block %exits_37 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401168:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198760_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R19:bv64 0x0:bv64 64;
      var var1_4198764_bv64:bv64 := 0x0:bv64;
      var var1_4198764_bv64:bv64 := $R1:bv64;
      $R30:bv64 := 0x401170:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4198764_bv64:bv64;
      indirect call var1_4198764_bv64:bv64;
      goto (%exits_35);
   ];
   block %exits_35 [ goto (%exits_29); ];
   block %exits_29 [
      assert eq($_PC:bv64, 0x401170:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198768_bv64:bv64 := 0x0:bv64;
      var var2_4198768_bv64:bv64 := 0x0:bv64;
      var var2_4198768_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(bvadd(var2_4198768_bv64:bv64, 0xffffffffffffffef:bv64),
       0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198772_bv64:bv64 := 0x0:bv64;
      var var2_4198772_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R19:bv64),
           sign_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R19:bv64),
           zero_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64,
          bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R19:bv64,
        bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%exits_27,%exits_7);
   ];
   block %exits_7 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401150:bv64;
      assert eq($_PC:bv64, 0x401150:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198736_bv64:bv64 := 0x0:bv64;
      var var1_4198736_bv64:bv64 := 0x0:bv64;
      var var2_4198736_bv64:bv64 := 0x0:bv64;
      var var2_4198736_bv64:bv64 := $R1:bv64;
      $R19:bv64 := bvor(var1_4198736_bv64:bv64,
       bvshl(var2_4198736_bv64:bv64, 0x0:bv64));
      goto (%exits_5);
   ];
   block %exits_5 [ goto (%exits_43); ];
   block %exits_27 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40117c:bv64);
      goto (%exits_25);
   ];
   block %exits_25 [ goto (%exits_23,%exits_11); ];
   block %exits_11 [
      guard eq($R22:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401188:bv64;
      goto (%exits_9);
   ];
   block %exits_23 [
      guard boolnot(eq($R22:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401180:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198784_bv64:bv64 := 0x0:bv64;
      var var1_4198784_bv64:bv64 := $R22:bv64;
      var var2_4198784_bv8:bv8 := 0x0:bv8;
      var var2_4198784_bv8:bv8 := load le $mem:(bv64->bv8) var1_4198784_bv64:bv64 8;
      $R0:bv64 := zero_extend(32, zero_extend(24, var2_4198784_bv8:bv8));
      goto (%exits_21);
   ];
   block %exits_21 [ goto (%exits_19,%exits_17); ];
   block %exits_17 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401190:bv64;
      assert eq($_PC:bv64, 0x401190:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198800_bv64:bv64 := 0x0:bv64;
      var var1_4198800_bv64:bv64 := 0x0:bv64;
      var var2_4198800_bv64:bv64 := 0x0:bv64;
      var var2_4198800_bv64:bv64 := $R22:bv64;
      $R0:bv64 := bvor(var1_4198800_bv64:bv64,
       bvshl(var2_4198800_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x401198:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4011a0:bv64;
      
      call @exitcode_4198816();
      goto (%exits_15);
   ];
   block %exits_15 [ goto (%exits_13); ];
   block %exits_13 [
      assert eq($_PC:bv64, 0x401198:bv64);
      $R30:bv64 := 0x40119c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400bc0:bv64;
      assert eq($R30:bv64, R30_begin_exits_4198688:bv64);
      goto (%FUN_400bc0_entry_89);
   ];
   block %FUN_400bc0_entry_89 [
      var R30_begin_FUN_400bc0_4197312_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400bc0:bv64);
      $_PC:bv64 := 0x400bc0:bv64;
      assert eq($_PC:bv64, 0x400bc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197316_bv64_2:bv64 := 0x0:bv64;
      var var1_4197316_bv64_2:bv64 := $R16:bv64;
      var var2_4197316_bv64_3:bv64 := 0x0:bv64;
      var var2_4197316_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197316_bv64_2:bv64,
       0x10:bv64) 64;
      $R17:bv64 := var2_4197316_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197320_bv64_4:bv64 := 0x0:bv64;
      var var2_4197320_bv64_5:bv64 := 0x0:bv64;
      var var2_4197320_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197320_bv64_5:bv64, 0x10:bv64);
      var var1_4197324_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400bc0_4197312_1:bv64);
      
      call @exit();
      goto (%FUN_400bc0_basil_return_1_90);
   ];
   block %FUN_400bc0_basil_return_1_90 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%exits_basil_return_1); ];
   block %exits_19 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%exits_9);
   ];
   block %exits_9 [
      assert eq($_PC:bv64, 0x401188:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $R30:bv64 := 0x401190:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400bc0:bv64;
      assert eq($R30:bv64, R30_begin_exits_4198688:bv64);
      goto (%FUN_400bc0_entry_91);
   ];
   block %FUN_400bc0_entry_91 [
      var R30_begin_FUN_400bc0_4197312_7:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400bc0:bv64);
      $_PC:bv64 := 0x400bc0:bv64;
      assert eq($_PC:bv64, 0x400bc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197316_bv64_8:bv64 := 0x0:bv64;
      var var1_4197316_bv64_8:bv64 := $R16:bv64;
      var var2_4197316_bv64_9:bv64 := 0x0:bv64;
      var var2_4197316_bv64_9:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197316_bv64_8:bv64,
       0x10:bv64) 64;
      $R17:bv64 := var2_4197316_bv64_9:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197320_bv64_10:bv64 := 0x0:bv64;
      var var2_4197320_bv64_11:bv64 := 0x0:bv64;
      var var2_4197320_bv64_11:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197320_bv64_11:bv64, 0x10:bv64);
      var var1_4197324_bv64_12:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400bc0_4197312_7:bv64);
      
      call @exit();
      goto (%FUN_400bc0_basil_return_1_92);
   ];
   block %FUN_400bc0_basil_return_1_92 [ goto (%_inlineret_4); ];
   block %_inlineret_4 [ goto (%exits_basil_return_1); ];
   block %exits_basil_return_1 [ nop; return; ]
];
proc @fmtlocaleinit_4209552()  -> () { .address = 4209552; .name = "fmtlocaleinit";
    .returnBlock = "fmtlocaleinit_basil_return_1" }
  modifies $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R1:bv64, $R2:bv64,
    $R3:bv64, $R4:bv64, $R5:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R30:bv64, $R4:bv64, $R5:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403b90:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %fmtlocaleinit_entry [
      assert eq($_PC:bv64, 0x403b90:bv64);
      $_PC:bv64 := 0x403b90:bv64;
      assert eq($_PC:bv64, 0x403b90:bv64);
      goto (%fmtlocaleinit_27,%fmtlocaleinit_19);
   ];
   block %fmtlocaleinit_19 [
      guard eq($R1:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403bd4:bv64;
      assert eq($_PC:bv64, 0x403bd4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209624_bv64:bv64 := 0x0:bv64;
      var var2_4209624_bv64:bv64 := 0x0:bv64;
      var var2_4209624_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvadd(var2_4209624_bv64:bv64, 0xd28:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403ba8:bv64;
      goto (%fmtlocaleinit_17);
   ];
   block %fmtlocaleinit_17 [ goto (%fmtlocaleinit_15); ];
   block %fmtlocaleinit_27 [
      guard boolnot(eq($R1:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403b94:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209556_bv64:bv64 := 0x0:bv64;
      var var1_4209556_bv64:bv64 := $R1:bv64;
      var var2_4209556_bv8:bv8 := 0x0:bv8;
      var var2_4209556_bv8:bv8 := load le $mem:(bv64->bv8) var1_4209556_bv64:bv64 8;
      $R5:bv64 := zero_extend(32, zero_extend(24, var2_4209556_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R4:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209564_bv64:bv64 := 0x0:bv64;
      var var2_4209564_bv64:bv64 := 0x0:bv64;
      var var2_4209564_bv64:bv64 := $R4:bv64;
      $R4:bv64 := bvadd(var2_4209564_bv64:bv64, 0xd28:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209568_bv32:bv32 := 0x0:bv32;
      var var2_4209568_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R5:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R5:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R5:bv64),
        0xffffffff:bv32), 0x1:bv32));
      var var1_4209572_bv64:bv64 := 0x0:bv64;
      var var1_4209572_bv64:bv64 := $R4:bv64;
      var var2_4209572_bv64:bv64 := 0x0:bv64;
      var var2_4209572_bv64:bv64 := $R1:bv64;
      goto (%fmtlocaleinit_25);
   ];
   block %fmtlocaleinit_25 [ goto (%fmtlocaleinit_23,%fmtlocaleinit_21); ];
   block %fmtlocaleinit_21 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var1_4209572_bv64:bv64;
      goto (%fmtlocaleinit_15);
   ];
   block %fmtlocaleinit_23 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var2_4209572_bv64:bv64;
      goto (%fmtlocaleinit_15);
   ];
   block %fmtlocaleinit_15 [
      assert eq($_PC:bv64, 0x403ba8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209576_bv64:bv64 := 0x0:bv64;
      var var2_4209576_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R5:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209584_bv64:bv64 := 0x0:bv64;
      var var2_4209584_bv64:bv64 := 0x0:bv64;
      var var2_4209584_bv64:bv64 := $R5:bv64;
      $R5:bv64 := bvadd(var2_4209584_bv64:bv64, 0xd30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R4:bv64 := 0x405000:bv64;
      var var1_4209592_bv64:bv64 := 0x0:bv64;
      var var1_4209592_bv64:bv64 := $R5:bv64;
      var var2_4209592_bv64:bv64 := 0x0:bv64;
      var var2_4209592_bv64:bv64 := $R2:bv64;
      goto (%fmtlocaleinit_13,%fmtlocaleinit_11);
   ];
   block %fmtlocaleinit_11 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := var1_4209592_bv64:bv64;
      goto (%fmtlocaleinit_9);
   ];
   block %fmtlocaleinit_13 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := var2_4209592_bv64:bv64;
      goto (%fmtlocaleinit_9);
   ];
   block %fmtlocaleinit_9 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209596_bv64:bv64 := 0x0:bv64;
      var var2_4209596_bv64:bv64 := 0x0:bv64;
      var var2_4209596_bv64:bv64 := $R4:bv64;
      $R4:bv64 := bvadd(var2_4209596_bv64:bv64, 0xd38:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209600_bv64:bv64 := 0x0:bv64;
      var var2_4209600_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R3:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R3:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209604_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x70:bv64) $R1:bv64 64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($R0:bv64,
        0x70:bv64), 0x8:bv64) $R2:bv64 64;
      var var1_4209608_bv64:bv64 := 0x0:bv64;
      var var1_4209608_bv64:bv64 := $R4:bv64;
      var var2_4209608_bv64:bv64 := 0x0:bv64;
      var var2_4209608_bv64:bv64 := $R3:bv64;
      goto (%fmtlocaleinit_7,%fmtlocaleinit_5);
   ];
   block %fmtlocaleinit_5 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := var1_4209608_bv64:bv64;
      goto (%fmtlocaleinit_3);
   ];
   block %fmtlocaleinit_7 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := var2_4209608_bv64:bv64;
      goto (%fmtlocaleinit_3);
   ];
   block %fmtlocaleinit_3 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209612_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x80:bv64) $R3:bv64 64;
      var var1_4209616_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%fmtlocaleinit_basil_return_1);
   ];
   block %fmtlocaleinit_basil_return_1 [ nop; return; ]
];
proc @fmtfdinit_4209364()  -> () { .address = 4209364; .name = "fmtfdinit";
    .returnBlock = "fmtfdinit_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R2:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R2:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403ad4:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %fmtfdinit_entry [
      assert eq($_PC:bv64, 0x403ad4:bv64);
      $_PC:bv64 := 0x403ad4:bv64;
      assert eq($_PC:bv64, 0x403ad4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209364_bv64:bv64 := 0x0:bv64;
      var var1_4209364_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xfffffffffffffff0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xfffffffffffffff0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4209364_bv64:bv64, 0xfffffffffffffff0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209368_bv64:bv64 := 0x0:bv64;
      var var2_4209368_bv64:bv64 := 0x0:bv64;
      var var2_4209368_bv64:bv64 := $R2:bv64;
      var var3_4209368_bv64:bv64 := 0x0:bv64;
      var var3_4209368_bv64:bv64 := $R3:bv64;
      $R8:bv64 := bvadd(var2_4209368_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4209368_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209372_bv64:bv64 := 0x0:bv64;
      var var1_4209372_bv64:bv64 := 0x0:bv64;
      var var2_4209372_bv64:bv64 := 0x0:bv64;
      var var2_4209372_bv64:bv64 := $R2:bv64;
      $R5:bv64 := bvor(var1_4209372_bv64:bv64,
       bvshl(var2_4209372_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209376_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209380_bv64:bv64 := 0x0:bv64;
      var var1_4209380_bv64:bv64 := $R1:bv64;
      $R6:bv64 := bvor(bvand(sign_extend(63,
        extract(32,31, var1_4209380_bv64:bv64)), 0xffffffff00000000:bv64),
       bvand(bvor(0x0:bv64, bvand(var1_4209380_bv64:bv64, 0xffffffff:bv64)),
        0xffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R7:bv64 := 0x403000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209388_bv64:bv64 := 0x0:bv64;
      var var2_4209388_bv64:bv64 := 0x0:bv64;
      var var2_4209388_bv64:bv64 := $R7:bv64;
      $R7:bv64 := bvadd(var2_4209388_bv64:bv64, 0xb30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209392_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 0x0:bv8 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209396_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x8:bv64) $R5:bv64 64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($R0:bv64, 0x8:bv64),
       0x8:bv64) $R5:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209408_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x18:bv64) $R8:bv64 64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($R0:bv64,
        0x18:bv64), 0x8:bv64) $R7:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209416_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x28:bv64) $R6:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209420_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x30:bv64) 0x0:bv32 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209424_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) 0x0:bv64 64;
      $R30:bv64 := 0x403b18:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b90:bv64;
      
      call @fmtlocaleinit_4209552();
      goto (%fmtfdinit_5);
   ];
   block %fmtfdinit_5 [
      assert eq($_PC:bv64, 0x403b18:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209436_bv64:bv64 := 0x0:bv64;
      var var1_4209436_bv64:bv64 := $R31:bv64;
      var var2_4209436_bv64:bv64 := 0x0:bv64;
      var var2_4209436_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4209436_bv64:bv64 := 0x0:bv64;
      var var3_4209436_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4209436_bv64:bv64;
      $R30:bv64 := var3_4209436_bv64:bv64;
      $R31:bv64 := bvadd(var1_4209436_bv64:bv64, 0x10:bv64);
      var var1_4209440_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%fmtfdinit_basil_return_1);
   ];
   block %fmtfdinit_basil_return_1 [ nop; return; ]
];
proc @write()  -> () { .name = "write" }
  
;
proc @__fmtFdFlush_4209456()  -> () { .address = 4209456; .name = "__fmtFdFlush";
    .returnBlock = "__fmtFdFlush_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403b30:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtFdFlush_entry [
      assert eq($_PC:bv64, 0x403b30:bv64);
      $_PC:bv64 := 0x403b30:bv64;
      assert eq($_PC:bv64, 0x403b30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209456_bv64:bv64 := 0x0:bv64;
      var var1_4209456_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffe0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4209456_bv64:bv64, 0xffffffffffffffe0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209460_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209468_bv64:bv64 := 0x0:bv64;
      var var1_4209468_bv64:bv64 := 0x0:bv64;
      var var2_4209468_bv64:bv64 := 0x0:bv64;
      var var2_4209468_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4209468_bv64:bv64,
       bvshl(var2_4209468_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209472_bv64:bv64 := 0x0:bv64;
      var var1_4209472_bv64:bv64 := $R0:bv64;
      var var2_4209472_bv64:bv64 := 0x0:bv64;
      var var2_4209472_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209472_bv64:bv64,
       0x8:bv64) 64;
      var var3_4209472_bv64:bv64 := 0x0:bv64;
      var var3_4209472_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4209472_bv64:bv64,
        0x8:bv64), 0x8:bv64) 64;
      $R1:bv64 := var2_4209472_bv64:bv64;
      $R0:bv64 := var3_4209472_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209476_bv64:bv64 := 0x0:bv64;
      var var1_4209476_bv64:bv64 := $R0:bv64;
      var var2_4209476_bv64:bv64 := 0x0:bv64;
      var var2_4209476_bv64:bv64 := $R1:bv64;
      $R2:bv64 := bvadd(bvadd(var1_4209476_bv64:bv64,
        bvnot(bvshl(var2_4209476_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209480_bv32:bv32 := 0x0:bv32;
      var var2_4209480_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64),
           bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64),
           bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64),
          bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtFdFlush_21,%__fmtFdFlush_19);
   ];
   block %__fmtFdFlush_19 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b64:bv64;
      assert eq($_PC:bv64, 0x403b64:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209508_bv64:bv64 := 0x0:bv64;
      var var1_4209508_bv64:bv64 := $R19:bv64;
      var var2_4209508_bv32:bv32 := 0x0:bv32;
      var var2_4209508_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4209508_bv64:bv64,
       0x28:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4209508_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209512_bv64:bv64 := 0x0:bv64;
      var var1_4209512_bv64:bv64 := $R2:bv64;
      $R20:bv64 := bvor(bvand(sign_extend(63,
        extract(32,31, var1_4209512_bv64:bv64)), 0xffffffff00000000:bv64),
       bvand(bvor(0x0:bv64, bvand(var1_4209512_bv64:bv64, 0xffffffff:bv64)),
        0xffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209516_bv64:bv64 := 0x0:bv64;
      var var1_4209516_bv64:bv64 := 0x0:bv64;
      var var2_4209516_bv64:bv64 := 0x0:bv64;
      var var2_4209516_bv64:bv64 := $R20:bv64;
      $R2:bv64 := bvor(var1_4209516_bv64:bv64,
       bvshl(var2_4209516_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x403b74:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c70:bv64;
      goto (%FUN_400c70_entry_85);
   ];
   block %FUN_400c70_entry_85 [
      var R30_begin_FUN_400c70_4197488_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c70:bv64);
      $_PC:bv64 := 0x400c70:bv64;
      assert eq($_PC:bv64, 0x400c70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197492_bv64_2:bv64 := 0x0:bv64;
      var var1_4197492_bv64_2:bv64 := $R16:bv64;
      var var2_4197492_bv64_3:bv64 := 0x0:bv64;
      var var2_4197492_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197492_bv64_2:bv64,
       0x68:bv64) 64;
      $R17:bv64 := var2_4197492_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197496_bv64_4:bv64 := 0x0:bv64;
      var var2_4197496_bv64_5:bv64 := 0x0:bv64;
      var var2_4197496_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197496_bv64_5:bv64, 0x68:bv64);
      var var1_4197500_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c70_4197488_1:bv64);
      
      call @write();
      goto (%FUN_400c70_basil_return_1_86);
   ];
   block %FUN_400c70_basil_return_1_86 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%__fmtFdFlush_17); ];
   block %__fmtFdFlush_17 [ goto (%__fmtFdFlush_15); ];
   block %__fmtFdFlush_15 [
      assert eq($_PC:bv64, 0x403b74:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209524_bv64:bv64 := 0x0:bv64;
      var var1_4209524_bv64:bv64 := 0x0:bv64;
      var var2_4209524_bv64:bv64 := 0x0:bv64;
      var var2_4209524_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvor(var1_4209524_bv64:bv64,
       bvshl(var2_4209524_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209532_bv64:bv64 := 0x0:bv64;
      var var2_4209532_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtFdFlush_13,%__fmtFdFlush_7);
   ];
   block %__fmtFdFlush_7 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b58:bv64;
      goto (%__fmtFdFlush_5);
   ];
   block %__fmtFdFlush_13 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403b84:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209540_bv64:bv64 := 0x0:bv64;
      var var1_4209540_bv64:bv64 := $R19:bv64;
      var var2_4209540_bv64:bv64 := 0x0:bv64;
      var var2_4209540_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209540_bv64:bv64,
       0x8:bv64) 64;
      $R1:bv64 := var2_4209540_bv64:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b50:bv64;
      goto (%__fmtFdFlush_11);
   ];
   block %__fmtFdFlush_11 [ goto (%__fmtFdFlush_9); ];
   block %__fmtFdFlush_21 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtFdFlush_9);
   ];
   block %__fmtFdFlush_5 [
      assert eq($_PC:bv64, 0x403b58:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209496_bv64:bv64 := 0x0:bv64;
      var var1_4209496_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4209496_bv64:bv64 := 0x0:bv64;
      var var2_4209496_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4209496_bv64:bv64;
      $R20:bv64 := var2_4209496_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209500_bv64:bv64 := 0x0:bv64;
      var var1_4209500_bv64:bv64 := $R31:bv64;
      var var2_4209500_bv64:bv64 := 0x0:bv64;
      var var2_4209500_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4209500_bv64:bv64 := 0x0:bv64;
      var var3_4209500_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4209500_bv64:bv64;
      $R30:bv64 := var3_4209500_bv64:bv64;
      $R31:bv64 := bvadd(var1_4209500_bv64:bv64, 0x20:bv64);
      var var1_4209504_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtFdFlush_basil_return_1);
   ];
   block %__fmtFdFlush_basil_return_1 [ nop; return; ];
   block %__fmtFdFlush_9 [
      assert eq($_PC:bv64, 0x403b50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209492_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $R1:bv64 64;
      goto (%__fmtFdFlush_5);
   ]
];
proc @__flagfmt_4208112()  -> () { .address = 4208112; .name = "__flagfmt";
    .returnBlock = "__flagfmt_basil_return_1" }
  modifies $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R30:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x4035f0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__flagfmt_entry [
      assert eq($_PC:bv64, 0x4035f0:bv64);
      $_PC:bv64 := 0x4035f0:bv64;
      assert eq($_PC:bv64, 0x4035f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208112_bv64:bv64 := 0x0:bv64;
      var var1_4208112_bv64:bv64 := $R0:bv64;
      var var2_4208112_bv32:bv32 := 0x0:bv32;
      var var2_4208112_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4208112_bv64:bv64,
       0x58:bv64) 32;
      $R1:bv64 := zero_extend(32, var2_4208112_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208116_bv32:bv32 := 0x0:bv32;
      var var2_4208116_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffd2:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffd2:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd2:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffd2:bv32), 0x1:bv32));
      goto (%__flagfmt_113,%__flagfmt_9);
   ];
   block %__flagfmt_9 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4036fc:bv64;
      assert eq($_PC:bv64, 0x4036fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208380_bv64:bv64 := 0x0:bv64;
      var var1_4208380_bv64:bv64 := $R0:bv64;
      var var2_4208380_bv64:bv64 := 0x0:bv64;
      var var2_4208380_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208380_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208380_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208384_bv64:bv64 := 0x0:bv64;
      var var1_4208384_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208384_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208388_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_7);
   ];
   block %__flagfmt_7 [ goto (%__flagfmt_5); ];
   block %__flagfmt_113 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4035fc:bv64);
      goto (%__flagfmt_111);
   ];
   block %__flagfmt_111 [ goto (%__flagfmt_109,%__flagfmt_61); ];
   block %__flagfmt_61 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40362c:bv64;
      assert eq($_PC:bv64, 0x40362c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208172_bv32:bv32 := 0x0:bv32;
      var var2_4208172_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffff93:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffff93:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff93:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffff93:bv32), 0x1:bv32));
      goto (%__flagfmt_59);
   ];
   block %__flagfmt_59 [ goto (%__flagfmt_57,%__flagfmt_19); ];
   block %__flagfmt_19 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4036d0:bv64;
      assert eq($_PC:bv64, 0x4036d0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208336_bv64:bv64 := 0x0:bv64;
      var var1_4208336_bv64:bv64 := $R0:bv64;
      var var2_4208336_bv64:bv64 := 0x0:bv64;
      var var2_4208336_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208336_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208336_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208340_bv64:bv64 := 0x0:bv64;
      var var1_4208340_bv64:bv64 := $R1:bv64;
      $R2:bv64 := bvor(var1_4208340_bv64:bv64, 0x800:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208344_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand($R1:bv64, 0x400:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvand($R1:bv64, 0x400:bv64));
      var var1_4208348_bv64:bv64 := 0x0:bv64;
      var var1_4208348_bv64:bv64 := $R2:bv64;
      var var2_4208348_bv64:bv64 := 0x0:bv64;
      var var2_4208348_bv64:bv64 := $R1:bv64;
      goto (%__flagfmt_17);
   ];
   block %__flagfmt_17 [ goto (%__flagfmt_15,%__flagfmt_13); ];
   block %__flagfmt_13 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var1_4208348_bv64:bv64;
      goto (%__flagfmt_11);
   ];
   block %__flagfmt_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var2_4208348_bv64:bv64;
      goto (%__flagfmt_11);
   ];
   block %__flagfmt_11 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208352_bv64:bv64 := 0x0:bv64;
      var var1_4208352_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208352_bv64:bv64, 0x400:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208356_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_57 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403634:bv64);
      goto (%__flagfmt_55);
   ];
   block %__flagfmt_55 [ goto (%__flagfmt_53,%__flagfmt_29); ];
   block %__flagfmt_29 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4036b8:bv64;
      assert eq($_PC:bv64, 0x4036b8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208312_bv32:bv32 := 0x0:bv32;
      var var2_4208312_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffff8a:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffff8a:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff8a:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffff8a:bv32), 0x1:bv32));
      goto (%__flagfmt_27);
   ];
   block %__flagfmt_27 [ goto (%__flagfmt_25,%__flagfmt_21); ];
   block %__flagfmt_21 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_25 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4036c0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208320_bv64:bv64 := 0x0:bv64;
      var var1_4208320_bv64:bv64 := $R0:bv64;
      var var2_4208320_bv64:bv64 := 0x0:bv64;
      var var2_4208320_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208320_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208320_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208324_bv64:bv64 := 0x0:bv64;
      var var1_4208324_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208324_bv64:bv64, 0x100:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208328_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_23);
   ];
   block %__flagfmt_23 [ goto (%__flagfmt_5); ];
   block %__flagfmt_53 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403638:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208184_bv32:bv32 := 0x0:bv32;
      var var2_4208184_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffb3:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffb3:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffb3:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffb3:bv32), 0x1:bv32));
      goto (%__flagfmt_51);
   ];
   block %__flagfmt_51 [ goto (%__flagfmt_49,%__flagfmt_33); ];
   block %__flagfmt_33 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403698:bv64;
      assert eq($_PC:bv64, 0x403698:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208280_bv64:bv64 := 0x0:bv64;
      var var1_4208280_bv64:bv64 := $R0:bv64;
      var var2_4208280_bv64:bv64 := 0x0:bv64;
      var var2_4208280_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208280_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208280_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208284_bv64:bv64 := 0x0:bv64;
      var var1_4208284_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208284_bv64:bv64, 0x4000:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208288_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_31);
   ];
   block %__flagfmt_31 [ goto (%__flagfmt_5); ];
   block %__flagfmt_49 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403640:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208192_bv32:bv32 := 0x0:bv32;
      var var2_4208192_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffff97:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffff97:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffff97:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffff97:bv32), 0x1:bv32));
      goto (%__flagfmt_47);
   ];
   block %__flagfmt_47 [ goto (%__flagfmt_45,%__flagfmt_35); ];
   block %__flagfmt_35 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_45 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403648:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208200_bv64:bv64 := 0x0:bv64;
      var var1_4208200_bv64:bv64 := $R0:bv64;
      var var2_4208200_bv64:bv64 := 0x0:bv64;
      var var2_4208200_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208200_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208200_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208204_bv64:bv64 := 0x0:bv64;
      var var1_4208204_bv64:bv64 := $R1:bv64;
      $R2:bv64 := bvor(var1_4208204_bv64:bv64, 0x2000:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208208_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand($R1:bv64, 0x200:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvand($R1:bv64, 0x200:bv64));
      var var1_4208212_bv64:bv64 := 0x0:bv64;
      var var1_4208212_bv64:bv64 := $R2:bv64;
      var var2_4208212_bv64:bv64 := 0x0:bv64;
      var var2_4208212_bv64:bv64 := $R1:bv64;
      goto (%__flagfmt_43);
   ];
   block %__flagfmt_43 [ goto (%__flagfmt_41,%__flagfmt_39); ];
   block %__flagfmt_39 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var1_4208212_bv64:bv64;
      goto (%__flagfmt_37);
   ];
   block %__flagfmt_41 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var2_4208212_bv64:bv64;
      goto (%__flagfmt_37);
   ];
   block %__flagfmt_37 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208216_bv64:bv64 := 0x0:bv64;
      var var1_4208216_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208216_bv64:bv64, 0x200:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208220_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_109 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403600:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208128_bv32:bv32 := 0x0:bv32;
      var var2_4208128_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffd8:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffd8:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd8:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffd8:bv32), 0x1:bv32));
      goto (%__flagfmt_107);
   ];
   block %__flagfmt_107 [ goto (%__flagfmt_105,%__flagfmt_65); ];
   block %__flagfmt_65 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4036ec:bv64;
      assert eq($_PC:bv64, 0x4036ec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208364_bv64:bv64 := 0x0:bv64;
      var var1_4208364_bv64:bv64 := $R0:bv64;
      var var2_4208364_bv64:bv64 := 0x0:bv64;
      var var2_4208364_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208364_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208364_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208368_bv64:bv64 := 0x0:bv64;
      var var1_4208368_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208368_bv64:bv64, 0x40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208372_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_63);
   ];
   block %__flagfmt_63 [ goto (%__flagfmt_5); ];
   block %__flagfmt_105 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403608:bv64);
      goto (%__flagfmt_103);
   ];
   block %__flagfmt_103 [ goto (%__flagfmt_101,%__flagfmt_83); ];
   block %__flagfmt_83 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403664:bv64;
      assert eq($_PC:bv64, 0x403664:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208228_bv32:bv32 := 0x0:bv32;
      var var2_4208228_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffd4:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffd4:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd4:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffd4:bv32), 0x1:bv32));
      goto (%__flagfmt_81);
   ];
   block %__flagfmt_81 [ goto (%__flagfmt_79,%__flagfmt_69); ];
   block %__flagfmt_69 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403688:bv64;
      assert eq($_PC:bv64, 0x403688:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208264_bv64:bv64 := 0x0:bv64;
      var var1_4208264_bv64:bv64 := $R0:bv64;
      var var2_4208264_bv64:bv64 := 0x0:bv64;
      var var2_4208264_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208264_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208264_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208268_bv64:bv64 := 0x0:bv64;
      var var1_4208268_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208268_bv64:bv64, 0x20:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208272_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_67);
   ];
   block %__flagfmt_67 [ goto (%__flagfmt_5); ];
   block %__flagfmt_79 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40366c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208236_bv32:bv32 := 0x0:bv32;
      var var2_4208236_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffd3:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffd3:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffd3:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffd3:bv32), 0x1:bv32));
      goto (%__flagfmt_77);
   ];
   block %__flagfmt_77 [ goto (%__flagfmt_75,%__flagfmt_71); ];
   block %__flagfmt_71 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_75 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403674:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208244_bv64:bv64 := 0x0:bv64;
      var var1_4208244_bv64:bv64 := $R0:bv64;
      var var2_4208244_bv64:bv64 := 0x0:bv64;
      var var2_4208244_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208244_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208244_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208248_bv64:bv64 := 0x0:bv64;
      var var1_4208248_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208248_bv64:bv64, 0x1000:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208252_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      goto (%__flagfmt_73);
   ];
   block %__flagfmt_73 [ goto (%__flagfmt_5); ];
   block %__flagfmt_101 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40360c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208140_bv32:bv32 := 0x0:bv32;
      var var2_4208140_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffdf:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffdf:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdf:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffdf:bv32), 0x1:bv32));
      goto (%__flagfmt_99);
   ];
   block %__flagfmt_99 [ goto (%__flagfmt_97,%__flagfmt_87); ];
   block %__flagfmt_87 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4036a8:bv64;
      assert eq($_PC:bv64, 0x4036a8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208296_bv64:bv64 := 0x0:bv64;
      var var1_4208296_bv64:bv64 := $R0:bv64;
      var var2_4208296_bv64:bv64 := 0x0:bv64;
      var var2_4208296_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208296_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208296_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208300_bv64:bv64 := 0x0:bv64;
      var var1_4208300_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208300_bv64:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208304_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_85);
   ];
   block %__flagfmt_85 [ goto (%__flagfmt_5); ];
   block %__flagfmt_97 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403614:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208148_bv32:bv32 := 0x0:bv32;
      var var2_4208148_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffdc:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffdc:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffdc:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffdc:bv32), 0x1:bv32));
      goto (%__flagfmt_95);
   ];
   block %__flagfmt_95 [ goto (%__flagfmt_93,%__flagfmt_89); ];
   block %__flagfmt_89 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_5);
   ];
   block %__flagfmt_93 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40361c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208156_bv64:bv64 := 0x0:bv64;
      var var1_4208156_bv64:bv64 := $R0:bv64;
      var var2_4208156_bv64:bv64 := 0x0:bv64;
      var var2_4208156_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208156_bv64:bv64,
       0x68:bv64) 64;
      $R1:bv64 := var2_4208156_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208160_bv64:bv64 := 0x0:bv64;
      var var1_4208160_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvor(var1_4208160_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208164_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403680:bv64;
      goto (%__flagfmt_91);
   ];
   block %__flagfmt_91 [ goto (%__flagfmt_5); ];
   block %__flagfmt_5 [
      assert eq($_PC:bv64, 0x403680:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      var var1_4208260_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__flagfmt_basil_return_1);
   ];
   block %__flagfmt_basil_return_1 [ nop; return; ]
];
proc @__rfmtpad_4203024()  -> () { .address = 4203024; .name = "__rfmtpad";
    .returnBlock = "__rfmtpad_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x402210:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__rfmtpad_entry [
      assert eq($_PC:bv64, 0x402210:bv64);
      $_PC:bv64 := 0x402210:bv64;
      assert eq($_PC:bv64, 0x402210:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203024_bv64:bv64 := 0x0:bv64;
      var var1_4203024_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4203024_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203028_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203036_bv64:bv64 := 0x0:bv64;
      var var1_4203036_bv64:bv64 := 0x0:bv64;
      var var2_4203036_bv64:bv64 := 0x0:bv64;
      var var2_4203036_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4203036_bv64:bv64,
       bvshl(var2_4203036_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203040_bv64:bv64 := 0x0:bv64;
      var var1_4203040_bv64:bv64 := $R0:bv64;
      var var2_4203040_bv64:bv64 := 0x0:bv64;
      var var2_4203040_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203040_bv64:bv64,
       0x10:bv64) 64;
      var var3_4203040_bv64:bv64 := 0x0:bv64;
      var var3_4203040_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4203040_bv64:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R2:bv64 := var2_4203040_bv64:bv64;
      $R6:bv64 := var3_4203040_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203044_bv32:bv32 := 0x0:bv32;
      var var2_4203044_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__rfmtpad_73,%__rfmtpad_11);
   ];
   block %__rfmtpad_11 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402310:bv64;
      assert eq($_PC:bv64, 0x402310:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203280_bv64:bv64 := 0x0:bv64;
      var var1_4203280_bv64:bv64 := $R19:bv64;
      var var2_4203280_bv32:bv32 := 0x0:bv32;
      var var2_4203280_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203280_bv64:bv64,
       0x30:bv64) 32;
      $R4:bv64 := zero_extend(32, var2_4203280_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4022e0:bv64;
      goto (%__rfmtpad_9);
   ];
   block %__rfmtpad_9 [ goto (%__rfmtpad_7); ];
   block %__rfmtpad_73 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40222c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203052_bv64:bv64 := 0x0:bv64;
      var var1_4203052_bv64:bv64 := $R0:bv64;
      var var2_4203052_bv32:bv32 := 0x0:bv32;
      var var2_4203052_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203052_bv64:bv64,
       0x30:bv64) 32;
      $R4:bv64 := zero_extend(32, var2_4203052_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203056_bv64:bv64 := 0x0:bv64;
      var var1_4203056_bv64:bv64 := 0x0:bv64;
      var var2_4203056_bv64:bv64 := 0x0:bv64;
      var var2_4203056_bv64:bv64 := $R2:bv64;
      $R5:bv64 := bvor(var1_4203056_bv64:bv64,
       bvshl(var2_4203056_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203068_bv32:bv32 := 0x0:bv32;
      var var1_4203068_bv32:bv32 := 0x0:bv32;
      var var2_4203068_bv32:bv32 := 0x0:bv32;
      var var2_4203068_bv32:bv32 := extract(32,0, $R1:bv64);
      $R21:bv64 := zero_extend(32,
      bvor(var1_4203068_bv32:bv32, bvshl(var2_4203068_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R22:bv64 := 0x20:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40225c:bv64;
      goto (%__rfmtpad_71);
   ];
   block %__rfmtpad_71 [ goto (%__rfmtpad_69); ];
   block %__rfmtpad_69 [
      assert eq($_PC:bv64, 0x40225c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203100_bv64:bv64 := 0x0:bv64;
      var var2_4203100_bv64:bv64 := 0x0:bv64;
      var var2_4203100_bv64:bv64 := $R2:bv64;
      $R0:bv64 := bvadd(var2_4203100_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203104_bv64:bv64 := 0x0:bv64;
      var var1_4203104_bv64:bv64 := 0x0:bv64;
      var var2_4203104_bv64:bv64 := 0x0:bv64;
      var var2_4203104_bv64:bv64 := $R2:bv64;
      $R3:bv64 := bvor(var1_4203104_bv64:bv64,
       bvshl(var2_4203104_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203108_bv64:bv64 := 0x0:bv64;
      var var2_4203108_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R0:bv64),
           sign_extend(64, bvnot(bvshl($R6:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R0:bv64),
           zero_extend(64, bvnot(bvshl($R6:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64,
          bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R0:bv64,
        bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__rfmtpad_67,%__rfmtpad_21);
   ];
   block %__rfmtpad_21 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402248:bv64;
      assert eq($_PC:bv64, 0x402248:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203080_bv32:bv32 := 0x0:bv32;
      var var2_4203080_bv32:bv32 := 0x0:bv32;
      var var2_4203080_bv32:bv32 := extract(32,0, $R20:bv64);
      $R20:bv64 := zero_extend(32, bvadd(var2_4203080_bv32:bv32, 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203084_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R3:bv64 extract(16,0, $R22:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203088_bv64:bv64 := 0x0:bv64;
      var var1_4203088_bv64:bv64 := 0x0:bv64;
      var var2_4203088_bv64:bv64 := 0x0:bv64;
      var var2_4203088_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvor(var1_4203088_bv64:bv64,
       bvshl(var2_4203088_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203092_bv32:bv32 := 0x0:bv32;
      var var2_4203092_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__rfmtpad_19);
   ];
   block %__rfmtpad_19 [ goto (%__rfmtpad_17,%__rfmtpad_15); ];
   block %__rfmtpad_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4022d4:bv64;
      goto (%__rfmtpad_13);
   ];
   block %__rfmtpad_17 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__rfmtpad_69);
   ];
   block %__rfmtpad_67 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40226c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203116_bv64:bv64 := 0x0:bv64;
      var var1_4203116_bv64:bv64 := $R2:bv64;
      var var2_4203116_bv64:bv64 := 0x0:bv64;
      var var2_4203116_bv64:bv64 := $R5:bv64;
      $R0:bv64 := bvadd(bvadd(var1_4203116_bv64:bv64,
        bvnot(bvshl(var2_4203116_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203120_bv64:bv64 := 0x0:bv64;
      var var1_4203120_bv64:bv64 := $R19:bv64;
      var var2_4203120_bv8:bv8 := 0x0:bv8;
      var var2_4203120_bv8:bv8 := load le $mem:(bv64->bv8) var1_4203120_bv64:bv64 8;
      $R5:bv64 := zero_extend(32, zero_extend(24, var2_4203120_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203124_bv64:bv64 := 0x0:bv64;
      var var1_4203124_bv64:bv64 := $R19:bv64;
      var var2_4203124_bv64:bv64 := 0x0:bv64;
      var var2_4203124_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203124_bv64:bv64,
       0x20:bv64) 64;
      $R1:bv64 := var2_4203124_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203128_bv64:bv64 := 0x0:bv64;
      var var1_4203128_bv64:bv64 := $R0:bv64;
      $R3:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4203128_bv64:bv64)), 0x8000000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4203128_bv64:bv64, 0x1:bv64),
          bvshl(var1_4203128_bv64:bv64, 0x3f:bv64))), 0x7fffffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203132_bv32:bv32 := 0x0:bv32;
      var var1_4203132_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4203132_bv32:bv32 := 0x0:bv32;
      var var2_4203132_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(var1_4203132_bv32:bv32, bvshl(var2_4203132_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203136_bv32:bv32 := 0x0:bv32;
      var var2_4203136_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R5:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R5:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R5:bv64),
        0xffffffff:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203140_bv32:bv32 := 0x0:bv32;
      var var1_4203140_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4203140_bv32:bv32 := 0x0:bv32;
      var var2_4203140_bv32:bv32 := extract(32,0, $R0:bv64);
      $R4:bv64 := zero_extend(32,
      bvadd(var1_4203140_bv32:bv32, bvshl(var2_4203140_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203144_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64;
      var var1_4203148_bv32:bv32 := 0x0:bv32;
      var var1_4203148_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4203148_bv32:bv32 := 0x0:bv32;
      var var2_4203148_bv32:bv32 := extract(32,0, $R3:bv64);
      goto (%__rfmtpad_65);
   ];
   block %__rfmtpad_65 [ goto (%__rfmtpad_63,%__rfmtpad_61); ];
   block %__rfmtpad_61 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R4:bv64 := zero_extend(32, var1_4203148_bv32:bv32);
      goto (%__rfmtpad_59);
   ];
   block %__rfmtpad_63 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R4:bv64 := zero_extend(32, var2_4203148_bv32:bv32);
      goto (%__rfmtpad_59);
   ];
   block %__rfmtpad_59 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203152_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x30:bv64) extract(32,0, $R4:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203156_bv64:bv64 := 0x0:bv64;
      var var1_4203156_bv64:bv64 := 0x0:bv64;
      var var2_4203156_bv64:bv64 := 0x0:bv64;
      var var2_4203156_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4203156_bv64:bv64,
       bvshl(var2_4203156_bv64:bv64, 0x0:bv64));
      goto (%__rfmtpad_57,%__rfmtpad_29);
   ];
   block %__rfmtpad_29 [
      guard eq($R1:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4022fc:bv64;
      assert eq($_PC:bv64, 0x4022fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203260_bv64:bv64 := 0x0:bv64;
      var var1_4203260_bv64:bv64 := 0x0:bv64;
      var var2_4203260_bv64:bv64 := 0x0:bv64;
      var var2_4203260_bv64:bv64 := $R2:bv64;
      $R3:bv64 := bvor(var1_4203260_bv64:bv64,
       bvshl(var2_4203260_bv64:bv64, 0x0:bv64));
      goto (%__rfmtpad_27);
   ];
   block %__rfmtpad_27 [ goto (%__rfmtpad_25); ];
   block %__rfmtpad_57 [
      guard boolnot(eq($R1:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40229c:bv64);
      var var1_4203164_bv64:bv64 := 0x0:bv64;
      var var1_4203164_bv64:bv64 := $R1:bv64;
      $R30:bv64 := 0x4022a0:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4203164_bv64:bv64;
      indirect call var1_4203164_bv64:bv64;
      goto (%__rfmtpad_55);
   ];
   block %__rfmtpad_55 [ goto (%__rfmtpad_53); ];
   block %__rfmtpad_53 [
      assert eq($_PC:bv64, 0x4022a0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203168_bv64:bv64 := 0x0:bv64;
      var var1_4203168_bv64:bv64 := $R19:bv64;
      var var2_4203168_bv64:bv64 := 0x0:bv64;
      var var2_4203168_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203168_bv64:bv64,
       0x10:bv64) 64;
      $R3:bv64 := var2_4203168_bv64:bv64;
      goto (%__rfmtpad_51,%__rfmtpad_31);
   ];
   block %__rfmtpad_31 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402300:bv64;
      goto (%__rfmtpad_25);
   ];
   block %__rfmtpad_51 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4022a8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203176_bv64:bv64 := 0x0:bv64;
      var var1_4203176_bv64:bv64 := $R19:bv64;
      var var2_4203176_bv64:bv64 := 0x0:bv64;
      var var2_4203176_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203176_bv64:bv64,
       0x18:bv64) 64;
      $R6:bv64 := var2_4203176_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203180_bv64:bv64 := 0x0:bv64;
      var var2_4203180_bv64:bv64 := 0x0:bv64;
      var var2_4203180_bv64:bv64 := $R3:bv64;
      $R2:bv64 := bvadd(var2_4203180_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203184_bv64:bv64 := 0x0:bv64;
      var var1_4203184_bv64:bv64 := 0x0:bv64;
      var var2_4203184_bv64:bv64 := 0x0:bv64;
      var var2_4203184_bv64:bv64 := $R3:bv64;
      $R5:bv64 := bvor(var1_4203184_bv64:bv64,
       bvshl(var2_4203184_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203188_bv64:bv64 := 0x0:bv64;
      var var2_4203188_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R6:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R6:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R6:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__rfmtpad_49);
   ];
   block %__rfmtpad_49 [ goto (%__rfmtpad_47,%__rfmtpad_33); ];
   block %__rfmtpad_33 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402300:bv64;
      goto (%__rfmtpad_25);
   ];
   block %__rfmtpad_47 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4022bc:bv64);
      goto (%__rfmtpad_45);
   ];
   block %__rfmtpad_45 [ goto (%__rfmtpad_43,%__rfmtpad_35); ];
   block %__rfmtpad_35 [
      guard eq($R3:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402304:bv64;
      goto (%__rfmtpad_23);
   ];
   block %__rfmtpad_43 [
      guard boolnot(eq($R3:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4022c0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203200_bv64:bv64 := 0x0:bv64;
      var var1_4203200_bv64:bv64 := $R19:bv64;
      var var2_4203200_bv32:bv32 := 0x0:bv32;
      var var2_4203200_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203200_bv64:bv64,
       0x30:bv64) 32;
      $R4:bv64 := zero_extend(32, var2_4203200_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203204_bv32:bv32 := 0x0:bv32;
      var var2_4203204_bv32:bv32 := 0x0:bv32;
      var var2_4203204_bv32:bv32 := extract(32,0, $R20:bv64);
      $R20:bv64 := zero_extend(32, bvadd(var2_4203204_bv32:bv32, 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203208_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R3:bv64 extract(16,0, $R22:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203212_bv32:bv32 := 0x0:bv32;
      var var2_4203212_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__rfmtpad_41);
   ];
   block %__rfmtpad_41 [ goto (%__rfmtpad_39,%__rfmtpad_37); ];
   block %__rfmtpad_37 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40225c:bv64;
      goto (%__rfmtpad_69);
   ];
   block %__rfmtpad_39 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__rfmtpad_13);
   ];
   block %__rfmtpad_23 [
      assert eq($_PC:bv64, 0x402304:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203268_bv64:bv64 := 0x0:bv64;
      var var1_4203268_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4203268_bv64:bv64 := 0x0:bv64;
      var var2_4203268_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4203268_bv64:bv64;
      $R22:bv64 := var2_4203268_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4022f0:bv64;
      goto (%__rfmtpad_5);
   ];
   block %__rfmtpad_25 [
      assert eq($_PC:bv64, 0x402300:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203264_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x18:bv64) $R3:bv64 64;
      goto (%__rfmtpad_23);
   ];
   block %__rfmtpad_13 [
      assert eq($_PC:bv64, 0x4022d4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203220_bv64:bv64 := 0x0:bv64;
      var var1_4203220_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4203220_bv64:bv64 := 0x0:bv64;
      var var2_4203220_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4203220_bv64:bv64;
      $R22:bv64 := var2_4203220_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203224_bv64:bv64 := 0x0:bv64;
      var var1_4203224_bv64:bv64 := $R2:bv64;
      var var2_4203224_bv64:bv64 := 0x0:bv64;
      var var2_4203224_bv64:bv64 := $R5:bv64;
      $R0:bv64 := bvadd(bvadd(var1_4203224_bv64:bv64,
        bvnot(bvshl(var2_4203224_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203228_bv64:bv64 := 0x0:bv64;
      var var1_4203228_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(0x0:bv64,
       bvand(bvor(0x0:bv64,
         bvand(bvor(bvlshr(var1_4203228_bv64:bv64, 0x1:bv64),
           bvshl(var1_4203228_bv64:bv64, 0x3f:bv64)), 0x80000000ffffffff:bv64)),
        0xffffffff:bv64));
      goto (%__rfmtpad_7);
   ];
   block %__rfmtpad_5 [
      assert eq($_PC:bv64, 0x4022f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203248_bv64:bv64 := 0x0:bv64;
      var var1_4203248_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4203248_bv64:bv64 := 0x0:bv64;
      var var2_4203248_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4203248_bv64:bv64;
      $R20:bv64 := var2_4203248_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203252_bv64:bv64 := 0x0:bv64;
      var var1_4203252_bv64:bv64 := $R31:bv64;
      var var2_4203252_bv64:bv64 := 0x0:bv64;
      var var2_4203252_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4203252_bv64:bv64 := 0x0:bv64;
      var var3_4203252_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4203252_bv64:bv64;
      $R30:bv64 := var3_4203252_bv64:bv64;
      $R31:bv64 := bvadd(var1_4203252_bv64:bv64, 0x30:bv64);
      var var1_4203256_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__rfmtpad_basil_return_1);
   ];
   block %__rfmtpad_basil_return_1 [ nop; return; ];
   block %__rfmtpad_7 [
      assert eq($_PC:bv64, 0x4022e0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203232_bv32:bv32 := 0x0:bv32;
      var var1_4203232_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4203232_bv32:bv32 := 0x0:bv32;
      var var2_4203232_bv32:bv32 := extract(32,0, $R0:bv64);
      $R4:bv64 := zero_extend(32,
      bvadd(var1_4203232_bv32:bv32, bvshl(var2_4203232_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203240_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203244_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x30:bv64) extract(32,0, $R4:bv64) 32;
      goto (%__rfmtpad_5);
   ]
];
proc @runelen_4210048()  -> () { .address = 4210048; .name = "runelen";
    .returnBlock = "runelen_basil_return_1" }
  modifies $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R30:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403d80:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %runelen_entry [
      assert eq($_PC:bv64, 0x403d80:bv64);
      $_PC:bv64 := 0x403d80:bv64;
      assert eq($_PC:bv64, 0x403d80:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210048_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand($R0:bv64, 0xff80:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvand($R0:bv64, 0xff80:bv64));
      goto (%runelen_15,%runelen_5);
   ];
   block %runelen_5 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403d98:bv64;
      assert eq($_PC:bv64, 0x403d98:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      var var1_4210076_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%runelen_3);
   ];
   block %runelen_3 [ goto (%runelen_basil_return_1); ];
   block %runelen_15 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403d88:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210056_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand($R0:bv64, 0xf800:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvand($R0:bv64, 0xf800:bv64));
      var var1_4210060_bv32:bv32 := 0x0:bv32;
      var var1_4210060_bv32:bv32 := 0x0:bv32;
      var var2_4210060_bv32:bv32 := 0x0:bv32;
      var var2_4210060_bv32:bv32 := 0x0:bv32;
      goto (%runelen_13);
   ];
   block %runelen_13 [ goto (%runelen_11,%runelen_9); ];
   block %runelen_9 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := zero_extend(32, var1_4210060_bv32:bv32);
      goto (%runelen_7);
   ];
   block %runelen_11 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := zero_extend(32, bvadd(var2_4210060_bv32:bv32, 0x1:bv32));
      goto (%runelen_7);
   ];
   block %runelen_7 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210064_bv32:bv32 := 0x0:bv32;
      var var2_4210064_bv32:bv32 := 0x0:bv32;
      var var2_4210064_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32, bvadd(var2_4210064_bv32:bv32, 0x2:bv32));
      var var1_4210068_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%runelen_basil_return_1);
   ];
   block %runelen_basil_return_1 [ nop; return; ]
];
proc @fullrune_4210160()  -> () { .address = 4210160; .name = "fullrune";
    .returnBlock = "fullrune_basil_return_1" }
  modifies $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R2:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R30:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403df0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %fullrune_entry [
      assert eq($_PC:bv64, 0x403df0:bv64);
      $_PC:bv64 := 0x403df0:bv64;
      assert eq($_PC:bv64, 0x403df0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210160_bv32:bv32 := 0x0:bv32;
      var var2_4210160_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%fullrune_35,%fullrune_7);
   ];
   block %fullrune_7 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403e24:bv64;
      assert eq($_PC:bv64, 0x403e24:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      var var1_4210216_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%fullrune_5);
   ];
   block %fullrune_5 [ goto (%fullrune_basil_return_1); ];
   block %fullrune_35 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403df8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210168_bv64:bv64 := 0x0:bv64;
      var var1_4210168_bv64:bv64 := $R0:bv64;
      var var2_4210168_bv8:bv8 := 0x0:bv8;
      var var2_4210168_bv8:bv8 := load le $mem:(bv64->bv8) var1_4210168_bv64:bv64 8;
      $R2:bv64 := zero_extend(32, zero_extend(24, var2_4210168_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210176_bv32:bv32 := 0x0:bv32;
      var var2_4210176_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%fullrune_33);
   ];
   block %fullrune_33 [ goto (%fullrune_31,%fullrune_11); ];
   block %fullrune_11 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403e20:bv64;
      goto (%fullrune_9);
   ];
   block %fullrune_31 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403e08:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210188_bv32:bv32 := 0x0:bv32;
      var var2_4210188_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xfffffffffffffffe:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xfffffffe:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffe:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xfffffffe:bv32), 0x1:bv32));
      goto (%fullrune_29);
   ];
   block %fullrune_29 [ goto (%fullrune_27,%fullrune_13); ];
   block %fullrune_13 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403e20:bv64;
      goto (%fullrune_9);
   ];
   block %fullrune_27 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403e14:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210196_bv32:bv32 := 0x0:bv32;
      var var2_4210196_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           0xffffffffffffff20:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)), 0xffffff20:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        0xffffff20:bv32), 0x1:bv32));
      var var1_4210200_bool:bool := booland(eq($NF:bv1, $VF:bv1),
       eq($ZF:bv1, 0x0:bv1));
      goto (%fullrune_25);
   ];
   block %fullrune_25 [ goto (%fullrune_23,%fullrune_21); ];
   block %fullrune_21 [
      guard var1_4210200_bool:bool;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xfffffffffffffffd:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xfffffffd:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffffd:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xfffffffd:bv32), 0x1:bv32));
      goto (%fullrune_19);
   ];
   block %fullrune_23 [
      guard boolnot(var1_4210200_bool:bool);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := 0x0:bv1;
      $NF:bv1 := 0x0:bv1;
      goto (%fullrune_19);
   ];
   block %fullrune_19 [
      var var1_4210204_bv32:bv32 := 0x0:bv32;
      var var1_4210204_bv32:bv32 := 0x0:bv32;
      var var2_4210204_bv32:bv32 := 0x0:bv32;
      var var2_4210204_bv32:bv32 := 0x0:bv32;
      goto (%fullrune_17,%fullrune_15);
   ];
   block %fullrune_15 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := zero_extend(32, var1_4210204_bv32:bv32);
      goto (%fullrune_9);
   ];
   block %fullrune_17 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := zero_extend(32, bvadd(var2_4210204_bv32:bv32, 0x1:bv32));
      goto (%fullrune_9);
   ];
   block %fullrune_9 [
      assert eq($_PC:bv64, 0x403e20:bv64);
      var var1_4210208_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%fullrune_basil_return_1);
   ];
   block %fullrune_basil_return_1 [ nop; return; ]
];
proc @__fmtpad_4202756()  -> () { .address = 4202756; .name = "__fmtpad";
    .returnBlock = "__fmtpad_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x402104:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtpad_entry [
      assert eq($_PC:bv64, 0x402104:bv64);
      $_PC:bv64 := 0x402104:bv64;
      assert eq($_PC:bv64, 0x402104:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202756_bv64:bv64 := 0x0:bv64;
      var var1_4202756_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4202756_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202760_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202768_bv64:bv64 := 0x0:bv64;
      var var1_4202768_bv64:bv64 := 0x0:bv64;
      var var2_4202768_bv64:bv64 := 0x0:bv64;
      var var2_4202768_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4202768_bv64:bv64,
       bvshl(var2_4202768_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202772_bv64:bv64 := 0x0:bv64;
      var var1_4202772_bv64:bv64 := $R0:bv64;
      var var2_4202772_bv64:bv64 := 0x0:bv64;
      var var2_4202772_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202772_bv64:bv64,
       0x10:bv64) 64;
      var var3_4202772_bv64:bv64 := 0x0:bv64;
      var var3_4202772_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4202772_bv64:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R2:bv64 := var2_4202772_bv64:bv64;
      $R4:bv64 := var3_4202772_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202776_bv32:bv32 := 0x0:bv32;
      var var2_4202776_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__fmtpad_75,%__fmtpad_11);
   ];
   block %__fmtpad_11 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402204:bv64;
      assert eq($_PC:bv64, 0x402204:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021c8:bv64;
      goto (%__fmtpad_9);
   ];
   block %__fmtpad_9 [ goto (%__fmtpad_7); ];
   block %__fmtpad_75 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402120:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202792_bv32:bv32 := 0x0:bv32;
      var var1_4202792_bv32:bv32 := 0x0:bv32;
      var var2_4202792_bv32:bv32 := 0x0:bv32;
      var var2_4202792_bv32:bv32 := extract(32,0, $R1:bv64);
      $R21:bv64 := zero_extend(32,
      bvor(var1_4202792_bv32:bv32, bvshl(var2_4202792_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R22:bv64 := 0x20:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402148:bv64;
      goto (%__fmtpad_73);
   ];
   block %__fmtpad_73 [ goto (%__fmtpad_71); ];
   block %__fmtpad_71 [
      assert eq($_PC:bv64, 0x402148:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202824_bv64:bv64 := 0x0:bv64;
      var var2_4202824_bv64:bv64 := 0x0:bv64;
      var var2_4202824_bv64:bv64 := $R2:bv64;
      $R3:bv64 := bvadd(var2_4202824_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202828_bv64:bv64 := 0x0:bv64;
      var var1_4202828_bv64:bv64 := 0x0:bv64;
      var var2_4202828_bv64:bv64 := 0x0:bv64;
      var var2_4202828_bv64:bv64 := $R2:bv64;
      $R0:bv64 := bvor(var1_4202828_bv64:bv64,
       bvshl(var2_4202828_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202832_bv64:bv64 := 0x0:bv64;
      var var2_4202832_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R3:bv64),
           sign_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R3:bv64),
           zero_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64,
          bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R3:bv64,
        bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtpad_69,%__fmtpad_21);
   ];
   block %__fmtpad_21 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402134:bv64;
      assert eq($_PC:bv64, 0x402134:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202804_bv32:bv32 := 0x0:bv32;
      var var2_4202804_bv32:bv32 := 0x0:bv32;
      var var2_4202804_bv32:bv32 := extract(32,0, $R20:bv64);
      $R20:bv64 := zero_extend(32, bvadd(var2_4202804_bv32:bv32, 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202808_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(8,0, $R22:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202812_bv64:bv64 := 0x0:bv64;
      var var1_4202812_bv64:bv64 := 0x0:bv64;
      var var2_4202812_bv64:bv64 := 0x0:bv64;
      var var2_4202812_bv64:bv64 := $R3:bv64;
      $R2:bv64 := bvor(var1_4202812_bv64:bv64,
       bvshl(var2_4202812_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202816_bv32:bv32 := 0x0:bv32;
      var var2_4202816_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtpad_19);
   ];
   block %__fmtpad_19 [ goto (%__fmtpad_17,%__fmtpad_15); ];
   block %__fmtpad_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021bc:bv64;
      goto (%__fmtpad_13);
   ];
   block %__fmtpad_17 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtpad_71);
   ];
   block %__fmtpad_69 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402158:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202840_bv64:bv64 := 0x0:bv64;
      var var1_4202840_bv64:bv64 := $R19:bv64;
      var var2_4202840_bv64:bv64 := 0x0:bv64;
      var var2_4202840_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202840_bv64:bv64,
       0x10:bv64) 64;
      $R4:bv64 := var2_4202840_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202844_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202848_bv64:bv64 := 0x0:bv64;
      var var1_4202848_bv64:bv64 := $R19:bv64;
      var var2_4202848_bv32:bv32 := 0x0:bv32;
      var var2_4202848_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202848_bv64:bv64,
       0x30:bv64) 32;
      $R3:bv64 := zero_extend(32, var2_4202848_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202852_bv64:bv64 := 0x0:bv64;
      var var1_4202852_bv64:bv64 := 0x0:bv64;
      var var2_4202852_bv64:bv64 := 0x0:bv64;
      var var2_4202852_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4202852_bv64:bv64,
       bvshl(var2_4202852_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202856_bv64:bv64 := 0x0:bv64;
      var var1_4202856_bv64:bv64 := $R2:bv64;
      var var2_4202856_bv64:bv64 := 0x0:bv64;
      var var2_4202856_bv64:bv64 := $R4:bv64;
      $R4:bv64 := bvadd(bvadd(var1_4202856_bv64:bv64,
        bvnot(bvshl(var2_4202856_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202860_bv64:bv64 := 0x0:bv64;
      var var1_4202860_bv64:bv64 := $R19:bv64;
      var var2_4202860_bv8:bv8 := 0x0:bv8;
      var var2_4202860_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202860_bv64:bv64 8;
      $R6:bv64 := zero_extend(32, zero_extend(24, var2_4202860_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202864_bv64:bv64 := 0x0:bv64;
      var var1_4202864_bv64:bv64 := $R19:bv64;
      var var2_4202864_bv64:bv64 := 0x0:bv64;
      var var2_4202864_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202864_bv64:bv64,
       0x20:bv64) 64;
      $R1:bv64 := var2_4202864_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202868_bv64:bv64 := 0x0:bv64;
      var var1_4202868_bv64:bv64 := $R4:bv64;
      $R5:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4202868_bv64:bv64)), 0x8000000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4202868_bv64:bv64, 0x1:bv64),
          bvshl(var1_4202868_bv64:bv64, 0x3f:bv64))), 0x7fffffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202872_bv32:bv32 := 0x0:bv32;
      var var1_4202872_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202872_bv32:bv32 := 0x0:bv32;
      var var2_4202872_bv32:bv32 := extract(32,0, $R5:bv64);
      $R5:bv64 := zero_extend(32,
      bvadd(var1_4202872_bv32:bv32, bvshl(var2_4202872_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202876_bv32:bv32 := 0x0:bv32;
      var var2_4202876_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R6:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R6:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R6:bv64),
        0xffffffff:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202880_bv32:bv32 := 0x0:bv32;
      var var1_4202880_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202880_bv32:bv32 := 0x0:bv32;
      var var2_4202880_bv32:bv32 := extract(32,0, $R4:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(var1_4202880_bv32:bv32, bvshl(var2_4202880_bv32:bv32, 0x0:bv32)));
      var var1_4202884_bv32:bv32 := 0x0:bv32;
      var var1_4202884_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202884_bv32:bv32 := 0x0:bv32;
      var var2_4202884_bv32:bv32 := extract(32,0, $R5:bv64);
      goto (%__fmtpad_67);
   ];
   block %__fmtpad_67 [ goto (%__fmtpad_65,%__fmtpad_63); ];
   block %__fmtpad_63 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, var1_4202884_bv32:bv32);
      goto (%__fmtpad_61);
   ];
   block %__fmtpad_65 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, var2_4202884_bv32:bv32);
      goto (%__fmtpad_61);
   ];
   block %__fmtpad_61 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202888_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x30:bv64) extract(32,0, $R3:bv64) 32;
      goto (%__fmtpad_59,%__fmtpad_29);
   ];
   block %__fmtpad_29 [
      guard eq($R1:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021fc:bv64;
      assert eq($_PC:bv64, 0x4021fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203004_bv64:bv64 := 0x0:bv64;
      var var1_4203004_bv64:bv64 := 0x0:bv64;
      var var2_4203004_bv64:bv64 := 0x0:bv64;
      var var2_4203004_bv64:bv64 := $R2:bv64;
      $R0:bv64 := bvor(var1_4203004_bv64:bv64,
       bvshl(var2_4203004_bv64:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021ec:bv64;
      goto (%__fmtpad_27);
   ];
   block %__fmtpad_27 [ goto (%__fmtpad_25); ];
   block %__fmtpad_59 [
      guard boolnot(eq($R1:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402190:bv64);
      var var1_4202896_bv64:bv64 := 0x0:bv64;
      var var1_4202896_bv64:bv64 := $R1:bv64;
      $R30:bv64 := 0x402194:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4202896_bv64:bv64;
      indirect call var1_4202896_bv64:bv64;
      goto (%__fmtpad_57);
   ];
   block %__fmtpad_57 [ goto (%__fmtpad_55); ];
   block %__fmtpad_55 [
      assert eq($_PC:bv64, 0x402194:bv64);
      goto (%__fmtpad_53,%__fmtpad_33);
   ];
   block %__fmtpad_33 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021e8:bv64;
      assert eq($_PC:bv64, 0x4021e8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202984_bv64:bv64 := 0x0:bv64;
      var var1_4202984_bv64:bv64 := $R19:bv64;
      var var2_4202984_bv64:bv64 := 0x0:bv64;
      var var2_4202984_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202984_bv64:bv64,
       0x10:bv64) 64;
      $R0:bv64 := var2_4202984_bv64:bv64;
      goto (%__fmtpad_31);
   ];
   block %__fmtpad_31 [ goto (%__fmtpad_25); ];
   block %__fmtpad_53 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402198:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202904_bv64:bv64 := 0x0:bv64;
      var var1_4202904_bv64:bv64 := $R19:bv64;
      var var2_4202904_bv64:bv64 := 0x0:bv64;
      var var2_4202904_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202904_bv64:bv64,
       0x10:bv64) 64;
      var var3_4202904_bv64:bv64 := 0x0:bv64;
      var var3_4202904_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4202904_bv64:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R0:bv64 := var2_4202904_bv64:bv64;
      $R4:bv64 := var3_4202904_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202908_bv64:bv64 := 0x0:bv64;
      var var2_4202908_bv64:bv64 := 0x0:bv64;
      var var2_4202908_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvadd(var2_4202908_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202912_bv64:bv64 := 0x0:bv64;
      var var2_4202912_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtpad_51);
   ];
   block %__fmtpad_51 [ goto (%__fmtpad_49,%__fmtpad_35); ];
   block %__fmtpad_35 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021ec:bv64;
      goto (%__fmtpad_25);
   ];
   block %__fmtpad_49 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4021a8:bv64);
      goto (%__fmtpad_47);
   ];
   block %__fmtpad_47 [ goto (%__fmtpad_45,%__fmtpad_37); ];
   block %__fmtpad_37 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021f0:bv64;
      goto (%__fmtpad_23);
   ];
   block %__fmtpad_45 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4021ac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202924_bv32:bv32 := 0x0:bv32;
      var var2_4202924_bv32:bv32 := 0x0:bv32;
      var var2_4202924_bv32:bv32 := extract(32,0, $R20:bv64);
      $R20:bv64 := zero_extend(32, bvadd(var2_4202924_bv32:bv32, 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202928_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(8,0, $R22:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202932_bv32:bv32 := 0x0:bv32;
      var var2_4202932_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64),
           bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        bvnot(bvshl(extract(32,0, $R20:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtpad_43);
   ];
   block %__fmtpad_43 [ goto (%__fmtpad_41,%__fmtpad_39); ];
   block %__fmtpad_39 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402148:bv64;
      goto (%__fmtpad_71);
   ];
   block %__fmtpad_41 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtpad_13);
   ];
   block %__fmtpad_23 [
      assert eq($_PC:bv64, 0x4021f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202992_bv64:bv64 := 0x0:bv64;
      var var1_4202992_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4202992_bv64:bv64 := 0x0:bv64;
      var var2_4202992_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4202992_bv64:bv64;
      $R22:bv64 := var2_4202992_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4021dc:bv64;
      goto (%__fmtpad_5);
   ];
   block %__fmtpad_25 [
      assert eq($_PC:bv64, 0x4021ec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202988_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x18:bv64) $R0:bv64 64;
      goto (%__fmtpad_23);
   ];
   block %__fmtpad_13 [
      assert eq($_PC:bv64, 0x4021bc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202940_bv64:bv64 := 0x0:bv64;
      var var1_4202940_bv64:bv64 := $R19:bv64;
      var var2_4202940_bv64:bv64 := 0x0:bv64;
      var var2_4202940_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202940_bv64:bv64,
       0x10:bv64) 64;
      $R3:bv64 := var2_4202940_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202944_bv64:bv64 := 0x0:bv64;
      var var1_4202944_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4202944_bv64:bv64 := 0x0:bv64;
      var var2_4202944_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4202944_bv64:bv64;
      $R22:bv64 := var2_4202944_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202948_bv32:bv32 := 0x0:bv32;
      var var1_4202948_bv32:bv32 := extract(32,0, $R2:bv64);
      var var2_4202948_bv32:bv32 := 0x0:bv32;
      var var2_4202948_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4202948_bv32:bv32,
        bvnot(bvshl(var2_4202948_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      goto (%__fmtpad_7);
   ];
   block %__fmtpad_5 [
      assert eq($_PC:bv64, 0x4021dc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202972_bv64:bv64 := 0x0:bv64;
      var var1_4202972_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4202972_bv64:bv64 := 0x0:bv64;
      var var2_4202972_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4202972_bv64:bv64;
      $R20:bv64 := var2_4202972_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202976_bv64:bv64 := 0x0:bv64;
      var var1_4202976_bv64:bv64 := $R31:bv64;
      var var2_4202976_bv64:bv64 := 0x0:bv64;
      var var2_4202976_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202976_bv64:bv64 := 0x0:bv64;
      var var3_4202976_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202976_bv64:bv64;
      $R30:bv64 := var3_4202976_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202976_bv64:bv64, 0x30:bv64);
      var var1_4202980_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtpad_basil_return_1);
   ];
   block %__fmtpad_basil_return_1 [ nop; return; ];
   block %__fmtpad_7 [
      assert eq($_PC:bv64, 0x4021c8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202952_bv64:bv64 := 0x0:bv64;
      var var1_4202952_bv64:bv64 := $R19:bv64;
      var var2_4202952_bv32:bv32 := 0x0:bv32;
      var var2_4202952_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202952_bv64:bv64,
       0x30:bv64) 32;
      $R1:bv64 := zero_extend(32, var2_4202952_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202960_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202964_bv32:bv32 := 0x0:bv32;
      var var1_4202964_bv32:bv32 := extract(32,0, $R1:bv64);
      var var2_4202964_bv32:bv32 := 0x0:bv32;
      var var2_4202964_bv32:bv32 := extract(32,0, $R3:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(var1_4202964_bv32:bv32, bvshl(var2_4202964_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202968_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x30:bv64) extract(32,0, $R1:bv64) 32;
      goto (%__fmtpad_5);
   ]
];
proc @runetochar_4209936()  -> () { .address = 4209936; .name = "runetochar";
    .returnBlock = "runetochar_basil_return_1" }
  modifies $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R4:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R30:bv64, $R4:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403d10:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %runetochar_entry [
      assert eq($_PC:bv64, 0x403d10:bv64);
      $_PC:bv64 := 0x403d10:bv64;
      assert eq($_PC:bv64, 0x403d10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209936_bv64:bv64 := 0x0:bv64;
      var var1_4209936_bv64:bv64 := $R1:bv64;
      var var2_4209936_bv16:bv16 := 0x0:bv16;
      var var2_4209936_bv16:bv16 := load le $mem:(bv64->bv8) var1_4209936_bv64:bv64 16;
      $R3:bv64 := zero_extend(32, zero_extend(16, var2_4209936_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209940_bv64:bv64 := 0x0:bv64;
      var var1_4209940_bv64:bv64 := 0x0:bv64;
      var var2_4209940_bv64:bv64 := 0x0:bv64;
      var var2_4209940_bv64:bv64 := $R0:bv64;
      $R4:bv64 := bvor(var1_4209940_bv64:bv64,
       bvshl(var2_4209940_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209944_bv64:bv64 := 0x0:bv64;
      var var2_4209944_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R3:bv64),
           0xffffffffffffffffffffffffffffff80:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R3:bv64), 0xffffffffffffff80:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64),
       0x1:bv64));
      goto (%runetochar_19,%runetochar_7);
   ];
   block %runetochar_7 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403d70:bv64;
      assert eq($_PC:bv64, 0x403d70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210036_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R4:bv64 extract(8,0, $R3:bv64) 8;
      var var1_4210040_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%runetochar_5);
   ];
   block %runetochar_5 [ goto (%runetochar_basil_return_1); ];
   block %runetochar_19 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403d20:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209952_bv64:bv64 := 0x0:bv64;
      var var1_4209952_bv64:bv64 := $R3:bv64;
      $R1:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4209952_bv64:bv64)), 0xfc00000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4209952_bv64:bv64, 0x6:bv64),
          bvshl(var1_4209952_bv64:bv64, 0x3a:bv64))), 0x3ffffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209956_bv32:bv32 := 0x0:bv32;
      var var1_4209956_bv32:bv32 := extract(32,0, $R3:bv64);
      $R2:bv64 := zero_extend(32, bvand(var1_4209956_bv32:bv32, 0x3f:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209960_bv32:bv32 := 0x0:bv32;
      var var1_4209960_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32, bvor(var1_4209960_bv32:bv32, 0x80:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209964_bv32:bv32 := 0x0:bv32;
      var var1_4209964_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(bvand(sign_extend(31, extract(8,7, var1_4209964_bv32:bv32)),
        0xffffff00:bv32),
       bvand(bvor(0x0:bv32, bvand(var1_4209964_bv32:bv32, 0xff:bv32)), 0xff:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209968_bv64:bv64 := 0x0:bv64;
      var var2_4209968_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R3:bv64),
           0xfffffffffffffffffffffffffffff800:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R3:bv64), 0xfffffffffffff800:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64),
       0x1:bv64));
      goto (%runetochar_17);
   ];
   block %runetochar_17 [ goto (%runetochar_15,%runetochar_11); ];
   block %runetochar_11 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403d5c:bv64;
      assert eq($_PC:bv64, 0x403d5c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210012_bv32:bv32 := 0x0:bv32;
      var var1_4210012_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4210012_bv32:bv32, 0xffffffc0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x2:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210020_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R4:bv64 extract(8,0, $R1:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210024_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R4:bv64, 0x1:bv64) extract(8,0, $R2:bv64) 8;
      var var1_4210028_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%runetochar_9);
   ];
   block %runetochar_9 [ goto (%runetochar_basil_return_1); ];
   block %runetochar_15 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403d38:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209976_bv64:bv64 := 0x0:bv64;
      var var1_4209976_bv64:bv64 := $R3:bv64;
      $R3:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4209976_bv64:bv64)), 0xfff0000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4209976_bv64:bv64, 0xc:bv64),
          bvshl(var1_4209976_bv64:bv64, 0x34:bv64))), 0xfffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209980_bv32:bv32 := 0x0:bv32;
      var var1_4209980_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvand(var1_4209980_bv32:bv32, 0x3f:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209984_bv32:bv32 := 0x0:bv32;
      var var1_4209984_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32, bvor(var1_4209984_bv32:bv32, 0xffffffe0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209988_bv32:bv32 := 0x0:bv32;
      var var1_4209988_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4209988_bv32:bv32, 0xffffff80:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209996_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R4:bv64 extract(8,0, $R3:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210000_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R4:bv64, 0x1:bv64) extract(8,0, $R1:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4210004_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R4:bv64, 0x2:bv64) extract(8,0, $R2:bv64) 8;
      var var1_4210008_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%runetochar_13);
   ];
   block %runetochar_13 [ goto (%runetochar_basil_return_1); ];
   block %runetochar_basil_return_1 [ nop; return; ]
];
proc @__fmtflush_4202032()  -> () { .address = 4202032; .name = "__fmtflush";
    .returnBlock = "__fmtflush_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401e30:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtflush_entry [
      assert eq($_PC:bv64, 0x401e30:bv64);
      $_PC:bv64 := 0x401e30:bv64;
      assert eq($_PC:bv64, 0x401e30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202032_bv64:bv64 := 0x0:bv64;
      var var1_4202032_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffe0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4202032_bv64:bv64, 0xffffffffffffffe0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202036_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202044_bv32:bv32 := 0x0:bv32;
      var var1_4202044_bv32:bv32 := 0x0:bv32;
      var var2_4202044_bv32:bv32 := 0x0:bv32;
      var var2_4202044_bv32:bv32 := extract(32,0, $R2:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4202044_bv32:bv32, bvshl(var2_4202044_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202048_bv64:bv64 := 0x0:bv64;
      var var1_4202048_bv64:bv64 := $R0:bv64;
      var var2_4202048_bv32:bv32 := 0x0:bv32;
      var var2_4202048_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202048_bv64:bv64,
       0x30:bv64) 32;
      $R3:bv64 := zero_extend(32, var2_4202048_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202052_bv64:bv64 := 0x0:bv64;
      var var1_4202052_bv64:bv64 := $R0:bv64;
      var var2_4202052_bv64:bv64 := 0x0:bv64;
      var var2_4202052_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202052_bv64:bv64,
       0x10:bv64) 64;
      $R2:bv64 := var2_4202052_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202056_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x10:bv64) $R1:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202060_bv64:bv64 := 0x0:bv64;
      var var1_4202060_bv64:bv64 := $R0:bv64;
      var var2_4202060_bv8:bv8 := 0x0:bv8;
      var var2_4202060_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202060_bv64:bv64 8;
      $R6:bv64 := zero_extend(32, zero_extend(24, var2_4202060_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202064_bv64:bv64 := 0x0:bv64;
      var var1_4202064_bv64:bv64 := 0x0:bv64;
      var var2_4202064_bv64:bv64 := 0x0:bv64;
      var var2_4202064_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4202064_bv64:bv64,
       bvshl(var2_4202064_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202068_bv64:bv64 := 0x0:bv64;
      var var1_4202068_bv64:bv64 := $R1:bv64;
      var var2_4202068_bv64:bv64 := 0x0:bv64;
      var var2_4202068_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(bvadd(var1_4202068_bv64:bv64,
        bvnot(bvshl(var2_4202068_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202072_bv64:bv64 := 0x0:bv64;
      var var1_4202072_bv64:bv64 := $R0:bv64;
      var var2_4202072_bv64:bv64 := 0x0:bv64;
      var var2_4202072_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202072_bv64:bv64,
       0x20:bv64) 64;
      $R5:bv64 := var2_4202072_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202076_bv64:bv64 := 0x0:bv64;
      var var1_4202076_bv64:bv64 := $R2:bv64;
      $R4:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4202076_bv64:bv64)), 0x8000000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4202076_bv64:bv64, 0x1:bv64),
          bvshl(var1_4202076_bv64:bv64, 0x3f:bv64))), 0x7fffffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202080_bv32:bv32 := 0x0:bv32;
      var var1_4202080_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202080_bv32:bv32 := 0x0:bv32;
      var var2_4202080_bv32:bv32 := extract(32,0, $R4:bv64);
      $R4:bv64 := zero_extend(32,
      bvadd(var1_4202080_bv32:bv32, bvshl(var2_4202080_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202084_bv32:bv32 := 0x0:bv32;
      var var2_4202084_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R6:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R6:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R6:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R6:bv64),
        0xffffffff:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202088_bv32:bv32 := 0x0:bv32;
      var var1_4202088_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202088_bv32:bv32 := 0x0:bv32;
      var var2_4202088_bv32:bv32 := extract(32,0, $R2:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(var1_4202088_bv32:bv32, bvshl(var2_4202088_bv32:bv32, 0x0:bv32)));
      var var1_4202092_bv32:bv32 := 0x0:bv32;
      var var1_4202092_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4202092_bv32:bv32 := 0x0:bv32;
      var var2_4202092_bv32:bv32 := extract(32,0, $R4:bv64);
      goto (%__fmtflush_35,%__fmtflush_33);
   ];
   block %__fmtflush_33 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, var1_4202092_bv32:bv32);
      goto (%__fmtflush_31);
   ];
   block %__fmtflush_35 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, var2_4202092_bv32:bv32);
      goto (%__fmtflush_31);
   ];
   block %__fmtflush_31 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202096_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x30:bv64) extract(32,0, $R3:bv64) 32;
      goto (%__fmtflush_29,%__fmtflush_9);
   ];
   block %__fmtflush_9 [
      guard eq($R5:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401eb4:bv64;
      assert eq($_PC:bv64, 0x401eb4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202164_bv64:bv64 := 0x0:bv64;
      var var1_4202164_bv64:bv64 := 0x0:bv64;
      var var2_4202164_bv64:bv64 := 0x0:bv64;
      var var2_4202164_bv64:bv64 := $R1:bv64;
      $R0:bv64 := bvor(var1_4202164_bv64:bv64,
       bvshl(var2_4202164_bv64:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ea0:bv64;
      goto (%__fmtflush_7);
   ];
   block %__fmtflush_7 [ goto (%__fmtflush_5); ];
   block %__fmtflush_29 [
      guard boolnot(eq($R5:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401e78:bv64);
      var var1_4202104_bv64:bv64 := 0x0:bv64;
      var var1_4202104_bv64:bv64 := $R5:bv64;
      $R30:bv64 := 0x401e7c:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4202104_bv64:bv64;
      indirect call var1_4202104_bv64:bv64;
      goto (%__fmtflush_27);
   ];
   block %__fmtflush_27 [ goto (%__fmtflush_25); ];
   block %__fmtflush_25 [
      assert eq($_PC:bv64, 0x401e7c:bv64);
      goto (%__fmtflush_23,%__fmtflush_13);
   ];
   block %__fmtflush_13 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e9c:bv64;
      assert eq($_PC:bv64, 0x401e9c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202140_bv64:bv64 := 0x0:bv64;
      var var1_4202140_bv64:bv64 := $R19:bv64;
      var var2_4202140_bv64:bv64 := 0x0:bv64;
      var var2_4202140_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202140_bv64:bv64,
       0x10:bv64) 64;
      $R0:bv64 := var2_4202140_bv64:bv64;
      goto (%__fmtflush_11);
   ];
   block %__fmtflush_11 [ goto (%__fmtflush_5); ];
   block %__fmtflush_23 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401e80:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202112_bv64:bv64 := 0x0:bv64;
      var var1_4202112_bv64:bv64 := $R19:bv64;
      var var2_4202112_bv64:bv64 := 0x0:bv64;
      var var2_4202112_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202112_bv64:bv64,
       0x10:bv64) 64;
      var var3_4202112_bv64:bv64 := 0x0:bv64;
      var var3_4202112_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4202112_bv64:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R0:bv64 := var2_4202112_bv64:bv64;
      $R1:bv64 := var3_4202112_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202116_bv64:bv64 := 0x0:bv64;
      var var2_4202116_bv64:bv64 := 0x0:bv64;
      var var2_4202116_bv64:bv64 := $R0:bv64;
      var var3_4202116_bv64:bv64 := 0x0:bv64;
      var var3_4202116_bv64:bv64 := $R20:bv64;
      $R20:bv64 := bvadd(var2_4202116_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4202116_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202120_bv64:bv64 := 0x0:bv64;
      var var2_4202120_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R20:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R20:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtflush_21);
   ];
   block %__fmtflush_21 [ goto (%__fmtflush_19,%__fmtflush_15); ];
   block %__fmtflush_15 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ea0:bv64;
      goto (%__fmtflush_5);
   ];
   block %__fmtflush_19 [
      guard eq($CF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401e90:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202128_bv64:bv64 := 0x0:bv64;
      var var1_4202128_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4202128_bv64:bv64 := 0x0:bv64;
      var var2_4202128_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4202128_bv64:bv64;
      $R20:bv64 := var2_4202128_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202132_bv64:bv64 := 0x0:bv64;
      var var1_4202132_bv64:bv64 := $R31:bv64;
      var var2_4202132_bv64:bv64 := 0x0:bv64;
      var var2_4202132_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202132_bv64:bv64 := 0x0:bv64;
      var var3_4202132_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202132_bv64:bv64;
      $R30:bv64 := var3_4202132_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202132_bv64:bv64, 0x20:bv64);
      var var1_4202136_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtflush_17);
   ];
   block %__fmtflush_17 [ goto (%__fmtflush_basil_return_1); ];
   block %__fmtflush_5 [
      assert eq($_PC:bv64, 0x401ea0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202144_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x18:bv64) $R0:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202148_bv64:bv64 := 0x0:bv64;
      var var1_4202148_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4202148_bv64:bv64 := 0x0:bv64;
      var var2_4202148_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4202148_bv64:bv64;
      $R20:bv64 := var2_4202148_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202156_bv64:bv64 := 0x0:bv64;
      var var1_4202156_bv64:bv64 := $R31:bv64;
      var var2_4202156_bv64:bv64 := 0x0:bv64;
      var var2_4202156_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202156_bv64:bv64 := 0x0:bv64;
      var var3_4202156_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202156_bv64:bv64;
      $R30:bv64 := var3_4202156_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202156_bv64:bv64, 0x20:bv64);
      var var1_4202160_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtflush_basil_return_1);
   ];
   block %__fmtflush_basil_return_1 [ nop; return; ]
];
proc @chartorune_4209760()  -> () { .address = 4209760; .name = "chartorune";
    .returnBlock = "chartorune_basil_return_1" }
  modifies $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R30:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403c60:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %chartorune_entry [
      assert eq($_PC:bv64, 0x403c60:bv64);
      $_PC:bv64 := 0x403c60:bv64;
      assert eq($_PC:bv64, 0x403c60:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209760_bv64:bv64 := 0x0:bv64;
      var var1_4209760_bv64:bv64 := $R1:bv64;
      var var2_4209760_bv8:bv8 := 0x0:bv8;
      var var2_4209760_bv8:bv8 := load le $mem:(bv64->bv8) var1_4209760_bv64:bv64 8;
      $R2:bv64 := zero_extend(32, zero_extend(24, var2_4209760_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209764_bv64:bv64 := 0x0:bv64;
      var var1_4209764_bv64:bv64 := 0x0:bv64;
      var var2_4209764_bv64:bv64 := 0x0:bv64;
      var var2_4209764_bv64:bv64 := $R0:bv64;
      $R3:bv64 := bvor(var1_4209764_bv64:bv64,
       bvshl(var2_4209764_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209768_bv32:bv32 := 0x0:bv32;
      var var2_4209768_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff80:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%chartorune_57,%chartorune_7);
   ];
   block %chartorune_7 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cc0:bv64;
      assert eq($_PC:bv64, 0x403cc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209856_bv32:bv32 := 0x0:bv32;
      var var1_4209856_bv32:bv32 := 0x0:bv32;
      var var2_4209856_bv32:bv32 := 0x0:bv32;
      var var2_4209856_bv32:bv32 := extract(32,0, $R2:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(var1_4209856_bv32:bv32, bvshl(var2_4209856_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209864_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R3:bv64 extract(16,0, $R1:bv64) 16;
      var var1_4209868_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%chartorune_5);
   ];
   block %chartorune_5 [ goto (%chartorune_basil_return_1); ];
   block %chartorune_57 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403c70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209776_bv64:bv64 := 0x0:bv64;
      var var1_4209776_bv64:bv64 := $R1:bv64;
      var var2_4209776_bv8:bv8 := 0x0:bv8;
      var var2_4209776_bv8:bv8 := load le $mem:(bv64->bv8) bvadd(var1_4209776_bv64:bv64,
       0x1:bv64) 8;
      $R4:bv64 := zero_extend(32, zero_extend(24, var2_4209776_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209780_bv32:bv32 := 0x0:bv32;
      var var1_4209780_bv32:bv32 := extract(32,0, $R4:bv64);
      $R4:bv64 := zero_extend(32, bvxor(var1_4209780_bv32:bv32, 0x80:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209784_bv32:bv32 := 0x0:bv32;
      var var2_4209784_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R4:bv64)),
           0xffffffffffffffc0:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R4:bv64)), 0xffffffc0:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffffc0:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R4:bv64),
        0xffffffc0:bv32), 0x1:bv32));
      goto (%chartorune_55);
   ];
   block %chartorune_55 [ goto (%chartorune_53,%chartorune_13); ];
   block %chartorune_13 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb0:bv64;
      goto (%chartorune_11);
   ];
   block %chartorune_53 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403c80:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209792_bv32:bv32 := 0x0:bv32;
      var var2_4209792_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           0xffffffffffffff20:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)), 0xffffff20:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff20:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        0xffffff20:bv32), 0x1:bv32));
      goto (%chartorune_51);
   ];
   block %chartorune_51 [ goto (%chartorune_49,%chartorune_33); ];
   block %chartorune_33 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cd0:bv64;
      assert eq($_PC:bv64, 0x403cd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209872_bv64:bv64 := 0x0:bv64;
      var var1_4209872_bv64:bv64 := $R1:bv64;
      var var2_4209872_bv8:bv8 := 0x0:bv8;
      var var2_4209872_bv8:bv8 := load le $mem:(bv64->bv8) bvadd(var1_4209872_bv64:bv64,
       0x2:bv64) 8;
      $R5:bv64 := zero_extend(32, zero_extend(24, var2_4209872_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R6:bv64 := 0xef:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0xfffd:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209888_bv32:bv32 := 0x0:bv32;
      var var1_4209888_bv32:bv32 := extract(32,0, $R5:bv64);
      $R5:bv64 := zero_extend(32, bvxor(var1_4209888_bv32:bv32, 0x80:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209892_bv32:bv32 := 0x0:bv32;
      var var2_4209892_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R5:bv64)),
           0xffffffffffffffc0:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R5:bv64)), 0xffffffc0:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R5:bv64), 0xffffffc0:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R5:bv64),
        0xffffffc0:bv32), 0x1:bv32));
      var var1_4209896_bool:bool := booland(eq($CF:bv1, 0x1:bv1),
       eq($ZF:bv1, 0x0:bv1));
      goto (%chartorune_31);
   ];
   block %chartorune_31 [ goto (%chartorune_29,%chartorune_27); ];
   block %chartorune_27 [
      guard boolnot(var1_4209896_bool:bool);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), bvnot(extract(32,0, $R6:bv64))),
          0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           sign_extend(32, bvnot(extract(32,0, $R6:bv64)))), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), bvnot(extract(32,0, $R6:bv64))),
          0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)),
           zero_extend(32, bvnot(extract(32,0, $R6:bv64)))), 0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64),
          bvnot(extract(32,0, $R6:bv64))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        bvnot(extract(32,0, $R6:bv64))), 0x1:bv32));
      goto (%chartorune_25,%chartorune_15);
   ];
   block %chartorune_29 [
      guard var1_4209896_bool:bool;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := 0x0:bv1;
      $NF:bv1 := 0x0:bv1;
      goto (%chartorune_25,%chartorune_15);
   ];
   block %chartorune_15 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb8:bv64;
      goto (%chartorune_9);
   ];
   block %chartorune_25 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403cf0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209904_bv32:bv32 := 0x0:bv32;
      var var1_4209904_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4209904_bv32:bv32 := 0x0:bv32;
      var var2_4209904_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4209904_bv32:bv32, bvshl(var2_4209904_bv32:bv32, 0x6:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209908_bv32:bv32 := 0x0:bv32;
      var var1_4209908_bv32:bv32 := extract(32,0, $R5:bv64);
      var var2_4209908_bv32:bv32 := 0x0:bv32;
      var var2_4209908_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4209908_bv32:bv32, bvshl(var2_4209908_bv32:bv32, 0x6:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209912_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand(extract(32,0, $R2:bv64), 0xf800:bv32),
        0x0:bv32));
      $NF:bv1 := extract(32,31, bvand(extract(32,0, $R2:bv64), 0xf800:bv32));
      goto (%chartorune_23);
   ];
   block %chartorune_23 [ goto (%chartorune_21,%chartorune_17); ];
   block %chartorune_17 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb8:bv64;
      goto (%chartorune_9);
   ];
   block %chartorune_21 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403d00:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209920_bv32:bv32 := 0x0:bv32;
      var var1_4209920_bv32:bv32 := extract(32,0, $R2:bv64);
      $R1:bv64 := zero_extend(32, bvand(var1_4209920_bv32:bv32, 0xffff:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x3:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb8:bv64;
      goto (%chartorune_19);
   ];
   block %chartorune_19 [ goto (%chartorune_9); ];
   block %chartorune_49 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403c88:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209800_bv32:bv32 := 0x0:bv32;
      var var2_4209800_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R2:bv64)),
           0xffffffffffffff40:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R2:bv64)), 0xffffff40:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R2:bv64), 0xffffff40:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R2:bv64),
        0xffffff40:bv32), 0x1:bv32));
      goto (%chartorune_47);
   ];
   block %chartorune_47 [ goto (%chartorune_45,%chartorune_35); ];
   block %chartorune_35 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb0:bv64;
      goto (%chartorune_11);
   ];
   block %chartorune_45 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403c90:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209808_bv32:bv32 := 0x0:bv32;
      var var1_4209808_bv32:bv32 := extract(32,0, $R4:bv64);
      var var2_4209808_bv32:bv32 := 0x0:bv32;
      var var2_4209808_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4209808_bv32:bv32, bvshl(var2_4209808_bv32:bv32, 0x6:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0xfffd:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209820_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := 0x0:bv1;
      $CF:bv1 := 0x0:bv1;
      $ZF:bv1 := booltobv1(eq(bvand(extract(32,0, $R2:bv64), 0x780:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvand(extract(32,0, $R2:bv64), 0x780:bv32));
      goto (%chartorune_43);
   ];
   block %chartorune_43 [ goto (%chartorune_41,%chartorune_37); ];
   block %chartorune_37 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb8:bv64;
      goto (%chartorune_9);
   ];
   block %chartorune_41 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403ca4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209828_bv32:bv32 := 0x0:bv32;
      var var1_4209828_bv32:bv32 := extract(32,0, $R2:bv64);
      $R1:bv64 := zero_extend(32, bvand(var1_4209828_bv32:bv32, 0x7ff:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x2:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403cb8:bv64;
      goto (%chartorune_39);
   ];
   block %chartorune_39 [ goto (%chartorune_9); ];
   block %chartorune_9 [
      assert eq($_PC:bv64, 0x403cb8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209848_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R3:bv64 extract(16,0, $R1:bv64) 16;
      var var1_4209852_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%chartorune_basil_return_1);
   ];
   block %chartorune_11 [
      assert eq($_PC:bv64, 0x403cb0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0xfffd:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      goto (%chartorune_9);
   ];
   block %chartorune_basil_return_1 [ nop; return; ]
];
proc @__fmtcpy_4203296()  -> () { .address = 4203296; .name = "__fmtcpy";
    .returnBlock = "__fmtcpy_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x402320:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtcpy_entry [
      assert eq($_PC:bv64, 0x402320:bv64);
      $_PC:bv64 := 0x402320:bv64;
      assert eq($_PC:bv64, 0x402320:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203296_bv64:bv64 := 0x0:bv64;
      var var1_4203296_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffff90:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffff90:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4203296_bv64:bv64, 0xffffffffffffff90:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203300_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x40:bv64) $R25:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x40:bv64), 0x8:bv64) $R26:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R26:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203312_bv64:bv64 := 0x0:bv64;
      var var1_4203312_bv64:bv64 := $R0:bv64;
      var var2_4203312_bv64:bv64 := 0x0:bv64;
      var var2_4203312_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203312_bv64:bv64,
       0x68:bv64) 64;
      $R25:bv64 := var2_4203312_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203320_bv64:bv64 := 0x0:bv64;
      var var1_4203320_bv64:bv64 := 0x0:bv64;
      var var2_4203320_bv64:bv64 := 0x0:bv64;
      var var2_4203320_bv64:bv64 := $R1:bv64;
      $R19:bv64 := bvor(var1_4203320_bv64:bv64,
       bvshl(var2_4203320_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203328_bv64:bv64 := 0x0:bv64;
      var var1_4203328_bv64:bv64 := 0x0:bv64;
      var var2_4203328_bv64:bv64 := 0x0:bv64;
      var var2_4203328_bv64:bv64 := $R0:bv64;
      $R21:bv64 := bvor(var1_4203328_bv64:bv64,
       bvshl(var2_4203328_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203332_bv64:bv64 := 0x0:bv64;
      var var2_4203332_bv64:bv64 := 0x0:bv64;
      var var2_4203332_bv64:bv64 := $R1:bv64;
      var var3_4203332_bv64:bv64 := 0x0:bv64;
      var var3_4203332_bv64:bv64 := $R3:bv64;
      $R22:bv64 := bvadd(var2_4203332_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4203332_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) $R24:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203340_bv32:bv32 := 0x0:bv32;
      var var1_4203340_bv32:bv32 := 0x0:bv32;
      var var2_4203340_bv32:bv32 := 0x0:bv32;
      var var2_4203340_bv32:bv32 := extract(32,0, $R2:bv64);
      $R24:bv64 := zero_extend(32,
      bvor(var1_4203340_bv32:bv32, bvshl(var2_4203340_bv32:bv32, 0x0:bv32)));
      goto (%__fmtcpy_233,%__fmtcpy_229);
   ];
   block %__fmtcpy_229 [
      guard eq(extract(1,0, extract(32,0, $R25:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402358:bv64;
      goto (%__fmtcpy_227);
   ];
   block %__fmtcpy_233 [
      guard boolnot(eq(extract(1,0, extract(32,0, $R25:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402354:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203348_bv64:bv64 := 0x0:bv64;
      var var1_4203348_bv64:bv64 := $R0:bv64;
      var var2_4203348_bv32:bv32 := 0x0:bv32;
      var var2_4203348_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203348_bv64:bv64,
       0x5c:bv64) 32;
      $R26:bv64 := zero_extend(32, var2_4203348_bv32:bv32);
      goto (%__fmtcpy_231);
   ];
   block %__fmtcpy_231 [ goto (%__fmtcpy_227); ];
   block %__fmtcpy_227 [
      assert eq($_PC:bv64, 0x402358:bv64);
      goto (%__fmtcpy_225,%__fmtcpy_217);
   ];
   block %__fmtcpy_217 [
      guard eq(extract(3,2, extract(32,0, $R25:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402368:bv64;
      goto (%__fmtcpy_215);
   ];
   block %__fmtcpy_225 [
      guard boolnot(eq(extract(3,2, extract(32,0, $R25:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40235c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203356_bv64:bv64 := 0x0:bv64;
      var var1_4203356_bv64:bv64 := $R21:bv64;
      var var2_4203356_bv32:bv32 := 0x0:bv32;
      var var2_4203356_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203356_bv64:bv64,
       0x60:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4203356_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203360_bv32:bv32 := 0x0:bv32;
      var var2_4203360_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R24:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R24:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R24:bv64),
          bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R24:bv64),
        bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32));
      var var1_4203364_bv32:bv32 := 0x0:bv32;
      var var1_4203364_bv32:bv32 := extract(32,0, $R24:bv64);
      var var2_4203364_bv32:bv32 := 0x0:bv32;
      var var2_4203364_bv32:bv32 := extract(32,0, $R0:bv64);
      goto (%__fmtcpy_223);
   ];
   block %__fmtcpy_223 [ goto (%__fmtcpy_221,%__fmtcpy_219); ];
   block %__fmtcpy_219 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R24:bv64 := zero_extend(32, var1_4203364_bv32:bv32);
      goto (%__fmtcpy_215);
   ];
   block %__fmtcpy_221 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R24:bv64 := zero_extend(32, var2_4203364_bv32:bv32);
      goto (%__fmtcpy_215);
   ];
   block %__fmtcpy_215 [
      assert eq($_PC:bv64, 0x402368:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203368_bv64:bv64 := 0x0:bv64;
      var var1_4203368_bv64:bv64 := $R21:bv64;
      var var2_4203368_bv8:bv8 := 0x0:bv8;
      var var2_4203368_bv8:bv8 := load le $mem:(bv64->bv8) var1_4203368_bv64:bv64 8;
      $R0:bv64 := zero_extend(32, zero_extend(24, var2_4203368_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203372_bv64:bv64 := 0x0:bv64;
      var var1_4203372_bv64:bv64 := $R25:bv64;
      $R25:bv64 := bvand(var1_4203372_bv64:bv64, 0x2:bv64);
      goto (%__fmtcpy_213,%__fmtcpy_121);
   ];
   block %__fmtcpy_121 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40247c:bv64;
      assert eq($_PC:bv64, 0x40247c:bv64);
      goto (%__fmtcpy_119);
   ];
   block %__fmtcpy_119 [ goto (%__fmtcpy_117,%__fmtcpy_115); ];
   block %__fmtcpy_115 [
      guard eq($R25:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4025a4:bv64;
      assert eq($_PC:bv64, 0x4025a4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203940_bv32:bv32 := 0x0:bv32;
      var var1_4203940_bv32:bv32 := extract(32,0, $R26:bv64);
      var var2_4203940_bv32:bv32 := 0x0:bv32;
      var var2_4203940_bv32:bv32 := extract(32,0, $R24:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4203940_bv32:bv32,
        bvnot(bvshl(var2_4203940_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203944_bv64:bv64 := 0x0:bv64;
      var var1_4203944_bv64:bv64 := 0x0:bv64;
      var var2_4203944_bv64:bv64 := 0x0:bv64;
      var var2_4203944_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203944_bv64:bv64,
       bvshl(var2_4203944_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x4025b0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402104:bv64;
      
      call @__fmtpad_4202756();
      goto (%__fmtcpy_113);
   ];
   block %__fmtcpy_113 [ goto (%__fmtcpy_111); ];
   block %__fmtcpy_111 [
      assert eq($_PC:bv64, 0x4025b0:bv64);
      goto (%__fmtcpy_109,%__fmtcpy_105);
   ];
   block %__fmtcpy_105 [
      guard eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402480:bv64;
      goto (%__fmtcpy_103);
   ];
   block %__fmtcpy_109 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4025b4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024f4:bv64;
      goto (%__fmtcpy_107);
   ];
   block %__fmtcpy_107 [ goto (%__fmtcpy_11); ];
   block %__fmtcpy_117 [
      guard boolnot(eq($R25:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_103);
   ];
   block %__fmtcpy_103 [
      assert eq($_PC:bv64, 0x402480:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203648_bv64:bv64 := 0x0:bv64;
      var var1_4203648_bv64:bv64 := $R21:bv64;
      var var2_4203648_bv64:bv64 := 0x0:bv64;
      var var2_4203648_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203648_bv64:bv64,
       0x18:bv64) 64;
      $R23:bv64 := var2_4203648_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x50:bv64) $R27:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203656_bv64:bv64 := 0x0:bv64;
      var var1_4203656_bv64:bv64 := $R21:bv64;
      var var2_4203656_bv64:bv64 := 0x0:bv64;
      var var2_4203656_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203656_bv64:bv64,
       0x10:bv64) 64;
      $R27:bv64 := var2_4203656_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203660_bv32:bv32 := 0x0:bv32;
      var var1_4203660_bv32:bv32 := 0x0:bv32;
      var var2_4203660_bv32:bv32 := 0x0:bv32;
      var var2_4203660_bv32:bv32 := extract(32,0, $R24:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4203660_bv32:bv32, bvshl(var2_4203660_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203668_bv32:bv32 := 0x0:bv32;
      var var2_4203668_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R24:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R24:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R24:bv64),
          0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R24:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__fmtcpy_101,%__fmtcpy_19);
   ];
   block %__fmtcpy_19 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024d8:bv64;
      goto (%__fmtcpy_17);
   ];
   block %__fmtcpy_101 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40249c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_99);
   ];
   block %__fmtcpy_99 [ goto (%__fmtcpy_97); ];
   block %__fmtcpy_97 [
      assert eq($_PC:bv64, 0x4024a0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203680_bv64:bv64 := 0x0:bv64;
      var var1_4203680_bv64:bv64 := $R19:bv64;
      var var2_4203680_bv8:bv8 := 0x0:bv8;
      var var2_4203680_bv8:bv8 := load le $mem:(bv64->bv8) var1_4203680_bv64:bv64 8;
      $R4:bv64 := zero_extend(32, zero_extend(24, var2_4203680_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x6c:bv64) extract(16,0, $R4:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203688_bv32:bv32 := 0x0:bv32;
      var var1_4203688_bv32:bv32 := 0x0:bv32;
      var var2_4203688_bv32:bv32 := 0x0:bv32;
      var var2_4203688_bv32:bv32 := extract(32,0, $R4:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4203688_bv32:bv32, bvshl(var2_4203688_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203692_bv32:bv32 := 0x0:bv32;
      var var2_4203692_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R4:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R4:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R4:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%__fmtcpy_95,%__fmtcpy_87);
   ];
   block %__fmtcpy_87 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40250c:bv64;
      assert eq($_PC:bv64, 0x40250c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203788_bv64:bv64 := 0x0:bv64;
      var var1_4203788_bv64:bv64 := $R22:bv64;
      var var2_4203788_bv64:bv64 := 0x0:bv64;
      var var2_4203788_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(bvadd(var1_4203788_bv64:bv64,
        bvnot(bvshl(var2_4203788_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203792_bv64:bv64 := 0x0:bv64;
      var var2_4203792_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           0xfffffffffffffffffffffffffffffffd:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64), 0xfffffffffffffffd:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64),
       0x1:bv64));
      goto (%__fmtcpy_85);
   ];
   block %__fmtcpy_85 [ goto (%__fmtcpy_83,%__fmtcpy_73); ];
   block %__fmtcpy_73 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402524:bv64;
      goto (%__fmtcpy_71);
   ];
   block %__fmtcpy_83 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402518:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203800_bv64:bv64 := 0x0:bv64;
      var var1_4203800_bv64:bv64 := 0x0:bv64;
      var var2_4203800_bv64:bv64 := 0x0:bv64;
      var var2_4203800_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4203800_bv64:bv64,
       bvshl(var2_4203800_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x402520:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403df0:bv64;
      
      call @fullrune_4210160();
      goto (%__fmtcpy_81);
   ];
   block %__fmtcpy_81 [ goto (%__fmtcpy_79); ];
   block %__fmtcpy_79 [
      assert eq($_PC:bv64, 0x402520:bv64);
      goto (%__fmtcpy_77,%__fmtcpy_75);
   ];
   block %__fmtcpy_75 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024d0:bv64;
      goto (%__fmtcpy_23);
   ];
   block %__fmtcpy_77 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_71);
   ];
   block %__fmtcpy_71 [
      assert eq($_PC:bv64, 0x402524:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203812_bv64:bv64 := 0x0:bv64;
      var var1_4203812_bv64:bv64 := 0x0:bv64;
      var var2_4203812_bv64:bv64 := 0x0:bv64;
      var var2_4203812_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4203812_bv64:bv64,
       bvshl(var2_4203812_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203816_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x6c:bv64);
      $R30:bv64 := 0x402530:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c60:bv64;
      
      call @chartorune_4209760();
      goto (%__fmtcpy_69);
   ];
   block %__fmtcpy_69 [
      assert eq($_PC:bv64, 0x402530:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203824_bv64:bv64 := 0x0:bv64;
      var var2_4203824_bv64:bv64 := 0x0:bv64;
      var var2_4203824_bv64:bv64 := $R19:bv64;
      var var3_4203824_bv64:bv64 := 0x0:bv64;
      var var3_4203824_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvadd(var2_4203824_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4203824_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203828_bv64:bv64 := 0x0:bv64;
      var var2_4203828_bv64:bv64 := 0x0:bv64;
      var var2_4203828_bv64:bv64 := $R27:bv64;
      $R1:bv64 := bvadd(var2_4203828_bv64:bv64, 0x3:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203832_bv64:bv64 := 0x0:bv64;
      var var2_4203832_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R23:bv64),
           sign_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R23:bv64),
           zero_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64,
          bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R23:bv64,
        bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtcpy_67,%__fmtcpy_43);
   ];
   block %__fmtcpy_43 [
      guard eq($CF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40255c:bv64;
      goto (%__fmtcpy_41);
   ];
   block %__fmtcpy_67 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402540:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203840_bv16:bv16 := 0x0:bv16;
      var var1_4203840_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x6c:bv64) 16;
      $R0:bv64 := zero_extend(32, zero_extend(16, var1_4203840_bv16:bv16));
      goto (%__fmtcpy_65);
   ];
   block %__fmtcpy_65 [ goto (%__fmtcpy_63); ];
   block %__fmtcpy_95 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4024b4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203700_bv64:bv64 := 0x0:bv64;
      var var2_4203700_bv64:bv64 := 0x0:bv64;
      var var2_4203700_bv64:bv64 := $R27:bv64;
      $R1:bv64 := bvadd(var2_4203700_bv64:bv64, 0x3:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203704_bv64:bv64 := 0x0:bv64;
      var var2_4203704_bv64:bv64 := 0x0:bv64;
      var var2_4203704_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4203704_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203708_bv64:bv64 := 0x0:bv64;
      var var2_4203708_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R23:bv64),
           sign_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R23:bv64),
           zero_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64,
          bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R23:bv64,
        bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtcpy_93);
   ];
   block %__fmtcpy_93 [ goto (%__fmtcpy_91,%__fmtcpy_89); ];
   block %__fmtcpy_89 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402544:bv64;
      goto (%__fmtcpy_63);
   ];
   block %__fmtcpy_91 [
      guard eq($CF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_35);
   ];
   block %__fmtcpy_23 [
      assert eq($_PC:bv64, 0x4024d0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203728_bv64:bv64 := 0x0:bv64;
      var var1_4203728_bv64:bv64 := $R21:bv64;
      var var2_4203728_bv64:bv64 := 0x0:bv64;
      var var2_4203728_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203728_bv64:bv64,
       0x10:bv64) 64;
      $R1:bv64 := var2_4203728_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203732_bv32:bv32 := 0x0:bv32;
      var var1_4203732_bv32:bv32 := extract(32,0, $R27:bv64);
      var var2_4203732_bv32:bv32 := 0x0:bv32;
      var var2_4203732_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4203732_bv32:bv32,
        bvnot(bvshl(var2_4203732_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      goto (%__fmtcpy_17);
   ];
   block %__fmtcpy_27 [
      assert eq($_PC:bv64, 0x4024c8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203720_bv32:bv32 := 0x0:bv32;
      var var2_4203720_bv32:bv32 := 0x0:bv32;
      var var2_4203720_bv32:bv32 := extract(32,0, $R20:bv64);
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, var2_4203720_bv32:bv32),
           0xfffffffffffffffe:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, var2_4203720_bv32:bv32), 0xfffffffe:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(var2_4203720_bv32:bv32,
        0xfffffffe:bv32), 0x1:bv32));
      $R20:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32));
      goto (%__fmtcpy_25,%__fmtcpy_21);
   ];
   block %__fmtcpy_21 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024a0:bv64;
      goto (%__fmtcpy_97);
   ];
   block %__fmtcpy_25 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_23);
   ];
   block %__fmtcpy_35 [
      assert eq($_PC:bv64, 0x4024c4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203716_bv64:bv64 := 0x0:bv64;
      var var1_4203716_bv64:bv64 := $R27:bv64;
      var var2_4203716_bv8:bv8 := 0x0:bv8;
      var var2_4203716_bv8:bv8 := extract(8,0, $R4:bv64);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) var1_4203716_bv64:bv64 var2_4203716_bv8:bv8 8;
      $R27:bv64 := bvadd(var1_4203716_bv64:bv64, 0x1:bv64);
      goto (%__fmtcpy_27);
   ];
   block %__fmtcpy_41 [
      assert eq($_PC:bv64, 0x40255c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203868_bv16:bv16 := 0x0:bv16;
      var var1_4203868_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x6c:bv64) 16;
      $R4:bv64 := zero_extend(32, zero_extend(16, var1_4203868_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203872_bv32:bv32 := 0x0:bv32;
      var var2_4203872_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R4:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R4:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R4:bv64), 0xffffff80:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R4:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%__fmtcpy_39,%__fmtcpy_33);
   ];
   block %__fmtcpy_33 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402570:bv64;
      assert eq($_PC:bv64, 0x402570:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203888_bv64:bv64 := 0x0:bv64;
      var var1_4203888_bv64:bv64 := 0x0:bv64;
      var var2_4203888_bv64:bv64 := 0x0:bv64;
      var var2_4203888_bv64:bv64 := $R27:bv64;
      $R0:bv64 := bvor(var1_4203888_bv64:bv64,
       bvshl(var2_4203888_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203892_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x6e:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x6e:bv64) extract(16,0, $R4:bv64) 16;
      $R30:bv64 := 0x402580:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403d10:bv64;
      
      call @runetochar_4209936();
      goto (%__fmtcpy_31);
   ];
   block %__fmtcpy_31 [ goto (%__fmtcpy_29); ];
   block %__fmtcpy_29 [
      assert eq($_PC:bv64, 0x402580:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203904_bv64:bv64 := 0x0:bv64;
      var var2_4203904_bv64:bv64 := 0x0:bv64;
      var var2_4203904_bv64:bv64 := $R27:bv64;
      var var3_4203904_bv64:bv64 := 0x0:bv64;
      var var3_4203904_bv64:bv64 := $R0:bv64;
      $R27:bv64 := bvadd(var2_4203904_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4203904_bv64:bv64)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024c8:bv64;
      goto (%__fmtcpy_27);
   ];
   block %__fmtcpy_39 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402568:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203880_bv32:bv32 := 0x0:bv32;
      var var1_4203880_bv32:bv32 := extract(32,0, $R4:bv64);
      $R4:bv64 := zero_extend(32, bvand(var1_4203880_bv32:bv32, 0xff:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024c4:bv64;
      goto (%__fmtcpy_37);
   ];
   block %__fmtcpy_37 [ goto (%__fmtcpy_35); ];
   block %__fmtcpy_63 [
      assert eq($_PC:bv64, 0x402544:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203844_bv64:bv64 := 0x0:bv64;
      var var1_4203844_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvand(var1_4203844_bv64:bv64, 0xffff:bv64);
      $R30:bv64 := 0x40254c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403d80:bv64;
      
      call @runelen_4210048();
      goto (%__fmtcpy_61);
   ];
   block %__fmtcpy_61 [
      assert eq($_PC:bv64, 0x40254c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203852_bv32:bv32 := 0x0:bv32;
      var var1_4203852_bv32:bv32 := 0x0:bv32;
      var var2_4203852_bv32:bv32 := 0x0:bv32;
      var var2_4203852_bv32:bv32 := extract(32,0, $R0:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4203852_bv32:bv32, bvshl(var2_4203852_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203856_bv64:bv64 := 0x0:bv64;
      var var2_4203856_bv64:bv64 := 0x0:bv64;
      var var2_4203856_bv64:bv64 := $R27:bv64;
      var var3_4203856_bv64:bv64 := 0x0:bv64;
      var var3_4203856_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4203856_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4203856_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203860_bv64:bv64 := 0x0:bv64;
      var var2_4203860_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R23:bv64),
           sign_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R23:bv64),
           zero_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64,
          bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R23:bv64,
        bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtcpy_59,%__fmtcpy_57);
   ];
   block %__fmtcpy_57 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402588:bv64;
      assert eq($_PC:bv64, 0x402588:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203912_bv64:bv64 := 0x0:bv64;
      var var1_4203912_bv64:bv64 := 0x0:bv64;
      var var2_4203912_bv64:bv64 := 0x0:bv64;
      var var2_4203912_bv64:bv64 := $R27:bv64;
      $R1:bv64 := bvor(var1_4203912_bv64:bv64,
       bvshl(var2_4203912_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203916_bv64:bv64 := 0x0:bv64;
      var var1_4203916_bv64:bv64 := 0x0:bv64;
      var var2_4203916_bv64:bv64 := 0x0:bv64;
      var var2_4203916_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203916_bv64:bv64,
       bvshl(var2_4203916_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x402594:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e30:bv64;
      
      call @__fmtflush_4202032();
      goto (%__fmtcpy_55);
   ];
   block %__fmtcpy_55 [ goto (%__fmtcpy_53); ];
   block %__fmtcpy_53 [
      assert eq($_PC:bv64, 0x402594:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203924_bv64:bv64 := 0x0:bv64;
      var var1_4203924_bv64:bv64 := 0x0:bv64;
      var var2_4203924_bv64:bv64 := 0x0:bv64;
      var var2_4203924_bv64:bv64 := $R0:bv64;
      $R27:bv64 := bvor(var1_4203924_bv64:bv64,
       bvshl(var2_4203924_bv64:bv64, 0x0:bv64));
      goto (%__fmtcpy_51,%__fmtcpy_47);
   ];
   block %__fmtcpy_47 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402600:bv64;
      goto (%__fmtcpy_45);
   ];
   block %__fmtcpy_51 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40259c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203932_bv64:bv64 := 0x0:bv64;
      var var1_4203932_bv64:bv64 := $R21:bv64;
      var var2_4203932_bv64:bv64 := 0x0:bv64;
      var var2_4203932_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203932_bv64:bv64,
       0x18:bv64) 64;
      $R23:bv64 := var2_4203932_bv64:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40255c:bv64;
      goto (%__fmtcpy_49);
   ];
   block %__fmtcpy_49 [ goto (%__fmtcpy_41); ];
   block %__fmtcpy_59 [
      guard eq($CF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_41);
   ];
   block %__fmtcpy_17 [
      assert eq($_PC:bv64, 0x4024d8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203736_bv64:bv64 := 0x0:bv64;
      var var1_4203736_bv64:bv64 := $R21:bv64;
      var var2_4203736_bv32:bv32 := 0x0:bv32;
      var var2_4203736_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203736_bv64:bv64,
       0x30:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4203736_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203740_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x10:bv64) $R27:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203744_bv32:bv32 := 0x0:bv32;
      var var1_4203744_bv32:bv32 := extract(32,0, $R0:bv64);
      var var2_4203744_bv32:bv32 := 0x0:bv32;
      var var2_4203744_bv32:bv32 := extract(32,0, $R1:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(var1_4203744_bv32:bv32, bvshl(var2_4203744_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203748_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x30:bv64) extract(32,0, $R0:bv64) 32;
      goto (%__fmtcpy_15,%__fmtcpy_9);
   ];
   block %__fmtcpy_9 [
      guard boolnot(eq($R25:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4025d4:bv64;
      assert eq($_PC:bv64, 0x4025d4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203988_bv32:bv32 := 0x0:bv32;
      var var1_4203988_bv32:bv32 := extract(32,0, $R26:bv64);
      var var2_4203988_bv32:bv32 := 0x0:bv32;
      var var2_4203988_bv32:bv32 := extract(32,0, $R24:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4203988_bv32:bv32,
        bvnot(bvshl(var2_4203988_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203992_bv64:bv64 := 0x0:bv64;
      var var1_4203992_bv64:bv64 := 0x0:bv64;
      var var2_4203992_bv64:bv64 := 0x0:bv64;
      var var2_4203992_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203992_bv64:bv64,
       bvshl(var2_4203992_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x4025e0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402104:bv64;
      
      call @__fmtpad_4202756();
      goto (%__fmtcpy_7);
   ];
   block %__fmtcpy_7 [ goto (%__fmtcpy_5); ];
   block %__fmtcpy_5 [
      assert eq($_PC:bv64, 0x4025e0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204000_bv32:bv32 := 0x0:bv32;
      var var1_4204000_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(bvand(sign_extend(31, extract(32,31, var1_4204000_bv32:bv32)),
        0xfffffffe:bv32),
       bvand(bvor(0x0:bv32,
         bvor(bvlshr(var1_4204000_bv32:bv32, 0x1f:bv32),
          bvshl(var1_4204000_bv32:bv32, 0x1:bv32))), 0x1:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204004_bv64:bv64 := 0x0:bv64;
      var var1_4204004_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4204004_bv64:bv64 := 0x0:bv64;
      var var2_4204004_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4204004_bv64:bv64;
      $R20:bv64 := var2_4204004_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204008_bv64:bv64 := 0x0:bv64;
      var var1_4204008_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4204008_bv64:bv64 := 0x0:bv64;
      var var2_4204008_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4204008_bv64:bv64;
      $R22:bv64 := var2_4204008_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204012_bv64:bv64 := 0x0:bv64;
      var var1_4204012_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      var var2_4204012_bv64:bv64 := 0x0:bv64;
      var var2_4204012_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) 64;
      $R23:bv64 := var1_4204012_bv64:bv64;
      $R24:bv64 := var2_4204012_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204016_bv64:bv64 := 0x0:bv64;
      var var1_4204016_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x40:bv64) 64;
      var var2_4204016_bv64:bv64 := 0x0:bv64;
      var var2_4204016_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x40:bv64), 0x8:bv64) 64;
      $R25:bv64 := var1_4204016_bv64:bv64;
      $R26:bv64 := var2_4204016_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204020_bv64:bv64 := 0x0:bv64;
      var var1_4204020_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x50:bv64) 64;
      $R27:bv64 := var1_4204020_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204024_bv64:bv64 := 0x0:bv64;
      var var1_4204024_bv64:bv64 := $R31:bv64;
      var var2_4204024_bv64:bv64 := 0x0:bv64;
      var var2_4204024_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4204024_bv64:bv64 := 0x0:bv64;
      var var3_4204024_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4204024_bv64:bv64;
      $R30:bv64 := var3_4204024_bv64:bv64;
      $R31:bv64 := bvadd(var1_4204024_bv64:bv64, 0x70:bv64);
      var var1_4204028_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtcpy_basil_return_1);
   ];
   block %__fmtcpy_15 [
      guard eq($R25:bv64, 0x0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_13);
   ];
   block %__fmtcpy_213 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402374:bv64);
      goto (%__fmtcpy_211);
   ];
   block %__fmtcpy_211 [ goto (%__fmtcpy_209,%__fmtcpy_207); ];
   block %__fmtcpy_207 [
      guard eq($R25:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4025bc:bv64;
      assert eq($_PC:bv64, 0x4025bc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203964_bv32:bv32 := 0x0:bv32;
      var var1_4203964_bv32:bv32 := extract(32,0, $R26:bv64);
      var var2_4203964_bv32:bv32 := 0x0:bv32;
      var var2_4203964_bv32:bv32 := extract(32,0, $R24:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4203964_bv32:bv32,
        bvnot(bvshl(var2_4203964_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203968_bv64:bv64 := 0x0:bv64;
      var var1_4203968_bv64:bv64 := 0x0:bv64;
      var var2_4203968_bv64:bv64 := 0x0:bv64;
      var var2_4203968_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203968_bv64:bv64,
       bvshl(var2_4203968_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x4025c8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402210:bv64;
      
      call @__rfmtpad_4203024();
      goto (%__fmtcpy_205);
   ];
   block %__fmtcpy_205 [ goto (%__fmtcpy_203); ];
   block %__fmtcpy_203 [
      assert eq($_PC:bv64, 0x4025c8:bv64);
      goto (%__fmtcpy_201,%__fmtcpy_197);
   ];
   block %__fmtcpy_197 [
      guard eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402378:bv64;
      goto (%__fmtcpy_195);
   ];
   block %__fmtcpy_201 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4025cc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024f4:bv64;
      goto (%__fmtcpy_199);
   ];
   block %__fmtcpy_199 [ goto (%__fmtcpy_11); ];
   block %__fmtcpy_209 [
      guard boolnot(eq($R25:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_195);
   ];
   block %__fmtcpy_195 [
      assert eq($_PC:bv64, 0x402378:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203384_bv64:bv64 := 0x0:bv64;
      var var1_4203384_bv64:bv64 := $R21:bv64;
      var var2_4203384_bv64:bv64 := 0x0:bv64;
      var var2_4203384_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203384_bv64:bv64,
       0x10:bv64) 64;
      $R20:bv64 := var2_4203384_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x50:bv64) $R27:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203392_bv64:bv64 := 0x0:bv64;
      var var1_4203392_bv64:bv64 := $R21:bv64;
      var var2_4203392_bv64:bv64 := 0x0:bv64;
      var var2_4203392_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203392_bv64:bv64,
       0x18:bv64) 64;
      $R27:bv64 := var2_4203392_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203396_bv32:bv32 := 0x0:bv32;
      var var1_4203396_bv32:bv32 := 0x0:bv32;
      var var2_4203396_bv32:bv32 := 0x0:bv32;
      var var2_4203396_bv32:bv32 := extract(32,0, $R24:bv64);
      $R23:bv64 := zero_extend(32,
      bvor(var1_4203396_bv32:bv32, bvshl(var2_4203396_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203404_bv32:bv32 := 0x0:bv32;
      var var2_4203404_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R24:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R24:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R24:bv64),
          0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R24:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__fmtcpy_193,%__fmtcpy_189);
   ];
   block %__fmtcpy_189 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4023c0:bv64;
      goto (%__fmtcpy_187);
   ];
   block %__fmtcpy_187 [
      assert eq($_PC:bv64, 0x4023c0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203456_bv64:bv64 := 0x0:bv64;
      var var1_4203456_bv64:bv64 := $R19:bv64;
      var var2_4203456_bv8:bv8 := 0x0:bv8;
      var var2_4203456_bv8:bv8 := load le $mem:(bv64->bv8) var1_4203456_bv64:bv64 8;
      $R0:bv64 := zero_extend(32, zero_extend(24, var2_4203456_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203460_bv64:bv64 := 0x0:bv64;
      var var1_4203460_bv64:bv64 := $R22:bv64;
      var var2_4203460_bv64:bv64 := 0x0:bv64;
      var var2_4203460_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(bvadd(var1_4203460_bv64:bv64,
        bvnot(bvshl(var2_4203460_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x6c:bv64) extract(16,0, $R0:bv64) 16;
      goto (%__fmtcpy_185,%__fmtcpy_161);
   ];
   block %__fmtcpy_161 [
      guard eq(extract(8,7, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402398:bv64;
      assert eq($_PC:bv64, 0x402398:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203416_bv64:bv64 := 0x0:bv64;
      var var2_4203416_bv64:bv64 := 0x0:bv64;
      var var2_4203416_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvadd(var2_4203416_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203420_bv64:bv64 := 0x0:bv64;
      var var2_4203420_bv64:bv64 := 0x0:bv64;
      var var2_4203420_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4203420_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203424_bv64:bv64 := 0x0:bv64;
      var var1_4203424_bv64:bv64 := 0x0:bv64;
      var var2_4203424_bv64:bv64 := 0x0:bv64;
      var var2_4203424_bv64:bv64 := $R20:bv64;
      $R0:bv64 := bvor(var1_4203424_bv64:bv64,
       bvshl(var2_4203424_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203428_bv64:bv64 := 0x0:bv64;
      var var2_4203428_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R27:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R27:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtcpy_159);
   ];
   block %__fmtcpy_159 [ goto (%__fmtcpy_157,%__fmtcpy_149); ];
   block %__fmtcpy_149 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402404:bv64;
      goto (%__fmtcpy_147);
   ];
   block %__fmtcpy_157 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_155);
   ];
   block %__fmtcpy_185 [
      guard boolnot(eq(extract(8,7, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4023d0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203472_bv64:bv64 := 0x0:bv64;
      var var2_4203472_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           0xfffffffffffffffffffffffffffffffd:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64), 0xfffffffffffffffd:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64),
       0x1:bv64));
      goto (%__fmtcpy_183);
   ];
   block %__fmtcpy_183 [ goto (%__fmtcpy_181,%__fmtcpy_171); ];
   block %__fmtcpy_171 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4023e4:bv64;
      goto (%__fmtcpy_169);
   ];
   block %__fmtcpy_181 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4023d8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203480_bv64:bv64 := 0x0:bv64;
      var var1_4203480_bv64:bv64 := 0x0:bv64;
      var var2_4203480_bv64:bv64 := 0x0:bv64;
      var var2_4203480_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4203480_bv64:bv64,
       bvshl(var2_4203480_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x4023e0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403df0:bv64;
      
      call @fullrune_4210160();
      goto (%__fmtcpy_179);
   ];
   block %__fmtcpy_179 [ goto (%__fmtcpy_177); ];
   block %__fmtcpy_177 [
      assert eq($_PC:bv64, 0x4023e0:bv64);
      goto (%__fmtcpy_175,%__fmtcpy_173);
   ];
   block %__fmtcpy_173 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402430:bv64;
      goto (%__fmtcpy_137);
   ];
   block %__fmtcpy_175 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_169);
   ];
   block %__fmtcpy_169 [
      assert eq($_PC:bv64, 0x4023e4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203492_bv64:bv64 := 0x0:bv64;
      var var1_4203492_bv64:bv64 := 0x0:bv64;
      var var2_4203492_bv64:bv64 := 0x0:bv64;
      var var2_4203492_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4203492_bv64:bv64,
       bvshl(var2_4203492_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203496_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x6c:bv64);
      $R30:bv64 := 0x4023f0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c60:bv64;
      
      call @chartorune_4209760();
      goto (%__fmtcpy_167);
   ];
   block %__fmtcpy_167 [
      assert eq($_PC:bv64, 0x4023f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203504_bv64:bv64 := 0x0:bv64;
      var var2_4203504_bv64:bv64 := 0x0:bv64;
      var var2_4203504_bv64:bv64 := $R19:bv64;
      var var3_4203504_bv64:bv64 := 0x0:bv64;
      var var3_4203504_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvadd(var2_4203504_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4203504_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203508_bv64:bv64 := 0x0:bv64;
      var var2_4203508_bv64:bv64 := 0x0:bv64;
      var var2_4203508_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvadd(var2_4203508_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203512_bv64:bv64 := 0x0:bv64;
      var var1_4203512_bv64:bv64 := 0x0:bv64;
      var var2_4203512_bv64:bv64 := 0x0:bv64;
      var var2_4203512_bv64:bv64 := $R20:bv64;
      $R0:bv64 := bvor(var1_4203512_bv64:bv64,
       bvshl(var2_4203512_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203516_bv64:bv64 := 0x0:bv64;
      var var2_4203516_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R27:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R27:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R27:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtcpy_165,%__fmtcpy_163);
   ];
   block %__fmtcpy_163 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4023ac:bv64;
      goto (%__fmtcpy_155);
   ];
   block %__fmtcpy_165 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_147);
   ];
   block %__fmtcpy_137 [
      assert eq($_PC:bv64, 0x402430:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203568_bv64:bv64 := 0x0:bv64;
      var var1_4203568_bv64:bv64 := $R21:bv64;
      var var2_4203568_bv64:bv64 := 0x0:bv64;
      var var2_4203568_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203568_bv64:bv64,
       0x10:bv64) 64;
      $R0:bv64 := var2_4203568_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203572_bv64:bv64 := 0x0:bv64;
      var var1_4203572_bv64:bv64 := $R20:bv64;
      var var2_4203572_bv64:bv64 := 0x0:bv64;
      var var2_4203572_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(bvadd(var1_4203572_bv64:bv64,
        bvnot(bvshl(var2_4203572_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203576_bv64:bv64 := 0x0:bv64;
      var var1_4203576_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(0x0:bv64,
       bvand(bvor(0x0:bv64,
         bvand(bvor(bvlshr(var1_4203576_bv64:bv64, 0x1:bv64),
           bvshl(var1_4203576_bv64:bv64, 0x3f:bv64)), 0x80000000ffffffff:bv64)),
        0xffffffff:bv64));
      goto (%__fmtcpy_135);
   ];
   block %__fmtcpy_147 [
      assert eq($_PC:bv64, 0x402404:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203524_bv64:bv64 := 0x0:bv64;
      var var1_4203524_bv64:bv64 := 0x0:bv64;
      var var2_4203524_bv64:bv64 := 0x0:bv64;
      var var2_4203524_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvor(var1_4203524_bv64:bv64,
       bvshl(var2_4203524_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203528_bv64:bv64 := 0x0:bv64;
      var var1_4203528_bv64:bv64 := 0x0:bv64;
      var var2_4203528_bv64:bv64 := 0x0:bv64;
      var var2_4203528_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203528_bv64:bv64,
       bvshl(var2_4203528_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x2:bv64;
      $R30:bv64 := 0x402414:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e30:bv64;
      
      call @__fmtflush_4202032();
      goto (%__fmtcpy_145);
   ];
   block %__fmtcpy_145 [
      assert eq($_PC:bv64, 0x402414:bv64);
      goto (%__fmtcpy_143,%__fmtcpy_123);
   ];
   block %__fmtcpy_123 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402600:bv64;
      goto (%__fmtcpy_45);
   ];
   block %__fmtcpy_143 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402418:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203544_bv16:bv16 := 0x0:bv16;
      var var1_4203544_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x6c:bv64) 16;
      $R1:bv64 := zero_extend(32, zero_extend(16, var1_4203544_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203548_bv64:bv64 := 0x0:bv64;
      var var2_4203548_bv64:bv64 := 0x0:bv64;
      var var2_4203548_bv64:bv64 := $R0:bv64;
      $R20:bv64 := bvadd(var2_4203548_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203552_bv64:bv64 := 0x0:bv64;
      var var1_4203552_bv64:bv64 := $R21:bv64;
      var var2_4203552_bv64:bv64 := 0x0:bv64;
      var var2_4203552_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4203552_bv64:bv64,
       0x18:bv64) 64;
      $R27:bv64 := var2_4203552_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203556_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(16,0, $R1:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203560_bv32:bv32 := 0x0:bv32;
      var var2_4203560_bv32:bv32 := 0x0:bv32;
      var var2_4203560_bv32:bv32 := extract(32,0, $R23:bv64);
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, var2_4203560_bv32:bv32),
           0xfffffffffffffffe:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, var2_4203560_bv32:bv32), 0xfffffffe:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(var2_4203560_bv32:bv32,
        0xfffffffe:bv32), 0x1:bv32));
      $R23:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32));
      goto (%__fmtcpy_141);
   ];
   block %__fmtcpy_141 [ goto (%__fmtcpy_139,%__fmtcpy_125); ];
   block %__fmtcpy_125 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4023c0:bv64;
      goto (%__fmtcpy_187);
   ];
   block %__fmtcpy_139 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_137);
   ];
   block %__fmtcpy_155 [
      assert eq($_PC:bv64, 0x4023ac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203436_bv64:bv64 := 0x0:bv64;
      var var1_4203436_bv64:bv64 := 0x0:bv64;
      var var2_4203436_bv64:bv64 := 0x0:bv64;
      var var2_4203436_bv64:bv64 := $R1:bv64;
      $R20:bv64 := bvor(var1_4203436_bv64:bv64,
       bvshl(var2_4203436_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203440_bv16:bv16 := 0x0:bv16;
      var var1_4203440_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x6c:bv64) 16;
      $R1:bv64 := zero_extend(32, zero_extend(16, var1_4203440_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203444_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(16,0, $R1:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203448_bv32:bv32 := 0x0:bv32;
      var var2_4203448_bv32:bv32 := 0x0:bv32;
      var var2_4203448_bv32:bv32 := extract(32,0, $R23:bv64);
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, var2_4203448_bv32:bv32),
           0xfffffffffffffffe:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, var2_4203448_bv32:bv32), 0xfffffffe:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(var2_4203448_bv32:bv32,
        0xfffffffe:bv32), 0x1:bv32));
      $R23:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32));
      goto (%__fmtcpy_153,%__fmtcpy_151);
   ];
   block %__fmtcpy_151 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402430:bv64;
      goto (%__fmtcpy_137);
   ];
   block %__fmtcpy_153 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtcpy_187);
   ];
   block %__fmtcpy_193 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402394:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40243c:bv64;
      goto (%__fmtcpy_191);
   ];
   block %__fmtcpy_191 [ goto (%__fmtcpy_135); ];
   block %__fmtcpy_135 [
      assert eq($_PC:bv64, 0x40243c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203580_bv64:bv64 := 0x0:bv64;
      var var1_4203580_bv64:bv64 := $R21:bv64;
      var var2_4203580_bv32:bv32 := 0x0:bv32;
      var var2_4203580_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4203580_bv64:bv64,
       0x30:bv64) 32;
      $R1:bv64 := zero_extend(32, var2_4203580_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203584_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x10:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203588_bv32:bv32 := 0x0:bv32;
      var var1_4203588_bv32:bv32 := extract(32,0, $R1:bv64);
      var var2_4203588_bv32:bv32 := 0x0:bv32;
      var var2_4203588_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(var1_4203588_bv32:bv32, bvshl(var2_4203588_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203592_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x30:bv64) extract(32,0, $R0:bv64) 32;
      goto (%__fmtcpy_133,%__fmtcpy_127);
   ];
   block %__fmtcpy_127 [
      guard eq($R25:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024ec:bv64;
      goto (%__fmtcpy_13);
   ];
   block %__fmtcpy_133 [
      guard boolnot(eq($R25:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402450:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203600_bv32:bv32 := 0x0:bv32;
      var var1_4203600_bv32:bv32 := extract(32,0, $R26:bv64);
      var var2_4203600_bv32:bv32 := 0x0:bv32;
      var var2_4203600_bv32:bv32 := extract(32,0, $R24:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4203600_bv32:bv32,
        bvnot(bvshl(var2_4203600_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203604_bv64:bv64 := 0x0:bv64;
      var var1_4203604_bv64:bv64 := 0x0:bv64;
      var var2_4203604_bv64:bv64 := 0x0:bv64;
      var var2_4203604_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4203604_bv64:bv64,
       bvshl(var2_4203604_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x40245c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402210:bv64;
      
      call @__rfmtpad_4203024();
      goto (%__fmtcpy_131);
   ];
   block %__fmtcpy_131 [ goto (%__fmtcpy_129); ];
   block %__fmtcpy_129 [
      assert eq($_PC:bv64, 0x40245c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203612_bv32:bv32 := 0x0:bv32;
      var var1_4203612_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(bvand(sign_extend(31, extract(32,31, var1_4203612_bv32:bv32)),
        0xfffffffe:bv32),
       bvand(bvor(0x0:bv32,
         bvor(bvlshr(var1_4203612_bv32:bv32, 0x1f:bv32),
          bvshl(var1_4203612_bv32:bv32, 0x1:bv32))), 0x1:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203616_bv64:bv64 := 0x0:bv64;
      var var1_4203616_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4203616_bv64:bv64 := 0x0:bv64;
      var var2_4203616_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4203616_bv64:bv64;
      $R20:bv64 := var2_4203616_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203620_bv64:bv64 := 0x0:bv64;
      var var1_4203620_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4203620_bv64:bv64 := 0x0:bv64;
      var var2_4203620_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4203620_bv64:bv64;
      $R22:bv64 := var2_4203620_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203624_bv64:bv64 := 0x0:bv64;
      var var1_4203624_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      var var2_4203624_bv64:bv64 := 0x0:bv64;
      var var2_4203624_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) 64;
      $R23:bv64 := var1_4203624_bv64:bv64;
      $R24:bv64 := var2_4203624_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203628_bv64:bv64 := 0x0:bv64;
      var var1_4203628_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x40:bv64) 64;
      var var2_4203628_bv64:bv64 := 0x0:bv64;
      var var2_4203628_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x40:bv64), 0x8:bv64) 64;
      $R25:bv64 := var1_4203628_bv64:bv64;
      $R26:bv64 := var2_4203628_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203632_bv64:bv64 := 0x0:bv64;
      var var1_4203632_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x50:bv64) 64;
      $R27:bv64 := var1_4203632_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203636_bv64:bv64 := 0x0:bv64;
      var var1_4203636_bv64:bv64 := $R31:bv64;
      var var2_4203636_bv64:bv64 := 0x0:bv64;
      var var2_4203636_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4203636_bv64:bv64 := 0x0:bv64;
      var var3_4203636_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4203636_bv64:bv64;
      $R30:bv64 := var3_4203636_bv64:bv64;
      $R31:bv64 := bvadd(var1_4203636_bv64:bv64, 0x70:bv64);
      var var1_4203640_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtcpy_basil_return_1);
   ];
   block %__fmtcpy_11 [
      assert eq($_PC:bv64, 0x4024f4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203764_bv64:bv64 := 0x0:bv64;
      var var1_4203764_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4203764_bv64:bv64 := 0x0:bv64;
      var var2_4203764_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4203764_bv64:bv64;
      $R20:bv64 := var2_4203764_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203768_bv64:bv64 := 0x0:bv64;
      var var1_4203768_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4203768_bv64:bv64 := 0x0:bv64;
      var var2_4203768_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4203768_bv64:bv64;
      $R22:bv64 := var2_4203768_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203772_bv64:bv64 := 0x0:bv64;
      var var1_4203772_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      var var2_4203772_bv64:bv64 := 0x0:bv64;
      var var2_4203772_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) 64;
      $R23:bv64 := var1_4203772_bv64:bv64;
      $R24:bv64 := var2_4203772_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203776_bv64:bv64 := 0x0:bv64;
      var var1_4203776_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x40:bv64) 64;
      var var2_4203776_bv64:bv64 := 0x0:bv64;
      var var2_4203776_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x40:bv64), 0x8:bv64) 64;
      $R25:bv64 := var1_4203776_bv64:bv64;
      $R26:bv64 := var2_4203776_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203780_bv64:bv64 := 0x0:bv64;
      var var1_4203780_bv64:bv64 := $R31:bv64;
      var var2_4203780_bv64:bv64 := 0x0:bv64;
      var var2_4203780_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4203780_bv64:bv64 := 0x0:bv64;
      var var3_4203780_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4203780_bv64:bv64;
      $R30:bv64 := var3_4203780_bv64:bv64;
      $R31:bv64 := bvadd(var1_4203780_bv64:bv64, 0x70:bv64);
      var var1_4203784_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtcpy_basil_return_1);
   ];
   block %__fmtcpy_13 [
      assert eq($_PC:bv64, 0x4024ec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4203756_bv64:bv64 := 0x0:bv64;
      var var1_4203756_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x50:bv64) 64;
      $R27:bv64 := var1_4203756_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      goto (%__fmtcpy_11);
   ];
   block %__fmtcpy_45 [
      assert eq($_PC:bv64, 0x402600:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4204032_bv64:bv64 := 0x0:bv64;
      var var1_4204032_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x50:bv64) 64;
      $R27:bv64 := var1_4204032_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4024f4:bv64;
      goto (%__fmtcpy_11);
   ];
   block %__fmtcpy_basil_return_1 [ nop; return; ]
];
proc @__badfmt_4208400()  -> () { .address = 4208400; .name = "__badfmt";
    .returnBlock = "__badfmt_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403710:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__badfmt_entry [
      assert eq($_PC:bv64, 0x403710:bv64);
      $_PC:bv64 := 0x403710:bv64;
      assert eq($_PC:bv64, 0x403710:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208400_bv64:bv64 := 0x0:bv64;
      var var1_4208400_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffe0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4208400_bv64:bv64, 0xffffffffffffffe0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R5:bv64 := 0x25:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208412_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208416_bv64:bv64 := 0x0:bv64;
      var var1_4208416_bv64:bv64 := $R0:bv64;
      var var2_4208416_bv32:bv32 := 0x0:bv32;
      var var2_4208416_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4208416_bv64:bv64,
       0x58:bv64) 32;
      $R4:bv64 := zero_extend(32, var2_4208416_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208420_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x18:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208424_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x60:bv64) extract(32,0, $R3:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208428_bv32:bv32 := 0x0:bv32;
      var var1_4208428_bv32:bv32 := 0x0:bv32;
      var var2_4208428_bv32:bv32 := 0x0:bv32;
      var var2_4208428_bv32:bv32 := extract(32,0, $R3:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4208428_bv32:bv32, bvshl(var2_4208428_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x18:bv64) extract(8,0, $R5:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x19:bv64) extract(8,0, $R4:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x1a:bv64) extract(8,0, $R5:bv64) 8;
      $R30:bv64 := 0x403740:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402320:bv64;
      
      call @__fmtcpy_4203296();
      goto (%__badfmt_5);
   ];
   block %__badfmt_5 [
      assert eq($_PC:bv64, 0x403740:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208452_bv64:bv64 := 0x0:bv64;
      var var1_4208452_bv64:bv64 := $R31:bv64;
      var var2_4208452_bv64:bv64 := 0x0:bv64;
      var var2_4208452_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4208452_bv64:bv64 := 0x0:bv64;
      var var3_4208452_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4208452_bv64:bv64;
      $R30:bv64 := var3_4208452_bv64:bv64;
      $R31:bv64 := bvadd(var1_4208452_bv64:bv64, 0x20:bv64);
      var var1_4208456_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__badfmt_basil_return_1);
   ];
   block %__badfmt_basil_return_1 [ nop; return; ]
];
proc @getcallerpc_4201920()  -> () { .address = 4201920; .name = "getcallerpc";
    .returnBlock = "getcallerpc_basil_return_1" }
  modifies $BTypeNext:bv2, $R0:bv64, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $R0:bv64, $R30:bv64, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401dc0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %getcallerpc_entry [
      assert eq($_PC:bv64, 0x401dc0:bv64);
      $_PC:bv64 := 0x401dc0:bv64;
      assert eq($_PC:bv64, 0x401dc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201920_bv64:bv64 := 0x0:bv64;
      var var1_4201920_bv64:bv64 := $R0:bv64;
      var var2_4201920_bv64:bv64 := 0x0:bv64;
      var var2_4201920_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4201920_bv64:bv64,
       0xfffffffffffffff0:bv64) 64;
      $R0:bv64 := var2_4201920_bv64:bv64;
      var var1_4201924_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%getcallerpc_basil_return_1);
   ];
   block %getcallerpc_basil_return_1 [ nop; return; ]
];
proc @unlock_4199332()  -> () { .address = 4199332; .name = "unlock";
    .returnBlock = "unlock_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x4013a4:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %unlock_entry [
      assert eq($_PC:bv64, 0x4013a4:bv64);
      $_PC:bv64 := 0x4013a4:bv64;
      assert eq($_PC:bv64, 0x4013a4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199332_bv64:bv64 := 0x0:bv64;
      var var1_4199332_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4199332_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199340_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199348_bv64:bv64 := 0x0:bv64;
      var var1_4199348_bv64:bv64 := 0x0:bv64;
      var var2_4199348_bv64:bv64 := 0x0:bv64;
      var var2_4199348_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4199348_bv64:bv64,
       bvshl(var2_4199348_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199352_bv64:bv64 := 0x0:bv64;
      var var1_4199352_bv64:bv64 := $R1:bv64;
      var var2_4199352_bv64:bv64 := 0x0:bv64;
      var var2_4199352_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4199352_bv64:bv64,
       0x630:bv64) 64;
      $R20:bv64 := var2_4199352_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x28:bv64) $R0:bv64 64;
      goto (%unlock_13,%unlock_5);
   ];
   block %unlock_5 [
      guard eq($R20:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4013e4:bv64;
      assert eq($_PC:bv64, 0x4013e4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199396_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 0x0:bv32 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199400_bv64:bv64 := 0x0:bv64;
      var var1_4199400_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4199400_bv64:bv64 := 0x0:bv64;
      var var2_4199400_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4199400_bv64:bv64;
      $R20:bv64 := var2_4199400_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199404_bv64:bv64 := 0x0:bv64;
      var var1_4199404_bv64:bv64 := $R31:bv64;
      var var2_4199404_bv64:bv64 := 0x0:bv64;
      var var2_4199404_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4199404_bv64:bv64 := 0x0:bv64;
      var var3_4199404_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4199404_bv64:bv64;
      $R30:bv64 := var3_4199404_bv64:bv64;
      $R31:bv64 := bvadd(var1_4199404_bv64:bv64, 0x30:bv64);
      var var1_4199408_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%unlock_3);
   ];
   block %unlock_3 [ goto (%unlock_basil_return_1); ];
   block %unlock_13 [
      guard boolnot(eq($R20:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4013c4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199364_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $R30:bv64 := 0x4013cc:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dc0:bv64;
      
      call @getcallerpc_4201920();
      goto (%unlock_11);
   ];
   block %unlock_11 [ goto (%unlock_9); ];
   block %unlock_9 [
      assert eq($_PC:bv64, 0x4013cc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199372_bv64:bv64 := 0x0:bv64;
      var var1_4199372_bv64:bv64 := 0x0:bv64;
      var var2_4199372_bv64:bv64 := 0x0:bv64;
      var var2_4199372_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvor(var1_4199372_bv64:bv64,
       bvshl(var2_4199372_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199376_bv64:bv64 := 0x0:bv64;
      var var1_4199376_bv64:bv64 := 0x0:bv64;
      var var2_4199376_bv64:bv64 := 0x0:bv64;
      var var2_4199376_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4199376_bv64:bv64,
       bvshl(var2_4199376_bv64:bv64, 0x0:bv64));
      var var1_4199380_bv64:bv64 := 0x0:bv64;
      var var1_4199380_bv64:bv64 := $R20:bv64;
      $R30:bv64 := 0x4013d8:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4199380_bv64:bv64;
      indirect call var1_4199380_bv64:bv64;
      goto (%unlock_7);
   ];
   block %unlock_7 [
      assert eq($_PC:bv64, 0x4013d8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199384_bv64:bv64 := 0x0:bv64;
      var var1_4199384_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4199384_bv64:bv64 := 0x0:bv64;
      var var2_4199384_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4199384_bv64:bv64;
      $R20:bv64 := var2_4199384_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199388_bv64:bv64 := 0x0:bv64;
      var var1_4199388_bv64:bv64 := $R31:bv64;
      var var2_4199388_bv64:bv64 := 0x0:bv64;
      var var2_4199388_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4199388_bv64:bv64 := 0x0:bv64;
      var var3_4199388_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4199388_bv64:bv64;
      $R30:bv64 := var3_4199388_bv64:bv64;
      $R31:bv64 := bvadd(var1_4199388_bv64:bv64, 0x30:bv64);
      var var1_4199392_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%unlock_basil_return_1);
   ];
   block %unlock_basil_return_1 [ nop; return; ]
];
proc @__fmtunlock_4209744()  -> () { .address = 4209744; .name = "__fmtunlock";
    .returnBlock = "__fmtunlock_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403c50:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtunlock_entry [
      var R30_begin___fmtunlock_4209744:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x403c50:bv64);
      $_PC:bv64 := 0x403c50:bv64;
      assert eq($_PC:bv64, 0x403c50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209748_bv64:bv64 := 0x0:bv64;
      var var2_4209748_bv64:bv64 := 0x0:bv64;
      var var2_4209748_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4209748_bv64:bv64, 0xb18:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4013a4:bv64;
      assert eq($R30:bv64, R30_begin___fmtunlock_4209744:bv64);
      
      call @unlock_4199332();
      goto (%__fmtunlock_basil_return_1);
   ];
   block %__fmtunlock_basil_return_1 [ nop; return; ]
];
proc @lock_4199120()  -> () { .address = 4199120; .name = "lock";
    .returnBlock = "lock_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x4012d0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %lock_entry [
      assert eq($_PC:bv64, 0x4012d0:bv64);
      $_PC:bv64 := 0x4012d0:bv64;
      assert eq($_PC:bv64, 0x4012d0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199120_bv64:bv64 := 0x0:bv64;
      var var1_4199120_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4199120_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199128_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199136_bv64:bv64 := 0x0:bv64;
      var var1_4199136_bv64:bv64 := 0x0:bv64;
      var var2_4199136_bv64:bv64 := 0x0:bv64;
      var var2_4199136_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4199136_bv64:bv64,
       bvshl(var2_4199136_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199140_bv64:bv64 := 0x0:bv64;
      var var1_4199140_bv64:bv64 := $R1:bv64;
      var var2_4199140_bv64:bv64 := 0x0:bv64;
      var var2_4199140_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4199140_bv64:bv64,
       0x628:bv64) 64;
      $R20:bv64 := var2_4199140_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x28:bv64) $R0:bv64 64;
      goto (%lock_15,%lock_7);
   ];
   block %lock_7 [
      guard eq($R20:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401314:bv64;
      assert eq($_PC:bv64, 0x401314:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199192_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R19:bv64 extract(32,0, $R0:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199196_bv64:bv64 := 0x0:bv64;
      var var1_4199196_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4199196_bv64:bv64 := 0x0:bv64;
      var var2_4199196_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4199196_bv64:bv64;
      $R20:bv64 := var2_4199196_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199200_bv64:bv64 := 0x0:bv64;
      var var1_4199200_bv64:bv64 := $R31:bv64;
      var var2_4199200_bv64:bv64 := 0x0:bv64;
      var var2_4199200_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4199200_bv64:bv64 := 0x0:bv64;
      var var3_4199200_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4199200_bv64:bv64;
      $R30:bv64 := var3_4199200_bv64:bv64;
      $R31:bv64 := bvadd(var1_4199200_bv64:bv64, 0x30:bv64);
      var var1_4199204_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%lock_5);
   ];
   block %lock_5 [ goto (%lock_basil_return_1); ];
   block %lock_15 [
      guard boolnot(eq($R20:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4012f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199152_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $R30:bv64 := 0x4012f8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dc0:bv64;
      
      call @getcallerpc_4201920();
      goto (%lock_13);
   ];
   block %lock_13 [ goto (%lock_11); ];
   block %lock_11 [
      assert eq($_PC:bv64, 0x4012f8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199164_bv64:bv64 := 0x0:bv64;
      var var1_4199164_bv64:bv64 := 0x0:bv64;
      var var2_4199164_bv64:bv64 := 0x0:bv64;
      var var2_4199164_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvor(var1_4199164_bv64:bv64,
       bvshl(var2_4199164_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199168_bv64:bv64 := 0x0:bv64;
      var var1_4199168_bv64:bv64 := 0x0:bv64;
      var var2_4199168_bv64:bv64 := 0x0:bv64;
      var var2_4199168_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4199168_bv64:bv64,
       bvshl(var2_4199168_bv64:bv64, 0x0:bv64));
      var var1_4199172_bv64:bv64 := 0x0:bv64;
      var var1_4199172_bv64:bv64 := $R20:bv64;
      $R30:bv64 := 0x401308:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4199172_bv64:bv64;
      indirect call var1_4199172_bv64:bv64;
      goto (%lock_9);
   ];
   block %lock_9 [
      assert eq($_PC:bv64, 0x401308:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199176_bv64:bv64 := 0x0:bv64;
      var var1_4199176_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4199176_bv64:bv64 := 0x0:bv64;
      var var2_4199176_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4199176_bv64:bv64;
      $R20:bv64 := var2_4199176_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199180_bv64:bv64 := 0x0:bv64;
      var var1_4199180_bv64:bv64 := $R31:bv64;
      var var2_4199180_bv64:bv64 := 0x0:bv64;
      var var2_4199180_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4199180_bv64:bv64 := 0x0:bv64;
      var var3_4199180_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4199180_bv64:bv64;
      $R30:bv64 := var3_4199180_bv64:bv64;
      $R31:bv64 := bvadd(var1_4199180_bv64:bv64, 0x30:bv64);
      var var1_4199184_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%lock_basil_return_1);
   ];
   block %lock_basil_return_1 [ nop; return; ]
];
proc @__fmtlock_4209728()  -> () { .address = 4209728; .name = "__fmtlock";
    .returnBlock = "__fmtlock_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $R0:bv64,
    $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403c40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtlock_entry [
      var R30_begin___fmtlock_4209728:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x403c40:bv64);
      $_PC:bv64 := 0x403c40:bv64;
      assert eq($_PC:bv64, 0x403c40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209732_bv64:bv64 := 0x0:bv64;
      var var2_4209732_bv64:bv64 := 0x0:bv64;
      var var2_4209732_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4209732_bv64:bv64, 0xb18:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4012d0:bv64;
      assert eq($R30:bv64, R30_begin___fmtlock_4209728:bv64);
      
      call @lock_4199120();
      goto (%__fmtlock_basil_return_1);
   ];
   block %__fmtlock_basil_return_1 [ nop; return; ]
];
proc @__fmtinstall_4208464()  -> () { .address = 4208464; .name = "__fmtinstall";
    .returnBlock = "__fmtinstall_basil_return_1" }
  modifies $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64,
    $R2:bv64, $R3:bv64, $R30:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1,
    $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403750:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtinstall_entry [
      assert eq($_PC:bv64, 0x403750:bv64);
      $_PC:bv64 := 0x403750:bv64;
      assert eq($_PC:bv64, 0x403750:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208464_bv32:bv32 := 0x0:bv32;
      var var2_4208464_bv32:bv32 := 0x0:bv32;
      var var2_4208464_bv32:bv32 := extract(32,0, $R0:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4208464_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0xfffe:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208472_bv32:bv32 := 0x0:bv32;
      var var2_4208472_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64),
           bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R3:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64),
           bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R3:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R3:bv64),
          bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R3:bv64),
        bvnot(bvshl(extract(32,0, $R2:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtinstall_53,%__fmtinstall_7);
   ];
   block %__fmtinstall_7 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037e0:bv64;
      goto (%__fmtinstall_5);
   ];
   block %__fmtinstall_53 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403760:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R6:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208484_bv64:bv64 := 0x0:bv64;
      var var2_4208484_bv64:bv64 := 0x0:bv64;
      var var2_4208484_bv64:bv64 := $R6:bv64;
      $R5:bv64 := bvadd(var2_4208484_bv64:bv64, 0x708:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208488_bv64:bv64 := 0x0:bv64;
      var var2_4208488_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x403000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208496_bv64:bv64 := 0x0:bv64;
      var var1_4208496_bv64:bv64 := $R6:bv64;
      var var2_4208496_bv32:bv32 := 0x0:bv32;
      var var2_4208496_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4208496_bv64:bv64,
       0x708:bv64) 32;
      $R7:bv64 := zero_extend(32, var2_4208496_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208500_bv64:bv64 := 0x0:bv64;
      var var2_4208500_bv64:bv64 := 0x0:bv64;
      var var2_4208500_bv64:bv64 := $R3:bv64;
      $R3:bv64 := bvadd(var2_4208500_bv64:bv64, 0x710:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208504_bv64:bv64 := 0x0:bv64;
      var var2_4208504_bv64:bv64 := 0x0:bv64;
      var var2_4208504_bv64:bv64 := $R5:bv64;
      $R2:bv64 := bvadd(var2_4208504_bv64:bv64, 0x8:bv64);
      var var1_4208508_bv64:bv64 := 0x0:bv64;
      var var1_4208508_bv64:bv64 := $R3:bv64;
      var var2_4208508_bv64:bv64 := 0x0:bv64;
      var var2_4208508_bv64:bv64 := $R1:bv64;
      goto (%__fmtinstall_51);
   ];
   block %__fmtinstall_51 [ goto (%__fmtinstall_49,%__fmtinstall_47); ];
   block %__fmtinstall_47 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var1_4208508_bv64:bv64;
      goto (%__fmtinstall_45);
   ];
   block %__fmtinstall_49 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := var2_4208508_bv64:bv64;
      goto (%__fmtinstall_45);
   ];
   block %__fmtinstall_45 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208512_bv64:bv64 := 0x0:bv64;
      var var2_4208512_bv64:bv64 := 0x0:bv64;
      var var2_4208512_bv64:bv64 := $R5:bv64;
      var var3_4208512_bv64:bv64 := 0x0:bv64;
      var var3_4208512_bv64:bv64 := $R7:bv64;
      $R4:bv64 := bvadd(var2_4208512_bv64:bv64,
       sign_extend(28, bvconcat(extract(32,0, var3_4208512_bv64:bv64), 0x0:bv4)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208516_bv64:bv64 := 0x0:bv64;
      var var2_4208516_bv64:bv64 := 0x0:bv64;
      var var2_4208516_bv64:bv64 := $R4:bv64;
      $R4:bv64 := bvadd(var2_4208516_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208520_bv64:bv64 := 0x0:bv64;
      var var2_4208520_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R4:bv64),
           sign_extend(64, bvnot(bvshl($R2:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R4:bv64),
           zero_extend(64, bvnot(bvshl($R2:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64,
          bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R4:bv64,
        bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtinstall_43,%__fmtinstall_39);
   ];
   block %__fmtinstall_39 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037a0:bv64;
      goto (%__fmtinstall_37);
   ];
   block %__fmtinstall_37 [
      assert eq($_PC:bv64, 0x4037a0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208544_bv64:bv64 := 0x0:bv64;
      var var1_4208544_bv64:bv64 := $R2:bv64;
      var var2_4208544_bv32:bv32 := 0x0:bv32;
      var var2_4208544_bv32:bv32 := load le $mem:(bv64->bv8) var1_4208544_bv64:bv64 32;
      $R3:bv64 := zero_extend(32, var2_4208544_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208548_bv32:bv32 := 0x0:bv32;
      var var2_4208548_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R3:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R3:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R3:bv64),
          bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R3:bv64),
        bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtinstall_35,%__fmtinstall_33);
   ];
   block %__fmtinstall_33 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403794:bv64;
      assert eq($_PC:bv64, 0x403794:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208532_bv64:bv64 := 0x0:bv64;
      var var2_4208532_bv64:bv64 := 0x0:bv64;
      var var2_4208532_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(var2_4208532_bv64:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208536_bv64:bv64 := 0x0:bv64;
      var var2_4208536_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R4:bv64),
           sign_extend(64, bvnot(bvshl($R2:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R4:bv64),
           zero_extend(64, bvnot(bvshl($R2:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64,
          bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R4:bv64,
        bvnot(bvshl($R2:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtinstall_31);
   ];
   block %__fmtinstall_31 [ goto (%__fmtinstall_29,%__fmtinstall_27); ];
   block %__fmtinstall_27 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037ac:bv64;
      goto (%__fmtinstall_25);
   ];
   block %__fmtinstall_29 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtinstall_37);
   ];
   block %__fmtinstall_35 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtinstall_25);
   ];
   block %__fmtinstall_25 [
      assert eq($_PC:bv64, 0x4037ac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208556_bv64:bv64 := 0x0:bv64;
      var var2_4208556_bv64:bv64 := 0x0:bv64;
      var var2_4208556_bv64:bv64 := $R5:bv64;
      $R5:bv64 := bvadd(var2_4208556_bv64:bv64, 0x408:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208560_bv64:bv64 := 0x0:bv64;
      var var2_4208560_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R5:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R5:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R5:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R5:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtinstall_23,%__fmtinstall_9);
   ];
   block %__fmtinstall_9 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037e0:bv64;
      goto (%__fmtinstall_5);
   ];
   block %__fmtinstall_23 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtinstall_21);
   ];
   block %__fmtinstall_43 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403790:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037b8:bv64;
      goto (%__fmtinstall_41);
   ];
   block %__fmtinstall_41 [ goto (%__fmtinstall_21); ];
   block %__fmtinstall_21 [
      assert eq($_PC:bv64, 0x4037b8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208568_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R2:bv64, 0x8:bv64) $R1:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208572_bv64:bv64 := 0x0:bv64;
      var var2_4208572_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R4:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R4:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtinstall_19,%__fmtinstall_15);
   ];
   block %__fmtinstall_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037cc:bv64;
      assert eq($_PC:bv64, 0x4037cc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208588_bv32:bv32 := 0x0:bv32;
      var var2_4208588_bv32:bv32 := 0x0:bv32;
      var var2_4208588_bv32:bv32 := extract(32,0, $R7:bv64);
      $R7:bv64 := zero_extend(32, bvadd(var2_4208588_bv32:bv32, 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208592_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R6:bv64, 0x708:bv64) extract(32,0, $R7:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208596_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R2:bv64 extract(32,0, $R0:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4037c8:bv64;
      goto (%__fmtinstall_13);
   ];
   block %__fmtinstall_13 [ goto (%__fmtinstall_11); ];
   block %__fmtinstall_19 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4037c4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      goto (%__fmtinstall_17);
   ];
   block %__fmtinstall_17 [ goto (%__fmtinstall_11); ];
   block %__fmtinstall_11 [
      assert eq($_PC:bv64, 0x4037c8:bv64);
      var var1_4208584_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtinstall_basil_return_1);
   ];
   block %__fmtinstall_5 [
      assert eq($_PC:bv64, 0x4037e0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      var var1_4208612_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtinstall_basil_return_1);
   ];
   block %__fmtinstall_basil_return_1 [ nop; return; ]
];
proc @__fmtdispatch_4208688()  -> () { .address = 4208688; .name = "__fmtdispatch";
    .returnBlock = "__fmtdispatch_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x403830:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fmtdispatch_entry [
      assert eq($_PC:bv64, 0x403830:bv64);
      $_PC:bv64 := 0x403830:bv64;
      assert eq($_PC:bv64, 0x403830:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208688_bv64:bv64 := 0x0:bv64;
      var var1_4208688_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffb0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffb0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4208688_bv64:bv64, 0xffffffffffffffb0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208692_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208700_bv64:bv64 := 0x0:bv64;
      var var1_4208700_bv64:bv64 := 0x0:bv64;
      var var2_4208700_bv64:bv64 := 0x0:bv64;
      var var2_4208700_bv64:bv64 := $R1:bv64;
      $R20:bv64 := bvor(var1_4208700_bv64:bv64,
       bvshl(var2_4208700_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208708_bv64:bv64 := 0x0:bv64;
      var var1_4208708_bv64:bv64 := 0x0:bv64;
      var var2_4208708_bv64:bv64 := 0x0:bv64;
      var var2_4208708_bv64:bv64 := $R0:bv64;
      $R21:bv64 := bvor(var1_4208708_bv64:bv64,
       bvshl(var2_4208708_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208712_bv32:bv32 := 0x0:bv32;
      var var1_4208712_bv32:bv32 := 0x0:bv32;
      var var2_4208712_bv32:bv32 := 0x0:bv32;
      var var2_4208712_bv32:bv32 := extract(32,0, $R2:bv64);
      $R22:bv64 := zero_extend(32,
      bvor(var1_4208712_bv32:bv32, bvshl(var2_4208712_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208716_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x5c:bv64) 0x0:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208720_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R0:bv64, 0x68:bv64) 0x0:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_225);
   ];
   block %__fmtdispatch_225 [
      assert eq($_PC:bv64, 0x403858:bv64);
      goto (%__fmtdispatch_223,%__fmtdispatch_221);
   ];
   block %__fmtdispatch_221 [
      guard eq(extract(32,0, $R22:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4038c0:bv64;
      goto (%__fmtdispatch_219);
   ];
   block %__fmtdispatch_223 [
      guard boolnot(eq(extract(32,0, $R22:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_167);
   ];
   block %__fmtdispatch_161 [
      assert eq($_PC:bv64, 0x4038e0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208864_bv64:bv64 := 0x0:bv64;
      var var1_4208864_bv64:bv64 := $R21:bv64;
      var var2_4208864_bv64:bv64 := 0x0:bv64;
      var var2_4208864_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208864_bv64:bv64,
       0x68:bv64) 64;
      $R0:bv64 := var2_4208864_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x5:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208872_bv64:bv64 := 0x0:bv64;
      var var1_4208872_bv64:bv64 := $R0:bv64;
      var var2_4208872_bv64:bv64 := 0x0:bv64;
      var var2_4208872_bv64:bv64 := $R1:bv64;
      $R0:bv64 := bvor(var1_4208872_bv64:bv64,
       bvshl(var2_4208872_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208876_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403858:bv64;
      goto (%__fmtdispatch_225);
   ];
   block %__fmtdispatch_167 [
      assert eq($_PC:bv64, 0x40385c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208732_bv64:bv64 := 0x0:bv64;
      var var1_4208732_bv64:bv64 := $R20:bv64;
      var var2_4208732_bv16:bv16 := 0x0:bv16;
      var var2_4208732_bv16:bv16 := load le $mem:(bv64->bv8) var1_4208732_bv64:bv64 16;
      $R19:bv64 := zero_extend(32, zero_extend(16, var2_4208732_bv16:bv16));
      $R20:bv64 := bvadd(var1_4208732_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208736_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x58:bv64) extract(32,0, $R19:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208740_bv32:bv32 := 0x0:bv32;
      var var2_4208740_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           0xffffffffffffffd1:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)), 0xffffffd1:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          0xffffffd1:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        0xffffffd1:bv32), 0x1:bv32));
      goto (%__fmtdispatch_165,%__fmtdispatch_163);
   ];
   block %__fmtdispatch_163 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4038e0:bv64;
      goto (%__fmtdispatch_161);
   ];
   block %__fmtdispatch_165 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_211);
   ];
   block %__fmtdispatch_211 [
      assert eq($_PC:bv64, 0x40386c:bv64);
      goto (%__fmtdispatch_209,%__fmtdispatch_149);
   ];
   block %__fmtdispatch_149 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4038f4:bv64;
      assert eq($_PC:bv64, 0x4038f4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208884_bv32:bv32 := 0x0:bv32;
      var var2_4208884_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           0xffffffffffffffcf:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)), 0xffffffcf:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          0xffffffcf:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        0xffffffcf:bv32), 0x1:bv32));
      goto (%__fmtdispatch_147);
   ];
   block %__fmtdispatch_147 [ goto (%__fmtdispatch_145,%__fmtdispatch_51); ];
   block %__fmtdispatch_51 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403974:bv64;
      assert eq($_PC:bv64, 0x403974:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209012_bv64:bv64 := 0x0:bv64;
      var var1_4209012_bv64:bv64 := $R21:bv64;
      var var2_4209012_bv64:bv64 := 0x0:bv64;
      var var2_4209012_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209012_bv64:bv64,
       0x68:bv64) 64;
      $R0:bv64 := var2_4209012_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209016_bv64:bv64 := 0x0:bv64;
      var var1_4209016_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvand(var1_4209016_bv64:bv64, 0x1:bv64);
      goto (%__fmtdispatch_49);
   ];
   block %__fmtdispatch_49 [ goto (%__fmtdispatch_47,%__fmtdispatch_43); ];
   block %__fmtdispatch_43 [
      guard eq(extract(1,0, extract(32,0, $R0:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403914:bv64;
      goto (%__fmtdispatch_41);
   ];
   block %__fmtdispatch_47 [
      guard boolnot(eq(extract(1,0, extract(32,0, $R0:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403980:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209024_bv64:bv64 := 0x0:bv64;
      var var1_4209024_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(var1_4209024_bv64:bv64, 0x80:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209028_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403858:bv64;
      goto (%__fmtdispatch_45);
   ];
   block %__fmtdispatch_45 [ goto (%__fmtdispatch_225); ];
   block %__fmtdispatch_145 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4038fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208892_bv32:bv32 := 0x0:bv32;
      var var2_4208892_bv32:bv32 := 0x0:bv32;
      var var2_4208892_bv32:bv32 := extract(32,0, $R19:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4208892_bv32:bv32, 0xffffffce:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208896_bv32:bv32 := 0x0:bv32;
      var var1_4208896_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32, bvand(var1_4208896_bv32:bv32, 0xffff:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208900_bv32:bv32 := 0x0:bv32;
      var var2_4208900_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xfffffffffffffff7:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xfffffff7:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffff7:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xfffffff7:bv32), 0x1:bv32));
      goto (%__fmtdispatch_143);
   ];
   block %__fmtdispatch_143 [ goto (%__fmtdispatch_141,%__fmtdispatch_137); ];
   block %__fmtdispatch_137 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40398c:bv64;
      goto (%__fmtdispatch_135);
   ];
   block %__fmtdispatch_141 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40390c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208908_bv64:bv64 := 0x0:bv64;
      var var1_4208908_bv64:bv64 := $R21:bv64;
      var var2_4208908_bv64:bv64 := 0x0:bv64;
      var var2_4208908_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208908_bv64:bv64,
       0x68:bv64) 64;
      $R0:bv64 := var2_4208908_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208912_bv64:bv64 := 0x0:bv64;
      var var1_4208912_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvand(var1_4208912_bv64:bv64, 0x1:bv64);
      goto (%__fmtdispatch_139);
   ];
   block %__fmtdispatch_139 [ goto (%__fmtdispatch_41); ];
   block %__fmtdispatch_41 [
      assert eq($_PC:bv64, 0x403914:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403930:bv64;
      goto (%__fmtdispatch_39);
   ];
   block %__fmtdispatch_39 [
      assert eq($_PC:bv64, 0x403930:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208944_bv32:bv32 := 0x0:bv32;
      var var1_4208944_bv32:bv32 := extract(32,0, $R3:bv64);
      var var2_4208944_bv32:bv32 := 0x0:bv32;
      var var2_4208944_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(var1_4208944_bv32:bv32, bvshl(var2_4208944_bv32:bv32, 0x2:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208948_bv32:bv32 := 0x0:bv32;
      var var1_4208948_bv32:bv32 := extract(32,0, $R19:bv64);
      var var2_4208948_bv32:bv32 := 0x0:bv32;
      var var2_4208948_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(var1_4208948_bv32:bv32, bvshl(var2_4208948_bv32:bv32, 0x1:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208952_bv32:bv32 := 0x0:bv32;
      var var2_4208952_bv32:bv32 := 0x0:bv32;
      var var2_4208952_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4208952_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32));
      goto (%__fmtdispatch_37,%__fmtdispatch_29);
   ];
   block %__fmtdispatch_29 [
      guard boolnot(eq(extract(32,0, $R22:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40391c:bv64;
      assert eq($_PC:bv64, 0x40391c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208924_bv64:bv64 := 0x0:bv64;
      var var1_4208924_bv64:bv64 := $R20:bv64;
      var var2_4208924_bv16:bv16 := 0x0:bv16;
      var var2_4208924_bv16:bv16 := load le $mem:(bv64->bv8) var1_4208924_bv64:bv64 16;
      $R19:bv64 := zero_extend(32, zero_extend(16, var2_4208924_bv16:bv16));
      $R20:bv64 := bvadd(var1_4208924_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208928_bv32:bv32 := 0x0:bv32;
      var var2_4208928_bv32:bv32 := 0x0:bv32;
      var var2_4208928_bv32:bv32 := extract(32,0, $R19:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4208928_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208932_bv32:bv32 := 0x0:bv32;
      var var1_4208932_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvand(var1_4208932_bv32:bv32, 0xffff:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208936_bv32:bv32 := 0x0:bv32;
      var var2_4208936_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xfffffffffffffff6:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xfffffff6:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xfffffff6:bv32), 0x1:bv32));
      goto (%__fmtdispatch_27);
   ];
   block %__fmtdispatch_27 [ goto (%__fmtdispatch_25,%__fmtdispatch_23); ];
   block %__fmtdispatch_23 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403954:bv64;
      goto (%__fmtdispatch_21);
   ];
   block %__fmtdispatch_25 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_39);
   ];
   block %__fmtdispatch_37 [
      guard eq(extract(32,0, $R22:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403940:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208960_bv64:bv64 := 0x0:bv64;
      var var1_4208960_bv64:bv64 := $R20:bv64;
      var var2_4208960_bv8:bv8 := 0x0:bv8;
      var var2_4208960_bv8:bv8 := load le $mem:(bv64->bv8) var1_4208960_bv64:bv64 8;
      $R19:bv64 := zero_extend(32, zero_extend(24, var2_4208960_bv8:bv8));
      $R20:bv64 := bvadd(var1_4208960_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208964_bv32:bv32 := 0x0:bv32;
      var var2_4208964_bv32:bv32 := 0x0:bv32;
      var var2_4208964_bv32:bv32 := extract(32,0, $R19:bv64);
      $R1:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4208964_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208968_bv32:bv32 := 0x0:bv32;
      var var1_4208968_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvand(var1_4208968_bv32:bv32, 0xffff:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208972_bv32:bv32 := 0x0:bv32;
      var var2_4208972_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R1:bv64)),
           0xfffffffffffffff6:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R1:bv64)), 0xfffffff6:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R1:bv64), 0xfffffff6:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R1:bv64),
        0xfffffff6:bv32), 0x1:bv32));
      goto (%__fmtdispatch_35);
   ];
   block %__fmtdispatch_35 [ goto (%__fmtdispatch_33,%__fmtdispatch_31); ];
   block %__fmtdispatch_31 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403930:bv64;
      goto (%__fmtdispatch_39);
   ];
   block %__fmtdispatch_33 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_21);
   ];
   block %__fmtdispatch_21 [
      assert eq($_PC:bv64, 0x403954:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208980_bv32:bv32 := 0x0:bv32;
      var var2_4208980_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R22:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R22:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R22:bv64),
          0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R22:bv64),
        0xffffffff:bv32), 0x1:bv32));
      var var1_4208984_bv64:bv64 := 0x0:bv64;
      var var1_4208984_bv64:bv64 := $R20:bv64;
      var var2_4208984_bv64:bv64 := 0x0:bv64;
      var var2_4208984_bv64:bv64 := $R20:bv64;
      goto (%__fmtdispatch_19,%__fmtdispatch_17);
   ];
   block %__fmtdispatch_17 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := var1_4208984_bv64:bv64;
      goto (%__fmtdispatch_15);
   ];
   block %__fmtdispatch_19 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := bvadd(var2_4208984_bv64:bv64, 0x1:bv64);
      goto (%__fmtdispatch_15);
   ];
   block %__fmtdispatch_15 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208988_bv64:bv64 := 0x0:bv64;
      var var2_4208988_bv64:bv64 := 0x0:bv64;
      var var2_4208988_bv64:bv64 := $R20:bv64;
      $R20:bv64 := bvadd(bvadd(var2_4208988_bv64:bv64, 0xfffffffffffffffd:bv64),
       0x1:bv64);
      goto (%__fmtdispatch_13);
   ];
   block %__fmtdispatch_209 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403870:bv64);
      goto (%__fmtdispatch_207);
   ];
   block %__fmtdispatch_207 [ goto (%__fmtdispatch_205,%__fmtdispatch_151); ];
   block %__fmtdispatch_151 [
      guard eq(extract(32,0, $R19:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a94:bv64;
      goto (%__fmtdispatch_55);
   ];
   block %__fmtdispatch_205 [
      guard boolnot(eq(extract(32,0, $R19:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403874:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208756_bv32:bv32 := 0x0:bv32;
      var var2_4208756_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           0xffffffffffffffd5:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)), 0xffffffd5:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          0xffffffd5:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        0xffffffd5:bv32), 0x1:bv32));
      goto (%__fmtdispatch_203);
   ];
   block %__fmtdispatch_203 [ goto (%__fmtdispatch_201,%__fmtdispatch_153); ];
   block %__fmtdispatch_153 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40398c:bv64;
      goto (%__fmtdispatch_135);
   ];
   block %__fmtdispatch_201 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40387c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208764_bv64:bv64 := 0x0:bv64;
      var var1_4208764_bv64:bv64 := $R21:bv64;
      var var2_4208764_bv32:bv32 := 0x0:bv32;
      var var2_4208764_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4208764_bv64:bv64,
       0x50:bv64) 32;
      $R1:bv64 := zero_extend(32, var2_4208764_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208768_bv64:bv64 := 0x0:bv64;
      var var2_4208768_bv64:bv64 := 0x0:bv64;
      var var2_4208768_bv64:bv64 := $R21:bv64;
      $R2:bv64 := bvadd(var2_4208768_bv64:bv64, 0x38:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208772_bv64:bv64 := 0x0:bv64;
      var var1_4208772_bv64:bv64 := $R21:bv64;
      var var2_4208772_bv64:bv64 := 0x0:bv64;
      var var2_4208772_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208772_bv64:bv64,
       0x38:bv64) 64;
      $R0:bv64 := var2_4208772_bv64:bv64;
      goto (%__fmtdispatch_199);
   ];
   block %__fmtdispatch_199 [ goto (%__fmtdispatch_197,%__fmtdispatch_195); ];
   block %__fmtdispatch_195 [
      guard eq(extract(32,31, extract(32,0, $R1:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a64:bv64;
      assert eq($_PC:bv64, 0x403a64:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209252_bv32:bv32 := 0x0:bv32;
      var var2_4209252_bv32:bv32 := 0x0:bv32;
      var var2_4209252_bv32:bv32 := extract(32,0, $R1:bv64);
      $R3:bv64 := zero_extend(32, bvadd(var2_4209252_bv32:bv32, 0x8:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209256_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R2:bv64, 0x18:bv64) extract(32,0, $R3:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209260_bv32:bv32 := 0x0:bv32;
      var var2_4209260_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R3:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R3:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R3:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R3:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__fmtdispatch_193);
   ];
   block %__fmtdispatch_193 [ goto (%__fmtdispatch_191,%__fmtdispatch_187); ];
   block %__fmtdispatch_187 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40388c:bv64;
      goto (%__fmtdispatch_185);
   ];
   block %__fmtdispatch_191 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403a74:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209268_bv64:bv64 := 0x0:bv64;
      var var1_4209268_bv64:bv64 := $R2:bv64;
      var var2_4209268_bv64:bv64 := 0x0:bv64;
      var var2_4209268_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209268_bv64:bv64,
       0x8:bv64) 64;
      $R0:bv64 := var2_4209268_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209272_bv64:bv64 := 0x0:bv64;
      var var2_4209272_bv64:bv64 := 0x0:bv64;
      var var2_4209272_bv64:bv64 := $R0:bv64;
      var var3_4209272_bv64:bv64 := 0x0:bv64;
      var var3_4209272_bv64:bv64 := $R1:bv64;
      $R0:bv64 := bvadd(var2_4209272_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4209272_bv64:bv64)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403898:bv64;
      goto (%__fmtdispatch_189);
   ];
   block %__fmtdispatch_189 [ goto (%__fmtdispatch_183); ];
   block %__fmtdispatch_197 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R1:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_185);
   ];
   block %__fmtdispatch_183 [
      assert eq($_PC:bv64, 0x403898:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208792_bv64:bv64 := 0x0:bv64;
      var var1_4208792_bv64:bv64 := $R0:bv64;
      var var2_4208792_bv32:bv32 := 0x0:bv32;
      var var2_4208792_bv32:bv32 := load le $mem:(bv64->bv8) var1_4208792_bv64:bv64 32;
      $R3:bv64 := zero_extend(32, var2_4208792_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208796_bv64:bv64 := 0x0:bv64;
      var var1_4208796_bv64:bv64 := $R21:bv64;
      var var2_4208796_bv64:bv64 := 0x0:bv64;
      var var2_4208796_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4208796_bv64:bv64,
       0x68:bv64) 64;
      $R0:bv64 := var2_4208796_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208800_bv64:bv64 := 0x0:bv64;
      var var1_4208800_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvand(var1_4208800_bv64:bv64, 0x1:bv64);
      goto (%__fmtdispatch_181,%__fmtdispatch_155);
   ];
   block %__fmtdispatch_155 [
      guard eq(extract(32,31, extract(32,0, $R3:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403960:bv64;
      goto (%__fmtdispatch_13);
   ];
   block %__fmtdispatch_181 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R3:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4038a8:bv64);
      goto (%__fmtdispatch_179);
   ];
   block %__fmtdispatch_179 [ goto (%__fmtdispatch_177,%__fmtdispatch_159); ];
   block %__fmtdispatch_159 [
      guard eq(extract(3,2, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a0c:bv64;
      assert eq($_PC:bv64, 0x403a0c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209164_bv64:bv64 := 0x0:bv64;
      var var1_4209164_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvand(var1_4209164_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209168_bv32:bv32 := 0x0:bv32;
      var var1_4209168_bv32:bv32 := 0x0:bv32;
      var var2_4209168_bv32:bv32 := 0x0:bv32;
      var var2_4209168_bv32:bv32 := extract(32,0, $R3:bv64);
      $R3:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4209168_bv32:bv32,
        bvnot(bvshl(var2_4209168_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209172_bv64:bv64 := 0x0:bv64;
      var var1_4209172_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(var1_4209172_bv64:bv64, 0x2:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403960:bv64;
      goto (%__fmtdispatch_157);
   ];
   block %__fmtdispatch_157 [ goto (%__fmtdispatch_13); ];
   block %__fmtdispatch_177 [
      guard boolnot(eq(extract(3,2, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4038ac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208812_bv64:bv64 := 0x0:bv64;
      var var1_4208812_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvand(var1_4208812_bv64:bv64, 0xfffffffffffffffb:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208816_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x60:bv64) 0x0:bv32 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208820_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64;
      goto (%__fmtdispatch_175);
   ];
   block %__fmtdispatch_175 [ goto (%__fmtdispatch_173,%__fmtdispatch_169); ];
   block %__fmtdispatch_169 [
      guard boolnot(eq(extract(32,0, $R22:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40385c:bv64;
      goto (%__fmtdispatch_167);
   ];
   block %__fmtdispatch_173 [
      guard eq(extract(32,0, $R22:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4038bc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_171);
   ];
   block %__fmtdispatch_171 [ goto (%__fmtdispatch_219); ];
   block %__fmtdispatch_185 [
      assert eq($_PC:bv64, 0x40388c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208780_bv64:bv64 := 0x0:bv64;
      var var2_4208780_bv64:bv64 := 0x0:bv64;
      var var2_4208780_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvadd(var2_4208780_bv64:bv64, 0xb:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208784_bv64:bv64 := 0x0:bv64;
      var var1_4208784_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvand(var1_4208784_bv64:bv64, 0xfffffffffffffff8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208788_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x38:bv64) $R1:bv64 64;
      goto (%__fmtdispatch_183);
   ];
   block %__fmtdispatch_13 [
      assert eq($_PC:bv64, 0x403960:bv64);
      goto (%__fmtdispatch_11,%__fmtdispatch_7);
   ];
   block %__fmtdispatch_7 [
      guard eq($R2:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039fc:bv64;
      assert eq($_PC:bv64, 0x4039fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209148_bv64:bv64 := 0x0:bv64;
      var var1_4209148_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(var1_4209148_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209152_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x5c:bv64) extract(32,0, $R3:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209156_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403858:bv64;
      goto (%__fmtdispatch_5);
   ];
   block %__fmtdispatch_5 [ goto (%__fmtdispatch_225); ];
   block %__fmtdispatch_11 [
      guard boolnot(eq($R2:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403964:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208996_bv64:bv64 := 0x0:bv64;
      var var1_4208996_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(var1_4208996_bv64:bv64, 0x4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209000_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x60:bv64) extract(32,0, $R3:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209004_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403858:bv64;
      goto (%__fmtdispatch_9);
   ];
   block %__fmtdispatch_9 [ goto (%__fmtdispatch_225); ];
   block %__fmtdispatch_53 [
      assert eq($_PC:bv64, 0x4039ec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209132_bv64:bv64 := 0x0:bv64;
      var var1_4209132_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4209132_bv64:bv64 := 0x0:bv64;
      var var2_4209132_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4209132_bv64:bv64;
      $R20:bv64 := var2_4209132_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209136_bv64:bv64 := 0x0:bv64;
      var var1_4209136_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4209136_bv64:bv64 := 0x0:bv64;
      var var2_4209136_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4209136_bv64:bv64;
      $R22:bv64 := var2_4209136_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209140_bv64:bv64 := 0x0:bv64;
      var var1_4209140_bv64:bv64 := $R31:bv64;
      var var2_4209140_bv64:bv64 := 0x0:bv64;
      var var2_4209140_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4209140_bv64:bv64 := 0x0:bv64;
      var var3_4209140_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4209140_bv64:bv64;
      $R30:bv64 := var3_4209140_bv64:bv64;
      $R31:bv64 := bvadd(var1_4209140_bv64:bv64, 0x50:bv64);
      var var1_4209144_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fmtdispatch_basil_return_1);
   ];
   block %__fmtdispatch_basil_return_1 [ nop; return; ];
   block %__fmtdispatch_55 [
      assert eq($_PC:bv64, 0x403a94:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039ec:bv64;
      goto (%__fmtdispatch_53);
   ];
   block %__fmtdispatch_135 [
      assert eq($_PC:bv64, 0x40398c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209040_bv64:bv64 := 0x0:bv64;
      var var2_4209040_bv64:bv64 := 0x0:bv64;
      var var2_4209040_bv64:bv64 := $R2:bv64;
      $R0:bv64 := bvadd(var2_4209040_bv64:bv64, 0x708:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209044_bv64:bv64 := 0x0:bv64;
      var var2_4209044_bv64:bv64 := 0x0:bv64;
      var var2_4209044_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvadd(var2_4209044_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209048_bv64:bv64 := 0x0:bv64;
      var var1_4209048_bv64:bv64 := $R2:bv64;
      var var2_4209048_bv32:bv32 := 0x0:bv32;
      var var2_4209048_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4209048_bv64:bv64,
       0x708:bv64) 32;
      $R2:bv64 := zero_extend(32, var2_4209048_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209052_bv64:bv64 := 0x0:bv64;
      var var2_4209052_bv64:bv64 := 0x0:bv64;
      var var2_4209052_bv64:bv64 := $R0:bv64;
      var var3_4209052_bv64:bv64 := 0x0:bv64;
      var var3_4209052_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(var2_4209052_bv64:bv64,
       sign_extend(28, bvconcat(extract(32,0, var3_4209052_bv64:bv64), 0x0:bv4)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209056_bv64:bv64 := 0x0:bv64;
      var var2_4209056_bv64:bv64 := 0x0:bv64;
      var var2_4209056_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(var2_4209056_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209060_bv64:bv64 := 0x0:bv64;
      var var2_4209060_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtdispatch_133,%__fmtdispatch_129);
   ];
   block %__fmtdispatch_129 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039bc:bv64;
      goto (%__fmtdispatch_127);
   ];
   block %__fmtdispatch_127 [
      assert eq($_PC:bv64, 0x4039bc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209084_bv64:bv64 := 0x0:bv64;
      var var1_4209084_bv64:bv64 := $R1:bv64;
      var var2_4209084_bv32:bv32 := 0x0:bv32;
      var var2_4209084_bv32:bv32 := load le $mem:(bv64->bv8) var1_4209084_bv64:bv64 32;
      $R0:bv64 := zero_extend(32, var2_4209084_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209088_bv32:bv32 := 0x0:bv32;
      var var2_4209088_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtdispatch_125,%__fmtdispatch_115);
   ];
   block %__fmtdispatch_115 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039b0:bv64;
      assert eq($_PC:bv64, 0x4039b0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209072_bv64:bv64 := 0x0:bv64;
      var var2_4209072_bv64:bv64 := 0x0:bv64;
      var var2_4209072_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvadd(var2_4209072_bv64:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209076_bv64:bv64 := 0x0:bv64;
      var var2_4209076_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           sign_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64),
           zero_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64,
          bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64,
        bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%__fmtdispatch_113);
   ];
   block %__fmtdispatch_113 [ goto (%__fmtdispatch_111,%__fmtdispatch_109); ];
   block %__fmtdispatch_109 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a1c:bv64;
      goto (%__fmtdispatch_107);
   ];
   block %__fmtdispatch_111 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_127);
   ];
   block %__fmtdispatch_125 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_123);
   ];
   block %__fmtdispatch_123 [
      assert eq($_PC:bv64, 0x4039c8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209096_bv64:bv64 := 0x0:bv64;
      var var1_4209096_bv64:bv64 := $R1:bv64;
      var var2_4209096_bv64:bv64 := 0x0:bv64;
      var var2_4209096_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209096_bv64:bv64,
       0x8:bv64) 64;
      $R0:bv64 := var2_4209096_bv64:bv64;
      goto (%__fmtdispatch_121,%__fmtdispatch_117);
   ];
   block %__fmtdispatch_117 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039c8:bv64;
      goto (%__fmtdispatch_123);
   ];
   block %__fmtdispatch_121 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4039d0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209104_bv64:bv64 := 0x0:bv64;
      var var1_4209104_bv64:bv64 := $R1:bv64;
      var var2_4209104_bv64:bv64 := 0x0:bv64;
      var var2_4209104_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209104_bv64:bv64,
       0x8:bv64) 64;
      $R1:bv64 := var2_4209104_bv64:bv64;
      goto (%__fmtdispatch_119);
   ];
   block %__fmtdispatch_119 [ goto (%__fmtdispatch_75); ];
   block %__fmtdispatch_133 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4039ac:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a1c:bv64;
      goto (%__fmtdispatch_131);
   ];
   block %__fmtdispatch_131 [ goto (%__fmtdispatch_107); ];
   block %__fmtdispatch_75 [
      assert eq($_PC:bv64, 0x4039d4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209108_bv64:bv64 := 0x0:bv64;
      var var1_4209108_bv64:bv64 := 0x0:bv64;
      var var2_4209108_bv64:bv64 := 0x0:bv64;
      var var2_4209108_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4209108_bv64:bv64,
       bvshl(var2_4209108_bv64:bv64, 0x0:bv64));
      var var1_4209112_bv64:bv64 := 0x0:bv64;
      var var1_4209112_bv64:bv64 := $R1:bv64;
      $R30:bv64 := 0x4039dc:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4209112_bv64:bv64;
      assert boolor(eq(var1_4209112_bv64:bv64, 0x403710:bv64),
       eq(var1_4209112_bv64:bv64, 0x4035f0:bv64));
      goto (%__fmtdispatch_73,%__fmtdispatch_71);
   ];
   block %__fmtdispatch_71 [
      assume eq(var1_4209112_bv64:bv64, 0x403710:bv64);
      
      call @__badfmt_4208400();
      goto (%__fmtdispatch_69);
   ];
   block %__fmtdispatch_73 [
      assume eq(var1_4209112_bv64:bv64, 0x4035f0:bv64);
      
      call @__flagfmt_4208112();
      goto (%__fmtdispatch_69);
   ];
   block %__fmtdispatch_69 [
      assert eq($_PC:bv64, 0x4039dc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209116_bv32:bv32 := 0x0:bv32;
      var var2_4209116_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%__fmtdispatch_67,%__fmtdispatch_57);
   ];
   block %__fmtdispatch_57 [
      guard boolnot(eq($NF:bv1, $VF:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a94:bv64;
      goto (%__fmtdispatch_55);
   ];
   block %__fmtdispatch_67 [
      guard eq($NF:bv1, $VF:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4039e4:bv64);
      goto (%__fmtdispatch_65);
   ];
   block %__fmtdispatch_65 [ goto (%__fmtdispatch_63,%__fmtdispatch_59); ];
   block %__fmtdispatch_59 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403858:bv64;
      goto (%__fmtdispatch_225);
   ];
   block %__fmtdispatch_63 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4039e8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209128_bv64:bv64 := 0x0:bv64;
      var var1_4209128_bv64:bv64 := 0x0:bv64;
      var var2_4209128_bv64:bv64 := 0x0:bv64;
      var var2_4209128_bv64:bv64 := $R20:bv64;
      $R0:bv64 := bvor(var1_4209128_bv64:bv64,
       bvshl(var2_4209128_bv64:bv64, 0x0:bv64));
      goto (%__fmtdispatch_61);
   ];
   block %__fmtdispatch_61 [ goto (%__fmtdispatch_53); ];
   block %__fmtdispatch_107 [
      assert eq($_PC:bv64, 0x403a1c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64;
      $R30:bv64 := 0x403a24:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c40:bv64;
      
      call @__fmtlock_4209728();
      goto (%__fmtdispatch_105);
   ];
   block %__fmtdispatch_105 [
      assert eq($_PC:bv64, 0x403a24:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209192_bv64:bv64 := 0x0:bv64;
      var var2_4209192_bv64:bv64 := 0x0:bv64;
      var var2_4209192_bv64:bv64 := $R0:bv64;
      $R23:bv64 := bvadd(var2_4209192_bv64:bv64, 0xd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209196_bv64:bv64 := 0x0:bv64;
      var var1_4209196_bv64:bv64 := $R0:bv64;
      var var2_4209196_bv32:bv32 := 0x0:bv32;
      var var2_4209196_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4209196_bv64:bv64,
       0xd0:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4209196_bv32:bv32);
      goto (%__fmtdispatch_103,%__fmtdispatch_99);
   ];
   block %__fmtdispatch_99 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a40:bv64;
      goto (%__fmtdispatch_97);
   ];
   block %__fmtdispatch_97 [
      assert eq($_PC:bv64, 0x403a40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209216_bv32:bv32 := 0x0:bv32;
      var var2_4209216_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64),
           bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        bvnot(bvshl(extract(32,0, $R0:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%__fmtdispatch_95,%__fmtdispatch_87);
   ];
   block %__fmtdispatch_87 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a38:bv64;
      assert eq($_PC:bv64, 0x403a38:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209208_bv64:bv64 := 0x0:bv64;
      var var1_4209208_bv64:bv64 := $R23:bv64;
      var var2_4209208_bv32:bv32 := 0x0:bv32;
      var var2_4209208_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4209208_bv64:bv64,
       0x10:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4209208_bv32:bv32);
      $R23:bv64 := bvadd(var1_4209208_bv64:bv64, 0x10:bv64);
      goto (%__fmtdispatch_85);
   ];
   block %__fmtdispatch_85 [ goto (%__fmtdispatch_83,%__fmtdispatch_81); ];
   block %__fmtdispatch_81 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a80:bv64;
      goto (%__fmtdispatch_79);
   ];
   block %__fmtdispatch_83 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_97);
   ];
   block %__fmtdispatch_95 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403a48:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209224_bv64:bv64 := 0x0:bv64;
      var var1_4209224_bv64:bv64 := $R23:bv64;
      var var2_4209224_bv64:bv64 := 0x0:bv64;
      var var2_4209224_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209224_bv64:bv64,
       0x8:bv64) 64;
      $R1:bv64 := var2_4209224_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209228_bv32:bv32 := 0x0:bv32;
      var var1_4209228_bv32:bv32 := 0x0:bv32;
      var var2_4209228_bv32:bv32 := 0x0:bv32;
      var var2_4209228_bv32:bv32 := extract(32,0, $R19:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4209228_bv32:bv32, bvshl(var2_4209228_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x403a54:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403750:bv64;
      
      call @__fmtinstall_4208464();
      goto (%__fmtdispatch_93);
   ];
   block %__fmtdispatch_93 [ goto (%__fmtdispatch_91); ];
   block %__fmtdispatch_91 [
      assert eq($_PC:bv64, 0x403a54:bv64);
      $R30:bv64 := 0x403a58:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c50:bv64;
      
      call @__fmtunlock_4209744();
      goto (%__fmtdispatch_89);
   ];
   block %__fmtdispatch_89 [
      assert eq($_PC:bv64, 0x403a58:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209240_bv64:bv64 := 0x0:bv64;
      var var1_4209240_bv64:bv64 := $R23:bv64;
      var var2_4209240_bv64:bv64 := 0x0:bv64;
      var var2_4209240_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4209240_bv64:bv64,
       0x8:bv64) 64;
      $R1:bv64 := var2_4209240_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209244_bv64:bv64 := 0x0:bv64;
      var var1_4209244_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      $R23:bv64 := var1_4209244_bv64:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039d4:bv64;
      goto (%__fmtdispatch_75);
   ];
   block %__fmtdispatch_103 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x403a34:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403a80:bv64;
      goto (%__fmtdispatch_101);
   ];
   block %__fmtdispatch_101 [ goto (%__fmtdispatch_79); ];
   block %__fmtdispatch_79 [
      assert eq($_PC:bv64, 0x403a80:bv64);
      $R30:bv64 := 0x403a84:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c50:bv64;
      
      call @__fmtunlock_4209744();
      goto (%__fmtdispatch_77);
   ];
   block %__fmtdispatch_77 [
      assert eq($_PC:bv64, 0x403a84:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209284_bv64:bv64 := 0x0:bv64;
      var var1_4209284_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      $R23:bv64 := var1_4209284_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x403000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4209292_bv64:bv64 := 0x0:bv64;
      var var2_4209292_bv64:bv64 := 0x0:bv64;
      var var2_4209292_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvadd(var2_4209292_bv64:bv64, 0x710:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4039d4:bv64;
      goto (%__fmtdispatch_75);
   ];
   block %__fmtdispatch_219 [
      assert eq($_PC:bv64, 0x4038c0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208832_bv64:bv64 := 0x0:bv64;
      var var1_4208832_bv64:bv64 := 0x0:bv64;
      var var2_4208832_bv64:bv64 := 0x0:bv64;
      var var2_4208832_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvor(var1_4208832_bv64:bv64,
       bvshl(var2_4208832_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208836_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x4e:bv64);
      $R30:bv64 := 0x4038cc:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c60:bv64;
      
      call @chartorune_4209760();
      goto (%__fmtdispatch_217);
   ];
   block %__fmtdispatch_217 [
      assert eq($_PC:bv64, 0x4038cc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208844_bv16:bv16 := 0x0:bv16;
      var var1_4208844_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x4e:bv64) 16;
      $R19:bv64 := zero_extend(32, zero_extend(16, var1_4208844_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208848_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R21:bv64, 0x58:bv64) extract(32,0, $R19:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208852_bv64:bv64 := 0x0:bv64;
      var var2_4208852_bv64:bv64 := 0x0:bv64;
      var var2_4208852_bv64:bv64 := $R20:bv64;
      var var3_4208852_bv64:bv64 := 0x0:bv64;
      var var3_4208852_bv64:bv64 := $R0:bv64;
      $R20:bv64 := bvadd(var2_4208852_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4208852_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4208856_bv32:bv32 := 0x0:bv32;
      var var2_4208856_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R19:bv64)),
           0xffffffffffffffd1:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R19:bv64)), 0xffffffd1:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R19:bv64),
          0xffffffd1:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R19:bv64),
        0xffffffd1:bv32), 0x1:bv32));
      goto (%__fmtdispatch_215,%__fmtdispatch_213);
   ];
   block %__fmtdispatch_213 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40386c:bv64;
      goto (%__fmtdispatch_211);
   ];
   block %__fmtdispatch_215 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%__fmtdispatch_161);
   ]
];
proc @dofmt_4202176()  -> () { .address = 4202176; .name = "dofmt";
    .returnBlock = "dofmt_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401ec0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %dofmt_entry [
      assert eq($_PC:bv64, 0x401ec0:bv64);
      $_PC:bv64 := 0x401ec0:bv64;
      assert eq($_PC:bv64, 0x401ec0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202176_bv64:bv64 := 0x0:bv64;
      var var1_4202176_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffa0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffa0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4202176_bv64:bv64, 0xffffffffffffffa0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202180_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202188_bv64:bv64 := 0x0:bv64;
      var var1_4202188_bv64:bv64 := 0x0:bv64;
      var var2_4202188_bv64:bv64 := 0x0:bv64;
      var var2_4202188_bv64:bv64 := $R1:bv64;
      $R20:bv64 := bvor(var1_4202188_bv64:bv64,
       bvshl(var2_4202188_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) $R24:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202196_bv64:bv64 := 0x0:bv64;
      var var1_4202196_bv64:bv64 := 0x0:bv64;
      var var2_4202196_bv64:bv64 := 0x0:bv64;
      var var2_4202196_bv64:bv64 := $R0:bv64;
      $R23:bv64 := bvor(var1_4202196_bv64:bv64,
       bvshl(var2_4202196_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202200_bv64:bv64 := 0x0:bv64;
      var var1_4202200_bv64:bv64 := $R0:bv64;
      var var2_4202200_bv32:bv32 := 0x0:bv32;
      var var2_4202200_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202200_bv64:bv64,
       0x30:bv64) 32;
      $R24:bv64 := zero_extend(32, var2_4202200_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x40:bv64) $R25:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_165);
   ];
   block %dofmt_165 [
      assert eq($_PC:bv64, 0x401ee8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202216_bv64:bv64 := 0x0:bv64;
      var var1_4202216_bv64:bv64 := $R23:bv64;
      var var2_4202216_bv8:bv8 := 0x0:bv8;
      var var2_4202216_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202216_bv64:bv64 8;
      $R0:bv64 := zero_extend(32, zero_extend(24, var2_4202216_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202220_bv64:bv64 := 0x0:bv64;
      var var1_4202220_bv64:bv64 := $R20:bv64;
      var var2_4202220_bv8:bv8 := 0x0:bv8;
      var var2_4202220_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202220_bv64:bv64 8;
      $R21:bv64 := zero_extend(32, zero_extend(24, var2_4202220_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202224_bv64:bv64 := 0x0:bv64;
      var var1_4202224_bv64:bv64 := $R23:bv64;
      var var2_4202224_bv64:bv64 := 0x0:bv64;
      var var2_4202224_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202224_bv64:bv64,
       0x10:bv64) 64;
      var var3_4202224_bv64:bv64 := 0x0:bv64;
      var var3_4202224_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(bvadd(var1_4202224_bv64:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var2_4202224_bv64:bv64;
      $R25:bv64 := var3_4202224_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202228_bv32:bv32 := 0x0:bv32;
      var var1_4202228_bv32:bv32 := 0x0:bv32;
      var var2_4202228_bv32:bv32 := 0x0:bv32;
      var var2_4202228_bv32:bv32 := extract(32,0, $R21:bv64);
      $R22:bv64 := zero_extend(32,
      bvor(var1_4202228_bv32:bv32, bvshl(var2_4202228_bv32:bv32, 0x0:bv32)));
      goto (%dofmt_163,%dofmt_103);
   ];
   block %dofmt_103 [
      guard eq(extract(32,0, $R0:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f94:bv64;
      assert eq($_PC:bv64, 0x401f94:bv64);
      goto (%dofmt_101);
   ];
   block %dofmt_101 [ goto (%dofmt_99,%dofmt_93); ];
   block %dofmt_93 [
      guard boolnot(eq(extract(32,0, $R21:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401fbc:bv64;
      goto (%dofmt_91);
   ];
   block %dofmt_91 [
      assert eq($_PC:bv64, 0x401fbc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202428_bv32:bv32 := 0x0:bv32;
      var var2_4202428_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           0xffffffffffffffda:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)), 0xffffffda:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          0xffffffda:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        0xffffffda:bv32), 0x1:bv32));
      goto (%dofmt_89,%dofmt_15);
   ];
   block %dofmt_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402094:bv64;
      assert eq($_PC:bv64, 0x402094:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202644_bv64:bv64 := 0x0:bv64;
      var var1_4202644_bv64:bv64 := $R23:bv64;
      var var2_4202644_bv64:bv64 := 0x0:bv64;
      var var2_4202644_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202644_bv64:bv64,
       0x10:bv64) 64;
      $R2:bv64 := var2_4202644_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202648_bv64:bv64 := 0x0:bv64;
      var var2_4202648_bv64:bv64 := 0x0:bv64;
      var var2_4202648_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvadd(var2_4202648_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202652_bv64:bv64 := 0x0:bv64;
      var var1_4202652_bv64:bv64 := $R23:bv64;
      var var2_4202652_bv32:bv32 := 0x0:bv32;
      var var2_4202652_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202652_bv64:bv64,
       0x30:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4202652_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202656_bv64:bv64 := 0x0:bv64;
      var var1_4202656_bv64:bv64 := $R19:bv64;
      var var2_4202656_bv64:bv64 := 0x0:bv64;
      var var2_4202656_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(bvadd(var1_4202656_bv64:bv64,
        bvnot(bvshl(var2_4202656_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202660_bv32:bv32 := 0x0:bv32;
      var var1_4202660_bv32:bv32 := extract(32,0, $R0:bv64);
      var var2_4202660_bv32:bv32 := 0x0:bv32;
      var var2_4202660_bv32:bv32 := extract(32,0, $R2:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(var1_4202660_bv32:bv32, bvshl(var2_4202660_bv32:bv32, 0x0:bv32)));
      goto (%dofmt_13);
   ];
   block %dofmt_13 [ goto (%dofmt_11); ];
   block %dofmt_89 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401fc4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202436_bv32:bv32 := 0x0:bv32;
      var var2_4202436_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R21:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R21:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R21:bv64),
          0xffffff80:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R21:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%dofmt_87);
   ];
   block %dofmt_87 [ goto (%dofmt_85,%dofmt_45); ];
   block %dofmt_45 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f9c:bv64;
      assert eq($_PC:bv64, 0x401f9c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202396_bv64:bv64 := 0x0:bv64;
      var var2_4202396_bv64:bv64 := 0x0:bv64;
      var var2_4202396_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvadd(var2_4202396_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202400_bv64:bv64 := 0x0:bv64;
      var var2_4202400_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R0:bv64),
           sign_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R0:bv64),
           zero_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64,
          bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R0:bv64,
        bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%dofmt_43);
   ];
   block %dofmt_43 [ goto (%dofmt_41,%dofmt_39); ];
   block %dofmt_39 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402050:bv64;
      assert eq($_PC:bv64, 0x402050:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202576_bv64:bv64 := 0x0:bv64;
      var var1_4202576_bv64:bv64 := 0x0:bv64;
      var var2_4202576_bv64:bv64 := 0x0:bv64;
      var var2_4202576_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4202576_bv64:bv64,
       bvshl(var2_4202576_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202580_bv64:bv64 := 0x0:bv64;
      var var1_4202580_bv64:bv64 := 0x0:bv64;
      var var2_4202580_bv64:bv64 := 0x0:bv64;
      var var2_4202580_bv64:bv64 := $R23:bv64;
      $R0:bv64 := bvor(var1_4202580_bv64:bv64,
       bvshl(var2_4202580_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x1:bv64;
      $R30:bv64 := 0x402060:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e30:bv64;
      
      call @__fmtflush_4202032();
      goto (%dofmt_37);
   ];
   block %dofmt_37 [ goto (%dofmt_35); ];
   block %dofmt_35 [
      assert eq($_PC:bv64, 0x402060:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202592_bv64:bv64 := 0x0:bv64;
      var var1_4202592_bv64:bv64 := 0x0:bv64;
      var var2_4202592_bv64:bv64 := 0x0:bv64;
      var var2_4202592_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4202592_bv64:bv64,
       bvshl(var2_4202592_bv64:bv64, 0x0:bv64));
      goto (%dofmt_33,%dofmt_17);
   ];
   block %dofmt_17 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020c4:bv64;
      goto (%dofmt_5);
   ];
   block %dofmt_33 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x402068:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202600_bv64:bv64 := 0x0:bv64;
      var var1_4202600_bv64:bv64 := $R23:bv64;
      var var2_4202600_bv64:bv64 := 0x0:bv64;
      var var2_4202600_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202600_bv64:bv64,
       0x18:bv64) 64;
      $R25:bv64 := var2_4202600_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202604_bv64:bv64 := 0x0:bv64;
      var var2_4202604_bv64:bv64 := 0x0:bv64;
      var var2_4202604_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4202604_bv64:bv64, 0x1:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401fa8:bv64;
      goto (%dofmt_31);
   ];
   block %dofmt_31 [ goto (%dofmt_29); ];
   block %dofmt_41 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_29);
   ];
   block %dofmt_29 [
      assert eq($_PC:bv64, 0x401fa8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202408_bv64:bv64 := 0x0:bv64;
      var var2_4202408_bv64:bv64 := 0x0:bv64;
      var var2_4202408_bv64:bv64 := $R20:bv64;
      $R20:bv64 := bvadd(var2_4202408_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202412_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R19:bv64 extract(8,0, $R21:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202416_bv64:bv64 := 0x0:bv64;
      var var1_4202416_bv64:bv64 := 0x0:bv64;
      var var2_4202416_bv64:bv64 := 0x0:bv64;
      var var2_4202416_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4202416_bv64:bv64,
       bvshl(var2_4202416_bv64:bv64, 0x0:bv64));
      goto (%dofmt_27);
   ];
   block %dofmt_85 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401fcc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202444_bv64:bv64 := 0x0:bv64;
      var var1_4202444_bv64:bv64 := 0x0:bv64;
      var var2_4202444_bv64:bv64 := 0x0:bv64;
      var var2_4202444_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvor(var1_4202444_bv64:bv64,
       bvshl(var2_4202444_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202448_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x5e:bv64);
      $R30:bv64 := 0x401fd8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c60:bv64;
      
      call @chartorune_4209760();
      goto (%dofmt_83);
   ];
   block %dofmt_83 [ goto (%dofmt_81); ];
   block %dofmt_81 [
      assert eq($_PC:bv64, 0x401fd8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202456_bv32:bv32 := 0x0:bv32;
      var var1_4202456_bv32:bv32 := 0x0:bv32;
      var var2_4202456_bv32:bv32 := 0x0:bv32;
      var var2_4202456_bv32:bv32 := extract(32,0, $R0:bv64);
      $R21:bv64 := zero_extend(32,
      bvor(var1_4202456_bv32:bv32, bvshl(var2_4202456_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202460_bv64:bv64 := 0x0:bv64;
      var var2_4202460_bv64:bv64 := 0x0:bv64;
      var var2_4202460_bv64:bv64 := $R19:bv64;
      var var3_4202460_bv64:bv64 := 0x0:bv64;
      var var3_4202460_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4202460_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4202460_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202464_bv64:bv64 := 0x0:bv64;
      var var2_4202464_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R25:bv64),
           sign_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R25:bv64),
           zero_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R25:bv64,
          bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R25:bv64,
        bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%dofmt_79,%dofmt_77);
   ];
   block %dofmt_77 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402074:bv64;
      assert eq($_PC:bv64, 0x402074:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202612_bv64:bv64 := 0x0:bv64;
      var var1_4202612_bv64:bv64 := 0x0:bv64;
      var var2_4202612_bv64:bv64 := 0x0:bv64;
      var var2_4202612_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4202612_bv64:bv64,
       bvshl(var2_4202612_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202616_bv32:bv32 := 0x0:bv32;
      var var1_4202616_bv32:bv32 := 0x0:bv32;
      var var2_4202616_bv32:bv32 := 0x0:bv32;
      var var2_4202616_bv32:bv32 := extract(32,0, $R21:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(var1_4202616_bv32:bv32, bvshl(var2_4202616_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202620_bv64:bv64 := 0x0:bv64;
      var var1_4202620_bv64:bv64 := 0x0:bv64;
      var var2_4202620_bv64:bv64 := 0x0:bv64;
      var var2_4202620_bv64:bv64 := $R23:bv64;
      $R0:bv64 := bvor(var1_4202620_bv64:bv64,
       bvshl(var2_4202620_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x402084:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e30:bv64;
      
      call @__fmtflush_4202032();
      goto (%dofmt_75);
   ];
   block %dofmt_75 [ goto (%dofmt_73); ];
   block %dofmt_73 [
      assert eq($_PC:bv64, 0x402084:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202628_bv64:bv64 := 0x0:bv64;
      var var1_4202628_bv64:bv64 := 0x0:bv64;
      var var2_4202628_bv64:bv64 := 0x0:bv64;
      var var2_4202628_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4202628_bv64:bv64,
       bvshl(var2_4202628_bv64:bv64, 0x0:bv64));
      goto (%dofmt_71,%dofmt_47);
   ];
   block %dofmt_47 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020c4:bv64;
      goto (%dofmt_5);
   ];
   block %dofmt_71 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40208c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202636_bv64:bv64 := 0x0:bv64;
      var var1_4202636_bv64:bv64 := $R23:bv64;
      var var2_4202636_bv64:bv64 := 0x0:bv64;
      var var2_4202636_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202636_bv64:bv64,
       0x18:bv64) 64;
      $R25:bv64 := var2_4202636_bv64:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401fe8:bv64;
      goto (%dofmt_69);
   ];
   block %dofmt_69 [ goto (%dofmt_67); ];
   block %dofmt_79 [
      guard eq($CF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_67);
   ];
   block %dofmt_67 [
      assert eq($_PC:bv64, 0x401fe8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202472_bv32:bv32 := 0x0:bv32;
      var var1_4202472_bv32:bv32 := 0x0:bv32;
      var var2_4202472_bv32:bv32 := 0x0:bv32;
      var var2_4202472_bv32:bv32 := extract(32,0, $R21:bv64);
      $R4:bv64 := zero_extend(32,
      bvor(var1_4202472_bv32:bv32, bvshl(var2_4202472_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x0:bv64;
      goto (%dofmt_65,%dofmt_49);
   ];
   block %dofmt_49 [
      guard eq(extract(32,0, $R21:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401fb4:bv64;
      goto (%dofmt_27);
   ];
   block %dofmt_65 [
      guard boolnot(eq(extract(32,0, $R21:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401ff4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_63);
   ];
   block %dofmt_63 [ goto (%dofmt_61); ];
   block %dofmt_61 [
      assert eq($_PC:bv64, 0x401ff8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202488_bv64:bv64 := 0x0:bv64;
      var var1_4202488_bv64:bv64 := $R3:bv64;
      var var2_4202488_bv64:bv64 := 0x0:bv64;
      var var2_4202488_bv64:bv64 := $R20:bv64;
      var var3_4202488_bv8:bv8 := 0x0:bv8;
      var var3_4202488_bv8:bv8 := load le $mem:(bv64->bv8) bvadd(var2_4202488_bv64:bv64,
       var1_4202488_bv64:bv64) 8;
      $R1:bv64 := zero_extend(32, zero_extend(24, var3_4202488_bv8:bv8));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202492_bv64:bv64 := 0x0:bv64;
      var var2_4202492_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, $R3:bv64) extract(8,0, $R1:bv64) 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202496_bv64:bv64 := 0x0:bv64;
      var var2_4202496_bv64:bv64 := 0x0:bv64;
      var var2_4202496_bv64:bv64 := $R3:bv64;
      $R3:bv64 := bvadd(var2_4202496_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202500_bv64:bv64 := 0x0:bv64;
      var var2_4202500_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R4:bv64),
           sign_extend(64, bvnot(bvshl($R3:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R4:bv64),
           zero_extend(64, bvnot(bvshl($R3:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64,
          bvnot(bvshl($R3:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R4:bv64,
        bvnot(bvshl($R3:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%dofmt_59,%dofmt_51);
   ];
   block %dofmt_51 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ff8:bv64;
      goto (%dofmt_61);
   ];
   block %dofmt_59 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40200c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202508_bv64:bv64 := 0x0:bv64;
      var var1_4202508_bv64:bv64 := $R20:bv64;
      var var2_4202508_bv64:bv64 := 0x0:bv64;
      var var2_4202508_bv64:bv64 := $R4:bv64;
      $R20:bv64 := bvadd(var1_4202508_bv64:bv64,
       bvshl(var2_4202508_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202512_bv64:bv64 := 0x0:bv64;
      var var1_4202512_bv64:bv64 := $R19:bv64;
      var var2_4202512_bv64:bv64 := 0x0:bv64;
      var var2_4202512_bv64:bv64 := $R4:bv64;
      $R19:bv64 := bvadd(var1_4202512_bv64:bv64,
       bvshl(var2_4202512_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202516_bv64:bv64 := 0x0:bv64;
      var var1_4202516_bv64:bv64 := $R20:bv64;
      var var2_4202516_bv8:bv8 := 0x0:bv8;
      var var2_4202516_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202516_bv64:bv64 8;
      $R21:bv64 := zero_extend(32, zero_extend(24, var2_4202516_bv8:bv8));
      goto (%dofmt_57);
   ];
   block %dofmt_57 [ goto (%dofmt_55,%dofmt_53); ];
   block %dofmt_53 [
      guard boolnot(eq(extract(32,0, $R21:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401fbc:bv64;
      goto (%dofmt_91);
   ];
   block %dofmt_55 [
      guard eq(extract(32,0, $R21:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_21);
   ];
   block %dofmt_21 [
      assert eq($_PC:bv64, 0x40201c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202524_bv64:bv64 := 0x0:bv64;
      var var1_4202524_bv64:bv64 := $R23:bv64;
      var var2_4202524_bv64:bv64 := 0x0:bv64;
      var var2_4202524_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202524_bv64:bv64,
       0x10:bv64) 64;
      $R0:bv64 := var2_4202524_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202528_bv32:bv32 := 0x0:bv32;
      var var1_4202528_bv32:bv32 := extract(32,0, $R19:bv64);
      var var2_4202528_bv32:bv32 := 0x0:bv32;
      var var2_4202528_bv32:bv32 := extract(32,0, $R0:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4202528_bv32:bv32,
        bvnot(bvshl(var2_4202528_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      goto (%dofmt_19);
   ];
   block %dofmt_27 [
      assert eq($_PC:bv64, 0x401fb4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202420_bv64:bv64 := 0x0:bv64;
      var var1_4202420_bv64:bv64 := $R20:bv64;
      var var2_4202420_bv8:bv8 := 0x0:bv8;
      var var2_4202420_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202420_bv64:bv64 8;
      $R21:bv64 := zero_extend(32, zero_extend(24, var2_4202420_bv8:bv8));
      goto (%dofmt_25,%dofmt_23);
   ];
   block %dofmt_23 [
      guard eq(extract(32,0, $R21:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40201c:bv64;
      goto (%dofmt_21);
   ];
   block %dofmt_25 [
      guard boolnot(eq(extract(32,0, $R21:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_91);
   ];
   block %dofmt_99 [
      guard eq(extract(32,0, $R21:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401f98:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020fc:bv64;
      goto (%dofmt_97);
   ];
   block %dofmt_97 [ goto (%dofmt_95); ];
   block %dofmt_163 [
      guard boolnot(eq(extract(32,0, $R0:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401efc:bv64);
      goto (%dofmt_161);
   ];
   block %dofmt_161 [ goto (%dofmt_159,%dofmt_155); ];
   block %dofmt_155 [
      guard boolnot(eq(extract(32,0, $R21:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f28:bv64;
      goto (%dofmt_153);
   ];
   block %dofmt_153 [
      assert eq($_PC:bv64, 0x401f28:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202280_bv32:bv32 := 0x0:bv32;
      var var2_4202280_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R22:bv64)),
           0xffffffffffffffda:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R22:bv64)), 0xffffffda:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R22:bv64),
          0xffffffda:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R22:bv64),
        0xffffffda:bv32), 0x1:bv32));
      goto (%dofmt_151,%dofmt_107);
   ];
   block %dofmt_107 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020e0:bv64;
      assert eq($_PC:bv64, 0x4020e0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202720_bv64:bv64 := 0x0:bv64;
      var var1_4202720_bv64:bv64 := $R23:bv64;
      var var2_4202720_bv64:bv64 := 0x0:bv64;
      var var2_4202720_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202720_bv64:bv64,
       0x10:bv64) 64;
      $R2:bv64 := var2_4202720_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202724_bv64:bv64 := 0x0:bv64;
      var var2_4202724_bv64:bv64 := 0x0:bv64;
      var var2_4202724_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvadd(var2_4202724_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202728_bv64:bv64 := 0x0:bv64;
      var var1_4202728_bv64:bv64 := $R23:bv64;
      var var2_4202728_bv32:bv32 := 0x0:bv32;
      var var2_4202728_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202728_bv64:bv64,
       0x30:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4202728_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202732_bv64:bv64 := 0x0:bv64;
      var var1_4202732_bv64:bv64 := $R19:bv64;
      var var2_4202732_bv64:bv64 := 0x0:bv64;
      var var2_4202732_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(bvadd(var1_4202732_bv64:bv64,
        bvnot(bvshl(var2_4202732_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202736_bv64:bv64 := 0x0:bv64;
      var var1_4202736_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvor(bvand(sign_extend(63,
        extract(64,63, var1_4202736_bv64:bv64)), 0x8000000000000000:bv64),
       bvand(bvor(0x0:bv64,
         bvor(bvlshr(var1_4202736_bv64:bv64, 0x1:bv64),
          bvshl(var1_4202736_bv64:bv64, 0x3f:bv64))), 0x7fffffffffffffff:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202740_bv32:bv32 := 0x0:bv32;
      var var1_4202740_bv32:bv32 := extract(32,0, $R0:bv64);
      var var2_4202740_bv32:bv32 := 0x0:bv32;
      var var2_4202740_bv32:bv32 := extract(32,0, $R2:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(var1_4202740_bv32:bv32, bvshl(var2_4202740_bv32:bv32, 0x0:bv32)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020a8:bv64;
      goto (%dofmt_105);
   ];
   block %dofmt_105 [ goto (%dofmt_11); ];
   block %dofmt_151 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401f30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202288_bv32:bv32 := 0x0:bv32;
      var var2_4202288_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R22:bv64)),
           0xffffffffffffff80:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R22:bv64)), 0xffffff80:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R22:bv64),
          0xffffff80:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R22:bv64),
        0xffffff80:bv32), 0x1:bv32));
      goto (%dofmt_149);
   ];
   block %dofmt_149 [ goto (%dofmt_147,%dofmt_137); ];
   block %dofmt_137 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f04:bv64;
      assert eq($_PC:bv64, 0x401f04:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202244_bv64:bv64 := 0x0:bv64;
      var var2_4202244_bv64:bv64 := 0x0:bv64;
      var var2_4202244_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(var2_4202244_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202248_bv64:bv64 := 0x0:bv64;
      var var2_4202248_bv64:bv64 := 0x0:bv64;
      var var2_4202248_bv64:bv64 := $R20:bv64;
      $R20:bv64 := bvadd(var2_4202248_bv64:bv64, 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202252_bv64:bv64 := 0x0:bv64;
      var var1_4202252_bv64:bv64 := 0x0:bv64;
      var var2_4202252_bv64:bv64 := 0x0:bv64;
      var var2_4202252_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4202252_bv64:bv64,
       bvshl(var2_4202252_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202256_bv64:bv64 := 0x0:bv64;
      var var2_4202256_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%dofmt_135);
   ];
   block %dofmt_135 [ goto (%dofmt_133,%dofmt_125); ];
   block %dofmt_125 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f5c:bv64;
      goto (%dofmt_123);
   ];
   block %dofmt_133 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_131);
   ];
   block %dofmt_147 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401f38:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202296_bv64:bv64 := 0x0:bv64;
      var var1_4202296_bv64:bv64 := 0x0:bv64;
      var var2_4202296_bv64:bv64 := 0x0:bv64;
      var var2_4202296_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvor(var1_4202296_bv64:bv64,
       bvshl(var2_4202296_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202300_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x5e:bv64);
      $R30:bv64 := 0x401f44:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403c60:bv64;
      
      call @chartorune_4209760();
      goto (%dofmt_145);
   ];
   block %dofmt_145 [ goto (%dofmt_143); ];
   block %dofmt_143 [
      assert eq($_PC:bv64, 0x401f44:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202308_bv16:bv16 := 0x0:bv16;
      var var1_4202308_bv16:bv16 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x5e:bv64) 16;
      $R22:bv64 := zero_extend(32, zero_extend(16, var1_4202308_bv16:bv16));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202312_bv64:bv64 := 0x0:bv64;
      var var2_4202312_bv64:bv64 := 0x0:bv64;
      var var2_4202312_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(var2_4202312_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202316_bv64:bv64 := 0x0:bv64;
      var var2_4202316_bv64:bv64 := 0x0:bv64;
      var var2_4202316_bv64:bv64 := $R20:bv64;
      var var3_4202316_bv64:bv64 := 0x0:bv64;
      var var3_4202316_bv64:bv64 := $R0:bv64;
      $R20:bv64 := bvadd(var2_4202316_bv64:bv64,
       sign_extend(32, extract(32,0, var3_4202316_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202320_bv64:bv64 := 0x0:bv64;
      var var1_4202320_bv64:bv64 := 0x0:bv64;
      var var2_4202320_bv64:bv64 := 0x0:bv64;
      var var2_4202320_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4202320_bv64:bv64,
       bvshl(var2_4202320_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202324_bv64:bv64 := 0x0:bv64;
      var var2_4202324_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R25:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R25:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%dofmt_141,%dofmt_139);
   ];
   block %dofmt_139 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f18:bv64;
      goto (%dofmt_131);
   ];
   block %dofmt_141 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_123);
   ];
   block %dofmt_113 [
      assert eq($_PC:bv64, 0x401f84:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202372_bv64:bv64 := 0x0:bv64;
      var var1_4202372_bv64:bv64 := $R23:bv64;
      var var2_4202372_bv64:bv64 := 0x0:bv64;
      var var2_4202372_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202372_bv64:bv64,
       0x10:bv64) 64;
      $R0:bv64 := var2_4202372_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202376_bv64:bv64 := 0x0:bv64;
      var var1_4202376_bv64:bv64 := $R19:bv64;
      var var2_4202376_bv64:bv64 := 0x0:bv64;
      var var2_4202376_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(bvadd(var1_4202376_bv64:bv64,
        bvnot(bvshl(var2_4202376_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202380_bv64:bv64 := 0x0:bv64;
      var var1_4202380_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvor(0x0:bv64,
       bvand(bvor(0x0:bv64,
         bvand(bvor(bvlshr(var1_4202380_bv64:bv64, 0x1:bv64),
           bvshl(var1_4202380_bv64:bv64, 0x3f:bv64)), 0x80000000ffffffff:bv64)),
        0xffffffff:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402024:bv64;
      goto (%dofmt_19);
   ];
   block %dofmt_123 [
      assert eq($_PC:bv64, 0x401f5c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202332_bv64:bv64 := 0x0:bv64;
      var var1_4202332_bv64:bv64 := 0x0:bv64;
      var var2_4202332_bv64:bv64 := 0x0:bv64;
      var var2_4202332_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4202332_bv64:bv64,
       bvshl(var2_4202332_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202336_bv64:bv64 := 0x0:bv64;
      var var1_4202336_bv64:bv64 := 0x0:bv64;
      var var2_4202336_bv64:bv64 := 0x0:bv64;
      var var2_4202336_bv64:bv64 := $R23:bv64;
      $R0:bv64 := bvor(var1_4202336_bv64:bv64,
       bvshl(var2_4202336_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x2:bv64;
      $R30:bv64 := 0x401f6c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e30:bv64;
      
      call @__fmtflush_4202032();
      goto (%dofmt_121);
   ];
   block %dofmt_121 [
      assert eq($_PC:bv64, 0x401f6c:bv64);
      goto (%dofmt_119,%dofmt_109);
   ];
   block %dofmt_109 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020c4:bv64;
      goto (%dofmt_5);
   ];
   block %dofmt_119 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401f70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202352_bv64:bv64 := 0x0:bv64;
      var var1_4202352_bv64:bv64 := $R23:bv64;
      var var2_4202352_bv64:bv64 := 0x0:bv64;
      var var2_4202352_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4202352_bv64:bv64,
       0x18:bv64) 64;
      $R25:bv64 := var2_4202352_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202356_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(16,0, $R22:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202360_bv64:bv64 := 0x0:bv64;
      var var2_4202360_bv64:bv64 := 0x0:bv64;
      var var2_4202360_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvadd(var2_4202360_bv64:bv64, 0x2:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202364_bv64:bv64 := 0x0:bv64;
      var var1_4202364_bv64:bv64 := $R20:bv64;
      var var2_4202364_bv8:bv8 := 0x0:bv8;
      var var2_4202364_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202364_bv64:bv64 8;
      $R22:bv64 := zero_extend(32, zero_extend(24, var2_4202364_bv8:bv8));
      goto (%dofmt_117);
   ];
   block %dofmt_117 [ goto (%dofmt_115,%dofmt_111); ];
   block %dofmt_111 [
      guard boolnot(eq(extract(32,0, $R22:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f28:bv64;
      goto (%dofmt_153);
   ];
   block %dofmt_115 [
      guard eq(extract(32,0, $R22:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_113);
   ];
   block %dofmt_131 [
      assert eq($_PC:bv64, 0x401f18:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202264_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 extract(16,0, $R22:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202268_bv64:bv64 := 0x0:bv64;
      var var1_4202268_bv64:bv64 := 0x0:bv64;
      var var2_4202268_bv64:bv64 := 0x0:bv64;
      var var2_4202268_bv64:bv64 := $R1:bv64;
      $R19:bv64 := bvor(var1_4202268_bv64:bv64,
       bvshl(var2_4202268_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202272_bv64:bv64 := 0x0:bv64;
      var var1_4202272_bv64:bv64 := $R20:bv64;
      var var2_4202272_bv8:bv8 := 0x0:bv8;
      var var2_4202272_bv8:bv8 := load le $mem:(bv64->bv8) var1_4202272_bv64:bv64 8;
      $R22:bv64 := zero_extend(32, zero_extend(24, var2_4202272_bv8:bv8));
      goto (%dofmt_129,%dofmt_127);
   ];
   block %dofmt_127 [
      guard eq(extract(32,0, $R22:bv64), 0x0:bv32);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401f84:bv64;
      goto (%dofmt_113);
   ];
   block %dofmt_129 [
      guard boolnot(eq(extract(32,0, $R22:bv64), 0x0:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_153);
   ];
   block %dofmt_159 [
      guard eq(extract(32,0, $R21:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401f00:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4020fc:bv64;
      goto (%dofmt_157);
   ];
   block %dofmt_157 [ goto (%dofmt_95); ];
   block %dofmt_5 [
      assert eq($_PC:bv64, 0x4020c4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202692_bv64:bv64 := 0x0:bv64;
      var var1_4202692_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4202692_bv64:bv64 := 0x0:bv64;
      var var2_4202692_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4202692_bv64:bv64;
      $R20:bv64 := var2_4202692_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0xffffffff:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202700_bv64:bv64 := 0x0:bv64;
      var var1_4202700_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4202700_bv64:bv64 := 0x0:bv64;
      var var2_4202700_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4202700_bv64:bv64;
      $R22:bv64 := var2_4202700_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202704_bv64:bv64 := 0x0:bv64;
      var var1_4202704_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      var var2_4202704_bv64:bv64 := 0x0:bv64;
      var var2_4202704_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) 64;
      $R23:bv64 := var1_4202704_bv64:bv64;
      $R24:bv64 := var2_4202704_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202708_bv64:bv64 := 0x0:bv64;
      var var1_4202708_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x40:bv64) 64;
      $R25:bv64 := var1_4202708_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202712_bv64:bv64 := 0x0:bv64;
      var var1_4202712_bv64:bv64 := $R31:bv64;
      var var2_4202712_bv64:bv64 := 0x0:bv64;
      var var2_4202712_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202712_bv64:bv64 := 0x0:bv64;
      var var3_4202712_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202712_bv64:bv64;
      $R30:bv64 := var3_4202712_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202712_bv64:bv64, 0x60:bv64);
      var var1_4202716_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%dofmt_basil_return_1);
   ];
   block %dofmt_11 [
      assert eq($_PC:bv64, 0x4020a8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202664_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R23:bv64, 0x10:bv64) $R19:bv64 64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($R23:bv64,
        0x10:bv64), 0x8:bv64) $R25:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202672_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R23:bv64, 0x30:bv64) extract(32,0, $R0:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202676_bv64:bv64 := 0x0:bv64;
      var var1_4202676_bv64:bv64 := 0x0:bv64;
      var var2_4202676_bv64:bv64 := 0x0:bv64;
      var var2_4202676_bv64:bv64 := $R23:bv64;
      $R0:bv64 := bvor(var1_4202676_bv64:bv64,
       bvshl(var2_4202676_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x4020bc:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403830:bv64;
      
      call @__fmtdispatch_4208688();
      goto (%dofmt_9);
   ];
   block %dofmt_9 [
      assert eq($_PC:bv64, 0x4020bc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202684_bv64:bv64 := 0x0:bv64;
      var var1_4202684_bv64:bv64 := 0x0:bv64;
      var var2_4202684_bv64:bv64 := 0x0:bv64;
      var var2_4202684_bv64:bv64 := $R0:bv64;
      $R20:bv64 := bvor(var1_4202684_bv64:bv64,
       bvshl(var2_4202684_bv64:bv64, 0x0:bv64));
      goto (%dofmt_7,%dofmt_3);
   ];
   block %dofmt_3 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ee8:bv64;
      goto (%dofmt_165);
   ];
   block %dofmt_7 [
      guard eq($R0:bv64, 0x0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%dofmt_5);
   ];
   block %dofmt_19 [
      assert eq($_PC:bv64, 0x402024:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202532_bv64:bv64 := 0x0:bv64;
      var var1_4202532_bv64:bv64 := $R23:bv64;
      var var2_4202532_bv32:bv32 := 0x0:bv32;
      var var2_4202532_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4202532_bv64:bv64,
       0x30:bv64) 32;
      $R1:bv64 := zero_extend(32, var2_4202532_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202536_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R23:bv64, 0x10:bv64) $R19:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202540_bv32:bv32 := 0x0:bv32;
      var var1_4202540_bv32:bv32 := extract(32,0, $R0:bv64);
      var var2_4202540_bv32:bv32 := 0x0:bv32;
      var var2_4202540_bv32:bv32 := extract(32,0, $R1:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(var1_4202540_bv32:bv32, bvshl(var2_4202540_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202544_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R23:bv64, 0x30:bv64) extract(32,0, $R0:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202548_bv64:bv64 := 0x0:bv64;
      var var1_4202548_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4202548_bv64:bv64 := 0x0:bv64;
      var var2_4202548_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4202548_bv64:bv64;
      $R20:bv64 := var2_4202548_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202552_bv32:bv32 := 0x0:bv32;
      var var1_4202552_bv32:bv32 := extract(32,0, $R0:bv64);
      var var2_4202552_bv32:bv32 := 0x0:bv32;
      var var2_4202552_bv32:bv32 := extract(32,0, $R24:bv64);
      $R0:bv64 := zero_extend(32,
      bvadd(bvadd(var1_4202552_bv32:bv32,
        bvnot(bvshl(var2_4202552_bv32:bv32, 0x0:bv32))), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202556_bv64:bv64 := 0x0:bv64;
      var var1_4202556_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4202556_bv64:bv64 := 0x0:bv64;
      var var2_4202556_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4202556_bv64:bv64;
      $R22:bv64 := var2_4202556_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202560_bv64:bv64 := 0x0:bv64;
      var var1_4202560_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 64;
      var var2_4202560_bv64:bv64 := 0x0:bv64;
      var var2_4202560_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) 64;
      $R23:bv64 := var1_4202560_bv64:bv64;
      $R24:bv64 := var2_4202560_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202564_bv64:bv64 := 0x0:bv64;
      var var1_4202564_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x40:bv64) 64;
      $R25:bv64 := var1_4202564_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202568_bv64:bv64 := 0x0:bv64;
      var var1_4202568_bv64:bv64 := $R31:bv64;
      var var2_4202568_bv64:bv64 := 0x0:bv64;
      var var2_4202568_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202568_bv64:bv64 := 0x0:bv64;
      var var3_4202568_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202568_bv64:bv64;
      $R30:bv64 := var3_4202568_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202568_bv64:bv64, 0x60:bv64);
      var var1_4202572_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%dofmt_basil_return_1);
   ];
   block %dofmt_95 [
      assert eq($_PC:bv64, 0x4020fc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x402024:bv64;
      goto (%dofmt_19);
   ];
   block %dofmt_basil_return_1 [ nop; return; ]
];
proc @vfprint_4201072()  -> () { .address = 4201072; .name = "vfprint";
    .returnBlock = "vfprint_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $R7:bv64, $R8:bv64, $VF:bv1, $Z0:bv128, $Z1:bv128, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64,
    $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64,
    $R7:bv64, $R8:bv64, $VF:bv1, $Z0:bv128, $Z1:bv128, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401a70:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %vfprint_entry [
      assert eq($_PC:bv64, 0x401a70:bv64);
      $_PC:bv64 := 0x401a70:bv64;
      assert eq($_PC:bv64, 0x401a70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201072_bv64:bv64 := 0x0:bv64;
      var var1_4201072_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xfffffffffffffe50:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xfffffffffffffe50:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201072_bv64:bv64, 0xfffffffffffffe50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x100:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201080_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201088_bv64:bv64 := 0x0:bv64;
      var var1_4201088_bv64:bv64 := 0x0:bv64;
      var var2_4201088_bv64:bv64 := 0x0:bv64;
      var var2_4201088_bv64:bv64 := $R2:bv64;
      $R19:bv64 := bvor(var1_4201088_bv64:bv64,
       bvshl(var2_4201088_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201092_bv64:bv64 := 0x0:bv64;
      var var1_4201092_bv64:bv64 := 0x0:bv64;
      var var2_4201092_bv64:bv64 := 0x0:bv64;
      var var2_4201092_bv64:bv64 := $R1:bv64;
      $R20:bv64 := bvor(var1_4201092_bv64:bv64,
       bvshl(var2_4201092_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201096_bv64:bv64 := 0x0:bv64;
      $R2:bv64 := bvadd($R31:bv64, 0xb0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201100_bv32:bv32 := 0x0:bv32;
      var var1_4201100_bv32:bv32 := 0x0:bv32;
      var var2_4201100_bv32:bv32 := 0x0:bv32;
      var var2_4201100_bv32:bv32 := extract(32,0, $R0:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(var1_4201100_bv32:bv32, bvshl(var2_4201100_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201104_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $R30:bv64 := 0x401a98:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403ad4:bv64;
      
      call @fmtfdinit_4209364();
      goto (%vfprint_21);
   ];
   block %vfprint_21 [
      assert eq($_PC:bv64, 0x401a98:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201112_bv128:bv128 := 0x0:bv128;
      var var1_4201112_bv128:bv128 := load le $stack:(bv64->bv8) $R19:bv64 128;
      var var2_4201112_bv128:bv128 := 0x0:bv128;
      var var2_4201112_bv128:bv128 := load le $stack:(bv64->bv8) bvadd($R19:bv64,
       0x10:bv64) 128;
      $Z0:bv128 := var1_4201112_bv128:bv128;
      $Z1:bv128 := var2_4201112_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201116_bv64:bv64 := 0x0:bv64;
      var var1_4201116_bv64:bv64 := 0x0:bv64;
      var var2_4201116_bv64:bv64 := 0x0:bv64;
      var var2_4201116_bv64:bv64 := $R20:bv64;
      $R1:bv64 := bvor(var1_4201116_bv64:bv64,
       bvshl(var2_4201116_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201120_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x60:bv64) $Z0:bv128 128;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x60:bv64), 0x10:bv64) $Z1:bv128 128;
      $R30:bv64 := 0x401aac:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ec0:bv64;
      
      call @dofmt_4202176();
      goto (%vfprint_19);
   ];
   block %vfprint_19 [
      assert eq($_PC:bv64, 0x401aac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201132_bv32:bv32 := 0x0:bv32;
      var var1_4201132_bv32:bv32 := 0x0:bv32;
      var var2_4201132_bv32:bv32 := 0x0:bv32;
      var var2_4201132_bv32:bv32 := extract(32,0, $R0:bv64);
      $R19:bv64 := zero_extend(32,
      bvor(var1_4201132_bv32:bv32, bvshl(var2_4201132_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201136_bv32:bv32 := 0x0:bv32;
      var var2_4201136_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xffffffff:bv32), 0x1:bv32));
      goto (%vfprint_17,%vfprint_7);
   ];
   block %vfprint_7 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ac8:bv64;
      goto (%vfprint_5);
   ];
   block %vfprint_17 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401ab8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201144_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $R30:bv64 := 0x401ac0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b30:bv64;
      
      call @__fmtFdFlush_4209456();
      goto (%vfprint_15);
   ];
   block %vfprint_15 [ goto (%vfprint_13); ];
   block %vfprint_13 [
      assert eq($_PC:bv64, 0x401ac0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201152_bv32:bv32 := 0x0:bv32;
      var var2_4201152_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xffffffff:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xffffffff:bv32), 0x1:bv32));
      var var1_4201156_bv32:bv32 := 0x0:bv32;
      var var1_4201156_bv32:bv32 := extract(32,0, $R19:bv64);
      var var2_4201156_bv32:bv32 := 0x0:bv32;
      var var2_4201156_bv32:bv32 := 0x0:bv32;
      goto (%vfprint_11,%vfprint_9);
   ];
   block %vfprint_9 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := zero_extend(32, var1_4201156_bv32:bv32);
      goto (%vfprint_5);
   ];
   block %vfprint_11 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := zero_extend(32, bvnot(var2_4201156_bv32:bv32));
      goto (%vfprint_5);
   ];
   block %vfprint_5 [
      assert eq($_PC:bv64, 0x401ac8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201160_bv32:bv32 := 0x0:bv32;
      var var1_4201160_bv32:bv32 := 0x0:bv32;
      var var2_4201160_bv32:bv32 := 0x0:bv32;
      var var2_4201160_bv32:bv32 := extract(32,0, $R19:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4201160_bv32:bv32, bvshl(var2_4201160_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201164_bv64:bv64 := 0x0:bv64;
      var var1_4201164_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4201164_bv64:bv64 := 0x0:bv64;
      var var2_4201164_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4201164_bv64:bv64;
      $R20:bv64 := var2_4201164_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201168_bv64:bv64 := 0x0:bv64;
      var var1_4201168_bv64:bv64 := $R31:bv64;
      var var2_4201168_bv64:bv64 := 0x0:bv64;
      var var2_4201168_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201168_bv64:bv64 := 0x0:bv64;
      var var3_4201168_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201168_bv64:bv64;
      $R30:bv64 := var3_4201168_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201168_bv64:bv64, 0x1b0:bv64);
      var var1_4201172_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%vfprint_basil_return_1);
   ];
   block %vfprint_basil_return_1 [ nop; return; ]
];
proc @fprint_4200960()  -> () { .address = 4200960; .name = "fprint";
    .returnBlock = "fprint_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401a00:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %fprint_entry [
      assert eq($_PC:bv64, 0x401a00:bv64);
      $_PC:bv64 := 0x401a00:bv64;
      assert eq($_PC:bv64, 0x401a00:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200960_bv64:bv64 := 0x0:bv64;
      var var1_4200960_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffff00:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffff00:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4200960_bv64:bv64, 0xffffffffffffff00:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R9:bv64 := 0xffffffd0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R8:bv64 := 0xffffff80:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200972_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200976_bv64:bv64 := 0x0:bv64;
      $R10:bv64 := bvadd($R31:bv64, 0xd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200980_bv64:bv64 := 0x0:bv64;
      $R11:bv64 := bvadd($R31:bv64, 0x100:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R11:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) $R11:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x40:bv64) $R10:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x48:bv64) extract(32,0, $R9:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x48:bv64), 0x4:bv64) extract(32,0, $R8:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x50:bv64) $Z0:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201000_bv128:bv128 := 0x0:bv128;
      var var1_4201000_bv128:bv128 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 128;
      var var2_4201000_bv128:bv128 := 0x0:bv128;
      var var2_4201000_bv128:bv128 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x10:bv64) 128;
      $Z0:bv128 := var1_4201000_bv128:bv128;
      $Z16:bv128 := var2_4201000_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x60:bv64) $Z1:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x70:bv64) $Z2:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $Z0:bv128 128;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x10:bv64) $Z16:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x80:bv64) $Z3:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x90:bv64) $Z4:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xa0:bv64) $Z5:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xb0:bv64) $Z6:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xc0:bv64) $Z7:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xd0:bv64) $R2:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xd0:bv64), 0x8:bv64) $R3:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201040_bv64:bv64 := 0x0:bv64;
      $R2:bv64 := bvadd($R31:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xe0:bv64) $R4:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xe0:bv64), 0x8:bv64) $R5:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xf0:bv64) $R6:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xf0:bv64), 0x8:bv64) $R7:bv64 64;
      $R30:bv64 := 0x401a60:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401a70:bv64;
      
      call @vfprint_4201072();
      goto (%fprint_5);
   ];
   block %fprint_5 [
      assert eq($_PC:bv64, 0x401a60:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201056_bv64:bv64 := 0x0:bv64;
      var var1_4201056_bv64:bv64 := $R31:bv64;
      var var2_4201056_bv64:bv64 := 0x0:bv64;
      var var2_4201056_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201056_bv64:bv64 := 0x0:bv64;
      var var3_4201056_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201056_bv64:bv64;
      $R30:bv64 := var3_4201056_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201056_bv64:bv64, 0x100:bv64);
      var var1_4201060_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%fprint_basil_return_1);
   ];
   block %fprint_basil_return_1 [ nop; return; ]
];
proc @__fixargv0_4198400()  -> () { .address = 4198400; .name = "__fixargv0";
    .returnBlock = "__fixargv0_basil_return_1" }
  modifies $BTypeNext:bv2, $_PC:bv64, $__BranchTaken:bv1;
  captures $BTypeNext:bv2, $R30:bv64, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401000:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %__fixargv0_entry [
      assert eq($_PC:bv64, 0x401000:bv64);
      $_PC:bv64 := 0x401000:bv64;
      assert eq($_PC:bv64, 0x401000:bv64);
      var var1_4198400_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%__fixargv0_basil_return_1);
   ];
   block %__fixargv0_basil_return_1 [ nop; return; ]
];
proc @vseprint_4201184()  -> () { .address = 4201184; .name = "vseprint";
    .returnBlock = "vseprint_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1,
    $Z0:bv128, $Z1:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64,
    $R23:bv64, $R24:bv64, $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64,
    $R30:bv64, $R31:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $VF:bv1,
    $Z0:bv128, $Z1:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401ae0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %vseprint_entry [
      assert eq($_PC:bv64, 0x401ae0:bv64);
      $_PC:bv64 := 0x401ae0:bv64;
      assert eq($_PC:bv64, 0x401ae0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201184_bv64:bv64 := 0x0:bv64;
      var var2_4201184_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R1:bv64),
           sign_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R1:bv64),
           zero_extend(64, bvnot(bvshl($R0:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64,
          bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R1:bv64,
        bvnot(bvshl($R0:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%vseprint_15,%vseprint_7);
   ];
   block %vseprint_7 [
      guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401b54:bv64;
      assert eq($_PC:bv64, 0x401b54:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      var var1_4201304_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%vseprint_5);
   ];
   block %vseprint_5 [ goto (%vseprint_basil_return_1); ];
   block %vseprint_15 [
      guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401ae8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201192_bv64:bv64 := 0x0:bv64;
      var var1_4201192_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffff50:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffff50:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201192_bv64:bv64, 0xffffffffffffff50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201196_bv64:bv64 := 0x0:bv64;
      var var1_4201196_bv64:bv64 := 0x0:bv64;
      var var2_4201196_bv64:bv64 := 0x0:bv64;
      var var2_4201196_bv64:bv64 := $R0:bv64;
      $R5:bv64 := bvor(var1_4201196_bv64:bv64,
       bvshl(var2_4201196_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201200_bv64:bv64 := 0x0:bv64;
      var var2_4201200_bv64:bv64 := 0x0:bv64;
      var var2_4201200_bv64:bv64 := $R1:bv64;
      $R4:bv64 := bvadd(bvadd(var2_4201200_bv64:bv64, 0xfffffffffffffffe:bv64),
       0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201204_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201208_bv128:bv128 := 0x0:bv128;
      var var1_4201208_bv128:bv128 := load le $mem:(bv64->bv8) $R3:bv64 128;
      var var2_4201208_bv128:bv128 := 0x0:bv128;
      var var2_4201208_bv128:bv128 := load le $mem:(bv64->bv8) bvadd($R3:bv64,
       0x10:bv64) 128;
      $Z0:bv128 := var1_4201208_bv128:bv128;
      $Z1:bv128 := var2_4201208_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201220_bv64:bv64 := 0x0:bv64;
      var var1_4201220_bv64:bv64 := 0x0:bv64;
      var var2_4201220_bv64:bv64 := 0x0:bv64;
      var var2_4201220_bv64:bv64 := $R2:bv64;
      $R19:bv64 := bvor(var1_4201220_bv64:bv64,
       bvshl(var2_4201220_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201228_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x28:bv64) 0x0:bv8 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R5:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) $R5:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x40:bv64) $R4:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x40:bv64), 0x8:bv64) 0x0:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x50:bv64) 0x0:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x58:bv64) 0x0:bv32 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x60:bv64) $Z0:bv128 128;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x60:bv64), 0x10:bv64) $Z1:bv128 128;
      $R30:bv64 := 0x401b30:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x403b90:bv64;
      
      call @fmtlocaleinit_4209552();
      goto (%vseprint_13);
   ];
   block %vseprint_13 [ goto (%vseprint_11); ];
   block %vseprint_11 [
      assert eq($_PC:bv64, 0x401b30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201264_bv64:bv64 := 0x0:bv64;
      var var1_4201264_bv64:bv64 := 0x0:bv64;
      var var2_4201264_bv64:bv64 := 0x0:bv64;
      var var2_4201264_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4201264_bv64:bv64,
       bvshl(var2_4201264_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201268_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x28:bv64);
      $R30:bv64 := 0x401b3c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ec0:bv64;
      
      call @dofmt_4202176();
      goto (%vseprint_9);
   ];
   block %vseprint_9 [
      assert eq($_PC:bv64, 0x401b3c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201276_bv64:bv64 := 0x0:bv64;
      var var1_4201276_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x38:bv64) 64;
      $R0:bv64 := var1_4201276_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201280_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R0:bv64 0x0:bv8 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201284_bv64:bv64 := 0x0:bv64;
      var var1_4201284_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      $R19:bv64 := var1_4201284_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201288_bv64:bv64 := 0x0:bv64;
      var var1_4201288_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x38:bv64) 64;
      $R0:bv64 := var1_4201288_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201292_bv64:bv64 := 0x0:bv64;
      var var1_4201292_bv64:bv64 := $R31:bv64;
      var var2_4201292_bv64:bv64 := 0x0:bv64;
      var var2_4201292_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201292_bv64:bv64 := 0x0:bv64;
      var var3_4201292_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201292_bv64:bv64;
      $R30:bv64 := var3_4201292_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201292_bv64:bv64, 0xb0:bv64);
      var var1_4201296_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%vseprint_basil_return_1);
   ];
   block %vseprint_basil_return_1 [ nop; return; ]
];
proc @sysfatal_4200560()  -> () { .address = 4200560; .name = "sysfatal";
    .returnBlock = "sysfatal_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401870:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %sysfatal_entry [
      var R30_begin_sysfatal_4200560:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x401870:bv64);
      $_PC:bv64 := 0x401870:bv64;
      assert eq($_PC:bv64, 0x401870:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200560_bv64:bv64 := 0x0:bv64;
      var var1_4200560_bv64:bv64 := $R31:bv64;
      $R31:bv64 := bvadd(bvadd(var1_4200560_bv64:bv64, 0xfffffffffffffdcf:bv64),
       0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R8:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200568_bv64:bv64 := 0x0:bv64;
      $R11:bv64 := bvadd($R31:bv64, 0x1f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200572_bv64:bv64 := 0x0:bv64;
      $R12:bv64 := bvadd($R31:bv64, 0x230:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R10:bv64 := 0xffffffc8:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R9:bv64 := 0xffffff80:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) $R31:bv64 $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x8:bv64) $R30:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200588_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200592_bv64:bv64 := 0x0:bv64;
      var var1_4200592_bv64:bv64 := $R8:bv64;
      var var2_4200592_bv64:bv64 := 0x0:bv64;
      var var2_4200592_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4200592_bv64:bv64,
       0x678:bv64) 64;
      $R8:bv64 := var2_4200592_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1f8:bv64) $R1:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x1f8:bv64), 0x8:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200600_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x208:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200608_bv64:bv64 := 0x0:bv64;
      $R19:bv64 := bvadd($R31:bv64, 0x30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200612_bv64:bv64 := 0x0:bv64;
      $R20:bv64 := bvadd($R31:bv64, 0x50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200620_bv64:bv64 := 0x0:bv64;
      var var1_4200620_bv64:bv64 := 0x0:bv64;
      var var2_4200620_bv64:bv64 := 0x0:bv64;
      var var2_4200620_bv64:bv64 := $R0:bv64;
      $R21:bv64 := bvor(var1_4200620_bv64:bv64,
       bvshl(var2_4200620_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x50:bv64) $R12:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x50:bv64), 0x8:bv64) $R12:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x60:bv64) $R11:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x68:bv64) extract(32,0, $R10:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x68:bv64), 0x4:bv64) extract(32,0, $R9:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x170:bv64) $Z0:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x180:bv64) $Z1:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x190:bv64) $Z2:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1a0:bv64) $Z3:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1b0:bv64) $Z4:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1c0:bv64) $Z5:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1d0:bv64) $Z6:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x1e0:bv64) $Z7:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200668_bv64:bv64 := 0x0:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) $R1:bv64 $R3:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R1:bv64, 0x8:bv64) $R4:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200672_bv64:bv64 := 0x0:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R1:bv64, 0x10:bv64) $R5:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R1:bv64,
        0x10:bv64), 0x8:bv64) $R6:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x228:bv64) $R7:bv64 64;
      goto (%sysfatal_23,%sysfatal_19);
   ];
   block %sysfatal_19 [
      guard eq($R8:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401904:bv64;
      goto (%sysfatal_17);
   ];
   block %sysfatal_23 [
      guard boolnot(eq($R8:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4018ec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200684_bv64:bv64 := 0x0:bv64;
      $R20:bv64 := bvadd($R31:bv64, 0x50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200688_bv64:bv64 := 0x0:bv64;
      $R19:bv64 := bvadd($R31:bv64, 0x30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200692_bv64:bv64 := 0x0:bv64;
      var var1_4200692_bv64:bv64 := 0x0:bv64;
      var var2_4200692_bv64:bv64 := 0x0:bv64;
      var var2_4200692_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvor(var1_4200692_bv64:bv64,
       bvshl(var2_4200692_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200696_bv128:bv128 := 0x0:bv128;
      var var1_4200696_bv128:bv128 := load le $stack:(bv64->bv8) $R20:bv64 128;
      var var2_4200696_bv128:bv128 := 0x0:bv128;
      var var2_4200696_bv128:bv128 := load le $stack:(bv64->bv8) bvadd($R20:bv64,
       0x10:bv64) 128;
      $Z0:bv128 := var1_4200696_bv128:bv128;
      $Z1:bv128 := var2_4200696_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) $R19:bv64 $Z0:bv128 128;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $Z1:bv128 128;
      var var1_4200704_bv64:bv64 := 0x0:bv64;
      var var1_4200704_bv64:bv64 := $R8:bv64;
      $R30:bv64 := 0x401904:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4200704_bv64:bv64;
      indirect call var1_4200704_bv64:bv64;
      goto (%sysfatal_21);
   ];
   block %sysfatal_21 [ goto (%sysfatal_17); ];
   block %sysfatal_17 [
      assert eq($_PC:bv64, 0x401904:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200708_bv64:bv64 := 0x0:bv64;
      var var1_4200708_bv64:bv64 := 0x0:bv64;
      var var2_4200708_bv64:bv64 := 0x0:bv64;
      var var2_4200708_bv64:bv64 := $R21:bv64;
      $R2:bv64 := bvor(var1_4200708_bv64:bv64,
       bvshl(var2_4200708_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200712_bv128:bv128 := 0x0:bv128;
      var var1_4200712_bv128:bv128 := load le $mem:(bv64->bv8) $R20:bv64 128;
      var var2_4200712_bv128:bv128 := 0x0:bv128;
      var var2_4200712_bv128:bv128 := load le $mem:(bv64->bv8) bvadd($R20:bv64,
       0x10:bv64) 128;
      $Z0:bv128 := var1_4200712_bv128:bv128;
      $Z1:bv128 := var2_4200712_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200716_bv64:bv64 := 0x0:bv64;
      var var1_4200716_bv64:bv64 := 0x0:bv64;
      var var2_4200716_bv64:bv64 := 0x0:bv64;
      var var2_4200716_bv64:bv64 := $R19:bv64;
      $R3:bv64 := bvor(var1_4200716_bv64:bv64,
       bvshl(var2_4200716_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200720_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x170:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200724_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R19:bv64 $Z0:bv128 128;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x10:bv64) $Z1:bv128 128;
      $R30:bv64 := 0x401920:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ae0:bv64;
      
      call @vseprint_4201184();
      goto (%sysfatal_15);
   ];
   block %sysfatal_15 [
      assert eq($_PC:bv64, 0x401920:bv64);
      $R30:bv64 := 0x401924:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401000:bv64;
      
      call @__fixargv0_4198400();
      goto (%sysfatal_13);
   ];
   block %sysfatal_13 [
      assert eq($_PC:bv64, 0x401924:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200748_bv64:bv64 := 0x0:bv64;
      var var2_4200748_bv64:bv64 := 0x0:bv64;
      var var2_4200748_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(var2_4200748_bv64:bv64, 0xcb8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200752_bv64:bv64 := 0x0:bv64;
      $R3:bv64 := bvadd($R31:bv64, 0x70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200756_bv64:bv64 := 0x0:bv64;
      var var1_4200756_bv64:bv64 := $R0:bv64;
      var var2_4200756_bv64:bv64 := 0x0:bv64;
      var var2_4200756_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4200756_bv64:bv64,
       0x408:bv64) 64;
      $R4:bv64 := var2_4200756_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200764_bv64:bv64 := 0x0:bv64;
      var var2_4200764_bv64:bv64 := 0x0:bv64;
      var var2_4200764_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvadd(var2_4200764_bv64:bv64, 0xcc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x2:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200772_bv64:bv64 := 0x0:bv64;
      var var2_4200772_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R4:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R4:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      var var1_4200776_bv64:bv64 := 0x0:bv64;
      var var1_4200776_bv64:bv64 := $R2:bv64;
      var var2_4200776_bv64:bv64 := 0x0:bv64;
      var var2_4200776_bv64:bv64 := $R4:bv64;
      goto (%sysfatal_11,%sysfatal_9);
   ];
   block %sysfatal_9 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := var1_4200776_bv64:bv64;
      goto (%sysfatal_7);
   ];
   block %sysfatal_11 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := var2_4200776_bv64:bv64;
      goto (%sysfatal_7);
   ];
   block %sysfatal_7 [
      $R30:bv64 := 0x401950:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401a00:bv64;
      
      call @fprint_4200960();
      goto (%sysfatal_5);
   ];
   block %sysfatal_5 [
      assert eq($_PC:bv64, 0x401950:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200788_bv64:bv64 := 0x0:bv64;
      var var2_4200788_bv64:bv64 := 0x0:bv64;
      var var2_4200788_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4200788_bv64:bv64, 0xcc8:bv64);
      $R30:bv64 := 0x40195c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401120:bv64;
      assert eq($R30:bv64, R30_begin_sysfatal_4200560:bv64);
      
      call @exits_4198688();
      goto (%sysfatal_basil_return_1);
   ];
   block %sysfatal_basil_return_1 [ nop; return; ]
];
proc @memccpy()  -> () { .name = "memccpy" }
  
;
proc @strecpy_4201936()  -> () { .address = 4201936; .name = "strecpy";
    .returnBlock = "strecpy_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R29:bv64,
    $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R29:bv64,
    $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401dd0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %strecpy_entry [
      assert eq($_PC:bv64, 0x401dd0:bv64);
      $_PC:bv64 := 0x401dd0:bv64;
      assert eq($_PC:bv64, 0x401dd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201936_bv64:bv64 := 0x0:bv64;
      var var2_4201936_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R0:bv64),
           sign_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R0:bv64),
           zero_extend(64, bvnot(bvshl($R1:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64,
          bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R0:bv64,
        bvnot(bvshl($R1:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%strecpy_21,%strecpy_17);
   ];
   block %strecpy_17 [
      guard boolnot(eq($CF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ddc:bv64;
      assert eq($_PC:bv64, 0x401ddc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201948_bv64:bv64 := 0x0:bv64;
      var var1_4201948_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffe0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201948_bv64:bv64, 0xffffffffffffffe0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201952_bv64:bv64 := 0x0:bv64;
      var var1_4201952_bv64:bv64 := $R1:bv64;
      var var2_4201952_bv64:bv64 := 0x0:bv64;
      var var2_4201952_bv64:bv64 := $R0:bv64;
      $R3:bv64 := bvadd(bvadd(var1_4201952_bv64:bv64,
        bvnot(bvshl(var2_4201952_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201956_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201964_bv64:bv64 := 0x0:bv64;
      var var1_4201964_bv64:bv64 := 0x0:bv64;
      var var2_4201964_bv64:bv64 := 0x0:bv64;
      var var2_4201964_bv64:bv64 := $R1:bv64;
      $R19:bv64 := bvor(var1_4201964_bv64:bv64,
       bvshl(var2_4201964_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201968_bv64:bv64 := 0x0:bv64;
      var var1_4201968_bv64:bv64 := 0x0:bv64;
      var var2_4201968_bv64:bv64 := 0x0:bv64;
      var var2_4201968_bv64:bv64 := $R2:bv64;
      $R1:bv64 := bvor(var1_4201968_bv64:bv64,
       bvshl(var2_4201968_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x0:bv64;
      $R30:bv64 := 0x401dfc:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400be0:bv64;
      goto (%FUN_400be0_entry_83);
   ];
   block %FUN_400be0_entry_83 [
      var R30_begin_FUN_400be0_4197344_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400be0:bv64);
      $_PC:bv64 := 0x400be0:bv64;
      assert eq($_PC:bv64, 0x400be0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197348_bv64_2:bv64 := 0x0:bv64;
      var var1_4197348_bv64_2:bv64 := $R16:bv64;
      var var2_4197348_bv64_3:bv64 := 0x0:bv64;
      var var2_4197348_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197348_bv64_2:bv64,
       0x20:bv64) 64;
      $R17:bv64 := var2_4197348_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197352_bv64_4:bv64 := 0x0:bv64;
      var var2_4197352_bv64_5:bv64 := 0x0:bv64;
      var var2_4197352_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197352_bv64_5:bv64, 0x20:bv64);
      var var1_4197356_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400be0_4197344_1:bv64);
      
      call @memccpy();
      goto (%FUN_400be0_basil_return_1_84);
   ];
   block %FUN_400be0_basil_return_1_84 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%strecpy_15); ];
   block %strecpy_15 [ goto (%strecpy_13); ];
   block %strecpy_13 [
      assert eq($_PC:bv64, 0x401dfc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201980_bv64:bv64 := 0x0:bv64;
      var var2_4201980_bv64:bv64 := 0x0:bv64;
      var var2_4201980_bv64:bv64 := $R0:bv64;
      $R3:bv64 := bvadd(bvadd(var2_4201980_bv64:bv64, 0xfffffffffffffffe:bv64),
       0x1:bv64);
      goto (%strecpy_11,%strecpy_7);
   ];
   block %strecpy_7 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401e14:bv64;
      assert eq($_PC:bv64, 0x401e14:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202004_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64,
       0xffffffffffffffff:bv64) 0x0:bv8 8;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202008_bv64:bv64 := 0x0:bv64;
      var var2_4202008_bv64:bv64 := 0x0:bv64;
      var var2_4202008_bv64:bv64 := $R19:bv64;
      $R3:bv64 := bvadd(bvadd(var2_4202008_bv64:bv64, 0xfffffffffffffffe:bv64),
       0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202012_bv64:bv64 := 0x0:bv64;
      var var1_4202012_bv64:bv64 := 0x0:bv64;
      var var2_4202012_bv64:bv64 := 0x0:bv64;
      var var2_4202012_bv64:bv64 := $R3:bv64;
      $R0:bv64 := bvor(var1_4202012_bv64:bv64,
       bvshl(var2_4202012_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202016_bv64:bv64 := 0x0:bv64;
      var var1_4202016_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      $R19:bv64 := var1_4202016_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4202020_bv64:bv64 := 0x0:bv64;
      var var1_4202020_bv64:bv64 := $R31:bv64;
      var var2_4202020_bv64:bv64 := 0x0:bv64;
      var var2_4202020_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4202020_bv64:bv64 := 0x0:bv64;
      var var3_4202020_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4202020_bv64:bv64;
      $R30:bv64 := var3_4202020_bv64:bv64;
      $R31:bv64 := bvadd(var1_4202020_bv64:bv64, 0x20:bv64);
      var var1_4202024_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%strecpy_5);
   ];
   block %strecpy_5 [ goto (%strecpy_basil_return_1); ];
   block %strecpy_11 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401e04:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201988_bv64:bv64 := 0x0:bv64;
      var var1_4201988_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      $R19:bv64 := var1_4201988_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201992_bv64:bv64 := 0x0:bv64;
      var var1_4201992_bv64:bv64 := 0x0:bv64;
      var var2_4201992_bv64:bv64 := 0x0:bv64;
      var var2_4201992_bv64:bv64 := $R3:bv64;
      $R0:bv64 := bvor(var1_4201992_bv64:bv64,
       bvshl(var2_4201992_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201996_bv64:bv64 := 0x0:bv64;
      var var1_4201996_bv64:bv64 := $R31:bv64;
      var var2_4201996_bv64:bv64 := 0x0:bv64;
      var var2_4201996_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201996_bv64:bv64 := 0x0:bv64;
      var var3_4201996_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201996_bv64:bv64;
      $R30:bv64 := var3_4201996_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201996_bv64:bv64, 0x20:bv64);
      var var1_4202000_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%strecpy_9);
   ];
   block %strecpy_9 [ goto (%strecpy_basil_return_1); ];
   block %strecpy_21 [
      guard eq($CF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401dd8:bv64);
      var var1_4201944_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%strecpy_19);
   ];
   block %strecpy_19 [ goto (%strecpy_basil_return_1); ];
   block %strecpy_basil_return_1 [ nop; return; ]
];
proc @__errno_location()  -> () { .name = "__errno_location" }
  
;
proc @strcpy()  -> () { .name = "strcpy" }
  
;
proc @strerror()  -> () { .name = "strerror" }
  
;
proc @rerrstr_4201312()  -> () { .address = 4201312; .name = "rerrstr";
    .returnBlock = "rerrstr_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1,
    $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1,
    $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401b60:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %rerrstr_entry [
      var R30_begin_rerrstr_4201312:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x401b60:bv64);
      $_PC:bv64 := 0x401b60:bv64;
      assert eq($_PC:bv64, 0x401b60:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201312_bv64:bv64 := 0x0:bv64;
      var var1_4201312_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201312_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201316_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201328_bv64:bv64 := 0x0:bv64;
      var var2_4201328_bv64:bv64 := 0x0:bv64;
      var var2_4201328_bv64:bv64 := $R20:bv64;
      $R20:bv64 := bvadd(var2_4201328_bv64:bv64, 0x680:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201336_bv64:bv64 := 0x0:bv64;
      var var1_4201336_bv64:bv64 := 0x0:bv64;
      var var2_4201336_bv64:bv64 := 0x0:bv64;
      var var2_4201336_bv64:bv64 := $R0:bv64;
      $R21:bv64 := bvor(var1_4201336_bv64:bv64,
       bvshl(var2_4201336_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201340_bv32:bv32 := 0x0:bv32;
      var var1_4201340_bv32:bv32 := 0x0:bv32;
      var var2_4201340_bv32:bv32 := 0x0:bv32;
      var var2_4201340_bv32:bv32 := extract(32,0, $R1:bv64);
      $R22:bv64 := zero_extend(32,
      bvor(var1_4201340_bv32:bv32, bvshl(var2_4201340_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201344_bv64:bv64 := 0x0:bv64;
      var var1_4201344_bv64:bv64 := $R20:bv64;
      var var2_4201344_bv64:bv64 := 0x0:bv64;
      var var2_4201344_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4201344_bv64:bv64,
       0x80:bv64) 64;
      $R2:bv64 := var2_4201344_bv64:bv64;
      goto (%rerrstr_45,%rerrstr_27);
   ];
   block %rerrstr_27 [
      guard eq($R2:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401bd0:bv64;
      goto (%rerrstr_25);
   ];
   block %rerrstr_45 [
      guard boolnot(eq($R2:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401b88:bv64);
      var var1_4201352_bv64:bv64 := 0x0:bv64;
      var var1_4201352_bv64:bv64 := $R2:bv64;
      $R30:bv64 := 0x401b8c:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4201352_bv64:bv64;
      indirect call var1_4201352_bv64:bv64;
      goto (%rerrstr_43);
   ];
   block %rerrstr_43 [ goto (%rerrstr_41); ];
   block %rerrstr_41 [
      assert eq($_PC:bv64, 0x401b8c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201356_bv64:bv64 := 0x0:bv64;
      var var1_4201356_bv64:bv64 := 0x0:bv64;
      var var2_4201356_bv64:bv64 := 0x0:bv64;
      var var2_4201356_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4201356_bv64:bv64,
       bvshl(var2_4201356_bv64:bv64, 0x0:bv64));
      goto (%rerrstr_39,%rerrstr_29);
   ];
   block %rerrstr_29 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401bd0:bv64;
      goto (%rerrstr_25);
   ];
   block %rerrstr_39 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401b94:bv64);
      $R30:bv64 := 0x401b98:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400d10:bv64;
      goto (%FUN_400d10_entry_73);
   ];
   block %FUN_400d10_entry_73 [
      var R30_begin_FUN_400d10_4197648_19:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := 0x400d10:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197652_bv64_20:bv64 := 0x0:bv64;
      var var1_4197652_bv64_20:bv64 := $R16:bv64;
      var var2_4197652_bv64_21:bv64 := 0x0:bv64;
      var var2_4197652_bv64_21:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197652_bv64_20:bv64,
       0xb8:bv64) 64;
      $R17:bv64 := var2_4197652_bv64_21:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197656_bv64_22:bv64 := 0x0:bv64;
      var var2_4197656_bv64_23:bv64 := 0x0:bv64;
      var var2_4197656_bv64_23:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197656_bv64_23:bv64, 0xb8:bv64);
      var var1_4197660_bv64_24:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_19:bv64);
      
      call @__errno_location();
      goto (%FUN_400d10_basil_return_1_74);
   ];
   block %FUN_400d10_basil_return_1_74 [ goto (%_inlineret_6); ];
   block %_inlineret_6 [ goto (%rerrstr_37); ];
   block %rerrstr_37 [ goto (%rerrstr_35); ];
   block %rerrstr_35 [
      assert eq($_PC:bv64, 0x401b98:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201368_bv64:bv64 := 0x0:bv64;
      var var1_4201368_bv64:bv64 := $R0:bv64;
      var var2_4201368_bv32:bv32 := 0x0:bv32;
      var var2_4201368_bv32:bv32 := load le $mem:(bv64->bv8) var1_4201368_bv64:bv64 32;
      $R0:bv64 := zero_extend(32, var2_4201368_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201372_bv32:bv32 := 0x0:bv32;
      var var2_4201372_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xfffffffffffffffb:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xfffffffb:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xfffffffb:bv32), 0x1:bv32));
      goto (%rerrstr_33,%rerrstr_31);
   ];
   block %rerrstr_31 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401be4:bv64;
      goto (%rerrstr_19);
   ];
   block %rerrstr_33 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%rerrstr_15);
   ];
   block %rerrstr_15 [
      assert eq($_PC:bv64, 0x401ba4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x3745:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201384_bv32:bv32 := 0x0:bv32;
      var var1_4201384_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(bvand(var1_4201384_bv32:bv32, 0xffff:bv32), 0x19280000:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201388_bv32:bv32 := 0x0:bv32;
      var var2_4201388_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64),
           bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           sign_extend(32, bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64),
           bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)),
           zero_extend(32, bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32)))),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64),
          bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        bvnot(bvshl(extract(32,0, $R1:bv64), 0x0:bv32))), 0x1:bv32));
      goto (%rerrstr_13,%rerrstr_9);
   ];
   block %rerrstr_9 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401c18:bv64;
      assert eq($_PC:bv64, 0x401c18:bv64);
      $R30:bv64 := 0x401c1c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c40:bv64;
      goto (%FUN_400c40_entry_57);
   ];
   block %FUN_400c40_entry_57 [
      var R30_begin_FUN_400c40_4197440_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c40:bv64);
      $_PC:bv64 := 0x400c40:bv64;
      assert eq($_PC:bv64, 0x400c40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197444_bv64_2:bv64 := 0x0:bv64;
      var var1_4197444_bv64_2:bv64 := $R16:bv64;
      var var2_4197444_bv64_3:bv64 := 0x0:bv64;
      var var2_4197444_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197444_bv64_2:bv64,
       0x50:bv64) 64;
      $R17:bv64 := var2_4197444_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197448_bv64_4:bv64 := 0x0:bv64;
      var var2_4197448_bv64_5:bv64 := 0x0:bv64;
      var var2_4197448_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197448_bv64_5:bv64, 0x50:bv64);
      var var1_4197452_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c40_4197440_1:bv64);
      
      call @strerror();
      goto (%FUN_400c40_basil_return_1_58);
   ];
   block %FUN_400c40_basil_return_1_58 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%rerrstr_7); ];
   block %rerrstr_7 [ goto (%rerrstr_5); ];
   block %rerrstr_5 [
      assert eq($_PC:bv64, 0x401c1c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201500_bv64:bv64 := 0x0:bv64;
      var var1_4201500_bv64:bv64 := 0x0:bv64;
      var var2_4201500_bv64:bv64 := 0x0:bv64;
      var var2_4201500_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvor(var1_4201500_bv64:bv64,
       bvshl(var2_4201500_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201504_bv64:bv64 := 0x0:bv64;
      var var1_4201504_bv64:bv64 := 0x0:bv64;
      var var2_4201504_bv64:bv64 := 0x0:bv64;
      var var2_4201504_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4201504_bv64:bv64,
       bvshl(var2_4201504_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x401c28:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400cd0:bv64;
      goto (%FUN_400cd0_entry_61);
   ];
   block %FUN_400cd0_entry_61 [
      var R30_begin_FUN_400cd0_4197584_7:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400cd0:bv64);
      $_PC:bv64 := 0x400cd0:bv64;
      assert eq($_PC:bv64, 0x400cd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197588_bv64_8:bv64 := 0x0:bv64;
      var var1_4197588_bv64_8:bv64 := $R16:bv64;
      var var2_4197588_bv64_9:bv64 := 0x0:bv64;
      var var2_4197588_bv64_9:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197588_bv64_8:bv64,
       0x98:bv64) 64;
      $R17:bv64 := var2_4197588_bv64_9:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197592_bv64_10:bv64 := 0x0:bv64;
      var var2_4197592_bv64_11:bv64 := 0x0:bv64;
      var var2_4197592_bv64_11:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197592_bv64_11:bv64, 0x98:bv64);
      var var1_4197596_bv64_12:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400cd0_4197584_7:bv64);
      
      call @strcpy();
      goto (%FUN_400cd0_basil_return_1_62);
   ];
   block %FUN_400cd0_basil_return_1_62 [ goto (%_inlineret_4); ];
   block %_inlineret_4 [ goto (%rerrstr_3); ];
   block %rerrstr_3 [
      assert eq($_PC:bv64, 0x401c28:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201512_bv64:bv64 := 0x0:bv64;
      var var1_4201512_bv64:bv64 := 0x0:bv64;
      var var2_4201512_bv64:bv64 := 0x0:bv64;
      var var2_4201512_bv64:bv64 := $R19:bv64;
      $R2:bv64 := bvor(var1_4201512_bv64:bv64,
       bvshl(var2_4201512_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201516_bv64:bv64 := 0x0:bv64;
      var var2_4201516_bv64:bv64 := 0x0:bv64;
      var var2_4201516_bv64:bv64 := $R21:bv64;
      var var3_4201516_bv64:bv64 := 0x0:bv64;
      var var3_4201516_bv64:bv64 := $R22:bv64;
      $R1:bv64 := bvadd(var2_4201516_bv64:bv64,
       zero_extend(32, extract(32,0, var3_4201516_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201520_bv64:bv64 := 0x0:bv64;
      var var1_4201520_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4201520_bv64:bv64 := 0x0:bv64;
      var var2_4201520_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4201520_bv64:bv64;
      $R20:bv64 := var2_4201520_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201524_bv64:bv64 := 0x0:bv64;
      var var1_4201524_bv64:bv64 := 0x0:bv64;
      var var2_4201524_bv64:bv64 := 0x0:bv64;
      var var2_4201524_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4201524_bv64:bv64,
       bvshl(var2_4201524_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201528_bv64:bv64 := 0x0:bv64;
      var var1_4201528_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4201528_bv64:bv64 := 0x0:bv64;
      var var2_4201528_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4201528_bv64:bv64;
      $R22:bv64 := var2_4201528_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201532_bv64:bv64 := 0x0:bv64;
      var var1_4201532_bv64:bv64 := $R31:bv64;
      var var2_4201532_bv64:bv64 := 0x0:bv64;
      var var2_4201532_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201532_bv64:bv64 := 0x0:bv64;
      var var3_4201532_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201532_bv64:bv64;
      $R30:bv64 := var3_4201532_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201532_bv64:bv64, 0x30:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dd0:bv64;
      assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64);
      
      call @strecpy_4201936();
      goto (%rerrstr_basil_return_1);
   ];
   block %rerrstr_13 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401bb4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201396_bv64:bv64 := 0x0:bv64;
      var var1_4201396_bv64:bv64 := 0x0:bv64;
      var var2_4201396_bv64:bv64 := 0x0:bv64;
      var var2_4201396_bv64:bv64 := $R19:bv64;
      $R2:bv64 := bvor(var1_4201396_bv64:bv64,
       bvshl(var2_4201396_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201400_bv64:bv64 := 0x0:bv64;
      var var2_4201400_bv64:bv64 := 0x0:bv64;
      var var2_4201400_bv64:bv64 := $R21:bv64;
      var var3_4201400_bv64:bv64 := 0x0:bv64;
      var var3_4201400_bv64:bv64 := $R22:bv64;
      $R1:bv64 := bvadd(var2_4201400_bv64:bv64,
       zero_extend(32, extract(32,0, var3_4201400_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201404_bv64:bv64 := 0x0:bv64;
      var var1_4201404_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4201404_bv64:bv64 := 0x0:bv64;
      var var2_4201404_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4201404_bv64:bv64;
      $R20:bv64 := var2_4201404_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201408_bv64:bv64 := 0x0:bv64;
      var var1_4201408_bv64:bv64 := 0x0:bv64;
      var var2_4201408_bv64:bv64 := 0x0:bv64;
      var var2_4201408_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4201408_bv64:bv64,
       bvshl(var2_4201408_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201412_bv64:bv64 := 0x0:bv64;
      var var1_4201412_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4201412_bv64:bv64 := 0x0:bv64;
      var var2_4201412_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4201412_bv64:bv64;
      $R22:bv64 := var2_4201412_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201416_bv64:bv64 := 0x0:bv64;
      var var1_4201416_bv64:bv64 := $R31:bv64;
      var var2_4201416_bv64:bv64 := 0x0:bv64;
      var var2_4201416_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201416_bv64:bv64 := 0x0:bv64;
      var var3_4201416_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201416_bv64:bv64;
      $R30:bv64 := var3_4201416_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201416_bv64:bv64, 0x30:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dd0:bv64;
      assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64);
      
      call @strecpy_4201936();
      goto (%rerrstr_basil_return_1);
   ];
   block %rerrstr_19 [
      assert eq($_PC:bv64, 0x401be4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201448_bv64:bv64 := 0x0:bv64;
      var var2_4201448_bv64:bv64 := 0x0:bv64;
      var var2_4201448_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4201448_bv64:bv64, 0xcd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201452_bv64:bv64 := 0x0:bv64;
      var var1_4201452_bv64:bv64 := 0x0:bv64;
      var var2_4201452_bv64:bv64 := 0x0:bv64;
      var var2_4201452_bv64:bv64 := $R19:bv64;
      $R2:bv64 := bvor(var1_4201452_bv64:bv64,
       bvshl(var2_4201452_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201456_bv64:bv64 := 0x0:bv64;
      var var1_4201456_bv64:bv64 := $R0:bv64;
      var var2_4201456_bv64:bv64 := 0x0:bv64;
      var var2_4201456_bv64:bv64 := load le $mem:(bv64->bv8) var1_4201456_bv64:bv64 64;
      $R1:bv64 := var2_4201456_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201460_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) $R19:bv64 $R1:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201464_bv64:bv64 := 0x0:bv64;
      var var1_4201464_bv64:bv64 := $R0:bv64;
      var var2_4201464_bv32:bv32 := 0x0:bv32;
      var var2_4201464_bv32:bv32 := load le $mem:(bv64->bv8) bvadd(var1_4201464_bv64:bv64,
       0x8:bv64) 32;
      $R0:bv64 := zero_extend(32, var2_4201464_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201468_bv64:bv64 := 0x0:bv64;
      var var2_4201468_bv64:bv64 := 0x0:bv64;
      var var2_4201468_bv64:bv64 := $R21:bv64;
      var var3_4201468_bv64:bv64 := 0x0:bv64;
      var var3_4201468_bv64:bv64 := $R22:bv64;
      $R1:bv64 := bvadd(var2_4201468_bv64:bv64,
       zero_extend(32, extract(32,0, var3_4201468_bv64:bv64)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201472_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19:bv64, 0x8:bv64) extract(32,0, $R0:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201476_bv64:bv64 := 0x0:bv64;
      var var1_4201476_bv64:bv64 := 0x0:bv64;
      var var2_4201476_bv64:bv64 := 0x0:bv64;
      var var2_4201476_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4201476_bv64:bv64,
       bvshl(var2_4201476_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201480_bv64:bv64 := 0x0:bv64;
      var var1_4201480_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4201480_bv64:bv64 := 0x0:bv64;
      var var2_4201480_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4201480_bv64:bv64;
      $R20:bv64 := var2_4201480_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201484_bv64:bv64 := 0x0:bv64;
      var var1_4201484_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4201484_bv64:bv64 := 0x0:bv64;
      var var2_4201484_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4201484_bv64:bv64;
      $R22:bv64 := var2_4201484_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201488_bv64:bv64 := 0x0:bv64;
      var var1_4201488_bv64:bv64 := $R31:bv64;
      var var2_4201488_bv64:bv64 := 0x0:bv64;
      var var2_4201488_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201488_bv64:bv64 := 0x0:bv64;
      var var3_4201488_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201488_bv64:bv64;
      $R30:bv64 := var3_4201488_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201488_bv64:bv64, 0x30:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dd0:bv64;
      assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64);
      
      call @strecpy_4201936();
      goto (%rerrstr_basil_return_1);
   ];
   block %rerrstr_25 [
      assert eq($_PC:bv64, 0x401bd0:bv64);
      $R30:bv64 := 0x401bd4:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400d10:bv64;
      goto (%FUN_400d10_entry_67);
   ];
   block %FUN_400d10_entry_67 [
      var R30_begin_FUN_400d10_4197648_13:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := 0x400d10:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197652_bv64_14:bv64 := 0x0:bv64;
      var var1_4197652_bv64_14:bv64 := $R16:bv64;
      var var2_4197652_bv64_15:bv64 := 0x0:bv64;
      var var2_4197652_bv64_15:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197652_bv64_14:bv64,
       0xb8:bv64) 64;
      $R17:bv64 := var2_4197652_bv64_15:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197656_bv64_16:bv64 := 0x0:bv64;
      var var2_4197656_bv64_17:bv64 := 0x0:bv64;
      var var2_4197656_bv64_17:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197656_bv64_17:bv64, 0xb8:bv64);
      var var1_4197660_bv64_18:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_13:bv64);
      
      call @__errno_location();
      goto (%FUN_400d10_basil_return_1_68);
   ];
   block %FUN_400d10_basil_return_1_68 [ goto (%_inlineret_5); ];
   block %_inlineret_5 [ goto (%rerrstr_23); ];
   block %rerrstr_23 [
      assert eq($_PC:bv64, 0x401bd4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201428_bv64:bv64 := 0x0:bv64;
      var var1_4201428_bv64:bv64 := $R0:bv64;
      var var2_4201428_bv32:bv32 := 0x0:bv32;
      var var2_4201428_bv32:bv32 := load le $mem:(bv64->bv8) var1_4201428_bv64:bv64 32;
      $R0:bv64 := zero_extend(32, var2_4201428_bv32:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201432_bv64:bv64 := 0x0:bv64;
      var var1_4201432_bv64:bv64 := 0x0:bv64;
      var var2_4201432_bv64:bv64 := 0x0:bv64;
      var var2_4201432_bv64:bv64 := $R20:bv64;
      $R19:bv64 := bvor(var1_4201432_bv64:bv64,
       bvshl(var2_4201432_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201436_bv32:bv32 := 0x0:bv32;
      var var2_4201436_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xfffffffffffffffb:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xfffffffb:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffb:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xfffffffb:bv32), 0x1:bv32));
      goto (%rerrstr_21,%rerrstr_17);
   ];
   block %rerrstr_17 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ba4:bv64;
      goto (%rerrstr_15);
   ];
   block %rerrstr_21 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%rerrstr_19);
   ];
   block %rerrstr_basil_return_1 [ nop; return; ]
];
proc @errstr_4201540()  -> () { .address = 4201540; .name = "errstr";
    .returnBlock = "errstr_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1,
    $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $VF:bv1,
    $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401c44:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %errstr_entry [
      assert eq($_PC:bv64, 0x401c44:bv64);
      $_PC:bv64 := 0x401c44:bv64;
      assert eq($_PC:bv64, 0x401c44:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201540_bv64:bv64 := 0x0:bv64;
      var var1_4201540_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffff60:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffff60:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201540_bv64:bv64, 0xffffffffffffff60:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201544_bv64:bv64 := 0x0:bv64;
      var var1_4201544_bv64:bv64 := 0x0:bv64;
      var var2_4201544_bv64:bv64 := 0x0:bv64;
      var var2_4201544_bv64:bv64 := $R0:bv64;
      $R2:bv64 := bvor(var1_4201544_bv64:bv64,
       bvshl(var2_4201544_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201548_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201556_bv64:bv64 := 0x0:bv64;
      var var1_4201556_bv64:bv64 := 0x0:bv64;
      var var2_4201556_bv64:bv64 := 0x0:bv64;
      var var2_4201556_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4201556_bv64:bv64,
       bvshl(var2_4201556_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201560_bv32:bv32 := 0x0:bv32;
      var var1_4201560_bv32:bv32 := 0x0:bv32;
      var var2_4201560_bv32:bv32 := 0x0:bv32;
      var var2_4201560_bv32:bv32 := extract(32,0, $R1:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4201560_bv32:bv32, bvshl(var2_4201560_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201564_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x20:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201568_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0xa0:bv64);
      $R30:bv64 := 0x401c68:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dd0:bv64;
      
      call @strecpy_4201936();
      goto (%errstr_25);
   ];
   block %errstr_25 [
      assert eq($_PC:bv64, 0x401c68:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201576_bv64:bv64 := 0x0:bv64;
      var var1_4201576_bv64:bv64 := 0x0:bv64;
      var var2_4201576_bv64:bv64 := 0x0:bv64;
      var var2_4201576_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4201576_bv64:bv64,
       bvshl(var2_4201576_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201584_bv64:bv64 := 0x0:bv64;
      var var2_4201584_bv64:bv64 := 0x0:bv64;
      var var2_4201584_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4201584_bv64:bv64, 0x680:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201588_bv32:bv32 := 0x0:bv32;
      var var1_4201588_bv32:bv32 := 0x0:bv32;
      var var2_4201588_bv32:bv32 := 0x0:bv32;
      var var2_4201588_bv32:bv32 := extract(32,0, $R20:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(var1_4201588_bv32:bv32, bvshl(var2_4201588_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x401c7c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401b60:bv64;
      
      call @rerrstr_4201312();
      goto (%errstr_23);
   ];
   block %errstr_23 [
      assert eq($_PC:bv64, 0x401c7c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201596_bv64:bv64 := 0x0:bv64;
      var var1_4201596_bv64:bv64 := $R19:bv64;
      var var2_4201596_bv64:bv64 := 0x0:bv64;
      var var2_4201596_bv64:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4201596_bv64:bv64,
       0x80:bv64) 64;
      $R0:bv64 := var2_4201596_bv64:bv64;
      goto (%errstr_21,%errstr_11);
   ];
   block %errstr_11 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401cbc:bv64;
      goto (%errstr_9);
   ];
   block %errstr_21 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401c84:bv64);
      var var1_4201604_bv64:bv64 := 0x0:bv64;
      var var1_4201604_bv64:bv64 := $R0:bv64;
      $R30:bv64 := 0x401c88:bv64;
      $BTypeNext:bv2 := 0x2:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := var1_4201604_bv64:bv64;
      indirect call var1_4201604_bv64:bv64;
      goto (%errstr_19);
   ];
   block %errstr_19 [ goto (%errstr_17); ];
   block %errstr_17 [
      assert eq($_PC:bv64, 0x401c88:bv64);
      goto (%errstr_15,%errstr_13);
   ];
   block %errstr_13 [
      guard eq($R0:bv64, 0x0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401cbc:bv64;
      goto (%errstr_9);
   ];
   block %errstr_15 [
      guard boolnot(eq($R0:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%errstr_7);
   ];
   block %errstr_7 [
      assert eq($_PC:bv64, 0x401c8c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201612_bv64:bv64 := 0x0:bv64;
      $R2:bv64 := bvadd($R31:bv64, 0x20:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201616_bv64:bv64 := 0x0:bv64;
      var var2_4201616_bv64:bv64 := 0x0:bv64;
      var var2_4201616_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvadd(var2_4201616_bv64:bv64, 0x80:bv64);
      $R30:bv64 := 0x401c98:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401dd0:bv64;
      
      call @strecpy_4201936();
      goto (%errstr_5);
   ];
   block %errstr_5 [
      assert eq($_PC:bv64, 0x401c98:bv64);
      $R30:bv64 := 0x401c9c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400d10:bv64;
      goto (%FUN_400d10_entry_75);
   ];
   block %FUN_400d10_entry_75 [
      var R30_begin_FUN_400d10_4197648_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := 0x400d10:bv64;
      assert eq($_PC:bv64, 0x400d10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197652_bv64_2:bv64 := 0x0:bv64;
      var var1_4197652_bv64_2:bv64 := $R16:bv64;
      var var2_4197652_bv64_3:bv64 := 0x0:bv64;
      var var2_4197652_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197652_bv64_2:bv64,
       0xb8:bv64) 64;
      $R17:bv64 := var2_4197652_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197656_bv64_4:bv64 := 0x0:bv64;
      var var2_4197656_bv64_5:bv64 := 0x0:bv64;
      var var2_4197656_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197656_bv64_5:bv64, 0xb8:bv64);
      var var1_4197660_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_1:bv64);
      
      call @__errno_location();
      goto (%FUN_400d10_basil_return_1_76);
   ];
   block %FUN_400d10_basil_return_1_76 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%errstr_3); ];
   block %errstr_3 [
      assert eq($_PC:bv64, 0x401c9c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201628_bv64:bv64 := 0x0:bv64;
      var var1_4201628_bv64:bv64 := 0x0:bv64;
      var var2_4201628_bv64:bv64 := 0x0:bv64;
      var var2_4201628_bv64:bv64 := $R0:bv64;
      $R1:bv64 := bvor(var1_4201628_bv64:bv64,
       bvshl(var2_4201628_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x3745:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201640_bv64:bv64 := 0x0:bv64;
      var var1_4201640_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4201640_bv64:bv64 := 0x0:bv64;
      var var2_4201640_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4201640_bv64:bv64;
      $R20:bv64 := var2_4201640_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201644_bv32:bv32 := 0x0:bv32;
      var var1_4201644_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32,
      bvor(bvand(var1_4201644_bv32:bv32, 0xffff:bv32), 0x19280000:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201648_bv64:bv64 := 0x0:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) $R1:bv64 extract(32,0, $R2:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201652_bv64:bv64 := 0x0:bv64;
      var var1_4201652_bv64:bv64 := $R31:bv64;
      var var2_4201652_bv64:bv64 := 0x0:bv64;
      var var2_4201652_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201652_bv64:bv64 := 0x0:bv64;
      var var3_4201652_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201652_bv64:bv64;
      $R30:bv64 := var3_4201652_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201652_bv64:bv64, 0xa0:bv64);
      var var1_4201656_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%errstr_basil_return_1);
   ];
   block %errstr_basil_return_1 [ nop; return; ];
   block %errstr_9 [
      assert eq($_PC:bv64, 0x401cbc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201660_bv64:bv64 := 0x0:bv64;
      var var1_4201660_bv64:bv64 := 0x0:bv64;
      var var2_4201660_bv64:bv64 := 0x0:bv64;
      var var2_4201660_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4201660_bv64:bv64,
       bvshl(var2_4201660_bv64:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401c8c:bv64;
      goto (%errstr_7);
   ]
];
proc @werrstr_4201780()  -> () { .address = 4201780; .name = "werrstr";
    .returnBlock = "werrstr_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401d34:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %werrstr_entry [
      assert eq($_PC:bv64, 0x401d34:bv64);
      $_PC:bv64 := 0x401d34:bv64;
      assert eq($_PC:bv64, 0x401d34:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201780_bv64:bv64 := 0x0:bv64;
      var var1_4201780_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xfffffffffffffe70:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xfffffffffffffe70:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4201780_bv64:bv64, 0xfffffffffffffe70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R10:bv64 := 0xffffffc8:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R9:bv64 := 0xffffff80:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201792_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201796_bv64:bv64 := 0x0:bv64;
      $R11:bv64 := bvadd($R31:bv64, 0x190:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201800_bv64:bv64 := 0x0:bv64;
      $R8:bv64 := bvadd($R31:bv64, 0x150:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) $R11:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x8:bv64) $R11:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x40:bv64) $R8:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201812_bv64:bv64 := 0x0:bv64;
      var var1_4201812_bv64:bv64 := 0x0:bv64;
      var var2_4201812_bv64:bv64 := 0x0:bv64;
      var var2_4201812_bv64:bv64 := $R0:bv64;
      $R8:bv64 := bvor(var1_4201812_bv64:bv64,
       bvshl(var2_4201812_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x48:bv64) extract(32,0, $R10:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x48:bv64), 0x4:bv64) extract(32,0, $R9:bv64) 32;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201820_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xd0:bv64) $Z0:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201828_bv128:bv128 := 0x0:bv128;
      var var1_4201828_bv128:bv128 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x30:bv64) 128;
      var var2_4201828_bv128:bv128 := 0x0:bv128;
      var var2_4201828_bv128:bv128 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x30:bv64), 0x10:bv64) 128;
      $Z0:bv128 := var1_4201828_bv128:bv128;
      $Z16:bv128 := var2_4201828_bv128:bv128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x158:bv64) $R1:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x158:bv64), 0x8:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201836_bv64:bv64 := 0x0:bv64;
      var var1_4201836_bv64:bv64 := 0x0:bv64;
      var var2_4201836_bv64:bv64 := 0x0:bv64;
      var var2_4201836_bv64:bv64 := $R8:bv64;
      $R2:bv64 := bvor(var1_4201836_bv64:bv64,
       bvshl(var2_4201836_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x168:bv64) $R3:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x168:bv64), 0x8:bv64) $R4:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201844_bv64:bv64 := 0x0:bv64;
      $R3:bv64 := bvadd($R31:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201848_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0xd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $Z0:bv128 128;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x10:bv64) $Z16:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xe0:bv64) $Z1:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0xf0:bv64) $Z2:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x100:bv64) $Z3:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x110:bv64) $Z4:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x120:bv64) $Z5:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x130:bv64) $Z6:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x140:bv64) $Z7:bv128 128;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x178:bv64) $R5:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x178:bv64), 0x8:bv64) $R6:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x188:bv64) $R7:bv64 64;
      $R30:bv64 := 0x401da8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401ae0:bv64;
      
      call @vseprint_4201184();
      goto (%werrstr_7);
   ];
   block %werrstr_7 [
      assert eq($_PC:bv64, 0x401da8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201896_bv64:bv64 := 0x0:bv64;
      $R0:bv64 := bvadd($R31:bv64, 0x50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x80:bv64;
      $R30:bv64 := 0x401db4:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401c44:bv64;
      
      call @errstr_4201540();
      goto (%werrstr_5);
   ];
   block %werrstr_5 [
      assert eq($_PC:bv64, 0x401db4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4201908_bv64:bv64 := 0x0:bv64;
      var var1_4201908_bv64:bv64 := $R31:bv64;
      var var2_4201908_bv64:bv64 := 0x0:bv64;
      var var2_4201908_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4201908_bv64:bv64 := 0x0:bv64;
      var var3_4201908_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4201908_bv64:bv64;
      $R30:bv64 := var3_4201908_bv64:bv64;
      $R31:bv64 := bvadd(var1_4201908_bv64:bv64, 0x190:bv64);
      var var1_4201912_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%werrstr_basil_return_1);
   ];
   block %werrstr_basil_return_1 [ nop; return; ]
];
proc @remove()  -> () { .name = "remove" }
  
;
proc @fcntl64()  -> () { .name = "fcntl64" }
  
;
proc @close()  -> () { .name = "close" }
  
;
proc @open64()  -> () { .name = "open64" }
  
;
proc @p9open_4198832()  -> () { .address = 4198832; .name = "p9open";
    .returnBlock = "p9open_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R16:bv64, $R17:bv64, $R19:bv64,
    $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64, $R25:bv64,
    $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64, $R4:bv64,
    $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x4011b0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %p9open_entry [
      assert eq($_PC:bv64, 0x4011b0:bv64);
      $_PC:bv64 := 0x4011b0:bv64;
      assert eq($_PC:bv64, 0x4011b0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198832_bv64:bv64 := 0x0:bv64;
      var var1_4198832_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffb0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffb0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4198832_bv64:bv64, 0xffffffffffffffb0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0xffffdf9c:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198840_bv32:bv32 := 0x0:bv32;
      var var1_4198840_bv32:bv32 := extract(32,0, $R1:bv64);
      var var2_4198840_bv32:bv32 := 0x0:bv32;
      var var2_4198840_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32,
      bvand(var1_4198840_bv32:bv32, bvshl(var2_4198840_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198844_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198852_bv32:bv32 := 0x0:bv32;
      var var1_4198852_bv32:bv32 := 0x0:bv32;
      var var2_4198852_bv32:bv32 := 0x0:bv32;
      var var2_4198852_bv32:bv32 := extract(32,0, $R1:bv64);
      $R19:bv64 := zero_extend(32,
      bvor(var1_4198852_bv32:bv32, bvshl(var2_4198852_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198860_bv32:bv32 := 0x0:bv32;
      var var1_4198860_bv32:bv32 := extract(32,0, $R1:bv64);
      $R22:bv64 := zero_extend(32, bvand(var1_4198860_bv32:bv32, 0x3:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198864_bv64:bv64 := 0x0:bv64;
      var var1_4198864_bv64:bv64 := 0x0:bv64;
      var var2_4198864_bv64:bv64 := 0x0:bv64;
      var var2_4198864_bv64:bv64 := $R0:bv64;
      $R21:bv64 := bvor(var1_4198864_bv64:bv64,
       bvshl(var2_4198864_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198868_bv32:bv32 := 0x0:bv32;
      var var1_4198868_bv32:bv32 := 0x0:bv32;
      var var2_4198868_bv32:bv32 := 0x0:bv32;
      var var2_4198868_bv32:bv32 := extract(32,0, $R22:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(var1_4198868_bv32:bv32, bvshl(var2_4198868_bv32:bv32, 0x0:bv32)));
      goto (%p9open_103,%p9open_99);
   ];
   block %p9open_99 [
      guard eq(extract(5,4, extract(32,0, $R19:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4011e4:bv64;
      goto (%p9open_97);
   ];
   block %p9open_103 [
      guard boolnot(eq(extract(5,4, extract(32,0, $R19:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4011dc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198876_bv32:bv32 := 0x0:bv32;
      var var1_4198876_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32, bvxor(var1_4198876_bv32:bv32, 0x10:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198880_bv32:bv32 := 0x0:bv32;
      var var1_4198880_bv32:bv32 := extract(32,0, $R22:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4198880_bv32:bv32, 0x200:bv32));
      goto (%p9open_101);
   ];
   block %p9open_101 [ goto (%p9open_97); ];
   block %p9open_97 [
      assert eq($_PC:bv64, 0x4011e4:bv64);
      goto (%p9open_95,%p9open_91);
   ];
   block %p9open_91 [
      guard eq(extract(8,7, extract(32,0, $R2:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4011f0:bv64;
      goto (%p9open_89);
   ];
   block %p9open_95 [
      guard boolnot(eq(extract(8,7, extract(32,0, $R2:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4011e8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198888_bv32:bv32 := 0x0:bv32;
      var var1_4198888_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4198888_bv32:bv32, 0x10000:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198892_bv32:bv32 := 0x0:bv32;
      var var1_4198892_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32, bvxor(var1_4198892_bv32:bv32, 0x80:bv32));
      goto (%p9open_93);
   ];
   block %p9open_93 [ goto (%p9open_89); ];
   block %p9open_89 [
      assert eq($_PC:bv64, 0x4011f0:bv64);
      goto (%p9open_87,%p9open_83);
   ];
   block %p9open_83 [
      guard eq(extract(9,8, extract(32,0, $R2:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4011fc:bv64;
      goto (%p9open_81);
   ];
   block %p9open_87 [
      guard boolnot(eq(extract(9,8, extract(32,0, $R2:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4011f4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198900_bv32:bv32 := 0x0:bv32;
      var var1_4198900_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4198900_bv32:bv32, 0x800:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198904_bv32:bv32 := 0x0:bv32;
      var var1_4198904_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32, bvxor(var1_4198904_bv32:bv32, 0x100:bv32));
      goto (%p9open_85);
   ];
   block %p9open_85 [ goto (%p9open_81); ];
   block %p9open_81 [
      assert eq($_PC:bv64, 0x4011fc:bv64);
      goto (%p9open_79,%p9open_75);
   ];
   block %p9open_75 [
      guard eq(extract(15,14, extract(32,0, $R2:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401208:bv64;
      goto (%p9open_73);
   ];
   block %p9open_79 [
      guard boolnot(eq(extract(15,14, extract(32,0, $R2:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401200:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198912_bv32:bv32 := 0x0:bv32;
      var var1_4198912_bv32:bv32 := extract(32,0, $R1:bv64);
      $R1:bv64 := zero_extend(32, bvor(var1_4198912_bv32:bv32, 0x400:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198916_bv32:bv32 := 0x0:bv32;
      var var1_4198916_bv32:bv32 := extract(32,0, $R2:bv64);
      $R2:bv64 := zero_extend(32, bvxor(var1_4198916_bv32:bv32, 0x4000:bv32));
      goto (%p9open_77);
   ];
   block %p9open_77 [ goto (%p9open_73); ];
   block %p9open_73 [
      assert eq($_PC:bv64, 0x401208:bv64);
      goto (%p9open_71,%p9open_11);
   ];
   block %p9open_11 [
      guard boolnot(eq(extract(32,0, $R2:bv64), 0x0:bv32));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4012ac:bv64;
      assert eq($_PC:bv64, 0x4012ac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199084_bv32:bv32 := 0x0:bv32;
      var var1_4199084_bv32:bv32 := 0x0:bv32;
      var var2_4199084_bv32:bv32 := 0x0:bv32;
      var var2_4199084_bv32:bv32 := extract(32,0, $R2:bv64);
      $R1:bv64 := zero_extend(32,
      bvor(var1_4199084_bv32:bv32, bvshl(var2_4199084_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := 0xffffffff:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199096_bv64:bv64 := 0x0:bv64;
      var var2_4199096_bv64:bv64 := 0x0:bv64;
      var var2_4199096_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4199096_bv64:bv64, 0xc90:bv64);
      $R30:bv64 := 0x4012c0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401d34:bv64;
      
      call @werrstr_4201780();
      goto (%p9open_9);
   ];
   block %p9open_9 [ goto (%p9open_7); ];
   block %p9open_7 [
      assert eq($_PC:bv64, 0x4012c0:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401228:bv64;
      goto (%p9open_5);
   ];
   block %p9open_71 [
      guard eq(extract(32,0, $R2:bv64), 0x0:bv32);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40120c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198924_bv64:bv64 := 0x0:bv64;
      var var1_4198924_bv64:bv64 := 0x0:bv64;
      var var2_4198924_bv64:bv64 := 0x0:bv64;
      var var2_4198924_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4198924_bv64:bv64,
       bvshl(var2_4198924_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x401214:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400cf0:bv64;
      goto (%FUN_400cf0_entry_45);
   ];
   block %FUN_400cf0_entry_45 [
      var R30_begin_FUN_400cf0_4197616_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400cf0:bv64);
      $_PC:bv64 := 0x400cf0:bv64;
      assert eq($_PC:bv64, 0x400cf0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197620_bv64_2:bv64 := 0x0:bv64;
      var var1_4197620_bv64_2:bv64 := $R16:bv64;
      var var2_4197620_bv64_3:bv64 := 0x0:bv64;
      var var2_4197620_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197620_bv64_2:bv64,
       0xa8:bv64) 64;
      $R17:bv64 := var2_4197620_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197624_bv64_4:bv64 := 0x0:bv64;
      var var2_4197624_bv64_5:bv64 := 0x0:bv64;
      var var2_4197624_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197624_bv64_5:bv64, 0xa8:bv64);
      var var1_4197628_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400cf0_4197616_1:bv64);
      
      call @open64();
      goto (%FUN_400cf0_basil_return_1_46);
   ];
   block %FUN_400cf0_basil_return_1_46 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%p9open_69); ];
   block %p9open_69 [ goto (%p9open_67); ];
   block %p9open_67 [
      assert eq($_PC:bv64, 0x401214:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198932_bv32:bv32 := 0x0:bv32;
      var var1_4198932_bv32:bv32 := 0x0:bv32;
      var var2_4198932_bv32:bv32 := 0x0:bv32;
      var var2_4198932_bv32:bv32 := extract(32,0, $R0:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4198932_bv32:bv32, bvshl(var2_4198932_bv32:bv32, 0x0:bv32)));
      goto (%p9open_65,%p9open_13);
   ];
   block %p9open_13 [
      guard eq(extract(32,31, extract(32,0, $R0:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401228:bv64;
      goto (%p9open_5);
   ];
   block %p9open_65 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R0:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x40121c:bv64);
      goto (%p9open_63);
   ];
   block %p9open_63 [ goto (%p9open_61,%p9open_59); ];
   block %p9open_59 [
      guard eq(extract(14,13, extract(32,0, $R19:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40123c:bv64;
      assert eq($_PC:bv64, 0x40123c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198972_bv32:bv32 := 0x0:bv32;
      var var2_4198972_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R22:bv64)),
           0xffffffffffffffff:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R22:bv64)), 0xffffffff:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R22:bv64),
          0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R22:bv64),
        0xffffffff:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198976_bv64:bv64 := 0x0:bv64;
      $R2:bv64 := bvadd($R31:bv64, 0x30:bv64);
      var var1_4198980_bv32:bv32 := 0x0:bv32;
      var var1_4198980_bv32:bv32 := 0x0:bv32;
      var var2_4198980_bv32:bv32 := 0x0:bv32;
      var var2_4198980_bv32:bv32 := 0x0:bv32;
      goto (%p9open_57);
   ];
   block %p9open_57 [ goto (%p9open_55,%p9open_53); ];
   block %p9open_53 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, var1_4198980_bv32:bv32);
      goto (%p9open_51);
   ];
   block %p9open_55 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := zero_extend(32, bvadd(var2_4198980_bv32:bv32, 0x1:bv32));
      goto (%p9open_51);
   ];
   block %p9open_51 [
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x6:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x30:bv64) extract(16,0, $R3:bv64) 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x32:bv64) 0x0:bv16 16;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x38:bv64) 0x0:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x38:bv64), 0x8:bv64) 0x0:bv64 64;
      $R30:bv64 := 0x40125c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400cc0:bv64;
      goto (%FUN_400cc0_entry_51);
   ];
   block %FUN_400cc0_entry_51 [
      var R30_begin_FUN_400cc0_4197568_13:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400cc0:bv64);
      $_PC:bv64 := 0x400cc0:bv64;
      assert eq($_PC:bv64, 0x400cc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197572_bv64_14:bv64 := 0x0:bv64;
      var var1_4197572_bv64_14:bv64 := $R16:bv64;
      var var2_4197572_bv64_15:bv64 := 0x0:bv64;
      var var2_4197572_bv64_15:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197572_bv64_14:bv64,
       0x90:bv64) 64;
      $R17:bv64 := var2_4197572_bv64_15:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197576_bv64_16:bv64 := 0x0:bv64;
      var var2_4197576_bv64_17:bv64 := 0x0:bv64;
      var var2_4197576_bv64_17:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197576_bv64_17:bv64, 0x90:bv64);
      var var1_4197580_bv64_18:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400cc0_4197568_13:bv64);
      
      call @fcntl64();
      goto (%FUN_400cc0_basil_return_1_52);
   ];
   block %FUN_400cc0_basil_return_1_52 [ goto (%_inlineret_5); ];
   block %_inlineret_5 [ goto (%p9open_49); ];
   block %p9open_49 [
      assert eq($_PC:bv64, 0x40125c:bv64);
      goto (%p9open_47,%p9open_39);
   ];
   block %p9open_39 [
      guard eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401220:bv64;
      goto (%p9open_37);
   ];
   block %p9open_47 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401260:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199008_bv32:bv32 := 0x0:bv32;
      var var1_4199008_bv32:bv32 := 0x0:bv32;
      var var2_4199008_bv32:bv32 := 0x0:bv32;
      var var2_4199008_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4199008_bv32:bv32, bvshl(var2_4199008_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x401268:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c50:bv64;
      goto (%FUN_400c50_entry_49);
   ];
   block %FUN_400c50_entry_49 [
      var R30_begin_FUN_400c50_4197456_7:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c50:bv64);
      $_PC:bv64 := 0x400c50:bv64;
      assert eq($_PC:bv64, 0x400c50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197460_bv64_8:bv64 := 0x0:bv64;
      var var1_4197460_bv64_8:bv64 := $R16:bv64;
      var var2_4197460_bv64_9:bv64 := 0x0:bv64;
      var var2_4197460_bv64_9:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197460_bv64_8:bv64,
       0x58:bv64) 64;
      $R17:bv64 := var2_4197460_bv64_9:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197464_bv64_10:bv64 := 0x0:bv64;
      var var2_4197464_bv64_11:bv64 := 0x0:bv64;
      var var2_4197464_bv64_11:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197464_bv64_11:bv64, 0x58:bv64);
      var var1_4197468_bv64_12:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c50_4197456_7:bv64);
      
      call @close();
      goto (%FUN_400c50_basil_return_1_50);
   ];
   block %FUN_400c50_basil_return_1_50 [ goto (%_inlineret_4); ];
   block %_inlineret_4 [ goto (%p9open_45); ];
   block %p9open_45 [ goto (%p9open_43); ];
   block %p9open_43 [
      assert eq($_PC:bv64, 0x401268:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R20:bv64 := 0xffffffff:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199024_bv64:bv64 := 0x0:bv64;
      var var2_4199024_bv64:bv64 := 0x0:bv64;
      var var2_4199024_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4199024_bv64:bv64, 0xca8:bv64);
      $R30:bv64 := 0x401278:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401d34:bv64;
      
      call @werrstr_4201780();
      goto (%p9open_41);
   ];
   block %p9open_41 [
      assert eq($_PC:bv64, 0x401278:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401228:bv64;
      goto (%p9open_5);
   ];
   block %p9open_61 [
      guard boolnot(eq(extract(14,13, extract(32,0, $R19:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%p9open_37);
   ];
   block %p9open_37 [
      assert eq($_PC:bv64, 0x401220:bv64);
      goto (%p9open_35,%p9open_27);
   ];
   block %p9open_27 [
      guard eq(extract(6,5, extract(32,0, $R19:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40127c:bv64;
      assert eq($_PC:bv64, 0x40127c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199036_bv32:bv32 := 0x0:bv32;
      var var1_4199036_bv32:bv32 := 0x0:bv32;
      var var2_4199036_bv32:bv32 := 0x0:bv32;
      var var2_4199036_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4199036_bv32:bv32, bvshl(var2_4199036_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x4:bv64;
      $R30:bv64 := 0x40128c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400cc0:bv64;
      goto (%FUN_400cc0_entry_53);
   ];
   block %FUN_400cc0_entry_53 [
      var R30_begin_FUN_400cc0_4197568_19:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400cc0:bv64);
      $_PC:bv64 := 0x400cc0:bv64;
      assert eq($_PC:bv64, 0x400cc0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197572_bv64_20:bv64 := 0x0:bv64;
      var var1_4197572_bv64_20:bv64 := $R16:bv64;
      var var2_4197572_bv64_21:bv64 := 0x0:bv64;
      var var2_4197572_bv64_21:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197572_bv64_20:bv64,
       0x90:bv64) 64;
      $R17:bv64 := var2_4197572_bv64_21:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197576_bv64_22:bv64 := 0x0:bv64;
      var var2_4197576_bv64_23:bv64 := 0x0:bv64;
      var var2_4197576_bv64_23:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197576_bv64_23:bv64, 0x90:bv64);
      var var1_4197580_bv64_24:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400cc0_4197568_19:bv64);
      
      call @fcntl64();
      goto (%FUN_400cc0_basil_return_1_54);
   ];
   block %FUN_400cc0_basil_return_1_54 [ goto (%_inlineret_6); ];
   block %_inlineret_6 [ goto (%p9open_25); ];
   block %p9open_25 [ goto (%p9open_23); ];
   block %p9open_23 [
      assert eq($_PC:bv64, 0x40128c:bv64);
      goto (%p9open_21,%p9open_15);
   ];
   block %p9open_15 [
      guard eq(extract(7,6, extract(32,0, $R19:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401228:bv64;
      goto (%p9open_5);
   ];
   block %p9open_21 [
      guard boolnot(eq(extract(7,6, extract(32,0, $R19:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%p9open_19);
   ];
   block %p9open_35 [
      guard boolnot(eq(extract(6,5, extract(32,0, $R19:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401224:bv64);
      goto (%p9open_33);
   ];
   block %p9open_33 [ goto (%p9open_31,%p9open_29); ];
   block %p9open_29 [
      guard eq(extract(7,6, extract(32,0, $R19:bv64)), 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401290:bv64;
      goto (%p9open_19);
   ];
   block %p9open_31 [
      guard boolnot(eq(extract(7,6, extract(32,0, $R19:bv64)), 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%p9open_5);
   ];
   block %p9open_19 [
      assert eq($_PC:bv64, 0x401290:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199056_bv64:bv64 := 0x0:bv64;
      var var1_4199056_bv64:bv64 := 0x0:bv64;
      var var2_4199056_bv64:bv64 := 0x0:bv64;
      var var2_4199056_bv64:bv64 := $R21:bv64;
      $R0:bv64 := bvor(var1_4199056_bv64:bv64,
       bvshl(var2_4199056_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x401298:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400bf0:bv64;
      goto (%FUN_400bf0_entry_55);
   ];
   block %FUN_400bf0_entry_55 [
      var R30_begin_FUN_400bf0_4197360_25:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400bf0:bv64);
      $_PC:bv64 := 0x400bf0:bv64;
      assert eq($_PC:bv64, 0x400bf0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197364_bv64_26:bv64 := 0x0:bv64;
      var var1_4197364_bv64_26:bv64 := $R16:bv64;
      var var2_4197364_bv64_27:bv64 := 0x0:bv64;
      var var2_4197364_bv64_27:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197364_bv64_26:bv64,
       0x28:bv64) 64;
      $R17:bv64 := var2_4197364_bv64_27:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197368_bv64_28:bv64 := 0x0:bv64;
      var var2_4197368_bv64_29:bv64 := 0x0:bv64;
      var var2_4197368_bv64_29:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197368_bv64_29:bv64, 0x28:bv64);
      var var1_4197372_bv64_30:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400bf0_4197360_25:bv64);
      
      call @remove();
      goto (%FUN_400bf0_basil_return_1_56);
   ];
   block %FUN_400bf0_basil_return_1_56 [ goto (%_inlineret_7); ];
   block %_inlineret_7 [ goto (%p9open_17); ];
   block %p9open_17 [
      assert eq($_PC:bv64, 0x401298:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199064_bv64:bv64 := 0x0:bv64;
      var var1_4199064_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4199064_bv64:bv64 := 0x0:bv64;
      var var2_4199064_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4199064_bv64:bv64;
      $R22:bv64 := var2_4199064_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199068_bv32:bv32 := 0x0:bv32;
      var var1_4199068_bv32:bv32 := 0x0:bv32;
      var var2_4199068_bv32:bv32 := 0x0:bv32;
      var var2_4199068_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4199068_bv32:bv32, bvshl(var2_4199068_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199072_bv64:bv64 := 0x0:bv64;
      var var1_4199072_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4199072_bv64:bv64 := 0x0:bv64;
      var var2_4199072_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4199072_bv64:bv64;
      $R20:bv64 := var2_4199072_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4199076_bv64:bv64 := 0x0:bv64;
      var var1_4199076_bv64:bv64 := $R31:bv64;
      var var2_4199076_bv64:bv64 := 0x0:bv64;
      var var2_4199076_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4199076_bv64:bv64 := 0x0:bv64;
      var var3_4199076_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4199076_bv64:bv64;
      $R30:bv64 := var3_4199076_bv64:bv64;
      $R31:bv64 := bvadd(var1_4199076_bv64:bv64, 0x50:bv64);
      var var1_4199080_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%p9open_basil_return_1);
   ];
   block %p9open_5 [
      assert eq($_PC:bv64, 0x401228:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198952_bv64:bv64 := 0x0:bv64;
      var var1_4198952_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4198952_bv64:bv64 := 0x0:bv64;
      var var2_4198952_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4198952_bv64:bv64;
      $R22:bv64 := var2_4198952_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198956_bv32:bv32 := 0x0:bv32;
      var var1_4198956_bv32:bv32 := 0x0:bv32;
      var var2_4198956_bv32:bv32 := 0x0:bv32;
      var var2_4198956_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4198956_bv32:bv32, bvshl(var2_4198956_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198960_bv64:bv64 := 0x0:bv64;
      var var1_4198960_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4198960_bv64:bv64 := 0x0:bv64;
      var var2_4198960_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4198960_bv64:bv64;
      $R20:bv64 := var2_4198960_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198964_bv64:bv64 := 0x0:bv64;
      var var1_4198964_bv64:bv64 := $R31:bv64;
      var var2_4198964_bv64:bv64 := 0x0:bv64;
      var var2_4198964_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4198964_bv64:bv64 := 0x0:bv64;
      var var3_4198964_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4198964_bv64:bv64;
      $R30:bv64 := var3_4198964_bv64:bv64;
      $R31:bv64 := bvadd(var1_4198964_bv64:bv64, 0x50:bv64);
      var var1_4198968_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%p9open_basil_return_1);
   ];
   block %p9open_basil_return_1 [ nop; return; ]
];
proc @p9write_4200816()  -> () { .address = 4200816; .name = "p9write";
    .returnBlock = "p9write_basil_return_1" }
  modifies $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1, $R0:bv64,
    $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64,
    $R22:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $_PC:bv64,
    $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R19:bv64, $R2:bv64, $R20:bv64,
    $R21:bv64, $R22:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1,
    $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x401970:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %p9write_entry [
      assert eq($_PC:bv64, 0x401970:bv64);
      $_PC:bv64 := 0x401970:bv64;
      assert eq($_PC:bv64, 0x401970:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200816_bv64:bv64 := 0x0:bv64;
      var var1_4200816_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4200816_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200820_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200828_bv64:bv64 := 0x0:bv64;
      var var2_4200828_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R2:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R2:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      goto (%p9write_35,%p9write_9);
   ];
   block %p9write_9 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4019f0:bv64;
      assert eq($_PC:bv64, 0x4019f0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4019cc:bv64;
      goto (%p9write_7);
   ];
   block %p9write_7 [ goto (%p9write_5); ];
   block %p9write_35 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x401984:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200836_bv64:bv64 := 0x0:bv64;
      var var1_4200836_bv64:bv64 := 0x0:bv64;
      var var2_4200836_bv64:bv64 := 0x0:bv64;
      var var2_4200836_bv64:bv64 := $R2:bv64;
      $R20:bv64 := bvor(var1_4200836_bv64:bv64,
       bvshl(var2_4200836_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200848_bv32:bv32 := 0x0:bv32;
      var var1_4200848_bv32:bv32 := 0x0:bv32;
      var var2_4200848_bv32:bv32 := 0x0:bv32;
      var var2_4200848_bv32:bv32 := extract(32,0, $R0:bv64);
      $R21:bv64 := zero_extend(32,
      bvor(var1_4200848_bv32:bv32, bvshl(var2_4200848_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200852_bv64:bv64 := 0x0:bv64;
      var var1_4200852_bv64:bv64 := 0x0:bv64;
      var var2_4200852_bv64:bv64 := 0x0:bv64;
      var var2_4200852_bv64:bv64 := $R1:bv64;
      $R22:bv64 := bvor(var1_4200852_bv64:bv64,
       bvshl(var2_4200852_bv64:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4019a8:bv64;
      goto (%p9write_33);
   ];
   block %p9write_33 [ goto (%p9write_31); ];
   block %p9write_31 [
      assert eq($_PC:bv64, 0x4019a8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200872_bv64:bv64 := 0x0:bv64;
      var var1_4200872_bv64:bv64 := $R20:bv64;
      var var2_4200872_bv64:bv64 := 0x0:bv64;
      var var2_4200872_bv64:bv64 := $R19:bv64;
      $R2:bv64 := bvadd(bvadd(var1_4200872_bv64:bv64,
        bvnot(bvshl(var2_4200872_bv64:bv64, 0x0:bv64))), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200876_bv64:bv64 := 0x0:bv64;
      var var1_4200876_bv64:bv64 := $R22:bv64;
      var var2_4200876_bv64:bv64 := 0x0:bv64;
      var var2_4200876_bv64:bv64 := $R19:bv64;
      $R1:bv64 := bvadd(var1_4200876_bv64:bv64,
       bvshl(var2_4200876_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200880_bv32:bv32 := 0x0:bv32;
      var var1_4200880_bv32:bv32 := 0x0:bv32;
      var var2_4200880_bv32:bv32 := 0x0:bv32;
      var var2_4200880_bv32:bv32 := extract(32,0, $R21:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4200880_bv32:bv32, bvshl(var2_4200880_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x4019b8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c70:bv64;
      goto (%FUN_400c70_entry_87);
   ];
   block %FUN_400c70_entry_87 [
      var R30_begin_FUN_400c70_4197488_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c70:bv64);
      $_PC:bv64 := 0x400c70:bv64;
      assert eq($_PC:bv64, 0x400c70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197492_bv64_2:bv64 := 0x0:bv64;
      var var1_4197492_bv64_2:bv64 := $R16:bv64;
      var var2_4197492_bv64_3:bv64 := 0x0:bv64;
      var var2_4197492_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197492_bv64_2:bv64,
       0x68:bv64) 64;
      $R17:bv64 := var2_4197492_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197496_bv64_4:bv64 := 0x0:bv64;
      var var2_4197496_bv64_5:bv64 := 0x0:bv64;
      var var2_4197496_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197496_bv64_5:bv64, 0x68:bv64);
      var var1_4197500_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c70_4197488_1:bv64);
      
      call @write();
      goto (%FUN_400c70_basil_return_1_88);
   ];
   block %FUN_400c70_basil_return_1_88 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%p9write_29); ];
   block %p9write_29 [
      assert eq($_PC:bv64, 0x4019b8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200888_bv64:bv64 := 0x0:bv64;
      var var2_4200888_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R0:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R0:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      goto (%p9write_27,%p9write_19);
   ];
   block %p9write_19 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x40199c:bv64;
      assert eq($_PC:bv64, 0x40199c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200860_bv64:bv64 := 0x0:bv64;
      var var1_4200860_bv64:bv64 := $R19:bv64;
      var var2_4200860_bv64:bv64 := 0x0:bv64;
      var var2_4200860_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvadd(var1_4200860_bv64:bv64,
       bvshl(var2_4200860_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200864_bv64:bv64 := 0x0:bv64;
      var var2_4200864_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R20:bv64),
           sign_extend(64, bvnot(bvshl($R19:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R20:bv64),
           zero_extend(64, bvnot(bvshl($R19:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R20:bv64,
          bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R20:bv64,
        bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%p9write_17);
   ];
   block %p9write_17 [ goto (%p9write_15,%p9write_13); ];
   block %p9write_13 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4019dc:bv64;
      assert eq($_PC:bv64, 0x4019dc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200924_bv64:bv64 := 0x0:bv64;
      var var1_4200924_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4200924_bv64:bv64 := 0x0:bv64;
      var var2_4200924_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4200924_bv64:bv64;
      $R22:bv64 := var2_4200924_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200928_bv64:bv64 := 0x0:bv64;
      var var1_4200928_bv64:bv64 := 0x0:bv64;
      var var2_4200928_bv64:bv64 := 0x0:bv64;
      var var2_4200928_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4200928_bv64:bv64,
       bvshl(var2_4200928_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200932_bv64:bv64 := 0x0:bv64;
      var var1_4200932_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4200932_bv64:bv64 := 0x0:bv64;
      var var2_4200932_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4200932_bv64:bv64;
      $R20:bv64 := var2_4200932_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200936_bv64:bv64 := 0x0:bv64;
      var var1_4200936_bv64:bv64 := $R31:bv64;
      var var2_4200936_bv64:bv64 := 0x0:bv64;
      var var2_4200936_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4200936_bv64:bv64 := 0x0:bv64;
      var var3_4200936_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4200936_bv64:bv64;
      $R30:bv64 := var3_4200936_bv64:bv64;
      $R31:bv64 := bvadd(var1_4200936_bv64:bv64, 0x30:bv64);
      var var1_4200940_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%p9write_11);
   ];
   block %p9write_11 [ goto (%p9write_basil_return_1); ];
   block %p9write_15 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%p9write_31);
   ];
   block %p9write_27 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x4019c0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200896_bv64:bv64 := 0x0:bv64;
      var var1_4200896_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4200896_bv64:bv64 := 0x0:bv64;
      var var2_4200896_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4200896_bv64:bv64;
      $R22:bv64 := var2_4200896_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200900_bv64:bv64 := 0x0:bv64;
      var var2_4200900_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R19:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R19:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      var var1_4200904_bv64:bv64 := 0x0:bv64;
      var var1_4200904_bv64:bv64 := $R19:bv64;
      var var2_4200904_bv64:bv64 := 0x0:bv64;
      var var2_4200904_bv64:bv64 := $R0:bv64;
      goto (%p9write_25);
   ];
   block %p9write_25 [ goto (%p9write_23,%p9write_21); ];
   block %p9write_21 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := var1_4200904_bv64:bv64;
      goto (%p9write_5);
   ];
   block %p9write_23 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R19:bv64 := var2_4200904_bv64:bv64;
      goto (%p9write_5);
   ];
   block %p9write_5 [
      assert eq($_PC:bv64, 0x4019cc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200908_bv64:bv64 := 0x0:bv64;
      var var1_4200908_bv64:bv64 := 0x0:bv64;
      var var2_4200908_bv64:bv64 := 0x0:bv64;
      var var2_4200908_bv64:bv64 := $R19:bv64;
      $R0:bv64 := bvor(var1_4200908_bv64:bv64,
       bvshl(var2_4200908_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200912_bv64:bv64 := 0x0:bv64;
      var var1_4200912_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4200912_bv64:bv64 := 0x0:bv64;
      var var2_4200912_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4200912_bv64:bv64;
      $R20:bv64 := var2_4200912_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4200916_bv64:bv64 := 0x0:bv64;
      var var1_4200916_bv64:bv64 := $R31:bv64;
      var var2_4200916_bv64:bv64 := 0x0:bv64;
      var var2_4200916_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4200916_bv64:bv64 := 0x0:bv64;
      var var3_4200916_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4200916_bv64:bv64;
      $R30:bv64 := var3_4200916_bv64:bv64;
      $R31:bv64 := bvadd(var1_4200916_bv64:bv64, 0x30:bv64);
      var var1_4200920_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%p9write_basil_return_1);
   ];
   block %p9write_basil_return_1 [ nop; return; ]
];
proc @read()  -> () { .name = "read" }
  
;
proc @cat_4198032()  -> () { .address = 4198032; .name = "cat";
    .returnBlock = "cat_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x400e90:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %cat_entry [
      var R30_begin_cat_4198032:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400e90:bv64);
      $_PC:bv64 := 0x400e90:bv64;
      assert eq($_PC:bv64, 0x400e90:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R12:bv64 := 0x2030:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198036_bv64:bv64 := 0x0:bv64;
      var var1_4198036_bv64:bv64 := $R31:bv64;
      var var2_4198036_bv64:bv64 := 0x0:bv64;
      $R31:bv64 := bvadd(bvadd(var1_4198036_bv64:bv64, bvnot($R12:bv64)), 0x1:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) $R31:bv64 $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x8:bv64) $R30:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198044_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198052_bv32:bv32 := 0x0:bv32;
      var var1_4198052_bv32:bv32 := 0x0:bv32;
      var var2_4198052_bv32:bv32 := 0x0:bv32;
      var var2_4198052_bv32:bv32 := extract(32,0, $R0:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4198052_bv32:bv32, bvshl(var2_4198052_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198060_bv64:bv64 := 0x0:bv64;
      var var1_4198060_bv64:bv64 := 0x0:bv64;
      var var2_4198060_bv64:bv64 := 0x0:bv64;
      var var2_4198060_bv64:bv64 := $R1:bv64;
      $R21:bv64 := bvor(var1_4198060_bv64:bv64,
       bvshl(var2_4198060_bv64:bv64, 0x0:bv64));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400ec0:bv64;
      goto (%cat_33);
   ];
   block %cat_33 [
      assert eq($_PC:bv64, 0x400ec0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198080_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x2000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198088_bv32:bv32 := 0x0:bv32;
      var var1_4198088_bv32:bv32 := 0x0:bv32;
      var var2_4198088_bv32:bv32 := 0x0:bv32;
      var var2_4198088_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4198088_bv32:bv32, bvshl(var2_4198088_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x400ed0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400ce0:bv64;
      goto (%FUN_400ce0_entry_43);
   ];
   block %FUN_400ce0_entry_43 [
      var R30_begin_FUN_400ce0_4197600_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400ce0:bv64);
      $_PC:bv64 := 0x400ce0:bv64;
      assert eq($_PC:bv64, 0x400ce0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197604_bv64_2:bv64 := 0x0:bv64;
      var var1_4197604_bv64_2:bv64 := $R16:bv64;
      var var2_4197604_bv64_3:bv64 := 0x0:bv64;
      var var2_4197604_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197604_bv64_2:bv64,
       0xa0:bv64) 64;
      $R17:bv64 := var2_4197604_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197608_bv64_4:bv64 := 0x0:bv64;
      var var2_4197608_bv64_5:bv64 := 0x0:bv64;
      var var2_4197608_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197608_bv64_5:bv64, 0xa0:bv64);
      var var1_4197612_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400ce0_4197600_1:bv64);
      
      call @read();
      goto (%FUN_400ce0_basil_return_1_44);
   ];
   block %FUN_400ce0_basil_return_1_44 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%cat_31); ];
   block %cat_31 [
      assert eq($_PC:bv64, 0x400ed0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198096_bv64:bv64 := 0x0:bv64;
      var var1_4198096_bv64:bv64 := 0x0:bv64;
      var var2_4198096_bv64:bv64 := 0x0:bv64;
      var var2_4198096_bv64:bv64 := $R0:bv64;
      $R19:bv64 := bvor(var1_4198096_bv64:bv64,
       bvshl(var2_4198096_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198100_bv64:bv64 := 0x0:bv64;
      $R1:bv64 := bvadd($R31:bv64, 0x30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198104_bv64:bv64 := 0x0:bv64;
      var var1_4198104_bv64:bv64 := 0x0:bv64;
      var var2_4198104_bv64:bv64 := 0x0:bv64;
      var var2_4198104_bv64:bv64 := $R19:bv64;
      $R2:bv64 := bvor(var1_4198104_bv64:bv64,
       bvshl(var2_4198104_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x1:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198112_bv64:bv64 := 0x0:bv64;
      var var2_4198112_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R19:bv64),
           0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R19:bv64), 0xffffffffffffffff:bv128),
          0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64),
         0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64),
       0x1:bv64));
      goto (%cat_29,%cat_17);
   ];
   block %cat_17 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400eb4:bv64;
      assert eq($_PC:bv64, 0x400eb4:bv64);
      $R30:bv64 := 0x400eb8:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401970:bv64;
      
      call @p9write_4200816();
      goto (%cat_15);
   ];
   block %cat_15 [ goto (%cat_13); ];
   block %cat_13 [
      assert eq($_PC:bv64, 0x400eb8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198072_bv64:bv64 := 0x0:bv64;
      var var2_4198072_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R0:bv64),
           sign_extend(64, bvnot(bvshl($R19:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R0:bv64),
           zero_extend(64, bvnot(bvshl($R19:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64,
          bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R0:bv64,
        bvnot(bvshl($R19:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%cat_11,%cat_9);
   ];
   block %cat_9 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400f04:bv64;
      assert eq($_PC:bv64, 0x400f04:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198148_bv64:bv64 := 0x0:bv64;
      var var1_4198148_bv64:bv64 := 0x0:bv64;
      var var2_4198148_bv64:bv64 := 0x0:bv64;
      var var2_4198148_bv64:bv64 := $R21:bv64;
      $R1:bv64 := bvor(var1_4198148_bv64:bv64,
       bvshl(var2_4198148_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198156_bv64:bv64 := 0x0:bv64;
      var var2_4198156_bv64:bv64 := 0x0:bv64;
      var var2_4198156_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4198156_bv64:bv64, 0xc28:bv64);
      $R30:bv64 := 0x400f14:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401870:bv64;
      assert eq($R30:bv64, R30_begin_cat_4198032:bv64);
      
      call @sysfatal_4200560();
      goto (%cat_basil_return_1);
   ];
   block %cat_11 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%cat_33);
   ];
   block %cat_29 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x400ee8:bv64);
      goto (%cat_27);
   ];
   block %cat_27 [ goto (%cat_25,%cat_21); ];
   block %cat_21 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400f18:bv64;
      assert eq($_PC:bv64, 0x400f18:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198168_bv64:bv64 := 0x0:bv64;
      var var1_4198168_bv64:bv64 := 0x0:bv64;
      var var2_4198168_bv64:bv64 := 0x0:bv64;
      var var2_4198168_bv64:bv64 := $R21:bv64;
      $R1:bv64 := bvor(var1_4198168_bv64:bv64,
       bvshl(var2_4198168_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198176_bv64:bv64 := 0x0:bv64;
      var var2_4198176_bv64:bv64 := 0x0:bv64;
      var var2_4198176_bv64:bv64 := $R0:bv64;
      $R0:bv64 := bvadd(var2_4198176_bv64:bv64, 0xc48:bv64);
      $R30:bv64 := 0x400f28:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401870:bv64;
      assert eq($R30:bv64, R30_begin_cat_4198032:bv64);
      
      call @sysfatal_4200560();
      goto (%cat_basil_return_1);
   ];
   block %cat_25 [
      guard eq($ZF:bv1, 0x1:bv1);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x400eec:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198124_bv64:bv64 := 0x0:bv64;
      var var1_4198124_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var2_4198124_bv64:bv64 := 0x0:bv64;
      var var2_4198124_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var1_4198124_bv64:bv64;
      $R30:bv64 := var2_4198124_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R12:bv64 := 0x2030:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198132_bv64:bv64 := 0x0:bv64;
      var var1_4198132_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4198132_bv64:bv64 := 0x0:bv64;
      var var2_4198132_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4198132_bv64:bv64;
      $R20:bv64 := var2_4198132_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198136_bv64:bv64 := 0x0:bv64;
      var var1_4198136_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      $R21:bv64 := var1_4198136_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198140_bv64:bv64 := 0x0:bv64;
      var var1_4198140_bv64:bv64 := $R31:bv64;
      var var2_4198140_bv64:bv64 := 0x0:bv64;
      $R31:bv64 := bvadd(var1_4198140_bv64:bv64, $R12:bv64);
      var var1_4198144_bv64:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x0:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R30:bv64;
      goto (%cat_23);
   ];
   block %cat_23 [ goto (%cat_basil_return_1); ];
   block %cat_basil_return_1 [ nop; return; ]
];
proc @p9main_4198208()  -> () { .address = 4198208; .name = "p9main";
    .returnBlock = "p9main_basil_return_1" }
  modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  captures $mem:(bv64->bv8), $stack:(bv64->bv8), $BTypeNext:bv2, $CF:bv1, $NF:bv1,
    $R0:bv64, $R1:bv64, $R10:bv64, $R11:bv64, $R12:bv64, $R16:bv64, $R17:bv64,
    $R19:bv64, $R2:bv64, $R20:bv64, $R21:bv64, $R22:bv64, $R23:bv64, $R24:bv64,
    $R25:bv64, $R26:bv64, $R27:bv64, $R29:bv64, $R3:bv64, $R30:bv64, $R31:bv64,
    $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64, $R9:bv64, $VF:bv1, $Z0:bv128,
    $Z1:bv128, $Z16:bv128, $Z2:bv128, $Z3:bv128, $Z4:bv128, $Z5:bv128, $Z6:bv128,
    $Z7:bv128, $ZF:bv1, $_PC:bv64, $__BranchTaken:bv1;
  requires eq($_PC:bv64, 0x400f40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));

[
   block %p9main_entry [
      var R30_begin_p9main_4198208:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400f40:bv64);
      $_PC:bv64 := 0x400f40:bv64;
      assert eq($_PC:bv64, 0x400f40:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198208_bv64:bv64 := 0x0:bv64;
      var var1_4198208_bv64:bv64 := $R31:bv64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64,
       0xffffffffffffffd0:bv64) $R29:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64;
      $R31:bv64 := bvadd(var1_4198208_bv64:bv64, 0xffffffffffffffd0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R3:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R2:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198220_bv64:bv64 := 0x0:bv64;
      $R29:bv64 := $R31:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198224_bv64:bv64 := 0x0:bv64;
      var var2_4198224_bv64:bv64 := 0x0:bv64;
      var var2_4198224_bv64:bv64 := $R2:bv64;
      $R2:bv64 := bvadd(var2_4198224_bv64:bv64, 0xc60:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198228_bv64:bv64 := 0x0:bv64;
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R3:bv64, 0x408:bv64) $R2:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198232_bv32:bv32 := 0x0:bv32;
      var var2_4198232_bv32:bv32 := 0x0:bv32;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(sign_extend(32, extract(32,0, $R0:bv64)),
           0xfffffffffffffffe:bv64), 0x1:bv64))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(32,
         bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32)),
         bvadd(bvadd(zero_extend(32, extract(32,0, $R0:bv64)), 0xfffffffe:bv64),
          0x1:bv64))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0:bv64), 0xfffffffe:bv32),
         0x1:bv32), 0x0:bv32));
      $NF:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0:bv64),
        0xfffffffe:bv32), 0x1:bv32));
      goto (%p9main_49,%p9main_15);
   ];
   block %p9main_15 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400fe0:bv64;
      assert eq($_PC:bv64, 0x400fe0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198376_bv64:bv64 := 0x0:bv64;
      var var2_4198376_bv64:bv64 := 0x0:bv64;
      var var2_4198376_bv64:bv64 := $R1:bv64;
      $R1:bv64 := bvadd(var2_4198376_bv64:bv64, 0xc68:bv64);
      $R30:bv64 := 0x400ff0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400e90:bv64;
      
      call @cat_4198032();
      goto (%p9main_13);
   ];
   block %p9main_13 [ goto (%p9main_11); ];
   block %p9main_11 [
      assert eq($_PC:bv64, 0x400ff0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198384_bv64:bv64 := 0x0:bv64;
      var var1_4198384_bv64:bv64 := $R31:bv64;
      var var2_4198384_bv64:bv64 := 0x0:bv64;
      var var2_4198384_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4198384_bv64:bv64 := 0x0:bv64;
      var var3_4198384_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4198384_bv64:bv64;
      $R30:bv64 := var3_4198384_bv64:bv64;
      $R31:bv64 := bvadd(var1_4198384_bv64:bv64, 0x30:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401120:bv64;
      assert eq($R30:bv64, R30_begin_p9main_4198208:bv64);
      
      call @exits_4198688();
      goto (%p9main_basil_return_1);
   ];
   block %p9main_49 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x400f60:bv64);
      goto (%p9main_47);
   ];
   block %p9main_47 [ goto (%p9main_45,%p9main_19); ];
   block %p9main_19 [
      guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400fd4:bv64;
      goto (%p9main_17);
   ];
   block %p9main_45 [
      guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x400f64:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) $R22:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198248_bv32:bv32 := 0x0:bv32;
      var var2_4198248_bv32:bv32 := 0x0:bv32;
      var var2_4198248_bv32:bv32 := extract(32,0, $R0:bv64);
      $R21:bv64 := zero_extend(32,
      bvadd(bvadd(var2_4198248_bv32:bv32, 0xfffffffd:bv32), 0x1:bv32));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198252_bv64:bv64 := 0x0:bv64;
      var var2_4198252_bv64:bv64 := 0x0:bv64;
      var var2_4198252_bv64:bv64 := $R1:bv64;
      $R0:bv64 := bvadd(var2_4198252_bv64:bv64, 0x10:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R22:bv64 := 0x405000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198260_bv64:bv64 := 0x0:bv64;
      var var2_4198260_bv64:bv64 := 0x0:bv64;
      var var2_4198260_bv64:bv64 := $R0:bv64;
      var var3_4198260_bv64:bv64 := 0x0:bv64;
      var var3_4198260_bv64:bv64 := $R21:bv64;
      $R21:bv64 := bvadd(var2_4198260_bv64:bv64,
       zero_extend(29, bvconcat(extract(32,0, var3_4198260_bv64:bv64), 0x0:bv3)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198264_bv64:bv64 := 0x0:bv64;
      var var2_4198264_bv64:bv64 := 0x0:bv64;
      var var2_4198264_bv64:bv64 := $R22:bv64;
      $R22:bv64 := bvadd(var2_4198264_bv64:bv64, 0xc70:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) $R20:bv64 64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198272_bv64:bv64 := 0x0:bv64;
      var var2_4198272_bv64:bv64 := 0x0:bv64;
      var var2_4198272_bv64:bv64 := $R1:bv64;
      $R19:bv64 := bvadd(var2_4198272_bv64:bv64, 0x8:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400fa0:bv64;
      goto (%p9main_43);
   ];
   block %p9main_43 [ goto (%p9main_41); ];
   block %p9main_41 [
      assert eq($_PC:bv64, 0x400fa0:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198304_bv64:bv64 := 0x0:bv64;
      var var1_4198304_bv64:bv64 := $R19:bv64;
      var var2_4198304_bv64:bv64 := 0x0:bv64;
      var var2_4198304_bv64:bv64 := load le $mem:(bv64->bv8) var1_4198304_bv64:bv64 64;
      $R0:bv64 := var2_4198304_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R1:bv64 := 0x0:bv64;
      $R30:bv64 := 0x400fac:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x4011b0:bv64;
      
      call @p9open_4198832();
      goto (%p9main_39);
   ];
   block %p9main_39 [
      assert eq($_PC:bv64, 0x400fac:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198316_bv32:bv32 := 0x0:bv32;
      var var1_4198316_bv32:bv32 := 0x0:bv32;
      var var2_4198316_bv32:bv32 := 0x0:bv32;
      var var2_4198316_bv32:bv32 := extract(32,0, $R0:bv64);
      $R20:bv64 := zero_extend(32,
      bvor(var1_4198316_bv32:bv32, bvshl(var2_4198316_bv32:bv32, 0x0:bv32)));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198320_bv64:bv64 := 0x0:bv64;
      var var1_4198320_bv64:bv64 := $R19:bv64;
      var var2_4198320_bv64:bv64 := 0x0:bv64;
      var var2_4198320_bv64:bv64 := load le $mem:(bv64->bv8) var1_4198320_bv64:bv64 64;
      $R1:bv64 := var2_4198320_bv64:bv64;
      goto (%p9main_37,%p9main_33);
   ];
   block %p9main_33 [
      guard eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400f88:bv64;
      assert eq($_PC:bv64, 0x400f88:bv64);
      $R30:bv64 := 0x400f8c:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400e90:bv64;
      
      call @cat_4198032();
      goto (%p9main_31);
   ];
   block %p9main_31 [ goto (%p9main_29); ];
   block %p9main_29 [
      assert eq($_PC:bv64, 0x400f8c:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198284_bv64:bv64 := 0x0:bv64;
      var var2_4198284_bv64:bv64 := 0x0:bv64;
      var var2_4198284_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4198284_bv64:bv64, 0x8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198288_bv32:bv32 := 0x0:bv32;
      var var1_4198288_bv32:bv32 := 0x0:bv32;
      var var2_4198288_bv32:bv32 := 0x0:bv32;
      var var2_4198288_bv32:bv32 := extract(32,0, $R20:bv64);
      $R0:bv64 := zero_extend(32,
      bvor(var1_4198288_bv32:bv32, bvshl(var2_4198288_bv32:bv32, 0x0:bv32)));
      $R30:bv64 := 0x400f98:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400c50:bv64;
      goto (%FUN_400c50_entry_47);
   ];
   block %FUN_400c50_entry_47 [
      var R30_begin_FUN_400c50_4197456_1:bv64 := $R30:bv64;
      assert eq($_PC:bv64, 0x400c50:bv64);
      $_PC:bv64 := 0x400c50:bv64;
      assert eq($_PC:bv64, 0x400c50:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R16:bv64 := 0x420000:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197460_bv64_2:bv64 := 0x0:bv64;
      var var1_4197460_bv64_2:bv64 := $R16:bv64;
      var var2_4197460_bv64_3:bv64 := 0x0:bv64;
      var var2_4197460_bv64_3:bv64 := load le $mem:(bv64->bv8) bvadd(var1_4197460_bv64_2:bv64,
       0x58:bv64) 64;
      $R17:bv64 := var2_4197460_bv64_3:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4197464_bv64_4:bv64 := 0x0:bv64;
      var var2_4197464_bv64_5:bv64 := 0x0:bv64;
      var var2_4197464_bv64_5:bv64 := $R16:bv64;
      $R16:bv64 := bvadd(var2_4197464_bv64_5:bv64, 0x58:bv64);
      var var1_4197468_bv64_6:bv64 := 0x0:bv64;
      $BTypeNext:bv2 := 0x1:bv2;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := $R17:bv64;
      assert eq($R30:bv64, R30_begin_FUN_400c50_4197456_1:bv64);
      
      call @close();
      goto (%FUN_400c50_basil_return_1_48);
   ];
   block %FUN_400c50_basil_return_1_48 [ goto (%_inlineret_3); ];
   block %_inlineret_3 [ goto (%p9main_27); ];
   block %p9main_27 [
      assert eq($_PC:bv64, 0x400f98:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198296_bv64:bv64 := 0x0:bv64;
      var var2_4198296_bv64:bv64 := 0x0:bv64;
      $VF:bv1 := bvnot(booltobv1(eq(sign_extend(64,
         bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(sign_extend(64, $R19:bv64),
           sign_extend(64, bvnot(bvshl($R21:bv64, 0x0:bv64)))), 0x1:bv128))));
      $CF:bv1 := bvnot(booltobv1(eq(zero_extend(64,
         bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, 0x0:bv64))), 0x1:bv64)),
         bvadd(bvadd(zero_extend(64, $R19:bv64),
           zero_extend(64, bvnot(bvshl($R21:bv64, 0x0:bv64)))), 0x1:bv128))));
      $ZF:bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64,
          bvnot(bvshl($R21:bv64, 0x0:bv64))), 0x1:bv64), 0x0:bv64));
      $NF:bv1 := extract(64,63, bvadd(bvadd($R19:bv64,
        bvnot(bvshl($R21:bv64, 0x0:bv64))), 0x1:bv64));
      goto (%p9main_25,%p9main_23);
   ];
   block %p9main_23 [
      guard eq($ZF:bv1, 0x1:bv1);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x400fcc:bv64;
      goto (%p9main_21);
   ];
   block %p9main_21 [
      assert eq($_PC:bv64, 0x400fcc:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198348_bv64:bv64 := 0x0:bv64;
      var var1_4198348_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x10:bv64) 64;
      var var2_4198348_bv64:bv64 := 0x0:bv64;
      var var2_4198348_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x10:bv64), 0x8:bv64) 64;
      $R19:bv64 := var1_4198348_bv64:bv64;
      $R20:bv64 := var2_4198348_bv64:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198352_bv64:bv64 := 0x0:bv64;
      var var1_4198352_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x20:bv64) 64;
      var var2_4198352_bv64:bv64 := 0x0:bv64;
      var var2_4198352_bv64:bv64 := load le $stack:(bv64->bv8) bvadd(bvadd($R31:bv64,
        0x20:bv64), 0x8:bv64) 64;
      $R21:bv64 := var1_4198352_bv64:bv64;
      $R22:bv64 := var2_4198352_bv64:bv64;
      goto (%p9main_17);
   ];
   block %p9main_25 [
      guard boolnot(eq($ZF:bv1, 0x1:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      goto (%p9main_41);
   ];
   block %p9main_37 [
      guard boolnot(eq(extract(32,31, extract(32,0, $R0:bv64)), 0x0:bv1));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      assert eq($_PC:bv64, 0x400fb8:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198328_bv64:bv64 := 0x0:bv64;
      var var1_4198328_bv64:bv64 := 0x0:bv64;
      var var2_4198328_bv64:bv64 := 0x0:bv64;
      var var2_4198328_bv64:bv64 := $R22:bv64;
      $R0:bv64 := bvor(var1_4198328_bv64:bv64,
       bvshl(var2_4198328_bv64:bv64, 0x0:bv64));
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198332_bv64:bv64 := 0x0:bv64;
      var var2_4198332_bv64:bv64 := 0x0:bv64;
      var var2_4198332_bv64:bv64 := $R19:bv64;
      $R19:bv64 := bvadd(var2_4198332_bv64:bv64, 0x8:bv64);
      $R30:bv64 := 0x400fc4:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401870:bv64;
      assert eq($R30:bv64, R30_begin_p9main_4198208:bv64);
      
      call @sysfatal_4200560();
      goto (%p9main_basil_return_1);
   ];
   block %p9main_17 [
      assert eq($_PC:bv64, 0x400fd4:bv64);
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      $R0:bv64 := 0x0:bv64;
      $_PC:bv64 := bvadd($_PC:bv64, 0x4:bv64);
      var var1_4198360_bv64:bv64 := 0x0:bv64;
      var var1_4198360_bv64:bv64 := $R31:bv64;
      var var2_4198360_bv64:bv64 := 0x0:bv64;
      var var2_4198360_bv64:bv64 := load le $stack:(bv64->bv8) $R31:bv64 64;
      var var3_4198360_bv64:bv64 := 0x0:bv64;
      var var3_4198360_bv64:bv64 := load le $stack:(bv64->bv8) bvadd($R31:bv64,
       0x8:bv64) 64;
      $R29:bv64 := var2_4198360_bv64:bv64;
      $R30:bv64 := var3_4198360_bv64:bv64;
      $R31:bv64 := bvadd(var1_4198360_bv64:bv64, 0x30:bv64);
      $__BranchTaken:bv1 := 0x1:bv1;
      $_PC:bv64 := 0x401120:bv64;
      assert eq($R30:bv64, R30_begin_p9main_4198208:bv64);
      
      call @exits_4198688();
      goto (%p9main_basil_return_1);
   ];
   block %p9main_basil_return_1 [ nop; return; ]
];