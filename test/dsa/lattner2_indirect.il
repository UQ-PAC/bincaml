var $PC:bv64;
proc @FUN_730()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x730:bv64, $PC))

[
   block %FUN_730_code { .address = 1840; .gtirb_block = "Djx7L34DQzuSXaBFEj/bpQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Branch" } ] } [
     assume eq(0x730:bv64, $PC);
     call @_aarch64_eval(0xa9bf7bf0:bv32, 0x730:bv64) { .asm = "stp x16, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0xf00000f0:bv32, 0x734:bv64) { .asm = "adrp x16, #0x1f000" };
     call @_aarch64_eval(0xf947fe11:bv32, 0x738:bv64) { .asm = "ldr x17, [x16, #0xff8]" };
     call @_aarch64_eval(0x913fe210:bv32, 0x73c:bv64) { .asm = "add x16, x16, #0xff8" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x740:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @FUN_750()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x750:bv64, $PC))

[
   block %FUN_750_code { .address = 1872; .gtirb_block = "fxMAJl44TWOTA8IHVD8V7Q";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:fpiImaZRSWGO0E5MpBbpFQ"; .type = "Type_Branch" } ] } [
     assume eq(0x750:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x750:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400211:bv32, 0x754:bv64) { .asm = "ldr x17, [x16]" };
     call @_aarch64_eval(0x91000210:bv32, 0x758:bv64) { .asm = "add x16, x16, #0" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x75c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @_fini()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x9b4:bv64, $PC))

[
   block %_fini_code_1 { .address = 2484; .gtirb_block = "pao7tNGFTG2/wwL2A6BKrQ";
       .succ = [ { .address = 2496; .conditional = "false"; .direct = "true";
               .target = "internal:QIZPtsaTQjiAsr+paN6ljw";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x9b4:bv64, $PC);
     call @_aarch64_eval(0xd503233f:bv32, 0x9b4:bv64) { .asm = "paciasp " };
     call @_aarch64_eval(0xa9bf7bfd:bv32, 0x9b8:bv64) { .asm = "stp x29, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x9bc:bv64) { .asm = "mov x29, sp" };
     assert boolor(eq(0x9c0:bv64, $PC));
     goto (%_fini_code);
   ];
   block %_fini_code { .address = 2496; .gtirb_block = "QIZPtsaTQjiAsr+paN6ljw";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x9c0:bv64, $PC);
     call @_aarch64_eval(0xa8c17bfd:bv32, 0x9c0:bv64) { .asm = "ldp x29, x30, [sp], #0x10" };
     call @_aarch64_eval(0xd50323bf:bv32, 0x9c4:bv64) { .asm = "autiasp " };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x9c8:bv64) { .asm = "ret " };
     assert false;
     goto (%ret);
   ];
   block %ret [ return; ]
];
proc @deregister_tm_clones()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x820:bv64, $PC))

[
   block %deregister_tm_clones_code_2 { .address = 2080;
       .gtirb_block = "lwyID0MJQb6vgyjzPFtz8Q";
       .succ = [ { .address = 2124; .conditional = "true"; .direct = "true";
               .target = "internal:mmpaLvZYQk2b8selWCLriA"; .type = "Type_Branch" };
           { .address = 2104; .conditional = "true"; .direct = "true";
               .target = "internal:TxTRm4kpQiq/Xgistx+xbQ";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x820:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x820:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91010000:bv32, 0x824:bv64) { .asm = "add x0, x0, #0x40" };
     call @_aarch64_eval(0x90000101:bv32, 0x828:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x91010021:bv32, 0x82c:bv64) { .asm = "add x1, x1, #0x40" };
     call @_aarch64_eval(0xeb00003f:bv32, 0x830:bv64) { .asm = "cmp x1, x0" };
     call @_aarch64_eval(0x540000c0:bv32, 0x834:bv64) { .asm = "b.eq #0x18" };
     assert boolor(eq(0x84c:bv64, $PC), eq(0x838:bv64, $PC));
     goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code_1);
   ];
   block %deregister_tm_clones_code_1 { .address = 2104;
       .gtirb_block = "TxTRm4kpQiq/Xgistx+xbQ";
       .succ = [ { .address = 2124; .conditional = "true"; .direct = "true";
               .target = "internal:mmpaLvZYQk2b8selWCLriA"; .type = "Type_Branch" };
           { .address = 2116; .conditional = "true"; .direct = "true";
               .target = "internal:SFN4dpBgSO2bPUu0fyDluw";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x838:bv64, $PC);
     call @_aarch64_eval(0xf00000e1:bv32, 0x838:bv64) { .asm = "adrp x1, #0x1f000" };
     call @_aarch64_eval(0xf947e021:bv32, 0x83c:bv64) { .asm = "ldr x1, [x1, #0xfc0]" };
     call @_aarch64_eval(0xb4000061:bv32, 0x840:bv64) { .asm = "cbz x1, #0xc" };
     assert boolor(eq(0x84c:bv64, $PC), eq(0x844:bv64, $PC));
     goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code);
   ];
   block %deregister_tm_clones_code { .address = 2116;
       .gtirb_block = "SFN4dpBgSO2bPUu0fyDluw";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Branch" } ] } [
     assume eq(0x844:bv64, $PC);
     call @_aarch64_eval(0xaa0103f0:bv32, 0x844:bv64) { .asm = "mov x16, x1" };
     call @_aarch64_eval(0xd61f0200:bv32, 0x848:bv64) { .asm = "br x16" };
     assert false;
     unreachable;
   ];
   block %deregister_tm_clones_code_3 { .address = 2124;
       .gtirb_block = "mmpaLvZYQk2b8selWCLriA";
       .succ = [ { .address = 2240; .conditional = "false"; .direct = "true";
               .target = "external:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Return" } ] } [
     assume eq(0x84c:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x84c:bv64) { .asm = "ret " };
     assert boolor(eq(0x8c0:bv64, $PC));
     goto (%ret_5);
   ];
   block %ret_5 [ return; ]
];
proc @FUN_790()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x790:bv64, $PC))

