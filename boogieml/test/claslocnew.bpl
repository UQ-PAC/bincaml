var {:extern} $Gamma_Global_4325420_4325424: bool;
var {:extern} $Gamma_Global_4325424_4325428: bool;
var {:extern} $Gamma_Global_4325428_4325432: bool;
var {:extern} $Gamma_Global_4325432_4325436: bool;
var {:extern} $Gamma_Global_4325436_4325440: bool;
var {:extern} $Gamma_Global_4325440_4325444: bool;
var {:extern} $Gamma_Global_4325444_4325448: bool;
var {:extern} $Global_4325420_4325424: bv32;
var {:extern} $Global_4325424_4325428: bv32;
var {:extern} $Global_4325428_4325432: bv32;
var {:extern} $Global_4325432_4325436: bv32;
var {:extern} $Global_4325436_4325440: bv32;
var {:extern} $Global_4325440_4325444: bv32;
var {:extern} $Global_4325444_4325448: bv32;
const {:extern} $busy_addr: bv64;
axiom ($busy_addr == 4325436bv64);
const {:extern} $public_addr: bv64;
axiom ($public_addr == 4325428bv64);
const {:extern} $secret_addr: bv64;
axiom ($secret_addr == 4325424bv64);
const {:extern} $snk_lck_addr: bv64;
axiom ($snk_lck_addr == 4325440bv64);
const {:extern} $snk_md_addr: bv64;
axiom ($snk_md_addr == 4325432bv64);
const {:extern} $src_lck_addr: bv64;
axiom ($src_lck_addr == 4325444bv64);
const {:extern} $src_md_addr: bv64;
axiom ($src_md_addr == 4325420bv64);
function {:extern} {:bvbuiltin "bvadd"} bvadd32(bv32, bv32) returns (bv32);
function {:extern} {:bvbuiltin "bvadd"} bvadd64(bv64, bv64) returns (bv64);
function {:extern} {:bvbuiltin "bvsgt"} bvsgt32(bv32, bv32) returns (bool);
function {:extern} {:bvbuiltin "bvsle"} bvsle32(bv32, bv32) returns (bool);

function {:extern} {:bvbuiltin "zero_extend 32"} zero_extend32_32(bv32) returns (bv64);
procedure {:extern} p$rely();
  modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;
  ensures $Global_4325420_4325424 == old($Global_4325420_4325424) ==> $Gamma_Global_4325420_4325424 == old($Gamma_Global_4325420_4325424);
  ensures $Global_4325424_4325428 == old($Global_4325424_4325428) ==> $Gamma_Global_4325424_4325428 == old($Gamma_Global_4325424_4325428);
  ensures $Global_4325428_4325432 == old($Global_4325428_4325432) ==> $Gamma_Global_4325428_4325432 == old($Gamma_Global_4325428_4325432);
  ensures $Global_4325432_4325436 == old($Global_4325432_4325436) ==> $Gamma_Global_4325432_4325436 == old($Gamma_Global_4325432_4325436);
  ensures $Global_4325436_4325440 == old($Global_4325436_4325440) ==> $Gamma_Global_4325436_4325440 == old($Gamma_Global_4325436_4325440);
  ensures $Global_4325440_4325444 == old($Global_4325440_4325444) ==> $Gamma_Global_4325440_4325444 == old($Gamma_Global_4325440_4325444);
  ensures $Global_4325444_4325448 == old($Global_4325444_4325448) ==> $Gamma_Global_4325444_4325448 == old($Gamma_Global_4325444_4325448);
  ensures (old($Global_4325440_4325444) == 1bv32 ==> old($Global_4325432_4325436) == $Global_4325432_4325436 && old($Global_4325440_4325444) == $Global_4325440_4325444) && (old($Global_4325444_4325448) == 1bv32 ==> old($Global_4325420_4325424) == $Global_4325420_4325424 && old($Global_4325444_4325448) == $Global_4325444_4325448);

procedure {:extern} p$rely_transitive();
  modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;
  ensures (old($Global_4325440_4325444) == 1bv32 ==> old($Global_4325432_4325436) == $Global_4325432_4325436 && old($Global_4325440_4325444) == $Global_4325440_4325444) && (old($Global_4325444_4325448) == 1bv32 ==> old($Global_4325420_4325424) == $Global_4325420_4325424 && old($Global_4325444_4325448) == $Global_4325444_4325448);

