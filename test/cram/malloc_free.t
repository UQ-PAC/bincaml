  $ bincaml script malloc_free.sexp
  (load-il ../../examples/memory/malloc_free.il)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (dump-boogie good.bpl)
  ()
  (load-il ../../examples/memory/malloc_free_oob.il)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (dump-boogie bad.bpl)

  $ cat ./good.bpl

  $ boogie ./good.bpl
  
  Boogie program verifier finished with 1 verified, 0 errors

  $ cat ./bad.bpl
  $ boogie ./bad.bpl
  
  Boogie program verifier finished with 0 verified, 1 error
