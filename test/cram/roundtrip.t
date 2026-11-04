
  $ bincaml script roundtrip.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)
  (load-il ../../examples/x-output.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il before2.il)
  (load-il before2.il)
  (dump-il after2.il)
  (load-il memassign.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il beforemem.il)
  (load-il beforemem.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il aftermem.il)
  (load-il ptrrec1.il)
  (dump-il ptrrec2.il)
  (load-il ptrrec2.il)
  (dump-il ptrrec3.il)

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il

  $ diff before2.il after2.il

Memassign repr

  $ diff beforemem.il aftermem.il
  $ cat aftermem.il
  var observable $Global_4325420_4325424:bv32 classification true;
  type uninterpSort = UninterpSort;
  type opaque = A | B | C;
  type variants = AA of {a: bv64} | BB of {b: bv32} | CC of {c: bv8};
  type record = Record of {a: bv64; b: bv32; c: bv64};
  type ilist = Cons of {head: bv64; tail: ilist} | Nil;
  let $mul_2 (a:bv64), (b:bv64) : bv64 = (bvadd(b:bv64, bvmul(a:bv64, 0x2:bv64)));
  let $test (a:bv64) : bv64 = (if eq(a:bv64, 0x1:bv64) then 0xa:bv64 else 0xb:bv64);
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
  let $a : uninterpSort = UninterpSort;
  let $b : record = (Record)(0x1:bv64, 0x2:bv32, 0x3:bv64);
  let $three : bv64 = let func (a:bv64) : bv64 = (bvadd(a:bv64, 0x1:bv64)) in ((func:(bv64->bv64))(($mul_2)(0x2:bv64,
           0x1:bv64)));
  prog entry @main_4196164;


Record and Pointer

  $ diff ptrrec1.il ptrrec2.il
  2d1
  < prog entry @main_4196164;
  14c13
  <      var as:ptr(bv64, bv64) := ptradd(R31_in, R0_in);
  ---
  >      var as:ptr(bv64, bv64) := ptradd(R31_in:bv64, R0_in:bv64);
  16c15
  <      $rec:{"field0": (bv32, 0), "field1": (bv64, 32)} := $rec with field0 = af;
  ---
  >      $rec:{"field0": (bv32, 0), "field1": (bv64, 32)} := $rec with field0 = af:bv32;
  23c22,23
  < ];
  \ No newline at end of file
  ---
  > ];
  > prog entry @main_4196164;
  \ No newline at end of file
  [1]
  $ diff ptrrec2.il ptrrec3.il


Examples Directory

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/cntlm-simp-output.il")
  > (dump-il "before.il")
  > (load-il "before.il")
  > (dump-il "after.il")
  > EOF
  (load-il ../../examples/cntlm-simp-output.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)

  $ diff before.il after.il | head


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/cntlm-output.il")
  > (dump-il "before.il")
  > (load-il "before.il")
  > (dump-il "after.il")
  > EOF
  (load-il ../../examples/cntlm-output.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)

  $ diff before.il after.il | head -n 50
  518c518
  <      goto (%main_2185,%main_2181,%main_2177,%main_2169,%main_2151,%main_2149,%main_2123,%main_2119,%main_2117,%main_2115,%main_2111,%main_2109,%main_2095,%main_2093,%main_2091,%main_2077,%main_2069,%main_2065,%main_2061,%main_2059,%main_2035,%main_2031,%main_2029,%main_2025,%main_1999,%main_1989,%main_1985,%main_1977,%main_1973,%main_1971,%main_1955);
  ---
  >      goto (%main_2177,%main_2185,%main_2181,%main_2169,%main_2151,%main_2149,%main_2123,%main_2119,%main_2117,%main_2115,%main_2111,%main_2109,%main_2095,%main_2093,%main_2091,%main_2077,%main_2069,%main_2065,%main_2061,%main_2059,%main_2035,%main_2031,%main_2029,%main_2025,%main_1999,%main_1989,%main_1985,%main_1977,%main_1973,%main_1971,%main_1955);


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (dump-il "before.il")
  > (load-il "before.il")
  > (dump-il "after.il")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)

  $ diff before.il after.il

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/sqrt.il")
  > (dump-il "before.il")
  > (load-il "before.il")
  > (dump-il "after.il")
  > EOF
  (load-il ../../examples/sqrt.il)
  (dump-il before.il)
  (load-il before.il)
  (dump-il after.il)

  $ diff before.il after.il

