proc @main_4196164(R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64,
   R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64,
   R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64,
   R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
   -> (R0_out:bv64, R1_out:bv64) { .address = 4196164; .name = "main";
    .returnBlock = "main_return" }

[
   block %main_entry [
     var as:bv64 := 0x32:bv64;
     (var x_2:bv64, var x_3:bv64, var addr:bv64):= call @_havoc();
     (var ptr0:bv64):= call @_malloc(as:bv64);
     (var ptr1:bv64):= call @_calloc(as:bv64);
     call @_free(ptr0:bv64);
     call @_free(ptr1:bv64);
     (var stack_ptr:bv64):= call @_alloca(as:bv64);
     call @_free_alloca(stack_ptr:bv64);
     goto (%main_return);
   ];
   block %main_return [
     (var R0_out:bv64 := 0x0:bv64, var R1_out:bv64 := 0x2a:bv64);
     return;
   ]
];
prog entry @main_4196164;