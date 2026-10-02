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
      out.bpl(167,3): b#main_entry
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(204,3): b#main_entry
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(229,3): b#main_entry
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(266,3): b#main_entry
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(303,3): b#main_entry
  
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
      out.bpl(203,3): b#main_entry
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(240,3): b#main_entry
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(240,3): b#main_entry
  out.bpl(243,5): Error: a precondition for this call could not be proved
  out.bpl(143,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(240,3): b#main_entry
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(265,3): b#main_entry
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(302,3): b#main_entry
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(339,3): b#main_entry
  
  Boogie program verifier finished with 1 verified, 7 errors
