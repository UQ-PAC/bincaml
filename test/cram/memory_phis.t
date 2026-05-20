  $ bincaml script memory_phis.sexp
  (load-il memory_phis.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  (dump-boogie out.bpl)

Expect 3 verified, 2 errors.
  $ boogie ./out.bpl
  ./out.bpl(191,5): Error: a postcondition could not be proved on this return path
  ./out.bpl(156,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      ./out.bpl(170,3): b#inputs
      ./out.bpl(176,3): b#c
      ./out.bpl(187,3): b#d
  ./out.bpl(284,5): Error: a precondition for this call could not be proved
  ./out.bpl(107,3): Related location: this is the precondition that could not be proved
  Execution trace:
      ./out.bpl(263,3): b#inputs
      ./out.bpl(269,3): b#c
      ./out.bpl(280,3): b#d
  
  Boogie program verifier finished with 3 verified, 2 errors
