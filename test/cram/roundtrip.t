
  $ ../../bin/main.exe script roundtrip.sexp

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  14,17c14,17
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1;
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1;
  ---
  >   modifies $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
  >     $VF:bv1, $ZF:bv1, $stack:(bv64->bv8), $mem:(bv64->bv8);
  >   captures $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64,
  >     $VF:bv1, $ZF:bv1, $stack:(bv64->bv8), $mem:(bv64->bv8);
  120c120
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]
