var shared $Global_4325420_4325424: bv32
  classification true;

prog entry @main_4196164;

proc @main_4196164
  (R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64, R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64, R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64, R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
    -> (R0_out:bv64, R1_out:bv64)
  { .name = "main"; .address = 0x400744; .returnBlock = "main_return" }
[
  block %main_entry {.address = 0x400744; .originalLabel = "SFN4dpBgSO2bPUu0fyDluw=="} [
    $Global_4325420_4325424: bv32 mem:= 0x2a:bv32 { .label = "4196176_0" };
    goto(%main_return);
  ];
  block %main_return [
    return (0x0:bv64, 0x2a:bv64);
  ]
];

