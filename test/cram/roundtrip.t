
  $ bincaml script roundtrip.sexp
  bincaml: Error in (load-il ../../examples/irreducible_loop_1.il): Parse error:  ../../examples/irreducible_loop_1.il:20
           20 |     store le $stack #4:bv64 $R29:bv64 64 { .label = "%00000360" };
                    ^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  diff: before.il: No such file or directory
  diff: after.il: No such file or directory
  [2]

  $ diff before2.il after2.il
  diff: before2.il: No such file or directory
  diff: after2.il: No such file or directory
  [2]

Memassign repr

  $ diff beforemem.il aftermem.il
  diff: beforemem.il: No such file or directory
  diff: aftermem.il: No such file or directory
  [2]

