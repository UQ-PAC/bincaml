  $ bincaml script malloc_free.sexp
  (load-il ../../examples/memory/malloc_free.il)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (dump-boogie good.bpl)
  (load-il ../../examples/memory/malloc_free_oob.il)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (dump-boogie bad.bpl)

  $ cat ./good.bpl
  var $mem: [bv64]bv8;
  var $mem_encoding: MemEncoding;
  var $stack: [bv64]bv8;
  
  function {:inline } {:extern } $me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:inline } {:extern } $me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:inline } {:extern } $me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:inline } {:extern } $me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:inline } {:extern } $me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:inline } {:extern } $me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:inline } {:extern } $me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:inline } {:extern } $me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:inline } {:extern } $me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    $me_alloc_size_update(
      $me_alloc_live_update(
        mem_encoding,
        $me_addr_alloc(mem_encoding, addr),
        1bv2
      ),
      $me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:inline } {:extern } $me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
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
  function {:inline } {:extern } $me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
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
  function {:inline } {:extern } $me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
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
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
  function {:extern } {:bvbuiltin "bvadd"} bvadd_bv64(bv64, bv64) returns (bv64);
  function {:extern } {:bvbuiltin "bvand"} bvand_bv64(bv64, bv64) returns (bv64);
  function {:extern } {:bvbuiltin "bvule"} bvule_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:extern } {:bvbuiltin "bvult"} bvult_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:extern } load64_le(#memory: [bv64]bv8, #index: bv64) returns (bv64) {
    (((((((#memory[bvadd_bv64(#index, 7bv64)]
           ++
           #memory[bvadd_bv64(#index, 6bv64)]): bv16
          ++
          #memory[bvadd_bv64(#index, 5bv64)]): bv24
         ++
         #memory[bvadd_bv64(#index, 4bv64)]): bv32
        ++
        #memory[bvadd_bv64(#index, 3bv64)]): bv40
       ++
       #memory[bvadd_bv64(#index, 2bv64)]): bv48
      ++
      #memory[bvadd_bv64(#index, 1bv64)]): bv56
     ++
     #memory[bvadd_bv64(#index, 0bv64)]): bv64
  }
  function {:extern } {:define } store64_le(#memory: [bv64]bv8, #index: bv64, #value: bv64) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]][bvadd_bv64(#index, 1bv64) := #value[16:8]][bvadd_bv64(
      #index,
      2bv64
    ) := #value[24:16]][bvadd_bv64(#index, 3bv64) := #value[32:24]][bvadd_bv64(
      #index,
      4bv64
    ) := #value[40:32]][bvadd_bv64(#index, 5bv64) := #value[48:40]][bvadd_bv64(
      #index,
      6bv64
    ) := #value[56:48]][bvadd_bv64(#index, 7bv64) := #value[64:56]]
  }
  function {:extern } {:define } store8_le(#memory: [bv64]bv8, #index: bv64, #value: bv8) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]]
  }
  
  procedure p$#free(R0_in: bv64);
    modifies $mem_encoding, $mem, $stack;
    ensures ($mem_encoding == $me_alloc_live_update(
       old($mem_encoding),
       $me_addr_alloc(old($mem_encoding), R0_in),
       2bv2
     ));
    requires $me_addr_is_heap($mem_encoding, R0_in);
    requires (0bv64 == $me_addr_offset($mem_encoding, R0_in));
    requires ($me_alloc_live($mem_encoding, $me_addr_alloc($mem_encoding, R0_in)) == 1bv2);
  
  procedure p$malloc(R0_in: bv64) returns (R0_out: bv64);
    modifies $mem_encoding, $mem, $stack;
    ensures $me_can_allocate(old($mem_encoding), R0_out, R0_in);
    ensures ($me_addr_offset($mem_encoding, R0_out) == 0bv64);
    ensures ($me_alloc_base($mem_encoding, $me_addr_alloc($mem_encoding, R0_out)) == R0_out);
    ensures ($mem_encoding == $me_allocate(old($mem_encoding), R0_out, R0_in));
  
  procedure p$main_2276(R0_in: bv64, R16_in: bv64, R17_in: bv64, R1_in: bv64,
     R29_in: bv64, R30_in: bv64, R31_in: bv64, _PC_in: bv64) returns (R0_out: bv64,
     R17_out: bv64, R1_out: bv64, R29_out: bv64, R30_out: bv64);
    modifies $mem_encoding, $mem, $stack;
    requires $me_init_encoding($mem_encoding);
  implementation p$main_2276(R0_in: bv64, R16_in: bv64, R17_in: bv64, R1_in: bv64,
   R29_in: bv64, R30_in: bv64, R31_in: bv64, _PC_in: bv64) returns (R0_out: bv64,
   R17_out: bv64, R1_out: bv64, R29_out: bv64, R30_out: bv64) {
    var Exp18__5_25_1: bv64;
    var Exp16__5_24_1: bv64;
    var Exp14__5_21_1: bv64;
    var R0_3: bv64;
    var Exp14__5_22_1: bv64;
    var Exp14__5_2_1: bv64;
    var Exp14__5_1_1: bv64;
    b#main_entry:
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551584bv64),
          R29_in
        );
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551592bv64),
          R30_in
        );
      assert $me_valid_access($mem_encoding, 131088bv64, 8bv64);
      Exp14__5_2_1 := load64_le($mem, 131088bv64);
      assert true;
      call R0_3 := p$malloc(1bv64);
      goto b#phi_5;
    b#phi_5:
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64),
          R0_3
        );
      Exp14__5_21_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64)
        );
      assert $me_valid_access($mem_encoding, Exp14__5_21_1, 1bv64);
      $mem := store8_le($mem, Exp14__5_21_1, 121bv8);
      Exp14__5_22_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64)
        );
      assert $me_valid_access($mem_encoding, 131112bv64, 8bv64);
      Exp14__5_1_1 := load64_le($mem, 131112bv64);
      assert true;
      call p$#free(Exp14__5_22_1);
      goto b#phi_6;
    b#phi_6:
      Exp16__5_24_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551584bv64)
        );
      Exp18__5_25_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551592bv64)
        );
      goto b#main_return;
    b#main_return:
      R0_out, R17_out, R1_out, R29_out, R30_out := 0bv64, Exp14__5_1_1, 121bv64,
        Exp16__5_24_1, Exp18__5_25_1;
      return;
  }
