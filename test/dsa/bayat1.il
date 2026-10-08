var $PC:bv64;
proc @frame_dummy()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x860:bv64, $PC))

[
   block %frame_dummy_code { .address = 2144;
       .gtirb_block = "lr6o4ptnRiK3TGR1gpiWGg";
       .succ = [ { .address = 2000; .conditional = "false"; .direct = "true";
               .target = "stmts:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Branch" } ] } [
     assume eq(0x860:bv64, $PC);
     call @_aarch64_eval(0x17ffffdc:bv32, 0x860:bv64) { .asm = "b #0xffffffffffffff70" };
     assert boolor(eq(0x7d0:bv64, $PC));
     goto (%frame_dummy_ext);
   ];
   block %frame_dummy_ext [
     assume eq(0x7d0:bv64, $PC);
     call @register_tm_clones();
     assert false;
     unreachable;
   ]
];
proc @_init()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x698:bv64, $PC))

[
   block %_init_code_1 { .address = 1688; .gtirb_block = "xdHqi8HzTJ+zBYVemlzAtg";
       .succ = [ { .address = 1908; .conditional = "false"; .direct = "true";
               .target = "stmts:GghTYm6bT12tNFmqu0nIjA"; .type = "Type_Call" } ] } [
     assume eq(0x698:bv64, $PC);
     call @_aarch64_eval(0xd503233f:bv32, 0x698:bv64) { .asm = "paciasp " };
     call @_aarch64_eval(0xa9bf7bfd:bv32, 0x69c:bv64) { .asm = "stp x29, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x6a0:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0x94000034:bv32, 0x6a4:bv64) { .asm = "bl #0xd0" };
     assert boolor(eq(0x774:bv64, $PC));
     goto (%_init_ext);
   ];
   block %_init_ext [
     assume eq(0x774:bv64, $PC);
     call @call_weak_fn();
     assert boolor(eq(0x6a8:bv64, $PC));
     goto (%_init_code);
   ];
   block %_init_code { .address = 1704; .gtirb_block = "t/6C+3O4SbalxMsQ9Vg3LA";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
     assume eq(0x6a8:bv64, $PC);
     call @_aarch64_eval(0xa8c17bfd:bv32, 0x6a8:bv64) { .asm = "ldp x29, x30, [sp], #0x10" };
     call @_aarch64_eval(0xd50323bf:bv32, 0x6ac:bv64) { .asm = "autiasp " };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x6b0:bv64) { .asm = "ret " };
     assert false;
     goto (%ret);
   ];
   block %ret [ return; ]
];
proc @_fini()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x8e8:bv64, $PC))

[
   block %_fini_code { .address = 2280; .gtirb_block = "Y/R8k4zNQOW7WdsmX6n3Vw";
       .succ = [ { .address = 2292; .conditional = "false"; .direct = "true";
               .target = "internal:lFxxVCVARIKoZ6fzUj5YPw";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x8e8:bv64, $PC);
     call @_aarch64_eval(0xd503233f:bv32, 0x8e8:bv64) { .asm = "paciasp " };
     call @_aarch64_eval(0xa9bf7bfd:bv32, 0x8ec:bv64) { .asm = "stp x29, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x8f0:bv64) { .asm = "mov x29, sp" };
     assert boolor(eq(0x8f4:bv64, $PC));
     goto (%_fini_code_1);
   ];
   block %_fini_code_1 { .address = 2292; .gtirb_block = "lFxxVCVARIKoZ6fzUj5YPw";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
     assume eq(0x8f4:bv64, $PC);
     call @_aarch64_eval(0xa8c17bfd:bv32, 0x8f4:bv64) { .asm = "ldp x29, x30, [sp], #0x10" };
     call @_aarch64_eval(0xd50323bf:bv32, 0x8f8:bv64) { .asm = "autiasp " };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x8fc:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_1);
   ];
   block %ret_1 [ return; ]
];
proc @main()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x864:bv64, $PC))