[
   block %FUN_790_code { .address = 1936; .gtirb_block = "NfWWPq4PTwyv0VapVhBGag";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:2RVf8+CWScepXoo7uSZOhQ"; .type = "Type_Branch" } ] } [
     assume eq(0x790:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x790:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9401211:bv32, 0x794:bv64) { .asm = "ldr x17, [x16, #0x20]" };
     call @_aarch64_eval(0x91008210:bv32, 0x798:bv64) { .asm = "add x16, x16, #0x20" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x79c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @func1()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x8e4:bv64, $PC))

[
   block %func1_code { .address = 2276; .gtirb_block = "lFxxVCVARIKoZ6fzUj5YPw";
       .succ = [ { .address = 2444; .conditional = "false"; .direct = "true";
               .target = "external:5jlZESzjQ4a4yO3+e1nyHQ"; .type = "Type_Return" } ] } [
     assume eq(0x8e4:bv64, $PC);
     call @_aarch64_eval(0xa9be7bfd:bv32, 0x8e4:bv64) { .asm = "stp x29, x30, [sp, #-0x20]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x8e8:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xf9000fe0:bv32, 0x8ec:bv64) { .asm = "str x0, [sp, #0x18]" };
     call @_aarch64_eval(0xf9400fe0:bv32, 0x8f0:bv64) { .asm = "ldr x0, [sp, #0x18]" };
     call @_aarch64_eval(0x52800021:bv32, 0x8f4:bv64) { .asm = "mov w1, #1" };
     call @_aarch64_eval(0xb9000001:bv32, 0x8f8:bv64) { .asm = "str w1, [x0]" };
     call @_aarch64_eval(0xf9400fe0:bv32, 0x8fc:bv64) { .asm = "ldr x0, [sp, #0x18]" };
     call @_aarch64_eval(0xa8c27bfd:bv32, 0x900:bv64) { .asm = "ldp x29, x30, [sp], #0x20" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x904:bv64) { .asm = "ret " };
     assert boolor(eq(0x98c:bv64, $PC));
     goto (%ret);
   ];
   block %ret [ return; ]
];
proc @FUN_7a0()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x7a0:bv64, $PC))

[
   block %FUN_7a0_code { .address = 1952; .gtirb_block = "cdQ2GS2+QhaOa7OUvPWMRQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:Cns0vXEvT8m65PzCg4HESA"; .type = "Type_Branch" } ] } [
     assume eq(0x7a0:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x7a0:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9401611:bv32, 0x7a4:bv64) { .asm = "ldr x17, [x16, #0x28]" };
     call @_aarch64_eval(0x9100a210:bv32, 0x7a8:bv64) { .asm = "add x16, x16, #0x28" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x7ac:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @frame_dummy()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x8e0:bv64, $PC))

[
   block %frame_dummy_code { .address = 2272;
       .gtirb_block = "Y/R8k4zNQOW7WdsmX6n3Vw";
       .succ = [ { .address = 2128; .conditional = "false"; .direct = "true";
               .target = "stmts:6JJvkaLhTaWXaEL0+yxKxg"; .type = "Type_Branch" } ] } [
     assume eq(0x8e0:bv64, $PC);
     call @_aarch64_eval(0x17ffffdc:bv32, 0x8e0:bv64) { .asm = "b #0xffffffffffffff70" };
     assert boolor(eq(0x850:bv64, $PC));
     goto (%frame_dummy_ext);
   ];
   block %frame_dummy_ext [
     assume eq(0x850:bv64, $PC);
     call @register_tm_clones();
     assert false;
     unreachable;
   ]
];
proc @register_tm_clones()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x850:bv64, $PC))

[
   block %register_tm_clones_code_3 { .address = 2128;
       .gtirb_block = "6JJvkaLhTaWXaEL0+yxKxg";
       .succ = [ { .address = 2184; .conditional = "true"; .direct = "true";
               .target = "internal:ZLfuz7OtTNOS9GLtqSI1gg"; .type = "Type_Branch" };
           { .address = 2164; .conditional = "true"; .direct = "true";
               .target = "internal:OuTzy8qRTci75taVjGinFQ";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x850:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x850:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0x91010000:bv32, 0x854:bv64) { .asm = "add x0, x0, #0x40" };
     call @_aarch64_eval(0x90000101:bv32, 0x858:bv64) { .asm = "adrp x1, #0x20000" };
     call @_aarch64_eval(0x91010021:bv32, 0x85c:bv64) { .asm = "add x1, x1, #0x40" };
     call @_aarch64_eval(0xcb000021:bv32, 0x860:bv64) { .asm = "sub x1, x1, x0" };
     call @_aarch64_eval(0xd37ffc22:bv32, 0x864:bv64) { .asm = "lsr x2, x1, #0x3f" };
     call @_aarch64_eval(0x8b810c41:bv32, 0x868:bv64) { .asm = "add x1, x2, x1, asr #3" };
     call @_aarch64_eval(0x9341fc21:bv32, 0x86c:bv64) { .asm = "asr x1, x1, #1" };
     call @_aarch64_eval(0xb40000c1:bv32, 0x870:bv64) { .asm = "cbz x1, #0x18" };
     assert boolor(eq(0x888:bv64, $PC), eq(0x874:bv64, $PC));
     goto (%register_tm_clones_code_1,%register_tm_clones_code);
   ];
   block %register_tm_clones_code { .address = 2164;
       .gtirb_block = "OuTzy8qRTci75taVjGinFQ";
       .succ = [ { .address = 2176; .conditional = "true"; .direct = "true";
               .target = "internal:rCSSdLZcRB2TKAu9h+WCqg";
               .type = "Type_Fallthrough" };
           { .address = 2184; .conditional = "true"; .direct = "true";
               .target = "internal:ZLfuz7OtTNOS9GLtqSI1gg"; .type = "Type_Branch" } ] } [
     assume eq(0x874:bv64, $PC);
     call @_aarch64_eval(0xf00000e2:bv32, 0x874:bv64) { .asm = "adrp x2, #0x1f000" };
     call @_aarch64_eval(0xf947f042:bv32, 0x878:bv64) { .asm = "ldr x2, [x2, #0xfe0]" };
     call @_aarch64_eval(0xb4000062:bv32, 0x87c:bv64) { .asm = "cbz x2, #0xc" };
     assert boolor(eq(0x880:bv64, $PC), eq(0x888:bv64, $PC));
     goto (%register_tm_clones_code_2,%register_tm_clones_code_1);
   ];
   block %register_tm_clones_code_2 { .address = 2176;
       .gtirb_block = "rCSSdLZcRB2TKAu9h+WCqg";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Branch" } ] } [
     assume eq(0x880:bv64, $PC);
     call @_aarch64_eval(0xaa0203f0:bv32, 0x880:bv64) { .asm = "mov x16, x2" };
     call @_aarch64_eval(0xd61f0200:bv32, 0x884:bv64) { .asm = "br x16" };
     assert false;
     unreachable;
   ];
   block %register_tm_clones_code_1 { .address = 2184;
       .gtirb_block = "ZLfuz7OtTNOS9GLtqSI1gg";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x888:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x888:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_2);
   ];
   block %ret_2 [ return; ]
];
proc @func2()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x908:bv64, $PC))

