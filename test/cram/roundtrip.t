
  $ ../../bin/main.exe script roundtrip.sexp

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  105c105
  <    block %main_basil_return_1 [ nop; return; ];
  ---
  >    block %main_basil_return_1 [ return; ];
  118c118
  < [ ];
  \ No newline at end of file
  ---
  > [  ];
  \ No newline at end of file
  [1]