[
   block %main_code { .address = 2148; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
       .succ = [ { .address = 2172; .conditional = "true"; .direct = "true";
               .target = "internal:rlVqjjqoR6uHwOYvPCS15g";
               .type = "Type_Fallthrough" };
           { .address = 2212; .conditional = "true"; .direct = "true";
               .target = "internal:gFBdrsFTRkSCdIsDFMk6qA"; .type = "Type_Branch" } ] } [
     assume eq(0x864:bv64, $PC);
     call @_aarch64_eval(0xa9bd7bfd:bv32, 0x864:bv64) { .asm = "stp x29, x30, [sp, #-0x30]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x868:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xb9001fe0:bv32, 0x86c:bv64) { .asm = "str w0, [sp, #0x1c]" };
     call @_aarch64_eval(0xb9401fe0:bv32, 0x870:bv64) { .asm = "ldr w0, [sp, #0x1c]" };
     call @_aarch64_eval(0x7100001f:bv32, 0x874:bv64) { .asm = "cmp w0, #0" };
     call @_aarch64_eval(0x54000160:bv32, 0x878:bv64) { .asm = "b.eq #0x2c" };
     assert boolor(eq(0x87c:bv64, $PC), eq(0x8a4:bv64, $PC));
     goto (%main_code_2,%main_code_1);
   ];
   block %main_code_1 { .address = 2212; .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
       .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
               .target = "internal:wK9NYU4TTr+D8gXPiCk+7w";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x8a4:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x8a4:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91010000:bv32, 0x8a8:bv64) { .asm = "add x0, x0, #0x40" };
     call @_aarch64_eval(0x9100a3e1:bv32, 0x8ac:bv64) { .asm = "add x1, sp, #0x28" };
     call @_aarch64_eval(0xf9000001:bv32, 0x8b0:bv64) { .asm = "str x1, [x0]" };
     call @_aarch64_eval(0x90000100:bv32, 0x8b4:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91012000:bv32, 0x8b8:bv64) { .asm = "add x0, x0, #0x48" };
     call @_aarch64_eval(0x90000101:bv32, 0x8bc:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x91010021:bv32, 0x8c0:bv64) { .asm = "add x1, x1, #0x40" };
     call @_aarch64_eval(0xf9000001:bv32, 0x8c4:bv64) { .asm = "str x1, [x0]" };
     assert boolor(eq(0x8c8:bv64, $PC));
     goto (%main_code_3);
   ];
   block %main_code_2 { .address = 2172; .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
       .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
               .target = "internal:wK9NYU4TTr+D8gXPiCk+7w"; .type = "Type_Branch" } ] } [
     assume eq(0x87c:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x87c:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x9100e000:bv32, 0x880:bv64) { .asm = "add x0, x0, #0x38" };
     call @_aarch64_eval(0x9100b3e1:bv32, 0x884:bv64) { .asm = "add x1, sp, #0x2c" };
     call @_aarch64_eval(0xf9000001:bv32, 0x888:bv64) { .asm = "str x1, [x0]" };
     call @_aarch64_eval(0x90000100:bv32, 0x88c:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91012000:bv32, 0x890:bv64) { .asm = "add x0, x0, #0x48" };
     call @_aarch64_eval(0x90000101:bv32, 0x894:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x9100e021:bv32, 0x898:bv64) { .asm = "add x1, x1, #0x38" };
     call @_aarch64_eval(0xf9000001:bv32, 0x89c:bv64) { .asm = "str x1, [x0]" };
     call @_aarch64_eval(0x1400000a:bv32, 0x8a0:bv64) { .asm = "b #0x28" };
     assert boolor(eq(0x8c8:bv64, $PC));
     goto (%main_code_3);
   ];
   block %main_code_3 { .address = 2248; .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
     assume eq(0x8c8:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x8c8:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91014000:bv32, 0x8cc:bv64) { .asm = "add x0, x0, #0x50" };
     call @_aarch64_eval(0x90000101:bv32, 0x8d0:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x91016021:bv32, 0x8d4:bv64) { .asm = "add x1, x1, #0x58" };
     call @_aarch64_eval(0xf9000001:bv32, 0x8d8:bv64) { .asm = "str x1, [x0]" };
     call @_aarch64_eval(0x52800000:bv32, 0x8dc:bv64) { .asm = "mov w0, #0" };
     call @_aarch64_eval(0xa8c37bfd:bv32, 0x8e0:bv64) { .asm = "ldp x29, x30, [sp], #0x30" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x8e4:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_4);
   ];
   block %ret_4 [ return; ]
];
proc @deregister_tm_clones()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x7a0:bv64, $PC))