[
   block %func2_code { .address = 2312; .gtirb_block = "G0vHB4sSQ3yHYTbHJG37zQ";
       .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
               .target = "stmts:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Call" } ] } [
     assume eq(0x908:bv64, $PC);
     call @_aarch64_eval(0xa9be7bfd:bv32, 0x908:bv64) { .asm = "stp x29, x30, [sp, #-0x20]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x90c:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xf9000fe0:bv32, 0x910:bv64) { .asm = "str x0, [sp, #0x18]" };
     call @_aarch64_eval(0xf9400fe0:bv32, 0x914:bv64) { .asm = "ldr x0, [sp, #0x18]" };
     call @_aarch64_eval(0x97ffffa2:bv32, 0x918:bv64) { .asm = "bl #0xfffffffffffffe88" };
     assert boolor(eq(0x7a0:bv64, $PC));
     goto (%func2_ext_2);
   ];
   block %func2_ext_2 [
     assume eq(0x7a0:bv64, $PC);
     call @FUN_7a0();
     assert boolor(eq(0x91c:bv64, $PC));
     goto (%func2_code_1);
   ];
   block %func2_code_1 { .address = 2332; .gtirb_block = "LyxvLr79TJCmN7I2k2Z9dA";
       .succ = [ { .address = 1904; .conditional = "false"; .direct = "true";
               .target = "stmts:GW0MHC+ORUKlCdpgOcZ6zA"; .type = "Type_Call" } ] } [
     assume eq(0x91c:bv64, $PC);
     call @_aarch64_eval(0xd2800080:bv32, 0x91c:bv64) { .asm = "mov x0, #4" };
     call @_aarch64_eval(0x97ffff94:bv32, 0x920:bv64) { .asm = "bl #0xfffffffffffffe50" };
     assert boolor(eq(0x770:bv64, $PC));
     goto (%func2_ext_1);
   ];
   block %func2_ext_1 [
     assume eq(0x770:bv64, $PC);
     call @FUN_770();
     assert boolor(eq(0x924:bv64, $PC));
     goto (%func2_code_2);
   ];
   block %func2_code_2 { .address = 2340; .gtirb_block = "24sQpyZMTFejNeMkgQiWnw";
       .succ = [ { .address = 2444; .conditional = "false"; .direct = "true";
               .target = "external:5jlZESzjQ4a4yO3+e1nyHQ"; .type = "Type_Return" } ] } [
     assume eq(0x924:bv64, $PC);
     call @_aarch64_eval(0xf9000fe0:bv32, 0x924:bv64) { .asm = "str x0, [sp, #0x18]" };
     call @_aarch64_eval(0xf9400fe0:bv32, 0x928:bv64) { .asm = "ldr x0, [sp, #0x18]" };
     call @_aarch64_eval(0x52800041:bv32, 0x92c:bv64) { .asm = "mov w1, #2" };
     call @_aarch64_eval(0xb9000001:bv32, 0x930:bv64) { .asm = "str w1, [x0]" };
     call @_aarch64_eval(0xf9400fe0:bv32, 0x934:bv64) { .asm = "ldr x0, [sp, #0x18]" };
     call @_aarch64_eval(0xa8c27bfd:bv32, 0x938:bv64) { .asm = "ldp x29, x30, [sp], #0x20" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x93c:bv64) { .asm = "ret " };
     assert boolor(eq(0x98c:bv64, $PC));
     goto (%ret_2);
   ];
   block %ret_2 [ return; ]
];
proc @_init()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x710:bv64, $PC))

[
   block %_init_code_1 { .address = 1808; .gtirb_block = "UtkQk4ONSE6hNEuDpZ95RQ";
       .succ = [ { .address = 2036; .conditional = "false"; .direct = "true";
               .target = "stmts:oqiqdATZTc6MDOYJqL9Aew"; .type = "Type_Call" } ] } [
     assume eq(0x710:bv64, $PC);
     call @_aarch64_eval(0xd503233f:bv32, 0x710:bv64) { .asm = "paciasp " };
     call @_aarch64_eval(0xa9bf7bfd:bv32, 0x714:bv64) { .asm = "stp x29, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x718:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0x94000036:bv32, 0x71c:bv64) { .asm = "bl #0xd8" };
     assert boolor(eq(0x7f4:bv64, $PC));
     goto (%_init_ext);
   ];
   block %_init_ext [
     assume eq(0x7f4:bv64, $PC);
     call @call_weak_fn();
     assert boolor(eq(0x720:bv64, $PC));
     goto (%_init_code);
   ];
   block %_init_code { .address = 1824; .gtirb_block = "KTHyjTW0SWiGwqylcMDw6Q";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x720:bv64, $PC);
     call @_aarch64_eval(0xa8c17bfd:bv32, 0x720:bv64) { .asm = "ldp x29, x30, [sp], #0x10" };
     call @_aarch64_eval(0xd50323bf:bv32, 0x724:bv64) { .asm = "autiasp " };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x728:bv64) { .asm = "ret " };
     assert false;
     goto (%ret);
   ];
   block %ret [ return; ]
];
proc @_start()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x7c0:bv64, $PC))

