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
  $ cat out.bpl
  var $mem: [bv64]bv8;
  datatype memory_encoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
  function {:extern } {:inline } $me_addr_offset(mem_encoding: memory_encoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:extern } {:inline } $me_alloc_base(mem_encoding: memory_encoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:extern } {:inline } $me_alloc_live(mem_encoding: memory_encoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:extern } {:inline } $me_alloc_size(mem_encoding: memory_encoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:extern } {:inline } $me_addr_alloc(mem_encoding: memory_encoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:extern } {:inline } $me_addr_is_heap(mem_encoding: memory_encoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:extern } {:inline } $me_can_allocate(mem_encoding: memory_encoding, addr: bv64, size: bv64) returns (bool) {
    (((($me_addr_is_heap(mem_encoding, addr)
        &&
        ($me_alloc_base(mem_encoding, addr) == addr))
       &&
       ($me_alloc_live(mem_encoding, $me_addr_alloc(mem_encoding, addr)) == 0bv2))
      &&
      bvule_bv64_bv64_bool(size, 4294967295bv64))
     &&
     bvult_bv64_bv64_bool(0bv64, size))
  }
  function {:extern } {:inline } $me_alloc_size_update(mem_encoding: memory_encoding, alloc: bv64, size: bv64) returns (memory_encoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:extern } {:inline } $me_alloc_live_update(mem_encoding: memory_encoding, alloc: bv64, live: bv2) returns (memory_encoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:extern } {:inline } $me_allocate(mem_encoding: memory_encoding, mem_encoding_out: memory_encoding, addr: bv64, size: bv64) returns (bool) {
    ($me_alloc_size_update(
       $me_alloc_live_update(
         mem_encoding,
         $me_addr_alloc(mem_encoding, addr),
         1bv2
       ),
       $me_addr_alloc(mem_encoding, addr),
       size
     ) == mem_encoding_out)
  }
  function {:extern } {:inline } $me_init_encoding(mem_encoding: memory_encoding) returns (bool) {
    (((forall 
       i: bv64 :: 
       {$me_addr_is_heap(mem_encoding, i)} 
       (bvult_bv64_bv64_bool(100000000bv64, i) == $me_addr_is_heap(
          mem_encoding,
          i
        )))
      &&
      (forall 
       i: bv64 :: 
       {$me_alloc_live(mem_encoding, i)} 
       ($me_addr_is_heap(mem_encoding, i) ==> ($me_alloc_live(mem_encoding, i) == 0bv2))))
     &&
     (forall 
      i: bv64 :: 
      {$me_alloc_live(mem_encoding, i)} 
      ((!($me_addr_is_heap(mem_encoding, i))) ==> ($me_alloc_live(mem_encoding, i) == 2bv2))))
  }
  function {:extern } {:inline } $me_valid_access(mem_encoding: memory_encoding, addr: bv64, size: bv64) returns (bool) {
    ($me_addr_is_heap(mem_encoding, addr) ==> (($me_alloc_live(
         mem_encoding,
         $me_alloc_base(mem_encoding, $me_addr_alloc(mem_encoding, addr))
       ) == 1bv2)
      &&
      bvule_bv64_bv64_bool(
        $me_addr_offset(mem_encoding, bvadd_bv64(addr, size)),
        $me_alloc_size(
          mem_encoding,
          $me_alloc_base(mem_encoding, $me_addr_alloc(mem_encoding, addr))
        )
      )))
  }
  function {:extern } load8_le(#memory: [bv64]bv8, #index: bv64) returns (bv8) {
    #memory[bvadd_bv64(#index, 0bv64)]
  }
  function {:define } {:extern } store8_le(#memory: [bv64]bv8, #index: bv64, #value: bv8) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]]
  }
  function {:bvbuiltin "bvadd"} {:extern } bvadd_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvand"} {:extern } bvand_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvule"} {:extern } bvule_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:bvbuiltin "bvult"} {:extern } bvult_bv64_bv64_bool(bv64, bv64) returns (bool);
  
  procedure p$malloc(R0_in: bv64, mem_encoding_in: memory_encoding) returns (R0_out: bv64,
     mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures $me_can_allocate(mem_encoding_in, R0_out, R0_in);
    ensures ($me_addr_offset(mem_encoding_out, R0_out) == 0bv64);
    ensures ($me_alloc_base(
       mem_encoding_out,
       $me_addr_alloc(mem_encoding_out, R0_out)
     ) == R0_out);
    ensures $me_allocate(mem_encoding_in, mem_encoding_out, R0_out, R0_in);
  procedure p$free(R0_in: bv64, mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Invalid Free"} (mem_encoding_out == $me_alloc_live_update(
       mem_encoding_in,
       $me_addr_alloc(mem_encoding_in, R0_in),
       2bv2
     ));
    requires $me_addr_is_heap(mem_encoding_in, R0_in);
    requires {:msg "Memory Error: Invalid Free (not base address)"} (0bv64 == $me_addr_offset(
       mem_encoding_in,
       R0_in
     ));
    requires {:msg "Memory Error: Invalid Free (object not live)"} ($me_alloc_live(
       mem_encoding_in,
       $me_addr_alloc(mem_encoding_in, R0_in)
     ) == 1bv2);
  procedure p$main(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$main(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_5: memory_encoding;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var addr_4: bv64;
    var mem_encoding_out_1: memory_encoding;
    var mem_encoding_4: memory_encoding;
    var temp_2: bv8;
    var addr_2: bv64;
    var addr_3: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      addr_3, mem_encoding_3 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(addr_2, 0bv64), 255bv8);
      addr_4, mem_encoding_4 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      temp_2 := load8_le($mem, bvadd_bv64(addr_2, 0bv64));
      call mem_encoding_5 := p$free(addr_2, mem_encoding_2);
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_5;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_5;
      return;
  }
  procedure p$double_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$double_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_5: memory_encoding;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var addr_4: bv64;
    var mem_encoding_6: memory_encoding;
    var mem_encoding_out_1: memory_encoding;
    var mem_encoding_4: memory_encoding;
    var temp_2: bv8;
    var addr_2: bv64;
    var addr_3: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      addr_3, mem_encoding_3 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(addr_2, 0bv64), 255bv8);
      addr_4, mem_encoding_4 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      temp_2 := load8_le($mem, bvadd_bv64(addr_2, 0bv64));
      call mem_encoding_5 := p$free(addr_2, mem_encoding_2);
      call mem_encoding_6 := p$free(addr_2, mem_encoding_5);
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_6;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_6;
      return;
  }
  procedure p$invalid_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$invalid_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var mem_encoding_out_1: memory_encoding;
    var addr_2: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      call mem_encoding_3 := p$free(bvadd_bv64(addr_2, 1bv64), mem_encoding_2);
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_3;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_3;
      return;
  }
  procedure p$use_after_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$use_after_free(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_5: memory_encoding;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var addr_4: bv64;
    var mem_encoding_out_1: memory_encoding;
    var mem_encoding_4: memory_encoding;
    var temp_2: bv8;
    var addr_2: bv64;
    var addr_3: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      addr_3, mem_encoding_3 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(addr_2, 0bv64), 255bv8);
      call mem_encoding_4 := p$free(addr_2, mem_encoding_2);
      addr_4, mem_encoding_5 := addr_2, mem_encoding_4;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_4,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      temp_2 := load8_le($mem, bvadd_bv64(addr_2, 0bv64));
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_4;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_4;
      return;
  }
  procedure p$out_of_bounds(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$out_of_bounds(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_5: memory_encoding;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var addr_4: bv64;
    var mem_encoding_out_1: memory_encoding;
    var mem_encoding_4: memory_encoding;
    var temp_2: bv8;
    var addr_2: bv64;
    var addr_3: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      addr_3, mem_encoding_3 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 4bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(addr_2, 4bv64), 255bv8);
      addr_4, mem_encoding_4 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 4bv64),
        1bv64
      );
      temp_2 := load8_le($mem, bvadd_bv64(addr_2, 4bv64));
      call mem_encoding_5 := p$free(addr_2, mem_encoding_2);
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_5;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_5;
      return;
  }
  procedure p$memory_leak(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding);
    modifies $mem;
    ensures {:msg "Memory Error: Memory Leak"} (forall 
     i: bv64 :: 
      
     ($me_addr_is_heap(mem_encoding_out, i) ==> ($me_alloc_live(
         mem_encoding_out,
         $me_addr_alloc(mem_encoding_out, i)
       ) != 1bv2)));
    requires $me_init_encoding(mem_encoding_in);
  implementation p$memory_leak(mem_encoding_in: memory_encoding) returns (mem_encoding_out: memory_encoding) {
    var mem_encoding_3: memory_encoding;
    var size_2: bv64;
    var mem_encoding_2: memory_encoding;
    var mem_encoding_1: memory_encoding;
    var addr_4: bv64;
    var mem_encoding_out_1: memory_encoding;
    var mem_encoding_4: memory_encoding;
    var temp_2: bv8;
    var addr_2: bv64;
    var addr_3: bv64;
    b#inputs:
      mem_encoding_1 := mem_encoding_in;
      goto b#main_entry;
    b#main_entry:
      size_2 := 2bv64;
      call addr_2, mem_encoding_2 := p$malloc(2bv64, mem_encoding_in);
      addr_3, mem_encoding_3 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(addr_2, 0bv64), 255bv8);
      addr_4, mem_encoding_4 := addr_2, mem_encoding_2;
      assert{:msg "Memory Error: Invalid Access"} $me_valid_access(
        mem_encoding_2,
        bvadd_bv64(addr_2, 0bv64),
        1bv64
      );
      temp_2 := load8_le($mem, bvadd_bv64(addr_2, 0bv64));
      goto b#main_return;
    b#main_return:
      goto b#Return;
    b#Return:
      assert true;
      goto b#returns;
    b#returns:
      mem_encoding_out_1 := mem_encoding_2;
      goto b#Return_1;
    b#Return_1:
      mem_encoding_out := mem_encoding_2;
      return;
  }
  $ boogie out.bpl
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(198,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(250,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(292,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(348,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(403,3): b#inputs
  
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
      out.bpl(234,3): b#inputs
  Memory Error: Invalid Free (not base address)
  Execution trace:
      out.bpl(286,3): b#inputs
  Memory Error: Invalid Free (object not live)
  Execution trace:
      out.bpl(286,3): b#inputs
  out.bpl(292,5): Error: a precondition for this call could not be proved
  out.bpl(146,3): Related location: this is the precondition that could not be proved
  Execution trace:
      out.bpl(286,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(328,3): b#inputs
  Memory Error: Invalid Access
  Execution trace:
      out.bpl(384,3): b#inputs
  Memory Error: Memory Leak
  Execution trace:
      out.bpl(439,3): b#inputs
  
  Boogie program verifier finished with 1 verified, 7 errors