[
   block %deregister_tm_clones_code_2 { .address = 1952;
       .gtirb_block = "rIlbG4jGSTydaFqMhxCKWw";
       .succ = [ { .address = 1976; .conditional = "true"; .direct = "true";
               .target = "internal:tXIOhSQ+R1WA/9VL5+6KQQ";
               .type = "Type_Fallthrough" };
           { .address = 1996; .conditional = "true"; .direct = "true";
               .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
     assume eq(0x7a0:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x7a0:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x9100c000:bv32, 0x7a4:bv64) { .asm = "add x0, x0, #0x30" };
     call @_aarch64_eval(0x90000101:bv32, 0x7a8:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x9100c021:bv32, 0x7ac:bv64) { .asm = "add x1, x1, #0x30" };
     call @_aarch64_eval(0xeb00003f:bv32, 0x7b0:bv64) { .asm = "cmp x1, x0" };
     call @_aarch64_eval(0x540000c0:bv32, 0x7b4:bv64) { .asm = "b.eq #0x18" };
     assert boolor(eq(0x7b8:bv64, $PC), eq(0x7cc:bv64, $PC));
     goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code);
   ];
   block %deregister_tm_clones_code { .address = 1996;
       .gtirb_block = "IkNYmV06TxC75h8A4NM3wA";
       .succ = [ { .address = 2112; .conditional = "false"; .direct = "true";
               .target = "external:ZLfuz7OtTNOS9GLtqSI1gg"; .type = "Type_Return" } ] } [
     assume eq(0x7cc:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x7cc:bv64) { .asm = "ret " };
     assert boolor(eq(0x840:bv64, $PC));
     goto (%ret);
   ];
   block %ret [ return; ];
   block %deregister_tm_clones_code_3 { .address = 1976;
       .gtirb_block = "tXIOhSQ+R1WA/9VL5+6KQQ";
       .succ = [ { .address = 1988; .conditional = "true"; .direct = "true";
               .target = "internal:oqiqdATZTc6MDOYJqL9Aew";
               .type = "Type_Fallthrough" };
           { .address = 1996; .conditional = "true"; .direct = "true";
               .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
     assume eq(0x7b8:bv64, $PC);
     call @_aarch64_eval(0xf00000e1:bv32, 0x7b8:bv64) { .asm = "adrp x1, #0x1f000" };
     call @_aarch64_eval(0xf947e021:bv32, 0x7bc:bv64) { .asm = "ldr x1, [x1, #0xfc0]" };
     call @_aarch64_eval(0xb4000061:bv32, 0x7c0:bv64) { .asm = "cbz x1, #0xc" };
     assert boolor(eq(0x7c4:bv64, $PC), eq(0x7cc:bv64, $PC));
     goto (%deregister_tm_clones_code_1,%deregister_tm_clones_code);
   ];
   block %deregister_tm_clones_code_1 { .address = 1988;
       .gtirb_block = "oqiqdATZTc6MDOYJqL9Aew";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Branch" } ] } [
     assume eq(0x7c4:bv64, $PC);
     call @_aarch64_eval(0xaa0103f0:bv32, 0x7c4:bv64) { .asm = "mov x16, x1" };
     call @_aarch64_eval(0xd61f0200:bv32, 0x7c8:bv64) { .asm = "br x16" };
     assert false;
     unreachable;
   ]
];
proc @FUN_710()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x710:bv64, $PC))

[
   block %FUN_710_code { .address = 1808; .gtirb_block = "fxMAJl44TWOTA8IHVD8V7Q";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:9HpGYN0mTFGqHtyUmtOrDA"; .type = "Type_Branch" } ] } [
     assume eq(0x710:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x710:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400e11:bv32, 0x714:bv64) { .asm = "ldr x17, [x16, #0x18]" };
     call @_aarch64_eval(0x91006210:bv32, 0x718:bv64) { .asm = "add x16, x16, #0x18" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x71c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @.L_700()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x700:bv64, $PC))

[
   block %L_700_code { .address = 1792; .gtirb_block = "Djx7L34DQzuSXaBFEj/bpQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:B71KPRlFTPmSI7vHIcCNkA"; .type = "Type_Branch" } ] } [
     assume eq(0x700:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x700:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400a11:bv32, 0x704:bv64) { .asm = "ldr x17, [x16, #0x10]" };
     call @_aarch64_eval(0x91004210:bv32, 0x708:bv64) { .asm = "add x16, x16, #0x10" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x70c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @_start()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x740:bv64, $PC))

[
   block %_start_code_1 { .address = 1856; .gtirb_block = "yQ1z8A+IRoSs4MRYTbbghg";
       .succ = [ { .address = 1760; .conditional = "false"; .direct = "true";
               .target = "stmts:UtkQk4ONSE6hNEuDpZ95RQ"; .type = "Type_Call" } ] } [
     assume eq(0x740:bv64, $PC);
     call @_aarch64_eval(0xd503245f:bv32, 0x740:bv64) { .asm = "bti c" };
     call @_aarch64_eval(0xd280001d:bv32, 0x744:bv64) { .asm = "mov x29, #0" };
     call @_aarch64_eval(0xd280001e:bv32, 0x748:bv64) { .asm = "mov x30, #0" };
     call @_aarch64_eval(0xaa0003e5:bv32, 0x74c:bv64) { .asm = "mov x5, x0" };
     call @_aarch64_eval(0xf94003e1:bv32, 0x750:bv64) { .asm = "ldr x1, [sp]" };
     call @_aarch64_eval(0x910023e2:bv32, 0x754:bv64) { .asm = "add x2, sp, #8" };
     call @_aarch64_eval(0x910003e6:bv32, 0x758:bv64) { .asm = "mov x6, sp" };
     call @_aarch64_eval(0xf00000e0:bv32, 0x75c:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947ec00:bv32, 0x760:bv64) { .asm = "ldr x0, [x0, #0xfd8]" };
     call @_aarch64_eval(0xd2800003:bv32, 0x764:bv64) { .asm = "mov x3, #0" };
     call @_aarch64_eval(0xd2800004:bv32, 0x768:bv64) { .asm = "mov x4, #0" };
     call @_aarch64_eval(0x97ffffdd:bv32, 0x76c:bv64) { .asm = "bl #0xffffffffffffff74" };
     assert boolor(eq(0x6e0:bv64, $PC));
     goto (%_start_ext);
   ];
   block %_start_ext [
     assume eq(0x6e0:bv64, $PC);
     call @FUN_6e0();
     assert boolor(eq(0x770:bv64, $PC));
     goto (%_start_code);
   ];
   block %_start_code { .address = 1904; .gtirb_block = "GW0MHC+ORUKlCdpgOcZ6zA";
       .succ = [ { .address = 1808; .conditional = "false"; .direct = "true";
               .target = "stmts:fxMAJl44TWOTA8IHVD8V7Q"; .type = "Type_Call" } ] } [
     assume eq(0x770:bv64, $PC);
     call @_aarch64_eval(0x97ffffe8:bv32, 0x770:bv64) { .asm = "bl #0xffffffffffffffa0" };
     assert boolor(eq(0x710:bv64, $PC));
     goto (%_start_ext_1);
   ];
   block %_start_ext_1 [
     assume eq(0x710:bv64, $PC);
     call @FUN_710();
     assert false;
     unreachable;
   ]
];
proc @call_weak_fn()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x774:bv64, $PC))

