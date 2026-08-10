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
  > 
  >  (run-transform irreducible-loops)
  >  (run-transform remove-loops)
  >  (run-transform ssa)
  >  (run-transform inline-summaries)
  >  (run-transform cfa-reduction)
  >  (run-transforms simplify)
  >  (live-smt)
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
  (run-transform irreducible-loops)
  bincaml: [INFO] found 0 loops, 0 irreducible
  bincaml: [INFO] found 0 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  (run-transform remove-loops)
  (run-transform ssa)
  (run-transform inline-summaries)
  (run-transform cfa-reduction)
  (run-transforms simplify)
  (live-smt)
  
  Unknown Assertion:
  assert boolor(forall { .boogie = { .msg = "Memory Error: Memory Leak" } } (i:bv64) :: (boolor(neq(($me_alloc_live)(mem_encoding_6:memory_encoding,
         ($me_addr_alloc)(mem_encoding_6:memory_encoding, i:bv64)), 0x1:bv2),
     boolnot(($me_addr_is_heap)(mem_encoding_6:memory_encoding, i:bv64)))),
   boolnot(trm_1:bool))
  
  Unknown Assertion:
  assert boolor(($me_valid_access)(mem_encoding_7:memory_encoding,
      bvadd(addr_5:bv64, 0x4:bv64), 0x1:bv64), boolnot(trm_1:bool)) { .boogie = { .msg = "Memory Error: Invalid Access" } }
  
  Unknown Assertion:
  assert boolor(($me_valid_access)(mem_encoding_10:memory_encoding, addr_5:bv64,
      0x1:bv64), boolnot(trm_1:bool)) { .boogie = { .msg = "Memory Error: Invalid Access" } }
  
  Unknown Assertion:
  assert boolor(eq { .boogie = { .msg = "Memory Error: Invalid Free (not base address)" } }(0x0:bv64,
    ($me_addr_offset)(mem_encoding_5:memory_encoding, bvadd(addr_3:bv64, 0x1:bv64))),
   boolnot(trm_1:bool))
  
  Unknown Assertion:
  assert boolor(eq { .boogie = { .msg = "Memory Error: Invalid Free (object not live)" } }(($me_alloc_live)(mem_encoding_13:memory_encoding,
       ($me_addr_alloc)(mem_encoding_13:memory_encoding, addr_5:bv64)), 0x1:bv2),
   boolnot(trm_1:bool))
  
  Procedure @main verified with:
  24 succeeding assertions.
  0 failing assertions.
  0 unknown assertions.
  
  Procedure @double_free verified with:
  35 succeeding assertions.
  0 failing assertions.
  1 unknown assertions.
  
  Procedure @invalid_free verified with:
  15 succeeding assertions.
  0 failing assertions.
  1 unknown assertions.
  
  Procedure @use_after_free verified with:
  23 succeeding assertions.
  0 failing assertions.
  1 unknown assertions.
  
  Procedure @out_of_bounds verified with:
  23 succeeding assertions.
  0 failing assertions.
  1 unknown assertions.
  
  Procedure @memory_leak verified with:
  11 succeeding assertions.
  0 failing assertions.
  1 unknown assertions.
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
      out.bpl(226,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(271,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(271,3): b#inputs
  out.bpl(277,5): Error: a precondition for this call could not be proved
  out.bpl(146,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(271,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(306,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(355,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(403,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