[
   block %_start_code { .address = 1984; .gtirb_block = "rIlbG4jGSTydaFqMhxCKWw";
       .succ = [ { .address = 1872; .conditional = "false"; .direct = "true";
               .target = "stmts:fxMAJl44TWOTA8IHVD8V7Q"; .type = "Type_Call" } ] } [
     assume eq(0x7c0:bv64, $PC);
     call @_aarch64_eval(0xd503245f:bv32, 0x7c0:bv64) { .asm = "bti c" };
     call @_aarch64_eval(0xd280001d:bv32, 0x7c4:bv64) { .asm = "mov x29, #0" };
     call @_aarch64_eval(0xd280001e:bv32, 0x7c8:bv64) { .asm = "mov x30, #0" };
     call @_aarch64_eval(0xaa0003e5:bv32, 0x7cc:bv64) { .asm = "mov x5, x0" };
     call @_aarch64_eval(0xf94003e1:bv32, 0x7d0:bv64) { .asm = "ldr x1, [sp]" };
     call @_aarch64_eval(0x910023e2:bv32, 0x7d4:bv64) { .asm = "add x2, sp, #8" };
     call @_aarch64_eval(0x910003e6:bv32, 0x7d8:bv64) { .asm = "mov x6, sp" };
     call @_aarch64_eval(0xf00000e0:bv32, 0x7dc:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947ec00:bv32, 0x7e0:bv64) { .asm = "ldr x0, [x0, #0xfd8]" };
     call @_aarch64_eval(0xd2800003:bv32, 0x7e4:bv64) { .asm = "mov x3, #0" };
     call @_aarch64_eval(0xd2800004:bv32, 0x7e8:bv64) { .asm = "mov x4, #0" };
     call @_aarch64_eval(0x97ffffd9:bv32, 0x7ec:bv64) { .asm = "bl #0xffffffffffffff64" };
     assert boolor(eq(0x750:bv64, $PC));
     goto (%_start_ext_1);
   ];
   block %_start_ext_1 [
     assume eq(0x750:bv64, $PC);
     call @FUN_750();
     assert boolor(eq(0x7f0:bv64, $PC));
     goto (%_start_code_1);
   ];
   block %_start_code_1 { .address = 2032; .gtirb_block = "tXIOhSQ+R1WA/9VL5+6KQQ";
       .succ = [ { .address = 1936; .conditional = "false"; .direct = "true";
               .target = "stmts:NfWWPq4PTwyv0VapVhBGag"; .type = "Type_Call" } ] } [
     assume eq(0x7f0:bv64, $PC);
     call @_aarch64_eval(0x97ffffe8:bv32, 0x7f0:bv64) { .asm = "bl #0xffffffffffffffa0" };
     assert boolor(eq(0x790:bv64, $PC));
     goto (%_start_ext);
   ];
   block %_start_ext [
     assume eq(0x790:bv64, $PC);
     call @FUN_790();
     assert false;
     unreachable;
   ]
];
proc @FUN_760()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x760:bv64, $PC))

[
   block %FUN_760_code { .address = 1888; .gtirb_block = "yQ1z8A+IRoSs4MRYTbbghg";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:ytZMtg8PQgqQBf3elNGusQ"; .type = "Type_Branch" } ] } [
     assume eq(0x760:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x760:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400611:bv32, 0x764:bv64) { .asm = "ldr x17, [x16, #8]" };
     call @_aarch64_eval(0x91002210:bv32, 0x768:bv64) { .asm = "add x16, x16, #8" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x76c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @__do_global_dtors_aux()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x88c:bv64, $PC))

[
   block %__do_global_dtors_aux_code { .address = 2188;
       .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
       .succ = [ { .address = 2212; .conditional = "true"; .direct = "true";
               .target = "internal:32fWxY7+R++JNJOFTmT+Sg";
               .type = "Type_Fallthrough" };
           { .address = 2248; .conditional = "true"; .direct = "true";
               .target = "internal:gFBdrsFTRkSCdIsDFMk6qA"; .type = "Type_Branch" } ] } [
     assume eq(0x88c:bv64, $PC);
     call @_aarch64_eval(0xa9be7bfd:bv32, 0x88c:bv64) { .asm = "stp x29, x30, [sp, #-0x20]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x890:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xf9000bf3:bv32, 0x894:bv64) { .asm = "str x19, [sp, #0x10]" };
     call @_aarch64_eval(0x90000113:bv32, 0x898:bv64) { .asm = "adrp x19, #0x20000" };
     call @_aarch64_eval(0x39410260:bv32, 0x89c:bv64) { .asm = "ldrb w0, [x19, #0x40]" };
     call @_aarch64_eval(0x37000140:bv32, 0x8a0:bv64) { .asm = "tbnz w0, #0, #0x28" };
     assert boolor(eq(0x8a4:bv64, $PC), eq(0x8c8:bv64, $PC));
     goto (%__do_global_dtors_aux_code_6,%__do_global_dtors_aux_code_2);
   ];
   block %__do_global_dtors_aux_code_2 { .address = 2248;
       .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x8c8:bv64, $PC);
     call @_aarch64_eval(0xf9400bf3:bv32, 0x8c8:bv64) { .asm = "ldr x19, [sp, #0x10]" };
     call @_aarch64_eval(0xa8c27bfd:bv32, 0x8cc:bv64) { .asm = "ldp x29, x30, [sp], #0x20" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x8d0:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_3);
   ];
   block %ret_3 [ return; ];
   block %__do_global_dtors_aux_code_6 { .address = 2212;
       .gtirb_block = "32fWxY7+R++JNJOFTmT+Sg";
       .succ = [ { .address = 2224; .conditional = "true"; .direct = "true";
               .target = "internal:lr6o4ptnRiK3TGR1gpiWGg";
               .type = "Type_Fallthrough" };
           { .address = 2236; .conditional = "true"; .direct = "true";
               .target = "internal:b8tsihT4Q6a/SWPo4w8HoA"; .type = "Type_Branch" } ] } [
     assume eq(0x8a4:bv64, $PC);
     call @_aarch64_eval(0xf00000e0:bv32, 0x8a4:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947e400:bv32, 0x8a8:bv64) { .asm = "ldr x0, [x0, #0xfc8]" };
     call @_aarch64_eval(0xb4000080:bv32, 0x8ac:bv64) { .asm = "cbz x0, #0x10" };
     assert boolor(eq(0x8b0:bv64, $PC), eq(0x8bc:bv64, $PC));
     goto (%__do_global_dtors_aux_code_3,%__do_global_dtors_aux_code_1);
   ];
   block %__do_global_dtors_aux_code_1 { .address = 2236;
       .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
       .succ = [ { .address = 2080; .conditional = "false"; .direct = "true";
               .target = "stmts:lwyID0MJQb6vgyjzPFtz8Q"; .type = "Type_Call" } ] } [
     assume eq(0x8bc:bv64, $PC);
     call @_aarch64_eval(0x97ffffd9:bv32, 0x8bc:bv64) { .asm = "bl #0xffffffffffffff64" };
     assert boolor(eq(0x820:bv64, $PC));
     goto (%__do_global_dtors_aux_ext);
   ];
   block %__do_global_dtors_aux_ext [
     assume eq(0x820:bv64, $PC);
     call @deregister_tm_clones();
     assert boolor(eq(0x8c0:bv64, $PC));
     goto (%__do_global_dtors_aux_code_4);
   ];
   block %__do_global_dtors_aux_code_4 { .address = 2240;
       .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
       .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
               .target = "internal:gFBdrsFTRkSCdIsDFMk6qA";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x8c0:bv64, $PC);
     call @_aarch64_eval(0x52800020:bv32, 0x8c0:bv64) { .asm = "mov w0, #1" };
     call @_aarch64_eval(0x39010260:bv32, 0x8c4:bv64) { .asm = "strb w0, [x19, #0x40]" };
     assert boolor(eq(0x8c8:bv64, $PC));
     goto (%__do_global_dtors_aux_code_2);
   ];
   block %__do_global_dtors_aux_code_3 { .address = 2224;
       .gtirb_block = "lr6o4ptnRiK3TGR1gpiWGg";
       .succ = [ { .address = 1888; .conditional = "false"; .direct = "true";
               .target = "stmts:yQ1z8A+IRoSs4MRYTbbghg"; .type = "Type_Call" } ] } [
     assume eq(0x8b0:bv64, $PC);
     call @_aarch64_eval(0x90000100:bv32, 0x8b0:bv64) { .asm = "adrp x0, #0x20000" };
     call @_aarch64_eval(0xf9401c00:bv32, 0x8b4:bv64) { .asm = "ldr x0, [x0, #0x38]" };
     call @_aarch64_eval(0x97ffffaa:bv32, 0x8b8:bv64) { .asm = "bl #0xfffffffffffffea8" };
     assert boolor(eq(0x760:bv64, $PC));
     goto (%__do_global_dtors_aux_ext_1);
   ];
   block %__do_global_dtors_aux_ext_1 [
     assume eq(0x760:bv64, $PC);
     call @FUN_760();
     assert boolor(eq(0x8bc:bv64, $PC));
     goto (%__do_global_dtors_aux_code_1);
   ]
];
proc @call_weak_fn()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x7f4:bv64, $PC))