[
   block %call_weak_fn_code { .address = 1908;
       .gtirb_block = "GghTYm6bT12tNFmqu0nIjA";
       .succ = [ { .address = 1924; .conditional = "true"; .direct = "true";
               .target = "internal:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Branch" };
           { .address = 1920; .conditional = "true"; .direct = "true";
               .target = "internal:NfWWPq4PTwyv0VapVhBGag";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x774:bv64, $PC);
     call @_aarch64_eval(0xf00000e0:bv32, 0x774:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947e800:bv32, 0x778:bv64) { .asm = "ldr x0, [x0, #0xfd0]" };
     call @_aarch64_eval(0xb4000040:bv32, 0x77c:bv64) { .asm = "cbz x0, #8" };
     assert boolor(eq(0x784:bv64, $PC), eq(0x780:bv64, $PC));
     goto (%call_weak_fn_code_2,%call_weak_fn_code_1);
   ];
   block %call_weak_fn_code_1 { .address = 1920;
       .gtirb_block = "NfWWPq4PTwyv0VapVhBGag";
       .succ = [ { .address = 1792; .conditional = "false"; .direct = "true";
               .target = "stmts:Djx7L34DQzuSXaBFEj/bpQ"; .type = "Type_Branch" } ] } [
     assume eq(0x780:bv64, $PC);
     call @_aarch64_eval(0x17ffffe0:bv32, 0x780:bv64) { .asm = "b #0xffffffffffffff80" };
     assert boolor(eq(0x700:bv64, $PC));
     goto (%call_weak_fn_ext_1);
   ];
   block %call_weak_fn_ext_1 [
     assume eq(0x700:bv64, $PC);
     call @.L_700();
     assert false;
     unreachable;
   ];
   block %call_weak_fn_code_2 { .address = 1924;
       .gtirb_block = "cdQ2GS2+QhaOa7OUvPWMRQ";
       .succ = [ { .address = 1704; .conditional = "false"; .direct = "true";
               .target = "external:t/6C+3O4SbalxMsQ9Vg3LA"; .type = "Type_Return" } ] } [
     assume eq(0x784:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x784:bv64) { .asm = "ret " };
     assert boolor(eq(0x6a8:bv64, $PC));
     goto (%ret_3);
   ];
   block %ret_3 [ return; ]
];
proc @FUN_6c0()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x6c0:bv64, $PC))

