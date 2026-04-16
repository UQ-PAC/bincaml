
  $ bincaml script roundtrip.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)
  (load-il ../../examples/x-output.il)
  (dump-il before2.il)
  (load-il before2.il)
  (dump-il after2.il)
  (load-il memassign.il)
  (dump-il beforemem.il)
  (load-il beforemem.il)
  (dump-il aftermem.il)
  (load-il ptrrec1.il)
  (dump-il ptrrec2.il)
  (load-il ptrrec2.il)
  (dump-il ptrrec3.il)

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  117c117
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  [1]

  $ diff before2.il after2.il

Memassign repr

  $ diff beforemem.il aftermem.il
  $ cat aftermem.il
  type uninterpSort = UninterpSort;
  type opaque = A | B | C;
  type variants = AA of {a: bv64} | BB of {b: bv32} | CC of {c: bv8};
  type record = Record of {a: bv64; b: bv32; c: bv64};
  type ilist = Cons of {head: bv64; tail: ilist} | Nil;
  var observable $Global_4325420_4325424:bv32 classification true;
  let $mul_2 (a:bv64), (b:bv64) : bv64 = (bvadd(b, bvmul(a, 0x2:bv64)));
  let $test (a:bv64) : bv64 = (if eq(a, 0x1:bv64) then 0xa:bv64 else 0xb:bv64);
  proc @main_4196164(R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64,
     R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64,
     R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64,
     R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
     -> (R0_out:bv64, R1_out:bv64) { .address = 4196164; .name = "main";
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32
    captures $Global_4325420_4325424:bv32
  
  [
     block %main_entry [
       $Global_4325420_4325424:bv32 := store  0x2a:bv32;
       goto (%main_return);
     ];
     block %main_return [
       (var R0_out:bv64 := 0x0:bv64, var R1_out:bv64 := 0x2a:bv64);
       return;
     ]
  ];
  let $a : uninterpSort = UninterpSort;
  let $b : record = (Record)(0x1:bv64, 0x2:bv64, 0x3:bv64);
  let $three : bv64 = let func (a:bv64) : bv64 = (bvadd(a, 0x1:bv64)) in ((func)(($mul_2)(0x2:bv64,
           0x1:bv64)));
  prog entry @main_4196164;


Record and Pointer

  $ diff ptrrec1.il ptrrec2.il
  2d1
  < prog entry @main_4196164;
  23c22,23
  < ];
  \ No newline at end of file
  ---
  > ];
  > prog entry @main_4196164;
  \ No newline at end of file
  [1]
  $ diff ptrrec2.il ptrrec3.il
