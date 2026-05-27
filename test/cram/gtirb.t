
  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/gtirb/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  (dump-il gtirb-output.il)
  (dump-il)
  var $PC:bv64;
  proc @_fini()  -> () {  }
    requires boolor(eq(0x400828:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400828:bv64, $PC);
       assert false { .opcode = "0xd503201f" };
       assert false { .opcode = "0xa9bf7bfd" };
       assert false { .opcode = "0x910003fd" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @_init()  -> () {  }
    requires boolor(eq(0x400600:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400600:bv64, $PC);
       assert false { .opcode = "0xd503201f" };
       assert false { .opcode = "0xa9bf7bfd" };
       assert false { .opcode = "0x910003fd" };
       assert false { .opcode = "0x9400002e" };
       assert boolor(eq(0x4006c4:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x4006c4:bv64, $PC);
       call @call_weak_fn();
       assert boolor(eq(0x400610:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400610:bv64, $PC);
       assert false { .opcode = "0xa8c17bfd" };
       assert false { .opcode = "0xd65f03c0" };
       assert boolor();
       goto (%ret_1);
     ];
     block %ret_1 [ return; ]
  ];
  proc @__do_global_dtors_aux()  -> () {  }
    requires boolor(eq(0x40074c:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x40074c:bv64, $PC);
       assert false { .opcode = "0xa9be7bfd" };
       assert false { .opcode = "0x910003fd" };
       assert false { .opcode = "0xf9000bf3" };
       assert false { .opcode = "0x90000113" };
       assert false { .opcode = "0x3940a260" };
       assert false { .opcode = "0x37000080" };
       assert boolor(eq(0x400770:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400770:bv64, $PC);
       assert false { .opcode = "0xf9400bf3" };
       assert false { .opcode = "0xa8c27bfd" };
       assert false { .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400764:bv64, $PC));
       goto (%ret_2,%gtirb_3);
     ];
     block %gtirb_3 [
       assume eq(0x400764:bv64, $PC);
       assert false { .opcode = "0x97ffffdf" };
       assert boolor(eq(0x4006e0:bv64, $PC));
       goto (%gtirb_5);
     ];
     block %gtirb_5 [
       assume eq(0x4006e0:bv64, $PC);
       call @deregister_tm_clones();
       assert boolor(eq(0x400768:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x400768:bv64, $PC);
       assert false { .opcode = "0x52800020" };
       assert false { .opcode = "0x3900a260" };
       assert boolor();
       unreachable;
     ];
     block %ret_2 [ return; ]
  ];
  proc @register_tm_clones()  -> () {  }
    requires boolor(eq(0x400710:bv64, $PC))
  
  [
     block %gtirb_2 [
       assume eq(0x400710:bv64, $PC);
       assert false { .opcode = "0x90000100" };
       assert false { .opcode = "0x9100a000" };
       assert false { .opcode = "0x90000101" };
       assert false { .opcode = "0x9100a021" };
       assert false { .opcode = "0xcb000021" };
       assert false { .opcode = "0xd37ffc22" };
       assert false { .opcode = "0x8b810c41" };
       assert false { .opcode = "0x9341fc21" };
       assert false { .opcode = "0xb40000c1" };
       assert boolor(eq(0x400748:bv64, $PC));
       goto (%gtirb);
     ];
     block %gtirb [
       assume eq(0x400748:bv64, $PC);
       assert false { .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400734:bv64, $PC), eq(0x400740:bv64, $PC));
       goto (%ret_2,%gtirb_3,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400740:bv64, $PC);
       assert false { .opcode = "0xaa0203f0" };
       assert false { .opcode = "0xd61f0200" };
       assert boolor();
       unreachable;
     ];
     block %gtirb_3 [
       assume eq(0x400734:bv64, $PC);
       assert false { .opcode = "0xf00000e2" };
       assert false { .opcode = "0xf947f042" };
       assert false { .opcode = "0xb4000062" };
       assert boolor(eq(0x400748:bv64, $PC));
       goto (%gtirb);
     ];
     block %ret_2 [ return; ]
  ];
  proc @frame_dummy()  -> () {  }
    requires boolor(eq(0x400780:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400780:bv64, $PC);
       assert false { .opcode = "0x17ffffe4" };
       assert boolor(eq(0x400710:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400710:bv64, $PC);
       call @register_tm_clones();
       assert boolor();
       unreachable;
     ]
  ];
  proc @FUN_400660()  -> () {  }
    requires boolor(eq(0x400660:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400660:bv64, $PC);
       assert false { .opcode = "0x90000110" };
       assert false { .opcode = "0xf9400a11" };
       assert false { .opcode = "0x91004210" };
       assert false { .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @Sqrt()  -> () {  }
    requires boolor(eq(0x400784:bv64, $PC))
  
  [
     block %gtirb_1 [
       assume eq(0x400784:bv64, $PC);
       assert false { .opcode = "0xd100c3ff" };
       assert false { .opcode = "0xf90007e0" };
       assert false { .opcode = "0xf90017ff" };
       assert false { .opcode = "0xf94007e0" };
       assert false { .opcode = "0x91000400" };
       assert false { .opcode = "0xf90013e0" };
       assert false { .opcode = "0x14000013" };
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%gtirb_5);
     ];
     block %gtirb_5 [
       assume eq(0x4007e8:bv64, $PC);
       assert false { .opcode = "0xf94017e0" };
       assert false { .opcode = "0x91000400" };
       assert false { .opcode = "0xf94013e1" };
       assert false { .opcode = "0xeb00003f" };
       assert false { .opcode = "0x54fffd41" };
       assert boolor(eq(0x4007a0:bv64, $PC));
       goto (%gtirb_4);
     ];
     block %gtirb_4 [
       assume eq(0x4007a0:bv64, $PC);
       assert false { .opcode = "0xf94017e1" };
       assert false { .opcode = "0xf94013e0" };
       assert false { .opcode = "0x8b000020" };
       assert false { .opcode = "0xd37ffc01" };
       assert false { .opcode = "0x8b000020" };
       assert false { .opcode = "0x9341fc00" };
       assert false { .opcode = "0xb9001fe0" };
       assert false { .opcode = "0xb9401fe0" };
       assert false { .opcode = "0x1b007c00" };
       assert false { .opcode = "0x93407c00" };
       assert false { .opcode = "0xf94007e1" };
       assert false { .opcode = "0xeb00003f" };
       assert false { .opcode = "0x5400008b" };
       assert boolor(eq(0x4007fc:bv64, $PC), eq(0x4007e0:bv64, $PC));
       goto (%gtirb_3,%gtirb);
     ];
     block %gtirb [
       assume eq(0x4007e0:bv64, $PC);
       assert false { .opcode = "0xb9801fe0" };
       assert false { .opcode = "0xf90013e0" };
       assert boolor(eq(0x4007d4:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x4007d4:bv64, $PC);
       assert false { .opcode = "0xb9801fe0" };
       assert false { .opcode = "0xf90017e0" };
       assert false { .opcode = "0x14000003" };
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%gtirb_5);
     ];
     block %gtirb_3 [
       assume eq(0x4007fc:bv64, $PC);
       assert false { .opcode = "0xf94017e0" };
       assert false { .opcode = "0x9100c3ff" };
       assert false { .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400820:bv64, $PC));
       goto (%ret_3);
     ];
     block %ret_3 [ return; ]
  ];
  proc @_start()  -> () {  }
    requires boolor(eq(0x400680:bv64, $PC))
  
  [
     block %gtirb_2 [
       assume eq(0x400680:bv64, $PC);
       assert false { .opcode = "0xd503201f" };
       assert false { .opcode = "0xd280001d" };
       assert false { .opcode = "0xd280001e" };
       assert false { .opcode = "0xaa0003e5" };
       assert false { .opcode = "0xf94003e1" };
       assert false { .opcode = "0x910023e2" };
       assert false { .opcode = "0x910003e6" };
       assert false { .opcode = "0x90000000" };
       assert false { .opcode = "0x911ad000" };
       assert false { .opcode = "0xd2800003" };
       assert false { .opcode = "0xd2800004" };
       assert false { .opcode = "0x97ffffe5" };
       assert boolor(eq(0x400640:bv64, $PC));
       goto (%gtirb_4);
     ];
     block %gtirb_4 [
       assume eq(0x400640:bv64, $PC);
       call @FUN_400640();
       assert boolor(eq(0x4006b0:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006b0:bv64, $PC);
       assert false { .opcode = "0x97ffffec" };
       assert boolor(eq(0x400660:bv64, $PC));
       goto (%gtirb_6);
     ];
     block %gtirb_6 [
       assume eq(0x400660:bv64, $PC);
       call @FUN_400660();
       assert boolor();
       unreachable;
     ]
  ];
  proc @_dl_relocate_static_pie()  -> () {  }
    requires boolor(eq(0x4006c0:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006c0:bv64, $PC);
       assert false { .opcode = "0xd65f03c0" };
       assert boolor();
       goto (%ret);
     ];
     block %ret [ return; ]
  ];
  proc @call_weak_fn()  -> () {  }
    requires boolor(eq(0x4006c4:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006c4:bv64, $PC);
       assert false { .opcode = "0xf00000e0" };
       assert false { .opcode = "0xf947ec00" };
       assert false { .opcode = "0xb4000040" };
       assert boolor(eq(0x4006d4:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x4006d4:bv64, $PC);
       assert false { .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400610:bv64, $PC), eq(0x4006d0:bv64, $PC));
       goto (%ret_3,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006d0:bv64, $PC);
       assert false { .opcode = "0x17ffffe0" };
       assert boolor(eq(0x400650:bv64, $PC));
       goto (%gtirb_4);
     ];
     block %gtirb_4 [
       assume eq(0x400650:bv64, $PC);
       call @.L_400650();
       assert boolor();
       unreachable;
     ];
     block %ret_3 [ return; ]
  ];
  proc @main()  -> () {  }
    requires boolor(eq(0x400808:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400808:bv64, $PC);
       assert false { .opcode = "0xa9be7bfd" };
       assert false { .opcode = "0x910003fd" };
       assert false { .opcode = "0xb9001fe0" };
       assert false { .opcode = "0xf9000be1" };
       assert false { .opcode = "0xb9801fe0" };
       assert false { .opcode = "0x97ffffda" };
       assert boolor(eq(0x400784:bv64, $PC));
       goto (%gtirb_2);
     ];
     block %gtirb_2 [
       assume eq(0x400784:bv64, $PC);
       call @Sqrt();
       assert boolor(eq(0x400820:bv64, $PC));
       goto (%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x400820:bv64, $PC);
       assert false { .opcode = "0xa8c27bfd" };
       assert false { .opcode = "0xd65f03c0" };
       assert boolor();
       goto (%ret_1);
     ];
     block %ret_1 [ return; ]
  ];
  proc @.L_400650()  -> () {  }
    requires boolor(eq(0x400650:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400650:bv64, $PC);
       assert false { .opcode = "0x90000110" };
       assert false { .opcode = "0xf9400611" };
       assert false { .opcode = "0x91002210" };
       assert false { .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @FUN_400640()  -> () {  }
    requires boolor(eq(0x400640:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400640:bv64, $PC);
       assert false { .opcode = "0x90000110" };
       assert false { .opcode = "0xf9400211" };
       assert false { .opcode = "0x91000210" };
       assert false { .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];
  proc @deregister_tm_clones()  -> () {  }
    requires boolor(eq(0x4006e0:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x4006e0:bv64, $PC);
       assert false { .opcode = "0x90000100" };
       assert false { .opcode = "0x9100a000" };
       assert false { .opcode = "0x90000101" };
       assert false { .opcode = "0x9100a021" };
       assert false { .opcode = "0xeb00003f" };
       assert false { .opcode = "0x540000c0" };
       assert boolor(eq(0x40070c:bv64, $PC));
       goto (%gtirb_3);
     ];
     block %gtirb_3 [
       assume eq(0x40070c:bv64, $PC);
       assert false { .opcode = "0xd65f03c0" };
       assert boolor(eq(0x400768:bv64, $PC), eq(0x400704:bv64, $PC),
        eq(0x4006f8:bv64, $PC));
       goto (%ret_5,%gtirb_2,%gtirb_1);
     ];
     block %gtirb_1 [
       assume eq(0x4006f8:bv64, $PC);
       assert false { .opcode = "0xf00000e1" };
       assert false { .opcode = "0xf947e821" };
       assert false { .opcode = "0xb4000061" };
       assert boolor(eq(0x40070c:bv64, $PC));
       goto (%gtirb_3);
     ];
     block %gtirb_2 [
       assume eq(0x400704:bv64, $PC);
       assert false { .opcode = "0xaa0103f0" };
       assert false { .opcode = "0xd61f0200" };
       assert boolor();
       unreachable;
     ];
     block %ret_5 [ return; ]
  ];
  proc @FUN_400620()  -> () {  }
    requires boolor(eq(0x400620:bv64, $PC))
  
  [
     block %gtirb [
       assume eq(0x400620:bv64, $PC);
       assert false { .opcode = "0xa9bf7bf0" };
       assert false { .opcode = "0xf00000f0" };
       assert false { .opcode = "0xf947fe11" };
       assert false { .opcode = "0x913fe210" };
       assert false { .opcode = "0xd61f0220" };
       assert boolor();
       unreachable;
     ]
  ];(load-il gtirb-output.il)
