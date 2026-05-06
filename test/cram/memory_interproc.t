  $ bincaml script memory_interproc.sexp
  (load-il ../../examples/memory/memory_interproc.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms inter-function-summaries)
  (dump-il after.il)
  (dump-boogie out.bpl)
  $ boogie out.bpl
  
  Boogie program verifier finished with 2 verified, 0 errors
