
  $ dune exec bincaml -- dump-il memassign.il --proc '@main_4196164' | grep Global --before-context 1 --after-context 1
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
           Called from Dune__exe__Main.dump_proc in file "bin/main.ml", line 34, characters 12-44
           Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 19-24
           Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 41, characters 7-16
  [1]
