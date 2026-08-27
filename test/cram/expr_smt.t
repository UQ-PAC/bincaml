

Should output no errors

  $  bincaml script expr_smt_check.sexp 
  (load-il ../../examples/cntlm-output.il)
  (run-transforms cf-expressions-smtcheck)
  (load-il concat.il)
  bincaml: [WARNING] Warn: global undeclared $__BranchTaken assuming mutable unshared 
  (dump-il before.il)
  (run-transforms cf-expressions-smtcheck)
  (dump-il after.il)

Check concat rewrites work

  $ diff before.il after.il
  16,82c16,18
  <      $R28:bv64 := bvor(bvand(bvconcat(extract(1,0, bvlshr(var1_4206396_bv64:bv64,
  <          0x1f:bv64)), extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64:bv64, 0x1f:bv64))),
  <        0xffffffff00000000:bv64),
  <       bvand(bvor(0x0:bv64, bvand(var1_4206396_bv64:bv64, 0xffffffff:bv64)),
  <        0xffffffff:bv64));
  ---
  >      $R28:bv64 := bvor(bvand(sign_extend(63,
  >        extract(32,31, var1_4206396_bv64:bv64)), 0xffffffff00000000:bv64),
  >       bvand(var1_4206396_bv64:bv64, 0xffffffff:bv64));
  87,88c23
  <      $R0:bv64 := bvor(var1_4206400_bv64:bv64,
  <       bvshl(var2_4206400_bv64:bv64, 0x0:bv64));
  ---
  >      $R0:bv64 := bvor(var1_4206400_bv64:bv64, var2_4206400_bv64:bv64);
  [1]
