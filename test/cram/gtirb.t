
  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
  warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
  (load-gtirb ../../examples/binsearch_sqrt.gtirb)
  (dump-il gtirb-output.il)
  (dump-il)
  var $PC:bv64;
  proc @_fini()  -> () {  }
    requires boolor(eq(0x400828:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400828:bv64, $PC);
       assert false { .asm = "nop"; .opcode = "0xd503201f" };
       assert false { .asm = "stp x29, x30, [sp, #-16]!"; .opcode = "0xa9bf7bfd" };
       assert false { .asm = "mov x29, sp"; .opcode = "0x910003fd" };
       assert boolor(eq(0x400834:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400834:bv64, $PC);
       assert false { .asm = "ldp x29, x30, [sp], #16"; .opcode = "0xa8c17bfd" };
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ]
  ];
  proc @_init()  -> () {  }
    requires boolor(eq(0x400600:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400600:bv64, $PC);
       assert false { .asm = "nop"; .opcode = "0xd503201f" };
       assert false { .asm = "stp x29, x30, [sp, #-16]!"; .opcode = "0xa9bf7bfd" };
       assert false { .asm = "mov x29, sp"; .opcode = "0x910003fd" };
       assert false { .asm = "bl #184"; .opcode = "0x9400002e" };
       assert boolor(eq(0x4006c4:bv64, $PC), eq(0x400610:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400610:bv64, $PC);
       assert false { .asm = "ldp x29, x30, [sp], #16"; .opcode = "0xa8c17bfd" };
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ]
  ];
  proc @__do_global_dtors_aux()  -> () {  }
    requires boolor(eq(0x40074c:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x40074c:bv64, $PC);
       assert false { .asm = "stp x29, x30, [sp, #-32]!"; .opcode = "0xa9be7bfd" };
       assert false { .asm = "mov x29, sp"; .opcode = "0x910003fd" };
       assert false { .asm = "str x19, [sp, #16]"; .opcode = "0xf9000bf3" };
       assert false { .asm = "adrp x19, #131072"; .opcode = "0x90000113" };
       assert false { .asm = "ldrb w0, [x19, #40]"; .opcode = "0x3940a260" };
       assert false { .asm = "tbnz w0, #0, #16"; .opcode = "0x37000080" };
       assert boolor(eq(0x400764:bv64, $PC), eq(0x400770:bv64, $PC));
       goto (%gtirb_3,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400770:bv64, $PC);
       assert false { .asm = "ldr x19, [sp, #16]"; .opcode = "0xf9400bf3" };
       assert false { .asm = "ldp x29, x30, [sp], #32"; .opcode = "0xa8c27bfd" };
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ];
     block %gtirb_3 [
       assume eq(0x400764:bv64, $PC);
       assert false { .asm = "bl #-132"; .opcode = "0x97ffffdf" };
       assert boolor(eq(0x4006e0:bv64, $PC), eq(0x400768:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x400768:bv64, $PC);
       assert false { .asm = "mov w0, #1                          // =0x1";
           .opcode = "0x52800020" };
       assert false { .asm = "strb w0, [x19, #40]"; .opcode = "0x3900a260" };
       assert boolor(eq(0x400770:bv64, $PC));
       goto (%gtirb_1);
     ]
  ];
  proc @register_tm_clones()  -> () {  }
    requires boolor(eq(0x400710:bv64, $PC))
  
  [
     block %gtirb_2 [
       assume eq(0x400710:bv64, $PC);
       assert false { .asm = "adrp x0, #131072"; .opcode = "0x90000100" };
       assert false { .asm = "add x0, x0, #40"; .opcode = "0x9100a000" };
       assert false { .asm = "adrp x1, #131072"; .opcode = "0x90000101" };
       assert false { .asm = "add x1, x1, #40"; .opcode = "0x9100a021" };
       assert false { .asm = "sub x1, x1, x0"; .opcode = "0xcb000021" };
       assert false { .asm = "lsr x2, x1, #63"; .opcode = "0xd37ffc22" };
       assert false { .asm = "add x1, x2, x1, asr #3"; .opcode = "0x8b810c41" };
       assert false { .asm = "asr x1, x1, #1"; .opcode = "0x9341fc21" };
       assert false { .asm = "cbz x1, #24"; .opcode = "0xb40000c1" };
       assert boolor(eq(0x400734:bv64, $PC), eq(0x400748:bv64, $PC));
       goto (%gtirb_3,%gtirb);
     ];
     block %gtirb [
       assume eq(0x400748:bv64, $PC);
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ];
     block %gtirb_3 [
       assume eq(0x400734:bv64, $PC);
       assert false { .asm = "adrp x2, #126976"; .opcode = "0xf00000e2" };
       assert false { .asm = "ldr x2, [x2, #4064]"; .opcode = "0xf947f042" };
       assert false { .asm = "cbz x2, #12"; .opcode = "0xb4000062" };
       assert boolor(eq(0x400740:bv64, $PC), eq(0x400748:bv64, $PC));
       goto (%gtirb_1,%gtirb);
     ];
     block %gtirb_1 [
       assume eq(0x400740:bv64, $PC);
       assert false { .asm = "mov x16, x2"; .opcode = "0xaa0203f0" };
       assert false { .asm = "br x16"; .opcode = "0xd61f0200" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @frame_dummy()  -> () {  }
    requires boolor(eq(0x400780:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400780:bv64, $PC);
       assert false { .asm = "b #-112"; .opcode = "0x17ffffe4" };
       assert boolor(eq(0x400710:bv64, $PC));
       unreachable;
     ]
  ];
  proc @FUN_400660()  -> () {  }
    requires boolor(eq(0x400660:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400660:bv64, $PC);
       assert false { .asm = "adrp x16, #131072"; .opcode = "0x90000110" };
       assert false { .asm = "ldr x17, [x16, #16]"; .opcode = "0xf9400a11" };
       assert false { .asm = "add x16, x16, #16"; .opcode = "0x91004210" };
       assert false { .asm = "br x17"; .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @Sqrt()  -> () {  }
    requires boolor(eq(0x400784:bv64, $PC))
  
  [
     block %gtirb_1 [
       assume eq(0x400784:bv64, $PC);
       assert false { .asm = "sub sp, sp, #48"; .opcode = "0xd100c3ff" };
       assert false { .asm = "str x0, [sp, #8]"; .opcode = "0xf90007e0" };
       assert false { .asm = "str xzr, [sp, #40]"; .opcode = "0xf90017ff" };
       assert false { .asm = "ldr x0, [sp, #8]"; .opcode = "0xf94007e0" };
       assert false { .asm = "add x0, x0, #1"; .opcode = "0x91000400" };
       assert false { .asm = "str x0, [sp, #32]"; .opcode = "0xf90013e0" };
       assert false { .asm = "b #76"; .opcode = "0x14000013" };
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%gtirb_5);
     ];
     block %gtirb_5 [
       assume eq(0x4007e8:bv64, $PC);
       assert false { .asm = "ldr x0, [sp, #40]"; .opcode = "0xf94017e0" };
       assert false { .asm = "add x0, x0, #1"; .opcode = "0x91000400" };
       assert false { .asm = "ldr x1, [sp, #32]"; .opcode = "0xf94013e1" };
       assert false { .asm = "cmp x1, x0"; .opcode = "0xeb00003f" };
       assert false { .asm = "b.ne #-88"; .opcode = "0x54fffd41" };
       assert boolor(eq(0x4007a0:bv64, $PC), eq(0x4007fc:bv64, $PC));
       goto (%gtirb_4,%gtirb_3);
     ];
     block %gtirb_3 [
       assume eq(0x4007fc:bv64, $PC);
       assert false { .asm = "ldr x0, [sp, #40]"; .opcode = "0xf94017e0" };
       assert false { .asm = "add sp, sp, #48"; .opcode = "0x9100c3ff" };
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400820:bv64, $PC));
       return;
     ];
     block %gtirb_4 [
       assume eq(0x4007a0:bv64, $PC);
       assert false { .asm = "ldr x1, [sp, #40]"; .opcode = "0xf94017e1" };
       assert false { .asm = "ldr x0, [sp, #32]"; .opcode = "0xf94013e0" };
       assert false { .asm = "add x0, x1, x0"; .opcode = "0x8b000020" };
       assert false { .asm = "lsr x1, x0, #63"; .opcode = "0xd37ffc01" };
       assert false { .asm = "add x0, x1, x0"; .opcode = "0x8b000020" };
       assert false { .asm = "asr x0, x0, #1"; .opcode = "0x9341fc00" };
       assert false { .asm = "str w0, [sp, #28]"; .opcode = "0xb9001fe0" };
       assert false { .asm = "ldr w0, [sp, #28]"; .opcode = "0xb9401fe0" };
       assert false { .asm = "mul w0, w0, w0"; .opcode = "0x1b007c00" };
       assert false { .asm = "sxtw x0, w0"; .opcode = "0x93407c00" };
       assert false { .asm = "ldr x1, [sp, #8]"; .opcode = "0xf94007e1" };
       assert false { .asm = "cmp x1, x0"; .opcode = "0xeb00003f" };
       assert false { .asm = "b.lt #16"; .opcode = "0x5400008b" };
       assert boolor(eq(0x4007d4:bv64, $PC), eq(0x4007e0:bv64, $PC));
       goto (%gtirb_2,%gtirb);
     ];
     block %gtirb [
       assume eq(0x4007e0:bv64, $PC);
       assert false { .asm = "ldrsw x0, [sp, #28]"; .opcode = "0xb9801fe0" };
       assert false { .asm = "str x0, [sp, #32]"; .opcode = "0xf90013e0" };
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%gtirb_5);
     ];
     block %gtirb_2 [
       assume eq(0x4007d4:bv64, $PC);
       assert false { .asm = "ldrsw x0, [sp, #28]"; .opcode = "0xb9801fe0" };
       assert false { .asm = "str x0, [sp, #40]"; .opcode = "0xf90017e0" };
       assert false { .asm = "b #12"; .opcode = "0x14000003" };
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%gtirb_5);
     ]
  ];
  proc @_start()  -> () {  }
    requires boolor(eq(0x400680:bv64, $PC))
  
  [
     block %gtirb_2 [
       assume eq(0x400680:bv64, $PC);
       assert false { .asm = "nop"; .opcode = "0xd503201f" };
       assert false { .asm = "mov x29, #0                         // =0x0";
           .opcode = "0xd280001d" };
       assert false { .asm = "mov x30, #0                         // =0x0";
           .opcode = "0xd280001e" };
       assert false { .asm = "mov x5, x0"; .opcode = "0xaa0003e5" };
       assert false { .asm = "ldr x1, [sp]"; .opcode = "0xf94003e1" };
       assert false { .asm = "add x2, sp, #8"; .opcode = "0x910023e2" };
       assert false { .asm = "mov x6, sp"; .opcode = "0x910003e6" };
       assert false { .asm = "adrp x0, #0"; .opcode = "0x90000000" };
       assert false { .asm = "add x0, x0, #1716"; .opcode = "0x911ad000" };
       assert false { .asm = "mov x3, #0                          // =0x0";
           .opcode = "0xd2800003" };
       assert false { .asm = "mov x4, #0                          // =0x0";
           .opcode = "0xd2800004" };
       assert false { .asm = "bl #-108"; .opcode = "0x97ffffe5" };
       assert boolor(eq(0x400640:bv64, $PC), eq(0x4006b0:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006b0:bv64, $PC);
       assert false { .asm = "bl #-80"; .opcode = "0x97ffffec" };
       assert boolor(eq(0x400660:bv64, $PC));
       unreachable;
     ]
  ];
  proc @_dl_relocate_static_pie()  -> () {  }
    requires boolor(eq(0x4006c0:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006c0:bv64, $PC);
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ]
  ];
  proc @call_weak_fn()  -> () {  }
    requires boolor(eq(0x4006c4:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006c4:bv64, $PC);
       assert false { .asm = "adrp x0, #126976"; .opcode = "0xf00000e0" };
       assert false { .asm = "ldr x0, [x0, #4056]"; .opcode = "0xf947ec00" };
       assert false { .asm = "cbz x0, #8"; .opcode = "0xb4000040" };
       assert boolor(eq(0x4006d4:bv64, $PC), eq(0x4006d0:bv64, $PC));
       goto (%gtirb_2,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006d0:bv64, $PC);
       assert false { .asm = "b #-128"; .opcode = "0x17ffffe0" };
       assert boolor(eq(0x400650:bv64, $PC));
       unreachable;
     ];
     block %gtirb_2 [
       assume eq(0x4006d4:bv64, $PC);
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400610:bv64, $PC));
       return;
     ]
  ];
  proc @main()  -> () {  }
    requires boolor(eq(0x400808:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400808:bv64, $PC);
       assert false { .asm = "stp x29, x30, [sp, #-32]!"; .opcode = "0xa9be7bfd" };
       assert false { .asm = "mov x29, sp"; .opcode = "0x910003fd" };
       assert false { .asm = "str w0, [sp, #28]"; .opcode = "0xb9001fe0" };
       assert false { .asm = "str x1, [sp, #16]"; .opcode = "0xf9000be1" };
       assert false { .asm = "ldrsw x0, [sp, #28]"; .opcode = "0xb9801fe0" };
       assert false { .asm = "bl #-152"; .opcode = "0x97ffffda" };
       assert boolor(eq(0x400784:bv64, $PC), eq(0x400820:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400820:bv64, $PC);
       assert false { .asm = "ldp x29, x30, [sp], #32"; .opcode = "0xa8c27bfd" };
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor();
       return;
     ]
  ];
  proc @.L_400650()  -> () {  }
    requires boolor(eq(0x400650:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400650:bv64, $PC);
       assert false { .asm = "adrp x16, #131072"; .opcode = "0x90000110" };
       assert false { .asm = "ldr x17, [x16, #8]"; .opcode = "0xf9400611" };
       assert false { .asm = "add x16, x16, #8"; .opcode = "0x91002210" };
       assert false { .asm = "br x17"; .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @FUN_400640()  -> () {  }
    requires boolor(eq(0x400640:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400640:bv64, $PC);
       assert false { .asm = "adrp x16, #131072"; .opcode = "0x90000110" };
       assert false { .asm = "ldr x17, [x16]"; .opcode = "0xf9400211" };
       assert false { .asm = "add x16, x16, #0"; .opcode = "0x91000210" };
       assert false { .asm = "br x17"; .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @deregister_tm_clones()  -> () {  }
    requires boolor(eq(0x4006e0:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006e0:bv64, $PC);
       assert false { .asm = "adrp x0, #131072"; .opcode = "0x90000100" };
       assert false { .asm = "add x0, x0, #40"; .opcode = "0x9100a000" };
       assert false { .asm = "adrp x1, #131072"; .opcode = "0x90000101" };
       assert false { .asm = "add x1, x1, #40"; .opcode = "0x9100a021" };
       assert false { .asm = "cmp x1, x0"; .opcode = "0xeb00003f" };
       assert false { .asm = "b.eq #24"; .opcode = "0x540000c0" };
       assert boolor(eq(0x40070c:bv64, $PC), eq(0x4006f8:bv64, $PC));
       goto (%gtirb_3,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006f8:bv64, $PC);
       assert false { .asm = "adrp x1, #126976"; .opcode = "0xf00000e1" };
       assert false { .asm = "ldr x1, [x1, #4048]"; .opcode = "0xf947e821" };
       assert false { .asm = "cbz x1, #12"; .opcode = "0xb4000061" };
       assert boolor(eq(0x40070c:bv64, $PC), eq(0x400704:bv64, $PC));
       goto (%gtirb_3,%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x400704:bv64, $PC);
       assert false { .asm = "mov x16, x1"; .opcode = "0xaa0103f0" };
       assert false { .asm = "br x16"; .opcode = "0xd61f0200" };
       assert boolor();
       unreachable;
     ];
     block %gtirb_3 [
       assume eq(0x40070c:bv64, $PC);
       assert false { .asm = "ret"; .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400768:bv64, $PC));
       return;
     ]
  ];
  proc @FUN_400620()  -> () {  }
    requires boolor(eq(0x400620:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400620:bv64, $PC);
       assert false { .asm = "stp x16, x30, [sp, #-16]!"; .opcode = "0xa9bf7bf0" };
       assert false { .asm = "adrp x16, #126976"; .opcode = "0xf00000f0" };
       assert false { .asm = "ldr x17, [x16, #4088]"; .opcode = "0xf947fe11" };
       assert false { .asm = "add x16, x16, #4088"; .opcode = "0x913fe210" };
       assert false { .asm = "br x17"; .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];(load-il gtirb-output.il)
