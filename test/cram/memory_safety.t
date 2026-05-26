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
  >  (load-il after.il)
  >  (dump-il after2.il)
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
  (load-il after.il)
  (dump-il after2.il)
  $ boogie out.bpl
  out.bpl(192,5): Error: a precondition for this call could not be proved
  out.bpl(112,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(179,3): b#inputs
  out.bpl(222,5): Error: a precondition for this call could not be proved
  out.bpl(111,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(216,3): b#inputs
  out.bpl(262,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(251,3): b#inputs
  out.bpl(299,5): Error: this assertion could not be proved
  Execution trace:
      out.bpl(292,3): b#inputs
  out.bpl(349,5): Error: a postcondition could not be proved on this return path
  out.bpl(314,3): Related location: this is the postcondition that could not be proved
  Execution trace:
      out.bpl(332,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 5 errors


  $ diff after.il after2.il
