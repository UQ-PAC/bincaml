
  $ bincaml script roundtrip.sexp
  bincaml: Error in (load-il before.il): Parse error:  before.il:17
           17 |   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $CF:bv1, $NF:bv1, $R0:bv64,
                  ^^^^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
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