implementation {:extern} p$rely_transitive()
{
  call p$rely();
  call p$rely();
}

procedure {:extern} p$rely_reflexive();

implementation {:extern} p$rely_reflexive()
{
  assert ($Global_4325440_4325444 == 1bv32 ==> $Global_4325432_4325436 == $Global_4325432_4325436 && $Global_4325440_4325444 == $Global_4325440_4325444) && ($Global_4325444_4325448 == 1bv32 ==> $Global_4325420_4325424 == $Global_4325420_4325424 && $Global_4325444_4325448 == $Global_4325444_4325448);
}

procedure {:extern} p$guarantee_reflexive();
    modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;

implementation {:extern} p$guarantee_reflexive()
{
  assert (((($Global_4325440_4325444 != 0bv32) && ($Global_4325440_4325444 != 1bv32)) ==> (($Global_4325440_4325444 == $Global_4325440_4325444) && ($Global_4325420_4325424 == $Global_4325420_4325424))) && ((($Global_4325444_4325448 != 0bv32) && ($Global_4325444_4325448  != 1bv32)) ==> (($Global_4325444_4325448  == $Global_4325444_4325448) && ($Global_4325420_4325424 == $Global_4325420_4325424))));
}

procedure p$src_at_md_4196448() returns (#R0_out: bv64, #Gamma_R0_out: bool, #R1_out: bv64, #Gamma_R1_out: bool);
  modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;
  requires ($Global_4325444_4325448 == 1bv32);
  ensures ((#Gamma_R0_out || (old($Global_4325420_4325424) == 1bv32)) && ($Global_4325444_4325448 == old($Global_4325444_4325448)));

implementation p$src_at_md_4196448() returns (#R0_out: bv64, #Gamma_R0_out: bool, #R1_out: bv64, #Gamma_R1_out: bool)
{
  var #Exp14__5_1_1: bv32;
  var #Exp14__5_2_1: bv32;
  var #Exp14__5_4_1: bv32;
  var #Gamma_Exp14__5_1_1: bool;
  var #Gamma_Exp14__5_2_1: bool;
  var #Gamma_Exp14__5_4_1: bool;
  var #Gamma_R0_8: bool;
  var #R0_8: bv64;
  b#src_at_md_entry:
    assume {:captureState "src_at_md_entry (wQy5IvXtT0a6h9Xb/DD2Pg==)"} true;
    call p$rely();
    #Exp14__5_2_1, #Gamma_Exp14__5_2_1 := $Global_4325420_4325424, $Gamma_Global_4325420_4325424 || true;
    assert #Gamma_Exp14__5_2_1;
    goto b#phi_3, b#phi_4;
  b#phi_4:
    assume {:captureState "phi_4 (wQy5IvXtT0a6h9Xb/DD2Pg==)"} true;
    assume (!(#Exp14__5_2_1 == 1bv32));
    call p$rely();
    #Exp14__5_1_1, #Gamma_Exp14__5_1_1 := $Global_4325428_4325432, $Gamma_Global_4325428_4325432 || true;
    #R0_8, #Gamma_R0_8 := zero_extend32_32(#Exp14__5_1_1), #Gamma_Exp14__5_1_1;
    goto b#src_at_md_return;
  b#phi_3:
    assume {:captureState "phi_3 (wQy5IvXtT0a6h9Xb/DD2Pg==)"} true;
    assume (#Exp14__5_2_1 == 1bv32);
    call p$rely();
    #Exp14__5_4_1, #Gamma_Exp14__5_4_1 := $Global_4325424_4325428, $Gamma_Global_4325424_4325428 || false;
    #R0_8, #Gamma_R0_8 := zero_extend32_32(#Exp14__5_4_1), #Gamma_Exp14__5_4_1;
    goto b#src_at_md_return;
  b#src_at_md_return:
    assume {:captureState "src_at_md_return"} true;
    #R0_out, #R1_out := #R0_8, 4325420bv64;
    #Gamma_R0_out, #Gamma_R1_out := #Gamma_R0_8, true;
    return;
}

procedure p$snk_at_md_4196484(#R0_in: bv64, #Gamma_R0_in: bool) returns (#R1_out: bv64, #Gamma_R1_out: bool, #R2_out: bv64, #Gamma_R2_out: bool);
  modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;
  requires ((#Gamma_R0_in || ($Global_4325432_4325436 == 1bv32)) && ($Global_4325440_4325444 == 1bv32));
  ensures ($Global_4325440_4325444 == old($Global_4325440_4325444));

implementation p$snk_at_md_4196484(#R0_in: bv64, #Gamma_R0_in: bool) returns (#R1_out: bv64, #Gamma_R1_out: bool, #R2_out: bv64, #Gamma_R2_out: bool)
{
  var #Exp14__5_41_1: bv32;
  var #Gamma_Exp14__5_41_1: bool;
  var #Gamma_R2_2: bool;
  var #R2_2: bv64;
  var #snk_lck_old: bv32;
  var #snk_md_old: bv32;
  var #src_lck_old: bv32;
  var #src_md_old: bv32;
  b#snk_at_md_entry:
    assume {:captureState "snk_at_md_entry (dVXzhAyiRaKWs+RXIyo/9Q==)"} true;
    call p$rely();
    #Exp14__5_41_1, #Gamma_Exp14__5_41_1 := $Global_4325432_4325436, $Gamma_Global_4325432_4325436 || true;
    #R2_2, #Gamma_R2_2 := zero_extend32_32(#Exp14__5_41_1), #Gamma_Exp14__5_41_1;
    assert #Gamma_R2_2;
    goto b#phi_3, b#phi_4;
  b#phi_4:
    assume {:captureState "phi_4 (dVXzhAyiRaKWs+RXIyo/9Q==)"} true;
    assume (!(#R2_2[32:0] == 1bv32));
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    assert (true ==> #Gamma_R0_in);
    $Global_4325428_4325432, $Gamma_Global_4325428_4325432 := #R0_in[32:0], #Gamma_R0_in;
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    goto b#snk_at_md_return;
  b#phi_3:
    assume {:captureState "phi_3 (dVXzhAyiRaKWs+RXIyo/9Q==)"} true;
    assume (#R2_2[32:0] == 1bv32);
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    assert (false ==> #Gamma_R0_in);
    $Global_4325424_4325428, $Gamma_Global_4325424_4325428 := #R0_in[32:0], #Gamma_R0_in;
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    goto b#snk_at_md_return;
  b#snk_at_md_return:
    assume {:captureState "snk_at_md_return"} true;
    #R1_out, #R2_out := 4325420bv64, #R2_2;
    #Gamma_R1_out, #Gamma_R2_out := true, #Gamma_R2_2;
    return;
}

procedure p$main_4195904(#R0_in: bv64, #Gamma_R0_in: bool, #R1_in: bv64, #Gamma_R1_in: bool, #R29_in: bv64, #Gamma_R29_in: bool, #R2_in: bv64, #Gamma_R2_in: bool, #R30_in: bv64, #Gamma_R30_in: bool, #R31_in: bv64, #Gamma_R31_in: bool, #R3_in: bv64, #Gamma_R3_in: bool, #R4_in: bv64, #Gamma_R4_in: bool, #R5_in: bv64, #Gamma_R5_in: bool, #R6_in: bv64, #Gamma_R6_in: bool, #R7_in: bv64, #Gamma_R7_in: bool, #_PC_in: bv64, #Gamma__PC_in: bool) returns (#R0_out: bv64, #Gamma_R0_out: bool, #R3_out: bv64, #Gamma_R3_out: bool);
  modifies $Gamma_Global_4325420_4325424, $Gamma_Global_4325424_4325428, $Gamma_Global_4325428_4325432, $Gamma_Global_4325432_4325436, $Gamma_Global_4325436_4325440, $Gamma_Global_4325440_4325444, $Gamma_Global_4325444_4325448, $Global_4325420_4325424, $Global_4325424_4325428, $Global_4325428_4325432, $Global_4325432_4325436, $Global_4325436_4325440, $Global_4325440_4325444, $Global_4325444_4325448;

implementation p$main_4195904(#R0_in: bv64, #Gamma_R0_in: bool, #R1_in: bv64, #Gamma_R1_in: bool, #R29_in: bv64, #Gamma_R29_in: bool, #R2_in: bv64, #Gamma_R2_in: bool, #R30_in: bv64, #Gamma_R30_in: bool, #R31_in: bv64, #Gamma_R31_in: bool, #R3_in: bv64, #Gamma_R3_in: bool, #R4_in: bv64, #Gamma_R4_in: bool, #R5_in: bv64, #Gamma_R5_in: bool, #R6_in: bv64, #Gamma_R6_in: bool, #R7_in: bv64, #Gamma_R7_in: bool, #_PC_in: bv64, #Gamma__PC_in: bool) returns (#R0_out: bv64, #Gamma_R0_out: bool, #R3_out: bv64, #Gamma_R3_out: bool)
{
  var #Exp10__5_29_1: bv32;
  var #Exp10__5_36_1: bv32;
  var #Exp14__5_27_1: bv32;
  var #Exp14__5_31_1: bv32;
  var #Exp14__5_37_1: bv32;
  var #Exp16__5_34_1: bv64;
  var #Exp16__6_24_1: bv32;
  var #Exp16__6_26_1: bv32;
  var #Exp16__6_30_1: bv32;
  var #Exp16__6_39_1: bv32;
  var #Exp18__5_35_1: bv64;
  var #Gamma_Exp10__5_29_1: bool;
  var #Gamma_Exp10__5_36_1: bool;
  var #Gamma_Exp14__5_27_1: bool;
  var #Gamma_Exp14__5_31_1: bool;
  var #Gamma_Exp14__5_37_1: bool;
  var #Gamma_Exp16__5_34_1: bool;
  var #Gamma_Exp16__6_24_1: bool;
  var #Gamma_Exp16__6_26_1: bool;
  var #Gamma_Exp16__6_30_1: bool;
  var #Gamma_Exp16__6_39_1: bool;
  var #Gamma_Exp18__5_35_1: bool;
  var #Gamma_R0_25: bool;
  var #Gamma_R0_29: bool;
  var #Gamma_R0_4: bool;
  var #Gamma_R0_47: bool;
  var #Gamma_R0_48: bool;
  var #Gamma_R0_55: bool;
  var #Gamma_R1_2: bool;
  var #Gamma_R1_38: bool;
  var #Gamma_R1_55: bool;
  var #Gamma_R1_59: bool;
  var #Gamma_R1_retval_inlined_10: bool;
  var #Gamma_R2_3: bool;
  var #Gamma_R2_35: bool;
  var #Gamma_R2_39: bool;
  var #Gamma_R2_65: bool;
  var #Gamma_R4_3: bool;
  var #Gamma_R4_8: bool;
  var #Gamma_R8_10: bool;
  var #Gamma_R9_1: bool;
  var #Gamma_Stack_n16_n8: bool;
  var #Gamma_Stack_n8_0: bool;
  var #R0_25: bv64;
  var #R0_29: bv64;
  var #R0_4: bv64;
  var #R0_47: bv64;
  var #R0_48: bv64;
  var #R0_55: bv64;
  var #R1_2: bv64;
  var #R1_38: bv64;
  var #R1_55: bv64;
  var #R1_59: bv64;
  var #R1_retval_inlined_10: bv64;
  var #R2_3: bv64;
  var #R2_35: bv64;
  var #R2_39: bv64;
  var #R2_65: bv64;
  var #R4_3: bv64;
  var #R4_8: bv64;
  var #R8_10: bv64;
  var #R9_1: bv64;
  var #Stack_n16_n8: bv64;
  var #Stack_n8_0: bv64;
  var #snk_lck_old: bv32;
  var #snk_md_old: bv32;
  var #src_lck_old: bv32;
  var #src_md_old: bv32;
  b#main_entry:
    assume {:captureState "main_entry (TxTRm4kpQiq/Xgistx+xbQ==)"} true;
    call p$rely();
    #Exp14__5_37_1, #Gamma_Exp14__5_37_1 := $Global_4325436_4325440, $Gamma_Global_4325436_4325440 || true;
    assert #Gamma_Exp14__5_37_1;
    goto b#phi_3, b#phi_4;
  b#phi_4:
    assume {:captureState "phi_4 (TxTRm4kpQiq/Xgistx+xbQ==)"} true;
    assume (!(#Exp14__5_37_1 == 4294967295bv32));
    #Stack_n16_n8, #Gamma_Stack_n16_n8 := #R29_in, #Gamma_R29_in;
    #Stack_n8_0, #Gamma_Stack_n8_0 := #R30_in, #Gamma_R30_in;
    #R2_3, #Gamma_R2_3, #R4_3, #Gamma_R4_3 := 0bv64, true, 0bv64, true;
    goto b#main_loop3_116;
  b#main_loop3_116:
    assume {:captureState "main_loop3_116 (rCSSdLZcRB2TKAu9h+WCqg==)"} true;
    call p$rely();
    #Exp14__5_31_1, #Gamma_Exp14__5_31_1 := $Global_4325436_4325440, $Gamma_Global_4325436_4325440 || true;
    #R1_2, #Gamma_R1_2 := zero_extend32_32(#R4_3[32:0]), #Gamma_R4_3;
    assert #Gamma_Exp14__5_31_1;
    goto b#phi_6, b#phi_7;
  b#phi_7:
    assume {:captureState "phi_7 (rCSSdLZcRB2TKAu9h+WCqg==)"} true;
    assume bvsgt32(#Exp14__5_31_1, 0bv32);
    #R4_8, #Gamma_R4_8 := 1bv64, true;
    goto b#main_loop2_110;
  b#phi_6:
    assume {:captureState "phi_6 (rCSSdLZcRB2TKAu9h+WCqg==)"} true;
    assume bvsle32(#Exp14__5_31_1, 0bv32);
    #R4_8, #Gamma_R4_8 := 0bv64, true;
    goto b#main_loop2_110;
  b#main_loop2_110:
    assume {:captureState "main_loop2_110"} true;
    assert (#Gamma_R1_2 && #Gamma_R4_8);
    goto b#phi_12, b#phi_13;
  b#phi_13:
    assume {:captureState "phi_13"} true;
    assume (!(#R4_8[32:0] == #R1_2[32:0]));
    #R0_4, #Gamma_R0_4 := 0bv64, true;
    assert true; //next block is atomic start
    goto b#main_loop2_104;
  b#main_loop2_104:
    assume {:captureState "main_loop2_104"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    #Exp16__6_30_1, #Gamma_Exp16__6_30_1 := $Global_4325440_4325444, $Gamma_Global_4325440_4325444 || true;
    assert (#Gamma_Exp16__6_30_1 && #Gamma_R0_4);
    goto b#phi_15, b#phi_16;
  b#phi_16:
    assume {:captureState "phi_16"} true;
    assume (!(#Exp16__6_30_1 == #R0_4[32:0]));
    assert (#Gamma_Exp16__6_30_1 && #Gamma_R0_4);
    goto b#main_loop2_102;
  b#main_loop2_102:
    assume {:captureState "main_loop2_102"} true;
    assume (!(#Exp16__6_30_1 == #R0_4[32:0]));
    goto b#main_loop2_98;
  b#phi_15:
    assume {:captureState "phi_15"} true;
    assume (#Exp16__6_30_1 == #R0_4[32:0]);
    assert (#Gamma_Exp16__6_30_1 && #Gamma_R0_4);
    goto b#main_loop2_100;
  b#main_loop2_100:
    assume {:captureState "main_loop2_100"} true;
    assume (#Exp16__6_30_1 == #R0_4[32:0]);
    $Global_4325440_4325444, $Gamma_Global_4325440_4325444 := 1bv32, true;
    goto b#main_loop2_98;
  b#main_loop2_98:
    assume {:captureState "main_loop2_98"} true;
    assert true; //this block is atomic end
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    assert #Gamma_Exp16__6_30_1;
    goto b#phi_22, b#phi_23;
  b#phi_23:
    assume {:captureState "phi_23"} true;
    assume (#Exp16__6_30_1 == 0bv32);
    goto b#main_loop1_66;
  b#phi_22:
    assume {:captureState "phi_22"} true;
    assume (!(#Exp16__6_30_1 == 0bv32));
    #R9_1, #Gamma_R9_1 := 1bv64, true;
    goto b#main_loop2_88;
  b#main_loop2_88:
    assume {:captureState "main_loop2_88 (G0vHB4sSQ3yHYTbHJG37zQ==)"} true;
    call p$rely();
    #Exp10__5_36_1, #Gamma_Exp10__5_36_1 := $Global_4325440_4325444, $Gamma_Global_4325440_4325444 || true;
    assert #Gamma_Exp10__5_36_1;
    goto b#phi_26, b#phi_27;
  b#phi_27:
    assume {:captureState "phi_27 (G0vHB4sSQ3yHYTbHJG37zQ==)"} true;
    assume (#Exp10__5_36_1 == 0bv32);
    assert true; //next block is atomic start
    goto b#main_loop1_82;
  b#main_loop1_82:
    assume {:captureState "main_loop1_82"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    #Exp16__6_39_1, #Gamma_Exp16__6_39_1 := $Global_4325440_4325444, $Gamma_Global_4325440_4325444 || true;
    assert (#Gamma_Exp10__5_36_1 && #Gamma_Exp16__6_39_1);
    goto b#phi_29, b#phi_30;
  b#phi_30:
    assume {:captureState "phi_30"} true;
    assume (!(#Exp16__6_39_1 == #Exp10__5_36_1));
    assert (#Gamma_Exp10__5_36_1 && #Gamma_Exp16__6_39_1);
    goto b#main_loop1_80;
  b#main_loop1_80:
    assume {:captureState "main_loop1_80"} true;
    assume (!(#Exp16__6_39_1 == #Exp10__5_36_1));
    goto b#main_loop1_76;
  b#phi_29:
    assume {:captureState "phi_29"} true;
    assume (#Exp16__6_39_1 == #Exp10__5_36_1);
    assert (#Gamma_Exp10__5_36_1 && #Gamma_Exp16__6_39_1);
    goto b#main_loop1_78;
  b#main_loop1_78:
    assume {:captureState "main_loop1_78"} true;
    assume (#Exp16__6_39_1 == #Exp10__5_36_1);
    $Global_4325440_4325444, $Gamma_Global_4325440_4325444 := #R9_1[32:0], #Gamma_R9_1;
    goto b#main_loop1_76;
  b#main_loop1_76:
    assume {:captureState "main_loop1_76"} true;
    assert true; //this block is atomic end
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    assert #Gamma_Exp16__6_39_1;
    goto b#phi_36, b#phi_37;
  b#phi_37:
    assume {:captureState "phi_37"} true;
    assume (!(#Exp16__6_39_1 == 0bv32));
    goto b#main_loop2_88;
  b#phi_36:
    assume {:captureState "phi_36"} true;
    assume (#Exp16__6_39_1 == 0bv32);
    goto b#main_loop1_66;
  b#main_loop1_66:
    assume {:captureState "main_loop1_66 (HVqN0/3+RWiLPKsHRvUqeg==)"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    assert (true ==> #Gamma_R1_2);
    $Global_4325432_4325436, $Gamma_Global_4325432_4325436 := #R1_2[32:0], #Gamma_R1_2;
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    call #R1_retval_inlined_10, #Gamma_R1_retval_inlined_10, #R2_35, #Gamma_R2_35 := p$snk_at_md_4196484(zero_extend32_32(#R2_3[32:0]), #Gamma_R2_3);
    goto b#main_loop1_66_retval_inline;
  b#main_loop1_66_retval_inline:
    assume {:captureState "main_loop1_66_retval_inline"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    $Global_4325440_4325444, $Gamma_Global_4325440_4325444 := 0bv32, true;
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    #R1_38, #Gamma_R1_38 := 4325420bv64, true;
    #R2_39, #Gamma_R2_39 := 0bv64, true;
    goto b#main_loop1_58;
  b#phi_26:
    assume {:captureState "phi_26 (G0vHB4sSQ3yHYTbHJG37zQ==)"} true;
    assume (!(#Exp10__5_36_1 == 0bv32));
    goto b#main_loop2_88;
  b#phi_12:
    assume {:captureState "phi_12"} true;
    assume (#R4_8[32:0] == #R1_2[32:0]);
    #R1_38, #Gamma_R1_38 := #R1_2, #Gamma_R1_2;
    #R2_39, #Gamma_R2_39 := #R2_3, #Gamma_R2_3;
    goto b#main_loop1_58;
  b#main_loop1_58:
    assume {:captureState "main_loop1_58 (mmpaLvZYQk2b8selWCLriA==)"} true;
    #R0_25, #Gamma_R0_25 := 0bv64, true;
    assert true; //next block is atomic start
    goto b#main_loop1_56;
  b#main_loop1_56:
    assume {:captureState "main_loop1_56"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    #Exp16__6_26_1, #Gamma_Exp16__6_26_1 := $Global_4325444_4325448, $Gamma_Global_4325444_4325448 || true;
    assert (#Gamma_Exp16__6_26_1 && #Gamma_R0_25);
    goto b#phi_49, b#phi_50;
  b#phi_50:
    assume {:captureState "phi_50"} true;
    assume (!(#Exp16__6_26_1 == #R0_25[32:0]));
    assert (#Gamma_Exp16__6_26_1 && #Gamma_R0_25);
    goto b#main_loop1_54;
  b#main_loop1_54:
    assume {:captureState "main_loop1_54"} true;
    assume (!(#Exp16__6_26_1 == #R0_25[32:0]));
    goto b#main_loop1_50;
  b#phi_49:
    assume {:captureState "phi_49"} true;
    assume (#Exp16__6_26_1 == #R0_25[32:0]);
    assert (#Gamma_Exp16__6_26_1 && #Gamma_R0_25);
    goto b#main_loop1_52;
  b#main_loop1_52:
    assume {:captureState "main_loop1_52"} true;
    assume (#Exp16__6_26_1 == #R0_25[32:0]);
    $Global_4325444_4325448, $Gamma_Global_4325444_4325448 := 1bv32, true;
    goto b#main_loop1_50;
  b#main_loop1_50:
    assume {:captureState "main_loop1_50"} true;
    assert true; //this block is atomic end
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    goto b#phi_55;
  b#phi_55:
    assume {:captureState "phi_55"} true;
    #R0_29, #Gamma_R0_29 := zero_extend32_32(#Exp16__6_26_1), #Gamma_Exp16__6_26_1;
    assert #Gamma_R0_29;
    goto b#phi_56, b#phi_57;
  b#phi_57:
    assume {:captureState "phi_57"} true;
    assume (#R0_29[32:0] == 0bv32);
    #R1_59, #Gamma_R1_59 := #R1_38, #Gamma_R1_38;
    #R0_47, #Gamma_R0_47 := #R0_29, #Gamma_R0_29;
    goto b#main_loop0_18;
  b#phi_56:
    assume {:captureState "phi_56"} true;
    assume (!(#R0_29[32:0] == 0bv32));
    #R8_10, #Gamma_R8_10 := 1bv64, true;
    goto b#main_loop1_40;
  b#main_loop1_40:
    assume {:captureState "main_loop1_40 (gFBdrsFTRkSCdIsDFMk6qA==)"} true;
    call p$rely();
    #Exp10__5_29_1, #Gamma_Exp10__5_29_1 := $Global_4325444_4325448, $Gamma_Global_4325444_4325448 || true;
    assert #Gamma_Exp10__5_29_1;
    goto b#phi_60, b#phi_61;
  b#phi_61:
    assume {:captureState "phi_61 (gFBdrsFTRkSCdIsDFMk6qA==)"} true;
    assume (#Exp10__5_29_1 == 0bv32);
    assert true; //next block is atomic start
    goto b#main_loop0_34;
  b#main_loop0_34:
    assume {:captureState "main_loop0_34"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    #Exp16__6_24_1, #Gamma_Exp16__6_24_1 := $Global_4325444_4325448, $Gamma_Global_4325444_4325448 || true;
    assert (#Gamma_Exp10__5_29_1 && #Gamma_Exp16__6_24_1);
    goto b#phi_63, b#phi_64;
  b#phi_64:
    assume {:captureState "phi_64"} true;
    assume (!(#Exp16__6_24_1 == #Exp10__5_29_1));
    assert (#Gamma_Exp10__5_29_1 && #Gamma_Exp16__6_24_1);
    goto b#main_loop0_32;
  b#main_loop0_32:
    assume {:captureState "main_loop0_32"} true;
    assume (!(#Exp16__6_24_1 == #Exp10__5_29_1));
    goto b#main_loop0_28;
  b#phi_63:
    assume {:captureState "phi_63"} true;
    assume (#Exp16__6_24_1 == #Exp10__5_29_1);
    assert (#Gamma_Exp10__5_29_1 && #Gamma_Exp16__6_24_1);
    goto b#main_loop0_30;
  b#main_loop0_30:
    assume {:captureState "main_loop0_30"} true;
    assume (#Exp16__6_24_1 == #Exp10__5_29_1);
    $Global_4325444_4325448, $Gamma_Global_4325444_4325448 := #R8_10[32:0], #Gamma_R8_10;
    goto b#main_loop0_28;
  b#main_loop0_28:
    assume {:captureState "main_loop0_28"} true;
    assert true; //this block is atomic end
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    goto b#phi_69;
  b#phi_69:
    assume {:captureState "phi_69"} true;
    #R1_55, #Gamma_R1_55 := zero_extend32_32(#Exp16__6_24_1), #Gamma_Exp16__6_24_1;
    assert #Gamma_R1_55;
    goto b#phi_70, b#phi_71;
  b#phi_71:
    assume {:captureState "phi_71"} true;
    assume (!(#R1_55[32:0] == 0bv32));
    goto b#main_loop1_40;
  b#phi_70:
    assume {:captureState "phi_70"} true;
    assume (#R1_55[32:0] == 0bv32);
    #R1_59, #Gamma_R1_59 := #R1_55, #Gamma_R1_55;
    #R0_47, #Gamma_R0_47 := 4325444bv64, true;
    goto b#main_loop0_18;
  b#main_loop0_18:
    assume {:captureState "main_loop0_18 (6JJvkaLhTaWXaEL0+yxKxg==)"} true;
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    assert (true ==> #Gamma_R4_8);
    $Global_4325420_4325424, $Gamma_Global_4325420_4325424 := #R4_8[32:0], #Gamma_R4_8;
    call #R0_48, #Gamma_R0_48, #R1_retval_inlined_10, #Gamma_R1_retval_inlined_10 := p$src_at_md_4196448();
    goto b#main_loop0_18_retval_inline;
  b#main_loop0_18_retval_inline:
    assume {:captureState "main_loop0_18_retval_inline"} true;
    #R2_65, #Gamma_R2_65 := zero_extend32_32(bvadd32(#R2_39[32:0], #R0_48[32:0])), (#Gamma_R0_48 && #Gamma_R2_39);
    call p$rely();
    #src_md_old := $Global_4325444_4325448;
    #snk_md_old := $Global_4325432_4325436;
    #snk_lck_old := $Global_4325440_4325444;
    #src_lck_old := $Global_4325444_4325448;
    $Global_4325444_4325448, $Gamma_Global_4325444_4325448 := 0bv32, true;
    assert ((((#snk_lck_old != 0bv32) && (#snk_lck_old != 1bv32)) ==> ((#snk_lck_old == $Global_4325440_4325444) && (#snk_md_old == $Global_4325432_4325436))) && (((#src_lck_old != 0bv32) && (#src_lck_old != 1bv32)) ==> ((#src_lck_old == $Global_4325444_4325448) && (#src_md_old == $Global_4325444_4325448))));
    call p$rely();
    #Exp14__5_27_1, #Gamma_Exp14__5_27_1 := $Global_4325436_4325440, $Gamma_Global_4325436_4325440 || true;
    assert #Gamma_Exp14__5_27_1;
    goto b#phi_77, b#phi_78;
  b#phi_78:
    assume {:captureState "phi_78 (OuTzy8qRTci75taVjGinFQ==)"} true;
    assume (!(#Exp14__5_27_1 == 4294967295bv32));
    #R2_3, #Gamma_R2_3, #R4_3, #Gamma_R4_3 := #R2_65, #Gamma_R2_65, #R4_8, #Gamma_R4_8;
    goto b#main_loop3_116;
  b#phi_77:
    assume {:captureState "phi_77 (OuTzy8qRTci75taVjGinFQ==)"} true;
    assume (#Exp14__5_27_1 == 4294967295bv32);
    #Exp16__5_34_1, #Gamma_Exp16__5_34_1 := #Stack_n16_n8, #Gamma_Stack_n16_n8;
    #Exp18__5_35_1, #Gamma_Exp18__5_35_1 := #Stack_n8_0, #Gamma_Stack_n8_0;
    #R0_55, #Gamma_R0_55 := 0bv64, true;
    goto b#main_return;
  b#phi_60:
    assume {:captureState "phi_60 (gFBdrsFTRkSCdIsDFMk6qA==)"} true;
    assume (!(#Exp10__5_29_1 == 0bv32));
    goto b#main_loop1_40;
  b#phi_3:
    assume {:captureState "phi_3 (TxTRm4kpQiq/Xgistx+xbQ==)"} true;
    assume (#Exp14__5_37_1 == 4294967295bv32);
    #R0_55, #Gamma_R0_55 := 0bv64, true;
    goto b#main_return;
  b#main_return:
    assume {:captureState "main_return"} true;
    #R0_out, #R3_out := #R0_55, 4325420bv64;
    #Gamma_R0_out, #Gamma_R3_out := #Gamma_R0_55, true;
    return;
}

