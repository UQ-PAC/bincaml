  $ cat << EOF | bincaml script -
  > (load-il "../../examples/memory/memory_interproc.il")
  > (run-transforms "ssa")
  > (run-transforms "split-memory-encoding")
  > (run-transforms "memory-specification")
  > (run-transforms "ssa")
  > (run-transforms "linear-const")
  > (run-transforms "linear-copy")
  > (run-transforms "inter-function-summaries")
  > (run-transforms "dynamic-single-assignment")
  > (dump-il "after.il")
  > (dump-boogie "out.bpl")
  > EOF
  (load-il ../../examples/memory/memory_interproc.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms inter-function-summaries)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  bincaml: Input error: parse error
           Related context:
           next token
           21 |   requires ($me_addr_is_heap) { .boogie = { .msg = "Memory Error: Invalid Free (non heap object)" } }(mem_encoding_in:memory_encoding,
                                              ^
           
  [123]
  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/memory/memory_interproc.il")
  > (run-transforms "ssa")
  > (run-transforms "flat-memory-encoding")
  > (run-transforms "memory-specification")
  > (run-transforms "ssa")
  > (run-transforms "linear-const")
  > (run-transforms "linear-copy")
  > (run-transforms "inter-function-summaries")
  > (run-transforms "dynamic-single-assignment")
  > (dump-il "after.il")
  > (dump-boogie "out.bpl")
  > EOF
  (load-il ../../examples/memory/memory_interproc.il)
  (run-transforms ssa)
  (run-transforms flat-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms inter-function-summaries)
  (run-transforms dynamic-single-assignment)
  (dump-il after.il)
  bincaml: Input error: parse error
           Related context:
           next token
           21 |   requires ($me_addr_is_heap) { .boogie = { .msg = "Memory Error: Invalid Free (non heap object)" } }(mem_encoding_in:memory_encoding,
                                              ^
           
  [123]

  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.

