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
      out.bpl(194,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(239,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(274,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(323,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(371,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 5 errors

  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms ssa)
  >  (run-transforms flat-memory-encoding)
  >  (run-transforms memory-specification)
  >  (run-transforms ssa)
  >  (run-transforms linear-const)
  >  (run-transforms linear-copy)
  >  (run-transforms "dynamic-single-assignment")
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
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  (dump-boogie out.bpl)

  $ boogie out.bpl
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(230,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(275,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(275,3): b#inputs
  out.bpl(281,5): Error: a precondition for this call could not be proved
  out.bpl(150,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(275,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(310,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(359,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(407,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
