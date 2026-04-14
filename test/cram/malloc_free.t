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
  var v$R0: bv64;
  var v$R1: bv64;
  var v$R16: bv64;
  var v$R17: bv64;
  var v$R29: bv64;
  var v$R30: bv64;
  var v$R31: bv64;
  var v$mem: [bv64]bv8;
  var v$mem_encoding: MemEncoding;
  var v$stack: [bv64]bv8;
  
  function  v$magic(a: [bv64]bv8, b: [bv64]bv8) returns ([bv64]bv8) { a }
  function {:extern } {:inline } v$me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:extern } {:inline } v$me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:extern } {:inline } v$me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:extern } {:inline } v$me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:extern } {:inline } v$me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:extern } {:inline } v$me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:extern } {:inline } v$me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:extern } {:inline } v$me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:extern } {:inline } v$me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    v$me_alloc_size_update(
      v$me_alloc_live_update(
        mem_encoding,
        v$me_addr_alloc(mem_encoding, addr),
        1bv2
      ),
      v$me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:extern } {:inline } v$me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    ((((v$me_addr_is_heap(mem_encoding, addr)&&(v$me_alloc_base(
           mem_encoding,
           addr
         ) == addr))&&(v$me_alloc_live(
          mem_encoding,
          v$me_addr_alloc(mem_encoding, addr)
        ) == 0bv2))&&bvule_bv64_bv64_bool(size, 4294967295bv64))&&bvult_bv64_bv64_bool(
       0bv64,
       size
     ))
  }
  function {:extern } {:inline } v$me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
    (((forall 
       i: bv64 :: 
       {v$me_addr_is_heap(mem_encoding, i)} 
       (bvult_bv64_bv64_bool(100000000bv64, i) == v$me_addr_is_heap(
          mem_encoding,
          i
        )))&&(forall 
       i: bv64 :: 
       {v$me_alloc_live(mem_encoding, i)} 
       (v$me_addr_is_heap(mem_encoding, i) ==> (v$me_alloc_live(mem_encoding, i) == 0bv2))))&&(forall 
      i: bv64 :: 
      {v$me_alloc_live(mem_encoding, i)} 
      ((!(v$me_addr_is_heap(mem_encoding, i))) ==> (v$me_alloc_live(
          mem_encoding,
          i
        ) == 2bv2))))
  }
  function {:extern } {:inline } v$me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    (v$me_addr_is_heap(mem_encoding, addr) ==> ((v$me_alloc_live(
         mem_encoding,
         v$me_alloc_base(mem_encoding, v$me_addr_alloc(mem_encoding, addr))
       ) == 1bv2)&&bvule_bv64_bv64_bool(
        v$me_addr_offset(mem_encoding, bvadd_bv64(addr, size)),
        v$me_alloc_size(
          mem_encoding,
          v$me_alloc_base(mem_encoding, v$me_addr_alloc(mem_encoding, addr))
        )
      )))
  }
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
  function {:bvbuiltin "bvadd"} {:extern } bvadd_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvand"} {:extern } bvand_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvule"} {:extern } bvule_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:bvbuiltin "bvult"} {:extern } bvult_bv64_bv64_bool(bv64, bv64) returns (bool);
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
  function {:define } {:extern } store64_le(#memory: [bv64]bv8, #index: bv64, #value: bv64) returns ([bv64]bv8) {
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
  function {:define } {:extern } store8_le(#memory: [bv64]bv8, #index: bv64, #value: bv8) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]]
  }
  
  procedure p$main();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    requires v$me_init_encoding(v$mem_encoding);
  implementation p$main() {
    var Exp18__5_25: bv64;
    var Exp16__5_24: bv64;
    var Exp14__5_2: bv64;
    var Exp14__5_21: bv64;
    var Cse0__5_23: bv64;
    var Exp14__5_1: bv64;
    var R30_begin_FUN_7a0_1952: bv64;
    var R30_begin_FUN_770_1904: bv64;
    var Exp14__5_22: bv64;
    b#main_entry:
      Cse0__5_23 := bvadd_bv64(v$R31, 18446744073709551584bv64);
      v$stack := store64_le(v$stack, Cse0__5_23, v$R29);
      v$stack := store64_le(v$stack, bvadd_bv64(Cse0__5_23, 8bv64), v$R30);
      v$R31 := Cse0__5_23;
      v$R29 := v$R31;
      v$R0 := 17bv64;
      v$R30 := 2292bv64;
      goto b#FUN_770_entry_9;
    b#FUN_770_entry_9:
      R30_begin_FUN_770_1904 := v$R30;
      v$R16 := 131072bv64;
      assert v$me_valid_access(v$mem_encoding, bvadd_bv64(v$R16, 16bv64), 8bv64);
      Exp14__5_2 := load64_le(v$mem, bvadd_bv64(v$R16, 16bv64));
      v$R17 := Exp14__5_2;
      v$R16 := bvadd_bv64(v$R16, 16bv64);
      assert (v$R30 == R30_begin_FUN_770_1904);
      v$R0 := 1bv64;
      call p$malloc();
      goto b#FUN_770_basil_return_1_10;
    b#FUN_770_basil_return_1_10:
      goto b#_inlineret_4;
    b#_inlineret_4:
      goto b#main_5;
    b#main_5:
      v$stack := store64_le(v$stack, bvadd_bv64(v$R31, 24bv64), v$R0);
      Exp14__5_21 := load64_le(v$stack, bvadd_bv64(v$R31, 24bv64));
      v$R0 := Exp14__5_21;
      v$R0 := bvadd_bv64(v$R0, 0bv64);
      v$R1 := 121bv64;
      assert v$me_valid_access(v$mem_encoding, v$R0, 1bv64);
      v$mem := store8_le(v$mem, v$R0, v$R1[8:0]);
      Exp14__5_22 := load64_le(v$stack, bvadd_bv64(v$R31, 24bv64));
      v$R0 := Exp14__5_22;
      v$R30 := 2320bv64;
      goto b#FUN_7a0_entry_7;
    b#FUN_7a0_entry_7:
      R30_begin_FUN_7a0_1952 := v$R30;
      v$R16 := 131072bv64;
      assert v$me_valid_access(v$mem_encoding, bvadd_bv64(v$R16, 40bv64), 8bv64);
      Exp14__5_1 := load64_le(v$mem, bvadd_bv64(v$R16, 40bv64));
      v$R17 := Exp14__5_1;
      v$R16 := bvadd_bv64(v$R16, 40bv64);
      assert (v$R30 == R30_begin_FUN_7a0_1952);
      call p$free();
      goto b#FUN_7a0_basil_return_1_8;
    b#FUN_7a0_basil_return_1_8:
      goto b#_inlineret_3;
    b#_inlineret_3:
      goto b#main_3;
    b#main_3:
      v$R0 := 0bv64;
      Exp16__5_24 := load64_le(v$stack, v$R31);
      Exp18__5_25 := load64_le(v$stack, bvadd_bv64(v$R31, 8bv64));
      v$R29 := Exp16__5_24;
      v$R30 := Exp18__5_25;
      v$R31 := bvadd_bv64(v$R31, 32bv64);
      goto b#main_basil_return_1;
    b#main_basil_return_1:
      assert true;
      return;
  }
  
  procedure p$malloc();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    ensures v$me_can_allocate(old(v$mem_encoding), v$R0, old(v$R0));
    ensures (v$me_addr_offset(v$mem_encoding, v$R0) == 0bv64);
    ensures (v$me_alloc_base(
       v$mem_encoding,
       v$me_addr_alloc(v$mem_encoding, v$R0)
     ) == v$R0);
    ensures (v$mem_encoding == v$me_allocate(old(v$mem_encoding), v$R0, old(v$R0)));
  
  procedure p$free();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    ensures (v$mem_encoding == v$me_alloc_live_update(
       old(v$mem_encoding),
       v$me_addr_alloc(old(v$mem_encoding), v$R0),
       2bv2
     ));
    requires v$me_addr_is_heap(v$mem_encoding, v$R0);
    requires (0bv64 == v$me_addr_offset(v$mem_encoding, v$R0));
    requires (v$me_alloc_live(
       v$mem_encoding,
       v$me_addr_alloc(v$mem_encoding, v$R0)
     ) == 1bv2);

  $ boogie ./good.bpl
  
  Boogie program verifier finished with 1 verified, 0 errors

  $ cat ./bad.bpl
  var v$R0: bv64;
  var v$R1: bv64;
  var v$R16: bv64;
  var v$R17: bv64;
  var v$R29: bv64;
  var v$R30: bv64;
  var v$R31: bv64;
  var v$mem: [bv64]bv8;
  var v$mem_encoding: MemEncoding;
  var v$stack: [bv64]bv8;
  
  function  v$magic(a: [bv64]bv8, b: [bv64]bv8) returns ([bv64]bv8) { a }
  function {:extern } {:inline } v$me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:extern } {:inline } v$me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:extern } {:inline } v$me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:extern } {:inline } v$me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:extern } {:inline } v$me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:extern } {:inline } v$me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:extern } {:inline } v$me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:extern } {:inline } v$me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:extern } {:inline } v$me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    v$me_alloc_size_update(
      v$me_alloc_live_update(
        mem_encoding,
        v$me_addr_alloc(mem_encoding, addr),
        1bv2
      ),
      v$me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:extern } {:inline } v$me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    ((((v$me_addr_is_heap(mem_encoding, addr)&&(v$me_alloc_base(
           mem_encoding,
           addr
         ) == addr))&&(v$me_alloc_live(
          mem_encoding,
          v$me_addr_alloc(mem_encoding, addr)
        ) == 0bv2))&&bvule_bv64_bv64_bool(size, 4294967295bv64))&&bvult_bv64_bv64_bool(
       0bv64,
       size
     ))
  }
  function {:extern } {:inline } v$me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
    (((forall 
       i: bv64 :: 
       {v$me_addr_is_heap(mem_encoding, i)} 
       (bvult_bv64_bv64_bool(100000000bv64, i) == v$me_addr_is_heap(
          mem_encoding,
          i
        )))&&(forall 
       i: bv64 :: 
       {v$me_alloc_live(mem_encoding, i)} 
       (v$me_addr_is_heap(mem_encoding, i) ==> (v$me_alloc_live(mem_encoding, i) == 0bv2))))&&(forall 
      i: bv64 :: 
      {v$me_alloc_live(mem_encoding, i)} 
      ((!(v$me_addr_is_heap(mem_encoding, i))) ==> (v$me_alloc_live(
          mem_encoding,
          i
        ) == 2bv2))))
  }
  function {:extern } {:inline } v$me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    (v$me_addr_is_heap(mem_encoding, addr) ==> ((v$me_alloc_live(
         mem_encoding,
         v$me_alloc_base(mem_encoding, v$me_addr_alloc(mem_encoding, addr))
       ) == 1bv2)&&bvule_bv64_bv64_bool(
        v$me_addr_offset(mem_encoding, bvadd_bv64(addr, size)),
        v$me_alloc_size(
          mem_encoding,
          v$me_alloc_base(mem_encoding, v$me_addr_alloc(mem_encoding, addr))
        )
      )))
  }
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
  function {:bvbuiltin "bvadd"} {:extern } bvadd_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvand"} {:extern } bvand_bv64(bv64, bv64) returns (bv64);
  function {:bvbuiltin "bvule"} {:extern } bvule_bv64_bv64_bool(bv64, bv64) returns (bool);
  function {:bvbuiltin "bvult"} {:extern } bvult_bv64_bv64_bool(bv64, bv64) returns (bool);
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
  function {:define } {:extern } store64_le(#memory: [bv64]bv8, #index: bv64, #value: bv64) returns ([bv64]bv8) {
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
  function {:define } {:extern } store8_le(#memory: [bv64]bv8, #index: bv64, #value: bv8) returns ([bv64]bv8) {
    #memory[#index := #value[8:0]]
  }
  
  procedure p$main();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    requires v$me_init_encoding(v$mem_encoding);
  implementation p$main() {
    var Exp18__5_25: bv64;
    var Exp16__5_24: bv64;
    var Exp14__5_2: bv64;
    var Exp14__5_21: bv64;
    var Cse0__5_23: bv64;
    var Exp14__5_1: bv64;
    var R30_begin_FUN_7a0_1952: bv64;
    var R30_begin_FUN_770_1904: bv64;
    var Exp14__5_22: bv64;
    b#main_entry:
      Cse0__5_23 := bvadd_bv64(v$R31, 18446744073709551584bv64);
      v$stack := store64_le(v$stack, Cse0__5_23, v$R29);
      v$stack := store64_le(v$stack, bvadd_bv64(Cse0__5_23, 8bv64), v$R30);
      v$R31 := Cse0__5_23;
      v$R29 := v$R31;
      v$R0 := 17bv64;
      v$R30 := 2292bv64;
      goto b#FUN_770_entry_9;
    b#FUN_770_entry_9:
      R30_begin_FUN_770_1904 := v$R30;
      v$R16 := 131072bv64;
      assert v$me_valid_access(v$mem_encoding, bvadd_bv64(v$R16, 16bv64), 8bv64);
      Exp14__5_2 := load64_le(v$mem, bvadd_bv64(v$R16, 16bv64));
      v$R17 := Exp14__5_2;
      v$R16 := bvadd_bv64(v$R16, 16bv64);
      assert (v$R30 == R30_begin_FUN_770_1904);
      v$R0 := 1bv64;
      call p$malloc();
      goto b#FUN_770_basil_return_1_10;
    b#FUN_770_basil_return_1_10:
      goto b#_inlineret_4;
    b#_inlineret_4:
      goto b#main_5;
    b#main_5:
      v$stack := store64_le(v$stack, bvadd_bv64(v$R31, 24bv64), v$R0);
      Exp14__5_21 := load64_le(v$stack, bvadd_bv64(v$R31, 24bv64));
      v$R0 := Exp14__5_21;
      v$R0 := bvadd_bv64(v$R0, 7bv64);
      v$R1 := 121bv64;
      assert v$me_valid_access(v$mem_encoding, v$R0, 1bv64);
      v$mem := store8_le(v$mem, v$R0, v$R1[8:0]);
      Exp14__5_22 := load64_le(v$stack, bvadd_bv64(v$R31, 24bv64));
      v$R0 := Exp14__5_22;
      v$R30 := 2320bv64;
      goto b#FUN_7a0_entry_7;
    b#FUN_7a0_entry_7:
      R30_begin_FUN_7a0_1952 := v$R30;
      v$R16 := 131072bv64;
      assert v$me_valid_access(v$mem_encoding, bvadd_bv64(v$R16, 40bv64), 8bv64);
      Exp14__5_1 := load64_le(v$mem, bvadd_bv64(v$R16, 40bv64));
      v$R17 := Exp14__5_1;
      v$R16 := bvadd_bv64(v$R16, 40bv64);
      assert (v$R30 == R30_begin_FUN_7a0_1952);
      call p$free();
      goto b#FUN_7a0_basil_return_1_8;
    b#FUN_7a0_basil_return_1_8:
      goto b#_inlineret_3;
    b#_inlineret_3:
      goto b#main_3;
    b#main_3:
      v$R0 := 0bv64;
      Exp16__5_24 := load64_le(v$stack, v$R31);
      Exp18__5_25 := load64_le(v$stack, bvadd_bv64(v$R31, 8bv64));
      v$R29 := Exp16__5_24;
      v$R30 := Exp18__5_25;
      v$R31 := bvadd_bv64(v$R31, 32bv64);
      goto b#main_basil_return_1;
    b#main_basil_return_1:
      assert true;
      return;
  }
  
  procedure p$malloc();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    ensures v$me_can_allocate(old(v$mem_encoding), v$R0, old(v$R0));
    ensures (v$me_addr_offset(v$mem_encoding, v$R0) == 0bv64);
    ensures (v$me_alloc_base(
       v$mem_encoding,
       v$me_addr_alloc(v$mem_encoding, v$R0)
     ) == v$R0);
    ensures (v$mem_encoding == v$me_allocate(old(v$mem_encoding), v$R0, old(v$R0)));
  
  procedure p$free();
    modifies v$mem_encoding, v$mem, v$stack, v$R0, v$R1, v$R16, v$R17, v$R29, v$R30, v$R31;
    ensures (v$mem_encoding == v$me_alloc_live_update(
       old(v$mem_encoding),
       v$me_addr_alloc(old(v$mem_encoding), v$R0),
       2bv2
     ));
    requires v$me_addr_is_heap(v$mem_encoding, v$R0);
    requires (0bv64 == v$me_addr_offset(v$mem_encoding, v$R0));
    requires (v$me_alloc_live(
       v$mem_encoding,
       v$me_addr_alloc(v$mem_encoding, v$R0)
     ) == 1bv2);
  $ boogie ./bad.bpl
  ./bad.bpl(171,5): Error: this assertion could not be proved
  Execution trace:
      ./bad.bpl(141,3): b#main_entry
  
  Boogie program verifier finished with 0 verified, 1 error
