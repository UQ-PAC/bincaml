  $ bincaml script branch_conditions.sexp
  (load-il branch_conditions.il)
  (run-transforms aslp-semantics)
  (dump-il branch_conditions_pre.il)
  (run-transforms branch-conditions)
  (dump-il branch_conditions_post.il)

  $ diff branch_conditions_pre.il branch_conditions_post.il | grep -v -- '---' | sed 's/^[^<>].*//'
  
  <    block %block_2 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_2:bv64; goto (%block_4); ];
  <    block %block_3 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_3:bv64; goto (%block_4); ];
  >    block %block_2 [ assume eq($R3, $R4); $R0:bv64 := local_2:bv64; goto (%block_4); ];
  >    block %block_3 [ assume boolnot(eq($R3, $R4)); $R0:bv64 := local_3:bv64; goto (%block_4); ];
  
  <    block %block_6 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_4:bv64; goto (%block_8); ];
  <    block %block_7 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_5:bv64; goto (%block_8); ];
  >    block %block_6 [ assume boolnot(eq($R3, $R4)); $R0:bv64 := local_4:bv64; goto (%block_8); ];
  >    block %block_7 [ assume eq($R3, $R4); $R0:bv64 := local_5:bv64; goto (%block_8); ];
  
  <    block %block_10 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_6:bv64; goto (%block_12); ];
  <    block %block_11 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_7:bv64; goto (%block_12); ];
  >    block %block_10 [ assume bvule($R4, $R3); $R0:bv64 := local_6:bv64; goto (%block_12); ];
  >    block %block_11 [ assume bvult($R3, $R4); $R0:bv64 := local_7:bv64; goto (%block_12); ];
  
  <    block %block_14 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_8:bv64; goto (%block_16); ];
  <    block %block_15 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_9:bv64; goto (%block_16); ];
  >    block %block_14 [ assume bvult($R3, $R4); $R0:bv64 := local_8:bv64; goto (%block_16); ];
  >    block %block_15 [ assume bvule($R4, $R3); $R0:bv64 := local_9:bv64; goto (%block_16); ];
  
  <    block %block_18 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_10:bv64; goto (%block_20); ];
  <    block %block_19 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_11:bv64; goto (%block_20); ];
  >    block %block_18 [ assume bvslt(bvsub($R3, $R4), 0x0:bv64); $R0:bv64 := local_10:bv64; goto (%block_20); ];
  >    block %block_19 [ assume bvsle(0x0:bv64, bvsub($R3, $R4)); $R0:bv64 := local_11:bv64; goto (%block_20); ];
  
  <    block %block_22 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_12:bv64; goto (%block_24); ];
  <    block %block_23 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_13:bv64; goto (%block_24); ];
  >    block %block_22 [ assume bvsle(0x0:bv64, bvsub($R3, $R4)); $R0:bv64 := local_12:bv64; goto (%block_24); ];
  >    block %block_23 [ assume bvslt(bvsub($R3, $R4), 0x0:bv64); $R0:bv64 := local_13:bv64; goto (%block_24); ];
  
  <    block %block_34 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_18:bv64;
  <      goto (%block_36);
  <    ];
  <    block %block_35 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_19:bv64;
  <      goto (%block_36);
  <    ];
  >    block %block_34 [ assume bvult($R4, $R3); $R0:bv64 := local_18:bv64; goto (%block_36); ];
  >    block %block_35 [ assume bvule($R3, $R4); $R0:bv64 := local_19:bv64; goto (%block_36); ];
  
  <    block %block_38 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_20:bv64;
  <      goto (%block_40);
  <    ];
  <    block %block_39 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_21:bv64;
  <      goto (%block_40);
  <    ];
  >    block %block_38 [ assume bvule($R3, $R4); $R0:bv64 := local_20:bv64; goto (%block_40); ];
  >    block %block_39 [ assume bvult($R4, $R3); $R0:bv64 := local_21:bv64; goto (%block_40); ];
  
  <    block %block_42 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_22:bv64; goto (%block_44); ];
  <    block %block_43 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_23:bv64; goto (%block_44); ];
  >    block %block_42 [ assume bvsle($R4, $R3); $R0:bv64 := local_22:bv64; goto (%block_44); ];
  >    block %block_43 [ assume bvslt($R3, $R4); $R0:bv64 := local_23:bv64; goto (%block_44); ];
  
  <    block %block_46 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_24:bv64; goto (%block_48); ];
  <    block %block_47 [ assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V))); $R0:bv64 := local_25:bv64; goto (%block_48); ];
  >    block %block_46 [ assume bvslt($R3, $R4); $R0:bv64 := local_24:bv64; goto (%block_48); ];
  >    block %block_47 [ assume bvsle($R4, $R3); $R0:bv64 := local_25:bv64; goto (%block_48); ];
  
  <    block %block_50 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_26:bv64;
  <      goto (%block_52);
  <    ];
  <    block %block_51 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_27:bv64;
  <      goto (%block_52);
  <    ];
  >    block %block_50 [ assume bvslt($R4, $R3); $R0:bv64 := local_26:bv64; goto (%block_52); ];
  >    block %block_51 [ assume bvsle($R3, $R4); $R0:bv64 := local_27:bv64; goto (%block_52); ];
  
  <    block %block_54 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_28:bv64;
  <      goto (%block_56);
  <    ];
  <    block %block_55 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_29:bv64;
  <      goto (%block_56);
  <    ];
  >    block %block_54 [ assume bvsle($R3, $R4); $R0:bv64 := local_28:bv64; goto (%block_56); ];
  >    block %block_55 [ assume bvslt($R4, $R3); $R0:bv64 := local_29:bv64; goto (%block_56); ];
  
  <    block %block_59 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_32:bv64; goto (%block_61); ];
  <    block %block_60 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_33:bv64; goto (%block_61); ];
  >    block %block_59 [ assume eq($R3, 0x0:bv64); $R0:bv64 := local_32:bv64; goto (%block_61); ];
  >    block %block_60 [ assume boolnot(eq($R3, 0x0:bv64)); $R0:bv64 := local_33:bv64; goto (%block_61); ];
  
  <    block %block_63 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_34:bv64; goto (%block_65); ];
  <    block %block_64 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_35:bv64; goto (%block_65); ];
  >    block %block_63 [ assume boolnot(eq($R3, 0x0:bv64)); $R0:bv64 := local_34:bv64; goto (%block_65); ];
  >    block %block_64 [ assume eq($R3, 0x0:bv64); $R0:bv64 := local_35:bv64; goto (%block_65); ];
  
  <    block %block_67 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_36:bv64; goto (%block_69); ];
  <    block %block_68 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_37:bv64; goto (%block_69); ];
  >    block %block_67 [ assume true; $R0:bv64 := local_36:bv64; goto (%block_69); ];
  >    block %block_68 [ assume false; $R0:bv64 := local_37:bv64; goto (%block_69); ];
  
  <    block %block_71 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_38:bv64; goto (%block_73); ];
  <    block %block_72 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_39:bv64; goto (%block_73); ];
  >    block %block_71 [ assume false; $R0:bv64 := local_38:bv64; goto (%block_73); ];
  >    block %block_72 [ assume true; $R0:bv64 := local_39:bv64; goto (%block_73); ];
  
  <    block %block_75 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_40:bv64; goto (%block_77); ];
  <    block %block_76 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_41:bv64; goto (%block_77); ];
  >    block %block_75 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_40:bv64; goto (%block_77); ];
  >    block %block_76 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_41:bv64; goto (%block_77); ];
  
  <    block %block_79 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_42:bv64; goto (%block_81); ];
  <    block %block_80 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_43:bv64; goto (%block_81); ];
  >    block %block_79 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_42:bv64; goto (%block_81); ];
  >    block %block_80 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_43:bv64; goto (%block_81); ];
  
  <    block %block_83 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_44:bv64; goto (%block_85); ];
  <    block %block_84 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_45:bv64; goto (%block_85); ];
  >    block %block_83 [ assume false; $R0:bv64 := local_44:bv64; goto (%block_85); ];
  >    block %block_84 [ assume true; $R0:bv64 := local_45:bv64; goto (%block_85); ];
  
  <    block %block_87 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_46:bv64; goto (%block_89); ];
  <    block %block_88 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_47:bv64; goto (%block_89); ];
  >    block %block_87 [ assume true; $R0:bv64 := local_46:bv64; goto (%block_89); ];
  >    block %block_88 [ assume false; $R0:bv64 := local_47:bv64; goto (%block_89); ];
  
  <    block %block_91 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_48:bv64;
  <      goto (%block_93);
  <    ];
  <    block %block_92 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_49:bv64;
  <      goto (%block_93);
  <    ];
  >    block %block_91 [ assume bvult(0x0:bv64, $R3); $R0:bv64 := local_48:bv64; goto (%block_93); ];
  >    block %block_92 [ assume bvule($R3, 0x0:bv64); $R0:bv64 := local_49:bv64; goto (%block_93); ];
  
  <    block %block_95 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_50:bv64;
  <      goto (%block_97);
  <    ];
  <    block %block_96 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_51:bv64;
  <      goto (%block_97);
  <    ];
  >    block %block_95 [ assume bvule($R3, 0x0:bv64); $R0:bv64 := local_50:bv64; goto (%block_97); ];
  >    block %block_96 [ assume bvult(0x0:bv64, $R3); $R0:bv64 := local_51:bv64; goto (%block_97); ];
  
  <    block %block_99 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_52:bv64; goto (%block_101); ];
  <    block %block_100 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_53:bv64; goto (%block_101); ];
  >    block %block_99 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_52:bv64; goto (%block_101); ];
  >    block %block_100 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_53:bv64; goto (%block_101); ];
  
  <    block %block_103 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_54:bv64; goto (%block_105); ];
  <    block %block_104 [ assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V))); $R0:bv64 := local_55:bv64; goto (%block_105); ];
  >    block %block_103 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_54:bv64; goto (%block_105); ];
  >    block %block_104 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_55:bv64; goto (%block_105); ];
  
  <    block %block_107 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_56:bv64;
  <      goto (%block_109);
  <    ];
  <    block %block_108 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_57:bv64;
  <      goto (%block_109);
  <    ];
  >    block %block_107 [ assume bvslt(0x0:bv64, $R3); $R0:bv64 := local_56:bv64; goto (%block_109); ];
  >    block %block_108 [ assume bvsle($R3, 0x0:bv64); $R0:bv64 := local_57:bv64; goto (%block_109); ];
  
  <    block %block_111 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_58:bv64;
  <      goto (%block_113);
  <    ];
  <    block %block_112 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_59:bv64;
  <      goto (%block_113);
  <    ];
  >    block %block_111 [ assume bvsle($R3, 0x0:bv64); $R0:bv64 := local_58:bv64; goto (%block_113); ];
  >    block %block_112 [ assume bvslt(0x0:bv64, $R3); $R0:bv64 := local_59:bv64; goto (%block_113); ];
  
  <    block %block_116 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_62:bv64; goto (%block_118); ];
  <    block %block_117 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_63:bv64; goto (%block_118); ];
  >    block %block_116 [ assume eq($R3, 0x1:bv64); $R0:bv64 := local_62:bv64; goto (%block_118); ];
  >    block %block_117 [ assume boolnot(eq($R3, 0x1:bv64)); $R0:bv64 := local_63:bv64; goto (%block_118); ];
  
  <    block %block_120 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_64:bv64; goto (%block_122); ];
  <    block %block_121 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_65:bv64; goto (%block_122); ];
  >    block %block_120 [ assume boolnot(eq($R3, 0x1:bv64)); $R0:bv64 := local_64:bv64; goto (%block_122); ];
  >    block %block_121 [ assume eq($R3, 0x1:bv64); $R0:bv64 := local_65:bv64; goto (%block_122); ];
  
  <    block %block_124 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_66:bv64; goto (%block_126); ];
  <    block %block_125 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_67:bv64; goto (%block_126); ];
  >    block %block_124 [ assume bvule(0x1:bv64, $R3); $R0:bv64 := local_66:bv64; goto (%block_126); ];
  >    block %block_125 [ assume bvult($R3, 0x1:bv64); $R0:bv64 := local_67:bv64; goto (%block_126); ];
  
  <    block %block_128 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_68:bv64; goto (%block_130); ];
  <    block %block_129 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_69:bv64; goto (%block_130); ];
  >    block %block_128 [ assume bvult($R3, 0x1:bv64); $R0:bv64 := local_68:bv64; goto (%block_130); ];
  >    block %block_129 [ assume bvule(0x1:bv64, $R3); $R0:bv64 := local_69:bv64; goto (%block_130); ];
  
  <    block %block_132 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_70:bv64; goto (%block_134); ];
  <    block %block_133 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_71:bv64; goto (%block_134); ];
  >    block %block_132 [ assume bvslt(bvsub($R3, 0x1:bv64), 0x0:bv64); $R0:bv64 := local_70:bv64; goto (%block_134); ];
  >    block %block_133 [ assume bvsle(0x0:bv64, bvsub($R3, 0x1:bv64)); $R0:bv64 := local_71:bv64; goto (%block_134); ];
  
  <    block %block_136 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_72:bv64; goto (%block_138); ];
  <    block %block_137 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_73:bv64; goto (%block_138); ];
  >    block %block_136 [ assume bvsle(0x0:bv64, bvsub($R3, 0x1:bv64)); $R0:bv64 := local_72:bv64; goto (%block_138); ];
  >    block %block_137 [ assume bvslt(bvsub($R3, 0x1:bv64), 0x0:bv64); $R0:bv64 := local_73:bv64; goto (%block_138); ];
  
  <    block %block_148 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_78:bv64;
  <      goto (%block_150);
  <    ];
  <    block %block_149 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_79:bv64;
  <      goto (%block_150);
  <    ];
  >    block %block_148 [ assume bvult(0x1:bv64, $R3); $R0:bv64 := local_78:bv64; goto (%block_150); ];
  >    block %block_149 [ assume bvule($R3, 0x1:bv64); $R0:bv64 := local_79:bv64; goto (%block_150); ];
  
  <    block %block_152 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_80:bv64;
  <      goto (%block_154);
  <    ];
  <    block %block_153 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_81:bv64;
  <      goto (%block_154);
  <    ];
  >    block %block_152 [ assume bvule($R3, 0x1:bv64); $R0:bv64 := local_80:bv64; goto (%block_154); ];
  >    block %block_153 [ assume bvult(0x1:bv64, $R3); $R0:bv64 := local_81:bv64; goto (%block_154); ];
  
  <    block %block_156 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_82:bv64; goto (%block_158); ];
  <    block %block_157 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_83:bv64; goto (%block_158); ];
  >    block %block_156 [ assume bvsle(0x1:bv64, $R3); $R0:bv64 := local_82:bv64; goto (%block_158); ];
  >    block %block_157 [ assume bvslt($R3, 0x1:bv64); $R0:bv64 := local_83:bv64; goto (%block_158); ];
  
  <    block %block_160 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_84:bv64; goto (%block_162); ];
  <    block %block_161 [ assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V))); $R0:bv64 := local_85:bv64; goto (%block_162); ];
  >    block %block_160 [ assume bvslt($R3, 0x1:bv64); $R0:bv64 := local_84:bv64; goto (%block_162); ];
  >    block %block_161 [ assume bvsle(0x1:bv64, $R3); $R0:bv64 := local_85:bv64; goto (%block_162); ];
  
  <    block %block_164 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_86:bv64;
  <      goto (%block_166);
  <    ];
  <    block %block_165 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_87:bv64;
  <      goto (%block_166);
  <    ];
  >    block %block_164 [ assume bvslt(0x1:bv64, $R3); $R0:bv64 := local_86:bv64; goto (%block_166); ];
  >    block %block_165 [ assume bvsle($R3, 0x1:bv64); $R0:bv64 := local_87:bv64; goto (%block_166); ];
  
  <    block %block_168 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_88:bv64;
  <      goto (%block_170);
  <    ];
  <    block %block_169 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_89:bv64;
  <      goto (%block_170);
  <    ];
  >    block %block_168 [ assume bvsle($R3, 0x1:bv64); $R0:bv64 := local_88:bv64; goto (%block_170); ];
  >    block %block_169 [ assume bvslt(0x1:bv64, $R3); $R0:bv64 := local_89:bv64; goto (%block_170); ];
  
  <    block %block_173 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_92:bv64; goto (%block_175); ];
  <    block %block_174 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_93:bv64; goto (%block_175); ];
  >    block %block_173 [ assume eq($R3, bvneg($R4)); $R0:bv64 := local_92:bv64; goto (%block_175); ];
  >    block %block_174 [ assume boolnot(eq($R3, bvneg($R4))); $R0:bv64 := local_93:bv64; goto (%block_175); ];
  
  <    block %block_177 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_94:bv64; goto (%block_179); ];
  <    block %block_178 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_95:bv64; goto (%block_179); ];
  >    block %block_177 [ assume boolnot(eq($R3, bvneg($R4))); $R0:bv64 := local_94:bv64; goto (%block_179); ];
  >    block %block_178 [ assume eq($R3, bvneg($R4)); $R0:bv64 := local_95:bv64; goto (%block_179); ];
  
  <    block %block_181 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_96:bv64; goto (%block_183); ];
  <    block %block_182 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_97:bv64; goto (%block_183); ];
  >    block %block_181 [ assume bvule(bvneg($R4), $R3); $R0:bv64 := local_96:bv64; goto (%block_183); ];
  >    block %block_182 [ assume bvult($R3, bvneg($R4)); $R0:bv64 := local_97:bv64; goto (%block_183); ];
  
  <    block %block_185 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_98:bv64; goto (%block_187); ];
  <    block %block_186 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_99:bv64; goto (%block_187); ];
  >    block %block_185 [ assume bvult($R3, bvneg($R4)); $R0:bv64 := local_98:bv64; goto (%block_187); ];
  >    block %block_186 [ assume bvule(bvneg($R4), $R3); $R0:bv64 := local_99:bv64; goto (%block_187); ];
  
  <    block %block_189 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_100:bv64; goto (%block_191); ];
  <    block %block_190 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_101:bv64; goto (%block_191); ];
  >    block %block_189 [ assume bvslt(bvadd($R3, $R4), 0x0:bv64); $R0:bv64 := local_100:bv64; goto (%block_191); ];
  >    block %block_190 [ assume bvsle(0x0:bv64, bvadd($R3, $R4)); $R0:bv64 := local_101:bv64; goto (%block_191); ];
  
  <    block %block_193 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_102:bv64; goto (%block_195); ];
  <    block %block_194 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_103:bv64; goto (%block_195); ];
  >    block %block_193 [ assume bvsle(0x0:bv64, bvadd($R3, $R4)); $R0:bv64 := local_102:bv64; goto (%block_195); ];
  >    block %block_194 [ assume bvslt(bvadd($R3, $R4), 0x0:bv64); $R0:bv64 := local_103:bv64; goto (%block_195); ];
  
  <    block %block_205 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_108:bv64;
  <      goto (%block_207);
  <    ];
  <    block %block_206 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_109:bv64;
  <      goto (%block_207);
  <    ];
  >    block %block_205 [ assume bvult(bvneg($R4), $R3); $R0:bv64 := local_108:bv64; goto (%block_207); ];
  >    block %block_206 [ assume bvule($R3, bvneg($R4)); $R0:bv64 := local_109:bv64; goto (%block_207); ];
  
  <    block %block_209 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_110:bv64;
  <      goto (%block_211);
  <    ];
  <    block %block_210 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_111:bv64;
  <      goto (%block_211);
  <    ];
  >    block %block_209 [ assume bvule($R3, bvneg($R4)); $R0:bv64 := local_110:bv64; goto (%block_211); ];
  >    block %block_210 [ assume bvult(bvneg($R4), $R3); $R0:bv64 := local_111:bv64; goto (%block_211); ];
  
  <    block %block_213 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_112:bv64; goto (%block_215); ];
  <    block %block_214 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_113:bv64; goto (%block_215); ];
  >    block %block_213 [ assume bvsle(bvneg($R4), $R3); $R0:bv64 := local_112:bv64; goto (%block_215); ];
  >    block %block_214 [ assume bvslt($R3, bvneg($R4)); $R0:bv64 := local_113:bv64; goto (%block_215); ];
  
  <    block %block_217 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_114:bv64; goto (%block_219); ];
  <    block %block_218 [
  <      assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
  <      $R0:bv64 := local_115:bv64;
  <      goto (%block_219);
  <    ];
  >    block %block_217 [ assume bvslt($R3, bvneg($R4)); $R0:bv64 := local_114:bv64; goto (%block_219); ];
  >    block %block_218 [ assume bvsle(bvneg($R4), $R3); $R0:bv64 := local_115:bv64; goto (%block_219); ];
  
  <    block %block_221 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_116:bv64;
  <      goto (%block_223);
  <    ];
  <    block %block_222 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_117:bv64;
  <      goto (%block_223);
  <    ];
  >    block %block_221 [ assume bvslt(bvneg($R4), $R3); $R0:bv64 := local_116:bv64; goto (%block_223); ];
  >    block %block_222 [ assume bvsle($R3, bvneg($R4)); $R0:bv64 := local_117:bv64; goto (%block_223); ];
  
  <    block %block_225 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_118:bv64;
  <      goto (%block_227);
  <    ];
  <    block %block_226 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_119:bv64;
  <      goto (%block_227);
  <    ];
  >    block %block_225 [ assume bvsle($R3, bvneg($R4)); $R0:bv64 := local_118:bv64; goto (%block_227); ];
  >    block %block_226 [ assume bvslt(bvneg($R4), $R3); $R0:bv64 := local_119:bv64; goto (%block_227); ];
  
  <    block %block_230 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_122:bv64; goto (%block_232); ];
  <    block %block_231 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_123:bv64; goto (%block_232); ];
  >    block %block_230 [ assume eq($R3, 0x0:bv64); $R0:bv64 := local_122:bv64; goto (%block_232); ];
  >    block %block_231 [ assume boolnot(eq($R3, 0x0:bv64)); $R0:bv64 := local_123:bv64; goto (%block_232); ];
  
  <    block %block_234 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_124:bv64; goto (%block_236); ];
  <    block %block_235 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_125:bv64; goto (%block_236); ];
  >    block %block_234 [ assume boolnot(eq($R3, 0x0:bv64)); $R0:bv64 := local_124:bv64; goto (%block_236); ];
  >    block %block_235 [ assume eq($R3, 0x0:bv64); $R0:bv64 := local_125:bv64; goto (%block_236); ];
  
  <    block %block_238 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_126:bv64; goto (%block_240); ];
  <    block %block_239 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_127:bv64; goto (%block_240); ];
  >    block %block_238 [ assume false; $R0:bv64 := local_126:bv64; goto (%block_240); ];
  >    block %block_239 [ assume true; $R0:bv64 := local_127:bv64; goto (%block_240); ];
  
  <    block %block_242 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_128:bv64; goto (%block_244); ];
  <    block %block_243 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_129:bv64; goto (%block_244); ];
  >    block %block_242 [ assume true; $R0:bv64 := local_128:bv64; goto (%block_244); ];
  >    block %block_243 [ assume false; $R0:bv64 := local_129:bv64; goto (%block_244); ];
  
  <    block %block_246 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_130:bv64; goto (%block_248); ];
  <    block %block_247 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_131:bv64; goto (%block_248); ];
  >    block %block_246 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_130:bv64; goto (%block_248); ];
  >    block %block_247 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_131:bv64; goto (%block_248); ];
  
  <    block %block_250 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_132:bv64; goto (%block_252); ];
  <    block %block_251 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_133:bv64; goto (%block_252); ];
  >    block %block_250 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_132:bv64; goto (%block_252); ];
  >    block %block_251 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_133:bv64; goto (%block_252); ];
  
  <    block %block_254 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_134:bv64; goto (%block_256); ];
  <    block %block_255 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_135:bv64; goto (%block_256); ];
  >    block %block_254 [ assume false; $R0:bv64 := local_134:bv64; goto (%block_256); ];
  >    block %block_255 [ assume true; $R0:bv64 := local_135:bv64; goto (%block_256); ];
  
  <    block %block_258 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_136:bv64; goto (%block_260); ];
  <    block %block_259 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_137:bv64; goto (%block_260); ];
  >    block %block_258 [ assume true; $R0:bv64 := local_136:bv64; goto (%block_260); ];
  >    block %block_259 [ assume false; $R0:bv64 := local_137:bv64; goto (%block_260); ];
  
  <    block %block_262 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_138:bv64;
  <      goto (%block_264);
  <    ];
  <    block %block_263 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_139:bv64;
  <      goto (%block_264);
  <    ];
  >    block %block_262 [ assume false; $R0:bv64 := local_138:bv64; goto (%block_264); ];
  >    block %block_263 [ assume true; $R0:bv64 := local_139:bv64; goto (%block_264); ];
  
  <    block %block_266 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_140:bv64;
  <      goto (%block_268);
  <    ];
  <    block %block_267 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_141:bv64;
  <      goto (%block_268);
  <    ];
  >    block %block_266 [ assume true; $R0:bv64 := local_140:bv64; goto (%block_268); ];
  >    block %block_267 [ assume false; $R0:bv64 := local_141:bv64; goto (%block_268); ];
  
  <    block %block_270 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_142:bv64; goto (%block_272); ];
  <    block %block_271 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_143:bv64; goto (%block_272); ];
  >    block %block_270 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_142:bv64; goto (%block_272); ];
  >    block %block_271 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_143:bv64; goto (%block_272); ];
  
  <    block %block_274 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_144:bv64; goto (%block_276); ];
  <    block %block_275 [
  <      assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
  <      $R0:bv64 := local_145:bv64;
  <      goto (%block_276);
  <    ];
  >    block %block_274 [ assume bvslt($R3, 0x0:bv64); $R0:bv64 := local_144:bv64; goto (%block_276); ];
  >    block %block_275 [ assume bvsle(0x0:bv64, $R3); $R0:bv64 := local_145:bv64; goto (%block_276); ];
  
  <    block %block_278 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_146:bv64;
  <      goto (%block_280);
  <    ];
  <    block %block_279 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_147:bv64;
  <      goto (%block_280);
  <    ];
  >    block %block_278 [ assume bvslt(0x0:bv64, $R3); $R0:bv64 := local_146:bv64; goto (%block_280); ];
  >    block %block_279 [ assume bvsle($R3, 0x0:bv64); $R0:bv64 := local_147:bv64; goto (%block_280); ];
  
  <    block %block_282 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_148:bv64;
  <      goto (%block_284);
  <    ];
  <    block %block_283 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_149:bv64;
  <      goto (%block_284);
  <    ];
  >    block %block_282 [ assume bvsle($R3, 0x0:bv64); $R0:bv64 := local_148:bv64; goto (%block_284); ];
  >    block %block_283 [ assume bvslt(0x0:bv64, $R3); $R0:bv64 := local_149:bv64; goto (%block_284); ];
  
  <    block %block_287 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_152:bv64; goto (%block_289); ];
  <    block %block_288 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_153:bv64; goto (%block_289); ];
  >    block %block_287 [ assume eq($R3, bvneg(0x1:bv64)); $R0:bv64 := local_152:bv64; goto (%block_289); ];
  >    block %block_288 [ assume boolnot(eq($R3, bvneg(0x1:bv64))); $R0:bv64 := local_153:bv64; goto (%block_289); ];
  
  <    block %block_291 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_154:bv64; goto (%block_293); ];
  <    block %block_292 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_155:bv64; goto (%block_293); ];
  >    block %block_291 [ assume boolnot(eq($R3, bvneg(0x1:bv64))); $R0:bv64 := local_154:bv64; goto (%block_293); ];
  >    block %block_292 [ assume eq($R3, bvneg(0x1:bv64)); $R0:bv64 := local_155:bv64; goto (%block_293); ];
  
  <    block %block_295 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_156:bv64; goto (%block_297); ];
  <    block %block_296 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_157:bv64; goto (%block_297); ];
  >    block %block_295 [ assume bvule(bvneg(0x1:bv64), $R3); $R0:bv64 := local_156:bv64; goto (%block_297); ];
  >    block %block_296 [ assume bvult($R3, bvneg(0x1:bv64)); $R0:bv64 := local_157:bv64; goto (%block_297); ];
  
  <    block %block_299 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_158:bv64; goto (%block_301); ];
  <    block %block_300 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_159:bv64; goto (%block_301); ];
  >    block %block_299 [ assume bvult($R3, bvneg(0x1:bv64)); $R0:bv64 := local_158:bv64; goto (%block_301); ];
  >    block %block_300 [ assume bvule(bvneg(0x1:bv64), $R3); $R0:bv64 := local_159:bv64; goto (%block_301); ];
  
  <    block %block_303 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_160:bv64; goto (%block_305); ];
  <    block %block_304 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_161:bv64; goto (%block_305); ];
  >    block %block_303 [ assume bvslt(bvadd($R3, 0x1:bv64), 0x0:bv64); $R0:bv64 := local_160:bv64; goto (%block_305); ];
  >    block %block_304 [ assume bvsle(0x0:bv64, bvadd($R3, 0x1:bv64)); $R0:bv64 := local_161:bv64; goto (%block_305); ];
  
  <    block %block_307 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_162:bv64; goto (%block_309); ];
  <    block %block_308 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_163:bv64; goto (%block_309); ];
  >    block %block_307 [ assume bvsle(0x0:bv64, bvadd($R3, 0x1:bv64)); $R0:bv64 := local_162:bv64; goto (%block_309); ];
  >    block %block_308 [ assume bvslt(bvadd($R3, 0x1:bv64), 0x0:bv64); $R0:bv64 := local_163:bv64; goto (%block_309); ];
  
  <    block %block_319 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_168:bv64;
  <      goto (%block_321);
  <    ];
  <    block %block_320 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_169:bv64;
  <      goto (%block_321);
  <    ];
  >    block %block_319 [ assume bvult(bvneg(0x1:bv64), $R3); $R0:bv64 := local_168:bv64; goto (%block_321); ];
  >    block %block_320 [ assume bvule($R3, bvneg(0x1:bv64)); $R0:bv64 := local_169:bv64; goto (%block_321); ];
  
  <    block %block_323 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_170:bv64;
  <      goto (%block_325);
  <    ];
  <    block %block_324 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_171:bv64;
  <      goto (%block_325);
  <    ];
  >    block %block_323 [ assume bvule($R3, bvneg(0x1:bv64)); $R0:bv64 := local_170:bv64; goto (%block_325); ];
  >    block %block_324 [ assume bvult(bvneg(0x1:bv64), $R3); $R0:bv64 := local_171:bv64; goto (%block_325); ];
  
  <    block %block_327 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_172:bv64; goto (%block_329); ];
  <    block %block_328 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_173:bv64; goto (%block_329); ];
  >    block %block_327 [ assume bvsle(bvneg(0x1:bv64), $R3); $R0:bv64 := local_172:bv64; goto (%block_329); ];
  >    block %block_328 [ assume bvslt($R3, bvneg(0x1:bv64)); $R0:bv64 := local_173:bv64; goto (%block_329); ];
  
  <    block %block_331 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_174:bv64; goto (%block_333); ];
  <    block %block_332 [
  <      assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
  <      $R0:bv64 := local_175:bv64;
  <      goto (%block_333);
  <    ];
  >    block %block_331 [ assume bvslt($R3, bvneg(0x1:bv64)); $R0:bv64 := local_174:bv64; goto (%block_333); ];
  >    block %block_332 [ assume bvsle(bvneg(0x1:bv64), $R3); $R0:bv64 := local_175:bv64; goto (%block_333); ];
  
  <    block %block_335 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_176:bv64;
  <      goto (%block_337);
  <    ];
  <    block %block_336 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_177:bv64;
  <      goto (%block_337);
  <    ];
  >    block %block_335 [ assume bvslt(bvneg(0x1:bv64), $R3); $R0:bv64 := local_176:bv64; goto (%block_337); ];
  >    block %block_336 [ assume bvsle($R3, bvneg(0x1:bv64)); $R0:bv64 := local_177:bv64; goto (%block_337); ];
  
  <    block %block_339 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_178:bv64;
  <      goto (%block_341);
  <    ];
  <    block %block_340 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_179:bv64;
  <      goto (%block_341);
  <    ];
  >    block %block_339 [ assume bvsle($R3, bvneg(0x1:bv64)); $R0:bv64 := local_178:bv64; goto (%block_341); ];
  >    block %block_340 [ assume bvslt(bvneg(0x1:bv64), $R3); $R0:bv64 := local_179:bv64; goto (%block_341); ];
  
  <    block %block_344 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_182:bv64; goto (%block_346); ];
  <    block %block_345 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_183:bv64; goto (%block_346); ];
  >    block %block_344 [ assume eq(local_180:bv64, local_181:bv64); $R0:bv64 := local_182:bv64; goto (%block_346); ];
  >    block %block_345 [
  >      assume boolnot(eq(local_180:bv64, local_181:bv64));
  >      $R0:bv64 := local_183:bv64;
  >      goto (%block_346);
  >    ];
  
  <    block %block_348 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_184:bv64; goto (%block_350); ];
  <    block %block_349 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_185:bv64; goto (%block_350); ];
  >    block %block_348 [
  >      assume boolnot(eq(local_180:bv64, local_181:bv64));
  >      $R0:bv64 := local_184:bv64;
  >      goto (%block_350);
  >    ];
  >    block %block_349 [ assume eq(local_180:bv64, local_181:bv64); $R0:bv64 := local_185:bv64; goto (%block_350); ];
  
  <    block %block_352 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_186:bv64; goto (%block_354); ];
  <    block %block_353 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_187:bv64; goto (%block_354); ];
  >    block %block_352 [ assume bvule(local_181:bv64, local_180:bv64); $R0:bv64 := local_186:bv64; goto (%block_354); ];
  >    block %block_353 [ assume bvult(local_180:bv64, local_181:bv64); $R0:bv64 := local_187:bv64; goto (%block_354); ];
  
  <    block %block_356 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_188:bv64; goto (%block_358); ];
  <    block %block_357 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_189:bv64; goto (%block_358); ];
  >    block %block_356 [ assume bvult(local_180:bv64, local_181:bv64); $R0:bv64 := local_188:bv64; goto (%block_358); ];
  >    block %block_357 [ assume bvule(local_181:bv64, local_180:bv64); $R0:bv64 := local_189:bv64; goto (%block_358); ];
  
  <    block %block_360 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_190:bv64; goto (%block_362); ];
  <    block %block_361 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_191:bv64; goto (%block_362); ];
  >    block %block_360 [
  >      assume bvslt(bvsub(local_180:bv64, local_181:bv64), 0x0:bv64);
  >      $R0:bv64 := local_190:bv64;
  >      goto (%block_362);
  >    ];
  >    block %block_361 [
  >      assume bvsle(0x0:bv64, bvsub(local_180:bv64, local_181:bv64));
  >      $R0:bv64 := local_191:bv64;
  >      goto (%block_362);
  >    ];
  
  <    block %block_364 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_192:bv64; goto (%block_366); ];
  <    block %block_365 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_193:bv64; goto (%block_366); ];
  >    block %block_364 [
  >      assume bvsle(0x0:bv64, bvsub(local_180:bv64, local_181:bv64));
  >      $R0:bv64 := local_192:bv64;
  >      goto (%block_366);
  >    ];
  >    block %block_365 [
  >      assume bvslt(bvsub(local_180:bv64, local_181:bv64), 0x0:bv64);
  >      $R0:bv64 := local_193:bv64;
  >      goto (%block_366);
  >    ];
  
  <    block %block_376 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_198:bv64;
  <      goto (%block_378);
  <    ];
  <    block %block_377 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_199:bv64;
  <      goto (%block_378);
  <    ];
  >    block %block_376 [ assume bvult(local_181:bv64, local_180:bv64); $R0:bv64 := local_198:bv64; goto (%block_378); ];
  >    block %block_377 [ assume bvule(local_180:bv64, local_181:bv64); $R0:bv64 := local_199:bv64; goto (%block_378); ];
  
  <    block %block_380 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_200:bv64;
  <      goto (%block_382);
  <    ];
  <    block %block_381 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_201:bv64;
  <      goto (%block_382);
  <    ];
  >    block %block_380 [ assume bvule(local_180:bv64, local_181:bv64); $R0:bv64 := local_200:bv64; goto (%block_382); ];
  >    block %block_381 [ assume bvult(local_181:bv64, local_180:bv64); $R0:bv64 := local_201:bv64; goto (%block_382); ];
  
  <    block %block_384 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_202:bv64; goto (%block_386); ];
  <    block %block_385 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_203:bv64; goto (%block_386); ];
  >    block %block_384 [ assume bvsle(local_181:bv64, local_180:bv64); $R0:bv64 := local_202:bv64; goto (%block_386); ];
  >    block %block_385 [ assume bvslt(local_180:bv64, local_181:bv64); $R0:bv64 := local_203:bv64; goto (%block_386); ];
  
  <    block %block_388 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_204:bv64; goto (%block_390); ];
  <    block %block_389 [
  <      assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
  <      $R0:bv64 := local_205:bv64;
  <      goto (%block_390);
  <    ];
  >    block %block_388 [ assume bvslt(local_180:bv64, local_181:bv64); $R0:bv64 := local_204:bv64; goto (%block_390); ];
  >    block %block_389 [ assume bvsle(local_181:bv64, local_180:bv64); $R0:bv64 := local_205:bv64; goto (%block_390); ];
  
  <    block %block_392 [
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_206:bv64;
  <      goto (%block_394);
  <    ];
  <    block %block_393 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_207:bv64;
  <      goto (%block_394);
  <    ];
  >    block %block_392 [ assume bvslt(local_181:bv64, local_180:bv64); $R0:bv64 := local_206:bv64; goto (%block_394); ];
  >    block %block_393 [ assume bvsle(local_180:bv64, local_181:bv64); $R0:bv64 := local_207:bv64; goto (%block_394); ];
  
  <    block %block_396 [
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_208:bv64;
  <      goto (%block_398);
  <    ];
  <    block %block_397 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_209:bv64;
  <      goto (%block_398);
  <    ];
  >    block %block_396 [ assume bvsle(local_180:bv64, local_181:bv64); $R0:bv64 := local_208:bv64; goto (%block_398); ];
  >    block %block_397 [ assume bvslt(local_181:bv64, local_180:bv64); $R0:bv64 := local_209:bv64; goto (%block_398); ];
  
  <    block %block_401 [ assume eq($PSTATE_Z, 0x1:bv1); $R0:bv64 := local_212:bv64; goto (%block_403); ];
  <    block %block_402 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_213:bv64; goto (%block_403); ];
  >    block %block_401 [
  >      assume eq(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_212:bv64;
  >      goto (%block_403);
  >    ];
  >    block %block_402 [
  >      assume boolnot(eq(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64));
  >      $R0:bv64 := local_213:bv64;
  >      goto (%block_403);
  >    ];
  
  <    block %block_405 [ assume boolnot(eq($PSTATE_Z, 0x1:bv1)); $R0:bv64 := local_214:bv64; goto (%block_407); ];
  <    block %block_406 [ assume boolnot(boolnot(eq($PSTATE_Z, 0x1:bv1))); $R0:bv64 := local_215:bv64; goto (%block_407); ];
  >    block %block_405 [
  >      assume boolnot(eq(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64));
  >      $R0:bv64 := local_214:bv64;
  >      goto (%block_407);
  >    ];
  >    block %block_406 [
  >      assume eq(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_215:bv64;
  >      goto (%block_407);
  >    ];
  
  <    block %block_409 [ assume eq($PSTATE_C, 0x1:bv1); $R0:bv64 := local_216:bv64; goto (%block_411); ];
  <    block %block_410 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_217:bv64; goto (%block_411); ];
  >    block %block_409 [ assume false; $R0:bv64 := local_216:bv64; goto (%block_411); ];
  >    block %block_410 [ assume true; $R0:bv64 := local_217:bv64; goto (%block_411); ];
  
  <    block %block_413 [ assume boolnot(eq($PSTATE_C, 0x1:bv1)); $R0:bv64 := local_218:bv64; goto (%block_415); ];
  <    block %block_414 [ assume boolnot(boolnot(eq($PSTATE_C, 0x1:bv1))); $R0:bv64 := local_219:bv64; goto (%block_415); ];
  >    block %block_413 [ assume true; $R0:bv64 := local_218:bv64; goto (%block_415); ];
  >    block %block_414 [ assume false; $R0:bv64 := local_219:bv64; goto (%block_415); ];
  
  <    block %block_417 [ assume eq($PSTATE_N, 0x1:bv1); $R0:bv64 := local_220:bv64; goto (%block_419); ];
  <    block %block_418 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_221:bv64; goto (%block_419); ];
  >    block %block_417 [
  >      assume bvslt(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_220:bv64;
  >      goto (%block_419);
  >    ];
  >    block %block_418 [
  >      assume bvsle(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));
  >      $R0:bv64 := local_221:bv64;
  >      goto (%block_419);
  >    ];
  
  <    block %block_421 [ assume boolnot(eq($PSTATE_N, 0x1:bv1)); $R0:bv64 := local_222:bv64; goto (%block_423); ];
  <    block %block_422 [ assume boolnot(boolnot(eq($PSTATE_N, 0x1:bv1))); $R0:bv64 := local_223:bv64; goto (%block_423); ];
  >    block %block_421 [
  >      assume bvsle(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));
  >      $R0:bv64 := local_222:bv64;
  >      goto (%block_423);
  >    ];
  >    block %block_422 [
  >      assume bvslt(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_223:bv64;
  >      goto (%block_423);
  >    ];
  
  <    block %block_425 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_224:bv64; goto (%block_427); ];
  <    block %block_426 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_225:bv64; goto (%block_427); ];
  >    block %block_425 [ assume false; $R0:bv64 := local_224:bv64; goto (%block_427); ];
  >    block %block_426 [ assume true; $R0:bv64 := local_225:bv64; goto (%block_427); ];
  
  <    block %block_429 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_226:bv64; goto (%block_431); ];
  <    block %block_430 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_227:bv64; goto (%block_431); ];
  >    block %block_429 [ assume true; $R0:bv64 := local_226:bv64; goto (%block_431); ];
  >    block %block_430 [ assume false; $R0:bv64 := local_227:bv64; goto (%block_431); ];
  
  <    block %block_433 [
  <      assume booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1));
  <      $R0:bv64 := local_228:bv64;
  <      goto (%block_435);
  <    ];
  <    block %block_434 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_229:bv64;
  <      goto (%block_435);
  <    ];
  >    block %block_433 [ assume false; $R0:bv64 := local_228:bv64; goto (%block_435); ];
  >    block %block_434 [ assume true; $R0:bv64 := local_229:bv64; goto (%block_435); ];
  
  <    block %block_437 [
  <      assume boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1)));
  <      $R0:bv64 := local_230:bv64;
  <      goto (%block_439);
  <    ];
  <    block %block_438 [
  <      assume boolnot(boolnot(booland(eq($PSTATE_C, 0x1:bv1), eq($PSTATE_Z, 0x0:bv1))));
  <      $R0:bv64 := local_231:bv64;
  <      goto (%block_439);
  <    ];
  >    block %block_437 [ assume true; $R0:bv64 := local_230:bv64; goto (%block_439); ];
  >    block %block_438 [ assume false; $R0:bv64 := local_231:bv64; goto (%block_439); ];
  
  <    block %block_441 [ assume eq($PSTATE_N, $PSTATE_V); $R0:bv64 := local_232:bv64; goto (%block_443); ];
  <    block %block_442 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_233:bv64; goto (%block_443); ];
  >    block %block_441 [
  >      assume bvsle(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));
  >      $R0:bv64 := local_232:bv64;
  >      goto (%block_443);
  >    ];
  >    block %block_442 [
  >      assume bvslt(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_233:bv64;
  >      goto (%block_443);
  >    ];
  
  <    block %block_445 [ assume boolnot(eq($PSTATE_N, $PSTATE_V)); $R0:bv64 := local_234:bv64; goto (%block_447); ];
  >    block %block_445 [
  >      assume bvslt(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  >      $R0:bv64 := local_234:bv64;
  >      goto (%block_447);
  >    ];
  
  <      assume boolnot(boolnot(eq($PSTATE_N, $PSTATE_V)));
  >      assume bvsle(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));
  
  <      assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
  >      assume bvslt(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));
  
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  >      assume bvsle(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  
  <      assume boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)));
  >      assume bvsle(bvand($R3, bvashr($R4, 0x4:bv64)), 0x0:bv64);
  
  <      assume boolnot(boolnot(booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1))));
  >      assume bvslt(0x0:bv64, bvand($R3, bvashr($R4, 0x4:bv64)));

  $ grep "assume.*\$PSTATE" branch_conditions_post.il
     block %block_26 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_14:bv64; goto (%block_28); ];
     block %block_27 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_15:bv64; goto (%block_28); ];
     block %block_30 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_16:bv64; goto (%block_32); ];
     block %block_31 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_17:bv64; goto (%block_32); ];
     block %block_140 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_74:bv64; goto (%block_142); ];
     block %block_141 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_75:bv64; goto (%block_142); ];
     block %block_144 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_76:bv64; goto (%block_146); ];
     block %block_145 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_77:bv64; goto (%block_146); ];
     block %block_197 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_104:bv64; goto (%block_199); ];
     block %block_198 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_105:bv64; goto (%block_199); ];
     block %block_201 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_106:bv64; goto (%block_203); ];
     block %block_202 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_107:bv64; goto (%block_203); ];
     block %block_311 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_164:bv64; goto (%block_313); ];
     block %block_312 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_165:bv64; goto (%block_313); ];
     block %block_315 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_166:bv64; goto (%block_317); ];
     block %block_316 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_167:bv64; goto (%block_317); ];
     block %block_368 [ assume eq($PSTATE_V, 0x1:bv1); $R0:bv64 := local_194:bv64; goto (%block_370); ];
     block %block_369 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_195:bv64; goto (%block_370); ];
     block %block_372 [ assume boolnot(eq($PSTATE_V, 0x1:bv1)); $R0:bv64 := local_196:bv64; goto (%block_374); ];
     block %block_373 [ assume boolnot(boolnot(eq($PSTATE_V, 0x1:bv1))); $R0:bv64 := local_197:bv64; goto (%block_374); ];
