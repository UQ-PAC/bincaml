
var $R28:bv64;
var $R0:bv64;
var $R30:bv64;

prog entry @main_4204352;
proc @main_4204352()  -> () [
   block %main_2045 [
      var var1_4206392_bv32:bv32 := 0x0:bv32;
      var var2_4206392_bv32:bv32 := 0x0:bv32;
      var var2_4206392_bv32:bv32 := extract(32,0, $R0:bv64);
      $R28:bv64 := zero_extend(32, bvadd(var2_4206392_bv32:bv32, 0x3:bv32));
      var var1_4206396_bv64:bv64 := 0x0:bv64;
      var var1_4206396_bv64:bv64 := $R28:bv64;
      $R28:bv64 := bvor(bvand(bvconcat(extract(1,0, bvlshr(var1_4206396_bv64:bv64,
          0x1f:bv64)), extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64))),
        0xffffffff00000000:bv64),
       bvand(bvor(0x0:bv64, bvand(var1_4206396_bv64:bv64, 0xffffffff:bv64)),
        0xffffffff:bv64));
      var var1_4206400_bv64:bv64 := 0x0:bv64;
      var var1_4206400_bv64:bv64 := 0x0:bv64;
      var var2_4206400_bv64:bv64 := 0x0:bv64;
      var var2_4206400_bv64:bv64 := $R28:bv64;
      $R0:bv64 := bvor(var1_4206400_bv64:bv64,
       bvshl(var2_4206400_bv64:bv64, 0x0:bv64));
      $R30:bv64 := 0x402f48:bv64;
      $__BranchTaken:bv1 := 0x1:bv1;
      goto (%main_basil_return_1);
   ];
   block %main_basil_return_1 [ nop; return; ]

   ];