[
   block %call_weak_fn_code_2 { .address = 2036;
       .gtirb_block = "oqiqdATZTc6MDOYJqL9Aew";
       .succ = [ { .address = 2048; .conditional = "true"; .direct = "true";
               .target = "internal:IkNYmV06TxC75h8A4NM3wA";
               .type = "Type_Fallthrough" };
           { .address = 2052; .conditional = "true"; .direct = "true";
               .target = "internal:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Branch" } ] } [
     assume eq(0x7f4:bv64, $PC);
     call @_aarch64_eval(0xf00000e0:bv32, 0x7f4:bv64) { .asm = "adrp x0, #0x1f000" };
     call @_aarch64_eval(0xf947e800:bv32, 0x7f8:bv64) { .asm = "ldr x0, [x0, #0xfd0]" };
     call @_aarch64_eval(0xb4000040:bv32, 0x7fc:bv64) { .asm = "cbz x0, #8" };
     assert boolor(eq(0x800:bv64, $PC), eq(0x804:bv64, $PC));
     goto (%call_weak_fn_code_1,%call_weak_fn_code);
   ];
   block %call_weak_fn_code { .address = 2052;
       .gtirb_block = "D9t2gNJrSmyMH3GAVRe3IQ";
       .succ = [ { .address = 1824; .conditional = "false"; .direct = "true";
               .target = "external:KTHyjTW0SWiGwqylcMDw6Q"; .type = "Type_Return" } ] } [
     assume eq(0x804:bv64, $PC);
     call @_aarch64_eval(0xd65f03c0:bv32, 0x804:bv64) { .asm = "ret " };
     assert boolor(eq(0x720:bv64, $PC));
     goto (%ret);
   ];
   block %ret [ return; ];
   block %call_weak_fn_code_1 { .address = 2048;
       .gtirb_block = "IkNYmV06TxC75h8A4NM3wA";
       .succ = [ { .address = 1920; .conditional = "false"; .direct = "true";
               .target = "stmts:GghTYm6bT12tNFmqu0nIjA"; .type = "Type_Branch" } ] } [
     assume eq(0x800:bv64, $PC);
     call @_aarch64_eval(0x17ffffe0:bv32, 0x800:bv64) { .asm = "b #0xffffffffffffff80" };
     assert boolor(eq(0x780:bv64, $PC));
     goto (%call_weak_fn_ext_1);
   ];
   block %call_weak_fn_ext_1 [
     assume eq(0x780:bv64, $PC);
     call @.L_780();
     assert false;
     unreachable;
   ]
];
proc @main()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x9a0:bv64, $PC))

[
   block %main_code { .address = 2464; .gtirb_block = "I2aaHzp+TUWUl9oP4OxUPg";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x9a0:bv64, $PC);
     call @_aarch64_eval(0xa9bf7bfd:bv32, 0x9a0:bv64) { .asm = "stp x29, x30, [sp, #-0x10]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x9a4:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0x52800000:bv32, 0x9a8:bv64) { .asm = "mov w0, #0" };
     call @_aarch64_eval(0xa8c17bfd:bv32, 0x9ac:bv64) { .asm = "ldp x29, x30, [sp], #0x10" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x9b0:bv64) { .asm = "ret " };
     assert false;
     goto (%ret);
   ];
   block %ret [ return; ]
];
proc @.L_780()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x780:bv64, $PC))

