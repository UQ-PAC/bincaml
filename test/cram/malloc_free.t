  $ bincaml script malloc_free.sexp

  $ cat ./good.bpl
  var $R0: bv64;
  var $R1: bv64;
  var $R16: bv64;
  var $R17: bv64;
  var $R29: bv64;
  var $R30: bv64;
  var $R31: bv64;
  var $mem: [bv64]bv8;
  var $stack: [bv64]bv8;
  var $mem_encoding: MemEncoding;
  
  function  f$magic(a: [bv64]bv8, b: [bv64]bv8) returns ([bv64]bv8) { a }
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
  function {:inline } {:extern } me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:inline } {:extern } me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:inline } {:extern } me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:inline } {:extern } me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:inline } {:extern } me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:inline } {:extern } me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:inline } {:extern } me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:inline } {:extern } me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:inline } {:extern } me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    me_alloc_size_update(
      me_alloc_live_update(mem_encoding, me_addr_alloc(mem_encoding, addr), 1bv2),
      me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:inline } {:extern } me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    ((((me_addr_is_heap(mem_encoding, addr)&&(me_alloc_base(mem_encoding, addr) == addr))&&(me_alloc_live(
          mem_encoding,
          me_addr_alloc(mem_encoding, addr)
        ) == 0bv2))&&bvule_bv64_bv64_bool(size, 4294967295bv64))&&bvult_bv64_bv64_bool(
       0bv64,
       size
     ))
  }
  function {:inline } {:extern } me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
    (((forall 
       i: bv64 :: 
       {me_addr_is_heap(mem_encoding, i)} 
       (bvult_bv64_bv64_bool(100000000bv64, i) == me_addr_is_heap(mem_encoding, i)))&&(forall 
       i: bv64 :: 
       {me_alloc_live(mem_encoding, i)} 
       (me_addr_is_heap(mem_encoding, i) ==> (me_alloc_live(mem_encoding, i) == 0bv2))))&&(forall 
      i: bv64 :: 
      {me_alloc_live(mem_encoding, i)} 
      ((!(me_addr_is_heap(mem_encoding, i))) ==> (me_alloc_live(mem_encoding, i) == 2bv2))))
  }
  function {:inline } {:extern } me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    (me_addr_is_heap(mem_encoding, addr) ==> ((me_alloc_live(
         mem_encoding,
         me_alloc_base(mem_encoding, me_addr_alloc(mem_encoding, addr))
       ) == 1bv2)&&bvule_bv64_bv64_bool(
        me_addr_offset(mem_encoding, bvadd_bv64(addr, size)),
        me_alloc_size(
          mem_encoding,
          me_alloc_base(mem_encoding, me_addr_alloc(mem_encoding, addr))
        )
      )))
  }
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
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
  
  procedure p$free();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    requires me_addr_is_heap($mem_encoding, $R0);
    requires (0bv64 == me_addr_offset($mem_encoding, $R0));
    requires (me_alloc_live($mem_encoding, me_addr_alloc($mem_encoding, $R0)) == 1bv2);
  
  procedure p$malloc();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    ensures me_can_allocate(old($mem_encoding), $R0, old($R0));
    ensures (me_addr_offset($mem_encoding, $R0) == 0bv64);
    ensures (me_alloc_base($mem_encoding, me_addr_alloc($mem_encoding, $R0)) == $R0);
    ensures ($mem_encoding == me_allocate(old($mem_encoding), $R0, old($R0)));
  
  procedure p$main();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    requires me_init_encoding($mem_encoding);
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
      Cse0__5_23 := bvadd_bv64($R31, 18446744073709551584bv64);
      $stack := store64_le($stack, Cse0__5_23, $R29);
      $stack := store64_le($stack, bvadd_bv64(Cse0__5_23, 8bv64), $R30);
      $R31 := Cse0__5_23;
      $R29 := $R31;
      $R0 := 17bv64;
      $R30 := 2292bv64;
      goto b#FUN_770_entry_9;
    b#FUN_770_entry_9:
      R30_begin_FUN_770_1904 := $R30;
      $R16 := 131072bv64;
      assert me_valid_access($mem_encoding, bvadd_bv64($R16, 16bv64), 8bv64);
      Exp14__5_2 := load64_le($mem, bvadd_bv64($R16, 16bv64));
      $R17 := Exp14__5_2;
      $R16 := bvadd_bv64($R16, 16bv64);
      assert ($R30 == R30_begin_FUN_770_1904);
      $R0 := 1bv64;
      call p$malloc();
      goto b#FUN_770_basil_return_1_10;
    b#FUN_770_basil_return_1_10:
      goto b#_inlineret_4;
    b#_inlineret_4:
      goto b#main_5;
    b#main_5:
      $stack := store64_le($stack, bvadd_bv64($R31, 24bv64), $R0);
      Exp14__5_21 := load64_le($stack, bvadd_bv64($R31, 24bv64));
      $R0 := Exp14__5_21;
      $R0 := bvadd_bv64($R0, 0bv64);
      $R1 := 121bv64;
      assert me_valid_access($mem_encoding, $R0, 1bv64);
      $mem := store8_le($mem, $R0, $R1[8:0]);
      Exp14__5_22 := load64_le($stack, bvadd_bv64($R31, 24bv64));
      $R0 := Exp14__5_22;
      $R30 := 2320bv64;
      goto b#FUN_7a0_entry_7;
    b#FUN_7a0_entry_7:
      R30_begin_FUN_7a0_1952 := $R30;
      $R16 := 131072bv64;
      assert me_valid_access($mem_encoding, bvadd_bv64($R16, 40bv64), 8bv64);
      Exp14__5_1 := load64_le($mem, bvadd_bv64($R16, 40bv64));
      $R17 := Exp14__5_1;
      $R16 := bvadd_bv64($R16, 40bv64);
      assert ($R30 == R30_begin_FUN_7a0_1952);
      call p$free();
      goto b#FUN_7a0_basil_return_1_8;
    b#FUN_7a0_basil_return_1_8:
      goto b#_inlineret_3;
    b#_inlineret_3:
      goto b#main_3;
    b#main_3:
      $R0 := 0bv64;
      Exp16__5_24 := load64_le($stack, $R31);
      Exp18__5_25 := load64_le($stack, bvadd_bv64($R31, 8bv64));
      $R29 := Exp16__5_24;
      $R30 := Exp18__5_25;
      $R31 := bvadd_bv64($R31, 32bv64);
      goto b#main_basil_return_1;
    b#main_basil_return_1:
      assert true;
      return;
  }

  $ boogie ./good.bpl
  
  Boogie program verifier finished with 1 verified, 0 errors

  $ cat ./bad.bpl
  var $R0: bv64;
  var $R1: bv64;
  var $R16: bv64;
  var $R17: bv64;
  var $R29: bv64;
  var $R30: bv64;
  var $R31: bv64;
  var $mem: [bv64]bv8;
  var $stack: [bv64]bv8;
  var $mem_encoding: MemEncoding;
  
  function  f$magic(a: [bv64]bv8, b: [bv64]bv8) returns ([bv64]bv8) { a }
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
  function {:inline } {:extern } me_addr_alloc(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    addr
  }
  function {:inline } {:extern } me_addr_is_heap(mem_encoding: MemEncoding, addr: bv64) returns (bool) {
    mem_encoding->addr_is_heap[addr]
  }
  function {:inline } {:extern } me_addr_offset(mem_encoding: MemEncoding, addr: bv64) returns (bv64) {
    bvand_bv64(addr, 4294967295bv64)
  }
  function {:inline } {:extern } me_alloc_base(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    bvand_bv64(alloc, 18446744069414584320bv64)
  }
  function {:inline } {:extern } me_alloc_live(mem_encoding: MemEncoding, alloc: bv64) returns (bv2) {
    mem_encoding->alloc_live[alloc]
  }
  function {:inline } {:extern } me_alloc_live_update(mem_encoding: MemEncoding, alloc: bv64, live: bv2) returns (MemEncoding) {
    mem_encoding->(alloc_live := mem_encoding->alloc_live[alloc := live])
  }
  function {:inline } {:extern } me_alloc_size(mem_encoding: MemEncoding, alloc: bv64) returns (bv64) {
    mem_encoding->alloc_size[alloc]
  }
  function {:inline } {:extern } me_alloc_size_update(mem_encoding: MemEncoding, alloc: bv64, size: bv64) returns (MemEncoding) {
    mem_encoding->(alloc_size := mem_encoding->alloc_size[alloc := size])
  }
  function {:inline } {:extern } me_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (MemEncoding) {
    me_alloc_size_update(
      me_alloc_live_update(mem_encoding, me_addr_alloc(mem_encoding, addr), 1bv2),
      me_addr_alloc(mem_encoding, addr),
      size
    )
  }
  function {:inline } {:extern } me_can_allocate(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    ((((me_addr_is_heap(mem_encoding, addr)&&(me_alloc_base(mem_encoding, addr) == addr))&&(me_alloc_live(
          mem_encoding,
          me_addr_alloc(mem_encoding, addr)
        ) == 0bv2))&&bvule_bv64_bv64_bool(size, 4294967295bv64))&&bvult_bv64_bv64_bool(
       0bv64,
       size
     ))
  }
  function {:inline } {:extern } me_init_encoding(mem_encoding: MemEncoding) returns (bool) {
    (((forall 
       i: bv64 :: 
       {me_addr_is_heap(mem_encoding, i)} 
       (bvult_bv64_bv64_bool(100000000bv64, i) == me_addr_is_heap(mem_encoding, i)))&&(forall 
       i: bv64 :: 
       {me_alloc_live(mem_encoding, i)} 
       (me_addr_is_heap(mem_encoding, i) ==> (me_alloc_live(mem_encoding, i) == 0bv2))))&&(forall 
      i: bv64 :: 
      {me_alloc_live(mem_encoding, i)} 
      ((!(me_addr_is_heap(mem_encoding, i))) ==> (me_alloc_live(mem_encoding, i) == 2bv2))))
  }
  function {:inline } {:extern } me_valid_access(mem_encoding: MemEncoding, addr: bv64, size: bv64) returns (bool) {
    (me_addr_is_heap(mem_encoding, addr) ==> ((me_alloc_live(
         mem_encoding,
         me_alloc_base(mem_encoding, me_addr_alloc(mem_encoding, addr))
       ) == 1bv2)&&bvule_bv64_bv64_bool(
        me_addr_offset(mem_encoding, bvadd_bv64(addr, size)),
        me_alloc_size(
          mem_encoding,
          me_alloc_base(mem_encoding, me_addr_alloc(mem_encoding, addr))
        )
      )))
  }
  datatype MemEncoding {MemEncoding(alloc_live: [bv64]bv2, alloc_size: [bv64]bv64, addr_is_heap: [bv64]bool)}
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
  
  procedure p$free();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    requires me_addr_is_heap($mem_encoding, $R0);
    requires (0bv64 == me_addr_offset($mem_encoding, $R0));
    requires (me_alloc_live($mem_encoding, me_addr_alloc($mem_encoding, $R0)) == 1bv2);
  
  procedure p$malloc();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    ensures me_can_allocate(old($mem_encoding), $R0, old($R0));
    ensures (me_addr_offset($mem_encoding, $R0) == 0bv64);
    ensures (me_alloc_base($mem_encoding, me_addr_alloc($mem_encoding, $R0)) == $R0);
    ensures ($mem_encoding == me_allocate(old($mem_encoding), $R0, old($R0)));
  
  procedure p$main();
    modifies $mem_encoding, $mem, $stack, $R0, $R1, $R16, $R17, $R29, $R30, $R31;
    requires me_init_encoding($mem_encoding);
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
      Cse0__5_23 := bvadd_bv64($R31, 18446744073709551584bv64);
      $stack := store64_le($stack, Cse0__5_23, $R29);
      $stack := store64_le($stack, bvadd_bv64(Cse0__5_23, 8bv64), $R30);
      $R31 := Cse0__5_23;
      $R29 := $R31;
      $R0 := 17bv64;
      $R30 := 2292bv64;
      goto b#FUN_770_entry_9;
    b#FUN_770_entry_9:
      R30_begin_FUN_770_1904 := $R30;
      $R16 := 131072bv64;
      assert me_valid_access($mem_encoding, bvadd_bv64($R16, 16bv64), 8bv64);
      Exp14__5_2 := load64_le($mem, bvadd_bv64($R16, 16bv64));
      $R17 := Exp14__5_2;
      $R16 := bvadd_bv64($R16, 16bv64);
      assert ($R30 == R30_begin_FUN_770_1904);
      $R0 := 1bv64;
      call p$malloc();
      goto b#FUN_770_basil_return_1_10;
    b#FUN_770_basil_return_1_10:
      goto b#_inlineret_4;
    b#_inlineret_4:
      goto b#main_5;
    b#main_5:
      $stack := store64_le($stack, bvadd_bv64($R31, 24bv64), $R0);
      Exp14__5_21 := load64_le($stack, bvadd_bv64($R31, 24bv64));
      $R0 := Exp14__5_21;
      $R0 := bvadd_bv64($R0, 7bv64);
      $R1 := 121bv64;
      assert me_valid_access($mem_encoding, $R0, 1bv64);
      $mem := store8_le($mem, $R0, $R1[8:0]);
      Exp14__5_22 := load64_le($stack, bvadd_bv64($R31, 24bv64));
      $R0 := Exp14__5_22;
      $R30 := 2320bv64;
      goto b#FUN_7a0_entry_7;
    b#FUN_7a0_entry_7:
      R30_begin_FUN_7a0_1952 := $R30;
      $R16 := 131072bv64;
      assert me_valid_access($mem_encoding, bvadd_bv64($R16, 40bv64), 8bv64);
      Exp14__5_1 := load64_le($mem, bvadd_bv64($R16, 40bv64));
      $R17 := Exp14__5_1;
      $R16 := bvadd_bv64($R16, 40bv64);
      assert ($R30 == R30_begin_FUN_7a0_1952);
      call p$free();
      goto b#FUN_7a0_basil_return_1_8;
    b#FUN_7a0_basil_return_1_8:
      goto b#_inlineret_3;
    b#_inlineret_3:
      goto b#main_3;
    b#main_3:
      $R0 := 0bv64;
      Exp16__5_24 := load64_le($stack, $R31);
      Exp18__5_25 := load64_le($stack, bvadd_bv64($R31, 8bv64));
      $R29 := Exp16__5_24;
      $R30 := Exp18__5_25;
      $R31 := bvadd_bv64($R31, 32bv64);
      goto b#main_basil_return_1;
    b#main_basil_return_1:
      assert true;
      return;
  }

  $ boogie ./bad.bpl
  ./bad.bpl(171,5): Error: this assertion could not be proved
  Execution trace:
      ./bad.bpl(141,3): b#main_entry
  
  Boogie program verifier finished with 0 verified, 1 error
