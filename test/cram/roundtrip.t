
  $ ../../bin/main.exe script roundtrip.sexp
  info: internal error, uncaught exception:
        Parse error: before.il
        
        Raised at Loader__Loadir.concrete_prog_ast_of_channel in file "lib/loadir.ml", line 687, characters 27-66
        Called from Trace_subscriber.collector.M.with_span in file "src/subscriber/trace_subscriber.ml", line 96, characters 16-22
        Re-raised at Trace_subscriber.collector.M.with_span in file "src/subscriber/trace_subscriber.ml", line 102, characters 8-44
        Called from Trace_core.with_span in file "src/core/trace_core.ml" (inlined), lines 46-47, characters 4-7
        Called from Loader__Loadir.ast_of_channel in file "lib/loadir.ml", lines 808-810, characters 4-5
        Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
        Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
        Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
        Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
        Called from Dune__exe__Script.of_cmd.(fun) in file "bin/script.ml", line 45, characters 18-50
        Called from Trace_subscriber.collector.M.with_span in file "src/subscriber/trace_subscriber.ml", line 96, characters 16-22
        Re-raised at Trace_subscriber.collector.M.with_span in file "src/subscriber/trace_subscriber.ml", line 102, characters 8-44
        Called from Iter.fold.(fun) in file "src/Iter.ml", line 77, characters 23-31
        Called from CCIO.gen_iter in file "src/core/CCIO.pp.ml", line 48, characters 4-7
        Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
        Called from Dune__exe__Main.run_script.(fun) in file "bin/main.ml", line 63, characters 18-70
        Called from CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 99, characters 14-17
        Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
        Re-raised at CCIO.finally_ in file "src/core/CCIO.pp.ml" (inlined), line 104, characters 4-11
        Called from CCIO.with_in in file "src/core/CCIO.pp.ml", line 108, characters 2-27
        Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
        Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  [125]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  diff: after.il: No such file or directory
  [2]