<<<<<<< HEAD
=======
>>>>>>> 0e8945b (flip the order)
<<<<<<< HEAD
=======
>>>>>>> 0e8945b (flip the order)
<<<<<<< HEAD
=======
>>>>>>> 0e8945b (flip the order)

  $ boogie ./good.bpl
  
  Boogie program verifier finished with 1 verified, 0 errors

  $ cat ./bad.bpl
  var $mem: [bv64]bv8;
  var $mem_encoding: MemEncoding;
  var $stack: [bv64]bv8;
  
  function {:inline } {:extern } $me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:inline } {:extern } $me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:inline } {:extern } $me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:inline } {:extern } $me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:inline } {:extern } $me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:inline } {:extern } $me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:inline } {:extern } $me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:inline } {:extern } $me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:inline } {:extern } $me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    $me_alloc_size_update(
      $me_alloc_live_update(
        mem_encoding,
        $me_addr_alloc(mem_encoding, addr),
        1bv2
      ),
      $me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:inline } {:extern } $me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
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
  function {:inline } {:extern } $me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
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
  function {:inline } {:extern } $me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
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
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
  function {:extern } {:bvbuiltin "bvadd"} bvadd_bv64(bv64, bv64) returns (bv64);
  function {:extern } {:bvbuiltin "bvand"} bvand_bv64(bv64, bv64) returns (bv64);
  function {:extern } {:bvbuiltin "bvule"} bvule_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:extern } {:bvbuiltin "bvult"} bvult_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:extern } load64_le(#memory: [bv64]bv8, #index: bv64) returns (bv64) {
    (((((((#memory[bvadd_bv64(#index, 7bv64)]
           ++
           #memory[bvadd_bv64(#index, 6bv64)]): bv16
          ++
          #memory[bvadd_bv64(#index, 5bv64)]): bv24
         ++
         #memory[bvadd_bv64(#index, 4bv64)]): bv32
        ++
        #memory[bvadd_bv64(#index, 3bv64)]): bv40
       ++
       #memory[bvadd_bv64(#index, 2bv64)]): bv48
      ++
      #memory[bvadd_bv64(#index, 1bv64)]): bv56
     ++
     #memory[bvadd_bv64(#index, 0bv64)]): bv64
  }
  function {:extern } {:define } store64_le(#memory: [bv64]bv8, #index: bv64, #value: bv64) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]][bvadd_bv64(#index, 1bv64) := #value[16:8]][bvadd_bv64(
      #index,
      2bv64
    ) := #value[24:16]][bvadd_bv64(#index, 3bv64) := #value[32:24]][bvadd_bv64(
      #index,
      4bv64
    ) := #value[40:32]][bvadd_bv64(#index, 5bv64) := #value[48:40]][bvadd_bv64(
      #index,
      6bv64
    ) := #value[56:48]][bvadd_bv64(#index, 7bv64) := #value[64:56]]
  }
  function {:extern } {:define } store8_le(#memory: [bv64]bv8, #index: bv64, #value: bv8) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]]
  }
  
  procedure p$#free(R0_in: bv64);
    modifies $mem_encoding, $mem, $stack;
    ensures ($mem_encoding == $me_alloc_live_update(
       old($mem_encoding),
       $me_addr_alloc(old($mem_encoding), R0_in),
       2bv2
     ));
    requires $me_addr_is_heap($mem_encoding, R0_in);
    requires (0bv64 == $me_addr_offset($mem_encoding, R0_in));
    requires ($me_alloc_live($mem_encoding, $me_addr_alloc($mem_encoding, R0_in)) == 1bv2);
  
  procedure p$malloc(R0_in: bv64) returns (R0_out: bv64);
    modifies $mem_encoding, $mem, $stack;
    ensures $me_can_allocate(old($mem_encoding), R0_out, R0_in);
    ensures ($me_addr_offset($mem_encoding, R0_out) == 0bv64);
    ensures ($me_alloc_base($mem_encoding, $me_addr_alloc($mem_encoding, R0_out)) == R0_out);
    ensures ($mem_encoding == $me_allocate(old($mem_encoding), R0_out, R0_in));
  
  procedure p$main_2276(R0_in: bv64, R16_in: bv64, R17_in: bv64, R1_in: bv64,
     R29_in: bv64, R30_in: bv64, R31_in: bv64, _PC_in: bv64) returns (R0_out: bv64,
     R17_out: bv64, R1_out: bv64, R29_out: bv64, R30_out: bv64);
    modifies $mem_encoding, $mem, $stack;
    requires $me_init_encoding($mem_encoding);
  implementation p$main_2276(R0_in: bv64, R16_in: bv64, R17_in: bv64, R1_in: bv64,
   R29_in: bv64, R30_in: bv64, R31_in: bv64, _PC_in: bv64) returns (R0_out: bv64,
   R17_out: bv64, R1_out: bv64, R29_out: bv64, R30_out: bv64) {
    var Exp18__5_25_1: bv64;
    var Exp16__5_24_1: bv64;
    var Exp14__5_21_1: bv64;
    var R0_3: bv64;
    var Exp14__5_22_1: bv64;
    var Exp14__5_2_1: bv64;
    var Exp14__5_1_1: bv64;
    b#main_entry:
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551584bv64),
          R29_in
        );
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551592bv64),
          R30_in
        );
      assert $me_valid_access($mem_encoding, 131088bv64, 8bv64);
      Exp14__5_2_1 := load64_le($mem, 131088bv64);
      assert true;
      call R0_3 := p$malloc(1bv64);
      goto b#phi_5;
    b#phi_5:
      $stack := store64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64),
          R0_3
        );
      Exp14__5_21_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64)
        );
      assert $me_valid_access(
        $mem_encoding,
        bvadd_bv64(Exp14__5_21_1, 7bv64),
        1bv64
      );
      $mem := store8_le($mem, bvadd_bv64(Exp14__5_21_1, 7bv64), 121bv8);
      Exp14__5_22_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551608bv64)
        );
      assert $me_valid_access($mem_encoding, 131112bv64, 8bv64);
      Exp14__5_1_1 := load64_le($mem, 131112bv64);
      assert true;
      call p$#free(Exp14__5_22_1);
      goto b#phi_6;
    b#phi_6:
      Exp16__5_24_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551584bv64)
        );
      Exp18__5_25_1 := load64_le(
          $stack,
          bvadd_bv64(R31_in, 18446744073709551592bv64)
        );
      goto b#main_return;
    b#main_return:
      R0_out, R17_out, R1_out, R29_out, R30_out := 0bv64, Exp14__5_1_1, 121bv64,
        Exp16__5_24_1, Exp18__5_25_1;
      return;
  }
<<<<<<< HEAD
=======
>>>>>>> 0e8945b (flip the order)
<<<<<<< HEAD
=======
>>>>>>> 0e8945b (flip the order)
<<<<<<< HEAD
  $ boogie ./bad.bpl
  ./bad.bpl(181,5): Error: this assertion could not be proved
  Execution trace:
      ./bad.bpl(155,3): b#main_entry
  
  Boogie program verifier finished with 0 verified, 1 error
=======
  $ boogie ./bad.bpl
  ./bad.bpl(181,5): Error: this assertion could not be proved
  Execution trace:
      ./bad.bpl(155,3): b#main_entry
  
  Boogie program verifier finished with 0 verified, 1 error
>>>>>>> 0e8945b (flip the order)
