  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/gtirb/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (load-il gtirb-output.il)
  > (dump-il "dumped.il")
  > (run-transforms aslp-semantics)
  > (dump-il "semantics.il")
  > (log-level debug)
  > (run-transforms type-check check-read-uninitialised-withlocals)
  > (load-il "semantics.il")
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  (dump-il gtirb-output.il)
  (load-il gtirb-output.il)
  (dump-il dumped.il)
  (run-transforms aslp-semantics)
  bincaml: [WARNING] Invariants not satisfied during 'aslp-semantics'. Needs [GtirbArm] but only have [].
  (dump-il semantics.il)
  (log-level debug)
  (run-transforms type-check check-read-uninitialised-withlocals)
  bincaml: [DEBUG] Starting type-check
  bincaml: [DEBUG] Starting check-read-uninitialised-withlocals
  (load-il semantics.il)
  $ diff gtirb-output.il dumped.il

  $ cat semantics.il
  var observable $mem:(bv64->bv8);
  var $SP:bv64;
  var $R0:bv64;
  var $R1:bv64;
  var $R2:bv64;
  var $R3:bv64;
  var $R4:bv64;
  var $R5:bv64;
  var $R6:bv64;
  var $R16:bv64;
  var $R17:bv64;
  var $R19:bv64;
  var $R29:bv64;
  var $R30:bv64;
  var $PSTATE_N:bv1;
  var $PSTATE_Z:bv1;
  var $PSTATE_C:bv1;
  var $PSTATE_V:bv1;
  var $PC:bv64;
  proc @_fini()  -> () {  }
    modifies $PC:bv64, $R29:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    captures $PC:bv64, $R29:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400828:bv64, $PC))
  
  [
     block %_fini_code { .address = 4196392; .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
         .succ = [ { .address = 4196404; .conditional = "false"; .direct = "true";
                 .target = "internal:wK9NYU4TTr+D8gXPiCk+7w";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x400828:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32, 0x400828:bv64) { .asm = "nop ";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
        0xfffffffffffffff0:bv64) $R29 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
         0xfffffffffffffff0:bv64), 0x8:bv64) $R30 64;
       $SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400830:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       $R29:bv64 := bvadd($SP, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400834:bv64);
       goto (%_fini_code_2);
     ];
     block %_fini_code_2 [
       assert boolor(eq(0x400834:bv64, $PC));
       goto (%_fini_code_1);
     ];
     block %_fini_code_1 { .address = 4196404;
         .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400834:bv64, $PC);
       goto (%block_2);
     ];
     block %block_2 { .asm = "ldp x29, x30, [sp], #0x10" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := $SP;
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := load le $mem:(bv64->bv8) $SP 64;
       var local_3:bv64 := local_4:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       $R29:bv64 := local_3:bv64;
       $R30:bv64 := local_5:bv64;
       $SP:bv64 := bvadd(local_2:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400838:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "ret " } [
       var local_7:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%_fini_code_3);
     ];
     block %_fini_code_3 [ assert boolor(); goto (%ret_1); ];
     block %ret_1 [ return; ]
  ];
  proc @_init()  -> () {  }
    modifies $PC:bv64, $R0:bv64, $R16:bv64, $R17:bv64, $R29:bv64, $R30:bv64,
      $SP:bv64, $mem:(bv64->bv8)
    captures $PC:bv64, $R0:bv64, $R16:bv64, $R17:bv64, $R29:bv64, $R30:bv64,
      $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400600:bv64, $PC))
  
  [
     block %_init_code { .address = 4195840; .gtirb_block = "UfNyH7KvQiam2F847lIf0g";
         .succ = [ { .address = 4196036; .conditional = "false"; .direct = "true";
                 .target = "stmts:Djx7L34DQzuSXaBFEj/bpQ"; .type = "Type_Call" } ] } [
       assume eq(0x400600:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32, 0x400600:bv64) { .asm = "nop ";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
        0xfffffffffffffff0:bv64) $R29 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
         0xfffffffffffffff0:bv64), 0x8:bv64) $R30 64;
       $SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400608:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       $R29:bv64 := bvadd($SP, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40060c:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "bl #0xb8" } [
       $R30:bv64 := 0x400610:bv64;
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4006c4:bv64;
       goto (%_init_code_2);
     ];
     block %_init_code_2 [
       assert boolor(eq(0x4006c4:bv64, $PC));
       goto (%_init_ext);
     ];
     block %_init_ext [
       assume eq(0x4006c4:bv64, $PC);
       call @call_weak_fn();
       assert boolor(eq(0x400610:bv64, $PC));
       goto (%_init_code_1);
     ];
     block %_init_code_1 { .address = 4195856;
         .gtirb_block = "xdU61Ad4R3aE/hVJ17n5eQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400610:bv64, $PC);
       goto (%block_3);
     ];
     block %block_3 { .asm = "ldp x29, x30, [sp], #0x10" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := $SP;
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := load le $mem:(bv64->bv8) $SP 64;
       var local_3:bv64 := local_4:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       $R29:bv64 := local_3:bv64;
       $R30:bv64 := local_5:bv64;
       $SP:bv64 := bvadd(local_2:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400614:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "ret " } [
       var local_7:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%_init_code_3);
     ];
     block %_init_code_3 [ assert boolor(); goto (%ret_1); ];
     block %ret_1 [ return; ]
  ];
  proc @__do_global_dtors_aux()  -> () {  }
    modifies $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R16:bv64, $R19:bv64, $R29:bv64, $R30:bv64, $SP:bv64,
      $mem:(bv64->bv8)
    captures $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R16:bv64, $R19:bv64, $R29:bv64, $R30:bv64, $SP:bv64,
      $mem:(bv64->bv8)
    requires boolor(eq(0x40074c:bv64, $PC))
  
  [
     block %__do_global_dtors_aux_code { .address = 4196172;
         .gtirb_block = "D9t2gNJrSmyMH3GAVRe3IQ";
         .succ = [ { .address = 4196196; .conditional = "true"; .direct = "true";
                 .target = "internal:lwyID0MJQb6vgyjzPFtz8Q";
                 .type = "Type_Fallthrough" };
             { .address = 4196208; .conditional = "true"; .direct = "true";
                 .target = "internal:SFN4dpBgSO2bPUu0fyDluw"; .type = "Type_Branch" } ] } [
       assume eq(0x40074c:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
        0xffffffffffffffe0:bv64) $R29 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
         0xffffffffffffffe0:bv64), 0x8:bv64) $R30 64;
       $SP:bv64 := bvadd(local:bv64, 0xffffffffffffffe0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400750:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       $R29:bv64 := bvadd($SP, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400754:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "str x19, [sp, #0x10]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x10:bv64) $R19 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400758:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "adrp x19, #0x20000" } [
       $R19:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40075c:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "ldrb w0, [x19, #0x28]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := $R19;
       var local_3:bv8 := 0x0:bv8;
       var local_4:bv8 := load le $mem:(bv64->bv8) bvadd(local_2:bv64, 0x28:bv64) 8;
       var local_3:bv8 := local_4:bv8;
       $R0:bv64 := zero_extend(32, zero_extend(24, local_3:bv8));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400760:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "tbnz w0, #0, #0x10" } [ goto (%block_7,%block_6); ];
     block %block_6 [
       assume eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, $R0),
         zero_extend(20, 0x0:bv12)))), 0x1:bv1);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400770:bv64;
       goto (%block_8);
     ];
     block %block_7 [
       assume boolnot(eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, $R0),
          zero_extend(20, 0x0:bv12)))), 0x1:bv1));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400764:bv64);
       goto (%block_8);
     ];
     block %block_8 [
       $PC:bv64 := if eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, $R0),
         zero_extend(20, 0x0:bv12)))), 0x1:bv1) then 0x400770:bv64 else 0x400764:bv64;
       goto (%__do_global_dtors_aux_code_4);
     ];
     block %__do_global_dtors_aux_code_4 [
       assert boolor(eq(0x400764:bv64, $PC), eq(0x400770:bv64, $PC));
       goto (%__do_global_dtors_aux_code_3,%__do_global_dtors_aux_code_1);
     ];
     block %__do_global_dtors_aux_code_1 { .address = 4196208;
         .gtirb_block = "SFN4dpBgSO2bPUu0fyDluw";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400770:bv64, $PC);
       goto (%block_9);
     ];
     block %block_9 { .asm = "ldr x19, [sp, #0x10]" } [
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x10:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       $R19:bv64 := zero_extend(0, zero_extend(0, local_5:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400774:bv64);
       goto (%block_10);
     ];
     block %block_10 { .asm = "ldp x29, x30, [sp], #0x20" } [
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := $SP;
       var local_8:bv64 := 0x0:bv64;
       var local_9:bv64 := load le $mem:(bv64->bv8) $SP 64;
       var local_8:bv64 := local_9:bv64;
       var local_10:bv64 := 0x0:bv64;
       var local_11:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_10:bv64 := local_11:bv64;
       $R29:bv64 := local_8:bv64;
       $R30:bv64 := local_10:bv64;
       $SP:bv64 := bvadd(local_7:bv64, 0x20:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400778:bv64);
       goto (%block_11);
     ];
     block %block_11 { .asm = "ret " } [
       var local_12:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%__do_global_dtors_aux_code_5);
     ];
     block %__do_global_dtors_aux_code_5 [ assert boolor(); goto (%ret_2); ];
     block %ret_2 [ return; ];
     block %__do_global_dtors_aux_code_3 { .address = 4196196;
         .gtirb_block = "lwyID0MJQb6vgyjzPFtz8Q";
         .succ = [ { .address = 4196064; .conditional = "false"; .direct = "true";
                 .target = "stmts:GW0MHC+ORUKlCdpgOcZ6zA"; .type = "Type_Call" } ] } [
       assume eq(0x400764:bv64, $PC);
       goto (%block_12);
     ];
     block %block_12 { .asm = "bl #0xffffffffffffff7c" } [
       $R30:bv64 := 0x400768:bv64;
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4006e0:bv64;
       goto (%__do_global_dtors_aux_code_6);
     ];
     block %__do_global_dtors_aux_code_6 [
       assert boolor(eq(0x4006e0:bv64, $PC));
       goto (%__do_global_dtors_aux_ext);
     ];
     block %__do_global_dtors_aux_ext [
       assume eq(0x4006e0:bv64, $PC);
       call @deregister_tm_clones();
       assert boolor(eq(0x400768:bv64, $PC));
       goto (%__do_global_dtors_aux_code_2);
     ];
     block %__do_global_dtors_aux_code_2 { .address = 4196200;
         .gtirb_block = "TxTRm4kpQiq/Xgistx+xbQ";
         .succ = [ { .address = 4196208; .conditional = "false"; .direct = "true";
                 .target = "internal:SFN4dpBgSO2bPUu0fyDluw";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x400768:bv64, $PC);
       goto (%block_13);
     ];
     block %block_13 { .asm = "mov w0, #1" } [
       $R0:bv64 := 0x1:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40076c:bv64);
       goto (%block_14);
     ];
     block %block_14 { .asm = "strb w0, [x19, #0x28]" } [
       var local_13:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($R19, 0x28:bv64) extract(8,0, $R0) 8;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400770:bv64);
       goto (%__do_global_dtors_aux_code_7);
     ];
     block %__do_global_dtors_aux_code_7 [
       assert boolor(eq(0x400770:bv64, $PC));
       goto (%__do_global_dtors_aux_code_1);
     ]
  ];
  proc @register_tm_clones()  -> () {  }
    modifies $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R2:bv64
    captures $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R2:bv64, $R30:bv64,
      $mem:(bv64->bv8)
    requires boolor(eq(0x400710:bv64, $PC))
  
  [
     block %register_tm_clones_code_2 { .address = 4196112;
         .gtirb_block = "rIlbG4jGSTydaFqMhxCKWw";
         .succ = [ { .address = 4196148; .conditional = "true"; .direct = "true";
                 .target = "internal:tXIOhSQ+R1WA/9VL5+6KQQ";
                 .type = "Type_Fallthrough" };
             { .address = 4196168; .conditional = "true"; .direct = "true";
                 .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
       assume eq(0x400710:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x0, #0x20000" } [
       $R0:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400714:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "add x0, x0, #0x28" } [
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := $R0;
       $R0:bv64 := bvadd(local_1:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400718:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "adrp x1, #0x20000" } [
       $R1:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40071c:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "add x1, x1, #0x28" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_3:bv64 := $R1;
       $R1:bv64 := bvadd(local_3:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400720:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "sub x1, x1, x0" } [
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $R1;
       var local_5:bv64 := 0x0:bv64;
       var local_5:bv64 := $R0;
       $R1:bv64 := bvadd(bvadd(local_4:bv64,
         bvnot(bvshl(local_5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400724:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "lsr x2, x1, #0x3f" } [
       var local_6:bv64 := 0x0:bv64;
       var local_6:bv64 := $R1;
       $R2:bv64 := bvor(bvand(0x0:bv64, 0xfffffffffffffffe:bv64),
        bvand(bvor(bvand(0x0:bv64, 0x0:bv64),
          bvand(bvor(bvlshr(local_6:bv64, zero_extend(52, 0x3f:bv12)),
            bvshl(local_6:bv64, zero_extend(48, 0x1:bv16))), 0xffffffffffffffff:bv64)),
         0x1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400728:bv64);
       goto (%block_6);
     ];
     block %block_6 { .asm = "add x1, x2, x1, asr #3" } [
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := $R2;
       var local_8:bv64 := 0x0:bv64;
       var local_8:bv64 := $R1;
       $R1:bv64 := bvadd(local_7:bv64,
        bvashr(local_8:bv64, zero_extend(52, 0x3:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x40072c:bv64);
       goto (%register_tm_clones_code_4);
     ];
     block %register_tm_clones_code_4 [
       call @_aarch64_eval(0x9341fc21:bv32, 0x40072c:bv64) { .asm = "asr x1, x1, #1";
           .error = "Failure(\"f_gen_replicate_bits\")" };
       goto (%block_7);
     ];
     block %block_7 { .asm = "cbz x1, #0x18" } [ goto (%block_9,%block_8); ];
     block %block_8 [
       assume eq($R1, 0x0:bv64);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400748:bv64;
       goto (%block_10);
     ];
     block %block_9 [
       assume boolnot(eq($R1, 0x0:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400734:bv64);
       goto (%block_10);
     ];
     block %block_10 [
       $PC:bv64 := if eq($R1, 0x0:bv64) then 0x400748:bv64 else 0x400734:bv64;
       goto (%register_tm_clones_code_5);
     ];
     block %register_tm_clones_code_5 [
       assert boolor(eq(0x400734:bv64, $PC), eq(0x400748:bv64, $PC));
       goto (%register_tm_clones_code_3,%register_tm_clones_code);
     ];
     block %register_tm_clones_code { .address = 4196168;
         .gtirb_block = "IkNYmV06TxC75h8A4NM3wA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400748:bv64, $PC);
       goto (%block_11);
     ];
     block %block_11 { .asm = "ret " } [
       var local_10:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%register_tm_clones_code_6);
     ];
     block %register_tm_clones_code_6 [ assert boolor(); goto (%ret); ];
     block %ret [ return; ];
     block %register_tm_clones_code_3 { .address = 4196148;
         .gtirb_block = "tXIOhSQ+R1WA/9VL5+6KQQ";
         .succ = [ { .address = 4196160; .conditional = "true"; .direct = "true";
                 .target = "internal:oqiqdATZTc6MDOYJqL9Aew";
                 .type = "Type_Fallthrough" };
             { .address = 4196168; .conditional = "true"; .direct = "true";
                 .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
       assume eq(0x400734:bv64, $PC);
       goto (%block_12);
     ];
     block %block_12 { .asm = "adrp x2, #0x1f000" } [
       $R2:bv64 := 0x41f000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400738:bv64);
       goto (%block_13);
     ];
     block %block_13 { .asm = "ldr x2, [x2, #0xfe0]" } [
       var local_11:bv64 := 0x0:bv64;
       var local_11:bv64 := $R2;
       var local_12:bv64 := 0x0:bv64;
       var local_13:bv64 := load le $mem:(bv64->bv8) bvadd(local_11:bv64, 0xfe0:bv64) 64;
       var local_12:bv64 := local_13:bv64;
       $R2:bv64 := zero_extend(0, zero_extend(0, local_12:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x40073c:bv64);
       goto (%block_14);
     ];
     block %block_14 { .asm = "cbz x2, #0xc" } [ goto (%block_16,%block_15); ];
     block %block_15 [
       assume eq($R2, 0x0:bv64);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400748:bv64;
       goto (%block_17);
     ];
     block %block_16 [
       assume boolnot(eq($R2, 0x0:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400740:bv64);
       goto (%block_17);
     ];
     block %block_17 [
       $PC:bv64 := if eq($R2, 0x0:bv64) then 0x400748:bv64 else 0x400740:bv64;
       goto (%register_tm_clones_code_7);
     ];
     block %register_tm_clones_code_7 [
       assert boolor(eq(0x400740:bv64, $PC), eq(0x400748:bv64, $PC));
       goto (%register_tm_clones_code_1,%register_tm_clones_code);
     ];
     block %register_tm_clones_code_1 { .address = 4196160;
         .gtirb_block = "oqiqdATZTc6MDOYJqL9Aew";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400740:bv64, $PC);
       goto (%block_18);
     ];
     block %block_18 { .asm = "mov x16, x2" } [
       var local_14:bv64 := 0x0:bv64;
       var local_14:bv64 := 0x0:bv64;
       var local_15:bv64 := 0x0:bv64;
       var local_15:bv64 := $R2;
       $R16:bv64 := bvor(local_14:bv64,
        bvshl(local_15:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400744:bv64);
       goto (%block_19);
     ];
     block %block_19 { .asm = "br x16" } [
       var local_16:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R16;
       goto (%register_tm_clones_code_8);
     ];
     block %register_tm_clones_code_8 [ assert boolor(); unreachable; ]
  ];
  proc @frame_dummy()  -> () {  }
    modifies $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R2:bv64
    captures $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R2:bv64, $R30:bv64,
      $mem:(bv64->bv8)
    requires boolor(eq(0x400780:bv64, $PC))
  
  [
     block %frame_dummy_code { .address = 4196224;
         .gtirb_block = "6JJvkaLhTaWXaEL0+yxKxg";
         .succ = [ { .address = 4196112; .conditional = "false"; .direct = "true";
                 .target = "stmts:rIlbG4jGSTydaFqMhxCKWw"; .type = "Type_Branch" } ] } [
       assume eq(0x400780:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "b #0xffffffffffffff90" } [
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400710:bv64;
       goto (%frame_dummy_code_1);
     ];
     block %frame_dummy_code_1 [
       assert boolor(eq(0x400710:bv64, $PC));
       goto (%frame_dummy_ext);
     ];
     block %frame_dummy_ext [
       assume eq(0x400710:bv64, $PC);
       call @register_tm_clones();
       assert boolor();
       unreachable;
     ]
  ];
  proc @FUN_400660()  -> () {  }
    modifies $PC:bv64, $R16:bv64, $R17:bv64
    captures $PC:bv64, $R16:bv64, $R17:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400660:bv64, $PC))
  
  [
     block %FUN_400660_code { .address = 4195936;
         .gtirb_block = "iedVtPHmSjuLgqSxHgXOuw";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:BsLBdgTFQlOA45HTKKU2gQ"; .type = "Type_Branch" } ] } [
       assume eq(0x400660:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       $R16:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400664:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #0x10]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $R16;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x10:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       $R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400668:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "add x16, x16, #0x10" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $R16;
       $R16:bv64 := bvadd(local_4:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40066c:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R17;
       goto (%FUN_400660_code_1);
     ];
     block %FUN_400660_code_1 [ assert boolor(); unreachable; ]
  ];
  proc @Sqrt()  -> () {  }
    modifies $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $SP:bv64, $mem:(bv64->bv8)
    captures $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400784:bv64, $PC))
  
  [
     block %Sqrt_code_1 { .address = 4196228;
         .gtirb_block = "OuTzy8qRTci75taVjGinFQ";
         .succ = [ { .address = 4196328; .conditional = "false"; .direct = "true";
                 .target = "internal:32fWxY7+R++JNJOFTmT+Sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400784:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "sub sp, sp, #0x30" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $SP:bv64 := bvadd(bvadd(local:bv64, 0xffffffffffffffcf:bv64), 0x1:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400788:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "str x0, [sp, #8]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) $R0 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40078c:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "str xzr, [sp, #0x28]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x28:bv64) 0x0:bv64 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400790:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "ldr x0, [sp, #8]" } [
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       $R0:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400794:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "add x0, x0, #1" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $R0;
       $R0:bv64 := bvadd(local_4:bv64, 0x1:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400798:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "str x0, [sp, #0x20]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x20:bv64) $R0 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40079c:bv64);
       goto (%block_6);
     ];
     block %block_6 { .asm = "b #0x4c" } [
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4007e8:bv64;
       goto (%Sqrt_code_6);
     ];
     block %Sqrt_code_6 [
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%Sqrt_code_5);
     ];
     block %Sqrt_code_5 { .address = 4196328;
         .gtirb_block = "32fWxY7+R++JNJOFTmT+Sg";
         .succ = [ { .address = 4196256; .conditional = "true"; .direct = "true";
                 .target = "internal:rCSSdLZcRB2TKAu9h+WCqg"; .type = "Type_Branch" };
             { .address = 4196348; .conditional = "true"; .direct = "true";
                 .target = "internal:lr6o4ptnRiK3TGR1gpiWGg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x4007e8:bv64, $PC);
       goto (%block_7);
     ];
     block %block_7 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x28:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       $R0:bv64 := zero_extend(0, zero_extend(0, local_5:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007ec:bv64);
       goto (%block_8);
     ];
     block %block_8 { .asm = "add x0, x0, #1" } [
       var local_7:bv64 := 0x0:bv64;
       var local_8:bv64 := 0x0:bv64;
       var local_8:bv64 := $R0;
       $R0:bv64 := bvadd(local_8:bv64, 0x1:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007f0:bv64);
       goto (%block_9);
     ];
     block %block_9 { .asm = "ldr x1, [sp, #0x20]" } [
       var local_9:bv64 := 0x0:bv64;
       var local_10:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x20:bv64) 64;
       var local_9:bv64 := local_10:bv64;
       $R1:bv64 := zero_extend(0, zero_extend(0, local_9:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007f4:bv64);
       goto (%block_10);
     ];
     block %block_10 { .asm = "cmp x1, x0" } [
       var local_11:bv64 := 0x0:bv64;
       var local_12:bv64 := 0x0:bv64;
       $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, $R1),
            sign_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, $R1),
            zero_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R1,
           bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64));
       $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R1,
         bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007f8:bv64);
       goto (%block_11);
     ];
     block %block_11 { .asm = "b.ne #0xffffffffffffffa8" } [
       goto (%block_13,%block_12);
     ];
     block %block_12 [
       assume boolnot(eq($PSTATE_Z, 0x1:bv1));
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4007a0:bv64;
       goto (%block_14);
     ];
     block %block_13 [
       assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007fc:bv64);
       goto (%block_14);
     ];
     block %block_14 [
       $PC:bv64 := if boolnot(eq($PSTATE_Z, 0x1:bv1)) then 0x4007a0:bv64 else 0x4007fc:bv64;
       goto (%Sqrt_code_7);
     ];
     block %Sqrt_code_7 [
       assert boolor(eq(0x4007a0:bv64, $PC), eq(0x4007fc:bv64, $PC));
       goto (%Sqrt_code_4,%Sqrt_code_3);
     ];
     block %Sqrt_code_3 { .address = 4196348;
         .gtirb_block = "lr6o4ptnRiK3TGR1gpiWGg";
         .succ = [ { .address = 4196384; .conditional = "false"; .direct = "true";
                 .target = "external:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Return" } ] } [
       assume eq(0x4007fc:bv64, $PC);
       goto (%block_15);
     ];
     block %block_15 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_13:bv64 := 0x0:bv64;
       var local_14:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x28:bv64) 64;
       var local_13:bv64 := local_14:bv64;
       $R0:bv64 := zero_extend(0, zero_extend(0, local_13:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400800:bv64);
       goto (%block_16);
     ];
     block %block_16 { .asm = "add sp, sp, #0x30" } [
       var local_15:bv64 := 0x0:bv64;
       var local_15:bv64 := $SP;
       $SP:bv64 := bvadd(local_15:bv64, 0x30:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400804:bv64);
       goto (%block_17);
     ];
     block %block_17 { .asm = "ret " } [
       var local_16:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%Sqrt_code_8);
     ];
     block %Sqrt_code_8 [ assert boolor(eq(0x400820:bv64, $PC)); goto (%ret_3); ];
     block %ret_3 [ return; ];
     block %Sqrt_code_4 { .address = 4196256;
         .gtirb_block = "rCSSdLZcRB2TKAu9h+WCqg";
         .succ = [ { .address = 4196308; .conditional = "true"; .direct = "true";
                 .target = "internal:ZLfuz7OtTNOS9GLtqSI1gg";
                 .type = "Type_Fallthrough" };
             { .address = 4196320; .conditional = "true"; .direct = "true";
                 .target = "internal:HVqN0/3+RWiLPKsHRvUqeg"; .type = "Type_Branch" } ] } [
       assume eq(0x4007a0:bv64, $PC);
       goto (%block_18);
     ];
     block %block_18 { .asm = "ldr x1, [sp, #0x28]" } [
       var local_17:bv64 := 0x0:bv64;
       var local_18:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x28:bv64) 64;
       var local_17:bv64 := local_18:bv64;
       $R1:bv64 := zero_extend(0, zero_extend(0, local_17:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007a4:bv64);
       goto (%block_19);
     ];
     block %block_19 { .asm = "ldr x0, [sp, #0x20]" } [
       var local_19:bv64 := 0x0:bv64;
       var local_20:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x20:bv64) 64;
       var local_19:bv64 := local_20:bv64;
       $R0:bv64 := zero_extend(0, zero_extend(0, local_19:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007a8:bv64);
       goto (%block_20);
     ];
     block %block_20 { .asm = "add x0, x1, x0" } [
       var local_21:bv64 := 0x0:bv64;
       var local_21:bv64 := $R1;
       var local_22:bv64 := 0x0:bv64;
       var local_22:bv64 := $R0;
       $R0:bv64 := bvadd(local_21:bv64,
        bvshl(local_22:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007ac:bv64);
       goto (%block_21);
     ];
     block %block_21 { .asm = "lsr x1, x0, #0x3f" } [
       var local_23:bv64 := 0x0:bv64;
       var local_23:bv64 := $R0;
       $R1:bv64 := bvor(bvand(0x0:bv64, 0xfffffffffffffffe:bv64),
        bvand(bvor(bvand(0x0:bv64, 0x0:bv64),
          bvand(bvor(bvlshr(local_23:bv64, zero_extend(52, 0x3f:bv12)),
            bvshl(local_23:bv64, zero_extend(48, 0x1:bv16))),
           0xffffffffffffffff:bv64)), 0x1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007b0:bv64);
       goto (%block_22);
     ];
     block %block_22 { .asm = "add x0, x1, x0" } [
       var local_24:bv64 := 0x0:bv64;
       var local_24:bv64 := $R1;
       var local_25:bv64 := 0x0:bv64;
       var local_25:bv64 := $R0;
       $R0:bv64 := bvadd(local_24:bv64,
        bvshl(local_25:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007b4:bv64);
       goto (%Sqrt_code_9);
     ];
     block %Sqrt_code_9 [
       call @_aarch64_eval(0x9341fc00:bv32, 0x4007b4:bv64) { .asm = "asr x0, x0, #1";
           .error = "Failure(\"f_gen_replicate_bits\")" };
       goto (%block_23);
     ];
     block %block_23 { .asm = "str w0, [sp, #0x1c]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) extract(32,0, $R0) 32;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007bc:bv64);
       goto (%block_24);
     ];
     block %block_24 { .asm = "ldr w0, [sp, #0x1c]" } [
       var local_27:bv32 := 0x0:bv32;
       var local_28:bv32 := load le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) 32;
       var local_27:bv32 := local_28:bv32;
       $R0:bv64 := zero_extend(32, zero_extend(0, local_27:bv32));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007c0:bv64);
       goto (%block_25);
     ];
     block %block_25 { .asm = "mul w0, w0, w0" } [
       var local_29:bv32 := 0x0:bv32;
       var local_29:bv32 := extract(32,0, $R0);
       var local_30:bv32 := 0x0:bv32;
       var local_30:bv32 := extract(32,0, $R0);
       var local_31:bv32 := 0x0:bv32;
       var local_31:bv32 := 0x0:bv32;
       $R0:bv64 := zero_extend(32,
       bvadd(local_31:bv32,
        extract(32,0, bvmul(extract(32,0, local_29:bv32),
         extract(32,0, local_30:bv32)))));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007c4:bv64);
       goto (%Sqrt_code_10);
     ];
     block %Sqrt_code_10 [
       call @_aarch64_eval(0x93407c00:bv32, 0x4007c4:bv64) { .asm = "sxtw x0, w0";
           .error = "Failure(\"f_gen_replicate_bits\")" };
       goto (%block_26);
     ];
     block %block_26 { .asm = "ldr x1, [sp, #8]" } [
       var local_33:bv64 := 0x0:bv64;
       var local_34:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_33:bv64 := local_34:bv64;
       $R1:bv64 := zero_extend(0, zero_extend(0, local_33:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007cc:bv64);
       goto (%block_27);
     ];
     block %block_27 { .asm = "cmp x1, x0" } [
       var local_35:bv64 := 0x0:bv64;
       var local_36:bv64 := 0x0:bv64;
       $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, $R1),
            sign_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, $R1),
            zero_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R1,
           bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64));
       $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R1,
         bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007d0:bv64);
       goto (%block_28);
     ];
     block %block_28 { .asm = "b.lt #0x10" } [ goto (%block_30,%block_29); ];
     block %block_29 [
       assume boolnot(eq($PSTATE_N, $PSTATE_V));
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4007e0:bv64;
       goto (%block_31);
     ];
     block %block_30 [
       assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007d4:bv64);
       goto (%block_31);
     ];
     block %block_31 [
       $PC:bv64 := if boolnot(eq($PSTATE_N, $PSTATE_V)) then 0x4007e0:bv64 else 0x4007d4:bv64;
       goto (%Sqrt_code_11);
     ];
     block %Sqrt_code_11 [
       assert boolor(eq(0x4007d4:bv64, $PC), eq(0x4007e0:bv64, $PC));
       goto (%Sqrt_code_2,%Sqrt_code);
     ];
     block %Sqrt_code { .address = 4196320; .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
         .succ = [ { .address = 4196328; .conditional = "false"; .direct = "true";
                 .target = "internal:32fWxY7+R++JNJOFTmT+Sg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x4007e0:bv64, $PC);
       goto (%block_32);
     ];
     block %block_32 { .asm = "ldrsw x0, [sp, #0x1c]" } [
       var local_37:bv32 := 0x0:bv32;
       var local_38:bv32 := load le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) 32;
       var local_37:bv32 := local_38:bv32;
       $R0:bv64 := zero_extend(0, sign_extend(32, local_37:bv32));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007e4:bv64);
       goto (%block_33);
     ];
     block %block_33 { .asm = "str x0, [sp, #0x20]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x20:bv64) $R0 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007e8:bv64);
       goto (%Sqrt_code_12);
     ];
     block %Sqrt_code_12 [
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%Sqrt_code_5);
     ];
     block %Sqrt_code_2 { .address = 4196308;
         .gtirb_block = "ZLfuz7OtTNOS9GLtqSI1gg";
         .succ = [ { .address = 4196328; .conditional = "false"; .direct = "true";
                 .target = "internal:32fWxY7+R++JNJOFTmT+Sg"; .type = "Type_Branch" } ] } [
       assume eq(0x4007d4:bv64, $PC);
       goto (%block_34);
     ];
     block %block_34 { .asm = "ldrsw x0, [sp, #0x1c]" } [
       var local_39:bv32 := 0x0:bv32;
       var local_40:bv32 := load le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) 32;
       var local_39:bv32 := local_40:bv32;
       $R0:bv64 := zero_extend(0, sign_extend(32, local_39:bv32));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007d8:bv64);
       goto (%block_35);
     ];
     block %block_35 { .asm = "str x0, [sp, #0x28]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x28:bv64) $R0 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4007dc:bv64);
       goto (%block_36);
     ];
     block %block_36 { .asm = "b #0xc" } [
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4007e8:bv64;
       goto (%Sqrt_code_13);
     ];
     block %Sqrt_code_13 [
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%Sqrt_code_5);
     ]
  ];
  proc @_start()  -> () {  }
    modifies $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R2:bv64, $R29:bv64,
      $R3:bv64, $R30:bv64, $R4:bv64, $R5:bv64, $R6:bv64
    captures $PC:bv64, $R0:bv64, $R1:bv64, $R16:bv64, $R17:bv64, $R2:bv64, $R29:bv64,
      $R3:bv64, $R30:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400680:bv64, $PC))
  
  [
     block %_start_code_2 { .address = 4195968;
         .gtirb_block = "xdHqi8HzTJ+zBYVemlzAtg";
         .succ = [ { .address = 4195904; .conditional = "false"; .direct = "true";
                 .target = "stmts:YmNxI7RsS/6TZy3HTKzvWg"; .type = "Type_Call" } ] } [
       assume eq(0x400680:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32, 0x400680:bv64) { .asm = "nop ";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %block { .asm = "mov x29, #0" } [
       $R29:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400688:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "mov x30, #0" } [
       $R30:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x40068c:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "mov x5, x0" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := $R0;
       $R5:bv64 := bvor(local:bv64, bvshl(local_1:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400690:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "ldr x1, [sp]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x0:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       $R1:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400694:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "add x2, sp, #8" } [
       var local_4:bv64 := 0x0:bv64;
       $R2:bv64 := bvadd($SP, 0x8:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400698:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "mov x6, sp" } [
       var local_5:bv64 := 0x0:bv64;
       $R6:bv64 := bvadd($SP, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40069c:bv64);
       goto (%block_6);
     ];
     block %block_6 { .asm = "adrp x0, #0" } [
       $R0:bv64 := 0x400000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006a0:bv64);
       goto (%block_7);
     ];
     block %block_7 { .asm = "add x0, x0, #0x6b4" } [
       var local_6:bv64 := 0x0:bv64;
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := $R0;
       $R0:bv64 := bvadd(local_7:bv64, 0x6b4:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006a4:bv64);
       goto (%block_8);
     ];
     block %block_8 { .asm = "mov x3, #0" } [
       $R3:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006a8:bv64);
       goto (%block_9);
     ];
     block %block_9 { .asm = "mov x4, #0" } [
       $R4:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006ac:bv64);
       goto (%block_10);
     ];
     block %block_10 { .asm = "bl #0xffffffffffffff94" } [
       $R30:bv64 := 0x4006b0:bv64;
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400640:bv64;
       goto (%_start_code_3);
     ];
     block %_start_code_3 [
       assert boolor(eq(0x400640:bv64, $PC));
       goto (%_start_ext);
     ];
     block %_start_ext [
       assume eq(0x400640:bv64, $PC);
       call @FUN_400640();
       assert boolor(eq(0x4006b0:bv64, $PC));
       goto (%_start_code_1);
     ];
     block %_start_code_1 { .address = 4196016;
         .gtirb_block = "t/6C+3O4SbalxMsQ9Vg3LA";
         .succ = [ { .address = 4195936; .conditional = "false"; .direct = "true";
                 .target = "stmts:iedVtPHmSjuLgqSxHgXOuw"; .type = "Type_Call" } ] } [
       assume eq(0x4006b0:bv64, $PC);
       goto (%block_11);
     ];
     block %block_11 { .asm = "bl #0xffffffffffffffb0" } [
       $R30:bv64 := 0x4006b4:bv64;
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400660:bv64;
       goto (%_start_code_4);
     ];
     block %_start_code_4 [
       assert boolor(eq(0x400660:bv64, $PC));
       goto (%_start_ext_2);
     ];
     block %_start_ext_2 [
       assume eq(0x400660:bv64, $PC);
       call @FUN_400660();
       assert boolor();
       unreachable;
     ]
  ];
  proc @_dl_relocate_static_pie()  -> () {  }
    modifies $PC:bv64
    captures $PC:bv64, $R30:bv64
    requires boolor(eq(0x4006c0:bv64, $PC))
  
  [
     block %_dl_relocate_static_pie_code { .address = 4196032;
         .gtirb_block = "KTHyjTW0SWiGwqylcMDw6Q";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x4006c0:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "ret " } [
       var local:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%_dl_relocate_static_pie_code_1);
     ];
     block %_dl_relocate_static_pie_code_1 [ assert boolor(); goto (%ret); ];
     block %ret [ return; ]
  ];
  proc @call_weak_fn()  -> () {  }
    modifies $PC:bv64, $R0:bv64, $R16:bv64, $R17:bv64
    captures $PC:bv64, $R0:bv64, $R16:bv64, $R17:bv64, $R30:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x4006c4:bv64, $PC))
  
  [
     block %call_weak_fn_code { .address = 4196036;
         .gtirb_block = "Djx7L34DQzuSXaBFEj/bpQ";
         .succ = [ { .address = 4196052; .conditional = "true"; .direct = "true";
                 .target = "internal:yQ1z8A+IRoSs4MRYTbbghg"; .type = "Type_Branch" };
             { .address = 4196048; .conditional = "true"; .direct = "true";
                 .target = "internal:fxMAJl44TWOTA8IHVD8V7Q";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x4006c4:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x0, #0x1f000" } [
       $R0:bv64 := 0x41f000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006c8:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "ldr x0, [x0, #0xfd8]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $R0;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0xfd8:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       $R0:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006cc:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "cbz x0, #8" } [ goto (%block_4,%block_3); ];
     block %block_3 [
       assume eq($R0, 0x0:bv64);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x4006d4:bv64;
       goto (%block_5);
     ];
     block %block_4 [
       assume boolnot(eq($R0, 0x0:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006d0:bv64);
       goto (%block_5);
     ];
     block %block_5 [
       $PC:bv64 := if eq($R0, 0x0:bv64) then 0x4006d4:bv64 else 0x4006d0:bv64;
       goto (%call_weak_fn_code_3);
     ];
     block %call_weak_fn_code_3 [
       assert boolor(eq(0x4006d4:bv64, $PC), eq(0x4006d0:bv64, $PC));
       goto (%call_weak_fn_code_2,%call_weak_fn_code_1);
     ];
     block %call_weak_fn_code_1 { .address = 4196048;
         .gtirb_block = "fxMAJl44TWOTA8IHVD8V7Q";
         .succ = [ { .address = 4195920; .conditional = "false"; .direct = "true";
                 .target = "stmts:i2bc6yURTw+Pq2nxe63pQA"; .type = "Type_Branch" } ] } [
       assume eq(0x4006d0:bv64, $PC);
       goto (%block_6);
     ];
     block %block_6 { .asm = "b #0xffffffffffffff80" } [
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400650:bv64;
       goto (%call_weak_fn_code_4);
     ];
     block %call_weak_fn_code_4 [
       assert boolor(eq(0x400650:bv64, $PC));
       goto (%call_weak_fn_ext_1);
     ];
     block %call_weak_fn_ext_1 [
       assume eq(0x400650:bv64, $PC);
       call @.L_400650();
       assert boolor();
       unreachable;
     ];
     block %call_weak_fn_code_2 { .address = 4196052;
         .gtirb_block = "yQ1z8A+IRoSs4MRYTbbghg";
         .succ = [ { .address = 4195856; .conditional = "false"; .direct = "true";
                 .target = "external:xdU61Ad4R3aE/hVJ17n5eQ"; .type = "Type_Return" } ] } [
       assume eq(0x4006d4:bv64, $PC);
       goto (%block_7);
     ];
     block %block_7 { .asm = "ret " } [
       var local_3:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%call_weak_fn_code_5);
     ];
     block %call_weak_fn_code_5 [
       assert boolor(eq(0x400610:bv64, $PC));
       goto (%ret_3);
     ];
     block %ret_3 [ return; ]
  ];
  proc @main()  -> () {  }
    modifies $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R29:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    captures $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R29:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400808:bv64, $PC))
  
  [
     block %main_code { .address = 4196360; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
         .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                 .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
       assume eq(0x400808:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
        0xffffffffffffffe0:bv64) $R29 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
         0xffffffffffffffe0:bv64), 0x8:bv64) $R30 64;
       $SP:bv64 := bvadd(local:bv64, 0xffffffffffffffe0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40080c:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       $R29:bv64 := bvadd($SP, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400810:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "str w0, [sp, #0x1c]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) extract(32,0, $R0) 32;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400814:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "str x1, [sp, #0x10]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP, 0x10:bv64) $R1 64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400818:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "ldrsw x0, [sp, #0x1c]" } [
       var local_2:bv32 := 0x0:bv32;
       var local_3:bv32 := load le $mem:(bv64->bv8) bvadd($SP, 0x1c:bv64) 32;
       var local_2:bv32 := local_3:bv32;
       $R0:bv64 := zero_extend(0, sign_extend(32, local_2:bv32));
       (var BranchTaken:bool := false, $PC:bv64 := 0x40081c:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "bl #0xffffffffffffff68" } [
       $R30:bv64 := 0x400820:bv64;
       var BranchTaken:bool := true;
       $PC:bv64 := 0x400784:bv64;
       goto (%main_code_2);
     ];
     block %main_code_2 [
       assert boolor(eq(0x400784:bv64, $PC));
       goto (%main_ext);
     ];
     block %main_ext [
       assume eq(0x400784:bv64, $PC);
       call @Sqrt();
       assert boolor(eq(0x400820:bv64, $PC));
       goto (%main_code_1);
     ];
     block %main_code_1 { .address = 4196384;
         .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400820:bv64, $PC);
       goto (%block_6);
     ];
     block %block_6 { .asm = "ldp x29, x30, [sp], #0x20" } [
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $SP;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) $SP 64;
       var local_5:bv64 := local_6:bv64;
       var local_7:bv64 := 0x0:bv64;
       var local_8:bv64 := load le $mem:(bv64->bv8) bvadd($SP, 0x8:bv64) 64;
       var local_7:bv64 := local_8:bv64;
       $R29:bv64 := local_5:bv64;
       $R30:bv64 := local_7:bv64;
       $SP:bv64 := bvadd(local_4:bv64, 0x20:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400824:bv64);
       goto (%block_7);
     ];
     block %block_7 { .asm = "ret " } [
       var local_9:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%main_code_3);
     ];
     block %main_code_3 [ assert boolor(); goto (%ret_1); ];
     block %ret_1 [ return; ]
  ];
  proc @.L_400650()  -> () {  }
    modifies $PC:bv64, $R16:bv64, $R17:bv64
    captures $PC:bv64, $R16:bv64, $R17:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400650:bv64, $PC))
  
  [
     block %L_400650_code { .address = 4195920;
         .gtirb_block = "i2bc6yURTw+Pq2nxe63pQA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:QQLF2yhHRgKOi0ouqIEdXw"; .type = "Type_Branch" } ] } [
       assume eq(0x400650:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       $R16:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400654:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #8]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $R16;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x8:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       $R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400658:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "add x16, x16, #8" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $R16;
       $R16:bv64 := bvadd(local_4:bv64, 0x8:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40065c:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R17;
       goto (%L_400650_code_1);
     ];
     block %L_400650_code_1 [ assert boolor(); unreachable; ]
  ];
  proc @FUN_400640()  -> () {  }
    modifies $PC:bv64, $R16:bv64, $R17:bv64
    captures $PC:bv64, $R16:bv64, $R17:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400640:bv64, $PC))
  
  [
     block %FUN_400640_code { .address = 4195904;
         .gtirb_block = "YmNxI7RsS/6TZy3HTKzvWg";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:3AqniX2CT+OA1g1jJcUzbQ"; .type = "Type_Branch" } ] } [
       assume eq(0x400640:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       $R16:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400644:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "ldr x17, [x16]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $R16;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x0:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       $R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400648:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "add x16, x16, #0" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := $R16;
       $R16:bv64 := bvadd(local_4:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x40064c:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R17;
       goto (%FUN_400640_code_1);
     ];
     block %FUN_400640_code_1 [ assert boolor(); unreachable; ]
  ];
  proc @deregister_tm_clones()  -> () {  }
    modifies $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R16:bv64
    captures $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1,
      $R0:bv64, $R1:bv64, $R16:bv64, $R30:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x4006e0:bv64, $PC))
  
  [
     block %deregister_tm_clones_code { .address = 4196064;
         .gtirb_block = "GW0MHC+ORUKlCdpgOcZ6zA";
         .succ = [ { .address = 4196108; .conditional = "true"; .direct = "true";
                 .target = "internal:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Branch" };
             { .address = 4196088; .conditional = "true"; .direct = "true";
                 .target = "internal:GghTYm6bT12tNFmqu0nIjA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x4006e0:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "adrp x0, #0x20000" } [
       $R0:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006e4:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "add x0, x0, #0x28" } [
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := $R0;
       $R0:bv64 := bvadd(local_1:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006e8:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "adrp x1, #0x20000" } [
       $R1:bv64 := 0x420000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006ec:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "add x1, x1, #0x28" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_3:bv64 := $R1;
       $R1:bv64 := bvadd(local_3:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006f0:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "cmp x1, x0" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, $R1),
            sign_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd($R1, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, $R1),
            zero_extend(64, bvnot(bvshl($R0, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R1,
           bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64));
       $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R1,
         bvnot(bvshl($R0, zero_extend(52, 0x0:bv12)))), 0x1:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006f4:bv64);
       goto (%block_5);
     ];
     block %block_5 { .asm = "b.eq #0x18" } [ goto (%block_7,%block_6); ];
     block %block_6 [
       assume eq($PSTATE_Z, 0x1:bv1);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x40070c:bv64;
       goto (%block_8);
     ];
     block %block_7 [
       assume boolnot(eq($PSTATE_Z, 0x1:bv1));
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006f8:bv64);
       goto (%block_8);
     ];
     block %block_8 [
       $PC:bv64 := if eq($PSTATE_Z, 0x1:bv1) then 0x40070c:bv64 else 0x4006f8:bv64;
       goto (%deregister_tm_clones_code_4);
     ];
     block %deregister_tm_clones_code_4 [
       assert boolor(eq(0x40070c:bv64, $PC), eq(0x4006f8:bv64, $PC));
       goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code_1);
     ];
     block %deregister_tm_clones_code_1 { .address = 4196088;
         .gtirb_block = "GghTYm6bT12tNFmqu0nIjA";
         .succ = [ { .address = 4196108; .conditional = "true"; .direct = "true";
                 .target = "internal:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Branch" };
             { .address = 4196100; .conditional = "true"; .direct = "true";
                 .target = "internal:NfWWPq4PTwyv0VapVhBGag";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x4006f8:bv64, $PC);
       goto (%block_9);
     ];
     block %block_9 { .asm = "adrp x1, #0x1f000" } [
       $R1:bv64 := 0x41f000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x4006fc:bv64);
       goto (%block_10);
     ];
     block %block_10 { .asm = "ldr x1, [x1, #0xfd0]" } [
       var local_6:bv64 := 0x0:bv64;
       var local_6:bv64 := $R1;
       var local_7:bv64 := 0x0:bv64;
       var local_8:bv64 := load le $mem:(bv64->bv8) bvadd(local_6:bv64, 0xfd0:bv64) 64;
       var local_7:bv64 := local_8:bv64;
       $R1:bv64 := zero_extend(0, zero_extend(0, local_7:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400700:bv64);
       goto (%block_11);
     ];
     block %block_11 { .asm = "cbz x1, #0xc" } [ goto (%block_13,%block_12); ];
     block %block_12 [
       assume eq($R1, 0x0:bv64);
       var BranchTaken:bool := true;
       $PC:bv64 := 0x40070c:bv64;
       goto (%block_14);
     ];
     block %block_13 [
       assume boolnot(eq($R1, 0x0:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400704:bv64);
       goto (%block_14);
     ];
     block %block_14 [
       $PC:bv64 := if eq($R1, 0x0:bv64) then 0x40070c:bv64 else 0x400704:bv64;
       goto (%deregister_tm_clones_code_5);
     ];
     block %deregister_tm_clones_code_5 [
       assert boolor(eq(0x40070c:bv64, $PC), eq(0x400704:bv64, $PC));
       goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code_2);
     ];
     block %deregister_tm_clones_code_2 { .address = 4196100;
         .gtirb_block = "NfWWPq4PTwyv0VapVhBGag";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400704:bv64, $PC);
       goto (%block_15);
     ];
     block %block_15 { .asm = "mov x16, x1" } [
       var local_9:bv64 := 0x0:bv64;
       var local_9:bv64 := 0x0:bv64;
       var local_10:bv64 := 0x0:bv64;
       var local_10:bv64 := $R1;
       $R16:bv64 := bvor(local_9:bv64,
        bvshl(local_10:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, $PC:bv64 := 0x400708:bv64);
       goto (%block_16);
     ];
     block %block_16 { .asm = "br x16" } [
       var local_11:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R16;
       goto (%deregister_tm_clones_code_6);
     ];
     block %deregister_tm_clones_code_6 [ assert boolor(); unreachable; ];
     block %deregister_tm_clones_code_3 { .address = 4196108;
         .gtirb_block = "cdQ2GS2+QhaOa7OUvPWMRQ";
         .succ = [ { .address = 4196200; .conditional = "false"; .direct = "true";
                 .target = "external:TxTRm4kpQiq/Xgistx+xbQ"; .type = "Type_Return" } ] } [
       assume eq(0x40070c:bv64, $PC);
       goto (%block_17);
     ];
     block %block_17 { .asm = "ret " } [
       var local_12:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R30;
       goto (%deregister_tm_clones_code_7);
     ];
     block %deregister_tm_clones_code_7 [
       assert boolor(eq(0x400768:bv64, $PC));
       goto (%ret_5);
     ];
     block %ret_5 [ return; ]
  ];
  proc @FUN_400620()  -> () {  }
    modifies $PC:bv64, $R16:bv64, $R17:bv64, $SP:bv64, $mem:(bv64->bv8)
    captures $PC:bv64, $R16:bv64, $R17:bv64, $R30:bv64, $SP:bv64, $mem:(bv64->bv8)
    requires boolor(eq(0x400620:bv64, $PC))
  
  [
     block %FUN_400620_code { .address = 4195872;
         .gtirb_block = "wtDzxxOjSJeWxzGBUpQYxA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400620:bv64, $PC);
       goto (%block);
     ];
     block %block { .asm = "stp x16, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := $SP;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd($SP,
        0xfffffffffffffff0:bv64) $R16 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd($SP,
         0xfffffffffffffff0:bv64), 0x8:bv64) $R30 64;
       $SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400624:bv64);
       goto (%block_1);
     ];
     block %block_1 { .asm = "adrp x16, #0x1f000" } [
       $R16:bv64 := 0x41f000:bv64;
       (var BranchTaken:bool := false, $PC:bv64 := 0x400628:bv64);
       goto (%block_2);
     ];
     block %block_2 { .asm = "ldr x17, [x16, #0xff8]" } [
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := $R16;
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd(local_1:bv64, 0xff8:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       $R17:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, $PC:bv64 := 0x40062c:bv64);
       goto (%block_3);
     ];
     block %block_3 { .asm = "add x16, x16, #0xff8" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_5:bv64 := $R16;
       $R16:bv64 := bvadd(local_5:bv64, 0xff8:bv64);
       (var BranchTaken:bool := false, $PC:bv64 := 0x400630:bv64);
       goto (%block_4);
     ];
     block %block_4 { .asm = "br x17" } [
       var local_6:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       $PC:bv64 := $R17;
       goto (%FUN_400620_code_1);
     ];
     block %FUN_400620_code_1 [ assert boolor(); unreachable; ]
  ];
  prog entry @_start;
