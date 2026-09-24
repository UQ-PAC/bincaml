

  $ boogiewrap claslocnew.bpl
  Boogie program verifier finished with 5 verified, 2 errors
  
  Error: this assertion could not be proved
  271 |     assert (#Gamma_R1_2 && #Gamma_R4_8);
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  
    Execution trace:
      claslocnew.bpl(239,3): b#main_entry
      claslocnew.bpl(245,3): b#phi_4
      claslocnew.bpl(252,3): b#main_loop3_116
      claslocnew.bpl(259,3): b#phi_7
      claslocnew.bpl(269,3): b#main_loop2_110
    
  Error: a precondition for this call could not be proved
  387 |     call #R1_retval_inlined_10, #Gamma_R1_retval_inlined_10, #R2_35, #Gamma_R2_35 := p$snk_at_md_4196484(zero_extend32_32(#R2_3[32:0]), #Gamma_R2_3);
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  
    Related: this is the precondition that could not be proved
    115 |   requires ((#Gamma_R0_in || ($Global_4325432_4325436 == 1bv32)) && ($Global_4325440_4325444 == 1bv32));
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    Execution trace:
      claslocnew.bpl(239,3): b#main_entry
      claslocnew.bpl(245,3): b#phi_4
      claslocnew.bpl(252,3): b#main_loop3_116
      claslocnew.bpl(259,3): b#phi_7
      claslocnew.bpl(269,3): b#main_loop2_110
      claslocnew.bpl(273,3): b#phi_13
      claslocnew.bpl(289,3): b#phi_16
      claslocnew.bpl(308,3): b#main_loop2_98
      claslocnew.bpl(318,3): b#phi_22
      claslocnew.bpl(323,3): b#main_loop2_88
      claslocnew.bpl(329,3): b#phi_27
      claslocnew.bpl(353,3): b#phi_29
      claslocnew.bpl(363,3): b#main_loop1_76
      claslocnew.bpl(373,3): b#phi_36
      claslocnew.bpl(377,3): b#main_loop1_66
    