[
   block %FUN_6c0_code { .address = 1728; .gtirb_block = "8D7O5dmBS1ek+5BDJ9mBtA";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Branch" } ] } [
     assume eq(0x6c0:bv64, $PC);
     call @_aarch64_eval(0xa9bf7bf0:bv32, 0x6c0:bv64) { .asm = "stp x16, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0xf00000f0:bv32, 0x6c4:bv64) { .asm = "adrp x16, #0x1f000" };
     call @_aarch64_eval(0xf947fe11:bv32, 0x6c8:bv64) { .asm = "ldr x17, [x16, #0xff8]" };
     call @_aarch64_eval(0x913fe210:bv32, 0x6cc:bv64) { .asm = "add x16, x16, #0xff8" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x6d0:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @FUN_6e0()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x6e0:bv64, $PC))

[
   block %FUN_6e0_code { .address = 1760; .gtirb_block = "UtkQk4ONSE6hNEuDpZ95RQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:S/peNesMQHWPpC0Q5JGblw"; .type = "Type_Branch" } ] } [
     assume eq(0x6e0:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x6e0:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400211:bv32, 0x6e4:bv64) { .asm = "ldr x17, [x16]" };
     call @_aarch64_eval(0x91000210:bv32, 0x6e8:bv64) { .asm = "add x16, x16, #0" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x6ec:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @FUN_6f0()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x6f0:bv64, $PC))

[
   block %FUN_6f0_code { .address = 1776; .gtirb_block = "KTHyjTW0SWiGwqylcMDw6Q";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy://hBYMVoSN20sEzlJ/DKzA"; .type = "Type_Branch" } ] } [
     assume eq(0x6f0:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x6f0:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400611:bv32, 0x6f4:bv64) { .asm = "ldr x17, [x16, #8]" };
     call @_aarch64_eval(0x91002210:bv32, 0x6f8:bv64) { .asm = "add x16, x16, #8" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x6fc:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @register_tm_clones()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x7d0:bv64, $PC))

[
   block %register_tm_clones_code { .address = 2000;
       .gtirb_block = "D9t2gNJrSmyMH3GAVRe3IQ";
       .succ = [ { .address = 2036; .conditional = "true"; .direct = "true";
               .target = "internal:lwyID0MJQb6vgyjzPFtz8Q";
               .type = "Type_Fallthrough" };
           { .address = 2056; .conditional = "true"; .direct = "true";
               .target = "internal:SFN4dpBgSO2bPUu0fyDluw"; .type = "Type_Branch" } ] } [
     assume eq(0x7d0:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x7d0:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x9100c000:bv32, 0x7d4:bv64) { .asm = "add x0, x0, #0x30" };
     call @_aarch64_eval(0x90000101:bv32, 0x7d8:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x9100c021:bv32, 0x7dc:bv64) { .asm = "add x1, x1, #0x30" };
     call @_aarch64_eval(0xcb000021:bv32, 0x7e0:bv64) { .asm = "sub x1, x1, x0" };
     call @_aarch64_eval(0xd37ffc22:bv32, 0x7e4:bv64) { .asm = "lsr x2, x1, #0x3f" };
     call @_aarch64_eval(0x8b810c41:bv32, 0x7e8:bv64) { .asm = "add x1, x2, x1, asr #3" };
     call @_aarch64_eval(0x9341fc21:bv32, 0x7ec:bv64) { .asm = "asr x1, x1, #1" };
     call @_aarch64_eval(0xb40000c1:bv32, 0x7f0:bv64) { .asm = "cbz x1, #0x18" };
     assert boolor(eq(0x7f4:bv64, $PC), eq(0x808:bv64, $PC));
     goto (%register_tm_clones_code_3,%register_tm_clones_code_1);
   ];
   block %register_tm_clones_code_1 { .address = 2056;
       .gtirb_block = "SFN4dpBgSO2bPUu0fyDluw";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
     assume eq(0x808:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x808:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_2);
   ];
   block %ret_2 [ return; ];
   block %register_tm_clones_code_3 { .address = 2036;
       .gtirb_block = "lwyID0MJQb6vgyjzPFtz8Q";
       .succ = [ { .address = 2048; .conditional = "true"; .direct = "true";
               .target = "internal:TxTRm4kpQiq/Xgistx+xbQ";
               .type = "Type_Fallthrough" };
           { .address = 2056; .conditional = "true"; .direct = "true";
               .target = "internal:SFN4dpBgSO2bPUu0fyDluw"; .type = "Type_Branch" } ] } [
     assume eq(0x7f4:bv64, $PC);
     call @_aarch64_eval(0xf00000e2:bv32, 0x7f4:bv64) { .asm = "adrp x2, #0x1f000" };
     call @_aarch64_eval(0xf947f042:bv32, 0x7f8:bv64) { .asm = "ldr x2, [x2, #0xfe0]" };
     call @_aarch64_eval(0xb4000062:bv32, 0x7fc:bv64) { .asm = "cbz x2, #0xc" };
     assert boolor(eq(0x800:bv64, $PC), eq(0x808:bv64, $PC));
     goto (%register_tm_clones_code_2,%register_tm_clones_code_1);
   ];
   block %register_tm_clones_code_2 { .address = 2048;
       .gtirb_block = "TxTRm4kpQiq/Xgistx+xbQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Branch" } ] } [
     assume eq(0x800:bv64, $PC);
     call @_aarch64_eval(0xaa0203f0:bv32, 0x800:bv64) { .asm = "mov x16, x2" };
     call @_aarch64_eval(0xd61f0200:bv32, 0x804:bv64) { .asm = "br x16" };
     assert false;
     unreachable;
   ]
];
proc @__do_global_dtors_aux()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x80c:bv64, $PC))

