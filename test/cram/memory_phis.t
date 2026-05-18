  $ bincaml script memory_phis.sexp
  (load-il memory_phis.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (dump-il after.il)
  (dump-boogie out.bpl)

Expect 3 verified, 2 errors.
  $ boogie ./out.bpl
  ./out.bpl(185,5): Error: a postcondition could not be proved on this return path
  ./out.bpl(153,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      ./out.bpl(167,3): b#inputs
      ./out.bpl(173,3): b#c
      ./out.bpl(180,3): b#d
  ./out.bpl(275,5): Error: a precondition for this call could not be proved
  ./out.bpl(107,3): Related location: this is the precondition that could not be proved
  Execution trace:
      ./out.bpl(256,3): b#inputs
      ./out.bpl(262,3): b#c
      ./out.bpl(271,3): b#d
  
  Boogie program verifier finished with 3 verified, 2 errors
