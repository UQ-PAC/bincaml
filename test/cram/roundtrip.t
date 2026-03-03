
  $ bincaml script roundtrip.sexp

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  15,18c15,18
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1;
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1;
  ---
  >   modifies $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64, $R29:bv64,
  >     $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8);
  >   captures $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64, $R1:bv64, $R29:bv64,
  >     $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8);
  121c121
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]

  $ diff before2.il after2.il
  7,8c7,8
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8);
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8);
  ---
  >   modifies $stack:(bv64->bv8), $mem:(bv64->bv8);
  >   captures $stack:(bv64->bv8), $mem:(bv64->bv8);
  [1]

Memassign repr

  $ diff beforemem.il aftermem.il

