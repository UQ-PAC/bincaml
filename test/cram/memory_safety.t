  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms ssa)
  >  (run-transforms split-memory-encoding)
  >  (run-transforms memory-specification)
  >  (run-transforms ssa)
  >  (run-transforms linear-const)
  >  (run-transforms linear-copy)
  >  (run-transforms dynamic-single-assignment)
  >  (dump-il after.il)
  >  (dump-boogie out.bpl)
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  (dump-boogie out.bpl)
  $ boogie out.bpl
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(190,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(235,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(270,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(319,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(367,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 5 errors

  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms ssa)
  >  (run-transforms flat-memory-encoding)
  >  (run-transforms memory-specification)
  >  (run-transforms ssa)
  >  (run-transforms linear-const)
  >  (run-transforms linear-copy)
  >  (dump-il after.il)
  >  (dump-boogie out.bpl)
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms flat-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (dump-il after.il)
  (dump-boogie out.bpl)

  $ boogie out.bpl
  out.bpl(228,5): Error: a precondition for this call could not be proved
  out.bpl(148,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(215,3): b#inputs
  out.bpl(258,5): Error: a precondition for this call could not be proved
  out.bpl(147,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(252,3): b#inputs
  out.bpl(258,5): Error: a precondition for this call could not be proved
  out.bpl(148,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(252,3): b#inputs
  out.bpl(258,5): Error: a precondition for this call could not be proved
  out.bpl(146,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(252,3): b#inputs
  out.bpl(298,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(287,3): b#inputs
  out.bpl(335,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(328,3): b#inputs
  out.bpl(385,5): Error: a postcondition could not be proved on this return path
  out.bpl(350,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      out.bpl(368,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
