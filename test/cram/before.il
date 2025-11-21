var $R29:bv64;
var $ZF:bv1;
var $R1:bv64;
memory $stack:(bv64->bv8);
var $R31:bv64;
var $R0:bv64;
var $VF:bv1;
memory $mem:(bv64->bv8);
var $CF:bv1;
var $NF:bv1;
var $R30:bv64;
prog entry @main_1876;
proc @main_1876()  -> ()
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
   block %main_27 [
      guard eq(booltobv1(eq($ZF:bv1, 0x1:bv1)), 0x0:bv1);
      goto (%main_25);
      ];
   block %main_25 [ goto (%main_5); ];
   block %main_23 [
      guard neq(booltobv1(eq($ZF:bv1, 0x1:bv1)), 0x0:bv1);
      goto (%main_21);
      ];
   block %main_21 [ goto (%main_19); ];
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
   block %main_basil_return_1 [ nop; return(); ]
];
proc @puts_1584()  -> ()
[  ];