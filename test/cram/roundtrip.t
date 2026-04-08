
  $ bincaml script roundtrip.sexp
  bincaml: Error in (load-il beforemem.il): Parse error:  beforemem.il:3
           3 | let $b : record = Record of {a: bv64; b: bv32; c: bv64} = (Record)(0x1:bv64,
                                        ^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:85
  [123]

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il
  16c16
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  18c18
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  121c121
  <    block %main_basil_return_1 [ nop; return; ]
  ---
  >    block %main_basil_return_1 [ return; ]
  125c125
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  127c127
  <     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1
  ---
  >     $R1:bv64, $R29:bv64, $R30:bv64, $R31:bv64, $VF:bv1, $ZF:bv1, $mem:(bv64->bv8)
  [1]

  $ diff before2.il after2.il
  7,8c7,8
  <   modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
  <   captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ---
  >   modifies $stack:(bv64->bv8), $mem:(bv64->bv8)
  >   captures $stack:(bv64->bv8), $mem:(bv64->bv8)
  [1]

Memassign repr

  $ diff beforemem.il aftermem.il
  $ cat aftermem.il
   var observable $Global_4325420_4325424:bv32 classification true;
     let $mul_2 (a:bv64), (b:bv64) : bv64 = (bvadd(b:bv64, bvmul(a:bv64, 0x2:bv64)));
     let $three : bv64 = let func (a:bv64) : bv64 = (bvadd(a:bv64, 0x1:bv64)) in ((func:(bv64->bv64))(($mul_2:((bv64)->(bv64->bv64)))(0x2:bv64,
              0x1:bv64)));
     type UninterpSort;
     type ilist = Cons of {head: bv64; tail: ilist} | Nil;
     type opaque = A | B | C;
     type record = Record of {a: bv64; b: bv32; c: bv64};
     type variants = A of {a: bv64} | B of {b: bv32} | C of {c: bv8};
     prog entry @main_4196164;
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


Record and Pointer

  $ diff ptrrec1.il ptrrec2.il
  $ diff ptrrec2.il ptrrec3.il
