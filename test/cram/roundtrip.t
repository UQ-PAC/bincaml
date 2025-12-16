
  $ ../../bin/main.exe script roundtrip.sexp

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  115c115
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]
