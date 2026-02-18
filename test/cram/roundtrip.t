
  $ ../../bin/main.exe script roundtrip.sexp
  bincaml: Error in (load-il before2.il): Error: local variable used before declaration : R0_in
           14 |        0xfffffffffffffffc:bv64) extract(32,0, R0_in) 32;
                                                              ^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:54
  [123]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  121c121
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]

  $ diff before2.il after2.il
  diff: after2.il: No such file or directory
  [2]
