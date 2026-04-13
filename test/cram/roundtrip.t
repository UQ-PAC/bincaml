
  $ bincaml script roundtrip.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)
  (load-il ../../examples/x-output.il)
  (dump-il before2.il)
  (load-il before2.il)
  (dump-il after2.il)
  ()
  (load-il memassign.il)
  (dump-il beforemem.il)
  (load-il beforemem.il)
  bincaml: Error in (load-il beforemem.il): Parse error:  beforemem.il:7
           7 | type $a : UninterpSort = (UninterpSort)();
                    ^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:109
  [123]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  16c16
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  18c18
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  118c118
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  122c122
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  124c124
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  [1]

  $ diff before2.il after2.il
  7,8c7,8
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $mem:(bv64->bv8), $stack:(bv64->bv8), $mem:(bv64->bv8)
  [1]

Memassign repr

  $ diff beforemem.il aftermem.il
  diff: aftermem.il: No such file or directory
  [2]
  $ cat aftermem.il
  cat: aftermem.il: No such file or directory
  [1]


Record and Pointer

  $ diff ptrrec1.il ptrrec2.il
  diff: ptrrec2.il: No such file or directory
  [2]
  $ diff ptrrec2.il ptrrec3.il
  diff: ptrrec2.il: No such file or directory
  diff: ptrrec3.il: No such file or directory
  [2]
