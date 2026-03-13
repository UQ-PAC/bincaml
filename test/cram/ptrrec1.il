var $rec:{("0": bv32)};
prog entry @main_4196164;
proc @main_4196164(R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64,
   R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64,
   R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64,
   R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
   -> (R0_out:bv64, R1_out:bv64) { .address = 4196164; .name = "main";
    .returnBlock = "main_return" }
  modifies $rec:{("0": bv32)}
  captures $rec:{("0": bv32)}

[
   block %main_entry [
     var as:ptr(bv64, bv64) := ptradd(R31_in:bv64, R0_in:bv64);
     var af:bv32 := faccess("0", $rec:{("0": bv32)});
     $rec:{("0": bv32)} := fset("0", $rec:{("0": bv32)}, af:bv32);
     goto (%main_return);
   ];
   block %main_return [
     (var R0_out:bv64 := 0x0:bv64, var R1_out:bv64 := 0x2a:bv64);
     return;
   ]
];