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
  (run-transforms flatten-phis)
  (dump-boogie out.bpl)
  $ boogie out.bpl
  out.bpl(222,5): Error: a precondition for this call could not be proved
  out.bpl(101,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(218,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(218,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(218,3): b#inputs
  out.bpl(230,5): Error: a postcondition could not be proved on this return path
  out.bpl(112,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      out.bpl(218,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 4 errors
