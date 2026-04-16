
  $ bincaml script roundtrip.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)
  (load-il ../../examples/x-output.il)
  (dump-il before2.il)
  (load-il before2.il)
  (dump-il after2.il)
  (load-il memassign.il)
  bincaml: internal error, uncaught exception:
           Failure("already declared: A")
           Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
           Called from Lang__Program.decl_typ.(fun) in file "lib/lang/program.ml", line 318, characters 30-61
           Called from Stdlib__List.map in file "list.ml", line 86, characters 15-19
           Called from Lang__Program.decl_typ in file "lib/lang/program.ml", lines 316-327, characters 12-19
           Called from Loader__Loadir.map_prog in file "lib/loadir.ml", line 38, characters 37-45
           Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
           Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
           Called from Loader__Loadir.BasilASTLoader.trans_program in file "lib/loadir.ml", line 113, characters 10-60
           Called from Loader__Loadir.ast_of_concrete_ast.(fun) in file "lib/loadir.ml", line 1453, characters 10-51
           Called from Trace_core.with_current_span_set_to in file "src/core/trace_core.ml" (inlined), line 47, characters 16-20
           Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 74, characters 4-33
           Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 82, characters 4-40
           Called from Loader__Loadir.ast_of_channel in file "lib/loadir.ml", line 1479, characters 6-44
           Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Called from Dune__exe__Script.of_cmd.(fun) in file "bin/script.ml", line 130, characters 27-76
           Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
           Called from Dune__exe__Script.of_cmd.(fun) in file "bin/script.ml", lines 128-132, characters 14-47
           Called from Trace_core.with_current_span_set_to in file "src/core/trace_core.ml" (inlined), line 47, characters 16-20
           Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 74, characters 4-33
           Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 82, characters 4-40
           Called from Iter.fold.(fun) in file "src/Iter.ml", line 77, characters 23-31
           Called from CCIO.gen_iter in file "src/core/CCIO.pp.ml", line 48, characters 4-7
           Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
           Called from Dune__exe__Main.run_script.(fun) in file "bin/main.ml", line 34, characters 12-64
           Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
           Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
           Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 19-24
           Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 41, characters 7-16
  [125]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  117c117
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]

  $ diff before2.il after2.il

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
