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
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: (run-transforms ssa): Failure("not found: mem_encoding_in:memory_encoding likely a read-uninitialised variable")
           
  [123]
  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.

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
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: [ERROR] formal parameter name differs from variable
  bincaml: (run-transforms ssa): Failure("not found: mem_encoding_in:memory_encoding likely a read-uninitialised variable")
           
  [123]

  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.
