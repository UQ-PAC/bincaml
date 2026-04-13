

Should output no errors

  $  bincaml script expr_smt_check.sexp 
  ()
  (load-il ../../examples/cntlm-output.il)
  (run-transforms cf-expressions-smtcheck)
  ()
  ()
  (load-il concat.il)
  Warn: global undeclared $__BranchTaken assuming mutable unshared
  (dump-il before.il)
  (run-transforms cf-expressions-smtcheck)
  (dump-il after.il)

Check concat rewrites work

  $ diff before.il after.il
  17,80c17
  <      $R28:bv64 := bvor(bvand(bvconcat(extract(1,0, bvlshr(var1_4206396_bv64,
  <          0x1f:bv64)), extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64)),
  <         extract(1,0, bvlshr(var1_4206396_bv64, 0x1f:bv64))),
  ---
  >      $R28:bv64 := bvor(bvand(sign_extend(63, extract(32,31, var1_4206396_bv64)),
  82,83c19
  <       bvand(bvor(0x0:bv64, bvand(var1_4206396_bv64, 0xffffffff:bv64)),
  <        0xffffffff:bv64));
  ---
  >       bvand(bvand(var1_4206396_bv64, 0xffffffff:bv64), 0xffffffff:bv64));
  [1]