[
   block %__do_global_dtors_aux_code_3 { .address = 2060;
       .gtirb_block = "mmpaLvZYQk2b8selWCLriA";
       .succ = [ { .address = 2084; .conditional = "true"; .direct = "true";
               .target = "internal:6JJvkaLhTaWXaEL0+yxKxg";
               .type = "Type_Fallthrough" };
           { .address = 2120; .conditional = "true"; .direct = "true";
               .target = "internal:HVqN0/3+RWiLPKsHRvUqeg"; .type = "Type_Branch" } ] } [
     assume eq(0x80c:bv64, $PC);
     call @_aarch64_eval(0xa9be7bfd:bv32, 0x80c:bv64) { .asm = "stp x29, x30, [sp, #-0x20]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x810:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xf9000bf3:bv32, 0x814:bv64) { .asm = "str x19, [sp, #0x10]" };
     call @_aarch64_eval(0x90000113:bv32, 0x818:bv64) { .asm = "adrp x19, #0x20000" };
     call @_aarch64_eval(0x3940c260:bv32, 0x81c:bv64) { .asm = "ldrb w0, [x19, #0x30]" };
     call @_aarch64_eval(0x37000140:bv32, 0x820:bv64) { .asm = "tbnz w0, #0, #0x28" };
     assert boolor(eq(0x824:bv64, $PC), eq(0x848:bv64, $PC));
     goto (%__do_global_dtors_aux_code_6,%__do_global_dtors_aux_code);
   ];
   block %__do_global_dtors_aux_code { .address = 2120;
       .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
     assume eq(0x848:bv64, $PC);
     call @_aarch64_eval(0xf9400bf3:bv32, 0x848:bv64) { .asm = "ldr x19, [sp, #0x10]" };
     call @_aarch64_eval(0xa8c27bfd:bv32, 0x84c:bv64) { .asm = "ldp x29, x30, [sp], #0x20" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x850:bv64) { .asm = "ret " };
     assert false;
     goto (%ret);
   ];
   block %ret [ return; ];
   block %__do_global_dtors_aux_code_6 { .address = 2084;
       .gtirb_block = "6JJvkaLhTaWXaEL0+yxKxg";
       .succ = [ { .address = 2108; .conditional = "true"; .direct = "true";
               .target = "internal:rCSSdLZcRB2TKAu9h+WCqg"; .type = "Type_Branch" };
           { .address = 2096; .conditional = "true"; .direct = "true";
               .target = "internal:OuTzy8qRTci75taVjGinFQ";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x824:bv64, $PC);
     call @_aarch64_eval(0xf00000e0:bv32, 0x824:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947e400:bv32, 0x828:bv64) { .asm = "ldr x0, [x0, #0xfc8]" };
     call @_aarch64_eval(0xb4000080:bv32, 0x82c:bv64) { .asm = "cbz x0, #0x10" };
     assert boolor(eq(0x83c:bv64, $PC), eq(0x830:bv64, $PC));
     goto (%__do_global_dtors_aux_code_4,%__do_global_dtors_aux_code_1);
   ];
   block %__do_global_dtors_aux_code_1 { .address = 2096;
       .gtirb_block = "OuTzy8qRTci75taVjGinFQ";
       .succ = [ { .address = 1776; .conditional = "false"; .direct = "true";
               .target = "stmts:KTHyjTW0SWiGwqylcMDw6Q"; .type = "Type_Call" } ] } [
     assume eq(0x830:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x830:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0xf9401400:bv32, 0x834:bv64) { .asm = "ldr x0, [x0, #0x28]" };
     call @_aarch64_eval(0x97ffffae:bv32, 0x838:bv64) { .asm = "bl #0xfffffffffffffeb8" };
     assert boolor(eq(0x6f0:bv64, $PC));
     goto (%__do_global_dtors_aux_ext);
   ];
   block %__do_global_dtors_aux_ext [
     assume eq(0x6f0:bv64, $PC);
     call @FUN_6f0();
     assert boolor(eq(0x83c:bv64, $PC));
     goto (%__do_global_dtors_aux_code_4);
   ];
   block %__do_global_dtors_aux_code_4 { .address = 2108;
       .gtirb_block = "rCSSdLZcRB2TKAu9h+WCqg";
       .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
               .target = "stmts:rIlbG4jGSTydaFqMhxCKWw"; .type = "Type_Call" } ] } [
     assume eq(0x83c:bv64, $PC);
     call @_aarch64_eval(0x97ffffd9:bv32, 0x83c:bv64) { .asm = "bl #0xffffffffffffff64" };
     assert boolor(eq(0x7a0:bv64, $PC));
     goto (%__do_global_dtors_aux_ext_1);
   ];
   block %__do_global_dtors_aux_ext_1 [
     assume eq(0x7a0:bv64, $PC);
     call @deregister_tm_clones();
     assert boolor(eq(0x840:bv64, $PC));
     goto (%__do_global_dtors_aux_code_2);
   ];
   block %__do_global_dtors_aux_code_2 { .address = 2112;
       .gtirb_block = "ZLfuz7OtTNOS9GLtqSI1gg";
       .succ = [ { .address = 2120; .conditional = "false"; .direct = "true";
               .target = "internal:HVqN0/3+RWiLPKsHRvUqeg";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x840:bv64, $PC);
     call @_aarch64_eval(0x52800020:bv32, 0x840:bv64) { .asm = "mov w0, #1" };
     call @_aarch64_eval(0x3900c260:bv32, 0x844:bv64) { .asm = "strb w0, [x19, #0x30]" };
     assert boolor(eq(0x848:bv64, $PC));
     goto (%__do_global_dtors_aux_code);
   ]
];
prog entry @_start;