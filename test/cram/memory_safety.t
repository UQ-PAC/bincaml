  $ bincaml script memory_safety.sexp
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (dump-il after.il)
  (dump-boogie out.bpl)
  $ boogie out.bpl
  out.bpl(193,5): Error: a precondition for this call could not be proved
  out.bpl(112,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(180,3): b#inputs
  out.bpl(224,5): Error: a precondition for this call could not be proved
  out.bpl(111,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(218,3): b#inputs
  out.bpl(265,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(254,3): b#inputs
  out.bpl(303,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(296,3): b#inputs
  out.bpl(355,5): Error: a postcondition could not be proved on this return path
  out.bpl(319,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      out.bpl(337,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 5 errors
