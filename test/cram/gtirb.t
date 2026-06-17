
  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/gtirb/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
  > (dump-il "dumped.il")
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  (dump-il gtirb-output.il)
  (dump-il)
  var $PC:bv64;
  proc @_fini()  -> () {  }
    requires boolor(eq(0x400828:bv64, $PC))
  
  [
     block %_fini_code { .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA"; .succ = [  ] } [
       assume eq(0x400828:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32);
       call @_aarch64_eval(0xa9bf7bfd:bv32);
       call @_aarch64_eval(0x910003fd:bv32);
       assert boolor();
       unreachable;
     ]
  ];
  proc @_init()  -> () {  }
    requires boolor(eq(0x400600:bv64, $PC))
  
  [
     block %_init_code { .gtirb_block = "UfNyH7KvQiam2F847lIf0g";
         .succ = [ { .address = 4196036; .conditional = "false"; .direct = "true";
                 .target = "stmts:Djx7L34DQzuSXaBFEj/bpQ"; .type = "Type_Call" } ] } [
       assume eq(0x400600:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32);
       call @_aarch64_eval(0xa9bf7bfd:bv32);
       call @_aarch64_eval(0x910003fd:bv32);
       call @_aarch64_eval(0x9400002e:bv32);
       assert boolor(eq(0x4006c4:bv64, $PC));
       goto (%_init_ext);
     ];
     block %_init_ext [
       assume eq(0x4006c4:bv64, $PC);
       call @call_weak_fn();
       assert boolor(eq(0x400610:bv64, $PC));
       goto (%_init_code_1);
     ];
     block %_init_code_1 { .gtirb_block = "xdU61Ad4R3aE/hVJ17n5eQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400610:bv64, $PC);
       call @_aarch64_eval(0xa8c17bfd:bv32);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor();
       goto (%ret_1);
     ];
     block %ret_1 [ return; ]
  ];
  proc @__do_global_dtors_aux()  -> () {  }
    requires boolor(eq(0x40074c:bv64, $PC))
  
  [
     block %__do_global_dtors_aux_code { .gtirb_block = "D9t2gNJrSmyMH3GAVRe3IQ";
         .succ = [ { .address = 4196208; .conditional = "true"; .direct = "true";
                 .target = "internal:SFN4dpBgSO2bPUu0fyDluw"; .type = "Type_Branch" } ] } [
       assume eq(0x40074c:bv64, $PC);
       call @_aarch64_eval(0xa9be7bfd:bv32);
       call @_aarch64_eval(0x910003fd:bv32);
       call @_aarch64_eval(0xf9000bf3:bv32);
       call @_aarch64_eval(0x90000113:bv32);
       call @_aarch64_eval(0x3940a260:bv32);
       call @_aarch64_eval(0x37000080:bv32);
       assert boolor(eq(0x400770:bv64, $PC));
       goto (%__do_global_dtors_aux_code_1);
     ];
     block %__do_global_dtors_aux_code_1 { .gtirb_block = "SFN4dpBgSO2bPUu0fyDluw";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" };
             { .address = 4196196; .target = "internal:lwyID0MJQb6vgyjzPFtz8Q" } ] } [
       assume eq(0x400770:bv64, $PC);
       call @_aarch64_eval(0xf9400bf3:bv32);
       call @_aarch64_eval(0xa8c27bfd:bv32);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor(eq(0x400764:bv64, $PC));
       goto (%ret_2,%__do_global_dtors_aux_code_3);
     ];
     block %__do_global_dtors_aux_code_3 { .gtirb_block = "lwyID0MJQb6vgyjzPFtz8Q";
         .succ = [ { .address = 4196064; .conditional = "false"; .direct = "true";
                 .target = "stmts:GW0MHC+ORUKlCdpgOcZ6zA"; .type = "Type_Call" } ] } [
       assume eq(0x400764:bv64, $PC);
       call @_aarch64_eval(0x97ffffdf:bv32);
       assert boolor(eq(0x4006e0:bv64, $PC));
       goto (%__do_global_dtors_aux_ext);
     ];
     block %__do_global_dtors_aux_ext [
       assume eq(0x4006e0:bv64, $PC);
       call @deregister_tm_clones();
       assert boolor(eq(0x400768:bv64, $PC));
       goto (%__do_global_dtors_aux_code_2);
     ];
     block %__do_global_dtors_aux_code_2 { .gtirb_block = "TxTRm4kpQiq/Xgistx+xbQ";
         .succ = [  ] } [
       assume eq(0x400768:bv64, $PC);
       call @_aarch64_eval(0x52800020:bv32);
       call @_aarch64_eval(0x3900a260:bv32);
       assert boolor();
       unreachable;
     ];
     block %ret_2 [ return; ]
  ];
  proc @register_tm_clones()  -> () {  }
    requires boolor(eq(0x400710:bv64, $PC))
  
  [
     block %register_tm_clones_code_2 { .gtirb_block = "rIlbG4jGSTydaFqMhxCKWw";
         .succ = [ { .address = 4196168; .conditional = "true"; .direct = "true";
                 .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
       assume eq(0x400710:bv64, $PC);
       call @_aarch64_eval(0x90000100:bv32);
       call @_aarch64_eval(0x9100a000:bv32);
       call @_aarch64_eval(0x90000101:bv32);
       call @_aarch64_eval(0x9100a021:bv32);
       call @_aarch64_eval(0xcb000021:bv32);
       call @_aarch64_eval(0xd37ffc22:bv32);
       call @_aarch64_eval(0x8b810c41:bv32);
       call @_aarch64_eval(0x9341fc21:bv32);
       call @_aarch64_eval(0xb40000c1:bv32);
       assert boolor(eq(0x400748:bv64, $PC));
       goto (%register_tm_clones_code);
     ];
     block %register_tm_clones_code { .gtirb_block = "IkNYmV06TxC75h8A4NM3wA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" };
             { .address = 4196148; .target = "internal:tXIOhSQ+R1WA/9VL5+6KQQ" };
             { .address = 4196160; .target = "internal:oqiqdATZTc6MDOYJqL9Aew" } ] } [
       assume eq(0x400748:bv64, $PC);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor(eq(0x400734:bv64, $PC), eq(0x400740:bv64, $PC));
       goto (%ret_2,%register_tm_clones_code_3,%register_tm_clones_code_1);
     ];
     block %register_tm_clones_code_1 { .gtirb_block = "oqiqdATZTc6MDOYJqL9Aew";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400740:bv64, $PC);
       call @_aarch64_eval(0xaa0203f0:bv32);
       call @_aarch64_eval(0xd61f0200:bv32);
       assert boolor();
       unreachable;
     ];
     block %register_tm_clones_code_3 { .gtirb_block = "tXIOhSQ+R1WA/9VL5+6KQQ";
         .succ = [ { .address = 4196168; .conditional = "true"; .direct = "true";
                 .target = "internal:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Branch" } ] } [
       assume eq(0x400734:bv64, $PC);
       call @_aarch64_eval(0xf00000e2:bv32);
       call @_aarch64_eval(0xf947f042:bv32);
       call @_aarch64_eval(0xb4000062:bv32);
       assert boolor(eq(0x400748:bv64, $PC));
       goto (%register_tm_clones_code);
     ];
     block %ret_2 [ return; ]
  ];
  proc @frame_dummy()  -> () {  }
    requires boolor(eq(0x400780:bv64, $PC))
  
  [
     block %frame_dummy_code { .gtirb_block = "6JJvkaLhTaWXaEL0+yxKxg";
         .succ = [ { .address = 4196112; .conditional = "false"; .direct = "true";
                 .target = "stmts:rIlbG4jGSTydaFqMhxCKWw"; .type = "Type_Branch" } ] } [
       assume eq(0x400780:bv64, $PC);
       call @_aarch64_eval(0x17ffffe4:bv32);
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
    requires boolor(eq(0x400660:bv64, $PC))
  
  [
     block %FUN_400660_code { .gtirb_block = "iedVtPHmSjuLgqSxHgXOuw";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:BsLBdgTFQlOA45HTKKU2gQ"; .type = "Type_Branch" } ] } [
       assume eq(0x400660:bv64, $PC);
       call @_aarch64_eval(0x90000110:bv32);
       call @_aarch64_eval(0xf9400a11:bv32);
       call @_aarch64_eval(0x91004210:bv32);
       call @_aarch64_eval(0xd61f0220:bv32);
       assert boolor();
       unreachable;
     ]
  ];
  proc @Sqrt()  -> () {  }
    requires boolor(eq(0x400784:bv64, $PC))
  
  [
     block %Sqrt_code_1 { .gtirb_block = "OuTzy8qRTci75taVjGinFQ";
         .succ = [ { .address = 4196328; .conditional = "false"; .direct = "true";
                 .target = "internal:32fWxY7+R++JNJOFTmT+Sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400784:bv64, $PC);
       call @_aarch64_eval(0xd100c3ff:bv32);
       call @_aarch64_eval(0xf90007e0:bv32);
       call @_aarch64_eval(0xf90017ff:bv32);
       call @_aarch64_eval(0xf94007e0:bv32);
       call @_aarch64_eval(0x91000400:bv32);
       call @_aarch64_eval(0xf90013e0:bv32);
       call @_aarch64_eval(0x14000013:bv32);
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%Sqrt_code_5);
     ];
     block %Sqrt_code_5 { .gtirb_block = "32fWxY7+R++JNJOFTmT+Sg";
         .succ = [ { .address = 4196256; .conditional = "true"; .direct = "true";
                 .target = "internal:rCSSdLZcRB2TKAu9h+WCqg"; .type = "Type_Branch" } ] } [
       assume eq(0x4007e8:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32);
       call @_aarch64_eval(0x91000400:bv32);
       call @_aarch64_eval(0xf94013e1:bv32);
       call @_aarch64_eval(0xeb00003f:bv32);
       call @_aarch64_eval(0x54fffd41:bv32);
       assert boolor(eq(0x4007a0:bv64, $PC));
       goto (%Sqrt_code_4);
     ];
     block %Sqrt_code_4 { .gtirb_block = "rCSSdLZcRB2TKAu9h+WCqg";
         .succ = [ { .address = 4196348; .target = "internal:lr6o4ptnRiK3TGR1gpiWGg" };
             { .address = 4196320; .conditional = "true"; .direct = "true";
                 .target = "internal:HVqN0/3+RWiLPKsHRvUqeg"; .type = "Type_Branch" } ] } [
       assume eq(0x4007a0:bv64, $PC);
       call @_aarch64_eval(0xf94017e1:bv32);
       call @_aarch64_eval(0xf94013e0:bv32);
       call @_aarch64_eval(0x8b000020:bv32);
       call @_aarch64_eval(0xd37ffc01:bv32);
       call @_aarch64_eval(0x8b000020:bv32);
       call @_aarch64_eval(0x9341fc00:bv32);
       call @_aarch64_eval(0xb9001fe0:bv32);
       call @_aarch64_eval(0xb9401fe0:bv32);
       call @_aarch64_eval(0x1b007c00:bv32);
       call @_aarch64_eval(0x93407c00:bv32);
       call @_aarch64_eval(0xf94007e1:bv32);
       call @_aarch64_eval(0xeb00003f:bv32);
       call @_aarch64_eval(0x5400008b:bv32);
       assert boolor(eq(0x4007fc:bv64, $PC), eq(0x4007e0:bv64, $PC));
       goto (%Sqrt_code_3,%Sqrt_code);
     ];
     block %Sqrt_code { .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
         .succ = [ { .address = 4196308; .target = "internal:ZLfuz7OtTNOS9GLtqSI1gg" } ] } [
       assume eq(0x4007e0:bv64, $PC);
       call @_aarch64_eval(0xb9801fe0:bv32);
       call @_aarch64_eval(0xf90013e0:bv32);
       assert boolor(eq(0x4007d4:bv64, $PC));
       goto (%Sqrt_code_2);
     ];
     block %Sqrt_code_2 { .gtirb_block = "ZLfuz7OtTNOS9GLtqSI1gg";
         .succ = [ { .address = 4196328; .conditional = "false"; .direct = "true";
                 .target = "internal:32fWxY7+R++JNJOFTmT+Sg"; .type = "Type_Branch" } ] } [
       assume eq(0x4007d4:bv64, $PC);
       call @_aarch64_eval(0xb9801fe0:bv32);
       call @_aarch64_eval(0xf90017e0:bv32);
       call @_aarch64_eval(0x14000003:bv32);
       assert boolor(eq(0x4007e8:bv64, $PC));
       goto (%Sqrt_code_5);
     ];
     block %Sqrt_code_3 { .gtirb_block = "lr6o4ptnRiK3TGR1gpiWGg";
         .succ = [ { .address = 4196384; .conditional = "false"; .direct = "true";
                 .target = "external:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Return" } ] } [
       assume eq(0x4007fc:bv64, $PC);
       call @_aarch64_eval(0xf94017e0:bv32);
       call @_aarch64_eval(0x9100c3ff:bv32);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor(eq(0x400820:bv64, $PC));
       goto (%ret_3);
     ];
     block %ret_3 [ return; ]
  ];
  proc @_start()  -> () {  }
    requires boolor(eq(0x400680:bv64, $PC))
  
  [
     block %_start_code_2 { .gtirb_block = "xdHqi8HzTJ+zBYVemlzAtg";
         .succ = [ { .address = 4195904; .conditional = "false"; .direct = "true";
                 .target = "stmts:YmNxI7RsS/6TZy3HTKzvWg"; .type = "Type_Call" } ] } [
       assume eq(0x400680:bv64, $PC);
       call @_aarch64_eval(0xd503201f:bv32);
       call @_aarch64_eval(0xd280001d:bv32);
       call @_aarch64_eval(0xd280001e:bv32);
       call @_aarch64_eval(0xaa0003e5:bv32);
       call @_aarch64_eval(0xf94003e1:bv32);
       call @_aarch64_eval(0x910023e2:bv32);
       call @_aarch64_eval(0x910003e6:bv32);
       call @_aarch64_eval(0x90000000:bv32);
       call @_aarch64_eval(0x911ad000:bv32);
       call @_aarch64_eval(0xd2800003:bv32);
       call @_aarch64_eval(0xd2800004:bv32);
       call @_aarch64_eval(0x97ffffe5:bv32);
       assert boolor(eq(0x400640:bv64, $PC));
       goto (%_start_ext);
     ];
     block %_start_ext [
       assume eq(0x400640:bv64, $PC);
       call @FUN_400640();
       assert boolor(eq(0x4006b0:bv64, $PC));
       goto (%_start_code_1);
     ];
     block %_start_code_1 { .gtirb_block = "t/6C+3O4SbalxMsQ9Vg3LA";
         .succ = [ { .address = 4195936; .conditional = "false"; .direct = "true";
                 .target = "stmts:iedVtPHmSjuLgqSxHgXOuw"; .type = "Type_Call" } ] } [
       assume eq(0x4006b0:bv64, $PC);
       call @_aarch64_eval(0x97ffffec:bv32);
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
    requires boolor(eq(0x4006c0:bv64, $PC))
  
  [
     block %_dl_relocate_static_pie_code { .gtirb_block = "KTHyjTW0SWiGwqylcMDw6Q";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x4006c0:bv64, $PC);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor();
       goto (%ret);
     ];
     block %ret [ return; ]
  ];
  proc @call_weak_fn()  -> () {  }
    requires boolor(eq(0x4006c4:bv64, $PC))
  
  [
     block %call_weak_fn_code { .gtirb_block = "Djx7L34DQzuSXaBFEj/bpQ";
         .succ = [ { .address = 4196052; .conditional = "true"; .direct = "true";
                 .target = "internal:yQ1z8A+IRoSs4MRYTbbghg"; .type = "Type_Branch" } ] } [
       assume eq(0x4006c4:bv64, $PC);
       call @_aarch64_eval(0xf00000e0:bv32);
       call @_aarch64_eval(0xf947ec00:bv32);
       call @_aarch64_eval(0xb4000040:bv32);
       assert boolor(eq(0x4006d4:bv64, $PC));
       goto (%call_weak_fn_code_2);
     ];
     block %call_weak_fn_code_2 { .gtirb_block = "yQ1z8A+IRoSs4MRYTbbghg";
         .succ = [ { .address = 4195856; .conditional = "false"; .direct = "true";
                 .target = "external:xdU61Ad4R3aE/hVJ17n5eQ"; .type = "Type_Return" };
             { .address = 4196048; .target = "internal:fxMAJl44TWOTA8IHVD8V7Q" } ] } [
       assume eq(0x4006d4:bv64, $PC);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor(eq(0x400610:bv64, $PC), eq(0x4006d0:bv64, $PC));
       goto (%ret_3,%call_weak_fn_code_1);
     ];
     block %call_weak_fn_code_1 { .gtirb_block = "fxMAJl44TWOTA8IHVD8V7Q";
         .succ = [ { .address = 4195920; .conditional = "false"; .direct = "true";
                 .target = "stmts:i2bc6yURTw+Pq2nxe63pQA"; .type = "Type_Branch" } ] } [
       assume eq(0x4006d0:bv64, $PC);
       call @_aarch64_eval(0x17ffffe0:bv32);
       assert boolor(eq(0x400650:bv64, $PC));
       goto (%call_weak_fn_ext_1);
     ];
     block %call_weak_fn_ext_1 [
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
     block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
         .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
                 .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
       assume eq(0x400808:bv64, $PC);
       call @_aarch64_eval(0xa9be7bfd:bv32);
       call @_aarch64_eval(0x910003fd:bv32);
       call @_aarch64_eval(0xb9001fe0:bv32);
       call @_aarch64_eval(0xf9000be1:bv32);
       call @_aarch64_eval(0xb9801fe0:bv32);
       call @_aarch64_eval(0x97ffffda:bv32);
       assert boolor(eq(0x400784:bv64, $PC));
       goto (%main_ext);
     ];
     block %main_ext [
       assume eq(0x400784:bv64, $PC);
       call @Sqrt();
       assert boolor(eq(0x400820:bv64, $PC));
       goto (%main_code_1);
     ];
     block %main_code_1 { .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Return" } ] } [
       assume eq(0x400820:bv64, $PC);
       call @_aarch64_eval(0xa8c27bfd:bv32);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor();
       goto (%ret_1);
     ];
     block %ret_1 [ return; ]
  ];
  proc @.L_400650()  -> () {  }
    requires boolor(eq(0x400650:bv64, $PC))
  
  [
     block %L_400650_code { .gtirb_block = "i2bc6yURTw+Pq2nxe63pQA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:QQLF2yhHRgKOi0ouqIEdXw"; .type = "Type_Branch" } ] } [
       assume eq(0x400650:bv64, $PC);
       call @_aarch64_eval(0x90000110:bv32);
       call @_aarch64_eval(0xf9400611:bv32);
       call @_aarch64_eval(0x91002210:bv32);
       call @_aarch64_eval(0xd61f0220:bv32);
       assert boolor();
       unreachable;
     ]
  ];
  proc @FUN_400640()  -> () {  }
    requires boolor(eq(0x400640:bv64, $PC))
  
  [
     block %FUN_400640_code { .gtirb_block = "YmNxI7RsS/6TZy3HTKzvWg";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:3AqniX2CT+OA1g1jJcUzbQ"; .type = "Type_Branch" } ] } [
       assume eq(0x400640:bv64, $PC);
       call @_aarch64_eval(0x90000110:bv32);
       call @_aarch64_eval(0xf9400211:bv32);
       call @_aarch64_eval(0x91000210:bv32);
       call @_aarch64_eval(0xd61f0220:bv32);
       assert boolor();
       unreachable;
     ]
  ];
  proc @deregister_tm_clones()  -> () {  }
    requires boolor(eq(0x4006e0:bv64, $PC))
  
  [
     block %deregister_tm_clones_code { .gtirb_block = "GW0MHC+ORUKlCdpgOcZ6zA";
         .succ = [ { .address = 4196108; .conditional = "true"; .direct = "true";
                 .target = "internal:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Branch" } ] } [
       assume eq(0x4006e0:bv64, $PC);
       call @_aarch64_eval(0x90000100:bv32);
       call @_aarch64_eval(0x9100a000:bv32);
       call @_aarch64_eval(0x90000101:bv32);
       call @_aarch64_eval(0x9100a021:bv32);
       call @_aarch64_eval(0xeb00003f:bv32);
       call @_aarch64_eval(0x540000c0:bv32);
       assert boolor(eq(0x40070c:bv64, $PC));
       goto (%deregister_tm_clones_code_3);
     ];
     block %deregister_tm_clones_code_3 { .gtirb_block = "cdQ2GS2+QhaOa7OUvPWMRQ";
         .succ = [ { .address = 4196200; .conditional = "false"; .direct = "true";
                 .target = "external:TxTRm4kpQiq/Xgistx+xbQ"; .type = "Type_Return" };
             { .address = 4196100; .target = "internal:NfWWPq4PTwyv0VapVhBGag" };
             { .address = 4196088; .target = "internal:GghTYm6bT12tNFmqu0nIjA" } ] } [
       assume eq(0x40070c:bv64, $PC);
       call @_aarch64_eval(0xd65f03c0:bv32);
       assert boolor(eq(0x400768:bv64, $PC), eq(0x400704:bv64, $PC),
        eq(0x4006f8:bv64, $PC));
       goto (%ret_5,%deregister_tm_clones_code_2,%deregister_tm_clones_code_1);
     ];
     block %deregister_tm_clones_code_1 { .gtirb_block = "GghTYm6bT12tNFmqu0nIjA";
         .succ = [ { .address = 4196108; .conditional = "true"; .direct = "true";
                 .target = "internal:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Branch" } ] } [
       assume eq(0x4006f8:bv64, $PC);
       call @_aarch64_eval(0xf00000e1:bv32);
       call @_aarch64_eval(0xf947e821:bv32);
       call @_aarch64_eval(0xb4000061:bv32);
       assert boolor(eq(0x40070c:bv64, $PC));
       goto (%deregister_tm_clones_code_3);
     ];
     block %deregister_tm_clones_code_2 { .gtirb_block = "NfWWPq4PTwyv0VapVhBGag";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400704:bv64, $PC);
       call @_aarch64_eval(0xaa0103f0:bv32);
       call @_aarch64_eval(0xd61f0200:bv32);
       assert boolor();
       unreachable;
     ];
     block %ret_5 [ return; ]
  ];
  proc @FUN_400620()  -> () {  }
    requires boolor(eq(0x400620:bv64, $PC))
  
  [
     block %FUN_400620_code { .gtirb_block = "wtDzxxOjSJeWxzGBUpQYxA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:P8unZs8jR1SVxJeeo8n1sg"; .type = "Type_Branch" } ] } [
       assume eq(0x400620:bv64, $PC);
       call @_aarch64_eval(0xa9bf7bf0:bv32);
       call @_aarch64_eval(0xf00000f0:bv32);
       call @_aarch64_eval(0xf947fe11:bv32);
       call @_aarch64_eval(0x913fe210:bv32);
       call @_aarch64_eval(0xd61f0220:bv32);
       assert boolor();
       unreachable;
     ]
  ];
  prog entry @_start;(load-il gtirb-output.il)
  (dump-il dumped.il)
















  $ diff -u gtirb-output.il dumped.il
  --- gtirb-output.il	2026-06-17 15:02:21.872603587 +1000
  +++ dumped.il	2026-06-17 15:02:21.876603580 +1000
  @@ -1,5 +1,6 @@
   var $PC:bv64;
   proc @_fini()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400828:bv64, $PC))
   
   [
  @@ -13,6 +14,7 @@
      ]
   ];
   proc @_init()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400600:bv64, $PC))
   
   [
  @@ -45,6 +47,7 @@
      block %ret_1 [ return; ]
   ];
   proc @__do_global_dtors_aux()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x40074c:bv64, $PC))
   
   [
  @@ -97,6 +100,7 @@
      block %ret_2 [ return; ]
   ];
   proc @register_tm_clones()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400710:bv64, $PC))
   
   [
  @@ -148,6 +152,7 @@
      block %ret_2 [ return; ]
   ];
   proc @frame_dummy()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400780:bv64, $PC))
   
   [
  @@ -167,6 +172,7 @@
      ]
   ];
   proc @FUN_400660()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400660:bv64, $PC))
   
   [
  @@ -183,6 +189,7 @@
      ]
   ];
   proc @Sqrt()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400784:bv64, $PC))
   
   [
  @@ -264,6 +271,7 @@
      block %ret_3 [ return; ]
   ];
   proc @_start()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400680:bv64, $PC))
   
   [
  @@ -308,6 +316,7 @@
      ]
   ];
   proc @_dl_relocate_static_pie()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x4006c0:bv64, $PC))
   
   [
  @@ -322,6 +331,7 @@
      block %ret [ return; ]
   ];
   proc @call_weak_fn()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x4006c4:bv64, $PC))
   
   [
  @@ -361,6 +371,7 @@
      block %ret_3 [ return; ]
   ];
   proc @main()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400808:bv64, $PC))
   
   [
  @@ -395,6 +406,7 @@
      block %ret_1 [ return; ]
   ];
   proc @.L_400650()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400650:bv64, $PC))
   
   [
  @@ -411,6 +423,7 @@
      ]
   ];
   proc @FUN_400640()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400640:bv64, $PC))
   
   [
  @@ -427,6 +440,7 @@
      ]
   ];
   proc @deregister_tm_clones()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x4006e0:bv64, $PC))
   
   [
  @@ -476,6 +490,7 @@
      block %ret_5 [ return; ]
   ];
   proc @FUN_400620()  -> () {  }
  +  captures $PC:bv64
     requires boolor(eq(0x400620:bv64, $PC))
   
   [
  [1]















