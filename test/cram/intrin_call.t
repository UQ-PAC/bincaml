  $ bincaml script intrin_call.sexp
  (load-il ../../examples/memory/malloc_free.il)
  (run-transforms intrin-call)
  (dump-il after.il)
  $ cat after.il
  var observable $mem:(bv64->bv8);
  var $stack:(bv64->bv8);
  proc @main_2276(R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64, R29_in:bv64,
     R30_in:bv64, R31_in:bv64, _PC_in:bv64)
     -> (R0_out:bv64, R17_out:bv64, R1_out:bv64, R29_out:bv64, R30_out:bv64) { .address = 2276;
      .name = "main"; .returnBlock = "main_return" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  
  [
     block %main_entry [
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xffffffffffffffe0:bv64) R29_in:bv64 64;
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xffffffffffffffe8:bv64) R30_in:bv64 64;
       var Exp14__5_2_1:bv64 := load le $mem:(bv64->bv8) 0x20010:bv64 64;
       assert true;
       (var R0_3:bv64):= call @_malloc(0x1:bv64);
       ($mem:(bv64->bv8), $stack:(bv64->bv8)):= call @_havoc();
       goto (%phi_5);
     ];
     block %phi_5 [
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xfffffffffffffff8:bv64) R0_3:bv64 64;
       var Exp14__5_21_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xfffffffffffffff8:bv64) 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) Exp14__5_21_1:bv64 0x79:bv8 8;
       var Exp14__5_22_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xfffffffffffffff8:bv64) 64;
       var Exp14__5_1_1:bv64 := load le $mem:(bv64->bv8) 0x20028:bv64 64;
       assert true;
       call @_free(Exp14__5_22_1:bv64);
       ($mem:(bv64->bv8), $stack:(bv64->bv8)):= call @_havoc();
       goto (%phi_6);
     ];
     block %phi_6 [
       var Exp16__5_24_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xffffffffffffffe0:bv64) 64;
       var Exp18__5_25_1:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
        0xffffffffffffffe8:bv64) 64;
       goto (%main_return);
     ];
     block %main_return [
       (var R0_out:bv64 := 0x0:bv64, var R17_out:bv64 := Exp14__5_1_1:bv64,
        var R1_out:bv64 := 0x79:bv64, var R29_out:bv64 := Exp16__5_24_1:bv64,
        var R30_out:bv64 := Exp18__5_25_1:bv64);
       return;
     ]
  ];
  proc @malloc(R0_in:bv64)  -> (R0_out:bv64) { .name = "malloc" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ;
  proc @#free(R0_in:bv64)  -> () { .name = "#free" }
    modifies $mem:(bv64->bv8), $stack:(bv64->bv8)
    captures $mem:(bv64->bv8), $stack:(bv64->bv8)
  ;
  prog entry @main_2276;
