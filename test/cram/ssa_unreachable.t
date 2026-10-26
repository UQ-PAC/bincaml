
  $ cat <<'EOF' > unreachable.il
  > proc @FUN_750(PC_in:bv64, R16_in:bv64, R17_in:bv64)  -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
  >   captures $mem:(bv64->bv8)
  >   requires boolor(eq(0x750:bv64, PC_in:bv64))
  > [
  >    block %inputs [
  >      (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64, var R17:bv64 := R17_in:bv64);
  >      goto (%FUN_750_code);
  >    ];
  >    block %FUN_750_code [
  >      var PC:bv64 := PC:bv64;
  >      assume eq(0x750:bv64, PC:bv64);
  >      goto (%block);
  >    ];
  >    block %block { .asm = "adrp x16, #0x20000" } [
  >      var R16:bv64 := 0x20000:bv64;
  >      (var BranchTaken:bool := false, var PC:bv64 := 0x754:bv64);
  >      goto (%block_1);
  >    ];
  >    block %block_1 { .asm = "ldr x17, [x16]" } [
  >      var local:bv64 := 0x0:bv64;
  >      var local:bv64 := R16:bv64;
  >      var local_1:bv64 := 0x0:bv64;
  >      var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x0:bv64) 64;
  >      var local_1:bv64 := local_2:bv64;
  >      var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
  >      (var BranchTaken:bool := false, var PC:bv64 := 0x758:bv64);
  >      goto (%block_2);
  >    ];
  >    block %block_2 { .asm = "add x16, x16, #0" } [
  >      var local_3:bv64 := 0x0:bv64;
  >      var local_4:bv64 := 0x0:bv64;
  >      var local_4:bv64 := R16:bv64;
  >      var R16:bv64 := bvadd(local_4:bv64, 0x0:bv64);
  >      (var BranchTaken:bool := false, var PC:bv64 := 0x75c:bv64);
  >      goto (%block_3);
  >    ];
  >    block %block_3 { .asm = "br x17" } [
  >      var local_5:bv64 := 0x0:bv64;
  >      var BTypeNext:bv2 := 0x1:bv2;
  >      var BranchTaken:bool := true;
  >      var PC:bv64 := R17:bv64;
  >      goto (%FUN_750_code_1);
  >    ];
  >    block %FUN_750_code_1 [ assert false; unreachable; ];
  >    block %returns [
  >      (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64, var R17_out:bv64 := R17:bv64);
  >      goto (%Return);
  >    ];
  >    block %Return [
  >      (var PC_out:bv64 := PC_out:bv64, var R16_out:bv64 := R16_out:bv64,
  >       var R17_out:bv64 := R17_out:bv64);
  >      return;
  >    ]
  > ];
  > EOF

  $ cat <<'EOF' | bincaml script -
  > (load-il unreachable.il)
  > (run-transforms simple-params)
  > (run-transforms simple-ssa)
  > (dump-il after.il)
  > EOF
  (load-il unreachable.il)
  bincaml: [WARNING] Warn: global undeclared $mem. assuming mutable unshared
  bincaml: [WARNING] Warn: global undeclared $mem. assuming mutable unshared
  (run-transforms simple-params)
  (run-transforms simple-ssa)
  bincaml: (run-transforms simple-ssa): Not_found
           
  [123]
