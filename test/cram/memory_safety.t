  $ cat << EOF | bincaml script -
  > (load-il "../../examples/memory/memory_safety.il")
  > (run-transforms "ssa")
  > (run-transforms "split-memory-encoding")
  > (run-transforms "memory-specification")
  > (run-transforms "reconstruct-ssa")
  > (run-transforms "linear-const")
  > (run-transforms "linear-copy")
  > (run-transforms "dynamic-single-assignment")
  > (dump-il "after.il")
  > (dump-boogie "out.bpl")
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms reconstruct-ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  (dump-boogie out.bpl)
  $ boogie out.bpl
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(188,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(238,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(276,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(326,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(375,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 5 errors

  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms "ssa")
  >  (run-transforms "flat-memory-encoding")
  >  (run-transforms "memory-specification")
  >  (run-transforms "reconstruct-ssa")
  >  (run-transforms "linear-const")
  >  (run-transforms "linear-copy")
  >  (run-transforms "dynamic-single-assignment")
  >  (dump-il "after.il")
  >  (dump-boogie "out.bpl")
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms flat-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms reconstruct-ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  (dump-boogie out.bpl)

  $ boogie out.bpl
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(224,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(274,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(274,3): b#inputs
  out.bpl(283,5): Error: a precondition for this call could not be proved
  out.bpl(146,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(274,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(312,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(362,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(411,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