[
   block %L_780_code { .address = 1920; .gtirb_block = "GghTYm6bT12tNFmqu0nIjA";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:RZVKHxz+S4Kj5KQwnCd8Bw"; .type = "Type_Branch" } ] } [
     assume eq(0x780:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x780:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400e11:bv32, 0x784:bv64) { .asm = "ldr x17, [x16, #0x18]" };
     call @_aarch64_eval(0x91006210:bv32, 0x788:bv64) { .asm = "add x16, x16, #0x18" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x78c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
proc @caller()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x940:bv64, $PC))

[
   block %caller_code_2 { .address = 2368; .gtirb_block = "X7GJYS43TTaiN95nNBoPIg";
       .succ = [ { .address = 2408; .conditional = "true"; .direct = "true";
               .target = "internal:lrKKe+miRjSnSiaG164qMA"; .type = "Type_Branch" };
           { .address = 2392; .conditional = "true"; .direct = "true";
               .target = "internal:c/WxqFxXSHWNzwaD8KmaZw";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x940:bv64, $PC);
     call @_aarch64_eval(0xa9bc7bfd:bv32, 0x940:bv64) { .asm = "stp x29, x30, [sp, #-0x40]!" };
     call @_aarch64_eval(0x910003fd:bv32, 0x944:bv64) { .asm = "mov x29, sp" };
     call @_aarch64_eval(0xb9001fe0:bv32, 0x948:bv64) { .asm = "str w0, [sp, #0x1c]" };
     call @_aarch64_eval(0xb9401fe0:bv32, 0x94c:bv64) { .asm = "ldr w0, [sp, #0x1c]" };
     call @_aarch64_eval(0x7100041f:bv32, 0x950:bv64) { .asm = "cmp w0, #1" };
     call @_aarch64_eval(0x540000ad:bv32, 0x954:bv64) { .asm = "b.le #0x14" };
     assert boolor(eq(0x968:bv64, $PC), eq(0x958:bv64, $PC));
     goto (%caller_code_4,%caller_code_3);
   ];
   block %caller_code_3 { .address = 2392; .gtirb_block = "c/WxqFxXSHWNzwaD8KmaZw";
       .succ = [ { .address = 2420; .conditional = "false"; .direct = "true";
               .target = "internal:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Branch" } ] } [
     assume eq(0x958:bv64, $PC);
     call @_aarch64_eval(0x90000000:bv32, 0x958:bv64) { .asm = "adrp x0, #0" };
     call @_aarch64_eval(0x91239000:bv32, 0x95c:bv64) { .asm = "add x0, x0, #0x8e4" };
     call @_aarch64_eval(0xf9001fe0:bv32, 0x960:bv64) { .asm = "str x0, [sp, #0x38]" };
     call @_aarch64_eval(0x14000004:bv32, 0x964:bv64) { .asm = "b #0x10" };
     assert boolor(eq(0x974:bv64, $PC));
     goto (%caller_code_1);
   ];
   block %caller_code_4 { .address = 2408; .gtirb_block = "lrKKe+miRjSnSiaG164qMA";
       .succ = [ { .address = 2420; .conditional = "false"; .direct = "true";
               .target = "internal:U8BozksvTwaykuzNC4dZRQ";
               .type = "Type_Fallthrough" } ] } [
     assume eq(0x968:bv64, $PC);
     call @_aarch64_eval(0x90000000:bv32, 0x968:bv64) { .asm = "adrp x0, #0" };
     call @_aarch64_eval(0x91242000:bv32, 0x96c:bv64) { .asm = "add x0, x0, #0x908" };
     call @_aarch64_eval(0xf9001fe0:bv32, 0x970:bv64) { .asm = "str x0, [sp, #0x38]" };
     assert boolor(eq(0x974:bv64, $PC));
     goto (%caller_code_1);
   ];
   block %caller_code_1 { .address = 2420; .gtirb_block = "U8BozksvTwaykuzNC4dZRQ";
       .succ = [ { .address = 1904; .conditional = "false"; .direct = "true";
               .target = "stmts:GW0MHC+ORUKlCdpgOcZ6zA"; .type = "Type_Call" } ] } [
     assume eq(0x974:bv64, $PC);
     call @_aarch64_eval(0xd2800080:bv32, 0x974:bv64) { .asm = "mov x0, #4" };
     call @_aarch64_eval(0x97ffff7e:bv32, 0x978:bv64) { .asm = "bl #0xfffffffffffffdf8" };
     assert boolor(eq(0x770:bv64, $PC));
     goto (%caller_ext);
   ];
   block %caller_ext [
     assume eq(0x770:bv64, $PC);
     call @FUN_770();
     assert boolor(eq(0x97c:bv64, $PC));
     goto (%caller_code);
   ];
   block %caller_code { .address = 2428; .gtirb_block = "H7LPJaZbQvWx+VL+kBk//Q";
       .succ = [ { .address = 2276; .conditional = "false"; .direct = "false";
               .target = "stmts:lFxxVCVARIKoZ6fzUj5YPw"; .type = "Type_Call" };
           { .address = 2312; .conditional = "false"; .direct = "false";
               .target = "stmts:G0vHB4sSQ3yHYTbHJG37zQ"; .type = "Type_Call" } ] } [
     assume eq(0x97c:bv64, $PC);
     call @_aarch64_eval(0xf9001be0:bv32, 0x97c:bv64) { .asm = "str x0, [sp, #0x30]" };
     call @_aarch64_eval(0xf9401fe1:bv32, 0x980:bv64) { .asm = "ldr x1, [sp, #0x38]" };
     call @_aarch64_eval(0xf9401be0:bv32, 0x984:bv64) { .asm = "ldr x0, [sp, #0x30]" };
     call @_aarch64_eval(0xd63f0020:bv32, 0x988:bv64) { .asm = "blr x1" };
     assert boolor(eq(0x8e4:bv64, $PC), eq(0x908:bv64, $PC));
     goto (%caller_ext_2,%caller_ext_1);
   ];
   block %caller_ext_1 [
     assume eq(0x908:bv64, $PC);
     call @func2();
     assert boolor(eq(0x98c:bv64, $PC));
     goto (%caller_code_5);
   ];
   block %caller_ext_2 [
     assume eq(0x8e4:bv64, $PC);
     call @func1();
     assert boolor(eq(0x98c:bv64, $PC));
     goto (%caller_code_5);
   ];
   block %caller_code_5 { .address = 2444; .gtirb_block = "5jlZESzjQ4a4yO3+e1nyHQ";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:HEccxMPvSjiDwavsuf9mCQ"; .type = "Type_Return" } ] } [
     assume eq(0x98c:bv64, $PC);
     call @_aarch64_eval(0xf90017e0:bv32, 0x98c:bv64) { .asm = "str x0, [sp, #0x28]" };
     call @_aarch64_eval(0xf94017e0:bv32, 0x990:bv64) { .asm = "ldr x0, [sp, #0x28]" };
     call @_aarch64_eval(0xb9400000:bv32, 0x994:bv64) { .asm = "ldr w0, [x0]" };
     call @_aarch64_eval(0xa8c47bfd:bv32, 0x998:bv64) { .asm = "ldp x29, x30, [sp], #0x40" };
     call @_aarch64_eval(0xd65f03c0:bv32, 0x99c:bv64) { .asm = "ret " };
     assert false;
     goto (%ret_7);
   ];
   block %ret_7 [ return; ]
];
proc @FUN_770()  -> () {  }
  captures $PC:bv64
  requires boolor(eq(0x770:bv64, $PC))

[
   block %FUN_770_code { .address = 1904; .gtirb_block = "GW0MHC+ORUKlCdpgOcZ6zA";
       .succ = [ { .conditional = "false"; .direct = "false";
               .target = "proxy:X9o/brdiRFeSd7R8PnB6LA"; .type = "Type_Branch" } ] } [
     assume eq(0x770:bv64, $PC);
     call @_aarch64_eval(0x90000110:bv32, 0x770:bv64) { .asm = "adrp x16, #0x20000" };
     call @_aarch64_eval(0xf9400a11:bv32, 0x774:bv64) { .asm = "ldr x17, [x16, #0x10]" };
     call @_aarch64_eval(0x91004210:bv32, 0x778:bv64) { .asm = "add x16, x16, #0x10" };
     call @_aarch64_eval(0xd61f0220:bv32, 0x77c:bv64) { .asm = "br x17" };
     assert false;
     unreachable;
   ]
];
prog entry @_start { .initial_memory = [ { .address = 0;
            .bytes = "A#\000\000\000aeabi_feature_and_bits\000\001\000\000\000\001\000\002\000";
            .name = ".ARM.attributes"; .read_only = true; .size = 36 };
        { .address = 568;
            .bytes = [ "H4sIAAAAAAAA/wFuAJH/L25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliL2xkLWxpbnV4LWFhcmNoNjQuc28uMQA6rjEIbgAAAA==" ];
            .name = ".interp"; .read_only = true; .size = 110 };
        { .address = 680;
            .bytes = "\003\000\000\000\011\000\000\000\007\000\000\000\n\000\000\000\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\005\000\000\000\000\000\000\000\006\000\000\000\004\000\000\000\t\000\000\000";
            .name = ".hash"; .read_only = true; .size = 64 };
        { .address = 744;
            .bytes = "\001\000\000\000\001\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
            .name = ".gnu.hash"; .read_only = true; .size = 28 };
        { .address = 776;
            .bytes = [ "H4sIAAAAAAAA/wEIAff+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMACgAQBwAAAAAAAAAAAAAAAAAAAAAAAAMAFwAwAAIAAAAAAAAAAAAAAAAADQAAABIAAAAAAAAAAAAAAAAAAAAAAAAAHwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAHwAAACIAAAAAAAAAAAAAAAAAAAAAAAAABgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAOwEAACAAAAAAAAAAAAAAAAAAAAAAAAAALgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAAAAAAAAAAAAAAAASgEAACAAAAAAAAAAAAAAAAAAAAAAAAAAFQpBtwgBAAA=" ];
            .name = ".dynsym"; .read_only = true; .size = 264 };
        { .address = 1040;
            .bytes = [ "H4sIAAAAAAAA/wFkAZv+AGZyZWUAbWFsbG9jAF9fbGliY19zdGFydF9tYWluAF9fY3hhX2ZpbmFsaXplAGFib3J0AGxpYmMuc28uNgBHTElCQ18yLjE3AEdMSUJDXzIuMzQAL25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliOi9uaXgvc3RvcmUvbGd3cTB6eWhzZjB2eGcyMHI1ajJnMW13cnJyc3lncWctYWFyY2g2NC11bmtub3duLWxpbnV4LWdudS1nY2MtMTUuMy4wLWxpYi9hYXJjaDY0LXVua25vd24tbGludXgtZ251L2xpYgBfSVRNX2RlcmVnaXN0ZXJUTUNsb25lVGFibGUAX19nbW9uX3N0YXJ0X18AX0lUTV9yZWdpc3RlclRNQ2xvbmVUYWJsZQCIWUk9ZAEAAA==" ];
            .name = ".dynstr"; .read_only = true; .size = 356 };
        { .address = 1396;
            .bytes = "\000\000\000\000\000\000\002\000\000\000\003\000\003\000\000\000\003\000\003\000\000\000";
            .name = ".gnu.version"; .read_only = true; .size = 22 };
        { .address = 1424;
            .bytes = "\001\000\002\0004\000\000\000\016\000\000\000\000\000\000\000\151\145\150\006\000\000\003\000>\000\000\000\016\000\000\000\180\145\150\006\000\000\002\000I\000\000\000\000\000\000\000";
            .name = ".gnu.version_r"; .read_only = true; .size = 48 };
        { .address = 1472;
            .bytes = [ "H4sIAAAAAAAA/wHAAD//qP0BAAAAAAADBAAAAAAAAOAIAAAAAAAAsP0BAAAAAAADBAAAAAAAAIwIAAAAAAAA2P8BAAAAAAADBAAAAAAAAKAJAAAAAAAAOAACAAAAAAADBAAAAAAAADgAAgAAAAAAwP8BAAAAAAABBAAABAAAAAAAAAAAAAAAyP8BAAAAAAABBAAABQAAAAAAAAAAAAAA0P8BAAAAAAABBAAABwAAAAAAAAAAAAAA4P8BAAAAAAABBAAACgAAAAAAAAAAAAAAG745w8AAAAA=" ];
            .name = ".rela.dyn"; .read_only = true; .size = 192 };
        { .address = 1664;
            .bytes = [ "H4sIAAAAAAAA/wGQAG//AAACAAAAAAACBAAAAwAAAAAAAAAAAAAACAACAAAAAAACBAAABQAAAAAAAAAAAAAAEAACAAAAAAACBAAABgAAAAAAAAAAAAAAGAACAAAAAAACBAAABwAAAAAAAAAAAAAAIAACAAAAAAACBAAACAAAAAAAAAAAAAAAKAACAAAAAAACBAAACQAAAAAAAAAAAAAA+1ZZqJAAAAA=" ];
            .name = ".rela.plt"; .read_only = true; .size = 144 };
        { .address = 1808;
            .bytes = "?#\003\213\253{\191\169\253\003\000\1456\000\000\148\253{\193\168\191#\003\213\192\003_\214";
            .name = ".init"; .read_only = true; .size = 28 };
        { .address = 1840;
            .bytes = [ "H4sIAAAAAAAA/wGAAH//8Hu/qfAAAPAR/kf5EOI/kSACH9YfIAPVHyAD1R8gA9UQAQCQEQJA+RACAJEgAh/WEAEAkBEGQPkQIgCRIAIf1hABAJARCkD5EEIAkSACH9YQAQCQEQ5A+RBiAJEgAh/WEAEAkBESQPkQggCRIAIf1hABAJARFkD5EKIAkSACH9YwvoyYgAAAAA==" ];
            .name = ".plt"; .read_only = true; .size = 128 };
        { .address = 1984;
            .bytes = [ "H4sIAAAAAAAA/wH0AQv+XyQD1R0AgNIeAIDS5QMAquEDQPniIwCR5gMAkeAAAPAA7Ef5AwCA0gQAgNLZ//+X6P//l+AAAPAA6Ef5QAAAtOD//xfAA1/WHyAD1R8gA9UfIAPVHyAD1R8gA9UfIAPVAAEAkAAAAZEBAQCQIQABkT8AAOvAAABU4QAA8CHgR/lhAAC08AMBqgACH9bAA1/WAAEAkAAAAZEBAQCQIQABkSEAAMsi/H/TQQyBiyH8QZPBAAC04gAA8ELwR/liAAC08AMCqgACH9bAA1/W/Xu+qf0DAJHzCwD5EwEAkGACQTlAAQA34AAA8ADkR/mAAAC0AAEAkAAcQPmq//+X2f//lyAAgFJgAgE58wtA+f17wqjAA1/WHyAD1R8gA9UfIAPV3P//F/17vqn9AwCR4A8A+eAPQPkhAIBSAQAAueAPQPn9e8KowANf1v17vqn9AwCR4A8A+eAPQPmi//+XgACA0pT//5fgDwD54A9A+UEAgFIBAAC54A9A+f17wqjAA1/W/Xu8qf0DAJHgHwC54B9AuR8EAHGtAABUAAAAkACQI5HgHwD5BAAAFAAAAJAAICSR4B8A+YAAgNJ+//+X4BsA+eEfQPngG0D5IAA/1uAXAPngF0D5AABAuf17xKjAA1/W/Xu/qf0DAJEAAIBS/XvBqMADX9ZzK/U69AEAAA==" ];
            .name = ".text"; .read_only = true; .size = 500 };
        { .address = 2484;
            .bytes = "?#\003\213\253{\191\169\253\003\000\145\253{\193\168\191#\003\213\192\003_\214";
            .name = ".fini"; .read_only = true; .size = 24 };
        { .address = 2508; .bytes = "\001\000\002\000"; .name = ".rodata";
            .read_only = true; .size = 4 };
        { .address = 2512;
            .bytes = [ "H4sIAAAAAAAA/wFUAKv/ARsDO1QAAAAJAAAA8P3//2wAAABQ/v//gAAAAID+//+UAAAAvP7//6gAAAAQ////zAAAABT////gAAAAOP///wABAABw////IAEAAND///9AAQAAlPEjtFQAAAA=" ];
            .name = ".eh_frame_hdr"; .read_only = true; .size = 84 };
        { .address = 2600;
            .bytes = [ "H4sIAAAAAAAA/wEMAfP+EAAAAAAAAAABelIABHgeARsMHwAQAAAAGAAAAHz9//80AAAAAEEHHhAAAAAsAAAAyP3//zAAAAAAAAAAEAAAAEAAAADk/f//PAAAAAAAAAAgAAAAVAAAAAz+//9IAAAAAEEOIJ0EngNCkwJO3t3TDgAAAAAQAAAAeAAAADz+//8EAAAAAAAAABwAAACMAAAALP7//yQAAAAAQQ4gnQSeA0fe3Q4AAAAAHAAAAKwAAAAw/v//OAAAAABBDiCdBJ4DTN7dDgAAAAAcAAAAzAAAAEj+//9gAAAAAEEOQJ0IngdW3t0OAAAAABwAAADsAAAAiP7//xQAAAAAQQ4QnQKeAUPe3Q4AAAAAAAAAAGiuKlsMAQAA" ];
            .name = ".eh_frame"; .read_only = true; .size = 268 };
        { .address = 2868;
            .bytes = "\004\000\000\000\016\000\000\000\001\000\000\000GNU\000\000\000\000\000\003\000\000\000\n\000\000\000\000\000\000\000";
            .name = ".note.ABI-tag"; .read_only = true; .size = 32 };
        { .address = 130472; .bytes = "\224\b\000\000\000\000\000\000";
            .name = ".init_array"; .size = 8 };
        { .address = 130480; .bytes = "\140\b\000\000\000\000\000\000";
            .name = ".fini_array"; .size = 8 };
        { .address = 130488;
            .bytes = [ "H4sIAAAAAAAA/wEAAv/9AQAAAAAAAAA0AAAAAAAAAB0AAAAAAAAAVAAAAAAAAAAMAAAAAAAAABAHAAAAAAAADQAAAAAAAAC0CQAAAAAAABkAAAAAAAAAqP0BAAAAAAAbAAAAAAAAAAgAAAAAAAAAGgAAAAAAAACw/QEAAAAAABwAAAAAAAAACAAAAAAAAAAEAAAAAAAAAKgCAAAAAAAA9f7/bwAAAADoAgAAAAAAAAUAAAAAAAAAEAQAAAAAAAAGAAAAAAAAAAgDAAAAAAAACgAAAAAAAABkAQAAAAAAAAsAAAAAAAAAGAAAAAAAAAAVAAAAAAAAAAAAAAAAAAAAAwAAAAAAAADo/wEAAAAAAAIAAAAAAAAAkAAAAAAAAAAUAAAAAAAAAAcAAAAAAAAAFwAAAAAAAACABgAAAAAAAAcAAAAAAAAAwAUAAAAAAAAIAAAAAAAAAMAAAAAAAAAACQAAAAAAAAAYAAAAAAAAAPv//28AAAAAAAAACAAAAAD+//9vAAAAAJAFAAAAAAAA////bwAAAAABAAAAAAAAAPD//28AAAAAdAUAAAAAAAD5//9vAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC8U8RIAAIAAA==" ];
            .name = ".dynamic"; .size = 512 };
        { .address = 131000;
            .bytes = "\184\253\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\160\t\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
            .name = ".got"; .size = 48 };
        { .address = 131048;
            .bytes = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\000";
            .name = ".got.plt"; .size = 72 };
        { .address = 131120;
            .bytes = "\000\000\000\000\000\000\000\0008\000\002\000\000\000\000\000";
            .name = ".data"; .size = 16 };
        { .address = 131136; .bytes = ""; .name = ".bss"; .size = 8 } ];
    .invariants = [ "GtirbArm" ] };