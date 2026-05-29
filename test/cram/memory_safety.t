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


