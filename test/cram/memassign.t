
  $ cat << EOF | bincaml script -
  > (load-il "memassign.il")
  > (run-transforms "hindley-milner-elaborate")
  > (dump-il "memout.il")
  > (load-il "memout.il")
  > EOF
  (load-il memassign.il)
  UninterpSort
  A | B | C
  A | B | C
  A | B | C
  ({a: bv64}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({b: bv32}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({c: bv8}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({a: bv64; b: bv32; c: bv64}->Record of ({a: bv64;
     b: bv32; c: bv64}))
  (run-transforms hindley-milner-elaborate)
  (dump-il memout.il)
  (load-il memout.il)
  UninterpSort
  A | B | C
  A | B | C
  A | B | C
  ({a: bv64}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({b: bv32}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({c: bv8}->AA of ({a: bv64}) | BB of ({b: bv32}) |
   CC of ({c: bv8}))
  ({a: bv64; b: bv32; c: bv64}->Record of ({a: bv64;
     b: bv32; c: bv64}))


  $ cat memout.il |  grep Global -B 1 -A 1
  var observable $Global_4325420_4325424:bv32 classification true;
  type uninterpSort = UninterpSort;
  --
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32
    captures $Global_4325420_4325424:bv32
  
  --
         .originalLabel = "SFN4dpBgSO2bPUu0fyDluw==" } [
       $Global_4325420_4325424:bv32 := store  0x2a:bv32 { .label = "4196176_0" };
       goto (%main_return);



  $ cat memout.il
  var observable $Global_4325420_4325424:bv32 classification true;
  type uninterpSort = UninterpSort;
  type opaque = A | B | C;
  type variants = AA of ({a: bv64}) | BB of ({b: bv32}) |
  CC of ({c: bv8});
  type abcderecord = Record of ({a: bv64; b: bv32; c: bv64});
  type abcde = {a: bv64; b: bv64};
  let $mul_2 (a:bv64 ), (b:bv64 ) : bv64 = (bvadd(b:bv64, bvmul(a:bv64, 0x2:bv64)));
  let $test (a:bv64 ) : bv64 = (if eq(a:bv64, 0x1:bv64) then 0xa:bv64 else 0xb:bv64);
  type finite_array = {data: (bv8[bv64]); offset: bv64; len: bv64};
  let $access_array (a:finite_array ), (addr:bv64 ) : bv8 = (get(a:finite_array.data,
    bvadd(a:finite_array.offset, addr:bv64)));
  let $array_len (a:finite_array ) : bv64 = (a:finite_array.len);
  let $array_equal (a:finite_array ), (b:finite_array ) : bool = (booland(eq(a:finite_array.len,
     b:finite_array.len),
    forall (ind:bv64) :: (eq(eq(bvule(0x0:bv64, ind:bv64),
       bvult(ind:bv64, a:finite_array.len)),
      eq(($access_array)(a:finite_array, ind:bv64),
       ($access_array)(b:finite_array, ind:bv64))))));
  let $memory_equal (data:(bv8[bv64]) ), (a:finite_array ) : bool = (forall (ind:bv64) :: (eq(eq(bvule(0x0:bv64,
       ind:bv64), bvult(ind:bv64, a:finite_array.len)),
     eq(($access_array)(a:finite_array, ind:bv64),
      get(data:(bv8[bv64]), bvadd(a:finite_array.offset, ind:bv64))))));
  proc @main_4196164(R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64,
     R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64,
     R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64,
     R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
     -> (R0_out:bv64, R1_out:bv64) { .address = 4196164; .name = "main";
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32
    captures $Global_4325420_4325424:bv32
  
  [
     block %main_entry { .address = 4196164;
         .originalLabel = "SFN4dpBgSO2bPUu0fyDluw==" } [
       $Global_4325420_4325424:bv32 := store  0x2a:bv32 { .label = "4196176_0" };
       goto (%main_return);
     ];
     block %main_return [
       (var R0_out:bv64 := 0x0:bv64, var R1_out:bv64 := 0x2a:bv64);
       return;
     ]
  ];
  let $a : uninterpSort = (uninterpSort#UninterpSort)();
  let $abcd : abcde = {a=0xa:bv64; b=0xb:bv64};
  let $b : abcderecord = (abcderecord#Record)({a=0x1:bv64; b=0x2:bv32; c=0x3:bv64});
  let $three : bv64 = let func (a:bv64 ) : bv64 = (bvadd(a:bv64, 0x1:bv64)) in ((func:(bv64->bv64))(($mul_2)(0x2:bv64,
           0x1:bv64)));
  prog entry @main_4196164;
