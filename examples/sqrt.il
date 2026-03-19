var $stack:(bv64->bv8);
prog entry @Sqrt_4196228;
proc @Sqrt_4196228(R0_in:bv64, R31_in:bv64)  -> (R0_out:bv64, R1_out:bv64) { .address = 4196228;
    .name = "Sqrt"; .returnBlock = "Sqrt_return" }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)

[
   block %Sqrt_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) R0_in:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 0x0:bv64 64;
      var var1_4196240_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) bvadd(var1_4196240_bv64_2:bv64, 0x1:bv64) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %Sqrt_loop1_18 [
      var var1_4196328_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196336_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      goto (%phi_3,%phi_2);
   ];
   block %phi_2 [
      guard boolnot(eq(var1_4196336_bv64_2:bv64,
        bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64)));
      var var1_4196256_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196260_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      var R0_9:bv64 := bvadd(var1_4196256_bv64_2:bv64, var1_4196260_bv64_2:bv64);
      var R1_7:bv64 := bvand(bvor(bvlshr(R0_9:bv64, 0x3f:bv64),
        bvshl(R0_9:bv64, 0x1:bv64)), 0x1:bv64);
      var R0_10:bv64 := bvadd(R1_7:bv64, R0_9:bv64);
      var R0_11:bv64 := bvor(bvand(sign_extend(63, extract(64,63, R0_10:bv64)),
        0x8000000000000000:bv64),
       bvand(bvor(bvlshr(R0_10:bv64, 0x1:bv64), bvshl(R0_10:bv64, 0x3f:bv64)),
        0x7fffffffffffffff:bv64));
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) extract(32,0, R0_11:bv64) 32;
      var var1_4196284_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      var R0_13:bv64 := zero_extend(32,
      bvmul(var1_4196284_bv32_2:bv32, var1_4196284_bv32_2:bv32));
      var R0_14:bv64 := bvor(bvand(sign_extend(63, extract(32,31, R0_13:bv64)),
        0xffffffff00000000:bv64),
       bvand(bvand(R0_13:bv64, 0xffffffff:bv64), 0xffffffff:bv64));
      var var1_4196296_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      goto (%phi_6,%phi_5);
   ];
   block %phi_5 [
      guard bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64);
      var var1_4196320_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) sign_extend(32, var1_4196320_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_6 [
      guard boolnot(bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64));
      var var1_4196308_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) sign_extend(32, var1_4196308_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_3 [
      guard eq(var1_4196336_bv64_2:bv64, bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64));
      var var1_4196348_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      goto (%Sqrt_return);
   ];
   block %Sqrt_return [
      (var R0_out:bv64 := var1_4196348_bv64_2:bv64,
       var R1_out:bv64 := var1_4196336_bv64_2:bv64);
      return;
   ]
];
