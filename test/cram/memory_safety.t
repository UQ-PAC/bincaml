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
      out.bpl(161,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(202,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(241,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(286,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(330,3): b#inputs
  
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
      out.bpl(186,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(227,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(227,3): b#inputs
  out.bpl(233,5): Error: a precondition for this call could not be proved
  out.bpl(115,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(227,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(266,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(311,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(355,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
