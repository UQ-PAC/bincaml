
  $ bincaml script roundtrip.sexp
  bincaml: internal error, uncaught exception:
           File "lib/loadir.ml", line 959, characters 4-9: Pattern matching failed
           Raised at Loader__Loadir.BasilASTLoader.trans_expr in file "lib/loadir.ml", lines 959-1089, characters 4-36
           Called from Loader__Loadir.BasilASTLoader.create_fun in file "lib/loadir.ml", line 279, characters 27-46
           Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
           Called from Loader__Loadir.BasilASTLoader.trans_program.(fun) in file "lib/loadir.ml", line 113, characters 10-56
           Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 49, characters 8-12
           Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 56, characters 4-40
           Called from Loader__Loadir.ast_of_channel in file "lib/loadir.ml", line 1364, characters 6-44
           Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Called from Dune__exe__Script.of_cmd.(fun) in file "bin/script.ml", line 75, characters 27-76
           Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
           Called from Dune__exe__Script.of_cmd.(fun) in file "bin/script.ml", lines 73-77, characters 14-47
           Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 49, characters 8-12
           Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 56, characters 4-40
           Called from Iter.fold.(fun) in file "src/Iter.ml", line 77, characters 23-31
           Called from CCIO.gen_iter in file "src/core/CCIO.pp.ml", line 48, characters 4-7
           Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
           Called from Dune__exe__Main.run_script.(fun) in file "bin/main.ml", line 68, characters 18-70
           Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 19-24
           Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 41, characters 7-16
  [125]

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
  121c121
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  125c125
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  127c127
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  [1]

  $ diff before2.il after2.il
  7,8c7,8
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $stack:(bv64->bv8), $mem:(bv64->bv8)
  [1]

Memassign repr

  $ diff beforemem.il aftermem.il
  diff: beforemem.il: No such file or directory
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
