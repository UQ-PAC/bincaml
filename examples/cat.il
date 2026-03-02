memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);
var $BTypeNext: bv2;
var $CF: bv1;
var $NF: bv1;
var $R0: bv64;
var $R1: bv64;
var $R10: bv64;
var $R11: bv64;
var $R12: bv64;
var $R16: bv64;
var $R17: bv64;
var $R19: bv64;
var $R2: bv64;
var $R20: bv64;
var $R21: bv64;
var $R22: bv64;
var $R23: bv64;
var $R24: bv64;
var $R25: bv64;
var $R26: bv64;
var $R27: bv64;
var $R29: bv64;
var $R3: bv64;
var $R30: bv64;
var $R31: bv64;
var $R4: bv64;
var $R5: bv64;
var $R6: bv64;
var $R7: bv64;
var $R8: bv64;
var $R9: bv64;
var $VF: bv1;
var $Z0: bv128;
var $Z1: bv128;
var $Z16: bv128;
var $Z2: bv128;
var $Z3: bv128;
var $Z4: bv128;
var $Z5: bv128;
var $Z6: bv128;
var $Z7: bv128;
var $ZF: bv1;
var $_PC: bv64;
var $__BranchTaken: bv1;

prog entry @main_4197696;

proc @main_4197696 () -> ()
  { .name = "main"; .address = 0x400d40; .returnBlock = "main_basil_return_1" }
  require eq($_PC:bv64, 0x400d40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %main_entry {.address = 0x400d40; .originalLabel = "KXhc9Fe2Qva4qWVLC1eV+w=="} [
    assert eq($_PC:bv64, 0x400d40:bv64);
    $_PC: bv64 := 0x400d40:bv64;
    assert eq($_PC:bv64, 0x400d40:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400d40:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197696_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bf7bfd" };
    var var1_4197696_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bf7bfd" };
    store le $stack bvadd($R31:bv64, 0xfffffffffffffff0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bf7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xfffffffffffffff0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bf7bfd" };
    $R31: bv64 := bvadd(var1_4197696_bv64:bv64, 0xfffffffffffffff0:bv64) { .comment = "op: 0xa9bf7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $R30: bv64 := 0x400d4c:bv64 { .comment = "op: 0x9400007e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400007e" };
    $_PC: bv64 := 0x400f40:bv64 { .comment = "op: 0x9400007e" };
    call @p9main_4198208 ();
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];


proc @getpid () -> ()
  { .name = "getpid" };


proc @exit () -> ()
  { .name = "exit" };


proc @exitcode_4198816 () -> ()
  { .name = "exitcode"; .address = 0x4011a0; .returnBlock = "exitcode_basil_return_1" }
  require eq($_PC:bv64, 0x4011a0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %exitcode_entry {.address = 0x4011a0; .originalLabel = "Hr3XvFHLQ62ROxw2L+L+kg=="} [
    assert eq($_PC:bv64, 0x4011a0:bv64);
    $_PC: bv64 := 0x4011a0:bv64;
    assert eq($_PC:bv64, 0x4011a0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011a0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    var var1_4198820_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%exitcode_basil_return_1);
  ];
  block %exitcode_basil_return_1 [
    return ();
  ]
];


proc @exits_4198688 () -> ()
  { .name = "exits"; .address = 0x401120; .returnBlock = "exits_basil_return_1" }
  require eq($_PC:bv64, 0x401120:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %exits_entry {.address = 0x401120; .originalLabel = "OamxgWkAT5S7lYhJLb34Bw=="} [
    var R30_begin_exits_4198688: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x401120:bv64);
    $_PC: bv64 := 0x401120:bv64;
    assert eq($_PC:bv64, 0x401120:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401120:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198688_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4198688_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4198688_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91104273" };
    var var2_4198704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91104273" };
    var var2_4198704_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91104273" };
    $R19: bv64 := bvadd(var2_4198704_bv64:bv64, 0x410:bv64) { .comment = "op: 0x91104273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002274" };
    var var2_4198708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002274" };
    var var2_4198708_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91002274" };
    $R20: bv64 := bvadd(var2_4198708_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002274" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198712_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91082273" };
    var var2_4198712_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91082273" };
    var var2_4198712_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91082273" };
    $R19: bv64 := bvadd(var2_4198712_bv64:bv64, 0x208:bv64) { .comment = "op: 0x91082273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f6" };
    var var1_4198720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f6" };
    var var2_4198720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f6" };
    var var2_4198720_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f6" };
    $R22: bv64 := bvor(var1_4198720_bv64:bv64, bvshl(var2_4198720_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f6" };
    $R30: bv64 := 0x401148:bv64 { .comment = "op: 0x97fffeb7" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffeb7" };
    $_PC: bv64 := 0x400c20:bv64 { .comment = "op: 0x97fffeb7" };
    goto(%FUN_400c20_entry_93);
  ];
  block %exits_3 {.address = 0x40119c; .originalLabel = "G/PZ+8UBQCiFe5RDCQNkeA=="} [
    assert eq($_PC:bv64, 0x40119c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40119c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    unreachable;
  ];
  block %exits_5 {.address = 0x401150; .originalLabel = "dRdcH2FmQU+o9U5BHHVUeg=="} [
    goto(%exits_43);
  ];
  block %exits_7 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401150:bv64;
    assert eq($_PC:bv64, 0x401150:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401150:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var1_4198736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4198736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4198736_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f3" };
    $R19: bv64 := bvor(var1_4198736_bv64:bv64, bvshl(var2_4198736_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f3" };
    goto(%exits_5);
  ];
  block %exits_9 {.address = 0x401188; .originalLabel = "l6HxnrUcTICnT89No+vNhA=="} [
    assert eq($_PC:bv64, 0x401188:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401188:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $R30: bv64 := 0x401190:bv64 { .comment = "op: 0x97fffe8d" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe8d" };
    $_PC: bv64 := 0x400bc0:bv64 { .comment = "op: 0x97fffe8d" };
    assert eq($R30:bv64, R30_begin_exits_4198688:bv64) { .comment = "R30 = R30_in" };
    goto(%FUN_400bc0_entry_91);
  ];
  block %exits_11 [
    guard eq($R22:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401188:bv64;
    goto(%exits_9);
  ];
  block %exits_13 {.address = 0x401198; .originalLabel = "MCmVUPhnQ5uTrpG/fJW9Og=="} [
    assert eq($_PC:bv64, 0x401198:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401198:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x40119c:bv64 { .comment = "op: 0x97fffe8a" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe8a" };
    $_PC: bv64 := 0x400bc0:bv64 { .comment = "op: 0x97fffe8a" };
    assert eq($R30:bv64, R30_begin_exits_4198688:bv64) { .comment = "R30 = R30_in" };
    goto(%FUN_400bc0_entry_89);
  ];
  block %exits_15 {.address = 0x401190; .originalLabel = "5BhT02DhTEqC0WwV2/F0DQ=="} [
    goto(%exits_13);
  ];
  block %exits_17 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401190:bv64;
    assert eq($_PC:bv64, 0x401190:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401190:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var1_4198800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var2_4198800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var2_4198800_bv64: bv64 := $R22:bv64 { .comment = "op: 0xaa1603e0" };
    $R0: bv64 := bvor(var1_4198800_bv64:bv64, bvshl(var2_4198800_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1603e0" };
    $R30: bv64 := 0x401198:bv64 { .comment = "op: 0x94000003" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000003" };
    $_PC: bv64 := 0x4011a0:bv64 { .comment = "op: 0x94000003" };
    call @exitcode_4198816 ();
    goto(%exits_15);
  ];
  block %exits_19 [
    guard boolnot(boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%exits_9);
  ];
  block %exits_21 {.address = 0x401180; .originalLabel = "4WOBwOCyTyOkZc3owROhvw=="} [
    goto(%exits_17, %exits_19);
  ];
  block %exits_23 [
    guard boolnot(eq($R22:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401180:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401180:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198784_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x394002c0" };
    var var1_4198784_bv64: bv64 := $R22:bv64 { .comment = "op: 0x394002c0" };
    var var2_4198784_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x394002c0" };
    var var2_4198784_bv8: bv8 := load le $mem bvadd(var1_4198784_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x394002c0" };
    $R0: bv64 := zero_extend(32, zero_extend(24, var2_4198784_bv8:bv8)) { .comment = "op: 0x394002c0" };
    goto(%exits_21);
  ];
  block %exits_25 {.address = 0x40117c; .originalLabel = "GPkGYYbcRLuTUGaZ6pGJRA=="} [
    goto(%exits_11, %exits_23);
  ];
  block %exits_27 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40117c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40117c:bv64)"; .label = "pc-tracking" };
    goto(%exits_25);
  ];
  block %exits_29 {.address = 0x401170; .originalLabel = "2jZL7+XrTEu+qPJz0fANVQ=="} [
    assert eq($_PC:bv64, 0x401170:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401170:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1004261" };
    var var2_4198768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1004261" };
    var var2_4198768_bv64: bv64 := $R19:bv64 { .comment = "op: 0xd1004261" };
    $R1: bv64 := bvadd(bvadd(var2_4198768_bv64:bv64, 0xffffffffffffffef:bv64), 0x1:bv64) { .comment = "op: 0xd1004261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14027f" };
    var var2_4198772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R19:bv64), sign_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R19:bv64), zero_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb14027f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R19:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb14027f" };
    goto(%exits_7, %exits_27);
  ];
  block %exits_31 [
    guard eq($R1:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401170:bv64;
    goto(%exits_29);
  ];
  block %exits_33 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401170:bv64;
    goto(%exits_29);
  ];
  block %exits_35 {.address = 0x401168; .originalLabel = "tCtEUNpcRveQqhfp5TkGSw=="} [
    goto(%exits_29);
  ];
  block %exits_37 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401168:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401168:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198760_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf900027f" };
    store le $mem bvadd($R19:bv64, 0x0:bv64) 0x0:bv64 64 { .comment = "op: 0xf900027f" };
    var var1_4198764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0020" };
    var var1_4198764_bv64: bv64 := $R1:bv64 { .comment = "op: 0xd63f0020" };
    $R30: bv64 := 0x401170:bv64 { .comment = "op: 0xd63f0020" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0020" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0020" };
    $_PC: bv64 := var1_4198764_bv64:bv64 { .comment = "op: 0xd63f0020" };
    indirect call var1_4198764_bv64:bv64 ;
    goto(%exits_35);
  ];
  block %exits_39 {.address = 0x40115c; .originalLabel = "SnByFss8SPGStUapVl5sFQ=="} [
    goto(%exits_33, %exits_37);
  ];
  block %exits_41 [
    guard boolnot(eq($R1:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40115c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40115c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400a62" };
    var var1_4198748_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9400a62" };
    var var2_4198748_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400a62" };
    var var2_4198748_bv32: bv32 := load le $mem bvadd(var1_4198748_bv64:bv64, 0x8:bv64) 32 { .comment = "op: 0xb9400a62" };
    $R2: bv64 := zero_extend(32, var2_4198748_bv32:bv32) { .comment = "op: 0xb9400a62" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198752_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b15005f" };
    var var2_4198752_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b15005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b15005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b15005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b15005f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(bvshl(extract(32, 0, $R21:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b15005f" };
    goto(%exits_39);
  ];
  block %exits_43 {.address = 0x401154; .originalLabel = "k/Osg27WR8ClFFB/Bi1X7A=="} [
    assert eq($_PC:bv64, 0x401154:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401154:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198740_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400261" };
    var var1_4198740_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400261" };
    var var2_4198740_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400261" };
    var var2_4198740_bv64: bv64 := load le $mem bvadd(var1_4198740_bv64:bv64, 0x0:bv64) 64 { .comment = "op: 0xf9400261" };
    $R1: bv64 := var2_4198740_bv64:bv64 { .comment = "op: 0xf9400261" };
    goto(%exits_31, %exits_41);
  ];
  block %exits_45 {.address = 0x401148; .originalLabel = "fpIQIwMPTuymlR9MxJqs2Q=="} [
    assert eq($_PC:bv64, 0x401148:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401148:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198728_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var1_4198728_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4198728_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4198728_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f5" };
    $R21: bv64 := zero_extend(32, bvor(var1_4198728_bv32:bv32, bvshl(var2_4198728_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f5" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000002" };
    $_PC: bv64 := 0x401154:bv64 { .comment = "op: 0x14000002" };
    goto(%exits_43);
  ];
  block %_inlineret_3 {.originalLabel = "MCmVUPhnQ5uTrpG/fJW9Og=="} [
    goto(%exits_basil_return_1);
  ];
  block %FUN_400bc0_entry_89 {.address = 0x400bc0} [
    var R30_begin_FUN_400bc0_4197312_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400bc0:bv64);
    $_PC: bv64 := 0x400bc0:bv64;
    assert eq($_PC:bv64, 0x400bc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400bc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197316_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a11" };
    var var1_4197316_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9400a11" };
    var var2_4197316_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a11" };
    var var2_4197316_bv64_3: bv64 := load le $mem bvadd(var1_4197316_bv64_2:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a11" };
    $R17: bv64 := var2_4197316_bv64_3:bv64 { .comment = "op: 0xf9400a11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197320_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x91004210" };
    var var2_4197320_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x91004210" };
    var var2_4197320_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x91004210" };
    $R16: bv64 := bvadd(var2_4197320_bv64_5:bv64, 0x10:bv64) { .comment = "op: 0x91004210" };
    var var1_4197324_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400bc0_4197312_1:bv64) { .comment = "R30 = R30_in" };
    call @exit ();
    goto(%FUN_400bc0_basil_return_1_90);
  ];
  block %FUN_400bc0_basil_return_1_90 [
    goto(%_inlineret_3);
  ];
  block %_inlineret_4 {.originalLabel = "l6HxnrUcTICnT89No+vNhA=="} [
    goto(%exits_basil_return_1);
  ];
  block %FUN_400bc0_entry_91 {.address = 0x400bc0} [
    var R30_begin_FUN_400bc0_4197312_7: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400bc0:bv64);
    $_PC: bv64 := 0x400bc0:bv64;
    assert eq($_PC:bv64, 0x400bc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400bc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197316_bv64_8: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a11" };
    var var1_4197316_bv64_8: bv64 := $R16:bv64 { .comment = "op: 0xf9400a11" };
    var var2_4197316_bv64_9: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a11" };
    var var2_4197316_bv64_9: bv64 := load le $mem bvadd(var1_4197316_bv64_8:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a11" };
    $R17: bv64 := var2_4197316_bv64_9:bv64 { .comment = "op: 0xf9400a11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197320_bv64_10: bv64 := 0x0:bv64 { .comment = "op: 0x91004210" };
    var var2_4197320_bv64_11: bv64 := 0x0:bv64 { .comment = "op: 0x91004210" };
    var var2_4197320_bv64_11: bv64 := $R16:bv64 { .comment = "op: 0x91004210" };
    $R16: bv64 := bvadd(var2_4197320_bv64_11:bv64, 0x10:bv64) { .comment = "op: 0x91004210" };
    var var1_4197324_bv64_12: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400bc0_4197312_7:bv64) { .comment = "R30 = R30_in" };
    call @exit ();
    goto(%FUN_400bc0_basil_return_1_92);
  ];
  block %FUN_400bc0_basil_return_1_92 [
    goto(%_inlineret_4);
  ];
  block %_inlineret_5 {.originalLabel = "OamxgWkAT5S7lYhJLb34Bw=="} [
    goto(%exits_45);
  ];
  block %FUN_400c20_entry_93 {.address = 0x400c20} [
    var R30_begin_FUN_400c20_4197408_13: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c20:bv64);
    $_PC: bv64 := 0x400c20:bv64;
    assert eq($_PC:bv64, 0x400c20:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c20:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197412_bv64_14: bv64 := 0x0:bv64 { .comment = "op: 0xf9402211" };
    var var1_4197412_bv64_14: bv64 := $R16:bv64 { .comment = "op: 0xf9402211" };
    var var2_4197412_bv64_15: bv64 := 0x0:bv64 { .comment = "op: 0xf9402211" };
    var var2_4197412_bv64_15: bv64 := load le $mem bvadd(var1_4197412_bv64_14:bv64, 0x40:bv64) 64 { .comment = "op: 0xf9402211" };
    $R17: bv64 := var2_4197412_bv64_15:bv64 { .comment = "op: 0xf9402211" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197416_bv64_16: bv64 := 0x0:bv64 { .comment = "op: 0x91010210" };
    var var2_4197416_bv64_17: bv64 := 0x0:bv64 { .comment = "op: 0x91010210" };
    var var2_4197416_bv64_17: bv64 := $R16:bv64 { .comment = "op: 0x91010210" };
    $R16: bv64 := bvadd(var2_4197416_bv64_17:bv64, 0x40:bv64) { .comment = "op: 0x91010210" };
    var var1_4197420_bv64_18: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c20_4197408_13:bv64) { .comment = "R30 = R30_in" };
    call @getpid ();
    goto(%FUN_400c20_basil_return_1_94);
  ];
  block %FUN_400c20_basil_return_1_94 [
    goto(%_inlineret_5);
  ];
  block %exits_basil_return_1 [
    return ();
  ]
];


proc @fmtlocaleinit_4209552 () -> ()
  { .name = "fmtlocaleinit"; .address = 0x403b90; .returnBlock = "fmtlocaleinit_basil_return_1" }
  require eq($_PC:bv64, 0x403b90:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %fmtlocaleinit_entry {.address = 0x403b90; .originalLabel = "LJeXYGqvSDa8MTgV+KKKNg=="} [
    assert eq($_PC:bv64, 0x403b90:bv64);
    $_PC: bv64 := 0x403b90:bv64;
    assert eq($_PC:bv64, 0x403b90:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b90:bv64)"; .label = "pc-tracking" };
    goto(%fmtlocaleinit_19, %fmtlocaleinit_27);
  ];
  block %fmtlocaleinit_3 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9004003" };
    store le $mem bvadd($R0:bv64, 0x80:bv64) $R3:bv64 64 { .comment = "op: 0xf9004003" };
    var var1_4209616_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%fmtlocaleinit_basil_return_1);
  ];
  block %fmtlocaleinit_5 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := var1_4209608_bv64:bv64;
    goto(%fmtlocaleinit_3);
  ];
  block %fmtlocaleinit_7 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := var2_4209608_bv64:bv64;
    goto(%fmtlocaleinit_3);
  ];
  block %fmtlocaleinit_9 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209596_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134e084" };
    var var2_4209596_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134e084" };
    var var2_4209596_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9134e084" };
    $R4: bv64 := bvadd(var2_4209596_bv64:bv64, 0xd38:bv64) { .comment = "op: 0x9134e084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209600_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100007f" };
    var var2_4209600_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100007f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R3:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100007f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R3:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100007f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100007f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R3:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100007f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9070801" };
    store le $mem bvadd($R0:bv64, 0x70:bv64) $R1:bv64 64 { .comment = "op: 0xa9070801" };
    store le $mem bvadd(bvadd($R0:bv64, 0x70:bv64), 0x8:bv64) $R2:bv64 64 { .comment = "op: 0xa9070801" };
    var var1_4209608_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a830083" };
    var var1_4209608_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9a830083" };
    var var2_4209608_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a830083" };
    var var2_4209608_bv64: bv64 := $R3:bv64 { .comment = "op: 0x9a830083" };
    goto(%fmtlocaleinit_5, %fmtlocaleinit_7);
  ];
  block %fmtlocaleinit_11 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := var1_4209592_bv64:bv64;
    goto(%fmtlocaleinit_9);
  ];
  block %fmtlocaleinit_13 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := var2_4209592_bv64:bv64;
    goto(%fmtlocaleinit_9);
  ];
  block %fmtlocaleinit_15 {.address = 0x403ba8; .originalLabel = "WGeOSmkTQkuYOqzE8knwVg=="} [
    assert eq($_PC:bv64, 0x403ba8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403ba8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100005f" };
    var var2_4209576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100005f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R5: bv64 := 0x405000:bv64 { .comment = "op: 0xd0000005" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134c0a5" };
    var var2_4209584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134c0a5" };
    var var2_4209584_bv64: bv64 := $R5:bv64 { .comment = "op: 0x9134c0a5" };
    $R5: bv64 := bvadd(var2_4209584_bv64:bv64, 0xd30:bv64) { .comment = "op: 0x9134c0a5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R4: bv64 := 0x405000:bv64 { .comment = "op: 0xd0000004" };
    var var1_4209592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a8200a2" };
    var var1_4209592_bv64: bv64 := $R5:bv64 { .comment = "op: 0x9a8200a2" };
    var var2_4209592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a8200a2" };
    var var2_4209592_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9a8200a2" };
    goto(%fmtlocaleinit_11, %fmtlocaleinit_13);
  ];
  block %fmtlocaleinit_17 {.address = 0x403bd4; .originalLabel = "8tAcpZYiSSSjgFTo4SJOdw=="} [
    goto(%fmtlocaleinit_15);
  ];
  block %fmtlocaleinit_19 [
    guard eq($R1:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403bd4:bv64;
    assert eq($_PC:bv64, 0x403bd4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403bd4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x405000:bv64 { .comment = "op: 0xd0000001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209624_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134a021" };
    var var2_4209624_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134a021" };
    var var2_4209624_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9134a021" };
    $R1: bv64 := bvadd(var2_4209624_bv64:bv64, 0xd28:bv64) { .comment = "op: 0x9134a021" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff3" };
    $_PC: bv64 := 0x403ba8:bv64 { .comment = "op: 0x17fffff3" };
    goto(%fmtlocaleinit_17);
  ];
  block %fmtlocaleinit_21 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var1_4209572_bv64:bv64;
    goto(%fmtlocaleinit_15);
  ];
  block %fmtlocaleinit_23 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var2_4209572_bv64:bv64;
    goto(%fmtlocaleinit_15);
  ];
  block %fmtlocaleinit_25 {.address = 0x403b94; .originalLabel = "d0mJkprJQCa/lqGEDHYA+w=="} [
    goto(%fmtlocaleinit_21, %fmtlocaleinit_23);
  ];
  block %fmtlocaleinit_27 [
    guard boolnot(eq($R1:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403b94:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b94:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400025" };
    var var1_4209556_bv64: bv64 := $R1:bv64 { .comment = "op: 0x39400025" };
    var var2_4209556_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400025" };
    var var2_4209556_bv8: bv8 := load le $mem bvadd(var1_4209556_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400025" };
    $R5: bv64 := zero_extend(32, zero_extend(24, var2_4209556_bv8:bv8)) { .comment = "op: 0x39400025" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R4: bv64 := 0x405000:bv64 { .comment = "op: 0xd0000004" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209564_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134a084" };
    var var2_4209564_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9134a084" };
    var var2_4209564_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9134a084" };
    $R4: bv64 := bvadd(var2_4209564_bv64:bv64, 0xd28:bv64) { .comment = "op: 0x9134a084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209568_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000bf" };
    var var2_4209568_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R5:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R5:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710000bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710000bf" };
    var var1_4209572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a810081" };
    var var1_4209572_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9a810081" };
    var var2_4209572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a810081" };
    var var2_4209572_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9a810081" };
    goto(%fmtlocaleinit_25);
  ];
  block %fmtlocaleinit_basil_return_1 [
    return ();
  ]
];


proc @fmtfdinit_4209364 () -> ()
  { .name = "fmtfdinit"; .address = 0x403ad4; .returnBlock = "fmtfdinit_basil_return_1" }
  require eq($_PC:bv64, 0x403ad4:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %fmtfdinit_entry {.address = 0x403ad4; .originalLabel = "Ase3rrH2SOSuhunVYXYBhg=="} [
    assert eq($_PC:bv64, 0x403ad4:bv64);
    $_PC: bv64 := 0x403ad4:bv64;
    assert eq($_PC:bv64, 0x403ad4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403ad4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209364_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bf7bfd" };
    var var1_4209364_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bf7bfd" };
    store le $stack bvadd($R31:bv64, 0xfffffffffffffff0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bf7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xfffffffffffffff0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bf7bfd" };
    $R31: bv64 := bvadd(var1_4209364_bv64:bv64, 0xfffffffffffffff0:bv64) { .comment = "op: 0xa9bf7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c048" };
    var var2_4209368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c048" };
    var var2_4209368_bv64: bv64 := $R2:bv64 { .comment = "op: 0x8b23c048" };
    var var3_4209368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c048" };
    var var3_4209368_bv64: bv64 := $R3:bv64 { .comment = "op: 0x8b23c048" };
    $R8: bv64 := bvadd(var2_4209368_bv64:bv64, sign_extend(32, extract(32, 0, var3_4209368_bv64:bv64))) { .comment = "op: 0x8b23c048" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var1_4209372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var2_4209372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var2_4209372_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e5" };
    $R5: bv64 := bvor(var1_4209372_bv64:bv64, bvshl(var2_4209372_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209380_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x93407c26" };
    var var1_4209380_bv64: bv64 := $R1:bv64 { .comment = "op: 0x93407c26" };
    $R6: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209380_bv64:bv64, zero_extend(52, 0x1f:bv12))))), 0xffffffff00000000:bv64), bvand(bvor(bvand(0x0:bv64, 0xffffffff00000000:bv64), bvand(var1_4209380_bv64:bv64, 0xffffffff:bv64)), 0xffffffff:bv64)) { .comment = "op: 0x93407c26" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R7: bv64 := 0x403000:bv64 { .comment = "op: 0x90000007" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912cc0e7" };
    var var2_4209388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912cc0e7" };
    var var2_4209388_bv64: bv64 := $R7:bv64 { .comment = "op: 0x912cc0e7" };
    $R7: bv64 := bvadd(var2_4209388_bv64:bv64, 0xb30:bv64) { .comment = "op: 0x912cc0e7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209392_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x3900001f" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) 0x0:bv8 8 { .comment = "op: 0x3900001f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9009405" };
    store le $mem bvadd($R0:bv64, 0x8:bv64) $R5:bv64 64 { .comment = "op: 0xa9009405" };
    store le $mem bvadd(bvadd($R0:bv64, 0x8:bv64), 0x8:bv64) $R5:bv64 64 { .comment = "op: 0xa9009405" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x0:bv64 { .comment = "op: 0xd2800003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x0:bv64 { .comment = "op: 0xd2800002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9019c08" };
    store le $mem bvadd($R0:bv64, 0x18:bv64) $R8:bv64 64 { .comment = "op: 0xa9019c08" };
    store le $mem bvadd(bvadd($R0:bv64, 0x18:bv64), 0x8:bv64) $R7:bv64 64 { .comment = "op: 0xa9019c08" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x0:bv64 { .comment = "op: 0xd2800001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9001406" };
    store le $mem bvadd($R0:bv64, 0x28:bv64) $R6:bv64 64 { .comment = "op: 0xf9001406" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209420_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb900301f" };
    store le $mem bvadd($R0:bv64, 0x30:bv64) 0x0:bv32 32 { .comment = "op: 0xb900301f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209424_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf900341f" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) 0x0:bv64 64 { .comment = "op: 0xf900341f" };
    $R30: bv64 := 0x403b18:bv64 { .comment = "op: 0x9400001f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400001f" };
    $_PC: bv64 := 0x403b90:bv64 { .comment = "op: 0x9400001f" };
    call @fmtlocaleinit_4209552 ();
    goto(%fmtfdinit_5);
  ];
  block %fmtfdinit_5 {.address = 0x403b18; .originalLabel = "PVWh67ivTRed+MKiOS8j6w=="} [
    assert eq($_PC:bv64, 0x403b18:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b18:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c17bfd" };
    var var1_4209436_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c17bfd" };
    var var2_4209436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c17bfd" };
    var var2_4209436_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c17bfd" };
    var var3_4209436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c17bfd" };
    var var3_4209436_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c17bfd" };
    $R29: bv64 := var2_4209436_bv64:bv64 { .comment = "op: 0xa8c17bfd" };
    $R30: bv64 := var3_4209436_bv64:bv64 { .comment = "op: 0xa8c17bfd" };
    $R31: bv64 := bvadd(var1_4209436_bv64:bv64, 0x10:bv64) { .comment = "op: 0xa8c17bfd" };
    var var1_4209440_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%fmtfdinit_basil_return_1);
  ];
  block %fmtfdinit_basil_return_1 [
    return ();
  ]
];


proc @write () -> ()
  { .name = "write" };


proc @__fmtFdFlush_4209456 () -> ()
  { .name = "__fmtFdFlush"; .address = 0x403b30; .returnBlock = "__fmtFdFlush_basil_return_1" }
  require eq($_PC:bv64, 0x403b30:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtFdFlush_entry {.address = 0x403b30; .originalLabel = "I+YOj/gGRqS87EwafUF4WA=="} [
    assert eq($_PC:bv64, 0x403b30:bv64);
    $_PC: bv64 := 0x403b30:bv64;
    assert eq($_PC:bv64, 0x403b30:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b30:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209456_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9be7bfd" };
    var var1_4209456_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffe0:bv64) $R29:bv64 64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9be7bfd" };
    $R31: bv64 := bvadd(var1_4209456_bv64:bv64, 0xffffffffffffffe0:bv64) { .comment = "op: 0xa9be7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4209468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4209468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4209468_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4209468_bv64:bv64, bvshl(var2_4209468_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9408001" };
    var var1_4209472_bv64: bv64 := $R0:bv64 { .comment = "op: 0xa9408001" };
    var var2_4209472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9408001" };
    var var2_4209472_bv64: bv64 := load le $mem bvadd(var1_4209472_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xa9408001" };
    var var3_4209472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9408001" };
    var var3_4209472_bv64: bv64 := load le $mem bvadd(bvadd(var1_4209472_bv64:bv64, 0x8:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9408001" };
    $R1: bv64 := var2_4209472_bv64:bv64 { .comment = "op: 0xa9408001" };
    $R0: bv64 := var3_4209472_bv64:bv64 { .comment = "op: 0xa9408001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209476_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb010002" };
    var var1_4209476_bv64: bv64 := $R0:bv64 { .comment = "op: 0xcb010002" };
    var var2_4209476_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb010002" };
    var var2_4209476_bv64: bv64 := $R1:bv64 { .comment = "op: 0xcb010002" };
    $R2: bv64 := bvadd(bvadd(var1_4209476_bv64:bv64, bvnot(bvshl(var2_4209476_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb010002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209480_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b01001f" };
    var var2_4209480_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b01001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b01001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b01001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b01001f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b01001f" };
    goto(%__fmtFdFlush_19, %__fmtFdFlush_21);
  ];
  block %__fmtFdFlush_5 {.address = 0x403b58; .originalLabel = "aUoJrS37TCGqZrHdtvku3w=="} [
    assert eq($_PC:bv64, 0x403b58:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b58:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4209496_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4209496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4209496_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4209496_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4209496_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4209500_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4209500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4209500_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4209500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4209500_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4209500_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4209500_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4209500_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4209504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtFdFlush_basil_return_1);
  ];
  block %__fmtFdFlush_7 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403b58:bv64;
    goto(%__fmtFdFlush_5);
  ];
  block %__fmtFdFlush_9 {.address = 0x403b50; .originalLabel = "+TV4BL46Tl+dxtE+a2gYKw=="} [
    assert eq($_PC:bv64, 0x403b50:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b50:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000a61" };
    store le $mem bvadd($R19:bv64, 0x10:bv64) $R1:bv64 64 { .comment = "op: 0xf9000a61" };
    goto(%__fmtFdFlush_5);
  ];
  block %__fmtFdFlush_11 {.address = 0x403b84; .originalLabel = "Kowpxq2tSxWyxGmPuAwkYw=="} [
    goto(%__fmtFdFlush_9);
  ];
  block %__fmtFdFlush_13 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403b84:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b84:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209540_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400661" };
    var var1_4209540_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400661" };
    var var2_4209540_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400661" };
    var var2_4209540_bv64: bv64 := load le $mem bvadd(var1_4209540_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf9400661" };
    $R1: bv64 := var2_4209540_bv64:bv64 { .comment = "op: 0xf9400661" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff2" };
    $_PC: bv64 := 0x403b50:bv64 { .comment = "op: 0x17fffff2" };
    goto(%__fmtFdFlush_11);
  ];
  block %__fmtFdFlush_15 {.address = 0x403b74; .originalLabel = "UHBp5tJzT1SBDiFi2TX79A=="} [
    assert eq($_PC:bv64, 0x403b74:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b74:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var1_4209524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4209524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4209524_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e1" };
    $R1: bv64 := bvor(var1_4209524_bv64:bv64, bvshl(var2_4209524_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14003f" };
    var var2_4209532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb14003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb14003f" };
    goto(%__fmtFdFlush_7, %__fmtFdFlush_13);
  ];
  block %__fmtFdFlush_17 {.address = 0x403b64; .originalLabel = "4oo+o5HCQUSnAScIdqVdww=="} [
    goto(%__fmtFdFlush_15);
  ];
  block %__fmtFdFlush_19 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403b64:bv64;
    assert eq($_PC:bv64, 0x403b64:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403b64:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9402a60" };
    var var1_4209508_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9402a60" };
    var var2_4209508_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9402a60" };
    var var2_4209508_bv32: bv32 := load le $mem bvadd(var1_4209508_bv64:bv64, 0x28:bv64) 32 { .comment = "op: 0xb9402a60" };
    $R0: bv64 := zero_extend(32, var2_4209508_bv32:bv32) { .comment = "op: 0xb9402a60" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x93407c54" };
    var var1_4209512_bv64: bv64 := $R2:bv64 { .comment = "op: 0x93407c54" };
    $R20: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209512_bv64:bv64, zero_extend(52, 0x1f:bv12))))), 0xffffffff00000000:bv64), bvand(bvor(bvand(0x0:bv64, 0xffffffff00000000:bv64), bvand(var1_4209512_bv64:bv64, 0xffffffff:bv64)), 0xffffffff:bv64)) { .comment = "op: 0x93407c54" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e2" };
    var var1_4209516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e2" };
    var var2_4209516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e2" };
    var var2_4209516_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e2" };
    $R2: bv64 := bvor(var1_4209516_bv64:bv64, bvshl(var2_4209516_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e2" };
    $R30: bv64 := 0x403b74:bv64 { .comment = "op: 0x97fff440" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fff440" };
    $_PC: bv64 := 0x400c70:bv64 { .comment = "op: 0x97fff440" };
    goto(%FUN_400c70_entry_85);
  ];
  block %__fmtFdFlush_21 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtFdFlush_9);
  ];
  block %_inlineret_3 [
    goto(%__fmtFdFlush_17);
  ];
  block %FUN_400c70_entry_85 {.address = 0x400c70} [
    var R30_begin_FUN_400c70_4197488_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c70:bv64);
    $_PC: bv64 := 0x400c70:bv64;
    assert eq($_PC:bv64, 0x400c70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197492_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9403611" };
    var var1_4197492_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9403611" };
    var var2_4197492_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9403611" };
    var var2_4197492_bv64_3: bv64 := load le $mem bvadd(var1_4197492_bv64_2:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403611" };
    $R17: bv64 := var2_4197492_bv64_3:bv64 { .comment = "op: 0xf9403611" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197496_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x9101a210" };
    var var2_4197496_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x9101a210" };
    var var2_4197496_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x9101a210" };
    $R16: bv64 := bvadd(var2_4197496_bv64_5:bv64, 0x68:bv64) { .comment = "op: 0x9101a210" };
    var var1_4197500_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c70_4197488_1:bv64) { .comment = "R30 = R30_in" };
    call @write ();
    goto(%FUN_400c70_basil_return_1_86);
  ];
  block %FUN_400c70_basil_return_1_86 [
    goto(%_inlineret_3);
  ];
  block %__fmtFdFlush_basil_return_1 [
    return ();
  ]
];


proc @__flagfmt_4208112 () -> ()
  { .name = "__flagfmt"; .address = 0x4035f0; .returnBlock = "__flagfmt_basil_return_1" }
  require eq($_PC:bv64, 0x4035f0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__flagfmt_entry {.address = 0x4035f0; .originalLabel = "Md5qE+eiRf+m/NPBkVuT3g=="} [
    assert eq($_PC:bv64, 0x4035f0:bv64);
    $_PC: bv64 := 0x4035f0:bv64;
    assert eq($_PC:bv64, 0x4035f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4035f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9405801" };
    var var1_4208112_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9405801" };
    var var2_4208112_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9405801" };
    var var2_4208112_bv32: bv32 := load le $mem bvadd(var1_4208112_bv64:bv64, 0x58:bv64) 32 { .comment = "op: 0xb9405801" };
    $R1: bv64 := zero_extend(32, var2_4208112_bv32:bv32) { .comment = "op: 0xb9405801" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208116_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100b43f" };
    var var2_4208116_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100b43f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffd2:bv64), 0x1:bv64)))) { .comment = "op: 0x7100b43f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffd2:bv64), 0x1:bv64)))) { .comment = "op: 0x7100b43f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100b43f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd2:bv32), 0x1:bv32)) { .comment = "op: 0x7100b43f" };
    goto(%__flagfmt_9, %__flagfmt_113);
  ];
  block %__flagfmt_5 {.address = 0x403680; .originalLabel = "p8U1zDiKQ26kgn5ONEFR8w=="} [
    assert eq($_PC:bv64, 0x403680:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403680:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    var var1_4208260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__flagfmt_basil_return_1);
  ];
  block %__flagfmt_7 {.address = 0x4036fc; .originalLabel = "eEi3ylMPRw++fN4SJCb1fA=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_9 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4036fc:bv64;
    assert eq($_PC:bv64, 0x4036fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208380_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208380_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208380_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208380_bv64: bv64 := load le $mem bvadd(var1_4208380_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208380_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27f0021" };
    var var1_4208384_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb27f0021" };
    $R1: bv64 := bvor(var1_4208384_bv64:bv64, 0x2:bv64) { .comment = "op: 0xb27f0021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffde" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17ffffde" };
    goto(%__flagfmt_7);
  ];
  block %__flagfmt_11 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2760021" };
    var var1_4208352_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2760021" };
    $R1: bv64 := bvor(var1_4208352_bv64:bv64, 0x400:bv64) { .comment = "op: 0xb2760021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffe6" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17ffffe6" };
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_13 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var1_4208348_bv64:bv64;
    goto(%__flagfmt_11);
  ];
  block %__flagfmt_15 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var2_4208348_bv64:bv64;
    goto(%__flagfmt_11);
  ];
  block %__flagfmt_17 {.address = 0x4036d0; .originalLabel = "Xo/0MpT5TNezdcsYgjM+HQ=="} [
    goto(%__flagfmt_13, %__flagfmt_15);
  ];
  block %__flagfmt_19 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4036d0:bv64;
    assert eq($_PC:bv64, 0x4036d0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036d0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208336_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208336_bv64: bv64 := load le $mem bvadd(var1_4208336_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208336_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208340_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2750022" };
    var var1_4208340_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2750022" };
    $R2: bv64 := bvor(var1_4208340_bv64:bv64, 0x800:bv64) { .comment = "op: 0xb2750022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208344_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf276003f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0xf276003f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0xf276003f" };
    $ZF: bv1 := booltobv1(eq(bvand($R1:bv64, 0x400:bv64), 0x0:bv64)) { .comment = "op: 0xf276003f" };
    $NF: bv1 := extract(64, 63, bvand($R1:bv64, 0x400:bv64)) { .comment = "op: 0xf276003f" };
    var var1_4208348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a811041" };
    var var1_4208348_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9a811041" };
    var var2_4208348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a811041" };
    var var2_4208348_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9a811041" };
    goto(%__flagfmt_17);
  ];
  block %__flagfmt_21 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403680:bv64;
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_23 {.address = 0x4036c0; .originalLabel = "pazV1eFNTF6AMI4CW/BGCA=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_25 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4036c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036c0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208320_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208320_bv64: bv64 := load le $mem bvadd(var1_4208320_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208320_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208324_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2780021" };
    var var1_4208324_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2780021" };
    $R1: bv64 := bvor(var1_4208324_bv64:bv64, 0x100:bv64) { .comment = "op: 0xb2780021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffed" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17ffffed" };
    goto(%__flagfmt_23);
  ];
  block %__flagfmt_27 {.address = 0x4036b8; .originalLabel = "luxGd5baRBa1hf/CwpcHsg=="} [
    goto(%__flagfmt_21, %__flagfmt_25);
  ];
  block %__flagfmt_29 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4036b8:bv64;
    assert eq($_PC:bv64, 0x4036b8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036b8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208312_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101d43f" };
    var var2_4208312_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101d43f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffff8a:bv64), 0x1:bv64)))) { .comment = "op: 0x7101d43f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffff8a:bv64), 0x1:bv64)))) { .comment = "op: 0x7101d43f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101d43f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff8a:bv32), 0x1:bv32)) { .comment = "op: 0x7101d43f" };
    goto(%__flagfmt_27);
  ];
  block %__flagfmt_31 {.address = 0x403698; .originalLabel = "cw+wkUTtT+ehy0d3hMl2aQ=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_33 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403698:bv64;
    assert eq($_PC:bv64, 0x403698:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403698:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208280_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208280_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208280_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208280_bv64: bv64 := load le $mem bvadd(var1_4208280_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208280_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2720021" };
    var var1_4208284_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2720021" };
    $R1: bv64 := bvor(var1_4208284_bv64:bv64, 0x4000:bv64) { .comment = "op: 0xb2720021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208288_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff7" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17fffff7" };
    goto(%__flagfmt_31);
  ];
  block %__flagfmt_35 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403680:bv64;
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_37 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208216_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2770021" };
    var var1_4208216_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2770021" };
    $R1: bv64 := bvor(var1_4208216_bv64:bv64, 0x200:bv64) { .comment = "op: 0xb2770021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000008" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x14000008" };
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_39 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var1_4208212_bv64:bv64;
    goto(%__flagfmt_37);
  ];
  block %__flagfmt_41 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var2_4208212_bv64:bv64;
    goto(%__flagfmt_37);
  ];
  block %__flagfmt_43 {.address = 0x403648; .originalLabel = "G98+8wP8Rr+pKZqw5PksWA=="} [
    goto(%__flagfmt_39, %__flagfmt_41);
  ];
  block %__flagfmt_45 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403648:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403648:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208200_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208200_bv64: bv64 := load le $mem bvadd(var1_4208200_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208200_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208204_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2730022" };
    var var1_4208204_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2730022" };
    $R2: bv64 := bvor(var1_4208204_bv64:bv64, 0x2000:bv64) { .comment = "op: 0xb2730022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208208_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf277003f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0xf277003f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0xf277003f" };
    $ZF: bv1 := booltobv1(eq(bvand($R1:bv64, 0x200:bv64), 0x0:bv64)) { .comment = "op: 0xf277003f" };
    $NF: bv1 := extract(64, 63, bvand($R1:bv64, 0x200:bv64)) { .comment = "op: 0xf277003f" };
    var var1_4208212_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a811041" };
    var var1_4208212_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9a811041" };
    var var2_4208212_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a811041" };
    var var2_4208212_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9a811041" };
    goto(%__flagfmt_43);
  ];
  block %__flagfmt_47 {.address = 0x403640; .originalLabel = "F71wJ5IpTZ6K1ck2tvRLBQ=="} [
    goto(%__flagfmt_35, %__flagfmt_45);
  ];
  block %__flagfmt_49 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403640:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403640:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208192_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101a03f" };
    var var2_4208192_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101a03f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffff97:bv64), 0x1:bv64)))) { .comment = "op: 0x7101a03f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffff97:bv64), 0x1:bv64)))) { .comment = "op: 0x7101a03f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101a03f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff97:bv32), 0x1:bv32)) { .comment = "op: 0x7101a03f" };
    goto(%__flagfmt_47);
  ];
  block %__flagfmt_51 {.address = 0x403638; .originalLabel = "0nOLfED6Qu6oVzb0JGMppg=="} [
    goto(%__flagfmt_33, %__flagfmt_49);
  ];
  block %__flagfmt_53 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403638:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403638:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208184_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101303f" };
    var var2_4208184_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101303f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffb3:bv64), 0x1:bv64)))) { .comment = "op: 0x7101303f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffb3:bv64), 0x1:bv64)))) { .comment = "op: 0x7101303f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101303f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffb3:bv32), 0x1:bv32)) { .comment = "op: 0x7101303f" };
    goto(%__flagfmt_51);
  ];
  block %__flagfmt_55 {.address = 0x403634; .originalLabel = "poMShIJdSNCBkKrx/fbhsw=="} [
    goto(%__flagfmt_29, %__flagfmt_53);
  ];
  block %__flagfmt_57 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403634:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403634:bv64)"; .label = "pc-tracking" };
    goto(%__flagfmt_55);
  ];
  block %__flagfmt_59 {.address = 0x40362c; .originalLabel = "QtDQfcoISxuxDJ4xzuSLNQ=="} [
    goto(%__flagfmt_19, %__flagfmt_57);
  ];
  block %__flagfmt_61 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40362c:bv64;
    assert eq($_PC:bv64, 0x40362c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40362c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208172_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101b03f" };
    var var2_4208172_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101b03f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffff93:bv64), 0x1:bv64)))) { .comment = "op: 0x7101b03f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffff93:bv64), 0x1:bv64)))) { .comment = "op: 0x7101b03f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101b03f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffff93:bv32), 0x1:bv32)) { .comment = "op: 0x7101b03f" };
    goto(%__flagfmt_59);
  ];
  block %__flagfmt_63 {.address = 0x4036ec; .originalLabel = "6p2EPfrOTQmAgkC7SFe4NQ=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_65 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4036ec:bv64;
    assert eq($_PC:bv64, 0x4036ec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036ec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208364_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208364_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208364_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208364_bv64: bv64 := load le $mem bvadd(var1_4208364_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208364_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27a0021" };
    var var1_4208368_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb27a0021" };
    $R1: bv64 := bvor(var1_4208368_bv64:bv64, 0x40:bv64) { .comment = "op: 0xb27a0021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffe2" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17ffffe2" };
    goto(%__flagfmt_63);
  ];
  block %__flagfmt_67 {.address = 0x403688; .originalLabel = "jNdVDjbFQgGp4R0YHnxewA=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_69 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403688:bv64;
    assert eq($_PC:bv64, 0x403688:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403688:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208264_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208264_bv64: bv64 := load le $mem bvadd(var1_4208264_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208264_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27b0021" };
    var var1_4208268_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb27b0021" };
    $R1: bv64 := bvor(var1_4208268_bv64:bv64, 0x20:bv64) { .comment = "op: 0xb27b0021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffffb" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17fffffb" };
    goto(%__flagfmt_67);
  ];
  block %__flagfmt_71 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403680:bv64;
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_73 {.address = 0x403674; .originalLabel = "vODmE1IBQYK6rV5IWn54rA=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_75 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403674:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403674:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208244_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208244_bv64: bv64 := load le $mem bvadd(var1_4208244_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208244_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208248_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2740021" };
    var var1_4208248_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb2740021" };
    $R1: bv64 := bvor(var1_4208248_bv64:bv64, 0x1000:bv64) { .comment = "op: 0xb2740021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    goto(%__flagfmt_73);
  ];
  block %__flagfmt_77 {.address = 0x40366c; .originalLabel = "H/Ww5+sIS7ChTGaVLbJ4gg=="} [
    goto(%__flagfmt_71, %__flagfmt_75);
  ];
  block %__flagfmt_79 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40366c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40366c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208236_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100b03f" };
    var var2_4208236_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100b03f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffd3:bv64), 0x1:bv64)))) { .comment = "op: 0x7100b03f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffd3:bv64), 0x1:bv64)))) { .comment = "op: 0x7100b03f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100b03f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd3:bv32), 0x1:bv32)) { .comment = "op: 0x7100b03f" };
    goto(%__flagfmt_77);
  ];
  block %__flagfmt_81 {.address = 0x403664; .originalLabel = "yD5i1R24TW2r0CYKlx2xuA=="} [
    goto(%__flagfmt_69, %__flagfmt_79);
  ];
  block %__flagfmt_83 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403664:bv64;
    assert eq($_PC:bv64, 0x403664:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403664:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ac3f" };
    var var2_4208228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ac3f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffd4:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ac3f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffd4:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ac3f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100ac3f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd4:bv32), 0x1:bv32)) { .comment = "op: 0x7100ac3f" };
    goto(%__flagfmt_81);
  ];
  block %__flagfmt_85 {.address = 0x4036a8; .originalLabel = "8BavGP4XRlChYjbh8T3V3w=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_87 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4036a8:bv64;
    assert eq($_PC:bv64, 0x4036a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4036a8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208296_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208296_bv64: bv64 := load le $mem bvadd(var1_4208296_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208296_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208300_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27c0021" };
    var var1_4208300_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb27c0021" };
    $R1: bv64 := bvor(var1_4208300_bv64:bv64, 0x10:bv64) { .comment = "op: 0xb27c0021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208304_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff3" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x17fffff3" };
    goto(%__flagfmt_85);
  ];
  block %__flagfmt_89 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403680:bv64;
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_91 {.address = 0x40361c; .originalLabel = "Dponu/kORFi2r4E2OoPjKQ=="} [
    goto(%__flagfmt_5);
  ];
  block %__flagfmt_93 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40361c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40361c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var1_4208156_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403401" };
    var var2_4208156_bv64: bv64 := load le $mem bvadd(var1_4208156_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403401" };
    $R1: bv64 := var2_4208156_bv64:bv64 { .comment = "op: 0xf9403401" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208160_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27d0021" };
    var var1_4208160_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb27d0021" };
    $R1: bv64 := bvor(var1_4208160_bv64:bv64, 0x8:bv64) { .comment = "op: 0xb27d0021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9003401" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) $R1:bv64 64 { .comment = "op: 0xf9003401" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000016" };
    $_PC: bv64 := 0x403680:bv64 { .comment = "op: 0x14000016" };
    goto(%__flagfmt_91);
  ];
  block %__flagfmt_95 {.address = 0x403614; .originalLabel = "HbBxZ4ukTXywTX9EsXMnfQ=="} [
    goto(%__flagfmt_89, %__flagfmt_93);
  ];
  block %__flagfmt_97 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403614:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403614:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208148_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71008c3f" };
    var var2_4208148_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71008c3f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffdc:bv64), 0x1:bv64)))) { .comment = "op: 0x71008c3f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffdc:bv64), 0x1:bv64)))) { .comment = "op: 0x71008c3f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x71008c3f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdc:bv32), 0x1:bv32)) { .comment = "op: 0x71008c3f" };
    goto(%__flagfmt_95);
  ];
  block %__flagfmt_99 {.address = 0x40360c; .originalLabel = "fi2g/0edQOapx9VNft10Hg=="} [
    goto(%__flagfmt_87, %__flagfmt_97);
  ];
  block %__flagfmt_101 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40360c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40360c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208140_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100803f" };
    var var2_4208140_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100803f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffdf:bv64), 0x1:bv64)))) { .comment = "op: 0x7100803f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffdf:bv64), 0x1:bv64)))) { .comment = "op: 0x7100803f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100803f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffdf:bv32), 0x1:bv32)) { .comment = "op: 0x7100803f" };
    goto(%__flagfmt_99);
  ];
  block %__flagfmt_103 {.address = 0x403608; .originalLabel = "Z8eDW404Qf+hQrDc0E6O4w=="} [
    goto(%__flagfmt_83, %__flagfmt_101);
  ];
  block %__flagfmt_105 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403608:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403608:bv64)"; .label = "pc-tracking" };
    goto(%__flagfmt_103);
  ];
  block %__flagfmt_107 {.address = 0x403600; .originalLabel = "OmmuwZ/8Qwq7m41vcMMhOw=="} [
    goto(%__flagfmt_65, %__flagfmt_105);
  ];
  block %__flagfmt_109 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403600:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403600:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208128_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71009c3f" };
    var var2_4208128_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71009c3f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffd8:bv64), 0x1:bv64)))) { .comment = "op: 0x71009c3f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffd8:bv64), 0x1:bv64)))) { .comment = "op: 0x71009c3f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x71009c3f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffd8:bv32), 0x1:bv32)) { .comment = "op: 0x71009c3f" };
    goto(%__flagfmt_107);
  ];
  block %__flagfmt_111 {.address = 0x4035fc; .originalLabel = "LpN4VJbAQrKtt8bKD2sjvg=="} [
    goto(%__flagfmt_61, %__flagfmt_109);
  ];
  block %__flagfmt_113 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4035fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4035fc:bv64)"; .label = "pc-tracking" };
    goto(%__flagfmt_111);
  ];
  block %__flagfmt_basil_return_1 [
    return ();
  ]
];


proc @__rfmtpad_4203024 () -> ()
  { .name = "__rfmtpad"; .address = 0x402210; .returnBlock = "__rfmtpad_basil_return_1" }
  require eq($_PC:bv64, 0x402210:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__rfmtpad_entry {.address = 0x402210; .originalLabel = "FnHqSK+lTxq6YDUq7NvnJg=="} [
    assert eq($_PC:bv64, 0x402210:bv64);
    $_PC: bv64 := 0x402210:bv64;
    assert eq($_PC:bv64, 0x402210:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402210:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4203024_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4203024_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203028_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4203036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4203036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4203036_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4203036_bv64:bv64, bvshl(var2_4203036_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411802" };
    var var1_4203040_bv64: bv64 := $R0:bv64 { .comment = "op: 0xa9411802" };
    var var2_4203040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411802" };
    var var2_4203040_bv64: bv64 := load le $mem bvadd(var1_4203040_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xa9411802" };
    var var3_4203040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411802" };
    var var3_4203040_bv64: bv64 := load le $mem bvadd(bvadd(var1_4203040_bv64:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9411802" };
    $R2: bv64 := var2_4203040_bv64:bv64 { .comment = "op: 0xa9411802" };
    $R6: bv64 := var3_4203040_bv64:bv64 { .comment = "op: 0xa9411802" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203044_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    var var2_4203044_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100003f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100003f" };
    goto(%__rfmtpad_11, %__rfmtpad_73);
  ];
  block %__rfmtpad_3 {.address = 0x40231c; .originalLabel = "4XFuM5TYTyepUKqwFo/SwQ=="} [
    assert eq($_PC:bv64, 0x40231c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40231c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    unreachable;
  ];
  block %__rfmtpad_5 {.address = 0x4022f0; .originalLabel = "at8ExOxbSzWyljPMXzwnAg=="} [
    assert eq($_PC:bv64, 0x4022f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203248_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4203248_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4203248_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4203248_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4203248_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4203248_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4203252_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4203252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4203252_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4203252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4203252_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4203252_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4203252_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4203252_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4203256_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__rfmtpad_basil_return_1);
  ];
  block %__rfmtpad_7 {.address = 0x4022e0; .originalLabel = "VxfMxyabTbidG8a3NL8Mmw=="} [
    assert eq($_PC:bv64, 0x4022e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022e0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203232_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000084" };
    var var1_4203232_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0xb000084" };
    var var2_4203232_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000084" };
    var var2_4203232_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb000084" };
    $R4: bv64 := zero_extend(32, bvadd(var1_4203232_bv32:bv32, bvshl(var2_4203232_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb000084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203240_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000a62" };
    store le $mem bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64 { .comment = "op: 0xf9000a62" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9003264" };
    store le $mem bvadd($R19:bv64, 0x30:bv64) extract(32, 0, $R4:bv64) 32 { .comment = "op: 0xb9003264" };
    goto(%__rfmtpad_5);
  ];
  block %__rfmtpad_9 {.address = 0x402310; .originalLabel = "nOjYj7zWT56CB4aaqC4LWg=="} [
    goto(%__rfmtpad_7);
  ];
  block %__rfmtpad_11 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402310:bv64;
    assert eq($_PC:bv64, 0x402310:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402310:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203280_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403264" };
    var var1_4203280_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9403264" };
    var var2_4203280_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403264" };
    var var2_4203280_bv32: bv32 := load le $mem bvadd(var1_4203280_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403264" };
    $R4: bv64 := zero_extend(32, var2_4203280_bv32:bv32) { .comment = "op: 0xb9403264" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff2" };
    $_PC: bv64 := 0x4022e0:bv64 { .comment = "op: 0x17fffff2" };
    goto(%__rfmtpad_9);
  ];
  block %__rfmtpad_13 {.address = 0x4022d4; .originalLabel = "jOmi7TrKR7Cbnu5G7GC8pw=="} [
    assert eq($_PC:bv64, 0x4022d4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022d4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4203220_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4203220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4203220_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4203220_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4203220_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb050040" };
    var var1_4203224_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb050040" };
    var var2_4203224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb050040" };
    var var2_4203224_bv64: bv64 := $R5:bv64 { .comment = "op: 0xcb050040" };
    $R0: bv64 := bvadd(bvadd(var1_4203224_bv64:bv64, bvnot(bvshl(var2_4203224_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb050040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203228_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd3418000" };
    var var1_4203228_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd3418000" };
    $R0: bv64 := bvor(bvand(0x0:bv64, 0xffffffff00000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x7fffffff00000000:bv64), bvand(bvor(bvlshr(var1_4203228_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4203228_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0x80000000ffffffff:bv64)), 0xffffffff:bv64)) { .comment = "op: 0xd3418000" };
    goto(%__rfmtpad_7);
  ];
  block %__rfmtpad_15 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4022d4:bv64;
    goto(%__rfmtpad_13);
  ];
  block %__rfmtpad_17 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__rfmtpad_69);
  ];
  block %__rfmtpad_19 {.address = 0x402248; .originalLabel = "2vX/CDM6Tzu5qntEEBwv0g=="} [
    goto(%__rfmtpad_15, %__rfmtpad_17);
  ];
  block %__rfmtpad_21 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402248:bv64;
    assert eq($_PC:bv64, 0x402248:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402248:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203080_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4203080_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4203080_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x11000694" };
    $R20: bv64 := zero_extend(32, bvadd(var2_4203080_bv32:bv32, 0x1:bv32)) { .comment = "op: 0x11000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203084_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000076" };
    store le $mem bvadd($R3:bv64, 0x0:bv64) extract(16, 0, $R22:bv64) 16 { .comment = "op: 0x79000076" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var1_4203088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4203088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4203088_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e2" };
    $R2: bv64 := bvor(var1_4203088_bv64:bv64, bvshl(var2_4203088_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203092_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    var var2_4203092_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b1402bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b1402bf" };
    goto(%__rfmtpad_19);
  ];
  block %__rfmtpad_23 {.address = 0x402304; .originalLabel = "oialukDRSeasNDcO8b0KRg=="} [
    assert eq($_PC:bv64, 0x402304:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402304:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4203268_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4203268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4203268_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4203268_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4203268_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff9" };
    $_PC: bv64 := 0x4022f0:bv64 { .comment = "op: 0x17fffff9" };
    goto(%__rfmtpad_5);
  ];
  block %__rfmtpad_25 {.address = 0x402300; .originalLabel = "mRvVkVjjSr6XqdG8v+ClHw=="} [
    assert eq($_PC:bv64, 0x402300:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402300:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000e63" };
    store le $mem bvadd($R19:bv64, 0x18:bv64) $R3:bv64 64 { .comment = "op: 0xf9000e63" };
    goto(%__rfmtpad_23);
  ];
  block %__rfmtpad_27 {.address = 0x4022fc; .originalLabel = "C+U3gU4xSPqhBtA/lCa1Sw=="} [
    goto(%__rfmtpad_25);
  ];
  block %__rfmtpad_29 [
    guard eq($R1:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4022fc:bv64;
    assert eq($_PC:bv64, 0x4022fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var1_4203260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var2_4203260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var2_4203260_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e3" };
    $R3: bv64 := bvor(var1_4203260_bv64:bv64, bvshl(var2_4203260_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e3" };
    goto(%__rfmtpad_27);
  ];
  block %__rfmtpad_31 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402300:bv64;
    goto(%__rfmtpad_25);
  ];
  block %__rfmtpad_33 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402300:bv64;
    goto(%__rfmtpad_25);
  ];
  block %__rfmtpad_35 [
    guard eq($R3:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402304:bv64;
    goto(%__rfmtpad_23);
  ];
  block %__rfmtpad_37 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40225c:bv64;
    goto(%__rfmtpad_69);
  ];
  block %__rfmtpad_39 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__rfmtpad_13);
  ];
  block %__rfmtpad_41 {.address = 0x4022c0; .originalLabel = "U6oZY1XVT5eNJHhRR8RkZA=="} [
    goto(%__rfmtpad_37, %__rfmtpad_39);
  ];
  block %__rfmtpad_43 [
    guard boolnot(eq($R3:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4022c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022c0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403264" };
    var var1_4203200_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9403264" };
    var var2_4203200_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403264" };
    var var2_4203200_bv32: bv32 := load le $mem bvadd(var1_4203200_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403264" };
    $R4: bv64 := zero_extend(32, var2_4203200_bv32:bv32) { .comment = "op: 0xb9403264" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4203204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4203204_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x11000694" };
    $R20: bv64 := zero_extend(32, bvadd(var2_4203204_bv32:bv32, 0x1:bv32)) { .comment = "op: 0x11000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203208_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000076" };
    store le $mem bvadd($R3:bv64, 0x0:bv64) extract(16, 0, $R22:bv64) 16 { .comment = "op: 0x79000076" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203212_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    var var2_4203212_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b1402bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b1402bf" };
    goto(%__rfmtpad_41);
  ];
  block %__rfmtpad_45 {.address = 0x4022bc; .originalLabel = "vqf2C/snQlqJrSrdZZtmOQ=="} [
    goto(%__rfmtpad_35, %__rfmtpad_43);
  ];
  block %__rfmtpad_47 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4022bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022bc:bv64)"; .label = "pc-tracking" };
    goto(%__rfmtpad_45);
  ];
  block %__rfmtpad_49 {.address = 0x4022a8; .originalLabel = "DPmZDkh/SsefgIdnLB7ibQ=="} [
    goto(%__rfmtpad_33, %__rfmtpad_47);
  ];
  block %__rfmtpad_51 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4022a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022a8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400e66" };
    var var1_4203176_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400e66" };
    var var2_4203176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400e66" };
    var var2_4203176_bv64: bv64 := load le $mem bvadd(var1_4203176_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400e66" };
    $R6: bv64 := var2_4203176_bv64:bv64 { .comment = "op: 0xf9400e66" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000862" };
    var var2_4203180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000862" };
    var var2_4203180_bv64: bv64 := $R3:bv64 { .comment = "op: 0x91000862" };
    $R2: bv64 := bvadd(var2_4203180_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000862" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e5" };
    var var1_4203184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e5" };
    var var2_4203184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e5" };
    var var2_4203184_bv64: bv64 := $R3:bv64 { .comment = "op: 0xaa0303e5" };
    $R5: bv64 := bvor(var1_4203184_bv64:bv64, bvshl(var2_4203184_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0303e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203188_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb06005f" };
    var var2_4203188_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb06005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb06005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb06005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb06005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb06005f" };
    goto(%__rfmtpad_49);
  ];
  block %__rfmtpad_53 {.address = 0x4022a0; .originalLabel = "DYqlgY9FTR6Q2jWymiycYA=="} [
    assert eq($_PC:bv64, 0x4022a0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4022a0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a63" };
    var var1_4203168_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400a63" };
    var var2_4203168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a63" };
    var var2_4203168_bv64: bv64 := load le $mem bvadd(var1_4203168_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a63" };
    $R3: bv64 := var2_4203168_bv64:bv64 { .comment = "op: 0xf9400a63" };
    goto(%__rfmtpad_31, %__rfmtpad_51);
  ];
  block %__rfmtpad_55 {.address = 0x40229c; .originalLabel = "y7hyl4hqSQu8qUQXM2/2oA=="} [
    goto(%__rfmtpad_53);
  ];
  block %__rfmtpad_57 [
    guard boolnot(eq($R1:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40229c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40229c:bv64)"; .label = "pc-tracking" };
    var var1_4203164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0020" };
    var var1_4203164_bv64: bv64 := $R1:bv64 { .comment = "op: 0xd63f0020" };
    $R30: bv64 := 0x4022a0:bv64 { .comment = "op: 0xd63f0020" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0020" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0020" };
    $_PC: bv64 := var1_4203164_bv64:bv64 { .comment = "op: 0xd63f0020" };
    indirect call var1_4203164_bv64:bv64 ;
    goto(%__rfmtpad_55);
  ];
  block %__rfmtpad_59 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203152_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9003264" };
    store le $mem bvadd($R19:bv64, 0x30:bv64) extract(32, 0, $R4:bv64) 32 { .comment = "op: 0xb9003264" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4203156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203156_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4203156_bv64:bv64, bvshl(var2_4203156_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    goto(%__rfmtpad_29, %__rfmtpad_57);
  ];
  block %__rfmtpad_61 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R4: bv64 := zero_extend(32, var1_4203148_bv32:bv32);
    goto(%__rfmtpad_59);
  ];
  block %__rfmtpad_63 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R4: bv64 := zero_extend(32, var2_4203148_bv32:bv32);
    goto(%__rfmtpad_59);
  ];
  block %__rfmtpad_65 {.address = 0x40226c; .originalLabel = "APWFGD7pTyirlknXaFXTUg=="} [
    goto(%__rfmtpad_61, %__rfmtpad_63);
  ];
  block %__rfmtpad_67 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40226c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40226c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb050040" };
    var var1_4203116_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb050040" };
    var var2_4203116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb050040" };
    var var2_4203116_bv64: bv64 := $R5:bv64 { .comment = "op: 0xcb050040" };
    $R0: bv64 := bvadd(bvadd(var1_4203116_bv64:bv64, bvnot(bvshl(var2_4203116_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb050040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203120_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400265" };
    var var1_4203120_bv64: bv64 := $R19:bv64 { .comment = "op: 0x39400265" };
    var var2_4203120_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400265" };
    var var2_4203120_bv8: bv8 := load le $mem bvadd(var1_4203120_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400265" };
    $R5: bv64 := zero_extend(32, zero_extend(24, var2_4203120_bv8:bv8)) { .comment = "op: 0x39400265" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203124_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401261" };
    var var1_4203124_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9401261" };
    var var2_4203124_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401261" };
    var var2_4203124_bv64: bv64 := load le $mem bvadd(var1_4203124_bv64:bv64, 0x20:bv64) 64 { .comment = "op: 0xf9401261" };
    $R1: bv64 := var2_4203124_bv64:bv64 { .comment = "op: 0xf9401261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9341fc03" };
    var var1_4203128_bv64: bv64 := $R0:bv64 { .comment = "op: 0x9341fc03" };
    $R3: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0x8000000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4203128_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4203128_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0xffffffffffffffff:bv64)), 0x7fffffffffffffff:bv64)) { .comment = "op: 0x9341fc03" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203132_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030083" };
    var var1_4203132_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0xb030083" };
    var var2_4203132_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030083" };
    var var2_4203132_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb030083" };
    $R3: bv64 := zero_extend(32, bvadd(var1_4203132_bv32:bv32, bvshl(var2_4203132_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb030083" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203136_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000bf" };
    var var2_4203136_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R5:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R5:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710000bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710000bf" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203140_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000084" };
    var var1_4203140_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0xb000084" };
    var var2_4203140_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000084" };
    var var2_4203140_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb000084" };
    $R4: bv64 := zero_extend(32, bvadd(var1_4203140_bv32:bv32, bvshl(var2_4203140_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb000084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203144_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000a62" };
    store le $mem bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64 { .comment = "op: 0xf9000a62" };
    var var1_4203148_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a830084" };
    var var1_4203148_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x1a830084" };
    var var2_4203148_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a830084" };
    var var2_4203148_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x1a830084" };
    goto(%__rfmtpad_65);
  ];
  block %__rfmtpad_69 {.address = 0x40225c; .originalLabel = "6fMuNbjTTLOKY7Wm1sqqdQ=="} [
    assert eq($_PC:bv64, 0x40225c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40225c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203100_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000840" };
    var var2_4203100_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000840" };
    var var2_4203100_bv64: bv64 := $R2:bv64 { .comment = "op: 0x91000840" };
    $R0: bv64 := bvadd(var2_4203100_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000840" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var1_4203104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var2_4203104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e3" };
    var var2_4203104_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e3" };
    $R3: bv64 := bvor(var1_4203104_bv64:bv64, bvshl(var2_4203104_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203108_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb06001f" };
    var var2_4203108_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb06001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0:bv64), sign_extend(64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb06001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0:bv64), zero_extend(64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb06001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb06001f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R0:bv64, bvnot(bvshl($R6:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb06001f" };
    goto(%__rfmtpad_21, %__rfmtpad_67);
  ];
  block %__rfmtpad_71 {.address = 0x40222c; .originalLabel = "P2iiL4B+RLeWswQ6/4h97w=="} [
    goto(%__rfmtpad_69);
  ];
  block %__rfmtpad_73 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40222c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40222c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403004" };
    var var1_4203052_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9403004" };
    var var2_4203052_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403004" };
    var var2_4203052_bv32: bv32 := load le $mem bvadd(var1_4203052_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403004" };
    $R4: bv64 := zero_extend(32, var2_4203052_bv32:bv32) { .comment = "op: 0xb9403004" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var1_4203056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var2_4203056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e5" };
    var var2_4203056_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e5" };
    $R5: bv64 := bvor(var1_4203056_bv64:bv64, bvshl(var2_4203056_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := 0x0:bv64 { .comment = "op: 0x52800014" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var1_4203068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var2_4203068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var2_4203068_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x2a0103f5" };
    $R21: bv64 := zero_extend(32, bvor(var1_4203068_bv32:bv32, bvshl(var2_4203068_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0103f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R22: bv64 := 0x20:bv64 { .comment = "op: 0x52800416" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000006" };
    $_PC: bv64 := 0x40225c:bv64 { .comment = "op: 0x14000006" };
    goto(%__rfmtpad_71);
  ];
  block %__rfmtpad_basil_return_1 [
    return ();
  ]
];


proc @runelen_4210048 () -> ()
  { .name = "runelen"; .address = 0x403d80; .returnBlock = "runelen_basil_return_1" }
  require eq($_PC:bv64, 0x403d80:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %runelen_entry {.address = 0x403d80; .originalLabel = "o0lVyZ2GT4mJNVkb5e5Vuw=="} [
    assert eq($_PC:bv64, 0x403d80:bv64);
    $_PC: bv64 := 0x403d80:bv64;
    assert eq($_PC:bv64, 0x403d80:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d80:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210048_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf279201f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0xf279201f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0xf279201f" };
    $ZF: bv1 := booltobv1(eq(bvand($R0:bv64, 0xff80:bv64), 0x0:bv64)) { .comment = "op: 0xf279201f" };
    $NF: bv1 := extract(64, 63, bvand($R0:bv64, 0xff80:bv64)) { .comment = "op: 0xf279201f" };
    goto(%runelen_5, %runelen_15);
  ];
  block %runelen_3 {.address = 0x403d98; .originalLabel = "w1fa9bX/Rd6gpx7WiUy+uA=="} [
    goto(%runelen_basil_return_1);
  ];
  block %runelen_5 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403d98:bv64;
    assert eq($_PC:bv64, 0x403d98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d98:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    var var1_4210076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%runelen_3);
  ];
  block %runelen_7 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210064_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000800" };
    var var2_4210064_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000800" };
    var var2_4210064_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x11000800" };
    $R0: bv64 := zero_extend(32, bvadd(var2_4210064_bv32:bv32, 0x2:bv32)) { .comment = "op: 0x11000800" };
    var var1_4210068_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%runelen_basil_return_1);
  ];
  block %runelen_9 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := zero_extend(32, var1_4210060_bv32:bv32);
    goto(%runelen_7);
  ];
  block %runelen_11 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := zero_extend(32, bvadd(var2_4210060_bv32:bv32, 0x1:bv32));
    goto(%runelen_7);
  ];
  block %runelen_13 {.address = 0x403d88; .originalLabel = "2dYTRi+lRMWpZPJKOMfRHA=="} [
    goto(%runelen_9, %runelen_11);
  ];
  block %runelen_15 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403d88:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d88:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf275101f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0xf275101f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0xf275101f" };
    $ZF: bv1 := booltobv1(eq(bvand($R0:bv64, 0xf800:bv64), 0x0:bv64)) { .comment = "op: 0xf275101f" };
    $NF: bv1 := extract(64, 63, bvand($R0:bv64, 0xf800:bv64)) { .comment = "op: 0xf275101f" };
    var var1_4210060_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e0" };
    var var1_4210060_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e0" };
    var var2_4210060_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e0" };
    var var2_4210060_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e0" };
    goto(%runelen_13);
  ];
  block %runelen_basil_return_1 [
    return ();
  ]
];


proc @fullrune_4210160 () -> ()
  { .name = "fullrune"; .address = 0x403df0; .returnBlock = "fullrune_basil_return_1" }
  require eq($_PC:bv64, 0x403df0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %fullrune_entry {.address = 0x403df0; .originalLabel = "ycUhyOy1TNW1hp1YrdP0uw=="} [
    assert eq($_PC:bv64, 0x403df0:bv64);
    $_PC: bv64 := 0x403df0:bv64;
    assert eq($_PC:bv64, 0x403df0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403df0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210160_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    var var2_4210160_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100003f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100003f" };
    goto(%fullrune_7, %fullrune_35);
  ];
  block %fullrune_5 {.address = 0x403e24; .originalLabel = "5EEjDn06T7uckDBG/0Z4XA=="} [
    goto(%fullrune_basil_return_1);
  ];
  block %fullrune_7 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403e24:bv64;
    assert eq($_PC:bv64, 0x403e24:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403e24:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    var var1_4210216_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%fullrune_5);
  ];
  block %fullrune_9 {.address = 0x403e20; .originalLabel = "37D3T8jBSsKS8jy9CJ375Q=="} [
    assert eq($_PC:bv64, 0x403e20:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403e20:bv64)"; .label = "pc-tracking" };
    var var1_4210208_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%fullrune_basil_return_1);
  ];
  block %fullrune_11 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403e20:bv64;
    goto(%fullrune_9);
  ];
  block %fullrune_13 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403e20:bv64;
    goto(%fullrune_9);
  ];
  block %fullrune_15 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := zero_extend(32, var1_4210204_bv32:bv32);
    goto(%fullrune_9);
  ];
  block %fullrune_17 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := zero_extend(32, bvadd(var2_4210204_bv32:bv32, 0x1:bv32));
    goto(%fullrune_9);
  ];
  block %fullrune_19 [
    var var1_4210204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9fd7e0" };
    var var1_4210204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9fd7e0" };
    var var2_4210204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9fd7e0" };
    var var2_4210204_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9fd7e0" };
    goto(%fullrune_15, %fullrune_17);
  ];
  block %fullrune_21 [
    guard var1_4210200_bool:bool;
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffffffffffd:bv64), 0x1:bv64))));
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffd:bv64), 0x1:bv64))));
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32), 0x0:bv32));
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffd:bv32), 0x1:bv32));
    goto(%fullrune_19);
  ];
  block %fullrune_23 [
    guard boolnot(var1_4210200_bool:bool);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $VF: bv1 := 0x0:bv1;
    $CF: bv1 := 0x0:bv1;
    $ZF: bv1 := 0x0:bv1;
    $NF: bv1 := 0x0:bv1;
    goto(%fullrune_19);
  ];
  block %fullrune_25 {.address = 0x403e14; .originalLabel = "X29dhRTkQpaF9uR7DGYNOA=="} [
    goto(%fullrune_21, %fullrune_23);
  ];
  block %fullrune_27 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403e14:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403e14:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210196_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71037c5f" };
    var var2_4210196_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71037c5f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), 0xffffffffffffff20:bv64), 0x1:bv64)))) { .comment = "op: 0x71037c5f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), 0xffffff20:bv64), 0x1:bv64)))) { .comment = "op: 0x71037c5f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x71037c5f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)) { .comment = "op: 0x71037c5f" };
    var var1_4210200_bool: bool := booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)) { .comment = "op: 0x7a42c820" };
    goto(%fullrune_25);
  ];
  block %fullrune_29 {.address = 0x403e08; .originalLabel = "qPkCfVBVTliljf4DHC3G5Q=="} [
    goto(%fullrune_13, %fullrune_27);
  ];
  block %fullrune_31 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403e08:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403e08:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210188_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100043f" };
    var var2_4210188_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100043f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffffffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x7100043f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x7100043f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100043f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x7100043f" };
    goto(%fullrune_29);
  ];
  block %fullrune_33 {.address = 0x403df8; .originalLabel = "RZJ68TBARxS2z/njc0Y4MQ=="} [
    goto(%fullrune_11, %fullrune_31);
  ];
  block %fullrune_35 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403df8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403df8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400002" };
    var var1_4210168_bv64: bv64 := $R0:bv64 { .comment = "op: 0x39400002" };
    var var2_4210168_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400002" };
    var var2_4210168_bv8: bv8 := load le $mem bvadd(var1_4210168_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400002" };
    $R2: bv64 := zero_extend(32, zero_extend(24, var2_4210168_bv8:bv8)) { .comment = "op: 0x39400002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210176_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc5f" };
    var var2_4210176_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc5f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc5f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc5f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101fc5f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101fc5f" };
    goto(%fullrune_33);
  ];
  block %fullrune_basil_return_1 [
    return ();
  ]
];


proc @__fmtpad_4202756 () -> ()
  { .name = "__fmtpad"; .address = 0x402104; .returnBlock = "__fmtpad_basil_return_1" }
  require eq($_PC:bv64, 0x402104:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtpad_entry {.address = 0x402104; .originalLabel = "DS7w57znRnmBsFkYW6cA+Q=="} [
    assert eq($_PC:bv64, 0x402104:bv64);
    $_PC: bv64 := 0x402104:bv64;
    assert eq($_PC:bv64, 0x402104:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402104:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202756_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4202756_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4202756_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202760_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4202768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202768_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4202768_bv64:bv64, bvshl(var2_4202768_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411002" };
    var var1_4202772_bv64: bv64 := $R0:bv64 { .comment = "op: 0xa9411002" };
    var var2_4202772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411002" };
    var var2_4202772_bv64: bv64 := load le $mem bvadd(var1_4202772_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xa9411002" };
    var var3_4202772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411002" };
    var var3_4202772_bv64: bv64 := load le $mem bvadd(bvadd(var1_4202772_bv64:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9411002" };
    $R2: bv64 := var2_4202772_bv64:bv64 { .comment = "op: 0xa9411002" };
    $R4: bv64 := var3_4202772_bv64:bv64 { .comment = "op: 0xa9411002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202776_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    var var2_4202776_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100003f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100003f" };
    goto(%__fmtpad_11, %__fmtpad_75);
  ];
  block %__fmtpad_3 {.address = 0x40220c; .originalLabel = "/KBRai1RRXueP8BAvuy79g=="} [
    assert eq($_PC:bv64, 0x40220c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40220c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    unreachable;
  ];
  block %__fmtpad_5 {.address = 0x4021dc; .originalLabel = "XoaX0BnyRyWTkWUbgekuTA=="} [
    assert eq($_PC:bv64, 0x4021dc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021dc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202972_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4202972_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4202972_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4202972_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4202972_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4202972_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4202976_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4202976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4202976_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4202976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4202976_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4202976_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4202976_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4202976_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4202980_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtpad_basil_return_1);
  ];
  block %__fmtpad_7 {.address = 0x4021c8; .originalLabel = "HEhUdMFQRae912/mVNz4aA=="} [
    assert eq($_PC:bv64, 0x4021c8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021c8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403261" };
    var var1_4202952_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9403261" };
    var var2_4202952_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403261" };
    var var2_4202952_bv32: bv32 := load le $mem bvadd(var1_4202952_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403261" };
    $R1: bv64 := zero_extend(32, var2_4202952_bv32:bv32) { .comment = "op: 0xb9403261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202960_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000a62" };
    store le $mem bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64 { .comment = "op: 0xf9000a62" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030021" };
    var var1_4202964_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0xb030021" };
    var var2_4202964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030021" };
    var var2_4202964_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb030021" };
    $R1: bv64 := zero_extend(32, bvadd(var1_4202964_bv32:bv32, bvshl(var2_4202964_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb030021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9003261" };
    store le $mem bvadd($R19:bv64, 0x30:bv64) extract(32, 0, $R1:bv64) 32 { .comment = "op: 0xb9003261" };
    goto(%__fmtpad_5);
  ];
  block %__fmtpad_9 {.address = 0x402204; .originalLabel = "3H62rkqWRk6pRraIIw7uqA=="} [
    goto(%__fmtpad_7);
  ];
  block %__fmtpad_11 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402204:bv64;
    assert eq($_PC:bv64, 0x402204:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402204:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x0:bv64 { .comment = "op: 0x52800003" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff0" };
    $_PC: bv64 := 0x4021c8:bv64 { .comment = "op: 0x17fffff0" };
    goto(%__fmtpad_9);
  ];
  block %__fmtpad_13 {.address = 0x4021bc; .originalLabel = "nf2eBCNfQSG6AaT/w0tX3w=="} [
    assert eq($_PC:bv64, 0x4021bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021bc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a63" };
    var var1_4202940_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400a63" };
    var var2_4202940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a63" };
    var var2_4202940_bv64: bv64 := load le $mem bvadd(var1_4202940_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a63" };
    $R3: bv64 := var2_4202940_bv64:bv64 { .comment = "op: 0xf9400a63" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4202944_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4202944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4202944_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4202944_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4202944_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202948_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b030043" };
    var var1_4202948_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x4b030043" };
    var var2_4202948_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b030043" };
    var var2_4202948_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x4b030043" };
    $R3: bv64 := zero_extend(32, bvadd(bvadd(var1_4202948_bv32:bv32, bvnot(bvshl(var2_4202948_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b030043" };
    goto(%__fmtpad_7);
  ];
  block %__fmtpad_15 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4021bc:bv64;
    goto(%__fmtpad_13);
  ];
  block %__fmtpad_17 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtpad_71);
  ];
  block %__fmtpad_19 {.address = 0x402134; .originalLabel = "E5JMogjgRgyCkBTiqb4jsg=="} [
    goto(%__fmtpad_15, %__fmtpad_17);
  ];
  block %__fmtpad_21 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402134:bv64;
    assert eq($_PC:bv64, 0x402134:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402134:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202804_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4202804_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4202804_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x11000694" };
    $R20: bv64 := zero_extend(32, bvadd(var2_4202804_bv32:bv32, 0x1:bv32)) { .comment = "op: 0x11000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202808_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000016" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(8, 0, $R22:bv64) 8 { .comment = "op: 0x39000016" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e2" };
    var var1_4202812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e2" };
    var var2_4202812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e2" };
    var var2_4202812_bv64: bv64 := $R3:bv64 { .comment = "op: 0xaa0303e2" };
    $R2: bv64 := bvor(var1_4202812_bv64:bv64, bvshl(var2_4202812_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202816_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    var var2_4202816_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b1402bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b1402bf" };
    goto(%__fmtpad_19);
  ];
  block %__fmtpad_23 {.address = 0x4021f0; .originalLabel = "TAobG6oOSlOAnm+SfF4HBw=="} [
    assert eq($_PC:bv64, 0x4021f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4202992_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4202992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4202992_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4202992_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4202992_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff9" };
    $_PC: bv64 := 0x4021dc:bv64 { .comment = "op: 0x17fffff9" };
    goto(%__fmtpad_5);
  ];
  block %__fmtpad_25 {.address = 0x4021ec; .originalLabel = "m//XjzkpQ8me1kxMDgSgXw=="} [
    assert eq($_PC:bv64, 0x4021ec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021ec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202988_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000e60" };
    store le $mem bvadd($R19:bv64, 0x18:bv64) $R0:bv64 64 { .comment = "op: 0xf9000e60" };
    goto(%__fmtpad_23);
  ];
  block %__fmtpad_27 {.address = 0x4021fc; .originalLabel = "hmus1PL2Qw6iSG1+CQCWeQ=="} [
    goto(%__fmtpad_25);
  ];
  block %__fmtpad_29 [
    guard eq($R1:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4021fc:bv64;
    assert eq($_PC:bv64, 0x4021fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var1_4203004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var2_4203004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var2_4203004_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e0" };
    $R0: bv64 := bvor(var1_4203004_bv64:bv64, bvshl(var2_4203004_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffffb" };
    $_PC: bv64 := 0x4021ec:bv64 { .comment = "op: 0x17fffffb" };
    goto(%__fmtpad_27);
  ];
  block %__fmtpad_31 {.address = 0x4021e8; .originalLabel = "hwQK7LjPSbm0PzFr0T6TpA=="} [
    goto(%__fmtpad_25);
  ];
  block %__fmtpad_33 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4021e8:bv64;
    assert eq($_PC:bv64, 0x4021e8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021e8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202984_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a60" };
    var var1_4202984_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400a60" };
    var var2_4202984_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a60" };
    var var2_4202984_bv64: bv64 := load le $mem bvadd(var1_4202984_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a60" };
    $R0: bv64 := var2_4202984_bv64:bv64 { .comment = "op: 0xf9400a60" };
    goto(%__fmtpad_31);
  ];
  block %__fmtpad_35 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4021ec:bv64;
    goto(%__fmtpad_25);
  ];
  block %__fmtpad_37 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4021f0:bv64;
    goto(%__fmtpad_23);
  ];
  block %__fmtpad_39 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402148:bv64;
    goto(%__fmtpad_71);
  ];
  block %__fmtpad_41 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtpad_13);
  ];
  block %__fmtpad_43 {.address = 0x4021ac; .originalLabel = "+xSOcx7CQquJr+gDZVxwQA=="} [
    goto(%__fmtpad_39, %__fmtpad_41);
  ];
  block %__fmtpad_45 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4021ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021ac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202924_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4202924_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11000694" };
    var var2_4202924_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x11000694" };
    $R20: bv64 := zero_extend(32, bvadd(var2_4202924_bv32:bv32, 0x1:bv32)) { .comment = "op: 0x11000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202928_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000016" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(8, 0, $R22:bv64) 8 { .comment = "op: 0x39000016" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    var var2_4202932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b1402bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b1402bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b1402bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), bvnot(bvshl(extract(32, 0, $R20:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b1402bf" };
    goto(%__fmtpad_43);
  ];
  block %__fmtpad_47 {.address = 0x4021a8; .originalLabel = "Sy2pM8YuQFqir3uRhGnLnQ=="} [
    goto(%__fmtpad_37, %__fmtpad_45);
  ];
  block %__fmtpad_49 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4021a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4021a8:bv64)"; .label = "pc-tracking" };
    goto(%__fmtpad_47);
  ];
  block %__fmtpad_51 {.address = 0x402198; .originalLabel = "qlSkjWc5QVKixsdSLVEpJg=="} [
    goto(%__fmtpad_35, %__fmtpad_49);
  ];
  block %__fmtpad_53 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402198:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402198:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411260" };
    var var1_4202904_bv64: bv64 := $R19:bv64 { .comment = "op: 0xa9411260" };
    var var2_4202904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411260" };
    var var2_4202904_bv64: bv64 := load le $mem bvadd(var1_4202904_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xa9411260" };
    var var3_4202904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9411260" };
    var var3_4202904_bv64: bv64 := load le $mem bvadd(bvadd(var1_4202904_bv64:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9411260" };
    $R0: bv64 := var2_4202904_bv64:bv64 { .comment = "op: 0xa9411260" };
    $R4: bv64 := var3_4202904_bv64:bv64 { .comment = "op: 0xa9411260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000402" };
    var var2_4202908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000402" };
    var var2_4202908_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91000402" };
    $R2: bv64 := bvadd(var2_4202908_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000402" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04005f" };
    var var2_4202912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb04005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb04005f" };
    goto(%__fmtpad_51);
  ];
  block %__fmtpad_55 {.address = 0x402194; .originalLabel = "efnI4vgIRpCfmCTkW0WUyg=="} [
    assert eq($_PC:bv64, 0x402194:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402194:bv64)"; .label = "pc-tracking" };
    goto(%__fmtpad_33, %__fmtpad_53);
  ];
  block %__fmtpad_57 {.address = 0x402190; .originalLabel = "VZRBU19ASR+iPL6twqeXrw=="} [
    goto(%__fmtpad_55);
  ];
  block %__fmtpad_59 [
    guard boolnot(eq($R1:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402190:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402190:bv64)"; .label = "pc-tracking" };
    var var1_4202896_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0020" };
    var var1_4202896_bv64: bv64 := $R1:bv64 { .comment = "op: 0xd63f0020" };
    $R30: bv64 := 0x402194:bv64 { .comment = "op: 0xd63f0020" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0020" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0020" };
    $_PC: bv64 := var1_4202896_bv64:bv64 { .comment = "op: 0xd63f0020" };
    indirect call var1_4202896_bv64:bv64 ;
    goto(%__fmtpad_57);
  ];
  block %__fmtpad_61 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9003263" };
    store le $mem bvadd($R19:bv64, 0x30:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb9003263" };
    goto(%__fmtpad_29, %__fmtpad_59);
  ];
  block %__fmtpad_63 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, var1_4202884_bv32:bv32);
    goto(%__fmtpad_61);
  ];
  block %__fmtpad_65 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, var2_4202884_bv32:bv32);
    goto(%__fmtpad_61);
  ];
  block %__fmtpad_67 {.address = 0x402158; .originalLabel = "9yHxvmNAT/mQU5bkahetuw=="} [
    goto(%__fmtpad_63, %__fmtpad_65);
  ];
  block %__fmtpad_69 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402158:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402158:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202840_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a64" };
    var var1_4202840_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400a64" };
    var var2_4202840_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a64" };
    var var2_4202840_bv64: bv64 := load le $mem bvadd(var1_4202840_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a64" };
    $R4: bv64 := var2_4202840_bv64:bv64 { .comment = "op: 0xf9400a64" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202844_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000a62" };
    store le $mem bvadd($R19:bv64, 0x10:bv64) $R2:bv64 64 { .comment = "op: 0xf9000a62" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202848_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403263" };
    var var1_4202848_bv64: bv64 := $R19:bv64 { .comment = "op: 0xb9403263" };
    var var2_4202848_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403263" };
    var var2_4202848_bv32: bv32 := load le $mem bvadd(var1_4202848_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403263" };
    $R3: bv64 := zero_extend(32, var2_4202848_bv32:bv32) { .comment = "op: 0xb9403263" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4202852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202852_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4202852_bv64:bv64, bvshl(var2_4202852_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202856_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb040044" };
    var var1_4202856_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb040044" };
    var var2_4202856_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb040044" };
    var var2_4202856_bv64: bv64 := $R4:bv64 { .comment = "op: 0xcb040044" };
    $R4: bv64 := bvadd(bvadd(var1_4202856_bv64:bv64, bvnot(bvshl(var2_4202856_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb040044" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202860_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400266" };
    var var1_4202860_bv64: bv64 := $R19:bv64 { .comment = "op: 0x39400266" };
    var var2_4202860_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400266" };
    var var2_4202860_bv8: bv8 := load le $mem bvadd(var1_4202860_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400266" };
    $R6: bv64 := zero_extend(32, zero_extend(24, var2_4202860_bv8:bv8)) { .comment = "op: 0x39400266" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401261" };
    var var1_4202864_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9401261" };
    var var2_4202864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401261" };
    var var2_4202864_bv64: bv64 := load le $mem bvadd(var1_4202864_bv64:bv64, 0x20:bv64) 64 { .comment = "op: 0xf9401261" };
    $R1: bv64 := var2_4202864_bv64:bv64 { .comment = "op: 0xf9401261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202868_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9341fc85" };
    var var1_4202868_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9341fc85" };
    $R5: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0x8000000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4202868_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4202868_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0xffffffffffffffff:bv64)), 0x7fffffffffffffff:bv64)) { .comment = "op: 0x9341fc85" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202872_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb050065" };
    var var1_4202872_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb050065" };
    var var2_4202872_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb050065" };
    var var2_4202872_bv32: bv32 := extract(32, 0, $R5:bv64) { .comment = "op: 0xb050065" };
    $R5: bv64 := zero_extend(32, bvadd(var1_4202872_bv32:bv32, bvshl(var2_4202872_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb050065" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202876_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000df" };
    var var2_4202876_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000df" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R6:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000df" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R6:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000df" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710000df" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710000df" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb040063" };
    var var1_4202880_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb040063" };
    var var2_4202880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb040063" };
    var var2_4202880_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0xb040063" };
    $R3: bv64 := zero_extend(32, bvadd(var1_4202880_bv32:bv32, bvshl(var2_4202880_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb040063" };
    var var1_4202884_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a850063" };
    var var1_4202884_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x1a850063" };
    var var2_4202884_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a850063" };
    var var2_4202884_bv32: bv32 := extract(32, 0, $R5:bv64) { .comment = "op: 0x1a850063" };
    goto(%__fmtpad_67);
  ];
  block %__fmtpad_71 {.address = 0x402148; .originalLabel = "qTWWnSClRBekGloLlPK2Iw=="} [
    assert eq($_PC:bv64, 0x402148:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402148:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202824_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000443" };
    var var2_4202824_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000443" };
    var var2_4202824_bv64: bv64 := $R2:bv64 { .comment = "op: 0x91000443" };
    $R3: bv64 := bvadd(var2_4202824_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000443" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var1_4202828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var2_4202828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e0" };
    var var2_4202828_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e0" };
    $R0: bv64 := bvor(var1_4202828_bv64:bv64, bvshl(var2_4202828_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04007f" };
    var var2_4202832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04007f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R3:bv64), sign_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04007f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R3:bv64), zero_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04007f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb04007f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R3:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb04007f" };
    goto(%__fmtpad_21, %__fmtpad_69);
  ];
  block %__fmtpad_73 {.address = 0x402120; .originalLabel = "DFJDq7UCSvqjtzrNDB8+OQ=="} [
    goto(%__fmtpad_71);
  ];
  block %__fmtpad_75 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402120:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402120:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := 0x0:bv64 { .comment = "op: 0x52800014" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var1_4202792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var2_4202792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f5" };
    var var2_4202792_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x2a0103f5" };
    $R21: bv64 := zero_extend(32, bvor(var1_4202792_bv32:bv32, bvshl(var2_4202792_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0103f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R22: bv64 := 0x20:bv64 { .comment = "op: 0x52800416" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000006" };
    $_PC: bv64 := 0x402148:bv64 { .comment = "op: 0x14000006" };
    goto(%__fmtpad_73);
  ];
  block %__fmtpad_basil_return_1 [
    return ();
  ]
];


proc @runetochar_4209936 () -> ()
  { .name = "runetochar"; .address = 0x403d10; .returnBlock = "runetochar_basil_return_1" }
  require eq($_PC:bv64, 0x403d10:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %runetochar_entry {.address = 0x403d10; .originalLabel = "Rkek/d08TK2mkJ7PEcm6mg=="} [
    assert eq($_PC:bv64, 0x403d10:bv64);
    $_PC: bv64 := 0x403d10:bv64;
    assert eq($_PC:bv64, 0x403d10:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d10:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79400023" };
    var var1_4209936_bv64: bv64 := $R1:bv64 { .comment = "op: 0x79400023" };
    var var2_4209936_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x79400023" };
    var var2_4209936_bv16: bv16 := load le $mem bvadd(var1_4209936_bv64:bv64, 0x0:bv64) 16 { .comment = "op: 0x79400023" };
    $R3: bv64 := zero_extend(32, zero_extend(16, var2_4209936_bv16:bv16)) { .comment = "op: 0x79400023" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e4" };
    var var1_4209940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e4" };
    var var2_4209940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e4" };
    var var2_4209940_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e4" };
    $R4: bv64 := bvor(var1_4209940_bv64:bv64, bvshl(var2_4209940_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf101fc7f" };
    var var2_4209944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf101fc7f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R3:bv64), 0xffffffffffffffffffffffffffffff80:bv128), 0x1:bv128)))) { .comment = "op: 0xf101fc7f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R3:bv64), 0xffffffffffffff80:bv128), 0x1:bv128)))) { .comment = "op: 0xf101fc7f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf101fc7f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R3:bv64, 0xffffffffffffff80:bv64), 0x1:bv64)) { .comment = "op: 0xf101fc7f" };
    goto(%runetochar_7, %runetochar_19);
  ];
  block %runetochar_5 {.address = 0x403d70; .originalLabel = "dbfTbPBuS/6evdJ8ZtRBTg=="} [
    goto(%runetochar_basil_return_1);
  ];
  block %runetochar_7 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403d70:bv64;
    assert eq($_PC:bv64, 0x403d70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000083" };
    store le $mem bvadd($R4:bv64, 0x0:bv64) extract(8, 0, $R3:bv64) 8 { .comment = "op: 0x39000083" };
    var var1_4210040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%runetochar_5);
  ];
  block %runetochar_9 {.address = 0x403d5c; .originalLabel = "12j+o4ojT8Cxuy4zHI98mQ=="} [
    goto(%runetochar_basil_return_1);
  ];
  block %runetochar_11 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403d5c:bv64;
    assert eq($_PC:bv64, 0x403d5c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d5c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210012_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x321a6421" };
    var var1_4210012_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x321a6421" };
    $R1: bv64 := zero_extend(32, bvor(var1_4210012_bv32:bv32, 0xffffffc0:bv32)) { .comment = "op: 0x321a6421" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x2:bv64 { .comment = "op: 0x52800040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210020_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000081" };
    store le $mem bvadd($R4:bv64, 0x0:bv64) extract(8, 0, $R1:bv64) 8 { .comment = "op: 0x39000081" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000482" };
    store le $mem bvadd($R4:bv64, 0x1:bv64) extract(8, 0, $R2:bv64) 8 { .comment = "op: 0x39000482" };
    var var1_4210028_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%runetochar_9);
  ];
  block %runetochar_13 {.address = 0x403d38; .originalLabel = "e43rkKlMT5u6ocaQNeP+Wg=="} [
    goto(%runetochar_basil_return_1);
  ];
  block %runetochar_15 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403d38:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d38:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x934cfc63" };
    var var1_4209976_bv64: bv64 := $R3:bv64 { .comment = "op: 0x934cfc63" };
    $R3: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0xfff0000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4209976_bv64:bv64, zero_extend(52, 0xc:bv12)), bvshl(var1_4209976_bv64:bv64, zero_extend(48, 0x34:bv16))), 0xffffffffffffffff:bv64)), 0xfffffffffffff:bv64)) { .comment = "op: 0x934cfc63" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12001421" };
    var var1_4209980_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x12001421" };
    $R1: bv64 := zero_extend(32, bvand(var1_4209980_bv32:bv32, 0x3f:bv32)) { .comment = "op: 0x12001421" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209984_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x321b6863" };
    var var1_4209984_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x321b6863" };
    $R3: bv64 := zero_extend(32, bvor(var1_4209984_bv32:bv32, 0xffffffe0:bv32)) { .comment = "op: 0x321b6863" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209988_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x32196021" };
    var var1_4209988_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x32196021" };
    $R1: bv64 := zero_extend(32, bvor(var1_4209988_bv32:bv32, 0xffffff80:bv32)) { .comment = "op: 0x32196021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x3:bv64 { .comment = "op: 0x52800060" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209996_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000083" };
    store le $mem bvadd($R4:bv64, 0x0:bv64) extract(8, 0, $R3:bv64) 8 { .comment = "op: 0x39000083" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210000_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000481" };
    store le $mem bvadd($R4:bv64, 0x1:bv64) extract(8, 0, $R1:bv64) 8 { .comment = "op: 0x39000481" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4210004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000882" };
    store le $mem bvadd($R4:bv64, 0x2:bv64) extract(8, 0, $R2:bv64) 8 { .comment = "op: 0x39000882" };
    var var1_4210008_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%runetochar_13);
  ];
  block %runetochar_17 {.address = 0x403d20; .originalLabel = "SQuuQwpeTxqk2HBFOIg7tg=="} [
    goto(%runetochar_11, %runetochar_15);
  ];
  block %runetochar_19 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403d20:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d20:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9346fc61" };
    var var1_4209952_bv64: bv64 := $R3:bv64 { .comment = "op: 0x9346fc61" };
    $R1: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0xfc00000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4209952_bv64:bv64, zero_extend(52, 0x6:bv12)), bvshl(var1_4209952_bv64:bv64, zero_extend(48, 0x3a:bv16))), 0xffffffffffffffff:bv64)), 0x3ffffffffffffff:bv64)) { .comment = "op: 0x9346fc61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209956_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12001462" };
    var var1_4209956_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x12001462" };
    $R2: bv64 := zero_extend(32, bvand(var1_4209956_bv32:bv32, 0x3f:bv32)) { .comment = "op: 0x12001462" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209960_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x32190042" };
    var var1_4209960_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x32190042" };
    $R2: bv64 := zero_extend(32, bvor(var1_4209960_bv32:bv32, 0x80:bv32)) { .comment = "op: 0x32190042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x13001c21" };
    var var1_4209964_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x13001c21" };
    $R1: bv64 := zero_extend(32, bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4209964_bv32:bv32, zero_extend(20, 0x7:bv12))))), 0xffffff00:bv32), bvand(bvor(bvand(0x0:bv32, 0xffffff00:bv32), bvand(var1_4209964_bv32:bv32, 0xff:bv32)), 0xff:bv32))) { .comment = "op: 0x13001c21" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf11ffc7f" };
    var var2_4209968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf11ffc7f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R3:bv64), 0xfffffffffffffffffffffffffffff800:bv128), 0x1:bv128)))) { .comment = "op: 0xf11ffc7f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R3:bv64), 0xfffffffffffff800:bv128), 0x1:bv128)))) { .comment = "op: 0xf11ffc7f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf11ffc7f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R3:bv64, 0xfffffffffffff800:bv64), 0x1:bv64)) { .comment = "op: 0xf11ffc7f" };
    goto(%runetochar_17);
  ];
  block %runetochar_basil_return_1 [
    return ();
  ]
];


proc @__fmtflush_4202032 () -> ()
  { .name = "__fmtflush"; .address = 0x401e30; .returnBlock = "__fmtflush_basil_return_1" }
  require eq($_PC:bv64, 0x401e30:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtflush_entry {.address = 0x401e30; .originalLabel = "Osy3QCRQRpSd5aY0vW+qkQ=="} [
    assert eq($_PC:bv64, 0x401e30:bv64);
    $_PC: bv64 := 0x401e30:bv64;
    assert eq($_PC:bv64, 0x401e30:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e30:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202032_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9be7bfd" };
    var var1_4202032_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffe0:bv64) $R29:bv64 64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9be7bfd" };
    $R31: bv64 := bvadd(var1_4202032_bv64:bv64, 0xffffffffffffffe0:bv64) { .comment = "op: 0xa9be7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202044_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f4" };
    var var1_4202044_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f4" };
    var var2_4202044_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f4" };
    var var2_4202044_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0203f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4202044_bv32:bv32, bvshl(var2_4202044_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0203f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202048_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403003" };
    var var1_4202048_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9403003" };
    var var2_4202048_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403003" };
    var var2_4202048_bv32: bv32 := load le $mem bvadd(var1_4202048_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403003" };
    $R3: bv64 := zero_extend(32, var2_4202048_bv32:bv32) { .comment = "op: 0xb9403003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400802" };
    var var1_4202052_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9400802" };
    var var2_4202052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400802" };
    var var2_4202052_bv64: bv64 := load le $mem bvadd(var1_4202052_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400802" };
    $R2: bv64 := var2_4202052_bv64:bv64 { .comment = "op: 0xf9400802" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000801" };
    store le $mem bvadd($R0:bv64, 0x10:bv64) $R1:bv64 64 { .comment = "op: 0xf9000801" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400006" };
    var var1_4202060_bv64: bv64 := $R0:bv64 { .comment = "op: 0x39400006" };
    var var2_4202060_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400006" };
    var var2_4202060_bv8: bv8 := load le $mem bvadd(var1_4202060_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400006" };
    $R6: bv64 := zero_extend(32, zero_extend(24, var2_4202060_bv8:bv8)) { .comment = "op: 0x39400006" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202064_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4202064_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202064_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202064_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4202064_bv64:bv64, bvshl(var2_4202064_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202068_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020022" };
    var var1_4202068_bv64: bv64 := $R1:bv64 { .comment = "op: 0xcb020022" };
    var var2_4202068_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020022" };
    var var2_4202068_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb020022" };
    $R2: bv64 := bvadd(bvadd(var1_4202068_bv64:bv64, bvnot(bvshl(var2_4202068_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb020022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401005" };
    var var1_4202072_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9401005" };
    var var2_4202072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401005" };
    var var2_4202072_bv64: bv64 := load le $mem bvadd(var1_4202072_bv64:bv64, 0x20:bv64) 64 { .comment = "op: 0xf9401005" };
    $R5: bv64 := var2_4202072_bv64:bv64 { .comment = "op: 0xf9401005" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9341fc44" };
    var var1_4202076_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9341fc44" };
    $R4: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0x8000000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4202076_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4202076_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0xffffffffffffffff:bv64)), 0x7fffffffffffffff:bv64)) { .comment = "op: 0x9341fc44" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202080_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb040064" };
    var var1_4202080_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb040064" };
    var var2_4202080_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb040064" };
    var var2_4202080_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0xb040064" };
    $R4: bv64 := zero_extend(32, bvadd(var1_4202080_bv32:bv32, bvshl(var2_4202080_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb040064" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000df" };
    var var2_4202084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710000df" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R6:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000df" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R6:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710000df" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710000df" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R6:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710000df" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020063" };
    var var1_4202088_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb020063" };
    var var2_4202088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020063" };
    var var2_4202088_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0xb020063" };
    $R3: bv64 := zero_extend(32, bvadd(var1_4202088_bv32:bv32, bvshl(var2_4202088_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb020063" };
    var var1_4202092_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a840063" };
    var var1_4202092_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x1a840063" };
    var var2_4202092_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a840063" };
    var var2_4202092_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x1a840063" };
    goto(%__fmtflush_33, %__fmtflush_35);
  ];
  block %__fmtflush_3 {.address = 0x401ebc; .originalLabel = "CnYrdlULTXKzT/SwRDDytA=="} [
    assert eq($_PC:bv64, 0x401ebc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ebc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    unreachable;
  ];
  block %__fmtflush_5 {.address = 0x401ea0; .originalLabel = "NeHg5jr5S2iOYgrYE99m9w=="} [
    assert eq($_PC:bv64, 0x401ea0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ea0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202144_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000e60" };
    store le $mem bvadd($R19:bv64, 0x18:bv64) $R0:bv64 64 { .comment = "op: 0xf9000e60" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4202148_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4202148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4202148_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4202148_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4202148_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0xd2800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4202156_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202156_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202156_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4202156_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4202156_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4202156_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4202160_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtflush_basil_return_1);
  ];
  block %__fmtflush_7 {.address = 0x401eb4; .originalLabel = "6mjBoDNETzeKu6rbf5EehQ=="} [
    goto(%__fmtflush_5);
  ];
  block %__fmtflush_9 [
    guard eq($R5:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401eb4:bv64;
    assert eq($_PC:bv64, 0x401eb4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401eb4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103e0" };
    var var1_4202164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103e0" };
    var var2_4202164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103e0" };
    var var2_4202164_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103e0" };
    $R0: bv64 := bvor(var1_4202164_bv64:bv64, bvshl(var2_4202164_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103e0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffffa" };
    $_PC: bv64 := 0x401ea0:bv64 { .comment = "op: 0x17fffffa" };
    goto(%__fmtflush_7);
  ];
  block %__fmtflush_11 {.address = 0x401e9c; .originalLabel = "efOr7SRNTOe6fyc81id1CQ=="} [
    goto(%__fmtflush_5);
  ];
  block %__fmtflush_13 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401e9c:bv64;
    assert eq($_PC:bv64, 0x401e9c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e9c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a60" };
    var var1_4202140_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400a60" };
    var var2_4202140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400a60" };
    var var2_4202140_bv64: bv64 := load le $mem bvadd(var1_4202140_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400a60" };
    $R0: bv64 := var2_4202140_bv64:bv64 { .comment = "op: 0xf9400a60" };
    goto(%__fmtflush_11);
  ];
  block %__fmtflush_15 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ea0:bv64;
    goto(%__fmtflush_5);
  ];
  block %__fmtflush_17 {.address = 0x401e90; .originalLabel = "qSRuZhqqTGGJ7hNPACoVnQ=="} [
    goto(%__fmtflush_basil_return_1);
  ];
  block %__fmtflush_19 [
    guard boolnot(boolnot(eq($CF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401e90:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e90:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4202128_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4202128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4202128_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4202128_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4202128_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4202132_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202132_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202132_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4202132_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4202132_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4202132_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4202136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtflush_17);
  ];
  block %__fmtflush_21 {.address = 0x401e80; .originalLabel = "Ue+kE7XBR2+qP6SRRVVT4w=="} [
    goto(%__fmtflush_15, %__fmtflush_19);
  ];
  block %__fmtflush_23 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401e80:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e80:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9410660" };
    var var1_4202112_bv64: bv64 := $R19:bv64 { .comment = "op: 0xa9410660" };
    var var2_4202112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9410660" };
    var var2_4202112_bv64: bv64 := load le $mem bvadd(var1_4202112_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xa9410660" };
    var var3_4202112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9410660" };
    var var3_4202112_bv64: bv64 := load le $mem bvadd(bvadd(var1_4202112_bv64:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9410660" };
    $R0: bv64 := var2_4202112_bv64:bv64 { .comment = "op: 0xa9410660" };
    $R1: bv64 := var3_4202112_bv64:bv64 { .comment = "op: 0xa9410660" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b34c014" };
    var var2_4202116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b34c014" };
    var var2_4202116_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b34c014" };
    var var3_4202116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b34c014" };
    var var3_4202116_bv64: bv64 := $R20:bv64 { .comment = "op: 0x8b34c014" };
    $R20: bv64 := bvadd(var2_4202116_bv64:bv64, sign_extend(32, extract(32, 0, var3_4202116_bv64:bv64))) { .comment = "op: 0x8b34c014" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202120_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14003f" };
    var var2_4202120_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb14003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb14003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb14003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R20:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb14003f" };
    goto(%__fmtflush_21);
  ];
  block %__fmtflush_25 {.address = 0x401e7c; .originalLabel = "Ma8pmuzBSiOV12t6DG5RDA=="} [
    assert eq($_PC:bv64, 0x401e7c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e7c:bv64)"; .label = "pc-tracking" };
    goto(%__fmtflush_13, %__fmtflush_23);
  ];
  block %__fmtflush_27 {.address = 0x401e78; .originalLabel = "G5PSTIeeRIeJzlZa7BOmeQ=="} [
    goto(%__fmtflush_25);
  ];
  block %__fmtflush_29 [
    guard boolnot(eq($R5:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401e78:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e78:bv64)"; .label = "pc-tracking" };
    var var1_4202104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f00a0" };
    var var1_4202104_bv64: bv64 := $R5:bv64 { .comment = "op: 0xd63f00a0" };
    $R30: bv64 := 0x401e7c:bv64 { .comment = "op: 0xd63f00a0" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f00a0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f00a0" };
    $_PC: bv64 := var1_4202104_bv64:bv64 { .comment = "op: 0xd63f00a0" };
    indirect call var1_4202104_bv64:bv64 ;
    goto(%__fmtflush_27);
  ];
  block %__fmtflush_31 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9003003" };
    store le $mem bvadd($R0:bv64, 0x30:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb9003003" };
    goto(%__fmtflush_9, %__fmtflush_29);
  ];
  block %__fmtflush_33 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, var1_4202092_bv32:bv32);
    goto(%__fmtflush_31);
  ];
  block %__fmtflush_35 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, var2_4202092_bv32:bv32);
    goto(%__fmtflush_31);
  ];
  block %__fmtflush_basil_return_1 [
    return ();
  ]
];


proc @chartorune_4209760 () -> ()
  { .name = "chartorune"; .address = 0x403c60; .returnBlock = "chartorune_basil_return_1" }
  require eq($_PC:bv64, 0x403c60:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %chartorune_entry {.address = 0x403c60; .originalLabel = "+s65+r9uRzKHgPS/OxqX3g=="} [
    assert eq($_PC:bv64, 0x403c60:bv64);
    $_PC: bv64 := 0x403c60:bv64;
    assert eq($_PC:bv64, 0x403c60:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c60:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209760_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400022" };
    var var1_4209760_bv64: bv64 := $R1:bv64 { .comment = "op: 0x39400022" };
    var var2_4209760_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400022" };
    var var2_4209760_bv8: bv8 := load le $mem bvadd(var1_4209760_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400022" };
    $R2: bv64 := zero_extend(32, zero_extend(24, var2_4209760_bv8:bv8)) { .comment = "op: 0x39400022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e3" };
    var var1_4209764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e3" };
    var var2_4209764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e3" };
    var var2_4209764_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e3" };
    $R3: bv64 := bvor(var1_4209764_bv64:bv64, bvshl(var2_4209764_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209768_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc5f" };
    var var2_4209768_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc5f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc5f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc5f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101fc5f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101fc5f" };
    goto(%chartorune_7, %chartorune_57);
  ];
  block %chartorune_5 {.address = 0x403cc0; .originalLabel = "++IaH6xuTqyFASJGXNRAlQ=="} [
    goto(%chartorune_basil_return_1);
  ];
  block %chartorune_7 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cc0:bv64;
    assert eq($_PC:bv64, 0x403cc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403cc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209856_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var1_4209856_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var2_4209856_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var2_4209856_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0203e1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4209856_bv32:bv32, bvshl(var2_4209856_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0203e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000061" };
    store le $mem bvadd($R3:bv64, 0x0:bv64) extract(16, 0, $R1:bv64) 16 { .comment = "op: 0x79000061" };
    var var1_4209868_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%chartorune_5);
  ];
  block %chartorune_9 {.address = 0x403cb8; .originalLabel = "T2j45CSHSgGUPDoAJalwDw=="} [
    assert eq($_PC:bv64, 0x403cb8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403cb8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209848_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000061" };
    store le $mem bvadd($R3:bv64, 0x0:bv64) extract(16, 0, $R1:bv64) 16 { .comment = "op: 0x79000061" };
    var var1_4209852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%chartorune_basil_return_1);
  ];
  block %chartorune_11 {.address = 0x403cb0; .originalLabel = "lvZ7ZLAwQZuXzLUtAZrL0w=="} [
    assert eq($_PC:bv64, 0x403cb0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403cb0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0xfffd:bv64 { .comment = "op: 0x529fffa1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    goto(%chartorune_9);
  ];
  block %chartorune_13 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cb0:bv64;
    goto(%chartorune_11);
  ];
  block %chartorune_15 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cb8:bv64;
    goto(%chartorune_9);
  ];
  block %chartorune_17 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cb8:bv64;
    goto(%chartorune_9);
  ];
  block %chartorune_19 {.address = 0x403d00; .originalLabel = "p+4IhkykSJmgEaFceff9eA=="} [
    goto(%chartorune_9);
  ];
  block %chartorune_21 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403d00:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403d00:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209920_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12003c41" };
    var var1_4209920_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x12003c41" };
    $R1: bv64 := zero_extend(32, bvand(var1_4209920_bv32:bv32, 0xffff:bv32)) { .comment = "op: 0x12003c41" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x3:bv64 { .comment = "op: 0x52800060" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffec" };
    $_PC: bv64 := 0x403cb8:bv64 { .comment = "op: 0x17ffffec" };
    goto(%chartorune_19);
  ];
  block %chartorune_23 {.address = 0x403cf0; .originalLabel = "8Oqn1B3bQeC9ilWP5MvO9g=="} [
    goto(%chartorune_17, %chartorune_21);
  ];
  block %chartorune_25 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403cf0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403cf0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209904_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a021882" };
    var var1_4209904_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x2a021882" };
    var var2_4209904_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a021882" };
    var var2_4209904_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a021882" };
    $R2: bv64 := zero_extend(32, bvor(var1_4209904_bv32:bv32, bvshl(var2_4209904_bv32:bv32, zero_extend(20, 0x6:bv12)))) { .comment = "op: 0x2a021882" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209908_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0218a2" };
    var var1_4209908_bv32: bv32 := extract(32, 0, $R5:bv64) { .comment = "op: 0x2a0218a2" };
    var var2_4209908_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0218a2" };
    var var2_4209908_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0218a2" };
    $R2: bv64 := zero_extend(32, bvor(var1_4209908_bv32:bv32, bvshl(var2_4209908_bv32:bv32, zero_extend(20, 0x6:bv12)))) { .comment = "op: 0x2a0218a2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209912_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7215105f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0x7215105f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0x7215105f" };
    $ZF: bv1 := booltobv1(eq(bvand(extract(32, 0, $R2:bv64), 0xf800:bv32), 0x0:bv32)) { .comment = "op: 0x7215105f" };
    $NF: bv1 := extract(32, 31, bvand(extract(32, 0, $R2:bv64), 0xf800:bv32)) { .comment = "op: 0x7215105f" };
    goto(%chartorune_23);
  ];
  block %chartorune_27 [
    guard boolnot(var1_4209896_bool:bool);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(extract(32, 0, $R6:bv64))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), sign_extend(32, bvnot(extract(32, 0, $R6:bv64)))), 0x1:bv64))));
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(extract(32, 0, $R6:bv64))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), zero_extend(32, bvnot(extract(32, 0, $R6:bv64)))), 0x1:bv64))));
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(extract(32, 0, $R6:bv64))), 0x1:bv32), 0x0:bv32));
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), bvnot(extract(32, 0, $R6:bv64))), 0x1:bv32));
    goto(%chartorune_15, %chartorune_25);
  ];
  block %chartorune_29 [
    guard boolnot(boolnot(var1_4209896_bool:bool));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $VF: bv1 := 0x0:bv1;
    $CF: bv1 := 0x0:bv1;
    $ZF: bv1 := 0x0:bv1;
    $NF: bv1 := 0x0:bv1;
    goto(%chartorune_15, %chartorune_25);
  ];
  block %chartorune_31 {.address = 0x403cd0; .originalLabel = "dBoJ6m+YT8+W2jBvWsqtnA=="} [
    goto(%chartorune_27, %chartorune_29);
  ];
  block %chartorune_33 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cd0:bv64;
    assert eq($_PC:bv64, 0x403cd0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403cd0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209872_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400825" };
    var var1_4209872_bv64: bv64 := $R1:bv64 { .comment = "op: 0x39400825" };
    var var2_4209872_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400825" };
    var var2_4209872_bv8: bv8 := load le $mem bvadd(var1_4209872_bv64:bv64, 0x2:bv64) 8 { .comment = "op: 0x39400825" };
    $R5: bv64 := zero_extend(32, zero_extend(24, var2_4209872_bv8:bv8)) { .comment = "op: 0x39400825" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R6: bv64 := 0xef:bv64 { .comment = "op: 0x52801de6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0xfffd:bv64 { .comment = "op: 0x529fffa1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209888_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x521900a5" };
    var var1_4209888_bv32: bv32 := extract(32, 0, $R5:bv64) { .comment = "op: 0x521900a5" };
    $R5: bv64 := zero_extend(32, bvxor(var1_4209888_bv32:bv32, 0x80:bv32)) { .comment = "op: 0x521900a5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209892_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100fcbf" };
    var var2_4209892_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100fcbf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R5:bv64)), 0xffffffffffffffc0:bv64), 0x1:bv64)))) { .comment = "op: 0x7100fcbf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R5:bv64)), 0xffffffc0:bv64), 0x1:bv64)))) { .comment = "op: 0x7100fcbf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100fcbf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R5:bv64), 0xffffffc0:bv32), 0x1:bv32)) { .comment = "op: 0x7100fcbf" };
    var var1_4209896_bool: bool := booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)) { .comment = "op: 0x7a469040" };
    goto(%chartorune_31);
  ];
  block %chartorune_35 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cb0:bv64;
    goto(%chartorune_11);
  ];
  block %chartorune_37 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403cb8:bv64;
    goto(%chartorune_9);
  ];
  block %chartorune_39 {.address = 0x403ca4; .originalLabel = "nThZSoy2Qy22Zrw41XjyKA=="} [
    goto(%chartorune_9);
  ];
  block %chartorune_41 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403ca4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403ca4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209828_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12002841" };
    var var1_4209828_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x12002841" };
    $R1: bv64 := zero_extend(32, bvand(var1_4209828_bv32:bv32, 0x7ff:bv32)) { .comment = "op: 0x12002841" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x2:bv64 { .comment = "op: 0x52800040" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000003" };
    $_PC: bv64 := 0x403cb8:bv64 { .comment = "op: 0x14000003" };
    goto(%chartorune_39);
  ];
  block %chartorune_43 {.address = 0x403c90; .originalLabel = "G8ZDeF+bQAaE0/VU+EbAKg=="} [
    goto(%chartorune_37, %chartorune_41);
  ];
  block %chartorune_45 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403c90:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c90:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209808_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a021882" };
    var var1_4209808_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x2a021882" };
    var var2_4209808_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a021882" };
    var var2_4209808_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a021882" };
    $R2: bv64 := zero_extend(32, bvor(var1_4209808_bv32:bv32, bvshl(var2_4209808_bv32:bv32, zero_extend(20, 0x6:bv12)))) { .comment = "op: 0x2a021882" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0xfffd:bv64 { .comment = "op: 0x529fffa1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209820_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x72190c5f" };
    $VF: bv1 := 0x0:bv1 { .comment = "op: 0x72190c5f" };
    $CF: bv1 := 0x0:bv1 { .comment = "op: 0x72190c5f" };
    $ZF: bv1 := booltobv1(eq(bvand(extract(32, 0, $R2:bv64), 0x780:bv32), 0x0:bv32)) { .comment = "op: 0x72190c5f" };
    $NF: bv1 := extract(32, 31, bvand(extract(32, 0, $R2:bv64), 0x780:bv32)) { .comment = "op: 0x72190c5f" };
    goto(%chartorune_43);
  ];
  block %chartorune_47 {.address = 0x403c88; .originalLabel = "e4M8xOwXSXyU/V9xKAe/Vg=="} [
    goto(%chartorune_35, %chartorune_45);
  ];
  block %chartorune_49 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403c88:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c88:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209800_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7102fc5f" };
    var var2_4209800_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7102fc5f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), 0xffffffffffffff40:bv64), 0x1:bv64)))) { .comment = "op: 0x7102fc5f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), 0xffffff40:bv64), 0x1:bv64)))) { .comment = "op: 0x7102fc5f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7102fc5f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff40:bv32), 0x1:bv32)) { .comment = "op: 0x7102fc5f" };
    goto(%chartorune_47);
  ];
  block %chartorune_51 {.address = 0x403c80; .originalLabel = "+bQcsNWXR7qPbYYLKzimBA=="} [
    goto(%chartorune_33, %chartorune_49);
  ];
  block %chartorune_53 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403c80:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c80:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71037c5f" };
    var var2_4209792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71037c5f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R2:bv64)), 0xffffffffffffff20:bv64), 0x1:bv64)))) { .comment = "op: 0x71037c5f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R2:bv64)), 0xffffff20:bv64), 0x1:bv64)))) { .comment = "op: 0x71037c5f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x71037c5f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R2:bv64), 0xffffff20:bv32), 0x1:bv32)) { .comment = "op: 0x71037c5f" };
    goto(%chartorune_51);
  ];
  block %chartorune_55 {.address = 0x403c70; .originalLabel = "pkKUFl5BQ5e5C4uEMbZz1Q=="} [
    goto(%chartorune_13, %chartorune_53);
  ];
  block %chartorune_57 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403c70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209776_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400424" };
    var var1_4209776_bv64: bv64 := $R1:bv64 { .comment = "op: 0x39400424" };
    var var2_4209776_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400424" };
    var var2_4209776_bv8: bv8 := load le $mem bvadd(var1_4209776_bv64:bv64, 0x1:bv64) 8 { .comment = "op: 0x39400424" };
    $R4: bv64 := zero_extend(32, zero_extend(24, var2_4209776_bv8:bv8)) { .comment = "op: 0x39400424" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209780_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x52190084" };
    var var1_4209780_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x52190084" };
    $R4: bv64 := zero_extend(32, bvxor(var1_4209780_bv32:bv32, 0x80:bv32)) { .comment = "op: 0x52190084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209784_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100fc9f" };
    var var2_4209784_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100fc9f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R4:bv64)), 0xffffffffffffffc0:bv64), 0x1:bv64)))) { .comment = "op: 0x7100fc9f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R4:bv64)), 0xffffffc0:bv64), 0x1:bv64)))) { .comment = "op: 0x7100fc9f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100fc9f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffffc0:bv32), 0x1:bv32)) { .comment = "op: 0x7100fc9f" };
    goto(%chartorune_55);
  ];
  block %chartorune_basil_return_1 [
    return ();
  ]
];


proc @__fmtcpy_4203296 () -> ()
  { .name = "__fmtcpy"; .address = 0x402320; .returnBlock = "__fmtcpy_basil_return_1" }
  require eq($_PC:bv64, 0x402320:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtcpy_entry {.address = 0x402320; .originalLabel = "onW0wUQSS+CWRE3FG7sZVA=="} [
    assert eq($_PC:bv64, 0x402320:bv64);
    $_PC: bv64 := 0x402320:bv64;
    assert eq($_PC:bv64, 0x402320:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402320:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9b97bfd" };
    var var1_4203296_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9b97bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffff90:bv64) $R29:bv64 64 { .comment = "op: 0xa9b97bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffff90:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9b97bfd" };
    $R31: bv64 := bvadd(var1_4203296_bv64:bv64, 0xffffffffffffff90:bv64) { .comment = "op: 0xa9b97bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203300_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x40:bv64) $R25:bv64 64 { .comment = "op: 0xa9046bf9" };
    store le $stack bvadd(bvadd($R31:bv64, 0x40:bv64), 0x8:bv64) $R26:bv64 64 { .comment = "op: 0xa9046bf9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R26: bv64 := 0x0:bv64 { .comment = "op: 0x5280001a" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203312_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403419" };
    var var1_4203312_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9403419" };
    var var2_4203312_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9403419" };
    var var2_4203312_bv64: bv64 := load le $mem bvadd(var1_4203312_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403419" };
    $R25: bv64 := var2_4203312_bv64:bv64 { .comment = "op: 0xf9403419" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var1_4203320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4203320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4203320_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f3" };
    $R19: bv64 := bvor(var1_4203320_bv64:bv64, bvshl(var2_4203320_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var1_4203328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4203328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4203328_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f5" };
    $R21: bv64 := bvor(var1_4203328_bv64:bv64, bvshl(var2_4203328_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c036" };
    var var2_4203332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c036" };
    var var2_4203332_bv64: bv64 := $R1:bv64 { .comment = "op: 0x8b23c036" };
    var var3_4203332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b23c036" };
    var var3_4203332_bv64: bv64 := $R3:bv64 { .comment = "op: 0x8b23c036" };
    $R22: bv64 := bvadd(var2_4203332_bv64:bv64, sign_extend(32, extract(32, 0, var3_4203332_bv64:bv64))) { .comment = "op: 0x8b23c036" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64 { .comment = "op: 0xa90363f7" };
    store le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) $R24:bv64 64 { .comment = "op: 0xa90363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f8" };
    var var1_4203340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f8" };
    var var2_4203340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f8" };
    var var2_4203340_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0203f8" };
    $R24: bv64 := zero_extend(32, bvor(var1_4203340_bv32:bv32, bvshl(var2_4203340_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0203f8" };
    goto(%__fmtcpy_229, %__fmtcpy_233);
  ];
  block %__fmtcpy_5 {.address = 0x4025e0; .originalLabel = "pib8MtlLR+aXFply555dLw=="} [
    assert eq($_PC:bv64, 0x4025e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025e0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204000_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x131f7c00" };
    var var1_4204000_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x131f7c00" };
    $R0: bv64 := zero_extend(32, bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4204000_bv32:bv32, zero_extend(20, 0x1f:bv12))))), 0xfffffffe:bv32), bvand(bvor(bvand(0x0:bv32, 0x0:bv32), bvand(bvor(bvlshr(var1_4204000_bv32:bv32, zero_extend(22, 0x1f:bv10)), bvshl(var1_4204000_bv32:bv32, zero_extend(16, 0x1:bv16))), 0xffffffff:bv32)), 0x1:bv32))) { .comment = "op: 0x131f7c00" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4204004_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4204004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4204004_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4204004_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4204004_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204008_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4204008_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4204008_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4204008_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4204008_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4204008_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var1_4204012_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xa94363f7" };
    var var2_4204012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var2_4204012_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94363f7" };
    $R23: bv64 := var1_4204012_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $R24: bv64 := var2_4204012_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204016_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var1_4204016_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x40:bv64) 64 { .comment = "op: 0xa9446bf9" };
    var var2_4204016_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var2_4204016_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x40:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9446bf9" };
    $R25: bv64 := var1_4204016_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $R26: bv64 := var2_4204016_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204020_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9402bfb" };
    var var1_4204020_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x50:bv64) 64 { .comment = "op: 0xf9402bfb" };
    $R27: bv64 := var1_4204020_bv64:bv64 { .comment = "op: 0xf9402bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var1_4204024_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4204024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4204024_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c77bfd" };
    var var3_4204024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var3_4204024_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c77bfd" };
    $R29: bv64 := var2_4204024_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R30: bv64 := var3_4204024_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R31: bv64 := bvadd(var1_4204024_bv64:bv64, 0x70:bv64) { .comment = "op: 0xa8c77bfd" };
    var var1_4204028_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtcpy_basil_return_1);
  ];
  block %__fmtcpy_7 {.address = 0x4025d4; .originalLabel = "uZ05ixJVQAqtWpq5zeE97Q=="} [
    goto(%__fmtcpy_5);
  ];
  block %__fmtcpy_9 [
    guard boolnot(eq($R25:bv64, 0x0:bv64));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4025d4:bv64;
    assert eq($_PC:bv64, 0x4025d4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025d4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203988_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var1_4203988_bv32: bv32 := extract(32, 0, $R26:bv64) { .comment = "op: 0x4b180341" };
    var var2_4203988_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var2_4203988_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x4b180341" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var1_4203988_bv32:bv32, bvnot(bvshl(var2_4203988_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b180341" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203992_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203992_bv64:bv64, bvshl(var2_4203992_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x4025e0:bv64 { .comment = "op: 0x97fffeca" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffeca" };
    $_PC: bv64 := 0x402104:bv64 { .comment = "op: 0x97fffeca" };
    call @__fmtpad_4202756 ();
    goto(%__fmtcpy_7);
  ];
  block %__fmtcpy_11 {.address = 0x4024f4; .originalLabel = "LSCXsGFKQyeMBZ7+4Rh+xA=="} [
    assert eq($_PC:bv64, 0x4024f4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024f4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4203764_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4203764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4203764_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4203764_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4203764_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4203768_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4203768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4203768_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4203768_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4203768_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var1_4203772_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xa94363f7" };
    var var2_4203772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var2_4203772_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94363f7" };
    $R23: bv64 := var1_4203772_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $R24: bv64 := var2_4203772_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203776_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var1_4203776_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x40:bv64) 64 { .comment = "op: 0xa9446bf9" };
    var var2_4203776_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var2_4203776_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x40:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9446bf9" };
    $R25: bv64 := var1_4203776_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $R26: bv64 := var2_4203776_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var1_4203780_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4203780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4203780_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c77bfd" };
    var var3_4203780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var3_4203780_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c77bfd" };
    $R29: bv64 := var2_4203780_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R30: bv64 := var3_4203780_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R31: bv64 := bvadd(var1_4203780_bv64:bv64, 0x70:bv64) { .comment = "op: 0xa8c77bfd" };
    var var1_4203784_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtcpy_basil_return_1);
  ];
  block %__fmtcpy_13 {.address = 0x4024ec; .originalLabel = "K/b5ZEWmRQeVD7xUL17wdA=="} [
    assert eq($_PC:bv64, 0x4024ec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024ec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203756_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9402bfb" };
    var var1_4203756_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x50:bv64) 64 { .comment = "op: 0xf9402bfb" };
    $R27: bv64 := var1_4203756_bv64:bv64 { .comment = "op: 0xf9402bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    goto(%__fmtcpy_11);
  ];
  block %__fmtcpy_15 [
    guard boolnot(boolnot(eq($R25:bv64, 0x0:bv64)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_13);
  ];
  block %__fmtcpy_17 {.address = 0x4024d8; .originalLabel = "3c6lsNijTBmrodhQeVV4Mw=="} [
    assert eq($_PC:bv64, 0x4024d8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024d8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94032a0" };
    var var1_4203736_bv64: bv64 := $R21:bv64 { .comment = "op: 0xb94032a0" };
    var var2_4203736_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94032a0" };
    var var2_4203736_bv32: bv32 := load le $mem bvadd(var1_4203736_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb94032a0" };
    $R0: bv64 := zero_extend(32, var2_4203736_bv32:bv32) { .comment = "op: 0xb94032a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203740_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000abb" };
    store le $mem bvadd($R21:bv64, 0x10:bv64) $R27:bv64 64 { .comment = "op: 0xf9000abb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203744_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb010000" };
    var var1_4203744_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb010000" };
    var var2_4203744_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb010000" };
    var var2_4203744_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0xb010000" };
    $R0: bv64 := zero_extend(32, bvadd(var1_4203744_bv32:bv32, bvshl(var2_4203744_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb010000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90032a0" };
    store le $mem bvadd($R21:bv64, 0x30:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb90032a0" };
    goto(%__fmtcpy_9, %__fmtcpy_15);
  ];
  block %__fmtcpy_19 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4024d8:bv64;
    goto(%__fmtcpy_17);
  ];
  block %__fmtcpy_21 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4024a0:bv64;
    goto(%__fmtcpy_97);
  ];
  block %__fmtcpy_23 {.address = 0x4024d0; .originalLabel = "lfR5/qYfR3mr0TINP2N0TQ=="} [
    assert eq($_PC:bv64, 0x4024d0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024d0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203728_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400aa1" };
    var var1_4203728_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400aa1" };
    var var2_4203728_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400aa1" };
    var var2_4203728_bv64: bv64 := load le $mem bvadd(var1_4203728_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400aa1" };
    $R1: bv64 := var2_4203728_bv64:bv64 { .comment = "op: 0xf9400aa1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203732_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b010361" };
    var var1_4203732_bv32: bv32 := extract(32, 0, $R27:bv64) { .comment = "op: 0x4b010361" };
    var var2_4203732_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b010361" };
    var var2_4203732_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x4b010361" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var1_4203732_bv32:bv32, bvnot(bvshl(var2_4203732_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b010361" };
    goto(%__fmtcpy_17);
  ];
  block %__fmtcpy_25 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_23);
  ];
  block %__fmtcpy_27 {.address = 0x4024c8; .originalLabel = "5QDIJ7x/R9GygBqPGRYWfw=="} [
    assert eq($_PC:bv64, 0x4024c8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024c8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203720_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71000694" };
    var var2_4203720_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x71000694" };
    var var2_4203720_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x71000694" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, var2_4203720_bv32:bv32), 0xfffffffffffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x71000694" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, var2_4203720_bv32:bv32), 0xfffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x71000694" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x71000694" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x71000694" };
    $R20: bv64 := zero_extend(32, bvadd(bvadd(var2_4203720_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x71000694" };
    goto(%__fmtcpy_21, %__fmtcpy_25);
  ];
  block %__fmtcpy_29 {.address = 0x402580; .originalLabel = "U61eho9TSZ+vlkC6UEw8VQ=="} [
    assert eq($_PC:bv64, 0x402580:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402580:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c37b" };
    var var2_4203904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c37b" };
    var var2_4203904_bv64: bv64 := $R27:bv64 { .comment = "op: 0x8b20c37b" };
    var var3_4203904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c37b" };
    var var3_4203904_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c37b" };
    $R27: bv64 := bvadd(var2_4203904_bv64:bv64, sign_extend(32, extract(32, 0, var3_4203904_bv64:bv64))) { .comment = "op: 0x8b20c37b" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd1" };
    $_PC: bv64 := 0x4024c8:bv64 { .comment = "op: 0x17ffffd1" };
    goto(%__fmtcpy_27);
  ];
  block %__fmtcpy_31 {.address = 0x402570; .originalLabel = "BEAl6mEQQ2imOFbVRVZeug=="} [
    goto(%__fmtcpy_29);
  ];
  block %__fmtcpy_33 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402570:bv64;
    assert eq($_PC:bv64, 0x402570:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402570:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e0" };
    var var1_4203888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e0" };
    var var2_4203888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e0" };
    var var2_4203888_bv64: bv64 := $R27:bv64 { .comment = "op: 0xaa1b03e0" };
    $R0: bv64 := bvor(var1_4203888_bv64:bv64, bvshl(var2_4203888_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1b03e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203892_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9101bbe1" };
    $R1: bv64 := bvadd($R31:bv64, 0x6e:bv64) { .comment = "op: 0x9101bbe1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x6e:bv64) extract(16, 0, $R4:bv64) 16 { .comment = "op: 0x7900dfe4" };
    $R30: bv64 := 0x402580:bv64 { .comment = "op: 0x940005e5" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940005e5" };
    $_PC: bv64 := 0x403d10:bv64 { .comment = "op: 0x940005e5" };
    call @runetochar_4209936 ();
    goto(%__fmtcpy_31);
  ];
  block %__fmtcpy_35 {.address = 0x4024c4; .originalLabel = "6mAf3mYXTn6vO/lfsdnxpg=="} [
    assert eq($_PC:bv64, 0x4024c4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024c4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38001764" };
    var var1_4203716_bv64: bv64 := $R27:bv64 { .comment = "op: 0x38001764" };
    var var2_4203716_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x38001764" };
    var var2_4203716_bv8: bv8 := extract(8, 0, $R4:bv64) { .comment = "op: 0x38001764" };
    store le $mem var1_4203716_bv64:bv64 var2_4203716_bv8:bv8 8 { .comment = "op: 0x38001764" };
    $R27: bv64 := bvadd(var1_4203716_bv64:bv64, 0x1:bv64) { .comment = "op: 0x38001764" };
    goto(%__fmtcpy_27);
  ];
  block %__fmtcpy_37 {.address = 0x402568; .originalLabel = "mWPz7DcmQTKj4HLIhakeAg=="} [
    goto(%__fmtcpy_35);
  ];
  block %__fmtcpy_39 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402568:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402568:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12001c84" };
    var var1_4203880_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x12001c84" };
    $R4: bv64 := zero_extend(32, bvand(var1_4203880_bv32:bv32, 0xff:bv32)) { .comment = "op: 0x12001c84" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd6" };
    $_PC: bv64 := 0x4024c4:bv64 { .comment = "op: 0x17ffffd6" };
    goto(%__fmtcpy_37);
  ];
  block %__fmtcpy_41 {.address = 0x40255c; .originalLabel = "eRHFp4R+S7ijeECbbHQMzg=="} [
    assert eq($_PC:bv64, 0x40255c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40255c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203868_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x7940dbe4" };
    var var1_4203868_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x6c:bv64) 16 { .comment = "op: 0x7940dbe4" };
    $R4: bv64 := zero_extend(32, zero_extend(16, var1_4203868_bv16:bv16)) { .comment = "op: 0x7940dbe4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203872_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc9f" };
    var var2_4203872_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc9f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R4:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc9f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R4:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc9f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101fc9f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101fc9f" };
    goto(%__fmtcpy_33, %__fmtcpy_39);
  ];
  block %__fmtcpy_43 [
    guard eq($CF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40255c:bv64;
    goto(%__fmtcpy_41);
  ];
  block %__fmtcpy_45 {.address = 0x402600; .originalLabel = "j+25wKkqQXWXRZbqBIbKVw=="} [
    assert eq($_PC:bv64, 0x402600:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402600:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4204032_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9402bfb" };
    var var1_4204032_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x50:bv64) 64 { .comment = "op: 0xf9402bfb" };
    $R27: bv64 := var1_4204032_bv64:bv64 { .comment = "op: 0xf9402bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffbb" };
    $_PC: bv64 := 0x4024f4:bv64 { .comment = "op: 0x17ffffbb" };
    goto(%__fmtcpy_11);
  ];
  block %__fmtcpy_47 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402600:bv64;
    goto(%__fmtcpy_45);
  ];
  block %__fmtcpy_49 {.address = 0x40259c; .originalLabel = "ybpE763UTCWAcEqvHX1D6Q=="} [
    goto(%__fmtcpy_41);
  ];
  block %__fmtcpy_51 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40259c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40259c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203932_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400eb7" };
    var var1_4203932_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400eb7" };
    var var2_4203932_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400eb7" };
    var var2_4203932_bv64: bv64 := load le $mem bvadd(var1_4203932_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400eb7" };
    $R23: bv64 := var2_4203932_bv64:bv64 { .comment = "op: 0xf9400eb7" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffef" };
    $_PC: bv64 := 0x40255c:bv64 { .comment = "op: 0x17ffffef" };
    goto(%__fmtcpy_49);
  ];
  block %__fmtcpy_53 {.address = 0x402594; .originalLabel = "HZFOKF4IQPSWgEGo4mthwA=="} [
    assert eq($_PC:bv64, 0x402594:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402594:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003fb" };
    var var1_4203924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003fb" };
    var var2_4203924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003fb" };
    var var2_4203924_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003fb" };
    $R27: bv64 := bvor(var1_4203924_bv64:bv64, bvshl(var2_4203924_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003fb" };
    goto(%__fmtcpy_47, %__fmtcpy_51);
  ];
  block %__fmtcpy_55 {.address = 0x402588; .originalLabel = "/MVRWt9cSFiVRhuM69U0lw=="} [
    goto(%__fmtcpy_53);
  ];
  block %__fmtcpy_57 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402588:bv64;
    assert eq($_PC:bv64, 0x402588:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402588:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e1" };
    var var1_4203912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e1" };
    var var2_4203912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1b03e1" };
    var var2_4203912_bv64: bv64 := $R27:bv64 { .comment = "op: 0xaa1b03e1" };
    $R1: bv64 := bvor(var1_4203912_bv64:bv64, bvshl(var2_4203912_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1b03e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203916_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203916_bv64:bv64, bvshl(var2_4203916_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x402594:bv64 { .comment = "op: 0x97fffe28" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe28" };
    $_PC: bv64 := 0x401e30:bv64 { .comment = "op: 0x97fffe28" };
    call @__fmtflush_4202032 ();
    goto(%__fmtcpy_55);
  ];
  block %__fmtcpy_59 [
    guard boolnot(boolnot(eq($CF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_41);
  ];
  block %__fmtcpy_61 {.address = 0x40254c; .originalLabel = "7REkp/GmTcyLG7vKM591hQ=="} [
    assert eq($_PC:bv64, 0x40254c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40254c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e2" };
    var var1_4203852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e2" };
    var var2_4203852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e2" };
    var var2_4203852_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003e2" };
    $R2: bv64 := zero_extend(32, bvor(var1_4203852_bv32:bv32, bvshl(var2_4203852_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203856_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c360" };
    var var2_4203856_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c360" };
    var var2_4203856_bv64: bv64 := $R27:bv64 { .comment = "op: 0x8b20c360" };
    var var3_4203856_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c360" };
    var var3_4203856_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c360" };
    $R0: bv64 := bvadd(var2_4203856_bv64:bv64, sign_extend(32, extract(32, 0, var3_4203856_bv64:bv64))) { .comment = "op: 0x8b20c360" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203860_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0002ff" };
    var var2_4203860_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0002ff" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R23:bv64), sign_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0002ff" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R23:bv64), zero_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0002ff" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb0002ff" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R23:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb0002ff" };
    goto(%__fmtcpy_57, %__fmtcpy_59);
  ];
  block %__fmtcpy_63 {.address = 0x402544; .originalLabel = "mlsiXBIMTJ+v+Y7RISTFFQ=="} [
    assert eq($_PC:bv64, 0x402544:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402544:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203844_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x92403c00" };
    var var1_4203844_bv64: bv64 := $R0:bv64 { .comment = "op: 0x92403c00" };
    $R0: bv64 := bvand(var1_4203844_bv64:bv64, 0xffff:bv64) { .comment = "op: 0x92403c00" };
    $R30: bv64 := 0x40254c:bv64 { .comment = "op: 0x9400060e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400060e" };
    $_PC: bv64 := 0x403d80:bv64 { .comment = "op: 0x9400060e" };
    call @runelen_4210048 ();
    goto(%__fmtcpy_61);
  ];
  block %__fmtcpy_65 {.address = 0x402540; .originalLabel = "sBMfbvG6QHqI0jF8cHuNfw=="} [
    goto(%__fmtcpy_63);
  ];
  block %__fmtcpy_67 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402540:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402540:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203840_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x7940dbe0" };
    var var1_4203840_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x6c:bv64) 16 { .comment = "op: 0x7940dbe0" };
    $R0: bv64 := zero_extend(32, zero_extend(16, var1_4203840_bv16:bv16)) { .comment = "op: 0x7940dbe0" };
    goto(%__fmtcpy_65);
  ];
  block %__fmtcpy_69 {.address = 0x402530; .originalLabel = "HCluRd6gSi+IqEqyN8vLzQ=="} [
    assert eq($_PC:bv64, 0x402530:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402530:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203824_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var2_4203824_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var2_4203824_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b20c273" };
    var var3_4203824_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var3_4203824_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c273" };
    $R19: bv64 := bvadd(var2_4203824_bv64:bv64, sign_extend(32, extract(32, 0, var3_4203824_bv64:bv64))) { .comment = "op: 0x8b20c273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000f61" };
    var var2_4203828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000f61" };
    var var2_4203828_bv64: bv64 := $R27:bv64 { .comment = "op: 0x91000f61" };
    $R1: bv64 := bvadd(var2_4203828_bv64:bv64, 0x3:bv64) { .comment = "op: 0x91000f61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0102ff" };
    var var2_4203832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0102ff" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R23:bv64), sign_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0102ff" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R23:bv64), zero_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0102ff" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb0102ff" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb0102ff" };
    goto(%__fmtcpy_43, %__fmtcpy_67);
  ];
  block %__fmtcpy_71 {.address = 0x402524; .originalLabel = "2akhd/Q4QiaY+S65ERYXgQ=="} [
    assert eq($_PC:bv64, 0x402524:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402524:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4203812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4203812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4203812_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4203812_bv64:bv64, bvshl(var2_4203812_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203816_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9101b3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x6c:bv64) { .comment = "op: 0x9101b3e0" };
    $R30: bv64 := 0x402530:bv64 { .comment = "op: 0x940005cd" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940005cd" };
    $_PC: bv64 := 0x403c60:bv64 { .comment = "op: 0x940005cd" };
    call @chartorune_4209760 ();
    goto(%__fmtcpy_69);
  ];
  block %__fmtcpy_73 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402524:bv64;
    goto(%__fmtcpy_71);
  ];
  block %__fmtcpy_75 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4024d0:bv64;
    goto(%__fmtcpy_23);
  ];
  block %__fmtcpy_77 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_71);
  ];
  block %__fmtcpy_79 {.address = 0x402520; .originalLabel = "MQ4XAbmISYe/1nlPKK0fGw=="} [
    assert eq($_PC:bv64, 0x402520:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402520:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_75, %__fmtcpy_77);
  ];
  block %__fmtcpy_81 {.address = 0x402518; .originalLabel = "GWLvSwOrR/WeWvnjzVKr0g=="} [
    goto(%__fmtcpy_79);
  ];
  block %__fmtcpy_83 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402518:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402518:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4203800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203800_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4203800_bv64:bv64, bvshl(var2_4203800_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $R30: bv64 := 0x402520:bv64 { .comment = "op: 0x94000635" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000635" };
    $_PC: bv64 := 0x403df0:bv64 { .comment = "op: 0x94000635" };
    call @fullrune_4210160 ();
    goto(%__fmtcpy_81);
  ];
  block %__fmtcpy_85 {.address = 0x40250c; .originalLabel = "39gFkPCoTmy7KTe7fSBMhw=="} [
    goto(%__fmtcpy_73, %__fmtcpy_83);
  ];
  block %__fmtcpy_87 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40250c:bv64;
    assert eq($_PC:bv64, 0x40250c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40250c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203788_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb1302c1" };
    var var1_4203788_bv64: bv64 := $R22:bv64 { .comment = "op: 0xcb1302c1" };
    var var2_4203788_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb1302c1" };
    var var2_4203788_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb1302c1" };
    $R1: bv64 := bvadd(bvadd(var1_4203788_bv64:bv64, bvnot(bvshl(var2_4203788_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb1302c1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203792_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100083f" };
    var var2_4203792_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100083f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), 0xfffffffffffffffffffffffffffffffd:bv128), 0x1:bv128)))) { .comment = "op: 0xf100083f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), 0xfffffffffffffffd:bv128), 0x1:bv128)))) { .comment = "op: 0xf100083f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100083f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)) { .comment = "op: 0xf100083f" };
    goto(%__fmtcpy_85);
  ];
  block %__fmtcpy_89 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402544:bv64;
    goto(%__fmtcpy_63);
  ];
  block %__fmtcpy_91 [
    guard boolnot(boolnot(eq($CF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_35);
  ];
  block %__fmtcpy_93 {.address = 0x4024b4; .originalLabel = "P0saBHYuQDum6W06doOvlA=="} [
    goto(%__fmtcpy_89, %__fmtcpy_91);
  ];
  block %__fmtcpy_95 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4024b4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024b4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000f61" };
    var var2_4203700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000f61" };
    var var2_4203700_bv64: bv64 := $R27:bv64 { .comment = "op: 0x91000f61" };
    $R1: bv64 := bvadd(var2_4203700_bv64:bv64, 0x3:bv64) { .comment = "op: 0x91000f61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000673" };
    var var2_4203704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000673" };
    var var2_4203704_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91000673" };
    $R19: bv64 := bvadd(var2_4203704_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000673" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0102ff" };
    var var2_4203708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb0102ff" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R23:bv64), sign_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0102ff" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R23:bv64), zero_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb0102ff" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb0102ff" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R23:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb0102ff" };
    goto(%__fmtcpy_93);
  ];
  block %__fmtcpy_97 {.address = 0x4024a0; .originalLabel = "UsbFs05DSfWqt0TNKwPKpw=="} [
    assert eq($_PC:bv64, 0x4024a0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4024a0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203680_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400264" };
    var var1_4203680_bv64: bv64 := $R19:bv64 { .comment = "op: 0x39400264" };
    var var2_4203680_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400264" };
    var var2_4203680_bv8: bv8 := load le $mem bvadd(var1_4203680_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400264" };
    $R4: bv64 := zero_extend(32, zero_extend(24, var2_4203680_bv8:bv8)) { .comment = "op: 0x39400264" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x6c:bv64) extract(16, 0, $R4:bv64) 16 { .comment = "op: 0x7900dbe4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203688_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0403e0" };
    var var1_4203688_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0403e0" };
    var var2_4203688_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0403e0" };
    var var2_4203688_bv32: bv32 := extract(32, 0, $R4:bv64) { .comment = "op: 0x2a0403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4203688_bv32:bv32, bvshl(var2_4203688_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203692_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc9f" };
    var var2_4203692_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fc9f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R4:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc9f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R4:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fc9f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101fc9f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R4:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101fc9f" };
    goto(%__fmtcpy_87, %__fmtcpy_95);
  ];
  block %__fmtcpy_99 {.address = 0x40249c; .originalLabel = "y/JelsTYQdGI00wUEenVEQ=="} [
    goto(%__fmtcpy_97);
  ];
  block %__fmtcpy_101 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40249c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40249c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_99);
  ];
  block %__fmtcpy_103 {.address = 0x402480; .originalLabel = "a42wscR+RnW56sJttImZ+Q=="} [
    assert eq($_PC:bv64, 0x402480:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402480:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203648_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400eb7" };
    var var1_4203648_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400eb7" };
    var var2_4203648_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400eb7" };
    var var2_4203648_bv64: bv64 := load le $mem bvadd(var1_4203648_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400eb7" };
    $R23: bv64 := var2_4203648_bv64:bv64 { .comment = "op: 0xf9400eb7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x50:bv64) $R27:bv64 64 { .comment = "op: 0xf9002bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203656_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400abb" };
    var var1_4203656_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400abb" };
    var var2_4203656_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400abb" };
    var var2_4203656_bv64: bv64 := load le $mem bvadd(var1_4203656_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400abb" };
    $R27: bv64 := var2_4203656_bv64:bv64 { .comment = "op: 0xf9400abb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203660_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f4" };
    var var1_4203660_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f4" };
    var var2_4203660_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f4" };
    var var2_4203660_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x2a1803f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4203660_bv32:bv32, bvshl(var2_4203660_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1803f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x0:bv64 { .comment = "op: 0x52800001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203668_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100031f" };
    var var2_4203668_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100031f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R24:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100031f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R24:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100031f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100031f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100031f" };
    goto(%__fmtcpy_19, %__fmtcpy_101);
  ];
  block %__fmtcpy_105 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402480:bv64;
    goto(%__fmtcpy_103);
  ];
  block %__fmtcpy_107 {.address = 0x4025b4; .originalLabel = "2eXDspDHQJ+X6/nRZPRLkw=="} [
    goto(%__fmtcpy_11);
  ];
  block %__fmtcpy_109 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4025b4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025b4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffcf" };
    $_PC: bv64 := 0x4024f4:bv64 { .comment = "op: 0x17ffffcf" };
    goto(%__fmtcpy_107);
  ];
  block %__fmtcpy_111 {.address = 0x4025b0; .originalLabel = "IknPtOEHQeqPjsisjg1zgQ=="} [
    assert eq($_PC:bv64, 0x4025b0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025b0:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_105, %__fmtcpy_109);
  ];
  block %__fmtcpy_113 {.address = 0x4025a4; .originalLabel = "j7ss0twBTWOr3lt0EEMwZQ=="} [
    goto(%__fmtcpy_111);
  ];
  block %__fmtcpy_115 [
    guard eq($R25:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4025a4:bv64;
    assert eq($_PC:bv64, 0x4025a4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025a4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203940_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var1_4203940_bv32: bv32 := extract(32, 0, $R26:bv64) { .comment = "op: 0x4b180341" };
    var var2_4203940_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var2_4203940_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x4b180341" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var1_4203940_bv32:bv32, bvnot(bvshl(var2_4203940_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b180341" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203944_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203944_bv64:bv64, bvshl(var2_4203944_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x4025b0:bv64 { .comment = "op: 0x97fffed6" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffed6" };
    $_PC: bv64 := 0x402104:bv64 { .comment = "op: 0x97fffed6" };
    call @__fmtpad_4202756 ();
    goto(%__fmtcpy_113);
  ];
  block %__fmtcpy_117 [
    guard boolnot(eq($R25:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_103);
  ];
  block %__fmtcpy_119 {.address = 0x40247c; .originalLabel = "hevCqvNPRua77D0QG9MY5g=="} [
    goto(%__fmtcpy_115, %__fmtcpy_117);
  ];
  block %__fmtcpy_121 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40247c:bv64;
    assert eq($_PC:bv64, 0x40247c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40247c:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_119);
  ];
  block %__fmtcpy_123 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402600:bv64;
    goto(%__fmtcpy_45);
  ];
  block %__fmtcpy_125 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4023c0:bv64;
    goto(%__fmtcpy_187);
  ];
  block %__fmtcpy_127 [
    guard eq($R25:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4024ec:bv64;
    goto(%__fmtcpy_13);
  ];
  block %__fmtcpy_129 {.address = 0x40245c; .originalLabel = "+7wxJjpOT+Kjd2Xox1F8Zw=="} [
    assert eq($_PC:bv64, 0x40245c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40245c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203612_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x131f7c00" };
    var var1_4203612_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x131f7c00" };
    $R0: bv64 := zero_extend(32, bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4203612_bv32:bv32, zero_extend(20, 0x1f:bv12))))), 0xfffffffe:bv32), bvand(bvor(bvand(0x0:bv32, 0x0:bv32), bvand(bvor(bvlshr(var1_4203612_bv32:bv32, zero_extend(22, 0x1f:bv10)), bvshl(var1_4203612_bv32:bv32, zero_extend(16, 0x1:bv16))), 0xffffffff:bv32)), 0x1:bv32))) { .comment = "op: 0x131f7c00" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203616_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4203616_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4203616_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4203616_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4203616_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4203616_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4203620_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4203620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4203620_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4203620_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4203620_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203624_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var1_4203624_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xa94363f7" };
    var var2_4203624_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var2_4203624_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94363f7" };
    $R23: bv64 := var1_4203624_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $R24: bv64 := var2_4203624_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var1_4203628_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x40:bv64) 64 { .comment = "op: 0xa9446bf9" };
    var var2_4203628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9446bf9" };
    var var2_4203628_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x40:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9446bf9" };
    $R25: bv64 := var1_4203628_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $R26: bv64 := var2_4203628_bv64:bv64 { .comment = "op: 0xa9446bf9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203632_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9402bfb" };
    var var1_4203632_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x50:bv64) 64 { .comment = "op: 0xf9402bfb" };
    $R27: bv64 := var1_4203632_bv64:bv64 { .comment = "op: 0xf9402bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203636_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var1_4203636_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4203636_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var2_4203636_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c77bfd" };
    var var3_4203636_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c77bfd" };
    var var3_4203636_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c77bfd" };
    $R29: bv64 := var2_4203636_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R30: bv64 := var3_4203636_bv64:bv64 { .comment = "op: 0xa8c77bfd" };
    $R31: bv64 := bvadd(var1_4203636_bv64:bv64, 0x70:bv64) { .comment = "op: 0xa8c77bfd" };
    var var1_4203640_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtcpy_basil_return_1);
  ];
  block %__fmtcpy_131 {.address = 0x402450; .originalLabel = "L81xlPS6TuCgjrrA2MS6cQ=="} [
    goto(%__fmtcpy_129);
  ];
  block %__fmtcpy_133 [
    guard boolnot(eq($R25:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402450:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402450:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203600_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var1_4203600_bv32: bv32 := extract(32, 0, $R26:bv64) { .comment = "op: 0x4b180341" };
    var var2_4203600_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var2_4203600_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x4b180341" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var1_4203600_bv32:bv32, bvnot(bvshl(var2_4203600_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b180341" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203604_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203604_bv64:bv64, bvshl(var2_4203604_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x40245c:bv64 { .comment = "op: 0x97ffff6e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff6e" };
    $_PC: bv64 := 0x402210:bv64 { .comment = "op: 0x97ffff6e" };
    call @__rfmtpad_4203024 ();
    goto(%__fmtcpy_131);
  ];
  block %__fmtcpy_135 {.address = 0x40243c; .originalLabel = "7wl5MpGGTwaQU6sZbQv18w=="} [
    assert eq($_PC:bv64, 0x40243c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40243c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203580_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94032a1" };
    var var1_4203580_bv64: bv64 := $R21:bv64 { .comment = "op: 0xb94032a1" };
    var var2_4203580_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94032a1" };
    var var2_4203580_bv32: bv32 := load le $mem bvadd(var1_4203580_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb94032a1" };
    $R1: bv64 := zero_extend(32, var2_4203580_bv32:bv32) { .comment = "op: 0xb94032a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000ab4" };
    store le $mem bvadd($R21:bv64, 0x10:bv64) $R20:bv64 64 { .comment = "op: 0xf9000ab4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000020" };
    var var1_4203588_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0xb000020" };
    var var2_4203588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb000020" };
    var var2_4203588_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb000020" };
    $R0: bv64 := zero_extend(32, bvadd(var1_4203588_bv32:bv32, bvshl(var2_4203588_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90032a0" };
    store le $mem bvadd($R21:bv64, 0x30:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb90032a0" };
    goto(%__fmtcpy_127, %__fmtcpy_133);
  ];
  block %__fmtcpy_137 {.address = 0x402430; .originalLabel = "EpeiNOz6SeeyllXOwUzoYA=="} [
    assert eq($_PC:bv64, 0x402430:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402430:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400aa0" };
    var var1_4203568_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400aa0" };
    var var2_4203568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400aa0" };
    var var2_4203568_bv64: bv64 := load le $mem bvadd(var1_4203568_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400aa0" };
    $R0: bv64 := var2_4203568_bv64:bv64 { .comment = "op: 0xf9400aa0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000280" };
    var var1_4203572_bv64: bv64 := $R20:bv64 { .comment = "op: 0xcb000280" };
    var var2_4203572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000280" };
    var var2_4203572_bv64: bv64 := $R0:bv64 { .comment = "op: 0xcb000280" };
    $R0: bv64 := bvadd(bvadd(var1_4203572_bv64:bv64, bvnot(bvshl(var2_4203572_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb000280" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd3418000" };
    var var1_4203576_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd3418000" };
    $R0: bv64 := bvor(bvand(0x0:bv64, 0xffffffff00000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x7fffffff00000000:bv64), bvand(bvor(bvlshr(var1_4203576_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4203576_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0x80000000ffffffff:bv64)), 0xffffffff:bv64)) { .comment = "op: 0xd3418000" };
    goto(%__fmtcpy_135);
  ];
  block %__fmtcpy_139 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_137);
  ];
  block %__fmtcpy_141 {.address = 0x402418; .originalLabel = "5w3DVJPRSIm1C1C0aCkquw=="} [
    goto(%__fmtcpy_125, %__fmtcpy_139);
  ];
  block %__fmtcpy_143 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402418:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402418:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203544_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x7940dbe1" };
    var var1_4203544_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x6c:bv64) 16 { .comment = "op: 0x7940dbe1" };
    $R1: bv64 := zero_extend(32, zero_extend(16, var1_4203544_bv16:bv16)) { .comment = "op: 0x7940dbe1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203548_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000814" };
    var var2_4203548_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000814" };
    var var2_4203548_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91000814" };
    $R20: bv64 := bvadd(var2_4203548_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000814" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203552_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ebb" };
    var var1_4203552_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400ebb" };
    var var2_4203552_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ebb" };
    var var2_4203552_bv64: bv64 := load le $mem bvadd(var1_4203552_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400ebb" };
    $R27: bv64 := var2_4203552_bv64:bv64 { .comment = "op: 0xf9400ebb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000001" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(16, 0, $R1:bv64) 16 { .comment = "op: 0x79000001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203560_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710006f7" };
    var var2_4203560_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710006f7" };
    var var2_4203560_bv32: bv32 := extract(32, 0, $R23:bv64) { .comment = "op: 0x710006f7" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, var2_4203560_bv32:bv32), 0xfffffffffffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x710006f7" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, var2_4203560_bv32:bv32), 0xfffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x710006f7" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710006f7" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x710006f7" };
    $R23: bv64 := zero_extend(32, bvadd(bvadd(var2_4203560_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x710006f7" };
    goto(%__fmtcpy_141);
  ];
  block %__fmtcpy_145 {.address = 0x402414; .originalLabel = "tKMCENl/TxWIjlT/Njfuqw=="} [
    assert eq($_PC:bv64, 0x402414:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402414:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_123, %__fmtcpy_143);
  ];
  block %__fmtcpy_147 {.address = 0x402404; .originalLabel = "xxbRdbpZQlG8Z/PpQKkMjg=="} [
    assert eq($_PC:bv64, 0x402404:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402404:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var1_4203524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4203524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4203524_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e1" };
    $R1: bv64 := bvor(var1_4203524_bv64:bv64, bvshl(var2_4203524_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203528_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203528_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203528_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203528_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203528_bv64:bv64, bvshl(var2_4203528_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x2:bv64 { .comment = "op: 0x52800042" };
    $R30: bv64 := 0x402414:bv64 { .comment = "op: 0x97fffe88" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe88" };
    $_PC: bv64 := 0x401e30:bv64 { .comment = "op: 0x97fffe88" };
    call @__fmtflush_4202032 ();
    goto(%__fmtcpy_145);
  ];
  block %__fmtcpy_149 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402404:bv64;
    goto(%__fmtcpy_147);
  ];
  block %__fmtcpy_151 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402430:bv64;
    goto(%__fmtcpy_137);
  ];
  block %__fmtcpy_153 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_187);
  ];
  block %__fmtcpy_155 {.address = 0x4023ac; .originalLabel = "bXdE3BFMSwiX9rUkCmXtMQ=="} [
    assert eq($_PC:bv64, 0x4023ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023ac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var1_4203436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4203436_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4203436_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f4" };
    $R20: bv64 := bvor(var1_4203436_bv64:bv64, bvshl(var2_4203436_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203440_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x7940dbe1" };
    var var1_4203440_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x6c:bv64) 16 { .comment = "op: 0x7940dbe1" };
    $R1: bv64 := zero_extend(32, zero_extend(16, var1_4203440_bv16:bv16)) { .comment = "op: 0x7940dbe1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203444_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000001" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(16, 0, $R1:bv64) 16 { .comment = "op: 0x79000001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203448_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710006f7" };
    var var2_4203448_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710006f7" };
    var var2_4203448_bv32: bv32 := extract(32, 0, $R23:bv64) { .comment = "op: 0x710006f7" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, var2_4203448_bv32:bv32), 0xfffffffffffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x710006f7" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, var2_4203448_bv32:bv32), 0xfffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x710006f7" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710006f7" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x710006f7" };
    $R23: bv64 := zero_extend(32, bvadd(bvadd(var2_4203448_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x710006f7" };
    goto(%__fmtcpy_151, %__fmtcpy_153);
  ];
  block %__fmtcpy_157 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_155);
  ];
  block %__fmtcpy_159 {.address = 0x402398; .originalLabel = "mTWXUWMDRAKHeknyVdWqCg=="} [
    goto(%__fmtcpy_149, %__fmtcpy_157);
  ];
  block %__fmtcpy_161 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x7:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402398:bv64;
    assert eq($_PC:bv64, 0x402398:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402398:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a81" };
    var var2_4203416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a81" };
    var var2_4203416_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000a81" };
    $R1: bv64 := bvadd(var2_4203416_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000a81" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203420_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000673" };
    var var2_4203420_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000673" };
    var var2_4203420_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91000673" };
    $R19: bv64 := bvadd(var2_4203420_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000673" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203424_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var1_4203424_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4203424_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4203424_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e0" };
    $R0: bv64 := bvor(var1_4203424_bv64:bv64, bvshl(var2_4203424_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203428_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb1b003f" };
    var var2_4203428_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb1b003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb1b003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb1b003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb1b003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb1b003f" };
    goto(%__fmtcpy_159);
  ];
  block %__fmtcpy_163 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4023ac:bv64;
    goto(%__fmtcpy_155);
  ];
  block %__fmtcpy_165 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_147);
  ];
  block %__fmtcpy_167 {.address = 0x4023f0; .originalLabel = "i2VRX3hRSyWMFefo0cI/nQ=="} [
    assert eq($_PC:bv64, 0x4023f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var2_4203504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var2_4203504_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b20c273" };
    var var3_4203504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c273" };
    var var3_4203504_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c273" };
    $R19: bv64 := bvadd(var2_4203504_bv64:bv64, sign_extend(32, extract(32, 0, var3_4203504_bv64:bv64))) { .comment = "op: 0x8b20c273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a81" };
    var var2_4203508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a81" };
    var var2_4203508_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000a81" };
    $R1: bv64 := bvadd(var2_4203508_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000a81" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var1_4203512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4203512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4203512_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e0" };
    $R0: bv64 := bvor(var1_4203512_bv64:bv64, bvshl(var2_4203512_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb1b003f" };
    var var2_4203516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb1b003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb1b003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb1b003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb1b003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R27:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb1b003f" };
    goto(%__fmtcpy_163, %__fmtcpy_165);
  ];
  block %__fmtcpy_169 {.address = 0x4023e4; .originalLabel = "M6UNXqStRyan5KwMZvib7w=="} [
    assert eq($_PC:bv64, 0x4023e4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023e4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4203492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4203492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4203492_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4203492_bv64:bv64, bvshl(var2_4203492_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9101b3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x6c:bv64) { .comment = "op: 0x9101b3e0" };
    $R30: bv64 := 0x4023f0:bv64 { .comment = "op: 0x9400061d" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400061d" };
    $_PC: bv64 := 0x403c60:bv64 { .comment = "op: 0x9400061d" };
    call @chartorune_4209760 ();
    goto(%__fmtcpy_167);
  ];
  block %__fmtcpy_171 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4023e4:bv64;
    goto(%__fmtcpy_169);
  ];
  block %__fmtcpy_173 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402430:bv64;
    goto(%__fmtcpy_137);
  ];
  block %__fmtcpy_175 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_169);
  ];
  block %__fmtcpy_177 {.address = 0x4023e0; .originalLabel = "r+i+SCx4ReOsQvrwaid16g=="} [
    assert eq($_PC:bv64, 0x4023e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023e0:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_173, %__fmtcpy_175);
  ];
  block %__fmtcpy_179 {.address = 0x4023d8; .originalLabel = "HmVm3hX9Rb+u7ho5W6Kwyw=="} [
    goto(%__fmtcpy_177);
  ];
  block %__fmtcpy_181 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4023d8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023d8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203480_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4203480_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203480_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4203480_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4203480_bv64:bv64, bvshl(var2_4203480_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $R30: bv64 := 0x4023e0:bv64 { .comment = "op: 0x94000685" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000685" };
    $_PC: bv64 := 0x403df0:bv64 { .comment = "op: 0x94000685" };
    call @fullrune_4210160 ();
    goto(%__fmtcpy_179);
  ];
  block %__fmtcpy_183 {.address = 0x4023d0; .originalLabel = "rB/VehlsQDaMPsKLkWA+lg=="} [
    goto(%__fmtcpy_171, %__fmtcpy_181);
  ];
  block %__fmtcpy_185 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x7:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4023d0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023d0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100083f" };
    var var2_4203472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100083f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), 0xfffffffffffffffffffffffffffffffd:bv128), 0x1:bv128)))) { .comment = "op: 0xf100083f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), 0xfffffffffffffffd:bv128), 0x1:bv128)))) { .comment = "op: 0xf100083f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100083f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64)) { .comment = "op: 0xf100083f" };
    goto(%__fmtcpy_183);
  ];
  block %__fmtcpy_187 {.address = 0x4023c0; .originalLabel = "5nqci6XGSVO7T/Iq/1l5Tg=="} [
    assert eq($_PC:bv64, 0x4023c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4023c0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203456_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400260" };
    var var1_4203456_bv64: bv64 := $R19:bv64 { .comment = "op: 0x39400260" };
    var var2_4203456_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400260" };
    var var2_4203456_bv8: bv8 := load le $mem bvadd(var1_4203456_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400260" };
    $R0: bv64 := zero_extend(32, zero_extend(24, var2_4203456_bv8:bv8)) { .comment = "op: 0x39400260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb1302c1" };
    var var1_4203460_bv64: bv64 := $R22:bv64 { .comment = "op: 0xcb1302c1" };
    var var2_4203460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb1302c1" };
    var var2_4203460_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb1302c1" };
    $R1: bv64 := bvadd(bvadd(var1_4203460_bv64:bv64, bvnot(bvshl(var2_4203460_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb1302c1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x6c:bv64) extract(16, 0, $R0:bv64) 16 { .comment = "op: 0x7900dbe0" };
    goto(%__fmtcpy_161, %__fmtcpy_185);
  ];
  block %__fmtcpy_189 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4023c0:bv64;
    goto(%__fmtcpy_187);
  ];
  block %__fmtcpy_191 {.address = 0x402394; .originalLabel = "++wKlbGLTwqoKx4C3xAaoA=="} [
    goto(%__fmtcpy_135);
  ];
  block %__fmtcpy_193 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402394:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402394:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400002a" };
    $_PC: bv64 := 0x40243c:bv64 { .comment = "op: 0x1400002a" };
    goto(%__fmtcpy_191);
  ];
  block %__fmtcpy_195 {.address = 0x402378; .originalLabel = "Pa2OiiL3Ra+a0yw0DLr6Pg=="} [
    assert eq($_PC:bv64, 0x402378:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402378:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ab4" };
    var var1_4203384_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400ab4" };
    var var2_4203384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ab4" };
    var var2_4203384_bv64: bv64 := load le $mem bvadd(var1_4203384_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400ab4" };
    $R20: bv64 := var2_4203384_bv64:bv64 { .comment = "op: 0xf9400ab4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x50:bv64) $R27:bv64 64 { .comment = "op: 0xf9002bfb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203392_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ebb" };
    var var1_4203392_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9400ebb" };
    var var2_4203392_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ebb" };
    var var2_4203392_bv64: bv64 := load le $mem bvadd(var1_4203392_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400ebb" };
    $R27: bv64 := var2_4203392_bv64:bv64 { .comment = "op: 0xf9400ebb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203396_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f7" };
    var var1_4203396_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f7" };
    var var2_4203396_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1803f7" };
    var var2_4203396_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x2a1803f7" };
    $R23: bv64 := zero_extend(32, bvor(var1_4203396_bv32:bv32, bvshl(var2_4203396_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1803f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203404_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100031f" };
    var var2_4203404_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100031f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R24:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100031f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R24:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100031f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100031f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R24:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100031f" };
    goto(%__fmtcpy_189, %__fmtcpy_193);
  ];
  block %__fmtcpy_197 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402378:bv64;
    goto(%__fmtcpy_195);
  ];
  block %__fmtcpy_199 {.address = 0x4025cc; .originalLabel = "1p//IcgWSN24p/wb4DefPQ=="} [
    goto(%__fmtcpy_11);
  ];
  block %__fmtcpy_201 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4025cc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025cc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffc9" };
    $_PC: bv64 := 0x4024f4:bv64 { .comment = "op: 0x17ffffc9" };
    goto(%__fmtcpy_199);
  ];
  block %__fmtcpy_203 {.address = 0x4025c8; .originalLabel = "PO7FsvenTgWW2w1jE7b8Eg=="} [
    assert eq($_PC:bv64, 0x4025c8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025c8:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_197, %__fmtcpy_201);
  ];
  block %__fmtcpy_205 {.address = 0x4025bc; .originalLabel = "VtbD7xoXTMmOBEo96kx76g=="} [
    goto(%__fmtcpy_203);
  ];
  block %__fmtcpy_207 [
    guard eq($R25:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4025bc:bv64;
    assert eq($_PC:bv64, 0x4025bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4025bc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var1_4203964_bv32: bv32 := extract(32, 0, $R26:bv64) { .comment = "op: 0x4b180341" };
    var var2_4203964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180341" };
    var var2_4203964_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x4b180341" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var1_4203964_bv32:bv32, bvnot(bvshl(var2_4203964_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b180341" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4203968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4203968_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4203968_bv64:bv64, bvshl(var2_4203968_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x4025c8:bv64 { .comment = "op: 0x97ffff13" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff13" };
    $_PC: bv64 := 0x402210:bv64 { .comment = "op: 0x97ffff13" };
    call @__rfmtpad_4203024 ();
    goto(%__fmtcpy_205);
  ];
  block %__fmtcpy_209 [
    guard boolnot(eq($R25:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtcpy_195);
  ];
  block %__fmtcpy_211 {.address = 0x402374; .originalLabel = "hJQV3y4TTuer8lmD0IPPdw=="} [
    goto(%__fmtcpy_207, %__fmtcpy_209);
  ];
  block %__fmtcpy_213 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402374:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402374:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_211);
  ];
  block %__fmtcpy_215 {.address = 0x402368; .originalLabel = "2ZxbBcvlTE6yaYAeKL2fsQ=="} [
    assert eq($_PC:bv64, 0x402368:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402368:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x394002a0" };
    var var1_4203368_bv64: bv64 := $R21:bv64 { .comment = "op: 0x394002a0" };
    var var2_4203368_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x394002a0" };
    var var2_4203368_bv8: bv8 := load le $mem bvadd(var1_4203368_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x394002a0" };
    $R0: bv64 := zero_extend(32, zero_extend(24, var2_4203368_bv8:bv8)) { .comment = "op: 0x394002a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x927f0339" };
    var var1_4203372_bv64: bv64 := $R25:bv64 { .comment = "op: 0x927f0339" };
    $R25: bv64 := bvand(var1_4203372_bv64:bv64, 0x2:bv64) { .comment = "op: 0x927f0339" };
    goto(%__fmtcpy_121, %__fmtcpy_213);
  ];
  block %__fmtcpy_217 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R25:bv64), zero_extend(20, 0x2:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402368:bv64;
    goto(%__fmtcpy_215);
  ];
  block %__fmtcpy_219 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R24: bv64 := zero_extend(32, var1_4203364_bv32:bv32);
    goto(%__fmtcpy_215);
  ];
  block %__fmtcpy_221 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R24: bv64 := zero_extend(32, var2_4203364_bv32:bv32);
    goto(%__fmtcpy_215);
  ];
  block %__fmtcpy_223 {.address = 0x40235c; .originalLabel = "4nhiv2O2TtKjP1U4V9W6ug=="} [
    goto(%__fmtcpy_219, %__fmtcpy_221);
  ];
  block %__fmtcpy_225 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R25:bv64), zero_extend(20, 0x2:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40235c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40235c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94062a0" };
    var var1_4203356_bv64: bv64 := $R21:bv64 { .comment = "op: 0xb94062a0" };
    var var2_4203356_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94062a0" };
    var var2_4203356_bv32: bv32 := load le $mem bvadd(var1_4203356_bv64:bv64, 0x60:bv64) 32 { .comment = "op: 0xb94062a0" };
    $R0: bv64 := zero_extend(32, var2_4203356_bv32:bv32) { .comment = "op: 0xb94062a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203360_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00031f" };
    var var2_4203360_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00031f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R24:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00031f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R24:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R24:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00031f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R24:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b00031f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R24:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b00031f" };
    var var1_4203364_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a80d318" };
    var var1_4203364_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x1a80d318" };
    var var2_4203364_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a80d318" };
    var var2_4203364_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x1a80d318" };
    goto(%__fmtcpy_223);
  ];
  block %__fmtcpy_227 {.address = 0x402358; .originalLabel = "LRIGA5oaR5C/6c2XIBglIw=="} [
    assert eq($_PC:bv64, 0x402358:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402358:bv64)"; .label = "pc-tracking" };
    goto(%__fmtcpy_217, %__fmtcpy_225);
  ];
  block %__fmtcpy_229 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R25:bv64), zero_extend(20, 0x0:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402358:bv64;
    goto(%__fmtcpy_227);
  ];
  block %__fmtcpy_231 {.address = 0x402354; .originalLabel = "9UKpzgnaQV2JTjGy187jHA=="} [
    goto(%__fmtcpy_227);
  ];
  block %__fmtcpy_233 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R25:bv64), zero_extend(20, 0x0:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402354:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402354:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4203348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9405c1a" };
    var var1_4203348_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9405c1a" };
    var var2_4203348_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9405c1a" };
    var var2_4203348_bv32: bv32 := load le $mem bvadd(var1_4203348_bv64:bv64, 0x5c:bv64) 32 { .comment = "op: 0xb9405c1a" };
    $R26: bv64 := zero_extend(32, var2_4203348_bv32:bv32) { .comment = "op: 0xb9405c1a" };
    goto(%__fmtcpy_231);
  ];
  block %__fmtcpy_basil_return_1 [
    return ();
  ]
];


proc @__badfmt_4208400 () -> ()
  { .name = "__badfmt"; .address = 0x403710; .returnBlock = "__badfmt_basil_return_1" }
  require eq($_PC:bv64, 0x403710:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__badfmt_entry {.address = 0x403710; .originalLabel = "VsS7dlFoQ3et0t9jIUUtyw=="} [
    assert eq($_PC:bv64, 0x403710:bv64);
    $_PC: bv64 := 0x403710:bv64;
    assert eq($_PC:bv64, 0x403710:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403710:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9be7bfd" };
    var var1_4208400_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffe0:bv64) $R29:bv64 64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9be7bfd" };
    $R31: bv64 := bvadd(var1_4208400_bv64:bv64, 0xffffffffffffffe0:bv64) { .comment = "op: 0xa9be7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x3:bv64 { .comment = "op: 0x52800063" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R5: bv64 := 0x25:bv64 { .comment = "op: 0x528004a5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208412_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9405804" };
    var var1_4208416_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9405804" };
    var var2_4208416_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9405804" };
    var var2_4208416_bv32: bv32 := load le $mem bvadd(var1_4208416_bv64:bv64, 0x58:bv64) 32 { .comment = "op: 0xb9405804" };
    $R4: bv64 := zero_extend(32, var2_4208416_bv32:bv32) { .comment = "op: 0xb9405804" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208420_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910063e1" };
    $R1: bv64 := bvadd($R31:bv64, 0x18:bv64) { .comment = "op: 0x910063e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208424_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9006003" };
    store le $mem bvadd($R0:bv64, 0x60:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb9006003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0303e2" };
    var var1_4208428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0303e2" };
    var var2_4208428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0303e2" };
    var var2_4208428_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x2a0303e2" };
    $R2: bv64 := zero_extend(32, bvor(var1_4208428_bv32:bv32, bvshl(var2_4208428_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x18:bv64) extract(8, 0, $R5:bv64) 8 { .comment = "op: 0x390063e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x19:bv64) extract(8, 0, $R4:bv64) 8 { .comment = "op: 0x390067e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1a:bv64) extract(8, 0, $R5:bv64) 8 { .comment = "op: 0x39006be5" };
    $R30: bv64 := 0x403740:bv64 { .comment = "op: 0x97fffaf9" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffaf9" };
    $_PC: bv64 := 0x402320:bv64 { .comment = "op: 0x97fffaf9" };
    call @__fmtcpy_4203296 ();
    goto(%__badfmt_5);
  ];
  block %__badfmt_5 {.address = 0x403740; .originalLabel = "MDacFx5HRPeHfGbkSivbHw=="} [
    assert eq($_PC:bv64, 0x403740:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403740:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4208452_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4208452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4208452_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4208452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4208452_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4208452_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4208452_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4208452_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4208456_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__badfmt_basil_return_1);
  ];
  block %__badfmt_basil_return_1 [
    return ();
  ]
];


proc @getcallerpc_4201920 () -> ()
  { .name = "getcallerpc"; .address = 0x401dc0; .returnBlock = "getcallerpc_basil_return_1" }
  require eq($_PC:bv64, 0x401dc0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %getcallerpc_entry {.address = 0x401dc0; .originalLabel = "/lgI4FfjS+yfGYqEtnuiGw=="} [
    assert eq($_PC:bv64, 0x401dc0:bv64);
    $_PC: bv64 := 0x401dc0:bv64;
    assert eq($_PC:bv64, 0x401dc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401dc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201920_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf85f0000" };
    var var1_4201920_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf85f0000" };
    var var2_4201920_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf85f0000" };
    var var2_4201920_bv64: bv64 := load le $mem bvadd(var1_4201920_bv64:bv64, 0xfffffffffffffff0:bv64) 64 { .comment = "op: 0xf85f0000" };
    $R0: bv64 := var2_4201920_bv64:bv64 { .comment = "op: 0xf85f0000" };
    var var1_4201924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%getcallerpc_basil_return_1);
  ];
  block %getcallerpc_basil_return_1 [
    return ();
  ]
];


proc @unlock_4199332 () -> ()
  { .name = "unlock"; .address = 0x4013a4; .returnBlock = "unlock_basil_return_1" }
  require eq($_PC:bv64, 0x4013a4:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %unlock_entry {.address = 0x4013a4; .originalLabel = "V0jFzXuITMiNHr/kb8xG4g=="} [
    assert eq($_PC:bv64, 0x4013a4:bv64);
    $_PC: bv64 := 0x4013a4:bv64;
    assert eq($_PC:bv64, 0x4013a4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4013a4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4199332_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4199332_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199340_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4199348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4199348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4199348_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4199348_bv64:bv64, bvshl(var2_4199348_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9431834" };
    var var1_4199352_bv64: bv64 := $R1:bv64 { .comment = "op: 0xf9431834" };
    var var2_4199352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9431834" };
    var var2_4199352_bv64: bv64 := load le $mem bvadd(var1_4199352_bv64:bv64, 0x630:bv64) 64 { .comment = "op: 0xf9431834" };
    $R20: bv64 := var2_4199352_bv64:bv64 { .comment = "op: 0xf9431834" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x28:bv64) $R0:bv64 64 { .comment = "op: 0xf90017e0" };
    goto(%unlock_5, %unlock_13);
  ];
  block %unlock_3 {.address = 0x4013e4; .originalLabel = "BwY9/eU5RFyKSKP5L0kj8w=="} [
    goto(%unlock_basil_return_1);
  ];
  block %unlock_5 [
    guard eq($R20:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4013e4:bv64;
    assert eq($_PC:bv64, 0x4013e4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4013e4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb900001f" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) 0x0:bv32 32 { .comment = "op: 0xb900001f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4199400_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4199400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4199400_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4199400_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4199400_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199404_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4199404_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199404_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199404_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199404_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199404_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4199404_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4199404_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4199404_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4199408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%unlock_3);
  ];
  block %unlock_7 {.address = 0x4013d8; .originalLabel = "IPue/nbORhWCu0/+8XJagQ=="} [
    assert eq($_PC:bv64, 0x4013d8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4013d8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4199384_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4199384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4199384_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4199384_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4199384_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4199388_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199388_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199388_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199388_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4199388_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4199388_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4199388_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4199392_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%unlock_basil_return_1);
  ];
  block %unlock_9 {.address = 0x4013cc; .originalLabel = "9iGRVgOwTQWzHo/SEQGAHg=="} [
    assert eq($_PC:bv64, 0x4013cc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4013cc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var1_4199372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4199372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4199372_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e1" };
    $R1: bv64 := bvor(var1_4199372_bv64:bv64, bvshl(var2_4199372_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4199376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4199376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4199376_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4199376_bv64:bv64, bvshl(var2_4199376_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    var var1_4199380_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0280" };
    var var1_4199380_bv64: bv64 := $R20:bv64 { .comment = "op: 0xd63f0280" };
    $R30: bv64 := 0x4013d8:bv64 { .comment = "op: 0xd63f0280" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0280" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0280" };
    $_PC: bv64 := var1_4199380_bv64:bv64 { .comment = "op: 0xd63f0280" };
    indirect call var1_4199380_bv64:bv64 ;
    goto(%unlock_7);
  ];
  block %unlock_11 {.address = 0x4013c4; .originalLabel = "VlOHEPnLTBaEbvjodJSZtw=="} [
    goto(%unlock_9);
  ];
  block %unlock_13 [
    guard boolnot(eq($R20:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4013c4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4013c4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199364_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $R30: bv64 := 0x4013cc:bv64 { .comment = "op: 0x9400027e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400027e" };
    $_PC: bv64 := 0x401dc0:bv64 { .comment = "op: 0x9400027e" };
    call @getcallerpc_4201920 ();
    goto(%unlock_11);
  ];
  block %unlock_basil_return_1 [
    return ();
  ]
];


proc @__fmtunlock_4209744 () -> ()
  { .name = "__fmtunlock"; .address = 0x403c50; .returnBlock = "__fmtunlock_basil_return_1" }
  require eq($_PC:bv64, 0x403c50:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtunlock_entry {.address = 0x403c50; .originalLabel = "LHWtkP5rQmqxTbinnC1hLw=="} [
    var R30_begin___fmtunlock_4209744: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x403c50:bv64);
    $_PC: bv64 := 0x403c50:bv64;
    assert eq($_PC:bv64, 0x403c50:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c50:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x420000:bv64 { .comment = "op: 0xb00000e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912c6000" };
    var var2_4209748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912c6000" };
    var var2_4209748_bv64: bv64 := $R0:bv64 { .comment = "op: 0x912c6000" };
    $R0: bv64 := bvadd(var2_4209748_bv64:bv64, 0xb18:bv64) { .comment = "op: 0x912c6000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fff5d3" };
    $_PC: bv64 := 0x4013a4:bv64 { .comment = "op: 0x17fff5d3" };
    assert eq($R30:bv64, R30_begin___fmtunlock_4209744:bv64) { .comment = "R30 = R30_in" };
    call @unlock_4199332 ();
    goto(%__fmtunlock_basil_return_1);
  ];
  block %__fmtunlock_basil_return_1 [
    return ();
  ]
];


proc @lock_4199120 () -> ()
  { .name = "lock"; .address = 0x4012d0; .returnBlock = "lock_basil_return_1" }
  require eq($_PC:bv64, 0x4012d0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %lock_entry {.address = 0x4012d0; .originalLabel = "EL5Ky+1GSIeJ6nw6JbZnPg=="} [
    assert eq($_PC:bv64, 0x4012d0:bv64);
    $_PC: bv64 := 0x4012d0:bv64;
    assert eq($_PC:bv64, 0x4012d0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4012d0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199120_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4199120_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4199120_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4199136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4199136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4199136_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4199136_bv64:bv64, bvshl(var2_4199136_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9431434" };
    var var1_4199140_bv64: bv64 := $R1:bv64 { .comment = "op: 0xf9431434" };
    var var2_4199140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9431434" };
    var var2_4199140_bv64: bv64 := load le $mem bvadd(var1_4199140_bv64:bv64, 0x628:bv64) 64 { .comment = "op: 0xf9431434" };
    $R20: bv64 := var2_4199140_bv64:bv64 { .comment = "op: 0xf9431434" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x28:bv64) $R0:bv64 64 { .comment = "op: 0xf90017e0" };
    goto(%lock_7, %lock_15);
  ];
  block %lock_3 {.address = 0x401328; .originalLabel = "1Wv8mVwEReKH3Aw+961Jnw=="} [
    assert eq($_PC:bv64, 0x401328:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401328:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    unreachable;
  ];
  block %lock_5 {.address = 0x401314; .originalLabel = "+SFvPrnsTkqEvZ0EqdU1uw=="} [
    goto(%lock_basil_return_1);
  ];
  block %lock_7 [
    guard eq($R20:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401314:bv64;
    assert eq($_PC:bv64, 0x401314:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401314:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199192_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9000260" };
    store le $mem bvadd($R19:bv64, 0x0:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb9000260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4199196_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4199196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4199196_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4199196_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4199196_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4199200_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199200_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199200_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4199200_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4199200_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4199200_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4199204_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%lock_5);
  ];
  block %lock_9 {.address = 0x401308; .originalLabel = "FAFGkPWNTbuxzrY6AxXwRw=="} [
    assert eq($_PC:bv64, 0x401308:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401308:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4199176_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4199176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4199176_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4199176_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4199176_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4199180_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4199180_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4199180_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4199180_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4199180_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4199180_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4199184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%lock_basil_return_1);
  ];
  block %lock_11 {.address = 0x4012f8; .originalLabel = "8E0vABaISoauSvmERnoBkA=="} [
    assert eq($_PC:bv64, 0x4012f8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4012f8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x1:bv64 { .comment = "op: 0x52800021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var1_4199164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4199164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4199164_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e2" };
    $R2: bv64 := bvor(var1_4199164_bv64:bv64, bvshl(var2_4199164_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4199168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4199168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4199168_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4199168_bv64:bv64, bvshl(var2_4199168_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    var var1_4199172_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0280" };
    var var1_4199172_bv64: bv64 := $R20:bv64 { .comment = "op: 0xd63f0280" };
    $R30: bv64 := 0x401308:bv64 { .comment = "op: 0xd63f0280" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0280" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0280" };
    $_PC: bv64 := var1_4199172_bv64:bv64 { .comment = "op: 0xd63f0280" };
    indirect call var1_4199172_bv64:bv64 ;
    goto(%lock_9);
  ];
  block %lock_13 {.address = 0x4012f0; .originalLabel = "NNSNuxyvSLmZ/mxh2WifTQ=="} [
    goto(%lock_11);
  ];
  block %lock_15 [
    guard boolnot(eq($R20:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4012f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4012f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199152_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $R30: bv64 := 0x4012f8:bv64 { .comment = "op: 0x940002b3" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940002b3" };
    $_PC: bv64 := 0x401dc0:bv64 { .comment = "op: 0x940002b3" };
    call @getcallerpc_4201920 ();
    goto(%lock_13);
  ];
  block %lock_basil_return_1 [
    return ();
  ]
];


proc @__fmtlock_4209728 () -> ()
  { .name = "__fmtlock"; .address = 0x403c40; .returnBlock = "__fmtlock_basil_return_1" }
  require eq($_PC:bv64, 0x403c40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtlock_entry {.address = 0x403c40; .originalLabel = "n9+4iNtqRLu7+3FBjvBlSg=="} [
    var R30_begin___fmtlock_4209728: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x403c40:bv64);
    $_PC: bv64 := 0x403c40:bv64;
    assert eq($_PC:bv64, 0x403c40:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403c40:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x420000:bv64 { .comment = "op: 0xb00000e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209732_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912c6000" };
    var var2_4209732_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x912c6000" };
    var var2_4209732_bv64: bv64 := $R0:bv64 { .comment = "op: 0x912c6000" };
    $R0: bv64 := bvadd(var2_4209732_bv64:bv64, 0xb18:bv64) { .comment = "op: 0x912c6000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fff5a2" };
    $_PC: bv64 := 0x4012d0:bv64 { .comment = "op: 0x17fff5a2" };
    assert eq($R30:bv64, R30_begin___fmtlock_4209728:bv64) { .comment = "R30 = R30_in" };
    call @lock_4199120 ();
    goto(%__fmtlock_basil_return_1);
  ];
  block %__fmtlock_basil_return_1 [
    return ();
  ]
];


proc @__fmtinstall_4208464 () -> ()
  { .name = "__fmtinstall"; .address = 0x403750; .returnBlock = "__fmtinstall_basil_return_1" }
  require eq($_PC:bv64, 0x403750:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtinstall_entry {.address = 0x403750; .originalLabel = "4vz6BXioRXa/LaTzSs8GSg=="} [
    assert eq($_PC:bv64, 0x403750:bv64);
    $_PC: bv64 := 0x403750:bv64;
    assert eq($_PC:bv64, 0x403750:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403750:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208464_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x51000403" };
    var var2_4208464_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x51000403" };
    var var2_4208464_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x51000403" };
    $R3: bv64 := zero_extend(32, bvadd(bvadd(var2_4208464_bv32:bv32, 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x51000403" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0xfffe:bv64 { .comment = "op: 0x529fffc2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208472_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b02007f" };
    var var2_4208472_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b02007f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R3:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b02007f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R3:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b02007f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b02007f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R2:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b02007f" };
    goto(%__fmtinstall_7, %__fmtinstall_53);
  ];
  block %__fmtinstall_5 {.address = 0x4037e0; .originalLabel = "YykedErSTC6ET5SLtKHyEg=="} [
    assert eq($_PC:bv64, 0x4037e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037e0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    var var1_4208612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtinstall_basil_return_1);
  ];
  block %__fmtinstall_7 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4037e0:bv64;
    goto(%__fmtinstall_5);
  ];
  block %__fmtinstall_9 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4037e0:bv64;
    goto(%__fmtinstall_5);
  ];
  block %__fmtinstall_11 {.address = 0x4037c8; .originalLabel = "rWNgFXVsS5u74w6fwFLxTw=="} [
    assert eq($_PC:bv64, 0x4037c8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037c8:bv64)"; .label = "pc-tracking" };
    var var1_4208584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtinstall_basil_return_1);
  ];
  block %__fmtinstall_13 {.address = 0x4037cc; .originalLabel = "gujHxBDrR22H2hKFwV9a4g=="} [
    goto(%__fmtinstall_11);
  ];
  block %__fmtinstall_15 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4037cc:bv64;
    assert eq($_PC:bv64, 0x4037cc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037cc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x110004e7" };
    var var2_4208588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x110004e7" };
    var var2_4208588_bv32: bv32 := extract(32, 0, $R7:bv64) { .comment = "op: 0x110004e7" };
    $R7: bv64 := zero_extend(32, bvadd(var2_4208588_bv32:bv32, 0x1:bv32)) { .comment = "op: 0x110004e7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90708c7" };
    store le $mem bvadd($R6:bv64, 0x708:bv64) extract(32, 0, $R7:bv64) 32 { .comment = "op: 0xb90708c7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208596_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9000040" };
    store le $mem bvadd($R2:bv64, 0x0:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb9000040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffffb" };
    $_PC: bv64 := 0x4037c8:bv64 { .comment = "op: 0x17fffffb" };
    goto(%__fmtinstall_13);
  ];
  block %__fmtinstall_17 {.address = 0x4037c4; .originalLabel = "TCuX1t61SLKy/uV8qmMZog=="} [
    goto(%__fmtinstall_11);
  ];
  block %__fmtinstall_19 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4037c4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037c4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    goto(%__fmtinstall_17);
  ];
  block %__fmtinstall_21 {.address = 0x4037b8; .originalLabel = "bA5T6Yc7Rj+9y9rTVowRmw=="} [
    assert eq($_PC:bv64, 0x4037b8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037b8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000441" };
    store le $mem bvadd($R2:bv64, 0x8:bv64) $R1:bv64 64 { .comment = "op: 0xf9000441" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04005f" };
    var var2_4208572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb04005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb04005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb04005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R4:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb04005f" };
    goto(%__fmtinstall_15, %__fmtinstall_19);
  ];
  block %__fmtinstall_23 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtinstall_21);
  ];
  block %__fmtinstall_25 {.address = 0x4037ac; .originalLabel = "wnC8FRBfQmW7i7pJT1TA5A=="} [
    assert eq($_PC:bv64, 0x4037ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037ac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911020a5" };
    var var2_4208556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911020a5" };
    var var2_4208556_bv64: bv64 := $R5:bv64 { .comment = "op: 0x911020a5" };
    $R5: bv64 := bvadd(var2_4208556_bv64:bv64, 0x408:bv64) { .comment = "op: 0x911020a5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208560_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb05005f" };
    var var2_4208560_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb05005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb05005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb05005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb05005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb05005f" };
    goto(%__fmtinstall_9, %__fmtinstall_23);
  ];
  block %__fmtinstall_27 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4037ac:bv64;
    goto(%__fmtinstall_25);
  ];
  block %__fmtinstall_29 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtinstall_37);
  ];
  block %__fmtinstall_31 {.address = 0x403794; .originalLabel = "bYsQhFSdSU2EWZF44YdbPQ=="} [
    goto(%__fmtinstall_27, %__fmtinstall_29);
  ];
  block %__fmtinstall_33 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403794:bv64;
    assert eq($_PC:bv64, 0x403794:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403794:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004042" };
    var var2_4208532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004042" };
    var var2_4208532_bv64: bv64 := $R2:bv64 { .comment = "op: 0x91004042" };
    $R2: bv64 := bvadd(var2_4208532_bv64:bv64, 0x10:bv64) { .comment = "op: 0x91004042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208536_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb02009f" };
    var var2_4208536_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb02009f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R4:bv64), sign_extend(64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb02009f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R4:bv64), zero_extend(64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb02009f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb02009f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb02009f" };
    goto(%__fmtinstall_31);
  ];
  block %__fmtinstall_35 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtinstall_25);
  ];
  block %__fmtinstall_37 {.address = 0x4037a0; .originalLabel = "WM0AlBD6RTipVTmSwCsNZg=="} [
    assert eq($_PC:bv64, 0x4037a0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4037a0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208544_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400043" };
    var var1_4208544_bv64: bv64 := $R2:bv64 { .comment = "op: 0xb9400043" };
    var var2_4208544_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400043" };
    var var2_4208544_bv32: bv32 := load le $mem bvadd(var1_4208544_bv64:bv64, 0x0:bv64) 32 { .comment = "op: 0xb9400043" };
    $R3: bv64 := zero_extend(32, var2_4208544_bv32:bv32) { .comment = "op: 0xb9400043" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208548_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00007f" };
    var var2_4208548_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00007f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R3:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00007f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R3:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00007f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b00007f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R3:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b00007f" };
    goto(%__fmtinstall_33, %__fmtinstall_35);
  ];
  block %__fmtinstall_39 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4037a0:bv64;
    goto(%__fmtinstall_37);
  ];
  block %__fmtinstall_41 {.address = 0x403790; .originalLabel = "I6ehzVlAT+yHaDX7RIQUzA=="} [
    goto(%__fmtinstall_21);
  ];
  block %__fmtinstall_43 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403790:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403790:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400000a" };
    $_PC: bv64 := 0x4037b8:bv64 { .comment = "op: 0x1400000a" };
    goto(%__fmtinstall_41);
  ];
  block %__fmtinstall_45 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b27d0a4" };
    var var2_4208512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b27d0a4" };
    var var2_4208512_bv64: bv64 := $R5:bv64 { .comment = "op: 0x8b27d0a4" };
    var var3_4208512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b27d0a4" };
    var var3_4208512_bv64: bv64 := $R7:bv64 { .comment = "op: 0x8b27d0a4" };
    $R4: bv64 := bvadd(var2_4208512_bv64:bv64, sign_extend(28, bvconcat(extract(32, 0, var3_4208512_bv64:bv64), 0x0:bv4))) { .comment = "op: 0x8b27d0a4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002084" };
    var var2_4208516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002084" };
    var var2_4208516_bv64: bv64 := $R4:bv64 { .comment = "op: 0x91002084" };
    $R4: bv64 := bvadd(var2_4208516_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002084" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208520_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb02009f" };
    var var2_4208520_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb02009f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R4:bv64), sign_extend(64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb02009f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R4:bv64), zero_extend(64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb02009f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb02009f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R4:bv64, bvnot(bvshl($R2:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb02009f" };
    goto(%__fmtinstall_39, %__fmtinstall_43);
  ];
  block %__fmtinstall_47 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var1_4208508_bv64:bv64;
    goto(%__fmtinstall_45);
  ];
  block %__fmtinstall_49 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := var2_4208508_bv64:bv64;
    goto(%__fmtinstall_45);
  ];
  block %__fmtinstall_51 {.address = 0x403760; .originalLabel = "PE3Jc5QSRTucfRTCDHXIOw=="} [
    goto(%__fmtinstall_47, %__fmtinstall_49);
  ];
  block %__fmtinstall_53 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403760:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403760:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R6: bv64 := 0x420000:bv64 { .comment = "op: 0xb00000e6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208484_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c20c5" };
    var var2_4208484_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c20c5" };
    var var2_4208484_bv64: bv64 := $R6:bv64 { .comment = "op: 0x911c20c5" };
    $R5: bv64 := bvadd(var2_4208484_bv64:bv64, 0x708:bv64) { .comment = "op: 0x911c20c5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100003f" };
    var var2_4208488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100003f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x403000:bv64 { .comment = "op: 0x90000003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94708c7" };
    var var1_4208496_bv64: bv64 := $R6:bv64 { .comment = "op: 0xb94708c7" };
    var var2_4208496_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94708c7" };
    var var2_4208496_bv32: bv32 := load le $mem bvadd(var1_4208496_bv64:bv64, 0x708:bv64) 32 { .comment = "op: 0xb94708c7" };
    $R7: bv64 := zero_extend(32, var2_4208496_bv32:bv32) { .comment = "op: 0xb94708c7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c4063" };
    var var2_4208500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c4063" };
    var var2_4208500_bv64: bv64 := $R3:bv64 { .comment = "op: 0x911c4063" };
    $R3: bv64 := bvadd(var2_4208500_bv64:bv64, 0x710:bv64) { .comment = "op: 0x911c4063" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910020a2" };
    var var2_4208504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910020a2" };
    var var2_4208504_bv64: bv64 := $R5:bv64 { .comment = "op: 0x910020a2" };
    $R2: bv64 := bvadd(var2_4208504_bv64:bv64, 0x8:bv64) { .comment = "op: 0x910020a2" };
    var var1_4208508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a810061" };
    var var1_4208508_bv64: bv64 := $R3:bv64 { .comment = "op: 0x9a810061" };
    var var2_4208508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a810061" };
    var var2_4208508_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9a810061" };
    goto(%__fmtinstall_51);
  ];
  block %__fmtinstall_basil_return_1 [
    return ();
  ]
];


proc @__fmtdispatch_4208688 () -> ()
  { .name = "__fmtdispatch"; .address = 0x403830; .returnBlock = "__fmtdispatch_basil_return_1" }
  require eq($_PC:bv64, 0x403830:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fmtdispatch_entry {.address = 0x403830; .originalLabel = "J5JvET/ORDyFBY1+xoNLkA=="} [
    assert eq($_PC:bv64, 0x403830:bv64);
    $_PC: bv64 := 0x403830:bv64;
    assert eq($_PC:bv64, 0x403830:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403830:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208688_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bb7bfd" };
    var var1_4208688_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bb7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffb0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bb7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffb0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bb7bfd" };
    $R31: bv64 := bvadd(var1_4208688_bv64:bv64, 0xffffffffffffffb0:bv64) { .comment = "op: 0xa9bb7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var1_4208700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4208700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4208700_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f4" };
    $R20: bv64 := bvor(var1_4208700_bv64:bv64, bvshl(var2_4208700_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var1_4208708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4208708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4208708_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f5" };
    $R21: bv64 := bvor(var1_4208708_bv64:bv64, bvshl(var2_4208708_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208712_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f6" };
    var var1_4208712_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f6" };
    var var2_4208712_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203f6" };
    var var2_4208712_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0203f6" };
    $R22: bv64 := zero_extend(32, bvor(var1_4208712_bv32:bv32, bvshl(var2_4208712_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0203f6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf805c01f" };
    store le $mem bvadd($R0:bv64, 0x5c:bv64) 0x0:bv64 64 { .comment = "op: 0xf805c01f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf900341f" };
    store le $mem bvadd($R0:bv64, 0x68:bv64) 0x0:bv64 64 { .comment = "op: 0xf900341f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_5 {.address = 0x4039fc; .originalLabel = "wLquM3I5S4i7lSpYpL0SYQ=="} [
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_7 [
    guard eq($R2:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4039fc:bv64;
    assert eq($_PC:bv64, 0x4039fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2400000" };
    var var1_4209148_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb2400000" };
    $R0: bv64 := bvor(var1_4209148_bv64:bv64, 0x1:bv64) { .comment = "op: 0xb2400000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209152_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9005ea3" };
    store le $mem bvadd($R21:bv64, 0x5c:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb9005ea3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf90036a0" };
    store le $mem bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64 { .comment = "op: 0xf90036a0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffff94" };
    $_PC: bv64 := 0x403858:bv64 { .comment = "op: 0x17ffff94" };
    goto(%__fmtdispatch_5);
  ];
  block %__fmtdispatch_9 {.address = 0x403964; .originalLabel = "CNqc6UbnS6inIZyW3eDRgw=="} [
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_11 [
    guard boolnot(eq($R2:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403964:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403964:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208996_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27e0000" };
    var var1_4208996_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb27e0000" };
    $R0: bv64 := bvor(var1_4208996_bv64:bv64, 0x4:bv64) { .comment = "op: 0xb27e0000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209000_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90062a3" };
    store le $mem bvadd($R21:bv64, 0x60:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb90062a3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf90036a0" };
    store le $mem bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64 { .comment = "op: 0xf90036a0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffba" };
    $_PC: bv64 := 0x403858:bv64 { .comment = "op: 0x17ffffba" };
    goto(%__fmtdispatch_9);
  ];
  block %__fmtdispatch_13 {.address = 0x403960; .originalLabel = "jOwazP/oSWGurjICwyaxcw=="} [
    assert eq($_PC:bv64, 0x403960:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403960:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_7, %__fmtdispatch_11);
  ];
  block %__fmtdispatch_15 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208988_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000a94" };
    var var2_4208988_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000a94" };
    var var2_4208988_bv64: bv64 := $R20:bv64 { .comment = "op: 0xd1000a94" };
    $R20: bv64 := bvadd(bvadd(var2_4208988_bv64:bv64, 0xfffffffffffffffd:bv64), 0x1:bv64) { .comment = "op: 0xd1000a94" };
    goto(%__fmtdispatch_13);
  ];
  block %__fmtdispatch_17 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := var1_4208984_bv64:bv64;
    goto(%__fmtdispatch_15);
  ];
  block %__fmtdispatch_19 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := bvadd(var2_4208984_bv64:bv64, 0x1:bv64);
    goto(%__fmtdispatch_15);
  ];
  block %__fmtdispatch_21 {.address = 0x403954; .originalLabel = "UMQqOjg9QVmNRHJZ/wq3/Q=="} [
    assert eq($_PC:bv64, 0x403954:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403954:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710002df" };
    var var2_4208980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710002df" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R22:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710002df" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R22:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710002df" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710002df" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710002df" };
    var var1_4208984_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a941694" };
    var var1_4208984_bv64: bv64 := $R20:bv64 { .comment = "op: 0x9a941694" };
    var var2_4208984_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a941694" };
    var var2_4208984_bv64: bv64 := $R20:bv64 { .comment = "op: 0x9a941694" };
    goto(%__fmtdispatch_17, %__fmtdispatch_19);
  ];
  block %__fmtdispatch_23 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403954:bv64;
    goto(%__fmtdispatch_21);
  ];
  block %__fmtdispatch_25 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_39);
  ];
  block %__fmtdispatch_27 {.address = 0x40391c; .originalLabel = "8tlO/QW/QJuMPAFWK4W1EA=="} [
    goto(%__fmtdispatch_23, %__fmtdispatch_25);
  ];
  block %__fmtdispatch_29 [
    guard boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40391c:bv64;
    assert eq($_PC:bv64, 0x40391c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40391c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x78402693" };
    var var1_4208924_bv64: bv64 := $R20:bv64 { .comment = "op: 0x78402693" };
    var var2_4208924_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x78402693" };
    var var2_4208924_bv16: bv16 := load le $mem var1_4208924_bv64:bv64 16 { .comment = "op: 0x78402693" };
    $R19: bv64 := zero_extend(32, zero_extend(16, var2_4208924_bv16:bv16)) { .comment = "op: 0x78402693" };
    $R20: bv64 := bvadd(var1_4208924_bv64:bv64, 0x2:bv64) { .comment = "op: 0x78402693" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208928_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c261" };
    var var2_4208928_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c261" };
    var var2_4208928_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x5100c261" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var2_4208928_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32)) { .comment = "op: 0x5100c261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12003c21" };
    var var1_4208932_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x12003c21" };
    $R1: bv64 := zero_extend(32, bvand(var1_4208932_bv32:bv32, 0xffff:bv32)) { .comment = "op: 0x12003c21" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208936_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100243f" };
    var var2_4208936_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100243f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffffffffff6:bv64), 0x1:bv64)))) { .comment = "op: 0x7100243f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xfffffff6:bv64), 0x1:bv64)))) { .comment = "op: 0x7100243f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100243f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)) { .comment = "op: 0x7100243f" };
    goto(%__fmtdispatch_27);
  ];
  block %__fmtdispatch_31 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403930:bv64;
    goto(%__fmtdispatch_39);
  ];
  block %__fmtdispatch_33 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_21);
  ];
  block %__fmtdispatch_35 {.address = 0x403940; .originalLabel = "lGTZtoIKTvmwl+jXD9GR1A=="} [
    goto(%__fmtdispatch_31, %__fmtdispatch_33);
  ];
  block %__fmtdispatch_37 [
    guard boolnot(boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403940:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403940:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208960_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38401693" };
    var var1_4208960_bv64: bv64 := $R20:bv64 { .comment = "op: 0x38401693" };
    var var2_4208960_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x38401693" };
    var var2_4208960_bv8: bv8 := load le $mem var1_4208960_bv64:bv64 8 { .comment = "op: 0x38401693" };
    $R19: bv64 := zero_extend(32, zero_extend(24, var2_4208960_bv8:bv8)) { .comment = "op: 0x38401693" };
    $R20: bv64 := bvadd(var1_4208960_bv64:bv64, 0x1:bv64) { .comment = "op: 0x38401693" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c261" };
    var var2_4208964_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c261" };
    var var2_4208964_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x5100c261" };
    $R1: bv64 := zero_extend(32, bvadd(bvadd(var2_4208964_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32)) { .comment = "op: 0x5100c261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208968_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12003c21" };
    var var1_4208968_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x12003c21" };
    $R1: bv64 := zero_extend(32, bvand(var1_4208968_bv32:bv32, 0xffff:bv32)) { .comment = "op: 0x12003c21" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208972_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100243f" };
    var var2_4208972_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100243f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R1:bv64)), 0xfffffffffffffff6:bv64), 0x1:bv64)))) { .comment = "op: 0x7100243f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R1:bv64)), 0xfffffff6:bv64), 0x1:bv64)))) { .comment = "op: 0x7100243f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100243f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R1:bv64), 0xfffffff6:bv32), 0x1:bv32)) { .comment = "op: 0x7100243f" };
    goto(%__fmtdispatch_35);
  ];
  block %__fmtdispatch_39 {.address = 0x403930; .originalLabel = "YddQiAu5TYafYywvB2pdMg=="} [
    assert eq($_PC:bv64, 0x403930:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403930:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208944_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030863" };
    var var1_4208944_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb030863" };
    var var2_4208944_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030863" };
    var var2_4208944_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb030863" };
    $R3: bv64 := zero_extend(32, bvadd(var1_4208944_bv32:bv32, bvshl(var2_4208944_bv32:bv32, zero_extend(20, 0x2:bv12)))) { .comment = "op: 0xb030863" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208948_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030663" };
    var var1_4208948_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0xb030663" };
    var var2_4208948_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb030663" };
    var var2_4208948_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0xb030663" };
    $R3: bv64 := zero_extend(32, bvadd(var1_4208948_bv32:bv32, bvshl(var2_4208948_bv32:bv32, zero_extend(20, 0x1:bv12)))) { .comment = "op: 0xb030663" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208952_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c063" };
    var var2_4208952_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c063" };
    var var2_4208952_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x5100c063" };
    $R3: bv64 := zero_extend(32, bvadd(bvadd(var2_4208952_bv32:bv32, 0xffffffcf:bv32), 0x1:bv32)) { .comment = "op: 0x5100c063" };
    goto(%__fmtdispatch_29, %__fmtdispatch_37);
  ];
  block %__fmtdispatch_41 {.address = 0x403914; .originalLabel = "RjgVdenwToKPFpXs4McXhw=="} [
    assert eq($_PC:bv64, 0x403914:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403914:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x0:bv64 { .comment = "op: 0x52800003" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000006" };
    $_PC: bv64 := 0x403930:bv64 { .comment = "op: 0x14000006" };
    goto(%__fmtdispatch_39);
  ];
  block %__fmtdispatch_43 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403914:bv64;
    goto(%__fmtdispatch_41);
  ];
  block %__fmtdispatch_45 {.address = 0x403980; .originalLabel = "1Ysu0Z+QTMeoe3ZVDkjGfQ=="} [
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_47 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403980:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403980:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb2790000" };
    var var1_4209024_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb2790000" };
    $R0: bv64 := bvor(var1_4209024_bv64:bv64, 0x80:bv64) { .comment = "op: 0xb2790000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209028_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf90036a0" };
    store le $mem bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64 { .comment = "op: 0xf90036a0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffb4" };
    $_PC: bv64 := 0x403858:bv64 { .comment = "op: 0x17ffffb4" };
    goto(%__fmtdispatch_45);
  ];
  block %__fmtdispatch_49 {.address = 0x403974; .originalLabel = "INOHZO5kSPG9+r3Lyk0hbQ=="} [
    goto(%__fmtdispatch_43, %__fmtdispatch_47);
  ];
  block %__fmtdispatch_51 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403974:bv64;
    assert eq($_PC:bv64, 0x403974:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403974:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var1_4209012_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4209012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4209012_bv64: bv64 := load le $mem bvadd(var1_4209012_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf94036a0" };
    $R0: bv64 := var2_4209012_bv64:bv64 { .comment = "op: 0xf94036a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209016_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x92400002" };
    var var1_4209016_bv64: bv64 := $R0:bv64 { .comment = "op: 0x92400002" };
    $R2: bv64 := bvand(var1_4209016_bv64:bv64, 0x1:bv64) { .comment = "op: 0x92400002" };
    goto(%__fmtdispatch_49);
  ];
  block %__fmtdispatch_53 {.address = 0x4039ec; .originalLabel = "4taYZ8esSm6xGsAXEcXWlQ=="} [
    assert eq($_PC:bv64, 0x4039ec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039ec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4209132_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4209132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4209132_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4209132_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4209132_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4209136_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4209136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4209136_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4209136_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4209136_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var1_4209140_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4209140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4209140_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c57bfd" };
    var var3_4209140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var3_4209140_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c57bfd" };
    $R29: bv64 := var2_4209140_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R30: bv64 := var3_4209140_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R31: bv64 := bvadd(var1_4209140_bv64:bv64, 0x50:bv64) { .comment = "op: 0xa8c57bfd" };
    var var1_4209144_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fmtdispatch_basil_return_1);
  ];
  block %__fmtdispatch_55 {.address = 0x403a94; .originalLabel = "x2BbtRffSlStUMcYKQN5Jw=="} [
    assert eq($_PC:bv64, 0x403a94:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a94:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0xd2800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd5" };
    $_PC: bv64 := 0x4039ec:bv64 { .comment = "op: 0x17ffffd5" };
    goto(%__fmtdispatch_53);
  ];
  block %__fmtdispatch_57 [
    guard boolnot(eq($NF:bv1, $VF:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a94:bv64;
    goto(%__fmtdispatch_55);
  ];
  block %__fmtdispatch_59 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403858:bv64;
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_61 {.address = 0x4039e8; .originalLabel = "999jv3tTSsGUyABHsdNpxQ=="} [
    goto(%__fmtdispatch_53);
  ];
  block %__fmtdispatch_63 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4039e8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039e8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var1_4209128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4209128_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e0" };
    var var2_4209128_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e0" };
    $R0: bv64 := bvor(var1_4209128_bv64:bv64, bvshl(var2_4209128_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e0" };
    goto(%__fmtdispatch_61);
  ];
  block %__fmtdispatch_65 {.address = 0x4039e4; .originalLabel = "xAnRblwOQQSHZP9+85hYUg=="} [
    goto(%__fmtdispatch_59, %__fmtdispatch_63);
  ];
  block %__fmtdispatch_67 [
    guard boolnot(boolnot(eq($NF:bv1, $VF:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4039e4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039e4:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_65);
  ];
  block %__fmtdispatch_69 {.address = 0x4039dc; .originalLabel = "tyF7x2M4QDW3gqi8IEJidw=="} [
    assert eq($_PC:bv64, 0x4039dc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039dc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209116_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    var var2_4209116_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100001f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100001f" };
    goto(%__fmtdispatch_57, %__fmtdispatch_67);
  ];
  block %__fmtdispatch_71 [
    assume eq(var1_4209112_bv64:bv64, 0x403710:bv64);
    call @__badfmt_4208400 ();
    goto(%__fmtdispatch_69);
  ];
  block %__fmtdispatch_73 [
    assume eq(var1_4209112_bv64:bv64, 0x4035f0:bv64);
    call @__flagfmt_4208112 ();
    goto(%__fmtdispatch_69);
  ];
  block %__fmtdispatch_75 {.address = 0x4039d4; .originalLabel = "KGm/4/NpQIO0Ifo7lDOrig=="} [
    assert eq($_PC:bv64, 0x4039d4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039d4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209108_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4209108_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4209108_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4209108_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4209108_bv64:bv64, bvshl(var2_4209108_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    var var1_4209112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0020" };
    var var1_4209112_bv64: bv64 := $R1:bv64 { .comment = "op: 0xd63f0020" };
    $R30: bv64 := 0x4039dc:bv64 { .comment = "op: 0xd63f0020" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0020" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0020" };
    $_PC: bv64 := var1_4209112_bv64:bv64 { .comment = "op: 0xd63f0020" };
    assert boolor(eq(var1_4209112_bv64:bv64, 0x403710:bv64),eq(var1_4209112_bv64:bv64, 0x4035f0:bv64));
    goto(%__fmtdispatch_71, %__fmtdispatch_73);
  ];
  block %__fmtdispatch_77 {.address = 0x403a84; .originalLabel = "Xq7cJa2dT8mGWs/CO9vX/g=="} [
    assert eq($_PC:bv64, 0x403a84:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a84:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401bf7" };
    var var1_4209284_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xf9401bf7" };
    $R23: bv64 := var1_4209284_bv64:bv64 { .comment = "op: 0xf9401bf7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x403000:bv64 { .comment = "op: 0x90000001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209292_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c4021" };
    var var2_4209292_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c4021" };
    var var2_4209292_bv64: bv64 := $R1:bv64 { .comment = "op: 0x911c4021" };
    $R1: bv64 := bvadd(var2_4209292_bv64:bv64, 0x710:bv64) { .comment = "op: 0x911c4021" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd1" };
    $_PC: bv64 := 0x4039d4:bv64 { .comment = "op: 0x17ffffd1" };
    goto(%__fmtdispatch_75);
  ];
  block %__fmtdispatch_79 {.address = 0x403a80; .originalLabel = "XuK3QMucTrylZFX45QvbOQ=="} [
    assert eq($_PC:bv64, 0x403a80:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a80:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x403a84:bv64 { .comment = "op: 0x94000074" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000074" };
    $_PC: bv64 := 0x403c50:bv64 { .comment = "op: 0x94000074" };
    call @__fmtunlock_4209744 ();
    goto(%__fmtdispatch_77);
  ];
  block %__fmtdispatch_81 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a80:bv64;
    goto(%__fmtdispatch_79);
  ];
  block %__fmtdispatch_83 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_97);
  ];
  block %__fmtdispatch_85 {.address = 0x403a38; .originalLabel = "aBzVK0oaRWKmModMD6QaTQ=="} [
    goto(%__fmtdispatch_81, %__fmtdispatch_83);
  ];
  block %__fmtdispatch_87 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a38:bv64;
    assert eq($_PC:bv64, 0x403a38:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a38:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209208_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb8410ee0" };
    var var1_4209208_bv64: bv64 := $R23:bv64 { .comment = "op: 0xb8410ee0" };
    var var2_4209208_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb8410ee0" };
    var var2_4209208_bv32: bv32 := load le $mem bvadd(var1_4209208_bv64:bv64, 0x10:bv64) 32 { .comment = "op: 0xb8410ee0" };
    $R0: bv64 := zero_extend(32, var2_4209208_bv32:bv32) { .comment = "op: 0xb8410ee0" };
    $R23: bv64 := bvadd(var1_4209208_bv64:bv64, 0x10:bv64) { .comment = "op: 0xb8410ee0" };
    goto(%__fmtdispatch_85);
  ];
  block %__fmtdispatch_89 {.address = 0x403a58; .originalLabel = "PT3O+VI5R8mUmZb7cjS1IQ=="} [
    assert eq($_PC:bv64, 0x403a58:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a58:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209240_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94006e1" };
    var var1_4209240_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf94006e1" };
    var var2_4209240_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94006e1" };
    var var2_4209240_bv64: bv64 := load le $mem bvadd(var1_4209240_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf94006e1" };
    $R1: bv64 := var2_4209240_bv64:bv64 { .comment = "op: 0xf94006e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401bf7" };
    var var1_4209244_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xf9401bf7" };
    $R23: bv64 := var1_4209244_bv64:bv64 { .comment = "op: 0xf9401bf7" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffdd" };
    $_PC: bv64 := 0x4039d4:bv64 { .comment = "op: 0x17ffffdd" };
    goto(%__fmtdispatch_75);
  ];
  block %__fmtdispatch_91 {.address = 0x403a54; .originalLabel = "79i+f7RJT8u8Pa1YZOrbMg=="} [
    assert eq($_PC:bv64, 0x403a54:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a54:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x403a58:bv64 { .comment = "op: 0x9400007f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400007f" };
    $_PC: bv64 := 0x403c50:bv64 { .comment = "op: 0x9400007f" };
    call @__fmtunlock_4209744 ();
    goto(%__fmtdispatch_89);
  ];
  block %__fmtdispatch_93 {.address = 0x403a48; .originalLabel = "yx+Hyg0dTee2OGypROqLNA=="} [
    goto(%__fmtdispatch_91);
  ];
  block %__fmtdispatch_95 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403a48:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a48:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94006e1" };
    var var1_4209224_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf94006e1" };
    var var2_4209224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94006e1" };
    var var2_4209224_bv64: bv64 := load le $mem bvadd(var1_4209224_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf94006e1" };
    $R1: bv64 := var2_4209224_bv64:bv64 { .comment = "op: 0xf94006e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var1_4209228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var2_4209228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var2_4209228_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x2a1303e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4209228_bv32:bv32, bvshl(var2_4209228_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1303e0" };
    $R30: bv64 := 0x403a54:bv64 { .comment = "op: 0x97ffff40" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff40" };
    $_PC: bv64 := 0x403750:bv64 { .comment = "op: 0x97ffff40" };
    call @__fmtinstall_4208464 ();
    goto(%__fmtdispatch_93);
  ];
  block %__fmtdispatch_97 {.address = 0x403a40; .originalLabel = "GWxoZ/X6QTilzMhpdOSoBg=="} [
    assert eq($_PC:bv64, 0x403a40:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a40:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209216_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00027f" };
    var var2_4209216_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b00027f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b00027f" };
    goto(%__fmtdispatch_87, %__fmtdispatch_95);
  ];
  block %__fmtdispatch_99 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a40:bv64;
    goto(%__fmtdispatch_97);
  ];
  block %__fmtdispatch_101 {.address = 0x403a34; .originalLabel = "WhK4atwUQLOp8cjR/QlZug=="} [
    goto(%__fmtdispatch_79);
  ];
  block %__fmtdispatch_103 [
    guard boolnot(boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403a34:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a34:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000013" };
    $_PC: bv64 := 0x403a80:bv64 { .comment = "op: 0x14000013" };
    goto(%__fmtdispatch_101);
  ];
  block %__fmtdispatch_105 {.address = 0x403a24; .originalLabel = "D13AnEo5TRqyqy3dTYGeaw=="} [
    assert eq($_PC:bv64, 0x403a24:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a24:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x420000:bv64 { .comment = "op: 0xb00000e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209192_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91034017" };
    var var2_4209192_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91034017" };
    var var2_4209192_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91034017" };
    $R23: bv64 := bvadd(var2_4209192_bv64:bv64, 0xd0:bv64) { .comment = "op: 0x91034017" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb940d000" };
    var var1_4209196_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb940d000" };
    var var2_4209196_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb940d000" };
    var var2_4209196_bv32: bv32 := load le $mem bvadd(var1_4209196_bv64:bv64, 0xd0:bv64) 32 { .comment = "op: 0xb940d000" };
    $R0: bv64 := zero_extend(32, var2_4209196_bv32:bv32) { .comment = "op: 0xb940d000" };
    goto(%__fmtdispatch_99, %__fmtdispatch_103);
  ];
  block %__fmtdispatch_107 {.address = 0x403a1c; .originalLabel = "1HNMn+dUReWY3UQQrHpRkw=="} [
    assert eq($_PC:bv64, 0x403a1c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a1c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64 { .comment = "op: 0xf9001bf7" };
    $R30: bv64 := 0x403a24:bv64 { .comment = "op: 0x94000088" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000088" };
    $_PC: bv64 := 0x403c40:bv64 { .comment = "op: 0x94000088" };
    call @__fmtlock_4209728 ();
    goto(%__fmtdispatch_105);
  ];
  block %__fmtdispatch_109 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a1c:bv64;
    goto(%__fmtdispatch_107);
  ];
  block %__fmtdispatch_111 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_127);
  ];
  block %__fmtdispatch_113 {.address = 0x4039b0; .originalLabel = "7vX80ojNTyOI789waBe7Uw=="} [
    goto(%__fmtdispatch_109, %__fmtdispatch_111);
  ];
  block %__fmtdispatch_115 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4039b0:bv64;
    assert eq($_PC:bv64, 0x4039b0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039b0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004021" };
    var var2_4209072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004021" };
    var var2_4209072_bv64: bv64 := $R1:bv64 { .comment = "op: 0x91004021" };
    $R1: bv64 := bvadd(var2_4209072_bv64:bv64, 0x10:bv64) { .comment = "op: 0x91004021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01005f" };
    var var2_4209076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb01005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb01005f" };
    goto(%__fmtdispatch_113);
  ];
  block %__fmtdispatch_117 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4039c8:bv64;
    goto(%__fmtdispatch_123);
  ];
  block %__fmtdispatch_119 {.address = 0x4039d0; .originalLabel = "hyoR+wrjTguo/irY01VaUA=="} [
    goto(%__fmtdispatch_75);
  ];
  block %__fmtdispatch_121 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4039d0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039d0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400421" };
    var var1_4209104_bv64: bv64 := $R1:bv64 { .comment = "op: 0xf9400421" };
    var var2_4209104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400421" };
    var var2_4209104_bv64: bv64 := load le $mem bvadd(var1_4209104_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf9400421" };
    $R1: bv64 := var2_4209104_bv64:bv64 { .comment = "op: 0xf9400421" };
    goto(%__fmtdispatch_119);
  ];
  block %__fmtdispatch_123 {.address = 0x4039c8; .originalLabel = "Rr+XBuaMT3SFb78OUioJHA=="} [
    assert eq($_PC:bv64, 0x4039c8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039c8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400420" };
    var var1_4209096_bv64: bv64 := $R1:bv64 { .comment = "op: 0xf9400420" };
    var var2_4209096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400420" };
    var var2_4209096_bv64: bv64 := load le $mem bvadd(var1_4209096_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf9400420" };
    $R0: bv64 := var2_4209096_bv64:bv64 { .comment = "op: 0xf9400420" };
    goto(%__fmtdispatch_117, %__fmtdispatch_121);
  ];
  block %__fmtdispatch_125 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_123);
  ];
  block %__fmtdispatch_127 {.address = 0x4039bc; .originalLabel = "DWyxWR6cQRuz0pulArwMBA=="} [
    assert eq($_PC:bv64, 0x4039bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039bc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209084_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400020" };
    var var1_4209084_bv64: bv64 := $R1:bv64 { .comment = "op: 0xb9400020" };
    var var2_4209084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400020" };
    var var2_4209084_bv32: bv32 := load le $mem bvadd(var1_4209084_bv64:bv64, 0x0:bv64) 32 { .comment = "op: 0xb9400020" };
    $R0: bv64 := zero_extend(32, var2_4209084_bv32:bv32) { .comment = "op: 0xb9400020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00027f" };
    var var2_4209088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b00027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b00027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b00027f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), bvnot(bvshl(extract(32, 0, $R0:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b00027f" };
    goto(%__fmtdispatch_115, %__fmtdispatch_125);
  ];
  block %__fmtdispatch_129 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4039bc:bv64;
    goto(%__fmtdispatch_127);
  ];
  block %__fmtdispatch_131 {.address = 0x4039ac; .originalLabel = "OMCVMD3hQ22OStiMJbIjmw=="} [
    goto(%__fmtdispatch_107);
  ];
  block %__fmtdispatch_133 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4039ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4039ac:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400001c" };
    $_PC: bv64 := 0x403a1c:bv64 { .comment = "op: 0x1400001c" };
    goto(%__fmtdispatch_131);
  ];
  block %__fmtdispatch_135 {.address = 0x40398c; .originalLabel = "VubX60KyQ/i3Ketlgye9aQ=="} [
    assert eq($_PC:bv64, 0x40398c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40398c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x420000:bv64 { .comment = "op: 0xb00000e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c2040" };
    var var2_4209040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911c2040" };
    var var2_4209040_bv64: bv64 := $R2:bv64 { .comment = "op: 0x911c2040" };
    $R0: bv64 := bvadd(var2_4209040_bv64:bv64, 0x708:bv64) { .comment = "op: 0x911c2040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209044_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002001" };
    var var2_4209044_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002001" };
    var var2_4209044_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91002001" };
    $R1: bv64 := bvadd(var2_4209044_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209048_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9470842" };
    var var1_4209048_bv64: bv64 := $R2:bv64 { .comment = "op: 0xb9470842" };
    var var2_4209048_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9470842" };
    var var2_4209048_bv32: bv32 := load le $mem bvadd(var1_4209048_bv64:bv64, 0x708:bv64) 32 { .comment = "op: 0xb9470842" };
    $R2: bv64 := zero_extend(32, var2_4209048_bv32:bv32) { .comment = "op: 0xb9470842" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b22d002" };
    var var2_4209052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b22d002" };
    var var2_4209052_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b22d002" };
    var var3_4209052_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b22d002" };
    var var3_4209052_bv64: bv64 := $R2:bv64 { .comment = "op: 0x8b22d002" };
    $R2: bv64 := bvadd(var2_4209052_bv64:bv64, sign_extend(28, bvconcat(extract(32, 0, var3_4209052_bv64:bv64), 0x0:bv4))) { .comment = "op: 0x8b22d002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002042" };
    var var2_4209056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002042" };
    var var2_4209056_bv64: bv64 := $R2:bv64 { .comment = "op: 0x91002042" };
    $R2: bv64 := bvadd(var2_4209056_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01005f" };
    var var2_4209060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), sign_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), zero_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb01005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb01005f" };
    goto(%__fmtdispatch_129, %__fmtdispatch_133);
  ];
  block %__fmtdispatch_137 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40398c:bv64;
    goto(%__fmtdispatch_135);
  ];
  block %__fmtdispatch_139 {.address = 0x40390c; .originalLabel = "q9jXudVUQPaou7SPic0vTw=="} [
    goto(%__fmtdispatch_41);
  ];
  block %__fmtdispatch_141 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40390c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40390c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var1_4208908_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208908_bv64: bv64 := load le $mem bvadd(var1_4208908_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf94036a0" };
    $R0: bv64 := var2_4208908_bv64:bv64 { .comment = "op: 0xf94036a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x92400002" };
    var var1_4208912_bv64: bv64 := $R0:bv64 { .comment = "op: 0x92400002" };
    $R2: bv64 := bvand(var1_4208912_bv64:bv64, 0x1:bv64) { .comment = "op: 0x92400002" };
    goto(%__fmtdispatch_139);
  ];
  block %__fmtdispatch_143 {.address = 0x4038fc; .originalLabel = "AO1KrAFBTvmdiU1PBPx4Zw=="} [
    goto(%__fmtdispatch_137, %__fmtdispatch_141);
  ];
  block %__fmtdispatch_145 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4038fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208892_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c660" };
    var var2_4208892_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5100c660" };
    var var2_4208892_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x5100c660" };
    $R0: bv64 := zero_extend(32, bvadd(bvadd(var2_4208892_bv32:bv32, 0xffffffce:bv32), 0x1:bv32)) { .comment = "op: 0x5100c660" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208896_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12003c00" };
    var var1_4208896_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x12003c00" };
    $R0: bv64 := zero_extend(32, bvand(var1_4208896_bv32:bv32, 0xffff:bv32)) { .comment = "op: 0x12003c00" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208900_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100201f" };
    var var2_4208900_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100201f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffffffffff7:bv64), 0x1:bv64)))) { .comment = "op: 0x7100201f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xfffffff7:bv64), 0x1:bv64)))) { .comment = "op: 0x7100201f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100201f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffff7:bv32), 0x1:bv32)) { .comment = "op: 0x7100201f" };
    goto(%__fmtdispatch_143);
  ];
  block %__fmtdispatch_147 {.address = 0x4038f4; .originalLabel = "8GKFjYa1RAS5uFVh244sUw=="} [
    goto(%__fmtdispatch_51, %__fmtdispatch_145);
  ];
  block %__fmtdispatch_149 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4038f4:bv64;
    assert eq($_PC:bv64, 0x4038f4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038f4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208884_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100c27f" };
    var var2_4208884_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100c27f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), 0xffffffffffffffcf:bv64), 0x1:bv64)))) { .comment = "op: 0x7100c27f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), 0xffffffcf:bv64), 0x1:bv64)))) { .comment = "op: 0x7100c27f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100c27f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffcf:bv32), 0x1:bv32)) { .comment = "op: 0x7100c27f" };
    goto(%__fmtdispatch_147);
  ];
  block %__fmtdispatch_151 [
    guard eq(extract(32, 0, $R19:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a94:bv64;
    goto(%__fmtdispatch_55);
  ];
  block %__fmtdispatch_153 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40398c:bv64;
    goto(%__fmtdispatch_135);
  ];
  block %__fmtdispatch_155 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R3:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403960:bv64;
    goto(%__fmtdispatch_13);
  ];
  block %__fmtdispatch_157 {.address = 0x403a0c; .originalLabel = "ijgur++vTcCsp4pKJnPujQ=="} [
    goto(%__fmtdispatch_13);
  ];
  block %__fmtdispatch_159 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x2:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a0c:bv64;
    assert eq($_PC:bv64, 0x403a0c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a0c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x92400002" };
    var var1_4209164_bv64: bv64 := $R0:bv64 { .comment = "op: 0x92400002" };
    $R2: bv64 := bvand(var1_4209164_bv64:bv64, 0x1:bv64) { .comment = "op: 0x92400002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209168_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b0303e3" };
    var var1_4209168_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b0303e3" };
    var var2_4209168_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b0303e3" };
    var var2_4209168_bv32: bv32 := extract(32, 0, $R3:bv64) { .comment = "op: 0x4b0303e3" };
    $R3: bv64 := zero_extend(32, bvadd(bvadd(var1_4209168_bv32:bv32, bvnot(bvshl(var2_4209168_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b0303e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209172_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb27f0000" };
    var var1_4209172_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb27f0000" };
    $R0: bv64 := bvor(var1_4209172_bv64:bv64, 0x2:bv64) { .comment = "op: 0xb27f0000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd2" };
    $_PC: bv64 := 0x403960:bv64 { .comment = "op: 0x17ffffd2" };
    goto(%__fmtdispatch_157);
  ];
  block %__fmtdispatch_161 {.address = 0x4038e0; .originalLabel = "BVzzsF6IRgae2Z/4AOWIqg=="} [
    assert eq($_PC:bv64, 0x4038e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038e0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var1_4208864_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208864_bv64: bv64 := load le $mem bvadd(var1_4208864_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf94036a0" };
    $R0: bv64 := var2_4208864_bv64:bv64 { .comment = "op: 0xf94036a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x5:bv64 { .comment = "op: 0xd28000a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208872_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa010000" };
    var var1_4208872_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa010000" };
    var var2_4208872_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa010000" };
    var var2_4208872_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa010000" };
    $R0: bv64 := bvor(var1_4208872_bv64:bv64, bvshl(var2_4208872_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa010000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208876_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf90036a0" };
    store le $mem bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64 { .comment = "op: 0xf90036a0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffda" };
    $_PC: bv64 := 0x403858:bv64 { .comment = "op: 0x17ffffda" };
    goto(%__fmtdispatch_225);
  ];
  block %__fmtdispatch_163 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4038e0:bv64;
    goto(%__fmtdispatch_161);
  ];
  block %__fmtdispatch_165 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_211);
  ];
  block %__fmtdispatch_167 {.address = 0x40385c; .originalLabel = "Dt4Wk+VzQ0C41AwU03DFcw=="} [
    assert eq($_PC:bv64, 0x40385c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40385c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208732_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x78402693" };
    var var1_4208732_bv64: bv64 := $R20:bv64 { .comment = "op: 0x78402693" };
    var var2_4208732_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x78402693" };
    var var2_4208732_bv16: bv16 := load le $mem var1_4208732_bv64:bv64 16 { .comment = "op: 0x78402693" };
    $R19: bv64 := zero_extend(32, zero_extend(16, var2_4208732_bv16:bv16)) { .comment = "op: 0x78402693" };
    $R20: bv64 := bvadd(var1_4208732_bv64:bv64, 0x2:bv64) { .comment = "op: 0x78402693" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9005ab3" };
    store le $mem bvadd($R21:bv64, 0x58:bv64) extract(32, 0, $R19:bv64) 32 { .comment = "op: 0xb9005ab3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208740_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ba7f" };
    var var2_4208740_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ba7f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), 0xffffffffffffffd1:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ba7f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), 0xffffffd1:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ba7f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100ba7f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)) { .comment = "op: 0x7100ba7f" };
    goto(%__fmtdispatch_163, %__fmtdispatch_165);
  ];
  block %__fmtdispatch_169 [
    guard boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40385c:bv64;
    goto(%__fmtdispatch_167);
  ];
  block %__fmtdispatch_171 {.address = 0x4038bc; .originalLabel = "pclxHqDsSsCfIdCMNF30Vw=="} [
    goto(%__fmtdispatch_219);
  ];
  block %__fmtdispatch_173 [
    guard boolnot(boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4038bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038bc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_171);
  ];
  block %__fmtdispatch_175 {.address = 0x4038ac; .originalLabel = "lNYUG67+ShuEegbVMds0ng=="} [
    goto(%__fmtdispatch_169, %__fmtdispatch_173);
  ];
  block %__fmtdispatch_177 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x2:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4038ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038ac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x927df800" };
    var var1_4208812_bv64: bv64 := $R0:bv64 { .comment = "op: 0x927df800" };
    $R0: bv64 := bvand(var1_4208812_bv64:bv64, 0xfffffffffffffffb:bv64) { .comment = "op: 0x927df800" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208816_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90062bf" };
    store le $mem bvadd($R21:bv64, 0x60:bv64) 0x0:bv32 32 { .comment = "op: 0xb90062bf" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208820_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf90036a0" };
    store le $mem bvadd($R21:bv64, 0x68:bv64) $R0:bv64 64 { .comment = "op: 0xf90036a0" };
    goto(%__fmtdispatch_175);
  ];
  block %__fmtdispatch_179 {.address = 0x4038a8; .originalLabel = "WZqV8BCUQN+JKYNESK+sRw=="} [
    goto(%__fmtdispatch_159, %__fmtdispatch_177);
  ];
  block %__fmtdispatch_181 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R3:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4038a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038a8:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_179);
  ];
  block %__fmtdispatch_183 {.address = 0x403898; .originalLabel = "r6d9duu0Q1WOz2e6oRDXlg=="} [
    assert eq($_PC:bv64, 0x403898:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403898:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208792_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400003" };
    var var1_4208792_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9400003" };
    var var2_4208792_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400003" };
    var var2_4208792_bv32: bv32 := load le $mem bvadd(var1_4208792_bv64:bv64, 0x0:bv64) 32 { .comment = "op: 0xb9400003" };
    $R3: bv64 := zero_extend(32, var2_4208792_bv32:bv32) { .comment = "op: 0xb9400003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208796_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var1_4208796_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208796_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94036a0" };
    var var2_4208796_bv64: bv64 := load le $mem bvadd(var1_4208796_bv64:bv64, 0x68:bv64) 64 { .comment = "op: 0xf94036a0" };
    $R0: bv64 := var2_4208796_bv64:bv64 { .comment = "op: 0xf94036a0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x92400002" };
    var var1_4208800_bv64: bv64 := $R0:bv64 { .comment = "op: 0x92400002" };
    $R2: bv64 := bvand(var1_4208800_bv64:bv64, 0x1:bv64) { .comment = "op: 0x92400002" };
    goto(%__fmtdispatch_155, %__fmtdispatch_181);
  ];
  block %__fmtdispatch_185 {.address = 0x40388c; .originalLabel = "PZzGwmf9SbSu1bOfejhsZQ=="} [
    assert eq($_PC:bv64, 0x40388c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40388c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002c01" };
    var var2_4208780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002c01" };
    var var2_4208780_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91002c01" };
    $R1: bv64 := bvadd(var2_4208780_bv64:bv64, 0xb:bv64) { .comment = "op: 0x91002c01" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208784_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x927df021" };
    var var1_4208784_bv64: bv64 := $R1:bv64 { .comment = "op: 0x927df021" };
    $R1: bv64 := bvand(var1_4208784_bv64:bv64, 0xfffffffffffffff8:bv64) { .comment = "op: 0x927df021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208788_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9001ea1" };
    store le $mem bvadd($R21:bv64, 0x38:bv64) $R1:bv64 64 { .comment = "op: 0xf9001ea1" };
    goto(%__fmtdispatch_183);
  ];
  block %__fmtdispatch_187 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40388c:bv64;
    goto(%__fmtdispatch_185);
  ];
  block %__fmtdispatch_189 {.address = 0x403a74; .originalLabel = "Yy+al2tDTnCCzXZCqe0HCQ=="} [
    goto(%__fmtdispatch_183);
  ];
  block %__fmtdispatch_191 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403a74:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a74:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400440" };
    var var1_4209268_bv64: bv64 := $R2:bv64 { .comment = "op: 0xf9400440" };
    var var2_4209268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400440" };
    var var2_4209268_bv64: bv64 := load le $mem bvadd(var1_4209268_bv64:bv64, 0x8:bv64) 64 { .comment = "op: 0xf9400440" };
    $R0: bv64 := var2_4209268_bv64:bv64 { .comment = "op: 0xf9400440" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b21c000" };
    var var2_4209272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b21c000" };
    var var2_4209272_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b21c000" };
    var var3_4209272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b21c000" };
    var var3_4209272_bv64: bv64 := $R1:bv64 { .comment = "op: 0x8b21c000" };
    $R0: bv64 := bvadd(var2_4209272_bv64:bv64, sign_extend(32, extract(32, 0, var3_4209272_bv64:bv64))) { .comment = "op: 0x8b21c000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffff87" };
    $_PC: bv64 := 0x403898:bv64 { .comment = "op: 0x17ffff87" };
    goto(%__fmtdispatch_189);
  ];
  block %__fmtdispatch_193 {.address = 0x403a64; .originalLabel = "QASrtSSFSZGs+AM8gjekag=="} [
    goto(%__fmtdispatch_187, %__fmtdispatch_191);
  ];
  block %__fmtdispatch_195 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R1:bv64), zero_extend(20, 0x1f:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x403a64:bv64;
    assert eq($_PC:bv64, 0x403a64:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403a64:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209252_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11002023" };
    var var2_4209252_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x11002023" };
    var var2_4209252_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x11002023" };
    $R3: bv64 := zero_extend(32, bvadd(var2_4209252_bv32:bv32, 0x8:bv32)) { .comment = "op: 0x11002023" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209256_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9001843" };
    store le $mem bvadd($R2:bv64, 0x18:bv64) extract(32, 0, $R3:bv64) 32 { .comment = "op: 0xb9001843" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4209260_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100007f" };
    var var2_4209260_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100007f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R3:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100007f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R3:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100007f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100007f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R3:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100007f" };
    goto(%__fmtdispatch_193);
  ];
  block %__fmtdispatch_197 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R1:bv64), zero_extend(20, 0x1f:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_185);
  ];
  block %__fmtdispatch_199 {.address = 0x40387c; .originalLabel = "SQ4HMTCaTKqkEAYf7JKVCQ=="} [
    goto(%__fmtdispatch_195, %__fmtdispatch_197);
  ];
  block %__fmtdispatch_201 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40387c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40387c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94052a1" };
    var var1_4208764_bv64: bv64 := $R21:bv64 { .comment = "op: 0xb94052a1" };
    var var2_4208764_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94052a1" };
    var var2_4208764_bv32: bv32 := load le $mem bvadd(var1_4208764_bv64:bv64, 0x50:bv64) 32 { .comment = "op: 0xb94052a1" };
    $R1: bv64 := zero_extend(32, var2_4208764_bv32:bv32) { .comment = "op: 0xb94052a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100e2a2" };
    var var2_4208768_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100e2a2" };
    var var2_4208768_bv64: bv64 := $R21:bv64 { .comment = "op: 0x9100e2a2" };
    $R2: bv64 := bvadd(var2_4208768_bv64:bv64, 0x38:bv64) { .comment = "op: 0x9100e2a2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401ea0" };
    var var1_4208772_bv64: bv64 := $R21:bv64 { .comment = "op: 0xf9401ea0" };
    var var2_4208772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401ea0" };
    var var2_4208772_bv64: bv64 := load le $mem bvadd(var1_4208772_bv64:bv64, 0x38:bv64) 64 { .comment = "op: 0xf9401ea0" };
    $R0: bv64 := var2_4208772_bv64:bv64 { .comment = "op: 0xf9401ea0" };
    goto(%__fmtdispatch_199);
  ];
  block %__fmtdispatch_203 {.address = 0x403874; .originalLabel = "M9AFxR1iTduPKSkLjz/oaA=="} [
    goto(%__fmtdispatch_153, %__fmtdispatch_201);
  ];
  block %__fmtdispatch_205 [
    guard boolnot(eq(extract(32, 0, $R19:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403874:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403874:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208756_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100aa7f" };
    var var2_4208756_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100aa7f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), 0xffffffffffffffd5:bv64), 0x1:bv64)))) { .comment = "op: 0x7100aa7f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), 0xffffffd5:bv64), 0x1:bv64)))) { .comment = "op: 0x7100aa7f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100aa7f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd5:bv32), 0x1:bv32)) { .comment = "op: 0x7100aa7f" };
    goto(%__fmtdispatch_203);
  ];
  block %__fmtdispatch_207 {.address = 0x403870; .originalLabel = "D3ArWc4VTka0t1b3SJ0r2Q=="} [
    goto(%__fmtdispatch_151, %__fmtdispatch_205);
  ];
  block %__fmtdispatch_209 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x403870:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403870:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_207);
  ];
  block %__fmtdispatch_211 {.address = 0x40386c; .originalLabel = "4bvo2N+lQeeD+hTLfjlpGA=="} [
    assert eq($_PC:bv64, 0x40386c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40386c:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_149, %__fmtdispatch_209);
  ];
  block %__fmtdispatch_213 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40386c:bv64;
    goto(%__fmtdispatch_211);
  ];
  block %__fmtdispatch_215 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_161);
  ];
  block %__fmtdispatch_217 {.address = 0x4038cc; .originalLabel = "GPxw+GtrTQGvMy3ShsHRgA=="} [
    assert eq($_PC:bv64, 0x4038cc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038cc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208844_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x79409ff3" };
    var var1_4208844_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x4e:bv64) 16 { .comment = "op: 0x79409ff3" };
    $R19: bv64 := zero_extend(32, zero_extend(16, var1_4208844_bv16:bv16)) { .comment = "op: 0x79409ff3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208848_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9005ab3" };
    store le $mem bvadd($R21:bv64, 0x58:bv64) extract(32, 0, $R19:bv64) 32 { .comment = "op: 0xb9005ab3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var2_4208852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var2_4208852_bv64: bv64 := $R20:bv64 { .comment = "op: 0x8b20c294" };
    var var3_4208852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var3_4208852_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c294" };
    $R20: bv64 := bvadd(var2_4208852_bv64:bv64, sign_extend(32, extract(32, 0, var3_4208852_bv64:bv64))) { .comment = "op: 0x8b20c294" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208856_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ba7f" };
    var var2_4208856_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100ba7f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R19:bv64)), 0xffffffffffffffd1:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ba7f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R19:bv64)), 0xffffffd1:bv64), 0x1:bv64)))) { .comment = "op: 0x7100ba7f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100ba7f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R19:bv64), 0xffffffd1:bv32), 0x1:bv32)) { .comment = "op: 0x7100ba7f" };
    goto(%__fmtdispatch_213, %__fmtdispatch_215);
  ];
  block %__fmtdispatch_219 {.address = 0x4038c0; .originalLabel = "ruCUpgiXR+iyRXKNWau8KQ=="} [
    assert eq($_PC:bv64, 0x4038c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4038c0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var1_4208832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4208832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4208832_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e1" };
    $R1: bv64 := bvor(var1_4208832_bv64:bv64, bvshl(var2_4208832_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4208836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91013be0" };
    $R0: bv64 := bvadd($R31:bv64, 0x4e:bv64) { .comment = "op: 0x91013be0" };
    $R30: bv64 := 0x4038cc:bv64 { .comment = "op: 0x940000e6" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940000e6" };
    $_PC: bv64 := 0x403c60:bv64 { .comment = "op: 0x940000e6" };
    call @chartorune_4209760 ();
    goto(%__fmtdispatch_217);
  ];
  block %__fmtdispatch_221 [
    guard eq(extract(32, 0, $R22:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4038c0:bv64;
    goto(%__fmtdispatch_219);
  ];
  block %__fmtdispatch_223 [
    guard boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%__fmtdispatch_167);
  ];
  block %__fmtdispatch_225 {.address = 0x403858; .originalLabel = "HDFVIQt2SMG4VryJW6AkVg=="} [
    assert eq($_PC:bv64, 0x403858:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x403858:bv64)"; .label = "pc-tracking" };
    goto(%__fmtdispatch_221, %__fmtdispatch_223);
  ];
  block %__fmtdispatch_basil_return_1 [
    return ();
  ]
];


proc @dofmt_4202176 () -> ()
  { .name = "dofmt"; .address = 0x401ec0; .returnBlock = "dofmt_basil_return_1" }
  require eq($_PC:bv64, 0x401ec0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %dofmt_entry {.address = 0x401ec0; .originalLabel = "ptCQBLyvTM22JSPE/cK18w=="} [
    assert eq($_PC:bv64, 0x401ec0:bv64);
    $_PC: bv64 := 0x401ec0:bv64;
    assert eq($_PC:bv64, 0x401ec0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ec0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9ba7bfd" };
    var var1_4202176_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9ba7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffa0:bv64) $R29:bv64 64 { .comment = "op: 0xa9ba7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffa0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9ba7bfd" };
    $R31: bv64 := bvadd(var1_4202176_bv64:bv64, 0xffffffffffffffa0:bv64) { .comment = "op: 0xa9ba7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202180_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202188_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var1_4202188_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4202188_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4202188_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f4" };
    $R20: bv64 := bvor(var1_4202188_bv64:bv64, bvshl(var2_4202188_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R23:bv64 64 { .comment = "op: 0xa90363f7" };
    store le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) $R24:bv64 64 { .comment = "op: 0xa90363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f7" };
    var var1_4202196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f7" };
    var var2_4202196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f7" };
    var var2_4202196_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f7" };
    $R23: bv64 := bvor(var1_4202196_bv64:bv64, bvshl(var2_4202196_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9403018" };
    var var1_4202200_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9403018" };
    var var2_4202200_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9403018" };
    var var2_4202200_bv32: bv32 := load le $mem bvadd(var1_4202200_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb9403018" };
    $R24: bv64 := zero_extend(32, var2_4202200_bv32:bv32) { .comment = "op: 0xb9403018" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x40:bv64) $R25:bv64 64 { .comment = "op: 0xf90023f9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_165);
  ];
  block %dofmt_3 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ee8:bv64;
    goto(%dofmt_165);
  ];
  block %dofmt_5 {.address = 0x4020c4; .originalLabel = "aBMifaipRq2K6Dl1r0S9qw=="} [
    assert eq($_PC:bv64, 0x4020c4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4020c4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4202692_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4202692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4202692_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4202692_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4202692_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4202700_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4202700_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4202700_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4202700_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4202700_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var1_4202704_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xa94363f7" };
    var var2_4202704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var2_4202704_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94363f7" };
    $R23: bv64 := var1_4202704_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $R24: bv64 := var2_4202704_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94023f9" };
    var var1_4202708_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x40:bv64) 64 { .comment = "op: 0xf94023f9" };
    $R25: bv64 := var1_4202708_bv64:bv64 { .comment = "op: 0xf94023f9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202712_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var1_4202712_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c67bfd" };
    var var2_4202712_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var2_4202712_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c67bfd" };
    var var3_4202712_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var3_4202712_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c67bfd" };
    $R29: bv64 := var2_4202712_bv64:bv64 { .comment = "op: 0xa8c67bfd" };
    $R30: bv64 := var3_4202712_bv64:bv64 { .comment = "op: 0xa8c67bfd" };
    $R31: bv64 := bvadd(var1_4202712_bv64:bv64, 0x60:bv64) { .comment = "op: 0xa8c67bfd" };
    var var1_4202716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%dofmt_basil_return_1);
  ];
  block %dofmt_7 [
    guard boolnot(boolnot(eq($R0:bv64, 0x0:bv64)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_5);
  ];
  block %dofmt_9 {.address = 0x4020bc; .originalLabel = "hrY374OTR6+VQLvmcm3GZA=="} [
    assert eq($_PC:bv64, 0x4020bc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4020bc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202684_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f4" };
    var var1_4202684_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f4" };
    var var2_4202684_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f4" };
    var var2_4202684_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f4" };
    $R20: bv64 := bvor(var1_4202684_bv64:bv64, bvshl(var2_4202684_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f4" };
    goto(%dofmt_3, %dofmt_7);
  ];
  block %dofmt_11 {.address = 0x4020a8; .originalLabel = "zv1tBw7VQzSyBniNNfYz9g=="} [
    assert eq($_PC:bv64, 0x4020a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4020a8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202664_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa90166f3" };
    store le $mem bvadd($R23:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90166f3" };
    store le $mem bvadd(bvadd($R23:bv64, 0x10:bv64), 0x8:bv64) $R25:bv64 64 { .comment = "op: 0xa90166f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x0:bv64 { .comment = "op: 0x52800002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202672_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90032e0" };
    store le $mem bvadd($R23:bv64, 0x30:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb90032e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202676_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var1_4202676_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202676_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202676_bv64: bv64 := $R23:bv64 { .comment = "op: 0xaa1703e0" };
    $R0: bv64 := bvor(var1_4202676_bv64:bv64, bvshl(var2_4202676_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1703e0" };
    $R30: bv64 := 0x4020bc:bv64 { .comment = "op: 0x940005de" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940005de" };
    $_PC: bv64 := 0x403830:bv64 { .comment = "op: 0x940005de" };
    call @__fmtdispatch_4208688 ();
    goto(%dofmt_9);
  ];
  block %dofmt_13 {.address = 0x402094; .originalLabel = "8JIxWbtYQWOWlqMw6SJ0+g=="} [
    goto(%dofmt_11);
  ];
  block %dofmt_15 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402094:bv64;
    assert eq($_PC:bv64, 0x402094:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402094:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202644_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae2" };
    var var1_4202644_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ae2" };
    var var2_4202644_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae2" };
    var var2_4202644_bv64: bv64 := load le $mem bvadd(var1_4202644_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400ae2" };
    $R2: bv64 := var2_4202644_bv64:bv64 { .comment = "op: 0xf9400ae2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202648_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000681" };
    var var2_4202648_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000681" };
    var var2_4202648_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000681" };
    $R1: bv64 := bvadd(var2_4202648_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000681" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202652_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94032e0" };
    var var1_4202652_bv64: bv64 := $R23:bv64 { .comment = "op: 0xb94032e0" };
    var var2_4202652_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94032e0" };
    var var2_4202652_bv32: bv32 := load le $mem bvadd(var1_4202652_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb94032e0" };
    $R0: bv64 := zero_extend(32, var2_4202652_bv32:bv32) { .comment = "op: 0xb94032e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202656_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020262" };
    var var1_4202656_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb020262" };
    var var2_4202656_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020262" };
    var var2_4202656_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb020262" };
    $R2: bv64 := bvadd(bvadd(var1_4202656_bv64:bv64, bvnot(bvshl(var2_4202656_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb020262" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202660_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020000" };
    var var1_4202660_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb020000" };
    var var2_4202660_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020000" };
    var var2_4202660_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0xb020000" };
    $R0: bv64 := zero_extend(32, bvadd(var1_4202660_bv32:bv32, bvshl(var2_4202660_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb020000" };
    goto(%dofmt_13);
  ];
  block %dofmt_17 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4020c4:bv64;
    goto(%dofmt_5);
  ];
  block %dofmt_19 {.address = 0x402024; .originalLabel = "E3IX9P6kRU+oVIK+4cYp6g=="} [
    assert eq($_PC:bv64, 0x402024:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402024:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94032e1" };
    var var1_4202532_bv64: bv64 := $R23:bv64 { .comment = "op: 0xb94032e1" };
    var var2_4202532_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94032e1" };
    var var2_4202532_bv32: bv32 := load le $mem bvadd(var1_4202532_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb94032e1" };
    $R1: bv64 := zero_extend(32, var2_4202532_bv32:bv32) { .comment = "op: 0xb94032e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202536_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000af3" };
    store le $mem bvadd($R23:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xf9000af3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202540_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb010000" };
    var var1_4202540_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb010000" };
    var var2_4202540_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb010000" };
    var var2_4202540_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0xb010000" };
    $R0: bv64 := zero_extend(32, bvadd(var1_4202540_bv32:bv32, bvshl(var2_4202540_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb010000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202544_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb90032e0" };
    store le $mem bvadd($R23:bv64, 0x30:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb90032e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202548_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4202548_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4202548_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4202548_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4202548_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4202548_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202552_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180000" };
    var var1_4202552_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x4b180000" };
    var var2_4202552_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b180000" };
    var var2_4202552_bv32: bv32 := extract(32, 0, $R24:bv64) { .comment = "op: 0x4b180000" };
    $R0: bv64 := zero_extend(32, bvadd(bvadd(var1_4202552_bv32:bv32, bvnot(bvshl(var2_4202552_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b180000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4202556_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4202556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4202556_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4202556_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4202556_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202560_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var1_4202560_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x30:bv64) 64 { .comment = "op: 0xa94363f7" };
    var var2_4202560_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94363f7" };
    var var2_4202560_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94363f7" };
    $R23: bv64 := var1_4202560_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $R24: bv64 := var2_4202560_bv64:bv64 { .comment = "op: 0xa94363f7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202564_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94023f9" };
    var var1_4202564_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x40:bv64) 64 { .comment = "op: 0xf94023f9" };
    $R25: bv64 := var1_4202564_bv64:bv64 { .comment = "op: 0xf94023f9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var1_4202568_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c67bfd" };
    var var2_4202568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var2_4202568_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c67bfd" };
    var var3_4202568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c67bfd" };
    var var3_4202568_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c67bfd" };
    $R29: bv64 := var2_4202568_bv64:bv64 { .comment = "op: 0xa8c67bfd" };
    $R30: bv64 := var3_4202568_bv64:bv64 { .comment = "op: 0xa8c67bfd" };
    $R31: bv64 := bvadd(var1_4202568_bv64:bv64, 0x60:bv64) { .comment = "op: 0xa8c67bfd" };
    var var1_4202572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%dofmt_basil_return_1);
  ];
  block %dofmt_21 {.address = 0x40201c; .originalLabel = "6JWasp/WRMOHedOB+3JikA=="} [
    assert eq($_PC:bv64, 0x40201c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40201c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae0" };
    var var1_4202524_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ae0" };
    var var2_4202524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae0" };
    var var2_4202524_bv64: bv64 := load le $mem bvadd(var1_4202524_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400ae0" };
    $R0: bv64 := var2_4202524_bv64:bv64 { .comment = "op: 0xf9400ae0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202528_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b000260" };
    var var1_4202528_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x4b000260" };
    var var2_4202528_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x4b000260" };
    var var2_4202528_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x4b000260" };
    $R0: bv64 := zero_extend(32, bvadd(bvadd(var1_4202528_bv32:bv32, bvnot(bvshl(var2_4202528_bv32:bv32, zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x4b000260" };
    goto(%dofmt_19);
  ];
  block %dofmt_23 [
    guard eq(extract(32, 0, $R21:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40201c:bv64;
    goto(%dofmt_21);
  ];
  block %dofmt_25 [
    guard boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_91);
  ];
  block %dofmt_27 {.address = 0x401fb4; .originalLabel = "QRbY4PBwTh21Vmb2CL/FRA=="} [
    assert eq($_PC:bv64, 0x401fb4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fb4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202420_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400295" };
    var var1_4202420_bv64: bv64 := $R20:bv64 { .comment = "op: 0x39400295" };
    var var2_4202420_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400295" };
    var var2_4202420_bv8: bv8 := load le $mem bvadd(var1_4202420_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400295" };
    $R21: bv64 := zero_extend(32, zero_extend(24, var2_4202420_bv8:bv8)) { .comment = "op: 0x39400295" };
    goto(%dofmt_23, %dofmt_25);
  ];
  block %dofmt_29 {.address = 0x401fa8; .originalLabel = "wIm8Vvo7TjyL9D3b/kD7Zw=="} [
    assert eq($_PC:bv64, 0x401fa8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fa8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000694" };
    var var2_4202408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000694" };
    var var2_4202408_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000694" };
    $R20: bv64 := bvadd(var2_4202408_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202412_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39000275" };
    store le $mem bvadd($R19:bv64, 0x0:bv64) extract(8, 0, $R21:bv64) 8 { .comment = "op: 0x39000275" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4202416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202416_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4202416_bv64:bv64, bvshl(var2_4202416_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    goto(%dofmt_27);
  ];
  block %dofmt_31 {.address = 0x402068; .originalLabel = "cWrO+VH4SiG8EHbalS0sSQ=="} [
    goto(%dofmt_29);
  ];
  block %dofmt_33 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x402068:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402068:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202600_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var1_4202600_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202600_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202600_bv64: bv64 := load le $mem bvadd(var1_4202600_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400ef9" };
    $R25: bv64 := var2_4202600_bv64:bv64 { .comment = "op: 0xf9400ef9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000400" };
    var var2_4202604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000400" };
    var var2_4202604_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91000400" };
    $R0: bv64 := bvadd(var2_4202604_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000400" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffce" };
    $_PC: bv64 := 0x401fa8:bv64 { .comment = "op: 0x17ffffce" };
    goto(%dofmt_31);
  ];
  block %dofmt_35 {.address = 0x402060; .originalLabel = "tXzalJvbQwKAdIiOOv4DXg=="} [
    assert eq($_PC:bv64, 0x402060:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402060:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4202592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202592_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4202592_bv64:bv64, bvshl(var2_4202592_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    goto(%dofmt_17, %dofmt_33);
  ];
  block %dofmt_37 {.address = 0x402050; .originalLabel = "7P9mYTSsTleIcDb/bAgttw=="} [
    goto(%dofmt_35);
  ];
  block %dofmt_39 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402050:bv64;
    assert eq($_PC:bv64, 0x402050:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402050:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4202576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202576_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4202576_bv64:bv64, bvshl(var2_4202576_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202580_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var1_4202580_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202580_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202580_bv64: bv64 := $R23:bv64 { .comment = "op: 0xaa1703e0" };
    $R0: bv64 := bvor(var1_4202580_bv64:bv64, bvshl(var2_4202580_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1703e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x1:bv64 { .comment = "op: 0x52800022" };
    $R30: bv64 := 0x402060:bv64 { .comment = "op: 0x97ffff75" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff75" };
    $_PC: bv64 := 0x401e30:bv64 { .comment = "op: 0x97ffff75" };
    call @__fmtflush_4202032 ();
    goto(%dofmt_37);
  ];
  block %dofmt_41 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_29);
  ];
  block %dofmt_43 {.address = 0x401f9c; .originalLabel = "RU2jCutqQZya69QyDDqd2w=="} [
    goto(%dofmt_39, %dofmt_41);
  ];
  block %dofmt_45 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f9c:bv64;
    assert eq($_PC:bv64, 0x401f9c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f9c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000660" };
    var var2_4202396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000660" };
    var var2_4202396_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91000660" };
    $R0: bv64 := bvadd(var2_4202396_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000660" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19001f" };
    var var2_4202400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0:bv64), sign_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0:bv64), zero_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb19001f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R0:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb19001f" };
    goto(%dofmt_43);
  ];
  block %dofmt_47 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4020c4:bv64;
    goto(%dofmt_5);
  ];
  block %dofmt_49 [
    guard eq(extract(32, 0, $R21:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401fb4:bv64;
    goto(%dofmt_27);
  ];
  block %dofmt_51 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ff8:bv64;
    goto(%dofmt_61);
  ];
  block %dofmt_53 [
    guard boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401fbc:bv64;
    goto(%dofmt_91);
  ];
  block %dofmt_55 [
    guard boolnot(boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_21);
  ];
  block %dofmt_57 {.address = 0x40200c; .originalLabel = "fT/9va8xR3y2KijdpOdg2Q=="} [
    goto(%dofmt_53, %dofmt_55);
  ];
  block %dofmt_59 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40200c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40200c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b040294" };
    var var1_4202508_bv64: bv64 := $R20:bv64 { .comment = "op: 0x8b040294" };
    var var2_4202508_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b040294" };
    var var2_4202508_bv64: bv64 := $R4:bv64 { .comment = "op: 0x8b040294" };
    $R20: bv64 := bvadd(var1_4202508_bv64:bv64, bvshl(var2_4202508_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0x8b040294" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b040273" };
    var var1_4202512_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b040273" };
    var var2_4202512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b040273" };
    var var2_4202512_bv64: bv64 := $R4:bv64 { .comment = "op: 0x8b040273" };
    $R19: bv64 := bvadd(var1_4202512_bv64:bv64, bvshl(var2_4202512_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0x8b040273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400295" };
    var var1_4202516_bv64: bv64 := $R20:bv64 { .comment = "op: 0x39400295" };
    var var2_4202516_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400295" };
    var var2_4202516_bv8: bv8 := load le $mem bvadd(var1_4202516_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400295" };
    $R21: bv64 := zero_extend(32, zero_extend(24, var2_4202516_bv8:bv8)) { .comment = "op: 0x39400295" };
    goto(%dofmt_57);
  ];
  block %dofmt_61 {.address = 0x401ff8; .originalLabel = "VNeNOxsKQqSEmHdPHBM/kg=="} [
    assert eq($_PC:bv64, 0x401ff8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ff8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38636a81" };
    var var1_4202488_bv64: bv64 := $R3:bv64 { .comment = "op: 0x38636a81" };
    var var2_4202488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38636a81" };
    var var2_4202488_bv64: bv64 := $R20:bv64 { .comment = "op: 0x38636a81" };
    var var3_4202488_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x38636a81" };
    var var3_4202488_bv8: bv8 := load le $mem bvadd(var2_4202488_bv64:bv64, var1_4202488_bv64:bv64) 8 { .comment = "op: 0x38636a81" };
    $R1: bv64 := zero_extend(32, zero_extend(24, var3_4202488_bv8:bv8)) { .comment = "op: 0x38636a81" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38236a61" };
    var var2_4202492_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x38236a61" };
    store le $mem bvadd($R19:bv64, $R3:bv64) extract(8, 0, $R1:bv64) 8 { .comment = "op: 0x38236a61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000463" };
    var var2_4202496_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000463" };
    var var2_4202496_bv64: bv64 := $R3:bv64 { .comment = "op: 0x91000463" };
    $R3: bv64 := bvadd(var2_4202496_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000463" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb03009f" };
    var var2_4202500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb03009f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R4:bv64), sign_extend(64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb03009f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R4:bv64), zero_extend(64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb03009f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb03009f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R4:bv64, bvnot(bvshl($R3:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb03009f" };
    goto(%dofmt_51, %dofmt_59);
  ];
  block %dofmt_63 {.address = 0x401ff4; .originalLabel = "o8MIlg1LTdaQ18oIE6mchQ=="} [
    goto(%dofmt_61);
  ];
  block %dofmt_65 [
    guard boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401ff4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ff4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_63);
  ];
  block %dofmt_67 {.address = 0x401fe8; .originalLabel = "dY3S1w9PTCWaU2aloR79sQ=="} [
    assert eq($_PC:bv64, 0x401fe8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fe8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202472_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e4" };
    var var1_4202472_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e4" };
    var var2_4202472_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e4" };
    var var2_4202472_bv32: bv32 := extract(32, 0, $R21:bv64) { .comment = "op: 0x2a1503e4" };
    $R4: bv64 := zero_extend(32, bvor(var1_4202472_bv32:bv32, bvshl(var2_4202472_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1503e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x0:bv64 { .comment = "op: 0xd2800003" };
    goto(%dofmt_49, %dofmt_65);
  ];
  block %dofmt_69 {.address = 0x40208c; .originalLabel = "S4RGIlHUQluEPuYxgeWsdg=="} [
    goto(%dofmt_67);
  ];
  block %dofmt_71 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40208c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40208c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202636_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var1_4202636_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202636_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202636_bv64: bv64 := load le $mem bvadd(var1_4202636_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400ef9" };
    $R25: bv64 := var2_4202636_bv64:bv64 { .comment = "op: 0xf9400ef9" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffd6" };
    $_PC: bv64 := 0x401fe8:bv64 { .comment = "op: 0x17ffffd6" };
    goto(%dofmt_69);
  ];
  block %dofmt_73 {.address = 0x402084; .originalLabel = "BYP+C84YSYikJhVrX90ZCg=="} [
    assert eq($_PC:bv64, 0x402084:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402084:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4202628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4202628_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4202628_bv64:bv64, bvshl(var2_4202628_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    goto(%dofmt_47, %dofmt_71);
  ];
  block %dofmt_75 {.address = 0x402074; .originalLabel = "qeZtIpSHTh+g6IJef9Bp7A=="} [
    goto(%dofmt_73);
  ];
  block %dofmt_77 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x402074:bv64;
    assert eq($_PC:bv64, 0x402074:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x402074:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4202612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202612_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4202612_bv64:bv64, bvshl(var2_4202612_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202616_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e2" };
    var var1_4202616_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e2" };
    var var2_4202616_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e2" };
    var var2_4202616_bv32: bv32 := extract(32, 0, $R21:bv64) { .comment = "op: 0x2a1503e2" };
    $R2: bv64 := zero_extend(32, bvor(var1_4202616_bv32:bv32, bvshl(var2_4202616_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1503e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var1_4202620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202620_bv64: bv64 := $R23:bv64 { .comment = "op: 0xaa1703e0" };
    $R0: bv64 := bvor(var1_4202620_bv64:bv64, bvshl(var2_4202620_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1703e0" };
    $R30: bv64 := 0x402084:bv64 { .comment = "op: 0x97ffff6c" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff6c" };
    $_PC: bv64 := 0x401e30:bv64 { .comment = "op: 0x97ffff6c" };
    call @__fmtflush_4202032 ();
    goto(%dofmt_75);
  ];
  block %dofmt_79 [
    guard boolnot(boolnot(eq($CF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_67);
  ];
  block %dofmt_81 {.address = 0x401fd8; .originalLabel = "WG36rbglTeOpm/4oJfFfLQ=="} [
    assert eq($_PC:bv64, 0x401fd8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fd8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202456_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var1_4202456_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4202456_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4202456_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f5" };
    $R21: bv64 := zero_extend(32, bvor(var1_4202456_bv32:bv32, bvshl(var2_4202456_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c260" };
    var var2_4202460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c260" };
    var var2_4202460_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b20c260" };
    var var3_4202460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c260" };
    var var3_4202460_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c260" };
    $R0: bv64 := bvadd(var2_4202460_bv64:bv64, sign_extend(32, extract(32, 0, var3_4202460_bv64:bv64))) { .comment = "op: 0x8b20c260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202464_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb00033f" };
    var var2_4202464_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb00033f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R25:bv64), sign_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb00033f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R25:bv64), zero_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb00033f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb00033f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R25:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb00033f" };
    goto(%dofmt_77, %dofmt_79);
  ];
  block %dofmt_83 {.address = 0x401fcc; .originalLabel = "uvLZTvJ1S1Cmsp2/+M62dw=="} [
    goto(%dofmt_81);
  ];
  block %dofmt_85 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401fcc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fcc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202444_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var1_4202444_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4202444_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4202444_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e1" };
    $R1: bv64 := bvor(var1_4202444_bv64:bv64, bvshl(var2_4202444_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202448_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91017be0" };
    $R0: bv64 := bvadd($R31:bv64, 0x5e:bv64) { .comment = "op: 0x91017be0" };
    $R30: bv64 := 0x401fd8:bv64 { .comment = "op: 0x94000723" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000723" };
    $_PC: bv64 := 0x403c60:bv64 { .comment = "op: 0x94000723" };
    call @chartorune_4209760 ();
    goto(%dofmt_83);
  ];
  block %dofmt_87 {.address = 0x401fc4; .originalLabel = "MX9iDMayQO607/Lpl0adMw=="} [
    goto(%dofmt_45, %dofmt_85);
  ];
  block %dofmt_89 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401fc4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fc4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202436_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101febf" };
    var var2_4202436_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101febf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101febf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101febf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101febf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101febf" };
    goto(%dofmt_87);
  ];
  block %dofmt_91 {.address = 0x401fbc; .originalLabel = "f7FlJ4WFTFSWt8Vkl0NNFA=="} [
    assert eq($_PC:bv64, 0x401fbc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401fbc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710096bf" };
    var var2_4202428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710096bf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R21:bv64)), 0xffffffffffffffda:bv64), 0x1:bv64)))) { .comment = "op: 0x710096bf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R21:bv64)), 0xffffffda:bv64), 0x1:bv64)))) { .comment = "op: 0x710096bf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710096bf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R21:bv64), 0xffffffda:bv32), 0x1:bv32)) { .comment = "op: 0x710096bf" };
    goto(%dofmt_15, %dofmt_89);
  ];
  block %dofmt_93 [
    guard boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401fbc:bv64;
    goto(%dofmt_91);
  ];
  block %dofmt_95 {.address = 0x4020fc; .originalLabel = "3Wvoe6rNS3C1Isv0mR8Y7A=="} [
    assert eq($_PC:bv64, 0x4020fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4020fc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffc9" };
    $_PC: bv64 := 0x402024:bv64 { .comment = "op: 0x17ffffc9" };
    goto(%dofmt_19);
  ];
  block %dofmt_97 {.address = 0x401f98; .originalLabel = "0h7GTpRXSfyearFVjTPQGA=="} [
    goto(%dofmt_95);
  ];
  block %dofmt_99 [
    guard boolnot(boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401f98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f98:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000059" };
    $_PC: bv64 := 0x4020fc:bv64 { .comment = "op: 0x14000059" };
    goto(%dofmt_97);
  ];
  block %dofmt_101 {.address = 0x401f94; .originalLabel = "E1lsEDgiTjyK2hbrUjrgWA=="} [
    goto(%dofmt_93, %dofmt_99);
  ];
  block %dofmt_103 [
    guard eq(extract(32, 0, $R0:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f94:bv64;
    assert eq($_PC:bv64, 0x401f94:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f94:bv64)"; .label = "pc-tracking" };
    goto(%dofmt_101);
  ];
  block %dofmt_105 {.address = 0x4020e0; .originalLabel = "uQgeSzsmSTSussC/Oda7jw=="} [
    goto(%dofmt_11);
  ];
  block %dofmt_107 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4020e0:bv64;
    assert eq($_PC:bv64, 0x4020e0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4020e0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae2" };
    var var1_4202720_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ae2" };
    var var2_4202720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae2" };
    var var2_4202720_bv64: bv64 := load le $mem bvadd(var1_4202720_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400ae2" };
    $R2: bv64 := var2_4202720_bv64:bv64 { .comment = "op: 0xf9400ae2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202724_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000681" };
    var var2_4202724_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000681" };
    var var2_4202724_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000681" };
    $R1: bv64 := bvadd(var2_4202724_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000681" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202728_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb94032e0" };
    var var1_4202728_bv64: bv64 := $R23:bv64 { .comment = "op: 0xb94032e0" };
    var var2_4202728_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb94032e0" };
    var var2_4202728_bv32: bv32 := load le $mem bvadd(var1_4202728_bv64:bv64, 0x30:bv64) 32 { .comment = "op: 0xb94032e0" };
    $R0: bv64 := zero_extend(32, var2_4202728_bv32:bv32) { .comment = "op: 0xb94032e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202732_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020262" };
    var var1_4202732_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb020262" };
    var var2_4202732_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb020262" };
    var var2_4202732_bv64: bv64 := $R2:bv64 { .comment = "op: 0xcb020262" };
    $R2: bv64 := bvadd(bvadd(var1_4202732_bv64:bv64, bvnot(bvshl(var2_4202732_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb020262" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202736_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9341fc42" };
    var var1_4202736_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9341fc42" };
    $R2: bv64 := bvor(bvand(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(bvconcat(extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12)))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), extract(1, 0, extract(1, 0, bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x3f:bv12))))), 0x8000000000000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x0:bv64), bvand(bvor(bvlshr(var1_4202736_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4202736_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0xffffffffffffffff:bv64)), 0x7fffffffffffffff:bv64)) { .comment = "op: 0x9341fc42" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202740_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020000" };
    var var1_4202740_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0xb020000" };
    var var2_4202740_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb020000" };
    var var2_4202740_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0xb020000" };
    $R0: bv64 := zero_extend(32, bvadd(var1_4202740_bv32:bv32, bvshl(var2_4202740_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xb020000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffec" };
    $_PC: bv64 := 0x4020a8:bv64 { .comment = "op: 0x17ffffec" };
    goto(%dofmt_105);
  ];
  block %dofmt_109 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4020c4:bv64;
    goto(%dofmt_5);
  ];
  block %dofmt_111 [
    guard boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f28:bv64;
    goto(%dofmt_153);
  ];
  block %dofmt_113 {.address = 0x401f84; .originalLabel = "lDscLUVlQLeZdlO8hVxXew=="} [
    assert eq($_PC:bv64, 0x401f84:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f84:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae0" };
    var var1_4202372_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ae0" };
    var var2_4202372_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ae0" };
    var var2_4202372_bv64: bv64 := load le $mem bvadd(var1_4202372_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400ae0" };
    $R0: bv64 := var2_4202372_bv64:bv64 { .comment = "op: 0xf9400ae0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000260" };
    var var1_4202376_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb000260" };
    var var2_4202376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000260" };
    var var2_4202376_bv64: bv64 := $R0:bv64 { .comment = "op: 0xcb000260" };
    $R0: bv64 := bvadd(bvadd(var1_4202376_bv64:bv64, bvnot(bvshl(var2_4202376_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb000260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202380_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd3418000" };
    var var1_4202380_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd3418000" };
    $R0: bv64 := bvor(bvand(0x0:bv64, 0xffffffff00000000:bv64), bvand(bvor(bvand(0x0:bv64, 0x7fffffff00000000:bv64), bvand(bvor(bvlshr(var1_4202380_bv64:bv64, zero_extend(52, 0x1:bv12)), bvshl(var1_4202380_bv64:bv64, zero_extend(48, 0x3f:bv16))), 0x80000000ffffffff:bv64)), 0xffffffff:bv64)) { .comment = "op: 0xd3418000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000025" };
    $_PC: bv64 := 0x402024:bv64 { .comment = "op: 0x14000025" };
    goto(%dofmt_19);
  ];
  block %dofmt_115 [
    guard boolnot(boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_113);
  ];
  block %dofmt_117 {.address = 0x401f70; .originalLabel = "fluuiGXAQmOAmd7scAO0Vg=="} [
    goto(%dofmt_111, %dofmt_115);
  ];
  block %dofmt_119 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401f70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var1_4202352_bv64: bv64 := $R23:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400ef9" };
    var var2_4202352_bv64: bv64 := load le $mem bvadd(var1_4202352_bv64:bv64, 0x18:bv64) 64 { .comment = "op: 0xf9400ef9" };
    $R25: bv64 := var2_4202352_bv64:bv64 { .comment = "op: 0xf9400ef9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000016" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(16, 0, $R22:bv64) 16 { .comment = "op: 0x79000016" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202360_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000813" };
    var var2_4202360_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000813" };
    var var2_4202360_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91000813" };
    $R19: bv64 := bvadd(var2_4202360_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000813" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202364_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400296" };
    var var1_4202364_bv64: bv64 := $R20:bv64 { .comment = "op: 0x39400296" };
    var var2_4202364_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400296" };
    var var2_4202364_bv8: bv8 := load le $mem bvadd(var1_4202364_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400296" };
    $R22: bv64 := zero_extend(32, zero_extend(24, var2_4202364_bv8:bv8)) { .comment = "op: 0x39400296" };
    goto(%dofmt_117);
  ];
  block %dofmt_121 {.address = 0x401f6c; .originalLabel = "IJV3Pd9MTHWIH8jgypmg0w=="} [
    assert eq($_PC:bv64, 0x401f6c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f6c:bv64)"; .label = "pc-tracking" };
    goto(%dofmt_109, %dofmt_119);
  ];
  block %dofmt_123 {.address = 0x401f5c; .originalLabel = "XfWGfMK2QWSEXVhm+DIDfQ=="} [
    assert eq($_PC:bv64, 0x401f5c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f5c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4202332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4202332_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4202332_bv64:bv64, bvshl(var2_4202332_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var1_4202336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1703e0" };
    var var2_4202336_bv64: bv64 := $R23:bv64 { .comment = "op: 0xaa1703e0" };
    $R0: bv64 := bvor(var1_4202336_bv64:bv64, bvshl(var2_4202336_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1703e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x2:bv64 { .comment = "op: 0x52800042" };
    $R30: bv64 := 0x401f6c:bv64 { .comment = "op: 0x97ffffb2" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffffb2" };
    $_PC: bv64 := 0x401e30:bv64 { .comment = "op: 0x97ffffb2" };
    call @__fmtflush_4202032 ();
    goto(%dofmt_121);
  ];
  block %dofmt_125 [
    guard booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f5c:bv64;
    goto(%dofmt_123);
  ];
  block %dofmt_127 [
    guard eq(extract(32, 0, $R22:bv64), 0x0:bv32);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f84:bv64;
    goto(%dofmt_113);
  ];
  block %dofmt_129 [
    guard boolnot(eq(extract(32, 0, $R22:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_153);
  ];
  block %dofmt_131 {.address = 0x401f18; .originalLabel = "VK1/OYWjTWS/G5/r6j9y1Q=="} [
    assert eq($_PC:bv64, 0x401f18:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f18:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x79000016" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) extract(16, 0, $R22:bv64) 16 { .comment = "op: 0x79000016" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var1_4202268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4202268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4202268_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f3" };
    $R19: bv64 := bvor(var1_4202268_bv64:bv64, bvshl(var2_4202268_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400296" };
    var var1_4202272_bv64: bv64 := $R20:bv64 { .comment = "op: 0x39400296" };
    var var2_4202272_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400296" };
    var var2_4202272_bv8: bv8 := load le $mem bvadd(var1_4202272_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400296" };
    $R22: bv64 := zero_extend(32, zero_extend(24, var2_4202272_bv8:bv8)) { .comment = "op: 0x39400296" };
    goto(%dofmt_127, %dofmt_129);
  ];
  block %dofmt_133 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_131);
  ];
  block %dofmt_135 {.address = 0x401f04; .originalLabel = "Ip0SUyhYSvaFEZXs1BsngA=="} [
    goto(%dofmt_125, %dofmt_133);
  ];
  block %dofmt_137 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f04:bv64;
    assert eq($_PC:bv64, 0x401f04:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f04:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a61" };
    var var2_4202244_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a61" };
    var var2_4202244_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91000a61" };
    $R1: bv64 := bvadd(var2_4202244_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000a61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202248_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000694" };
    var var2_4202248_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000694" };
    var var2_4202248_bv64: bv64 := $R20:bv64 { .comment = "op: 0x91000694" };
    $R20: bv64 := bvadd(var2_4202248_bv64:bv64, 0x1:bv64) { .comment = "op: 0x91000694" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4202252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202252_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4202252_bv64:bv64, bvshl(var2_4202252_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202256_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19003f" };
    var var2_4202256_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb19003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb19003f" };
    goto(%dofmt_135);
  ];
  block %dofmt_139 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f18:bv64;
    goto(%dofmt_131);
  ];
  block %dofmt_141 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%dofmt_123);
  ];
  block %dofmt_143 {.address = 0x401f44; .originalLabel = "PwyVLJH8QgyrAitwtJYRCg=="} [
    assert eq($_PC:bv64, 0x401f44:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f44:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202308_bv16: bv16 := 0x0:bv16 { .comment = "op: 0x7940bff6" };
    var var1_4202308_bv16: bv16 := load le $stack bvadd($R31:bv64, 0x5e:bv64) 16 { .comment = "op: 0x7940bff6" };
    $R22: bv64 := zero_extend(32, zero_extend(16, var1_4202308_bv16:bv16)) { .comment = "op: 0x7940bff6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202312_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a61" };
    var var2_4202312_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91000a61" };
    var var2_4202312_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91000a61" };
    $R1: bv64 := bvadd(var2_4202312_bv64:bv64, 0x2:bv64) { .comment = "op: 0x91000a61" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202316_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var2_4202316_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var2_4202316_bv64: bv64 := $R20:bv64 { .comment = "op: 0x8b20c294" };
    var var3_4202316_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b20c294" };
    var var3_4202316_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b20c294" };
    $R20: bv64 := bvadd(var2_4202316_bv64:bv64, sign_extend(32, extract(32, 0, var3_4202316_bv64:bv64))) { .comment = "op: 0x8b20c294" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4202320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4202320_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4202320_bv64:bv64, bvshl(var2_4202320_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202324_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19003f" };
    var var2_4202324_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb19003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb19003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb19003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R25:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb19003f" };
    goto(%dofmt_139, %dofmt_141);
  ];
  block %dofmt_145 {.address = 0x401f38; .originalLabel = "IfXk+cjzSWaG41ufskMYZw=="} [
    goto(%dofmt_143);
  ];
  block %dofmt_147 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401f38:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f38:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var1_4202296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4202296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4202296_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e1" };
    $R1: bv64 := bvor(var1_4202296_bv64:bv64, bvshl(var2_4202296_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202300_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91017be0" };
    $R0: bv64 := bvadd($R31:bv64, 0x5e:bv64) { .comment = "op: 0x91017be0" };
    $R30: bv64 := 0x401f44:bv64 { .comment = "op: 0x94000748" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000748" };
    $_PC: bv64 := 0x403c60:bv64 { .comment = "op: 0x94000748" };
    call @chartorune_4209760 ();
    goto(%dofmt_145);
  ];
  block %dofmt_149 {.address = 0x401f30; .originalLabel = "Tbtm4LoTR86ABQrOCYvzrQ=="} [
    goto(%dofmt_137, %dofmt_147);
  ];
  block %dofmt_151 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401f30:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f30:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202288_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fedf" };
    var var2_4202288_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7101fedf" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R22:bv64)), 0xffffffffffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fedf" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R22:bv64)), 0xffffff80:bv64), 0x1:bv64)))) { .comment = "op: 0x7101fedf" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7101fedf" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffff80:bv32), 0x1:bv32)) { .comment = "op: 0x7101fedf" };
    goto(%dofmt_149);
  ];
  block %dofmt_153 {.address = 0x401f28; .originalLabel = "j7mUHN13SYGqAZudnQnP6Q=="} [
    assert eq($_PC:bv64, 0x401f28:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f28:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202280_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710096df" };
    var var2_4202280_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710096df" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R22:bv64)), 0xffffffffffffffda:bv64), 0x1:bv64)))) { .comment = "op: 0x710096df" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R22:bv64)), 0xffffffda:bv64), 0x1:bv64)))) { .comment = "op: 0x710096df" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710096df" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffda:bv32), 0x1:bv32)) { .comment = "op: 0x710096df" };
    goto(%dofmt_107, %dofmt_151);
  ];
  block %dofmt_155 [
    guard boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401f28:bv64;
    goto(%dofmt_153);
  ];
  block %dofmt_157 {.address = 0x401f00; .originalLabel = "lO2rEmBHTtaOwgzuxhHxmQ=="} [
    goto(%dofmt_95);
  ];
  block %dofmt_159 [
    guard boolnot(boolnot(eq(extract(32, 0, $R21:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401f00:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401f00:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400007f" };
    $_PC: bv64 := 0x4020fc:bv64 { .comment = "op: 0x1400007f" };
    goto(%dofmt_157);
  ];
  block %dofmt_161 {.address = 0x401efc; .originalLabel = "mxwzTeMXQE6jN/Pv8wkPpg=="} [
    goto(%dofmt_155, %dofmt_159);
  ];
  block %dofmt_163 [
    guard boolnot(eq(extract(32, 0, $R0:bv64), 0x0:bv32));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401efc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401efc:bv64)"; .label = "pc-tracking" };
    goto(%dofmt_161);
  ];
  block %dofmt_165 {.address = 0x401ee8; .originalLabel = "5nuvhvzmRHq1ZpIHrerB6A=="} [
    assert eq($_PC:bv64, 0x401ee8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ee8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202216_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x394002e0" };
    var var1_4202216_bv64: bv64 := $R23:bv64 { .comment = "op: 0x394002e0" };
    var var2_4202216_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x394002e0" };
    var var2_4202216_bv8: bv8 := load le $mem bvadd(var1_4202216_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x394002e0" };
    $R0: bv64 := zero_extend(32, zero_extend(24, var2_4202216_bv8:bv8)) { .comment = "op: 0x394002e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x39400295" };
    var var1_4202220_bv64: bv64 := $R20:bv64 { .comment = "op: 0x39400295" };
    var var2_4202220_bv8: bv8 := 0x0:bv8 { .comment = "op: 0x39400295" };
    var var2_4202220_bv8: bv8 := load le $mem bvadd(var1_4202220_bv64:bv64, 0x0:bv64) 8 { .comment = "op: 0x39400295" };
    $R21: bv64 := zero_extend(32, zero_extend(24, var2_4202220_bv8:bv8)) { .comment = "op: 0x39400295" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94166f3" };
    var var1_4202224_bv64: bv64 := $R23:bv64 { .comment = "op: 0xa94166f3" };
    var var2_4202224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94166f3" };
    var var2_4202224_bv64: bv64 := load le $mem bvadd(var1_4202224_bv64:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94166f3" };
    var var3_4202224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94166f3" };
    var var3_4202224_bv64: bv64 := load le $mem bvadd(bvadd(var1_4202224_bv64:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94166f3" };
    $R19: bv64 := var2_4202224_bv64:bv64 { .comment = "op: 0xa94166f3" };
    $R25: bv64 := var3_4202224_bv64:bv64 { .comment = "op: 0xa94166f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503f6" };
    var var1_4202228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503f6" };
    var var2_4202228_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503f6" };
    var var2_4202228_bv32: bv32 := extract(32, 0, $R21:bv64) { .comment = "op: 0x2a1503f6" };
    $R22: bv64 := zero_extend(32, bvor(var1_4202228_bv32:bv32, bvshl(var2_4202228_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1503f6" };
    goto(%dofmt_103, %dofmt_163);
  ];
  block %dofmt_basil_return_1 [
    return ();
  ]
];


proc @vfprint_4201072 () -> ()
  { .name = "vfprint"; .address = 0x401a70; .returnBlock = "vfprint_basil_return_1" }
  require eq($_PC:bv64, 0x401a70:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %vfprint_entry {.address = 0x401a70; .originalLabel = "kh4iUxoKQMenD77ljouyEQ=="} [
    assert eq($_PC:bv64, 0x401a70:bv64);
    $_PC: bv64 := 0x401a70:bv64;
    assert eq($_PC:bv64, 0x401a70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401a70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9a57bfd" };
    var var1_4201072_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9a57bfd" };
    store le $stack bvadd($R31:bv64, 0xfffffffffffffe50:bv64) $R29:bv64 64 { .comment = "op: 0xa9a57bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xfffffffffffffe50:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9a57bfd" };
    $R31: bv64 := bvadd(var1_4201072_bv64:bv64, 0xfffffffffffffe50:bv64) { .comment = "op: 0xa9a57bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x100:bv64 { .comment = "op: 0x52802003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201080_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var1_4201088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var2_4201088_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var2_4201088_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203f3" };
    $R19: bv64 := bvor(var1_4201088_bv64:bv64, bvshl(var2_4201088_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201092_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var1_4201092_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4201092_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f4" };
    var var2_4201092_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f4" };
    $R20: bv64 := bvor(var1_4201092_bv64:bv64, bvshl(var2_4201092_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9102c3e2" };
    $R2: bv64 := bvadd($R31:bv64, 0xb0:bv64) { .comment = "op: 0x9102c3e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201100_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e1" };
    var var1_4201100_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e1" };
    var var2_4201100_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003e1" };
    var var2_4201100_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003e1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4201100_bv32:bv32, bvshl(var2_4201100_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $R30: bv64 := 0x401a98:bv64 { .comment = "op: 0x94000810" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000810" };
    $_PC: bv64 := 0x403ad4:bv64 { .comment = "op: 0x94000810" };
    call @fmtfdinit_4209364 ();
    goto(%vfprint_21);
  ];
  block %vfprint_5 {.address = 0x401ac8; .originalLabel = "pFaL4bnlR5eKTRDrkqDslA=="} [
    assert eq($_PC:bv64, 0x401ac8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ac8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201160_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var1_4201160_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var2_4201160_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1303e0" };
    var var2_4201160_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x2a1303e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4201160_bv32:bv32, bvshl(var2_4201160_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4201164_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4201164_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4201164_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4201164_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4201164_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8db7bfd" };
    var var1_4201168_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8db7bfd" };
    var var2_4201168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8db7bfd" };
    var var2_4201168_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8db7bfd" };
    var var3_4201168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8db7bfd" };
    var var3_4201168_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8db7bfd" };
    $R29: bv64 := var2_4201168_bv64:bv64 { .comment = "op: 0xa8db7bfd" };
    $R30: bv64 := var3_4201168_bv64:bv64 { .comment = "op: 0xa8db7bfd" };
    $R31: bv64 := bvadd(var1_4201168_bv64:bv64, 0x1b0:bv64) { .comment = "op: 0xa8db7bfd" };
    var var1_4201172_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%vfprint_basil_return_1);
  ];
  block %vfprint_7 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ac8:bv64;
    goto(%vfprint_5);
  ];
  block %vfprint_9 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := zero_extend(32, var1_4201156_bv32:bv32);
    goto(%vfprint_5);
  ];
  block %vfprint_11 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := zero_extend(32, bvnot(var2_4201156_bv32:bv32));
    goto(%vfprint_5);
  ];
  block %vfprint_13 {.address = 0x401ac0; .originalLabel = "LdFXyI9vSimOBL1ciuZ/UA=="} [
    assert eq($_PC:bv64, 0x401ac0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ac0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201152_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    var var2_4201152_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100001f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100001f" };
    var var1_4201156_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5a9f1273" };
    var var1_4201156_bv32: bv32 := extract(32, 0, $R19:bv64) { .comment = "op: 0x5a9f1273" };
    var var2_4201156_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5a9f1273" };
    var var2_4201156_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x5a9f1273" };
    goto(%vfprint_9, %vfprint_11);
  ];
  block %vfprint_15 {.address = 0x401ab8; .originalLabel = "eH5IQbG5SZKMIIAkx682MQ=="} [
    goto(%vfprint_13);
  ];
  block %vfprint_17 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401ab8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ab8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201144_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $R30: bv64 := 0x401ac0:bv64 { .comment = "op: 0x9400081d" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400081d" };
    $_PC: bv64 := 0x403b30:bv64 { .comment = "op: 0x9400081d" };
    call @__fmtFdFlush_4209456 ();
    goto(%vfprint_15);
  ];
  block %vfprint_19 {.address = 0x401aac; .originalLabel = "U9QXt0beTG+awBLek5iNWQ=="} [
    assert eq($_PC:bv64, 0x401aac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401aac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201132_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f3" };
    var var1_4201132_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f3" };
    var var2_4201132_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f3" };
    var var2_4201132_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f3" };
    $R19: bv64 := zero_extend(32, bvor(var1_4201132_bv32:bv32, bvshl(var2_4201132_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201136_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    var var2_4201136_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x7100001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100001f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x7100001f" };
    goto(%vfprint_7, %vfprint_17);
  ];
  block %vfprint_21 {.address = 0x401a98; .originalLabel = "B/t0q0P0RPSzoKGe8z1CqA=="} [
    assert eq($_PC:bv64, 0x401a98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401a98:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201112_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400660" };
    var var1_4201112_bv128: bv128 := load le $stack bvadd($R19:bv64, 0x0:bv64) 128 { .comment = "op: 0xad400660" };
    var var2_4201112_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400660" };
    var var2_4201112_bv128: bv128 := load le $stack bvadd(bvadd($R19:bv64, 0x0:bv64), 0x10:bv64) 128 { .comment = "op: 0xad400660" };
    $Z0: bv128 := var1_4201112_bv128:bv128 { .comment = "op: 0xad400660" };
    $Z1: bv128 := var2_4201112_bv128:bv128 { .comment = "op: 0xad400660" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var1_4201116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4201116_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403e1" };
    var var2_4201116_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403e1" };
    $R1: bv64 := bvor(var1_4201116_bv64:bv64, bvshl(var2_4201116_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201120_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x60:bv64) $Z0:bv128 128 { .comment = "op: 0xad0307e0" };
    store le $stack bvadd(bvadd($R31:bv64, 0x60:bv64), 0x10:bv64) $Z1:bv128 128 { .comment = "op: 0xad0307e0" };
    $R30: bv64 := 0x401aac:bv64 { .comment = "op: 0x94000106" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000106" };
    $_PC: bv64 := 0x401ec0:bv64 { .comment = "op: 0x94000106" };
    call @dofmt_4202176 ();
    goto(%vfprint_19);
  ];
  block %vfprint_basil_return_1 [
    return ();
  ]
];


proc @fprint_4200960 () -> ()
  { .name = "fprint"; .address = 0x401a00; .returnBlock = "fprint_basil_return_1" }
  require eq($_PC:bv64, 0x401a00:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %fprint_entry {.address = 0x401a00; .originalLabel = "fQteMOadSm+stHHR3jx4Qw=="} [
    assert eq($_PC:bv64, 0x401a00:bv64);
    $_PC: bv64 := 0x401a00:bv64;
    assert eq($_PC:bv64, 0x401a00:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401a00:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200960_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9b07bfd" };
    var var1_4200960_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9b07bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffff00:bv64) $R29:bv64 64 { .comment = "op: 0xa9b07bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffff00:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9b07bfd" };
    $R31: bv64 := bvadd(var1_4200960_bv64:bv64, 0xffffffffffffff00:bv64) { .comment = "op: 0xa9b07bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R9: bv64 := 0xffffffd0:bv64 { .comment = "op: 0x128005e9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R8: bv64 := 0xffffff80:bv64 { .comment = "op: 0x12800fe8" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200972_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910343ea" };
    $R10: bv64 := bvadd($R31:bv64, 0xd0:bv64) { .comment = "op: 0x910343ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200980_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910403eb" };
    $R11: bv64 := bvadd($R31:bv64, 0x100:bv64) { .comment = "op: 0x910403eb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R11:bv64 64 { .comment = "op: 0xa9032feb" };
    store le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) $R11:bv64 64 { .comment = "op: 0xa9032feb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x40:bv64) $R10:bv64 64 { .comment = "op: 0xf90023ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x48:bv64) extract(32, 0, $R9:bv64) 32 { .comment = "op: 0x290923e9" };
    store le $stack bvadd(bvadd($R31:bv64, 0x48:bv64), 0x4:bv64) extract(32, 0, $R8:bv64) 32 { .comment = "op: 0x290923e9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x50:bv64) $Z0:bv128 128 { .comment = "op: 0x3d8017e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201000_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad41c3e0" };
    var var1_4201000_bv128: bv128 := load le $stack bvadd($R31:bv64, 0x30:bv64) 128 { .comment = "op: 0xad41c3e0" };
    var var2_4201000_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad41c3e0" };
    var var2_4201000_bv128: bv128 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x10:bv64) 128 { .comment = "op: 0xad41c3e0" };
    $Z0: bv128 := var1_4201000_bv128:bv128 { .comment = "op: 0xad41c3e0" };
    $Z16: bv128 := var2_4201000_bv128:bv128 { .comment = "op: 0xad41c3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x60:bv64) $Z1:bv128 128 { .comment = "op: 0x3d801be1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x70:bv64) $Z2:bv128 128 { .comment = "op: 0x3d801fe2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $Z0:bv128 128 { .comment = "op: 0xad00c3e0" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x10:bv64) $Z16:bv128 128 { .comment = "op: 0xad00c3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x80:bv64) $Z3:bv128 128 { .comment = "op: 0x3d8023e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x90:bv64) $Z4:bv128 128 { .comment = "op: 0x3d8027e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xa0:bv64) $Z5:bv128 128 { .comment = "op: 0x3d802be5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xb0:bv64) $Z6:bv128 128 { .comment = "op: 0x3d802fe6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xc0:bv64) $Z7:bv128 128 { .comment = "op: 0x3d8033e7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xd0:bv64) $R2:bv64 64 { .comment = "op: 0xa90d0fe2" };
    store le $stack bvadd(bvadd($R31:bv64, 0xd0:bv64), 0x8:bv64) $R3:bv64 64 { .comment = "op: 0xa90d0fe2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201040_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910043e2" };
    $R2: bv64 := bvadd($R31:bv64, 0x10:bv64) { .comment = "op: 0x910043e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xe0:bv64) $R4:bv64 64 { .comment = "op: 0xa90e17e4" };
    store le $stack bvadd(bvadd($R31:bv64, 0xe0:bv64), 0x8:bv64) $R5:bv64 64 { .comment = "op: 0xa90e17e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xf0:bv64) $R6:bv64 64 { .comment = "op: 0xa90f1fe6" };
    store le $stack bvadd(bvadd($R31:bv64, 0xf0:bv64), 0x8:bv64) $R7:bv64 64 { .comment = "op: 0xa90f1fe6" };
    $R30: bv64 := 0x401a60:bv64 { .comment = "op: 0x94000005" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000005" };
    $_PC: bv64 := 0x401a70:bv64 { .comment = "op: 0x94000005" };
    call @vfprint_4201072 ();
    goto(%fprint_5);
  ];
  block %fprint_5 {.address = 0x401a60; .originalLabel = "cdsXxKd9T/6DKbLkSNCnfw=="} [
    assert eq($_PC:bv64, 0x401a60:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401a60:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d07bfd" };
    var var1_4201056_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8d07bfd" };
    var var2_4201056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d07bfd" };
    var var2_4201056_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8d07bfd" };
    var var3_4201056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d07bfd" };
    var var3_4201056_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8d07bfd" };
    $R29: bv64 := var2_4201056_bv64:bv64 { .comment = "op: 0xa8d07bfd" };
    $R30: bv64 := var3_4201056_bv64:bv64 { .comment = "op: 0xa8d07bfd" };
    $R31: bv64 := bvadd(var1_4201056_bv64:bv64, 0x100:bv64) { .comment = "op: 0xa8d07bfd" };
    var var1_4201060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%fprint_basil_return_1);
  ];
  block %fprint_basil_return_1 [
    return ();
  ]
];


proc @__fixargv0_4198400 () -> ()
  { .name = "__fixargv0"; .address = 0x401000; .returnBlock = "__fixargv0_basil_return_1" }
  require eq($_PC:bv64, 0x401000:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %__fixargv0_entry {.address = 0x401000; .originalLabel = "78skE39ZS92hlwuQoG/N1g=="} [
    assert eq($_PC:bv64, 0x401000:bv64);
    $_PC: bv64 := 0x401000:bv64;
    assert eq($_PC:bv64, 0x401000:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401000:bv64)"; .label = "pc-tracking" };
    var var1_4198400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%__fixargv0_basil_return_1);
  ];
  block %__fixargv0_basil_return_1 [
    return ();
  ]
];


proc @vseprint_4201184 () -> ()
  { .name = "vseprint"; .address = 0x401ae0; .returnBlock = "vseprint_basil_return_1" }
  require eq($_PC:bv64, 0x401ae0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %vseprint_entry {.address = 0x401ae0; .originalLabel = "xuA0Edh9S8yFZV1Qu/Jgqw=="} [
    assert eq($_PC:bv64, 0x401ae0:bv64);
    $_PC: bv64 := 0x401ae0:bv64;
    assert eq($_PC:bv64, 0x401ae0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ae0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb00003f" };
    var var2_4201184_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb00003f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R1:bv64), sign_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb00003f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R1:bv64), zero_extend(64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb00003f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb00003f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R1:bv64, bvnot(bvshl($R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb00003f" };
    goto(%vseprint_7, %vseprint_15);
  ];
  block %vseprint_5 {.address = 0x401b54; .originalLabel = "XE3UoVQ8QJ+lGfCxFsl9HA=="} [
    goto(%vseprint_basil_return_1);
  ];
  block %vseprint_7 [
    guard boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401b54:bv64;
    assert eq($_PC:bv64, 0x401b54:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b54:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0xd2800000" };
    var var1_4201304_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%vseprint_5);
  ];
  block %vseprint_9 {.address = 0x401b3c; .originalLabel = "cZc5CNyvT0ii430V9xwH5w=="} [
    assert eq($_PC:bv64, 0x401b3c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b3c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201276_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401fe0" };
    var var1_4201276_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x38:bv64) 64 { .comment = "op: 0xf9401fe0" };
    $R0: bv64 := var1_4201276_bv64:bv64 { .comment = "op: 0xf9401fe0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201280_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x3900001f" };
    store le $mem bvadd($R0:bv64, 0x0:bv64) 0x0:bv8 8 { .comment = "op: 0x3900001f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400bf3" };
    var var1_4201284_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400bf3" };
    $R19: bv64 := var1_4201284_bv64:bv64 { .comment = "op: 0xf9400bf3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201288_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401fe0" };
    var var1_4201288_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x38:bv64) 64 { .comment = "op: 0xf9401fe0" };
    $R0: bv64 := var1_4201288_bv64:bv64 { .comment = "op: 0xf9401fe0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201292_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8cb7bfd" };
    var var1_4201292_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8cb7bfd" };
    var var2_4201292_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8cb7bfd" };
    var var2_4201292_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8cb7bfd" };
    var var3_4201292_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8cb7bfd" };
    var var3_4201292_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8cb7bfd" };
    $R29: bv64 := var2_4201292_bv64:bv64 { .comment = "op: 0xa8cb7bfd" };
    $R30: bv64 := var3_4201292_bv64:bv64 { .comment = "op: 0xa8cb7bfd" };
    $R31: bv64 := bvadd(var1_4201292_bv64:bv64, 0xb0:bv64) { .comment = "op: 0xa8cb7bfd" };
    var var1_4201296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%vseprint_basil_return_1);
  ];
  block %vseprint_11 {.address = 0x401b30; .originalLabel = "e5HDk3GbQ8+8gKIfdkCxWQ=="} [
    assert eq($_PC:bv64, 0x401b30:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b30:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4201264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4201264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4201264_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4201264_bv64:bv64, bvshl(var2_4201264_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $R30: bv64 := 0x401b3c:bv64 { .comment = "op: 0x940000e2" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940000e2" };
    $_PC: bv64 := 0x401ec0:bv64 { .comment = "op: 0x940000e2" };
    call @dofmt_4202176 ();
    goto(%vseprint_9);
  ];
  block %vseprint_13 {.address = 0x401ae8; .originalLabel = "debJJUITQMafkRDoSFNkJA=="} [
    goto(%vseprint_11);
  ];
  block %vseprint_15 [
    guard boolnot(boolnot(booland(eq($CF:bv1, 0x1:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401ae8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ae8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201192_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9b57bfd" };
    var var1_4201192_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9b57bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffff50:bv64) $R29:bv64 64 { .comment = "op: 0xa9b57bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffff50:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9b57bfd" };
    $R31: bv64 := bvadd(var1_4201192_bv64:bv64, 0xffffffffffffff50:bv64) { .comment = "op: 0xa9b57bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e5" };
    var var1_4201196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e5" };
    var var2_4201196_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e5" };
    var var2_4201196_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e5" };
    $R5: bv64 := bvor(var1_4201196_bv64:bv64, bvshl(var2_4201196_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000424" };
    var var2_4201200_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000424" };
    var var2_4201200_bv64: bv64 := $R1:bv64 { .comment = "op: 0xd1000424" };
    $R4: bv64 := bvadd(bvadd(var2_4201200_bv64:bv64, 0xfffffffffffffffe:bv64), 0x1:bv64) { .comment = "op: 0xd1000424" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201204_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201208_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400460" };
    var var1_4201208_bv128: bv128 := load le $mem bvadd($R3:bv64, 0x0:bv64) 128 { .comment = "op: 0xad400460" };
    var var2_4201208_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400460" };
    var var2_4201208_bv128: bv128 := load le $mem bvadd(bvadd($R3:bv64, 0x0:bv64), 0x10:bv64) 128 { .comment = "op: 0xad400460" };
    $Z0: bv128 := var1_4201208_bv128:bv128 { .comment = "op: 0xad400460" };
    $Z1: bv128 := var2_4201208_bv128:bv128 { .comment = "op: 0xad400460" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x0:bv64 { .comment = "op: 0xd2800003" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xf9000bf3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var1_4201220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var2_4201220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f3" };
    var var2_4201220_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203f3" };
    $R19: bv64 := bvor(var1_4201220_bv64:bv64, bvshl(var2_4201220_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x0:bv64 { .comment = "op: 0xd2800002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201228_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100a3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x28:bv64) { .comment = "op: 0x9100a3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x0:bv64 { .comment = "op: 0xd2800001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x28:bv64) 0x0:bv8 8 { .comment = "op: 0x3900a3ff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R5:bv64 64 { .comment = "op: 0xa90317e5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) $R5:bv64 64 { .comment = "op: 0xa90317e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x40:bv64) $R4:bv64 64 { .comment = "op: 0xa9047fe4" };
    store le $stack bvadd(bvadd($R31:bv64, 0x40:bv64), 0x8:bv64) 0x0:bv64 64 { .comment = "op: 0xa9047fe4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x50:bv64) 0x0:bv64 64 { .comment = "op: 0xf9002bff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x58:bv64) 0x0:bv32 32 { .comment = "op: 0xb9005bff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x60:bv64) $Z0:bv128 128 { .comment = "op: 0xad0307e0" };
    store le $stack bvadd(bvadd($R31:bv64, 0x60:bv64), 0x10:bv64) $Z1:bv128 128 { .comment = "op: 0xad0307e0" };
    $R30: bv64 := 0x401b30:bv64 { .comment = "op: 0x94000819" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000819" };
    $_PC: bv64 := 0x403b90:bv64 { .comment = "op: 0x94000819" };
    call @fmtlocaleinit_4209552 ();
    goto(%vseprint_13);
  ];
  block %vseprint_basil_return_1 [
    return ();
  ]
];


proc @sysfatal_4200560 () -> ()
  { .name = "sysfatal"; .address = 0x401870; .returnBlock = "sysfatal_basil_return_1" }
  require eq($_PC:bv64, 0x401870:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %sysfatal_entry {.address = 0x401870; .originalLabel = "HN8ZNDP1RUKhvFhL/Qx3ng=="} [
    var R30_begin_sysfatal_4200560: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x401870:bv64);
    $_PC: bv64 := 0x401870:bv64;
    assert eq($_PC:bv64, 0x401870:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401870:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200560_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd108c3ff" };
    var var1_4200560_bv64: bv64 := $R31:bv64 { .comment = "op: 0xd108c3ff" };
    $R31: bv64 := bvadd(bvadd(var1_4200560_bv64:bv64, 0xfffffffffffffdcf:bv64), 0x1:bv64) { .comment = "op: 0xd108c3ff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R8: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000e8" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9107c3eb" };
    $R11: bv64 := bvadd($R31:bv64, 0x1f0:bv64) { .comment = "op: 0x9107c3eb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200572_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9108c3ec" };
    $R12: bv64 := bvadd($R31:bv64, 0x230:bv64) { .comment = "op: 0x9108c3ec" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R10: bv64 := 0xffffffc8:bv64 { .comment = "op: 0x128006ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R9: bv64 := 0xffffff80:bv64 { .comment = "op: 0x12800fe9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x0:bv64) $R29:bv64 64 { .comment = "op: 0xa9007bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0x0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9007bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200588_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9433d08" };
    var var1_4200592_bv64: bv64 := $R8:bv64 { .comment = "op: 0xf9433d08" };
    var var2_4200592_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9433d08" };
    var var2_4200592_bv64: bv64 := load le $mem bvadd(var1_4200592_bv64:bv64, 0x678:bv64) 64 { .comment = "op: 0xf9433d08" };
    $R8: bv64 := var2_4200592_bv64:bv64 { .comment = "op: 0xf9433d08" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1f8:bv64) $R1:bv64 64 { .comment = "op: 0xa91f8be1" };
    store le $stack bvadd(bvadd($R31:bv64, 0x1f8:bv64), 0x8:bv64) $R2:bv64 64 { .comment = "op: 0xa91f8be1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200600_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910823e1" };
    $R1: bv64 := bvadd($R31:bv64, 0x208:bv64) { .comment = "op: 0x910823e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200608_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100c3f3" };
    $R19: bv64 := bvadd($R31:bv64, 0x30:bv64) { .comment = "op: 0x9100c3f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910143f4" };
    $R20: bv64 := bvadd($R31:bv64, 0x50:bv64) { .comment = "op: 0x910143f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xf90013f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var1_4200620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4200620_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4200620_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f5" };
    $R21: bv64 := bvor(var1_4200620_bv64:bv64, bvshl(var2_4200620_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x50:bv64) $R12:bv64 64 { .comment = "op: 0xa90533ec" };
    store le $stack bvadd(bvadd($R31:bv64, 0x50:bv64), 0x8:bv64) $R12:bv64 64 { .comment = "op: 0xa90533ec" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x60:bv64) $R11:bv64 64 { .comment = "op: 0xf90033eb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x68:bv64) extract(32, 0, $R10:bv64) 32 { .comment = "op: 0x290d27ea" };
    store le $stack bvadd(bvadd($R31:bv64, 0x68:bv64), 0x4:bv64) extract(32, 0, $R9:bv64) 32 { .comment = "op: 0x290d27ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x170:bv64) $Z0:bv128 128 { .comment = "op: 0x3d805fe0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x180:bv64) $Z1:bv128 128 { .comment = "op: 0x3d8063e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x190:bv64) $Z2:bv128 128 { .comment = "op: 0x3d8067e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1a0:bv64) $Z3:bv128 128 { .comment = "op: 0x3d806be3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1b0:bv64) $Z4:bv128 128 { .comment = "op: 0x3d806fe4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1c0:bv64) $Z5:bv128 128 { .comment = "op: 0x3d8073e5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1d0:bv64) $Z6:bv128 128 { .comment = "op: 0x3d8077e6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x1e0:bv64) $Z7:bv128 128 { .comment = "op: 0x3d807be7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200668_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9001023" };
    store le $stack bvadd($R1:bv64, 0x0:bv64) $R3:bv64 64 { .comment = "op: 0xa9001023" };
    store le $stack bvadd(bvadd($R1:bv64, 0x0:bv64), 0x8:bv64) $R4:bv64 64 { .comment = "op: 0xa9001023" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200672_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9011825" };
    store le $stack bvadd($R1:bv64, 0x10:bv64) $R5:bv64 64 { .comment = "op: 0xa9011825" };
    store le $stack bvadd(bvadd($R1:bv64, 0x10:bv64), 0x8:bv64) $R6:bv64 64 { .comment = "op: 0xa9011825" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x228:bv64) $R7:bv64 64 { .comment = "op: 0xf90117e7" };
    goto(%sysfatal_19, %sysfatal_23);
  ];
  block %sysfatal_3 {.address = 0x40195c; .originalLabel = "aE8K3w09T2W6JiepPMCHPw=="} [
    assert eq($_PC:bv64, 0x40195c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40195c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200796_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9407bfd" };
    var var1_4200796_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x0:bv64) 64 { .comment = "op: 0xa9407bfd" };
    var var2_4200796_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9407bfd" };
    var var2_4200796_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x0:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9407bfd" };
    $R29: bv64 := var1_4200796_bv64:bv64 { .comment = "op: 0xa9407bfd" };
    $R30: bv64 := var2_4200796_bv64:bv64 { .comment = "op: 0xa9407bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4200800_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4200800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4200800_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4200800_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4200800_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200804_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94013f5" };
    var var1_4200804_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xf94013f5" };
    $R21: bv64 := var1_4200804_bv64:bv64 { .comment = "op: 0xf94013f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200808_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9108c3ff" };
    var var1_4200808_bv64: bv64 := $R31:bv64 { .comment = "op: 0x9108c3ff" };
    $R31: bv64 := bvadd(var1_4200808_bv64:bv64, 0x230:bv64) { .comment = "op: 0x9108c3ff" };
    var var1_4200812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%sysfatal_basil_return_1);
  ];
  block %sysfatal_5 {.address = 0x401950; .originalLabel = "t3WclX5hThuT91ZlZbIe6Q=="} [
    assert eq($_PC:bv64, 0x401950:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401950:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0x90000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200788_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91332000" };
    var var2_4200788_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91332000" };
    var var2_4200788_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91332000" };
    $R0: bv64 := bvadd(var2_4200788_bv64:bv64, 0xcc8:bv64) { .comment = "op: 0x91332000" };
    $R30: bv64 := 0x40195c:bv64 { .comment = "op: 0x97fffdf2" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffdf2" };
    $_PC: bv64 := 0x401120:bv64 { .comment = "op: 0x97fffdf2" };
    assert eq($R30:bv64, R30_begin_sysfatal_4200560:bv64) { .comment = "R30 = R30_in" };
    call @exits_4198688 ();
    goto(%sysfatal_basil_return_1);
  ];
  block %sysfatal_7 [
    $R30: bv64 := 0x401950:bv64 { .comment = "op: 0x9400002d" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400002d" };
    $_PC: bv64 := 0x401a00:bv64 { .comment = "op: 0x9400002d" };
    call @fprint_4200960 ();
    goto(%sysfatal_5);
  ];
  block %sysfatal_9 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := var1_4200776_bv64:bv64;
    goto(%sysfatal_7);
  ];
  block %sysfatal_11 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := var2_4200776_bv64:bv64;
    goto(%sysfatal_7);
  ];
  block %sysfatal_13 {.address = 0x401924; .originalLabel = "miSWFhjpQbeyl9ggMg3TQQ=="} [
    assert eq($_PC:bv64, 0x401924:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401924:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x405000:bv64 { .comment = "op: 0x90000022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9132e042" };
    var var2_4200748_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9132e042" };
    var var2_4200748_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9132e042" };
    $R2: bv64 := bvadd(var2_4200748_bv64:bv64, 0xcb8:bv64) { .comment = "op: 0x9132e042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200752_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9101c3e3" };
    $R3: bv64 := bvadd($R31:bv64, 0x70:bv64) { .comment = "op: 0x9101c3e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200756_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9420404" };
    var var1_4200756_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9420404" };
    var var2_4200756_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9420404" };
    var var2_4200756_bv64: bv64 := load le $mem bvadd(var1_4200756_bv64:bv64, 0x408:bv64) 64 { .comment = "op: 0xf9420404" };
    $R4: bv64 := var2_4200756_bv64:bv64 { .comment = "op: 0xf9420404" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x405000:bv64 { .comment = "op: 0x90000021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91330021" };
    var var2_4200764_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91330021" };
    var var2_4200764_bv64: bv64 := $R1:bv64 { .comment = "op: 0x91330021" };
    $R1: bv64 := bvadd(var2_4200764_bv64:bv64, 0xcc0:bv64) { .comment = "op: 0x91330021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x2:bv64 { .comment = "op: 0x52800040" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100009f" };
    var var2_4200772_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100009f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R4:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100009f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R4:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100009f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100009f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R4:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100009f" };
    var var1_4200776_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a840042" };
    var var1_4200776_bv64: bv64 := $R2:bv64 { .comment = "op: 0x9a840042" };
    var var2_4200776_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a840042" };
    var var2_4200776_bv64: bv64 := $R4:bv64 { .comment = "op: 0x9a840042" };
    goto(%sysfatal_9, %sysfatal_11);
  ];
  block %sysfatal_15 {.address = 0x401920; .originalLabel = "dCVBbmUOTTmtRKBy4/k3rA=="} [
    assert eq($_PC:bv64, 0x401920:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401920:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x401924:bv64 { .comment = "op: 0x97fffdb8" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffdb8" };
    $_PC: bv64 := 0x401000:bv64 { .comment = "op: 0x97fffdb8" };
    call @__fixargv0_4198400 ();
    goto(%sysfatal_13);
  ];
  block %sysfatal_17 {.address = 0x401904; .originalLabel = "3I/R27QwRN2VkV+l2/VVWQ=="} [
    assert eq($_PC:bv64, 0x401904:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401904:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e2" };
    var var1_4200708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e2" };
    var var2_4200708_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e2" };
    var var2_4200708_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e2" };
    $R2: bv64 := bvor(var1_4200708_bv64:bv64, bvshl(var2_4200708_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200712_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400680" };
    var var1_4200712_bv128: bv128 := load le $mem bvadd($R20:bv64, 0x0:bv64) 128 { .comment = "op: 0xad400680" };
    var var2_4200712_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400680" };
    var var2_4200712_bv128: bv128 := load le $mem bvadd(bvadd($R20:bv64, 0x0:bv64), 0x10:bv64) 128 { .comment = "op: 0xad400680" };
    $Z0: bv128 := var1_4200712_bv128:bv128 { .comment = "op: 0xad400680" };
    $Z1: bv128 := var2_4200712_bv128:bv128 { .comment = "op: 0xad400680" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e3" };
    var var1_4200716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e3" };
    var var2_4200716_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e3" };
    var var2_4200716_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e3" };
    $R3: bv64 := bvor(var1_4200716_bv64:bv64, bvshl(var2_4200716_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200720_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9105c3e1" };
    $R1: bv64 := bvadd($R31:bv64, 0x170:bv64) { .comment = "op: 0x9105c3e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200724_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9101c3e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x70:bv64) { .comment = "op: 0x9101c3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $mem bvadd($R19:bv64, 0x0:bv64) $Z0:bv128 128 { .comment = "op: 0xad000660" };
    store le $mem bvadd(bvadd($R19:bv64, 0x0:bv64), 0x10:bv64) $Z1:bv128 128 { .comment = "op: 0xad000660" };
    $R30: bv64 := 0x401920:bv64 { .comment = "op: 0x94000071" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000071" };
    $_PC: bv64 := 0x401ae0:bv64 { .comment = "op: 0x94000071" };
    call @vseprint_4201184 ();
    goto(%sysfatal_15);
  ];
  block %sysfatal_19 [
    guard eq($R8:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401904:bv64;
    goto(%sysfatal_17);
  ];
  block %sysfatal_21 {.address = 0x4018ec; .originalLabel = "HaYqFqogRlGahRwWYCb5zQ=="} [
    goto(%sysfatal_17);
  ];
  block %sysfatal_23 [
    guard boolnot(eq($R8:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4018ec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4018ec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200684_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910143f4" };
    $R20: bv64 := bvadd($R31:bv64, 0x50:bv64) { .comment = "op: 0x910143f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200688_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100c3f3" };
    $R19: bv64 := bvadd($R31:bv64, 0x30:bv64) { .comment = "op: 0x9100c3f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var1_4200692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4200692_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e1" };
    var var2_4200692_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e1" };
    $R1: bv64 := bvor(var1_4200692_bv64:bv64, bvshl(var2_4200692_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200696_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400680" };
    var var1_4200696_bv128: bv128 := load le $stack bvadd($R20:bv64, 0x0:bv64) 128 { .comment = "op: 0xad400680" };
    var var2_4200696_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad400680" };
    var var2_4200696_bv128: bv128 := load le $stack bvadd(bvadd($R20:bv64, 0x0:bv64), 0x10:bv64) 128 { .comment = "op: 0xad400680" };
    $Z0: bv128 := var1_4200696_bv128:bv128 { .comment = "op: 0xad400680" };
    $Z1: bv128 := var2_4200696_bv128:bv128 { .comment = "op: 0xad400680" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R19:bv64, 0x0:bv64) $Z0:bv128 128 { .comment = "op: 0xad000660" };
    store le $stack bvadd(bvadd($R19:bv64, 0x0:bv64), 0x10:bv64) $Z1:bv128 128 { .comment = "op: 0xad000660" };
    var var1_4200704_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0100" };
    var var1_4200704_bv64: bv64 := $R8:bv64 { .comment = "op: 0xd63f0100" };
    $R30: bv64 := 0x401904:bv64 { .comment = "op: 0xd63f0100" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0100" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0100" };
    $_PC: bv64 := var1_4200704_bv64:bv64 { .comment = "op: 0xd63f0100" };
    indirect call var1_4200704_bv64:bv64 ;
    goto(%sysfatal_21);
  ];
  block %sysfatal_basil_return_1 [
    return ();
  ]
];


proc @memccpy () -> ()
  { .name = "memccpy" };


proc @strecpy_4201936 () -> ()
  { .name = "strecpy"; .address = 0x401dd0; .returnBlock = "strecpy_basil_return_1" }
  require eq($_PC:bv64, 0x401dd0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %strecpy_entry {.address = 0x401dd0; .originalLabel = "gS9qAucpRMKJD8TibWbm5A=="} [
    assert eq($_PC:bv64, 0x401dd0:bv64);
    $_PC: bv64 := 0x401dd0:bv64;
    assert eq($_PC:bv64, 0x401dd0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401dd0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01001f" };
    var var2_4201936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb01001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0:bv64), sign_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0:bv64), zero_extend(64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb01001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb01001f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R0:bv64, bvnot(bvshl($R1:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb01001f" };
    goto(%strecpy_17, %strecpy_21);
  ];
  block %strecpy_5 {.address = 0x401e14; .originalLabel = "OQtOPjH4Q2yMtmDv/3Nu1A=="} [
    goto(%strecpy_basil_return_1);
  ];
  block %strecpy_7 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401e14:bv64;
    assert eq($_PC:bv64, 0x401e14:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e14:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202004_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x381ff27f" };
    store le $mem bvadd($R19:bv64, 0xffffffffffffffff:bv64) 0x0:bv8 8 { .comment = "op: 0x381ff27f" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202008_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000663" };
    var var2_4202008_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000663" };
    var var2_4202008_bv64: bv64 := $R19:bv64 { .comment = "op: 0xd1000663" };
    $R3: bv64 := bvadd(bvadd(var2_4202008_bv64:bv64, 0xfffffffffffffffe:bv64), 0x1:bv64) { .comment = "op: 0xd1000663" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var1_4202012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var2_4202012_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var2_4202012_bv64: bv64 := $R3:bv64 { .comment = "op: 0xaa0303e0" };
    $R0: bv64 := bvor(var1_4202012_bv64:bv64, bvshl(var2_4202012_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202016_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400bf3" };
    var var1_4202016_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400bf3" };
    $R19: bv64 := var1_4202016_bv64:bv64 { .comment = "op: 0xf9400bf3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4202020_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4202020_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202020_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4202020_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202020_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4202020_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4202020_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4202020_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4202020_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4202024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%strecpy_5);
  ];
  block %strecpy_9 {.address = 0x401e04; .originalLabel = "SS2QEtcQTzCxPboZ08XF9A=="} [
    goto(%strecpy_basil_return_1);
  ];
  block %strecpy_11 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401e04:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401e04:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201988_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400bf3" };
    var var1_4201988_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xf9400bf3" };
    $R19: bv64 := var1_4201988_bv64:bv64 { .comment = "op: 0xf9400bf3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var1_4201992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var2_4201992_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0303e0" };
    var var2_4201992_bv64: bv64 := $R3:bv64 { .comment = "op: 0xaa0303e0" };
    $R0: bv64 := bvor(var1_4201992_bv64:bv64, bvshl(var2_4201992_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201996_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var1_4201996_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4201996_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var2_4201996_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c27bfd" };
    var var3_4201996_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c27bfd" };
    var var3_4201996_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c27bfd" };
    $R29: bv64 := var2_4201996_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R30: bv64 := var3_4201996_bv64:bv64 { .comment = "op: 0xa8c27bfd" };
    $R31: bv64 := bvadd(var1_4201996_bv64:bv64, 0x20:bv64) { .comment = "op: 0xa8c27bfd" };
    var var1_4202000_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%strecpy_9);
  ];
  block %strecpy_13 {.address = 0x401dfc; .originalLabel = "omAoMCU3TgKVB0hoOKrCng=="} [
    assert eq($_PC:bv64, 0x401dfc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401dfc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201980_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000403" };
    var var2_4201980_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd1000403" };
    var var2_4201980_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd1000403" };
    $R3: bv64 := bvadd(bvadd(var2_4201980_bv64:bv64, 0xfffffffffffffffe:bv64), 0x1:bv64) { .comment = "op: 0xd1000403" };
    goto(%strecpy_7, %strecpy_11);
  ];
  block %strecpy_15 {.address = 0x401ddc; .originalLabel = "iI83mUlnTDiLnmBxOUqmIQ=="} [
    goto(%strecpy_13);
  ];
  block %strecpy_17 [
    guard boolnot(eq($CF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ddc:bv64;
    assert eq($_PC:bv64, 0x401ddc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ddc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201948_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9be7bfd" };
    var var1_4201948_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffe0:bv64) $R29:bv64 64 { .comment = "op: 0xa9be7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffe0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9be7bfd" };
    $R31: bv64 := bvadd(var1_4201948_bv64:bv64, 0xffffffffffffffe0:bv64) { .comment = "op: 0xa9be7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000023" };
    var var1_4201952_bv64: bv64 := $R1:bv64 { .comment = "op: 0xcb000023" };
    var var2_4201952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb000023" };
    var var2_4201952_bv64: bv64 := $R0:bv64 { .comment = "op: 0xcb000023" };
    $R3: bv64 := bvadd(bvadd(var1_4201952_bv64:bv64, bvnot(bvshl(var2_4201952_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb000023" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201956_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xf9000bf3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var1_4201964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4201964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f3" };
    var var2_4201964_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f3" };
    $R19: bv64 := bvor(var1_4201964_bv64:bv64, bvshl(var2_4201964_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e1" };
    var var1_4201968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e1" };
    var var2_4201968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203e1" };
    var var2_4201968_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203e1" };
    $R1: bv64 := bvor(var1_4201968_bv64:bv64, bvshl(var2_4201968_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x0:bv64 { .comment = "op: 0x52800002" };
    $R30: bv64 := 0x401dfc:bv64 { .comment = "op: 0x97fffb7a" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffb7a" };
    $_PC: bv64 := 0x400be0:bv64 { .comment = "op: 0x97fffb7a" };
    goto(%FUN_400be0_entry_83);
  ];
  block %strecpy_19 {.address = 0x401dd8; .originalLabel = "bh9QQ9J6RVCaAZdr9Pnc+Q=="} [
    goto(%strecpy_basil_return_1);
  ];
  block %strecpy_21 [
    guard boolnot(boolnot(eq($CF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401dd8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401dd8:bv64)"; .label = "pc-tracking" };
    var var1_4201944_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%strecpy_19);
  ];
  block %_inlineret_3 [
    goto(%strecpy_15);
  ];
  block %FUN_400be0_entry_83 {.address = 0x400be0} [
    var R30_begin_FUN_400be0_4197344_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400be0:bv64);
    $_PC: bv64 := 0x400be0:bv64;
    assert eq($_PC:bv64, 0x400be0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400be0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197348_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9401211" };
    var var1_4197348_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9401211" };
    var var2_4197348_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9401211" };
    var var2_4197348_bv64_3: bv64 := load le $mem bvadd(var1_4197348_bv64_2:bv64, 0x20:bv64) 64 { .comment = "op: 0xf9401211" };
    $R17: bv64 := var2_4197348_bv64_3:bv64 { .comment = "op: 0xf9401211" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197352_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x91008210" };
    var var2_4197352_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x91008210" };
    var var2_4197352_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x91008210" };
    $R16: bv64 := bvadd(var2_4197352_bv64_5:bv64, 0x20:bv64) { .comment = "op: 0x91008210" };
    var var1_4197356_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400be0_4197344_1:bv64) { .comment = "R30 = R30_in" };
    call @memccpy ();
    goto(%FUN_400be0_basil_return_1_84);
  ];
  block %FUN_400be0_basil_return_1_84 [
    goto(%_inlineret_3);
  ];
  block %strecpy_basil_return_1 [
    return ();
  ]
];


proc @__errno_location () -> ()
  { .name = "__errno_location" };


proc @strcpy () -> ()
  { .name = "strcpy" };


proc @strerror () -> ()
  { .name = "strerror" };


proc @rerrstr_4201312 () -> ()
  { .name = "rerrstr"; .address = 0x401b60; .returnBlock = "rerrstr_basil_return_1" }
  require eq($_PC:bv64, 0x401b60:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %rerrstr_entry {.address = 0x401b60; .originalLabel = "ldWhLOMYSKyYFGShQwXqIg=="} [
    var R30_begin_rerrstr_4201312: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x401b60:bv64);
    $_PC: bv64 := 0x401b60:bv64;
    assert eq($_PC:bv64, 0x401b60:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b60:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201312_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4201312_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4201312_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201316_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911a0294" };
    var var2_4201328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911a0294" };
    var var2_4201328_bv64: bv64 := $R20:bv64 { .comment = "op: 0x911a0294" };
    $R20: bv64 := bvadd(var2_4201328_bv64:bv64, 0x680:bv64) { .comment = "op: 0x911a0294" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var1_4201336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4201336_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4201336_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f5" };
    $R21: bv64 := bvor(var1_4201336_bv64:bv64, bvshl(var2_4201336_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f6" };
    var var1_4201340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f6" };
    var var2_4201340_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f6" };
    var var2_4201340_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x2a0103f6" };
    $R22: bv64 := zero_extend(32, bvor(var1_4201340_bv32:bv32, bvshl(var2_4201340_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0103f6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201344_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9404282" };
    var var1_4201344_bv64: bv64 := $R20:bv64 { .comment = "op: 0xf9404282" };
    var var2_4201344_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9404282" };
    var var2_4201344_bv64: bv64 := load le $mem bvadd(var1_4201344_bv64:bv64, 0x80:bv64) 64 { .comment = "op: 0xf9404282" };
    $R2: bv64 := var2_4201344_bv64:bv64 { .comment = "op: 0xf9404282" };
    goto(%rerrstr_27, %rerrstr_45);
  ];
  block %rerrstr_3 {.address = 0x401c28; .originalLabel = "TSmOt4DBS4+H6ZfijcJvug=="} [
    assert eq($_PC:bv64, 0x401c28:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c28:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var1_4201512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201512_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201512_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e2" };
    $R2: bv64 := bvor(var1_4201512_bv64:bv64, bvshl(var2_4201512_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201516_bv64: bv64 := $R21:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201516_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201516_bv64: bv64 := $R22:bv64 { .comment = "op: 0x8b3642a1" };
    $R1: bv64 := bvadd(var2_4201516_bv64:bv64, zero_extend(32, extract(32, 0, var3_4201516_bv64:bv64))) { .comment = "op: 0x8b3642a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201520_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4201520_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4201520_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4201520_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4201520_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4201520_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4201524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201524_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201524_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4201524_bv64:bv64, bvshl(var2_4201524_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201528_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4201528_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4201528_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4201528_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4201528_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4201528_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4201532_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201532_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201532_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201532_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4201532_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4201532_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4201532_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000064" };
    $_PC: bv64 := 0x401dd0:bv64 { .comment = "op: 0x14000064" };
    assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64) { .comment = "R30 = R30_in" };
    call @strecpy_4201936 ();
    goto(%rerrstr_basil_return_1);
  ];
  block %rerrstr_5 {.address = 0x401c1c; .originalLabel = "HIYg9nK0QK+SbtSpi6FDfA=="} [
    assert eq($_PC:bv64, 0x401c1c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c1c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var1_4201500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4201500_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4201500_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e1" };
    $R1: bv64 := bvor(var1_4201500_bv64:bv64, bvshl(var2_4201500_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4201504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201504_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201504_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4201504_bv64:bv64, bvshl(var2_4201504_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $R30: bv64 := 0x401c28:bv64 { .comment = "op: 0x97fffc2b" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffc2b" };
    $_PC: bv64 := 0x400cd0:bv64 { .comment = "op: 0x97fffc2b" };
    goto(%FUN_400cd0_entry_61);
  ];
  block %rerrstr_7 {.address = 0x401c18; .originalLabel = "txT6uVMAQ3C/6VSAUeTjkw=="} [
    goto(%rerrstr_5);
  ];
  block %rerrstr_9 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401c18:bv64;
    assert eq($_PC:bv64, 0x401c18:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c18:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x401c1c:bv64 { .comment = "op: 0x97fffc0a" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffc0a" };
    $_PC: bv64 := 0x400c40:bv64 { .comment = "op: 0x97fffc0a" };
    goto(%FUN_400c40_entry_57);
  ];
  block %rerrstr_13 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401bb4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401bb4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var1_4201396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201396_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201396_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e2" };
    $R2: bv64 := bvor(var1_4201396_bv64:bv64, bvshl(var2_4201396_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201400_bv64: bv64 := $R21:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201400_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201400_bv64: bv64 := $R22:bv64 { .comment = "op: 0x8b3642a1" };
    $R1: bv64 := bvadd(var2_4201400_bv64:bv64, zero_extend(32, extract(32, 0, var3_4201400_bv64:bv64))) { .comment = "op: 0x8b3642a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201404_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4201404_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4201404_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4201404_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4201404_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4201404_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4201408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201408_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201408_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4201408_bv64:bv64, bvshl(var2_4201408_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201412_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4201412_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4201412_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4201412_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4201412_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4201412_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4201416_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201416_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201416_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201416_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4201416_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4201416_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4201416_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000081" };
    $_PC: bv64 := 0x401dd0:bv64 { .comment = "op: 0x14000081" };
    assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64) { .comment = "R30 = R30_in" };
    call @strecpy_4201936 ();
    goto(%rerrstr_basil_return_1);
  ];
  block %rerrstr_15 {.address = 0x401ba4; .originalLabel = "wbk3xO9oSaKIgAlTkteIZw=="} [
    assert eq($_PC:bv64, 0x401ba4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401ba4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x3745:bv64 { .comment = "op: 0x5286e8a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201384_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x72a32501" };
    var var1_4201384_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x72a32501" };
    $R1: bv64 := zero_extend(32, bvor(bvand(var1_4201384_bv32:bv32, 0xffff:bv32), 0x19280000:bv32)) { .comment = "op: 0x72a32501" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201388_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b01001f" };
    var var2_4201388_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x6b01001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), sign_extend(32, bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b01001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), zero_extend(32, bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .comment = "op: 0x6b01001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x6b01001f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), bvnot(bvshl(extract(32, 0, $R1:bv64), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .comment = "op: 0x6b01001f" };
    goto(%rerrstr_9, %rerrstr_13);
  ];
  block %rerrstr_17 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401ba4:bv64;
    goto(%rerrstr_15);
  ];
  block %rerrstr_19 {.address = 0x401be4; .originalLabel = "uUhnzoqyTDa9ckkbBNfdNA=="} [
    assert eq($_PC:bv64, 0x401be4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401be4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0x90000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201448_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91334000" };
    var var2_4201448_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91334000" };
    var var2_4201448_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91334000" };
    $R0: bv64 := bvadd(var2_4201448_bv64:bv64, 0xcd0:bv64) { .comment = "op: 0x91334000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var1_4201452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201452_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4201452_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e2" };
    $R2: bv64 := bvor(var1_4201452_bv64:bv64, bvshl(var2_4201452_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201456_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400001" };
    var var1_4201456_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9400001" };
    var var2_4201456_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400001" };
    var var2_4201456_bv64: bv64 := load le $mem bvadd(var1_4201456_bv64:bv64, 0x0:bv64) 64 { .comment = "op: 0xf9400001" };
    $R1: bv64 := var2_4201456_bv64:bv64 { .comment = "op: 0xf9400001" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201460_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9000261" };
    store le $mem bvadd($R19:bv64, 0x0:bv64) $R1:bv64 64 { .comment = "op: 0xf9000261" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201464_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400800" };
    var var1_4201464_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9400800" };
    var var2_4201464_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400800" };
    var var2_4201464_bv32: bv32 := load le $mem bvadd(var1_4201464_bv64:bv64, 0x8:bv64) 32 { .comment = "op: 0xb9400800" };
    $R0: bv64 := zero_extend(32, var2_4201464_bv32:bv32) { .comment = "op: 0xb9400800" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var2_4201468_bv64: bv64 := $R21:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201468_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b3642a1" };
    var var3_4201468_bv64: bv64 := $R22:bv64 { .comment = "op: 0x8b3642a1" };
    $R1: bv64 := bvadd(var2_4201468_bv64:bv64, zero_extend(32, extract(32, 0, var3_4201468_bv64:bv64))) { .comment = "op: 0x8b3642a1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201472_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9000a60" };
    store le $mem bvadd($R19:bv64, 0x8:bv64) extract(32, 0, $R0:bv64) 32 { .comment = "op: 0xb9000a60" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201476_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4201476_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201476_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4201476_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4201476_bv64:bv64, bvshl(var2_4201476_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201480_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4201480_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4201480_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4201480_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4201480_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4201480_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201484_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4201484_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4201484_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4201484_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4201484_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4201484_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4201488_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4201488_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201488_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4201488_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4201488_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4201488_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4201488_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400006f" };
    $_PC: bv64 := 0x401dd0:bv64 { .comment = "op: 0x1400006f" };
    assert eq($R30:bv64, R30_begin_rerrstr_4201312:bv64) { .comment = "R30 = R30_in" };
    call @strecpy_4201936 ();
    goto(%rerrstr_basil_return_1);
  ];
  block %rerrstr_21 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%rerrstr_19);
  ];
  block %rerrstr_23 {.address = 0x401bd4; .originalLabel = "pjNl7mc/S1iHKZBTNfwg9g=="} [
    assert eq($_PC:bv64, 0x401bd4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401bd4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201428_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400000" };
    var var1_4201428_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9400000" };
    var var2_4201428_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400000" };
    var var2_4201428_bv32: bv32 := load le $mem bvadd(var1_4201428_bv64:bv64, 0x0:bv64) 32 { .comment = "op: 0xb9400000" };
    $R0: bv64 := zero_extend(32, var2_4201428_bv32:bv32) { .comment = "op: 0xb9400000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201432_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403f3" };
    var var1_4201432_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403f3" };
    var var2_4201432_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1403f3" };
    var var2_4201432_bv64: bv64 := $R20:bv64 { .comment = "op: 0xaa1403f3" };
    $R19: bv64 := bvor(var1_4201432_bv64:bv64, bvshl(var2_4201432_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1403f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201436_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100101f" };
    var var2_4201436_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100101f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffffffffffb:bv64), 0x1:bv64)))) { .comment = "op: 0x7100101f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffb:bv64), 0x1:bv64)))) { .comment = "op: 0x7100101f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100101f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)) { .comment = "op: 0x7100101f" };
    goto(%rerrstr_17, %rerrstr_21);
  ];
  block %rerrstr_25 {.address = 0x401bd0; .originalLabel = "EAajJv6fT9SOWcWgj2zy+Q=="} [
    assert eq($_PC:bv64, 0x401bd0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401bd0:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x401bd4:bv64 { .comment = "op: 0x97fffc50" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffc50" };
    $_PC: bv64 := 0x400d10:bv64 { .comment = "op: 0x97fffc50" };
    goto(%FUN_400d10_entry_67);
  ];
  block %rerrstr_27 [
    guard eq($R2:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401bd0:bv64;
    goto(%rerrstr_25);
  ];
  block %rerrstr_29 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401bd0:bv64;
    goto(%rerrstr_25);
  ];
  block %rerrstr_31 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401be4:bv64;
    goto(%rerrstr_19);
  ];
  block %rerrstr_33 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%rerrstr_15);
  ];
  block %rerrstr_35 {.address = 0x401b98; .originalLabel = "0j6o8VumRZOywvkhu9HKkA=="} [
    assert eq($_PC:bv64, 0x401b98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b98:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201368_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9400000" };
    var var1_4201368_bv64: bv64 := $R0:bv64 { .comment = "op: 0xb9400000" };
    var var2_4201368_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xb9400000" };
    var var2_4201368_bv32: bv32 := load le $mem bvadd(var1_4201368_bv64:bv64, 0x0:bv64) 32 { .comment = "op: 0xb9400000" };
    $R0: bv64 := zero_extend(32, var2_4201368_bv32:bv32) { .comment = "op: 0xb9400000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201372_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100101f" };
    var var2_4201372_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100101f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffffffffffb:bv64), 0x1:bv64)))) { .comment = "op: 0x7100101f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffb:bv64), 0x1:bv64)))) { .comment = "op: 0x7100101f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100101f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffb:bv32), 0x1:bv32)) { .comment = "op: 0x7100101f" };
    goto(%rerrstr_31, %rerrstr_33);
  ];
  block %rerrstr_37 {.address = 0x401b94; .originalLabel = "VrTygMoOT0KVYfDyv6XGDQ=="} [
    goto(%rerrstr_35);
  ];
  block %rerrstr_39 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401b94:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b94:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x401b98:bv64 { .comment = "op: 0x97fffc5f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffc5f" };
    $_PC: bv64 := 0x400d10:bv64 { .comment = "op: 0x97fffc5f" };
    goto(%FUN_400d10_entry_73);
  ];
  block %rerrstr_41 {.address = 0x401b8c; .originalLabel = "b/Ahzas8TGWodQQsZ5wEaw=="} [
    assert eq($_PC:bv64, 0x401b8c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b8c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4201356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4201356_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4201356_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4201356_bv64:bv64, bvshl(var2_4201356_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    goto(%rerrstr_29, %rerrstr_39);
  ];
  block %rerrstr_43 {.address = 0x401b88; .originalLabel = "fkOAxH+2Ruyn0K2w5cr2Pw=="} [
    goto(%rerrstr_41);
  ];
  block %rerrstr_45 [
    guard boolnot(eq($R2:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401b88:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401b88:bv64)"; .label = "pc-tracking" };
    var var1_4201352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0040" };
    var var1_4201352_bv64: bv64 := $R2:bv64 { .comment = "op: 0xd63f0040" };
    $R30: bv64 := 0x401b8c:bv64 { .comment = "op: 0xd63f0040" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0040" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0040" };
    $_PC: bv64 := var1_4201352_bv64:bv64 { .comment = "op: 0xd63f0040" };
    indirect call var1_4201352_bv64:bv64 ;
    goto(%rerrstr_43);
  ];
  block %_inlineret_3 [
    goto(%rerrstr_7);
  ];
  block %FUN_400c40_entry_57 {.address = 0x400c40} [
    var R30_begin_FUN_400c40_4197440_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c40:bv64);
    $_PC: bv64 := 0x400c40:bv64;
    assert eq($_PC:bv64, 0x400c40:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c40:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197444_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9402a11" };
    var var1_4197444_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9402a11" };
    var var2_4197444_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9402a11" };
    var var2_4197444_bv64_3: bv64 := load le $mem bvadd(var1_4197444_bv64_2:bv64, 0x50:bv64) 64 { .comment = "op: 0xf9402a11" };
    $R17: bv64 := var2_4197444_bv64_3:bv64 { .comment = "op: 0xf9402a11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197448_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x91014210" };
    var var2_4197448_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x91014210" };
    var var2_4197448_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x91014210" };
    $R16: bv64 := bvadd(var2_4197448_bv64_5:bv64, 0x50:bv64) { .comment = "op: 0x91014210" };
    var var1_4197452_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c40_4197440_1:bv64) { .comment = "R30 = R30_in" };
    call @strerror ();
    goto(%FUN_400c40_basil_return_1_58);
  ];
  block %FUN_400c40_basil_return_1_58 [
    goto(%_inlineret_3);
  ];
  block %_inlineret_4 {.originalLabel = "HIYg9nK0QK+SbtSpi6FDfA=="} [
    goto(%rerrstr_3);
  ];
  block %FUN_400cd0_entry_61 {.address = 0x400cd0} [
    var R30_begin_FUN_400cd0_4197584_7: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400cd0:bv64);
    $_PC: bv64 := 0x400cd0:bv64;
    assert eq($_PC:bv64, 0x400cd0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400cd0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197588_bv64_8: bv64 := 0x0:bv64 { .comment = "op: 0xf9404e11" };
    var var1_4197588_bv64_8: bv64 := $R16:bv64 { .comment = "op: 0xf9404e11" };
    var var2_4197588_bv64_9: bv64 := 0x0:bv64 { .comment = "op: 0xf9404e11" };
    var var2_4197588_bv64_9: bv64 := load le $mem bvadd(var1_4197588_bv64_8:bv64, 0x98:bv64) 64 { .comment = "op: 0xf9404e11" };
    $R17: bv64 := var2_4197588_bv64_9:bv64 { .comment = "op: 0xf9404e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197592_bv64_10: bv64 := 0x0:bv64 { .comment = "op: 0x91026210" };
    var var2_4197592_bv64_11: bv64 := 0x0:bv64 { .comment = "op: 0x91026210" };
    var var2_4197592_bv64_11: bv64 := $R16:bv64 { .comment = "op: 0x91026210" };
    $R16: bv64 := bvadd(var2_4197592_bv64_11:bv64, 0x98:bv64) { .comment = "op: 0x91026210" };
    var var1_4197596_bv64_12: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400cd0_4197584_7:bv64) { .comment = "R30 = R30_in" };
    call @strcpy ();
    goto(%FUN_400cd0_basil_return_1_62);
  ];
  block %FUN_400cd0_basil_return_1_62 [
    goto(%_inlineret_4);
  ];
  block %_inlineret_5 {.originalLabel = "EAajJv6fT9SOWcWgj2zy+Q=="} [
    goto(%rerrstr_23);
  ];
  block %FUN_400d10_entry_67 {.address = 0x400d10} [
    var R30_begin_FUN_400d10_4197648_13: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64);
    $_PC: bv64 := 0x400d10:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400d10:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197652_bv64_14: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var1_4197652_bv64_14: bv64 := $R16:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_15: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_15: bv64 := load le $mem bvadd(var1_4197652_bv64_14:bv64, 0xb8:bv64) 64 { .comment = "op: 0xf9405e11" };
    $R17: bv64 := var2_4197652_bv64_15:bv64 { .comment = "op: 0xf9405e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197656_bv64_16: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_17: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_17: bv64 := $R16:bv64 { .comment = "op: 0x9102e210" };
    $R16: bv64 := bvadd(var2_4197656_bv64_17:bv64, 0xb8:bv64) { .comment = "op: 0x9102e210" };
    var var1_4197660_bv64_18: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_13:bv64) { .comment = "R30 = R30_in" };
    call @__errno_location ();
    goto(%FUN_400d10_basil_return_1_68);
  ];
  block %FUN_400d10_basil_return_1_68 [
    goto(%_inlineret_5);
  ];
  block %_inlineret_6 [
    goto(%rerrstr_37);
  ];
  block %FUN_400d10_entry_73 {.address = 0x400d10} [
    var R30_begin_FUN_400d10_4197648_19: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64);
    $_PC: bv64 := 0x400d10:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400d10:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197652_bv64_20: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var1_4197652_bv64_20: bv64 := $R16:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_21: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_21: bv64 := load le $mem bvadd(var1_4197652_bv64_20:bv64, 0xb8:bv64) 64 { .comment = "op: 0xf9405e11" };
    $R17: bv64 := var2_4197652_bv64_21:bv64 { .comment = "op: 0xf9405e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197656_bv64_22: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_23: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_23: bv64 := $R16:bv64 { .comment = "op: 0x9102e210" };
    $R16: bv64 := bvadd(var2_4197656_bv64_23:bv64, 0xb8:bv64) { .comment = "op: 0x9102e210" };
    var var1_4197660_bv64_24: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_19:bv64) { .comment = "R30 = R30_in" };
    call @__errno_location ();
    goto(%FUN_400d10_basil_return_1_74);
  ];
  block %FUN_400d10_basil_return_1_74 [
    goto(%_inlineret_6);
  ];
  block %rerrstr_basil_return_1 [
    return ();
  ]
];


proc @errstr_4201540 () -> ()
  { .name = "errstr"; .address = 0x401c44; .returnBlock = "errstr_basil_return_1" }
  require eq($_PC:bv64, 0x401c44:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %errstr_entry {.address = 0x401c44; .originalLabel = "3ReV3l3lTEWXlI8dRV4Pcw=="} [
    assert eq($_PC:bv64, 0x401c44:bv64);
    $_PC: bv64 := 0x401c44:bv64;
    assert eq($_PC:bv64, 0x401c44:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c44:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201540_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9b67bfd" };
    var var1_4201540_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9b67bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffff60:bv64) $R29:bv64 64 { .comment = "op: 0xa9b67bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffff60:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9b67bfd" };
    $R31: bv64 := bvadd(var1_4201540_bv64:bv64, 0xffffffffffffff60:bv64) { .comment = "op: 0xa9b67bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201544_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var1_4201544_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4201544_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e2" };
    var var2_4201544_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e2" };
    $R2: bv64 := bvor(var1_4201544_bv64:bv64, bvshl(var2_4201544_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201548_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4201556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4201556_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4201556_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4201556_bv64:bv64, bvshl(var2_4201556_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201560_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f4" };
    var var1_4201560_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f4" };
    var var2_4201560_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f4" };
    var var2_4201560_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x2a0103f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4201560_bv32:bv32, bvshl(var2_4201560_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0103f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201564_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910083e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x20:bv64) { .comment = "op: 0x910083e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201568_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910283e1" };
    $R1: bv64 := bvadd($R31:bv64, 0xa0:bv64) { .comment = "op: 0x910283e1" };
    $R30: bv64 := 0x401c68:bv64 { .comment = "op: 0x9400005b" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400005b" };
    $_PC: bv64 := 0x401dd0:bv64 { .comment = "op: 0x9400005b" };
    call @strecpy_4201936 ();
    goto(%errstr_25);
  ];
  block %errstr_3 {.address = 0x401c9c; .originalLabel = "vnUCBVITRHaAu+63BFZIvg=="} [
    assert eq($_PC:bv64, 0x401c9c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c9c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var1_4201628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4201628_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e1" };
    var var2_4201628_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e1" };
    $R1: bv64 := bvor(var1_4201628_bv64:bv64, bvshl(var2_4201628_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x3745:bv64 { .comment = "op: 0x5286e8a2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201640_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4201640_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4201640_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4201640_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4201640_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4201640_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201644_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x72a32502" };
    var var1_4201644_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x72a32502" };
    $R2: bv64 := zero_extend(32, bvor(bvand(var1_4201644_bv32:bv32, 0xffff:bv32), 0x19280000:bv32)) { .comment = "op: 0x72a32502" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201648_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xb9000022" };
    store le $stack bvadd($R1:bv64, 0x0:bv64) extract(32, 0, $R2:bv64) 32 { .comment = "op: 0xb9000022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201652_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8ca7bfd" };
    var var1_4201652_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8ca7bfd" };
    var var2_4201652_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8ca7bfd" };
    var var2_4201652_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8ca7bfd" };
    var var3_4201652_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8ca7bfd" };
    var var3_4201652_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8ca7bfd" };
    $R29: bv64 := var2_4201652_bv64:bv64 { .comment = "op: 0xa8ca7bfd" };
    $R30: bv64 := var3_4201652_bv64:bv64 { .comment = "op: 0xa8ca7bfd" };
    $R31: bv64 := bvadd(var1_4201652_bv64:bv64, 0xa0:bv64) { .comment = "op: 0xa8ca7bfd" };
    var var1_4201656_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%errstr_basil_return_1);
  ];
  block %errstr_5 {.address = 0x401c98; .originalLabel = "Co/LVkMiTVyPERBYorwrzw=="} [
    assert eq($_PC:bv64, 0x401c98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c98:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x401c9c:bv64 { .comment = "op: 0x97fffc1e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffc1e" };
    $_PC: bv64 := 0x400d10:bv64 { .comment = "op: 0x97fffc1e" };
    goto(%FUN_400d10_entry_75);
  ];
  block %errstr_7 {.address = 0x401c8c; .originalLabel = "efXe1cTBRXi46nMunP8mZw=="} [
    assert eq($_PC:bv64, 0x401c8c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c8c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201612_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910083e2" };
    $R2: bv64 := bvadd($R31:bv64, 0x20:bv64) { .comment = "op: 0x910083e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201616_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91020001" };
    var var2_4201616_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91020001" };
    var var2_4201616_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91020001" };
    $R1: bv64 := bvadd(var2_4201616_bv64:bv64, 0x80:bv64) { .comment = "op: 0x91020001" };
    $R30: bv64 := 0x401c98:bv64 { .comment = "op: 0x9400004f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400004f" };
    $_PC: bv64 := 0x401dd0:bv64 { .comment = "op: 0x9400004f" };
    call @strecpy_4201936 ();
    goto(%errstr_5);
  ];
  block %errstr_9 {.address = 0x401cbc; .originalLabel = "wXqrMOzwQWWPFMqJ3rBAyQ=="} [
    assert eq($_PC:bv64, 0x401cbc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401cbc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201660_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4201660_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201660_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201660_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4201660_bv64:bv64, bvshl(var2_4201660_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff3" };
    $_PC: bv64 := 0x401c8c:bv64 { .comment = "op: 0x17fffff3" };
    goto(%errstr_7);
  ];
  block %errstr_11 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401cbc:bv64;
    goto(%errstr_9);
  ];
  block %errstr_13 [
    guard eq($R0:bv64, 0x0:bv64);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401cbc:bv64;
    goto(%errstr_9);
  ];
  block %errstr_15 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%errstr_7);
  ];
  block %errstr_17 {.address = 0x401c88; .originalLabel = "c2uqiaTESQCFPjeGp7asMg=="} [
    assert eq($_PC:bv64, 0x401c88:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c88:bv64)"; .label = "pc-tracking" };
    goto(%errstr_13, %errstr_15);
  ];
  block %errstr_19 {.address = 0x401c84; .originalLabel = "U7bhqlePRVSsEJixz6eB9A=="} [
    goto(%errstr_17);
  ];
  block %errstr_21 [
    guard boolnot(eq($R0:bv64, 0x0:bv64));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401c84:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c84:bv64)"; .label = "pc-tracking" };
    var var1_4201604_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd63f0000" };
    var var1_4201604_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd63f0000" };
    $R30: bv64 := 0x401c88:bv64 { .comment = "op: 0xd63f0000" };
    $BTypeNext: bv2 := 0x2:bv2 { .comment = "op: 0xd63f0000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd63f0000" };
    $_PC: bv64 := var1_4201604_bv64:bv64 { .comment = "op: 0xd63f0000" };
    indirect call var1_4201604_bv64:bv64 ;
    goto(%errstr_19);
  ];
  block %errstr_23 {.address = 0x401c7c; .originalLabel = "zkcaJcNtRmWYGlfR/l2eIA=="} [
    assert eq($_PC:bv64, 0x401c7c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c7c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201596_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9404260" };
    var var1_4201596_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9404260" };
    var var2_4201596_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9404260" };
    var var2_4201596_bv64: bv64 := load le $mem bvadd(var1_4201596_bv64:bv64, 0x80:bv64) 64 { .comment = "op: 0xf9404260" };
    $R0: bv64 := var2_4201596_bv64:bv64 { .comment = "op: 0xf9404260" };
    goto(%errstr_11, %errstr_21);
  ];
  block %errstr_25 {.address = 0x401c68; .originalLabel = "tMKfd8XWTy+VlAGJ/Jx4zw=="} [
    assert eq($_PC:bv64, 0x401c68:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401c68:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4201576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201576_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4201576_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4201576_bv64:bv64, bvshl(var2_4201576_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := 0x420000:bv64 { .comment = "op: 0xf00000f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911a0273" };
    var var2_4201584_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x911a0273" };
    var var2_4201584_bv64: bv64 := $R19:bv64 { .comment = "op: 0x911a0273" };
    $R19: bv64 := bvadd(var2_4201584_bv64:bv64, 0x680:bv64) { .comment = "op: 0x911a0273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e1" };
    var var1_4201588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e1" };
    var var2_4201588_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e1" };
    var var2_4201588_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4201588_bv32:bv32, bvshl(var2_4201588_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e1" };
    $R30: bv64 := 0x401c7c:bv64 { .comment = "op: 0x97ffffba" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffffba" };
    $_PC: bv64 := 0x401b60:bv64 { .comment = "op: 0x97ffffba" };
    call @rerrstr_4201312 ();
    goto(%errstr_23);
  ];
  block %_inlineret_3 {.originalLabel = "Co/LVkMiTVyPERBYorwrzw=="} [
    goto(%errstr_3);
  ];
  block %FUN_400d10_entry_75 {.address = 0x400d10} [
    var R30_begin_FUN_400d10_4197648_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64);
    $_PC: bv64 := 0x400d10:bv64;
    assert eq($_PC:bv64, 0x400d10:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400d10:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197652_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var1_4197652_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9405e11" };
    var var2_4197652_bv64_3: bv64 := load le $mem bvadd(var1_4197652_bv64_2:bv64, 0xb8:bv64) 64 { .comment = "op: 0xf9405e11" };
    $R17: bv64 := var2_4197652_bv64_3:bv64 { .comment = "op: 0xf9405e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197656_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x9102e210" };
    var var2_4197656_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x9102e210" };
    $R16: bv64 := bvadd(var2_4197656_bv64_5:bv64, 0xb8:bv64) { .comment = "op: 0x9102e210" };
    var var1_4197660_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400d10_4197648_1:bv64) { .comment = "R30 = R30_in" };
    call @__errno_location ();
    goto(%FUN_400d10_basil_return_1_76);
  ];
  block %FUN_400d10_basil_return_1_76 [
    goto(%_inlineret_3);
  ];
  block %errstr_basil_return_1 [
    return ();
  ]
];


proc @werrstr_4201780 () -> ()
  { .name = "werrstr"; .address = 0x401d34; .returnBlock = "werrstr_basil_return_1" }
  require eq($_PC:bv64, 0x401d34:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %werrstr_entry {.address = 0x401d34; .originalLabel = "EsiP/3+hSbS6DhsMqrwxFA=="} [
    assert eq($_PC:bv64, 0x401d34:bv64);
    $_PC: bv64 := 0x401d34:bv64;
    assert eq($_PC:bv64, 0x401d34:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401d34:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201780_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9a77bfd" };
    var var1_4201780_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9a77bfd" };
    store le $stack bvadd($R31:bv64, 0xfffffffffffffe70:bv64) $R29:bv64 64 { .comment = "op: 0xa9a77bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xfffffffffffffe70:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9a77bfd" };
    $R31: bv64 := bvadd(var1_4201780_bv64:bv64, 0xfffffffffffffe70:bv64) { .comment = "op: 0xa9a77bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R10: bv64 := 0xffffffc8:bv64 { .comment = "op: 0x128006ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R9: bv64 := 0xffffff80:bv64 { .comment = "op: 0x12800fe9" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201792_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201796_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910643eb" };
    $R11: bv64 := bvadd($R31:bv64, 0x190:bv64) { .comment = "op: 0x910643eb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201800_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910543e8" };
    $R8: bv64 := bvadd($R31:bv64, 0x150:bv64) { .comment = "op: 0x910543e8" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) $R11:bv64 64 { .comment = "op: 0xa9032feb" };
    store le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x8:bv64) $R11:bv64 64 { .comment = "op: 0xa9032feb" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x40:bv64) $R8:bv64 64 { .comment = "op: 0xf90023e8" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e8" };
    var var1_4201812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e8" };
    var var2_4201812_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003e8" };
    var var2_4201812_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003e8" };
    $R8: bv64 := bvor(var1_4201812_bv64:bv64, bvshl(var2_4201812_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003e8" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x48:bv64) extract(32, 0, $R10:bv64) 32 { .comment = "op: 0x290927ea" };
    store le $stack bvadd(bvadd($R31:bv64, 0x48:bv64), 0x4:bv64) extract(32, 0, $R9:bv64) 32 { .comment = "op: 0x290927ea" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201820_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910143e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x50:bv64) { .comment = "op: 0x910143e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xd0:bv64) $Z0:bv128 128 { .comment = "op: 0x3d8037e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201828_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad41c3e0" };
    var var1_4201828_bv128: bv128 := load le $stack bvadd($R31:bv64, 0x30:bv64) 128 { .comment = "op: 0xad41c3e0" };
    var var2_4201828_bv128: bv128 := 0x0:bv128 { .comment = "op: 0xad41c3e0" };
    var var2_4201828_bv128: bv128 := load le $stack bvadd(bvadd($R31:bv64, 0x30:bv64), 0x10:bv64) 128 { .comment = "op: 0xad41c3e0" };
    $Z0: bv128 := var1_4201828_bv128:bv128 { .comment = "op: 0xad41c3e0" };
    $Z16: bv128 := var2_4201828_bv128:bv128 { .comment = "op: 0xad41c3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x158:bv64) $R1:bv64 64 { .comment = "op: 0xa9158be1" };
    store le $stack bvadd(bvadd($R31:bv64, 0x158:bv64), 0x8:bv64) $R2:bv64 64 { .comment = "op: 0xa9158be1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0803e2" };
    var var1_4201836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0803e2" };
    var var2_4201836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0803e2" };
    var var2_4201836_bv64: bv64 := $R8:bv64 { .comment = "op: 0xaa0803e2" };
    $R2: bv64 := bvor(var1_4201836_bv64:bv64, bvshl(var2_4201836_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0803e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x168:bv64) $R3:bv64 64 { .comment = "op: 0xa91693e3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x168:bv64), 0x8:bv64) $R4:bv64 64 { .comment = "op: 0xa91693e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201844_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910043e3" };
    $R3: bv64 := bvadd($R31:bv64, 0x10:bv64) { .comment = "op: 0x910043e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201848_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910343e1" };
    $R1: bv64 := bvadd($R31:bv64, 0xd0:bv64) { .comment = "op: 0x910343e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $Z0:bv128 128 { .comment = "op: 0xad00c3e0" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x10:bv64) $Z16:bv128 128 { .comment = "op: 0xad00c3e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xe0:bv64) $Z1:bv128 128 { .comment = "op: 0x3d803be1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0xf0:bv64) $Z2:bv128 128 { .comment = "op: 0x3d803fe2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x100:bv64) $Z3:bv128 128 { .comment = "op: 0x3d8043e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x110:bv64) $Z4:bv128 128 { .comment = "op: 0x3d8047e4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x120:bv64) $Z5:bv128 128 { .comment = "op: 0x3d804be5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x130:bv64) $Z6:bv128 128 { .comment = "op: 0x3d804fe6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x140:bv64) $Z7:bv128 128 { .comment = "op: 0x3d8053e7" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x178:bv64) $R5:bv64 64 { .comment = "op: 0xa9179be5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x178:bv64), 0x8:bv64) $R6:bv64 64 { .comment = "op: 0xa9179be5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x188:bv64) $R7:bv64 64 { .comment = "op: 0xf900c7e7" };
    $R30: bv64 := 0x401da8:bv64 { .comment = "op: 0x97ffff4f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff4f" };
    $_PC: bv64 := 0x401ae0:bv64 { .comment = "op: 0x97ffff4f" };
    call @vseprint_4201184 ();
    goto(%werrstr_7);
  ];
  block %werrstr_5 {.address = 0x401db4; .originalLabel = "M6nMm4cETPChPGRp+64SbQ=="} [
    assert eq($_PC:bv64, 0x401db4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401db4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d97bfd" };
    var var1_4201908_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8d97bfd" };
    var var2_4201908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d97bfd" };
    var var2_4201908_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8d97bfd" };
    var var3_4201908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8d97bfd" };
    var var3_4201908_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8d97bfd" };
    $R29: bv64 := var2_4201908_bv64:bv64 { .comment = "op: 0xa8d97bfd" };
    $R30: bv64 := var3_4201908_bv64:bv64 { .comment = "op: 0xa8d97bfd" };
    $R31: bv64 := bvadd(var1_4201908_bv64:bv64, 0x190:bv64) { .comment = "op: 0xa8d97bfd" };
    var var1_4201912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%werrstr_basil_return_1);
  ];
  block %werrstr_7 {.address = 0x401da8; .originalLabel = "AqC6Zdb7SHKUzL/tutKRaQ=="} [
    assert eq($_PC:bv64, 0x401da8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401da8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4201896_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910143e0" };
    $R0: bv64 := bvadd($R31:bv64, 0x50:bv64) { .comment = "op: 0x910143e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x80:bv64 { .comment = "op: 0x52801001" };
    $R30: bv64 := 0x401db4:bv64 { .comment = "op: 0x97ffffa5" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffffa5" };
    $_PC: bv64 := 0x401c44:bv64 { .comment = "op: 0x97ffffa5" };
    call @errstr_4201540 ();
    goto(%werrstr_5);
  ];
  block %werrstr_basil_return_1 [
    return ();
  ]
];


proc @remove () -> ()
  { .name = "remove" };


proc @fcntl64 () -> ()
  { .name = "fcntl64" };


proc @close () -> ()
  { .name = "close" };


proc @open64 () -> ()
  { .name = "open64" };


proc @p9open_4198832 () -> ()
  { .name = "p9open"; .address = 0x4011b0; .returnBlock = "p9open_basil_return_1" }
  require eq($_PC:bv64, 0x4011b0:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %p9open_entry {.address = 0x4011b0; .originalLabel = "DYW7Gbw6QwK5DzhE/cGL7w=="} [
    assert eq($_PC:bv64, 0x4011b0:bv64);
    $_PC: bv64 := 0x4011b0:bv64;
    assert eq($_PC:bv64, 0x4011b0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011b0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198832_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bb7bfd" };
    var var1_4198832_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bb7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffb0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bb7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffb0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bb7bfd" };
    $R31: bv64 := bvadd(var1_4198832_bv64:bv64, 0xffffffffffffffb0:bv64) { .comment = "op: 0xa9bb7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0xffffdf9c:bv64 { .comment = "op: 0x12840c62" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198840_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xa020022" };
    var var1_4198840_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0xa020022" };
    var var2_4198840_bv32: bv32 := 0x0:bv32 { .comment = "op: 0xa020022" };
    var var2_4198840_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0xa020022" };
    $R2: bv64 := zero_extend(32, bvand(var1_4198840_bv32:bv32, bvshl(var2_4198840_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0xa020022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198844_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f3" };
    var var1_4198852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f3" };
    var var2_4198852_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0103f3" };
    var var2_4198852_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x2a0103f3" };
    $R19: bv64 := zero_extend(32, bvor(var1_4198852_bv32:bv32, bvshl(var2_4198852_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0103f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198860_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x12000436" };
    var var1_4198860_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x12000436" };
    $R22: bv64 := zero_extend(32, bvand(var1_4198860_bv32:bv32, 0x3:bv32)) { .comment = "op: 0x12000436" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var1_4198864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4198864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f5" };
    var var2_4198864_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f5" };
    $R21: bv64 := bvor(var1_4198864_bv64:bv64, bvshl(var2_4198864_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198868_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1603e1" };
    var var1_4198868_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1603e1" };
    var var2_4198868_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1603e1" };
    var var2_4198868_bv32: bv32 := extract(32, 0, $R22:bv64) { .comment = "op: 0x2a1603e1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4198868_bv32:bv32, bvshl(var2_4198868_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1603e1" };
    goto(%p9open_99, %p9open_103);
  ];
  block %p9open_5 {.address = 0x401228; .originalLabel = "PRS5Jt1zSd2UOUpuNucPFQ=="} [
    assert eq($_PC:bv64, 0x401228:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401228:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4198952_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4198952_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4198952_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4198952_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4198952_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198956_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4198956_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198956_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198956_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4198956_bv32:bv32, bvshl(var2_4198956_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198960_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4198960_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4198960_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4198960_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4198960_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4198960_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var1_4198964_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4198964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4198964_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c57bfd" };
    var var3_4198964_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var3_4198964_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c57bfd" };
    $R29: bv64 := var2_4198964_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R30: bv64 := var3_4198964_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R31: bv64 := bvadd(var1_4198964_bv64:bv64, 0x50:bv64) { .comment = "op: 0xa8c57bfd" };
    var var1_4198968_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%p9open_basil_return_1);
  ];
  block %p9open_7 {.address = 0x4012c0; .originalLabel = "VD11bd0PRFeMtWOvELtDwg=="} [
    assert eq($_PC:bv64, 0x4012c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4012c0:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffda" };
    $_PC: bv64 := 0x401228:bv64 { .comment = "op: 0x17ffffda" };
    goto(%p9open_5);
  ];
  block %p9open_9 {.address = 0x4012ac; .originalLabel = "3Df6EdPRTmiBZQGPQyc0yQ=="} [
    goto(%p9open_7);
  ];
  block %p9open_11 [
    guard boolnot(eq(extract(32, 0, $R2:bv64), 0x0:bv32));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4012ac:bv64;
    assert eq($_PC:bv64, 0x4012ac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4012ac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var1_4199084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var2_4199084_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0203e1" };
    var var2_4199084_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x2a0203e1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4199084_bv32:bv32, bvshl(var2_4199084_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0203e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0x90000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800014" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91324000" };
    var var2_4199096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91324000" };
    var var2_4199096_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91324000" };
    $R0: bv64 := bvadd(var2_4199096_bv64:bv64, 0xc90:bv64) { .comment = "op: 0x91324000" };
    $R30: bv64 := 0x4012c0:bv64 { .comment = "op: 0x9400029e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400029e" };
    $_PC: bv64 := 0x401d34:bv64 { .comment = "op: 0x9400029e" };
    call @werrstr_4201780 ();
    goto(%p9open_9);
  ];
  block %p9open_13 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401228:bv64;
    goto(%p9open_5);
  ];
  block %p9open_15 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x6:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401228:bv64;
    goto(%p9open_5);
  ];
  block %p9open_17 {.address = 0x401298; .originalLabel = "449xLVEJTGa6pPbxGVEE2Q=="} [
    assert eq($_PC:bv64, 0x401298:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401298:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199064_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4199064_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4199064_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4199064_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4199064_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4199064_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4199068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199068_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199068_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4199068_bv32:bv32, bvshl(var2_4199068_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4199072_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4199072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4199072_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4199072_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4199072_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var1_4199076_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4199076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var2_4199076_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c57bfd" };
    var var3_4199076_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c57bfd" };
    var var3_4199076_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c57bfd" };
    $R29: bv64 := var2_4199076_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R30: bv64 := var3_4199076_bv64:bv64 { .comment = "op: 0xa8c57bfd" };
    $R31: bv64 := bvadd(var1_4199076_bv64:bv64, 0x50:bv64) { .comment = "op: 0xa8c57bfd" };
    var var1_4199080_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%p9open_basil_return_1);
  ];
  block %p9open_19 {.address = 0x401290; .originalLabel = "Gm2LBR8eQIqjVYYMR43VQg=="} [
    assert eq($_PC:bv64, 0x401290:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401290:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4199056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4199056_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4199056_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4199056_bv64:bv64, bvshl(var2_4199056_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x401298:bv64 { .comment = "op: 0x97fffe57" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe57" };
    $_PC: bv64 := 0x400bf0:bv64 { .comment = "op: 0x97fffe57" };
    goto(%FUN_400bf0_entry_55);
  ];
  block %p9open_21 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x6:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9open_19);
  ];
  block %p9open_23 {.address = 0x40128c; .originalLabel = "nz5xUkUVRg2cTH/Hfo8VlA=="} [
    assert eq($_PC:bv64, 0x40128c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40128c:bv64)"; .label = "pc-tracking" };
    goto(%p9open_15, %p9open_21);
  ];
  block %p9open_25 {.address = 0x40127c; .originalLabel = "8a/w3iFMQROspU5s+A6hEA=="} [
    goto(%p9open_23);
  ];
  block %p9open_27 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x5:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40127c:bv64;
    assert eq($_PC:bv64, 0x40127c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40127c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199036_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4199036_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199036_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199036_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4199036_bv32:bv32, bvshl(var2_4199036_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x1:bv64 { .comment = "op: 0x52800022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x4:bv64 { .comment = "op: 0x52800081" };
    $R30: bv64 := 0x40128c:bv64 { .comment = "op: 0x97fffe8e" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe8e" };
    $_PC: bv64 := 0x400cc0:bv64 { .comment = "op: 0x97fffe8e" };
    goto(%FUN_400cc0_entry_53);
  ];
  block %p9open_29 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x6:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401290:bv64;
    goto(%p9open_19);
  ];
  block %p9open_31 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x6:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9open_5);
  ];
  block %p9open_33 {.address = 0x401224; .originalLabel = "alIJOTkkRYWZ27Go6iu1AA=="} [
    goto(%p9open_29, %p9open_31);
  ];
  block %p9open_35 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x5:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401224:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401224:bv64)"; .label = "pc-tracking" };
    goto(%p9open_33);
  ];
  block %p9open_37 {.address = 0x401220; .originalLabel = "nQWVqHuWRAWTn+l0Y0jz6A=="} [
    assert eq($_PC:bv64, 0x401220:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401220:bv64)"; .label = "pc-tracking" };
    goto(%p9open_27, %p9open_35);
  ];
  block %p9open_39 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401220:bv64;
    goto(%p9open_37);
  ];
  block %p9open_41 {.address = 0x401278; .originalLabel = "kj1av9+1RuanSeIDfmLDiw=="} [
    assert eq($_PC:bv64, 0x401278:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401278:bv64)"; .label = "pc-tracking" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17ffffec" };
    $_PC: bv64 := 0x401228:bv64 { .comment = "op: 0x17ffffec" };
    goto(%p9open_5);
  ];
  block %p9open_43 {.address = 0x401268; .originalLabel = "oZZFMK1yRWG+HfVLV3Xicw=="} [
    assert eq($_PC:bv64, 0x401268:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401268:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0x90000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R20: bv64 := 0xffffffff:bv64 { .comment = "op: 0x12800014" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9132a000" };
    var var2_4199024_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9132a000" };
    var var2_4199024_bv64: bv64 := $R0:bv64 { .comment = "op: 0x9132a000" };
    $R0: bv64 := bvadd(var2_4199024_bv64:bv64, 0xca8:bv64) { .comment = "op: 0x9132a000" };
    $R30: bv64 := 0x401278:bv64 { .comment = "op: 0x940002b0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940002b0" };
    $_PC: bv64 := 0x401d34:bv64 { .comment = "op: 0x940002b0" };
    call @werrstr_4201780 ();
    goto(%p9open_41);
  ];
  block %p9open_45 {.address = 0x401260; .originalLabel = "DEnW0YNFSWeAu/7gpgegvQ=="} [
    goto(%p9open_43);
  ];
  block %p9open_47 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401260:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401260:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4199008_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4199008_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199008_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4199008_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4199008_bv32:bv32, bvshl(var2_4199008_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $R30: bv64 := 0x401268:bv64 { .comment = "op: 0x97fffe7b" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe7b" };
    $_PC: bv64 := 0x400c50:bv64 { .comment = "op: 0x97fffe7b" };
    goto(%FUN_400c50_entry_49);
  ];
  block %p9open_49 {.address = 0x40125c; .originalLabel = "KcNOwrWLSweGwIU+S2j5/g=="} [
    assert eq($_PC:bv64, 0x40125c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40125c:bv64)"; .label = "pc-tracking" };
    goto(%p9open_39, %p9open_47);
  ];
  block %p9open_51 [
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x6:bv64 { .comment = "op: 0x528000c1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x30:bv64) extract(16, 0, $R3:bv64) 16 { .comment = "op: 0x790063e3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x32:bv64) 0x0:bv16 16 { .comment = "op: 0x790067ff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x38:bv64) 0x0:bv64 64 { .comment = "op: 0xa903ffff" };
    store le $stack bvadd(bvadd($R31:bv64, 0x38:bv64), 0x8:bv64) 0x0:bv64 64 { .comment = "op: 0xa903ffff" };
    $R30: bv64 := 0x40125c:bv64 { .comment = "op: 0x97fffe9a" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffe9a" };
    $_PC: bv64 := 0x400cc0:bv64 { .comment = "op: 0x97fffe9a" };
    goto(%FUN_400cc0_entry_51);
  ];
  block %p9open_53 [
    guard eq($ZF:bv1, 0x1:bv1);
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, var1_4198980_bv32:bv32);
    goto(%p9open_51);
  ];
  block %p9open_55 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := zero_extend(32, bvadd(var2_4198980_bv32:bv32, 0x1:bv32));
    goto(%p9open_51);
  ];
  block %p9open_57 {.address = 0x40123c; .originalLabel = "J3twCCKKQuqoQAZjGOU1bw=="} [
    goto(%p9open_53, %p9open_55);
  ];
  block %p9open_59 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0xd:bv12)))), 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40123c:bv64;
    assert eq($_PC:bv64, 0x40123c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40123c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198972_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710002df" };
    var var2_4198972_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x710002df" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R22:bv64)), 0xffffffffffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710002df" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R22:bv64)), 0xffffffff:bv64), 0x1:bv64)))) { .comment = "op: 0x710002df" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x710002df" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R22:bv64), 0xffffffff:bv32), 0x1:bv32)) { .comment = "op: 0x710002df" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198976_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100c3e2" };
    $R2: bv64 := bvadd($R31:bv64, 0x30:bv64) { .comment = "op: 0x9100c3e2" };
    var var1_4198980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e3" };
    var var1_4198980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e3" };
    var var2_4198980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e3" };
    var var2_4198980_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x1a9f07e3" };
    goto(%p9open_57);
  ];
  block %p9open_61 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0xd:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9open_37);
  ];
  block %p9open_63 {.address = 0x40121c; .originalLabel = "AFAr1iL5QQ2Jc7Lcv8olag=="} [
    goto(%p9open_59, %p9open_61);
  ];
  block %p9open_65 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40121c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40121c:bv64)"; .label = "pc-tracking" };
    goto(%p9open_63);
  ];
  block %p9open_67 {.address = 0x401214; .originalLabel = "16cjRfIRTGSibJLXxjbCWA=="} [
    assert eq($_PC:bv64, 0x401214:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401214:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var1_4198932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198932_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198932_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4198932_bv32:bv32, bvshl(var2_4198932_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f4" };
    goto(%p9open_13, %p9open_65);
  ];
  block %p9open_69 {.address = 0x40120c; .originalLabel = "fGpMpUMvT6yNpRToOQFvqg=="} [
    goto(%p9open_67);
  ];
  block %p9open_71 [
    guard boolnot(boolnot(eq(extract(32, 0, $R2:bv64), 0x0:bv32)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x40120c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40120c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var1_4198924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4198924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e0" };
    var var2_4198924_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e0" };
    $R0: bv64 := bvor(var1_4198924_bv64:bv64, bvshl(var2_4198924_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e0" };
    $R30: bv64 := 0x401214:bv64 { .comment = "op: 0x97fffeb8" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffeb8" };
    $_PC: bv64 := 0x400cf0:bv64 { .comment = "op: 0x97fffeb8" };
    goto(%FUN_400cf0_entry_45);
  ];
  block %p9open_73 {.address = 0x401208; .originalLabel = "B7+L3lUpTMWTnn4gbgBUWQ=="} [
    assert eq($_PC:bv64, 0x401208:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401208:bv64)"; .label = "pc-tracking" };
    goto(%p9open_11, %p9open_71);
  ];
  block %p9open_75 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0xe:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x401208:bv64;
    goto(%p9open_73);
  ];
  block %p9open_77 {.address = 0x401200; .originalLabel = "ukZwZPH0S8G4lyKYnX6iOA=="} [
    goto(%p9open_73);
  ];
  block %p9open_79 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0xe:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401200:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401200:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198912_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x32160021" };
    var var1_4198912_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x32160021" };
    $R1: bv64 := zero_extend(32, bvor(var1_4198912_bv32:bv32, 0x400:bv32)) { .comment = "op: 0x32160021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198916_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x52120042" };
    var var1_4198916_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x52120042" };
    $R2: bv64 := zero_extend(32, bvxor(var1_4198916_bv32:bv32, 0x4000:bv32)) { .comment = "op: 0x52120042" };
    goto(%p9open_77);
  ];
  block %p9open_81 {.address = 0x4011fc; .originalLabel = "dUbIG4o3RIOQBtZwZ/gRqw=="} [
    assert eq($_PC:bv64, 0x4011fc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011fc:bv64)"; .label = "pc-tracking" };
    goto(%p9open_75, %p9open_79);
  ];
  block %p9open_83 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0x8:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4011fc:bv64;
    goto(%p9open_81);
  ];
  block %p9open_85 {.address = 0x4011f4; .originalLabel = "NIuxhOjSRRqGZ2L/7CAWsg=="} [
    goto(%p9open_81);
  ];
  block %p9open_87 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0x8:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4011f4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011f4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198900_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x32150021" };
    var var1_4198900_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x32150021" };
    $R1: bv64 := zero_extend(32, bvor(var1_4198900_bv32:bv32, 0x800:bv32)) { .comment = "op: 0x32150021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198904_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x52180042" };
    var var1_4198904_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x52180042" };
    $R2: bv64 := zero_extend(32, bvxor(var1_4198904_bv32:bv32, 0x100:bv32)) { .comment = "op: 0x52180042" };
    goto(%p9open_85);
  ];
  block %p9open_89 {.address = 0x4011f0; .originalLabel = "iK2bk60dT52CQM0YziZaGA=="} [
    assert eq($_PC:bv64, 0x4011f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011f0:bv64)"; .label = "pc-tracking" };
    goto(%p9open_83, %p9open_87);
  ];
  block %p9open_91 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0x7:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4011f0:bv64;
    goto(%p9open_89);
  ];
  block %p9open_93 {.address = 0x4011e8; .originalLabel = "UtiAEBS3ShaMgJuiYgrh3w=="} [
    goto(%p9open_89);
  ];
  block %p9open_95 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R2:bv64), zero_extend(20, 0x7:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4011e8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011e8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198888_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x32100021" };
    var var1_4198888_bv32: bv32 := extract(32, 0, $R1:bv64) { .comment = "op: 0x32100021" };
    $R1: bv64 := zero_extend(32, bvor(var1_4198888_bv32:bv32, 0x10000:bv32)) { .comment = "op: 0x32100021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198892_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x52190042" };
    var var1_4198892_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x52190042" };
    $R2: bv64 := zero_extend(32, bvxor(var1_4198892_bv32:bv32, 0x80:bv32)) { .comment = "op: 0x52190042" };
    goto(%p9open_93);
  ];
  block %p9open_97 {.address = 0x4011e4; .originalLabel = "OixGd8qBRu2iSsiGuPSWWg=="} [
    assert eq($_PC:bv64, 0x4011e4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011e4:bv64)"; .label = "pc-tracking" };
    goto(%p9open_91, %p9open_95);
  ];
  block %p9open_99 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x4:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4011e4:bv64;
    goto(%p9open_97);
  ];
  block %p9open_101 {.address = 0x4011dc; .originalLabel = "O//ewonYTOKSQvUVknJ6Vw=="} [
    goto(%p9open_97);
  ];
  block %p9open_103 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R19:bv64), zero_extend(20, 0x4:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4011dc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4011dc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198876_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x521c0042" };
    var var1_4198876_bv32: bv32 := extract(32, 0, $R2:bv64) { .comment = "op: 0x521c0042" };
    $R2: bv64 := zero_extend(32, bvxor(var1_4198876_bv32:bv32, 0x10:bv32)) { .comment = "op: 0x521c0042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x321702c1" };
    var var1_4198880_bv32: bv32 := extract(32, 0, $R22:bv64) { .comment = "op: 0x321702c1" };
    $R1: bv64 := zero_extend(32, bvor(var1_4198880_bv32:bv32, 0x200:bv32)) { .comment = "op: 0x321702c1" };
    goto(%p9open_101);
  ];
  block %_inlineret_3 [
    goto(%p9open_69);
  ];
  block %FUN_400cf0_entry_45 {.address = 0x400cf0} [
    var R30_begin_FUN_400cf0_4197616_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400cf0:bv64);
    $_PC: bv64 := 0x400cf0:bv64;
    assert eq($_PC:bv64, 0x400cf0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400cf0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197620_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9405611" };
    var var1_4197620_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9405611" };
    var var2_4197620_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9405611" };
    var var2_4197620_bv64_3: bv64 := load le $mem bvadd(var1_4197620_bv64_2:bv64, 0xa8:bv64) 64 { .comment = "op: 0xf9405611" };
    $R17: bv64 := var2_4197620_bv64_3:bv64 { .comment = "op: 0xf9405611" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197624_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x9102a210" };
    var var2_4197624_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x9102a210" };
    var var2_4197624_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x9102a210" };
    $R16: bv64 := bvadd(var2_4197624_bv64_5:bv64, 0xa8:bv64) { .comment = "op: 0x9102a210" };
    var var1_4197628_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400cf0_4197616_1:bv64) { .comment = "R30 = R30_in" };
    call @open64 ();
    goto(%FUN_400cf0_basil_return_1_46);
  ];
  block %FUN_400cf0_basil_return_1_46 [
    goto(%_inlineret_3);
  ];
  block %_inlineret_4 [
    goto(%p9open_45);
  ];
  block %FUN_400c50_entry_49 {.address = 0x400c50} [
    var R30_begin_FUN_400c50_4197456_7: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c50:bv64);
    $_PC: bv64 := 0x400c50:bv64;
    assert eq($_PC:bv64, 0x400c50:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c50:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197460_bv64_8: bv64 := 0x0:bv64 { .comment = "op: 0xf9402e11" };
    var var1_4197460_bv64_8: bv64 := $R16:bv64 { .comment = "op: 0xf9402e11" };
    var var2_4197460_bv64_9: bv64 := 0x0:bv64 { .comment = "op: 0xf9402e11" };
    var var2_4197460_bv64_9: bv64 := load le $mem bvadd(var1_4197460_bv64_8:bv64, 0x58:bv64) 64 { .comment = "op: 0xf9402e11" };
    $R17: bv64 := var2_4197460_bv64_9:bv64 { .comment = "op: 0xf9402e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197464_bv64_10: bv64 := 0x0:bv64 { .comment = "op: 0x91016210" };
    var var2_4197464_bv64_11: bv64 := 0x0:bv64 { .comment = "op: 0x91016210" };
    var var2_4197464_bv64_11: bv64 := $R16:bv64 { .comment = "op: 0x91016210" };
    $R16: bv64 := bvadd(var2_4197464_bv64_11:bv64, 0x58:bv64) { .comment = "op: 0x91016210" };
    var var1_4197468_bv64_12: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c50_4197456_7:bv64) { .comment = "R30 = R30_in" };
    call @close ();
    goto(%FUN_400c50_basil_return_1_50);
  ];
  block %FUN_400c50_basil_return_1_50 [
    goto(%_inlineret_4);
  ];
  block %_inlineret_5 [
    goto(%p9open_49);
  ];
  block %FUN_400cc0_entry_51 {.address = 0x400cc0} [
    var R30_begin_FUN_400cc0_4197568_13: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400cc0:bv64);
    $_PC: bv64 := 0x400cc0:bv64;
    assert eq($_PC:bv64, 0x400cc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400cc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197572_bv64_14: bv64 := 0x0:bv64 { .comment = "op: 0xf9404a11" };
    var var1_4197572_bv64_14: bv64 := $R16:bv64 { .comment = "op: 0xf9404a11" };
    var var2_4197572_bv64_15: bv64 := 0x0:bv64 { .comment = "op: 0xf9404a11" };
    var var2_4197572_bv64_15: bv64 := load le $mem bvadd(var1_4197572_bv64_14:bv64, 0x90:bv64) 64 { .comment = "op: 0xf9404a11" };
    $R17: bv64 := var2_4197572_bv64_15:bv64 { .comment = "op: 0xf9404a11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197576_bv64_16: bv64 := 0x0:bv64 { .comment = "op: 0x91024210" };
    var var2_4197576_bv64_17: bv64 := 0x0:bv64 { .comment = "op: 0x91024210" };
    var var2_4197576_bv64_17: bv64 := $R16:bv64 { .comment = "op: 0x91024210" };
    $R16: bv64 := bvadd(var2_4197576_bv64_17:bv64, 0x90:bv64) { .comment = "op: 0x91024210" };
    var var1_4197580_bv64_18: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400cc0_4197568_13:bv64) { .comment = "R30 = R30_in" };
    call @fcntl64 ();
    goto(%FUN_400cc0_basil_return_1_52);
  ];
  block %FUN_400cc0_basil_return_1_52 [
    goto(%_inlineret_5);
  ];
  block %_inlineret_6 [
    goto(%p9open_25);
  ];
  block %FUN_400cc0_entry_53 {.address = 0x400cc0} [
    var R30_begin_FUN_400cc0_4197568_19: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400cc0:bv64);
    $_PC: bv64 := 0x400cc0:bv64;
    assert eq($_PC:bv64, 0x400cc0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400cc0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197572_bv64_20: bv64 := 0x0:bv64 { .comment = "op: 0xf9404a11" };
    var var1_4197572_bv64_20: bv64 := $R16:bv64 { .comment = "op: 0xf9404a11" };
    var var2_4197572_bv64_21: bv64 := 0x0:bv64 { .comment = "op: 0xf9404a11" };
    var var2_4197572_bv64_21: bv64 := load le $mem bvadd(var1_4197572_bv64_20:bv64, 0x90:bv64) 64 { .comment = "op: 0xf9404a11" };
    $R17: bv64 := var2_4197572_bv64_21:bv64 { .comment = "op: 0xf9404a11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197576_bv64_22: bv64 := 0x0:bv64 { .comment = "op: 0x91024210" };
    var var2_4197576_bv64_23: bv64 := 0x0:bv64 { .comment = "op: 0x91024210" };
    var var2_4197576_bv64_23: bv64 := $R16:bv64 { .comment = "op: 0x91024210" };
    $R16: bv64 := bvadd(var2_4197576_bv64_23:bv64, 0x90:bv64) { .comment = "op: 0x91024210" };
    var var1_4197580_bv64_24: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400cc0_4197568_19:bv64) { .comment = "R30 = R30_in" };
    call @fcntl64 ();
    goto(%FUN_400cc0_basil_return_1_54);
  ];
  block %FUN_400cc0_basil_return_1_54 [
    goto(%_inlineret_6);
  ];
  block %_inlineret_7 {.originalLabel = "Gm2LBR8eQIqjVYYMR43VQg=="} [
    goto(%p9open_17);
  ];
  block %FUN_400bf0_entry_55 {.address = 0x400bf0} [
    var R30_begin_FUN_400bf0_4197360_25: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400bf0:bv64);
    $_PC: bv64 := 0x400bf0:bv64;
    assert eq($_PC:bv64, 0x400bf0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400bf0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197364_bv64_26: bv64 := 0x0:bv64 { .comment = "op: 0xf9401611" };
    var var1_4197364_bv64_26: bv64 := $R16:bv64 { .comment = "op: 0xf9401611" };
    var var2_4197364_bv64_27: bv64 := 0x0:bv64 { .comment = "op: 0xf9401611" };
    var var2_4197364_bv64_27: bv64 := load le $mem bvadd(var1_4197364_bv64_26:bv64, 0x28:bv64) 64 { .comment = "op: 0xf9401611" };
    $R17: bv64 := var2_4197364_bv64_27:bv64 { .comment = "op: 0xf9401611" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197368_bv64_28: bv64 := 0x0:bv64 { .comment = "op: 0x9100a210" };
    var var2_4197368_bv64_29: bv64 := 0x0:bv64 { .comment = "op: 0x9100a210" };
    var var2_4197368_bv64_29: bv64 := $R16:bv64 { .comment = "op: 0x9100a210" };
    $R16: bv64 := bvadd(var2_4197368_bv64_29:bv64, 0x28:bv64) { .comment = "op: 0x9100a210" };
    var var1_4197372_bv64_30: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400bf0_4197360_25:bv64) { .comment = "R30 = R30_in" };
    call @remove ();
    goto(%FUN_400bf0_basil_return_1_56);
  ];
  block %FUN_400bf0_basil_return_1_56 [
    goto(%_inlineret_7);
  ];
  block %p9open_basil_return_1 [
    return ();
  ]
];


proc @p9write_4200816 () -> ()
  { .name = "p9write"; .address = 0x401970; .returnBlock = "p9write_basil_return_1" }
  require eq($_PC:bv64, 0x401970:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %p9write_entry {.address = 0x401970; .originalLabel = "qVvzznzaToayt5BQelE/sg=="} [
    assert eq($_PC:bv64, 0x401970:bv64);
    $_PC: bv64 := 0x401970:bv64;
    assert eq($_PC:bv64, 0x401970:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401970:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200816_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4200816_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4200816_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200820_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100005f" };
    var var2_4200828_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100005f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R2:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100005f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R2:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100005f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100005f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R2:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100005f" };
    goto(%p9write_9, %p9write_35);
  ];
  block %p9write_5 {.address = 0x4019cc; .originalLabel = "GfUJ+CFqT+qZ/+gCf0vyNQ=="} [
    assert eq($_PC:bv64, 0x4019cc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019cc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4200908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4200908_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4200908_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4200908_bv64:bv64, bvshl(var2_4200908_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4200912_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4200912_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4200912_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4200912_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4200912_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4200916_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4200916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4200916_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4200916_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4200916_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4200916_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4200916_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4200916_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4200920_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%p9write_basil_return_1);
  ];
  block %p9write_7 {.address = 0x4019f0; .originalLabel = "Y2arzhdOSMarSpm2af7Mzw=="} [
    goto(%p9write_5);
  ];
  block %p9write_9 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4019f0:bv64;
    assert eq($_PC:bv64, 0x4019f0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019f0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := 0x0:bv64 { .comment = "op: 0xd2800013" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffff6" };
    $_PC: bv64 := 0x4019cc:bv64 { .comment = "op: 0x17fffff6" };
    goto(%p9write_7);
  ];
  block %p9write_11 {.address = 0x4019dc; .originalLabel = "sf3l5+dnQ9ydhRWYgxCfyw=="} [
    goto(%p9write_basil_return_1);
  ];
  block %p9write_13 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4019dc:bv64;
    assert eq($_PC:bv64, 0x4019dc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019dc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4200924_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4200924_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4200924_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4200924_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4200924_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200928_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var1_4200928_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4200928_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e0" };
    var var2_4200928_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e0" };
    $R0: bv64 := bvor(var1_4200928_bv64:bv64, bvshl(var2_4200928_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200932_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4200932_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4200932_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4200932_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4200932_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4200932_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4200936_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4200936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4200936_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4200936_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4200936_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4200936_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4200936_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4200936_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    var var1_4200940_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%p9write_11);
  ];
  block %p9write_15 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9write_31);
  ];
  block %p9write_17 {.address = 0x40199c; .originalLabel = "KGR5PZbkTPCwrPjauEtfJw=="} [
    goto(%p9write_13, %p9write_15);
  ];
  block %p9write_19 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x40199c:bv64;
    assert eq($_PC:bv64, 0x40199c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x40199c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200860_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b000273" };
    var var1_4200860_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b000273" };
    var var2_4200860_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b000273" };
    var var2_4200860_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b000273" };
    $R19: bv64 := bvadd(var1_4200860_bv64:bv64, bvshl(var2_4200860_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0x8b000273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb13029f" };
    var var2_4200864_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb13029f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R20:bv64), sign_extend(64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb13029f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R20:bv64), zero_extend(64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb13029f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb13029f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R20:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb13029f" };
    goto(%p9write_17);
  ];
  block %p9write_21 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := var1_4200904_bv64:bv64;
    goto(%p9write_5);
  ];
  block %p9write_23 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := var2_4200904_bv64:bv64;
    goto(%p9write_5);
  ];
  block %p9write_25 {.address = 0x4019c0; .originalLabel = "GCUQrtnIRxadzLUXAgJJSA=="} [
    goto(%p9write_21, %p9write_23);
  ];
  block %p9write_27 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4019c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019c0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200896_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4200896_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4200896_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4200896_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4200896_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4200896_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200900_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100027f" };
    var var2_4200900_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R19:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R19:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100027f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100027f" };
    var var1_4200904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a801273" };
    var var1_4200904_bv64: bv64 := $R19:bv64 { .comment = "op: 0x9a801273" };
    var var2_4200904_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9a801273" };
    var var2_4200904_bv64: bv64 := $R0:bv64 { .comment = "op: 0x9a801273" };
    goto(%p9write_25);
  ];
  block %p9write_29 {.address = 0x4019b8; .originalLabel = "ySJjH72sSbOn1g4pxkhGbQ=="} [
    assert eq($_PC:bv64, 0x4019b8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019b8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100001f" };
    var var2_4200888_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100001f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100001f" };
    goto(%p9write_19, %p9write_27);
  ];
  block %p9write_31 {.address = 0x4019a8; .originalLabel = "WqscjNEOQJ2B8AZiX2Kguw=="} [
    assert eq($_PC:bv64, 0x4019a8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4019a8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200872_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb130282" };
    var var1_4200872_bv64: bv64 := $R20:bv64 { .comment = "op: 0xcb130282" };
    var var2_4200872_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb130282" };
    var var2_4200872_bv64: bv64 := $R19:bv64 { .comment = "op: 0xcb130282" };
    $R2: bv64 := bvadd(bvadd(var1_4200872_bv64:bv64, bvnot(bvshl(var2_4200872_bv64:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64) { .comment = "op: 0xcb130282" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200876_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b1302c1" };
    var var1_4200876_bv64: bv64 := $R22:bv64 { .comment = "op: 0x8b1302c1" };
    var var2_4200876_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b1302c1" };
    var var2_4200876_bv64: bv64 := $R19:bv64 { .comment = "op: 0x8b1302c1" };
    $R1: bv64 := bvadd(var1_4200876_bv64:bv64, bvshl(var2_4200876_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0x8b1302c1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e0" };
    var var1_4200880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e0" };
    var var2_4200880_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1503e0" };
    var var2_4200880_bv32: bv32 := extract(32, 0, $R21:bv64) { .comment = "op: 0x2a1503e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4200880_bv32:bv32, bvshl(var2_4200880_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1503e0" };
    $R30: bv64 := 0x4019b8:bv64 { .comment = "op: 0x97fffcaf" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97fffcaf" };
    $_PC: bv64 := 0x400c70:bv64 { .comment = "op: 0x97fffcaf" };
    goto(%FUN_400c70_entry_87);
  ];
  block %p9write_33 {.address = 0x401984; .originalLabel = "ytRcCiKTT22uJMcCgZSDJg=="} [
    goto(%p9write_31);
  ];
  block %p9write_35 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x401984:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x401984:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f4" };
    var var1_4200836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f4" };
    var var2_4200836_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0203f4" };
    var var2_4200836_bv64: bv64 := $R2:bv64 { .comment = "op: 0xaa0203f4" };
    $R20: bv64 := bvor(var1_4200836_bv64:bv64, bvshl(var2_4200836_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0203f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R19: bv64 := 0x0:bv64 { .comment = "op: 0xd2800013" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200848_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var1_4200848_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4200848_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f5" };
    var var2_4200848_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f5" };
    $R21: bv64 := zero_extend(32, bvor(var1_4200848_bv32:bv32, bvshl(var2_4200848_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4200852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f6" };
    var var1_4200852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f6" };
    var var2_4200852_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f6" };
    var var2_4200852_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f6" };
    $R22: bv64 := bvor(var1_4200852_bv64:bv64, bvshl(var2_4200852_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f6" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000004" };
    $_PC: bv64 := 0x4019a8:bv64 { .comment = "op: 0x14000004" };
    goto(%p9write_33);
  ];
  block %_inlineret_3 {.originalLabel = "WqscjNEOQJ2B8AZiX2Kguw=="} [
    goto(%p9write_29);
  ];
  block %FUN_400c70_entry_87 {.address = 0x400c70} [
    var R30_begin_FUN_400c70_4197488_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c70:bv64);
    $_PC: bv64 := 0x400c70:bv64;
    assert eq($_PC:bv64, 0x400c70:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c70:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197492_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9403611" };
    var var1_4197492_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9403611" };
    var var2_4197492_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9403611" };
    var var2_4197492_bv64_3: bv64 := load le $mem bvadd(var1_4197492_bv64_2:bv64, 0x68:bv64) 64 { .comment = "op: 0xf9403611" };
    $R17: bv64 := var2_4197492_bv64_3:bv64 { .comment = "op: 0xf9403611" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197496_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x9101a210" };
    var var2_4197496_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x9101a210" };
    var var2_4197496_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x9101a210" };
    $R16: bv64 := bvadd(var2_4197496_bv64_5:bv64, 0x68:bv64) { .comment = "op: 0x9101a210" };
    var var1_4197500_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c70_4197488_1:bv64) { .comment = "R30 = R30_in" };
    call @write ();
    goto(%FUN_400c70_basil_return_1_88);
  ];
  block %FUN_400c70_basil_return_1_88 [
    goto(%_inlineret_3);
  ];
  block %p9write_basil_return_1 [
    return ();
  ]
];


proc @read () -> ()
  { .name = "read" };


proc @cat_4198032 () -> ()
  { .name = "cat"; .address = 0x400e90; .returnBlock = "cat_basil_return_1" }
  require eq($_PC:bv64, 0x400e90:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %cat_entry {.address = 0x400e90; .originalLabel = "OMO2ysIfSmeORBpBsr5OIQ=="} [
    var R30_begin_cat_4198032: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400e90:bv64);
    $_PC: bv64 := 0x400e90:bv64;
    assert eq($_PC:bv64, 0x400e90:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400e90:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R12: bv64 := 0x2030:bv64 { .comment = "op: 0xd284060c" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb2c63ff" };
    var var1_4198036_bv64: bv64 := $R31:bv64 { .comment = "op: 0xcb2c63ff" };
    var var2_4198036_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xcb2c63ff" };
    $R31: bv64 := bvadd(bvadd(var1_4198036_bv64:bv64, bvnot($R12:bv64)), 0x1:bv64) { .comment = "op: 0xcb2c63ff" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x0:bv64) $R29:bv64 64 { .comment = "op: 0xa9007bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0x0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9007bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198044_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198052_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var1_4198052_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198052_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198052_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4198052_bv32:bv32, bvshl(var2_4198052_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xf90013f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f5" };
    var var1_4198060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f5" };
    var var2_4198060_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0103f5" };
    var var2_4198060_bv64: bv64 := $R1:bv64 { .comment = "op: 0xaa0103f5" };
    $R21: bv64 := bvor(var1_4198060_bv64:bv64, bvshl(var2_4198060_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0103f5" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000004" };
    $_PC: bv64 := 0x400ec0:bv64 { .comment = "op: 0x14000004" };
    goto(%cat_33);
  ];
  block %cat_9 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400f04:bv64;
    assert eq($_PC:bv64, 0x400f04:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f04:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var1_4198148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var2_4198148_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var2_4198148_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e1" };
    $R1: bv64 := bvor(var1_4198148_bv64:bv64, bvshl(var2_4198148_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0xb0000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9130a000" };
    var var2_4198156_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9130a000" };
    var var2_4198156_bv64: bv64 := $R0:bv64 { .comment = "op: 0x9130a000" };
    $R0: bv64 := bvadd(var2_4198156_bv64:bv64, 0xc28:bv64) { .comment = "op: 0x9130a000" };
    $R30: bv64 := 0x400f14:bv64 { .comment = "op: 0x94000258" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000258" };
    $_PC: bv64 := 0x401870:bv64 { .comment = "op: 0x94000258" };
    assert eq($R30:bv64, R30_begin_cat_4198032:bv64) { .comment = "R30 = R30_in" };
    call @sysfatal_4200560 ();
    goto(%cat_basil_return_1);
  ];
  block %cat_11 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%cat_33);
  ];
  block %cat_13 {.address = 0x400eb8; .originalLabel = "o6i0yPhaQkOOkRALzNDFRw=="} [
    assert eq($_PC:bv64, 0x400eb8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400eb8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb13001f" };
    var var2_4198072_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb13001f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0:bv64), sign_extend(64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb13001f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0:bv64), zero_extend(64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb13001f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb13001f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R0:bv64, bvnot(bvshl($R19:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb13001f" };
    goto(%cat_9, %cat_11);
  ];
  block %cat_15 {.address = 0x400eb4; .originalLabel = "+nrvjbl4Swe9s4hujeUyOg=="} [
    goto(%cat_13);
  ];
  block %cat_17 [
    guard booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400eb4:bv64;
    assert eq($_PC:bv64, 0x400eb4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400eb4:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x400eb8:bv64 { .comment = "op: 0x940002af" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x940002af" };
    $_PC: bv64 := 0x401970:bv64 { .comment = "op: 0x940002af" };
    call @p9write_4200816 ();
    goto(%cat_15);
  ];
  block %cat_21 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400f18:bv64;
    assert eq($_PC:bv64, 0x400f18:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f18:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var1_4198168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var2_4198168_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1503e1" };
    var var2_4198168_bv64: bv64 := $R21:bv64 { .comment = "op: 0xaa1503e1" };
    $R1: bv64 := bvor(var1_4198168_bv64:bv64, bvshl(var2_4198168_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1503e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x405000:bv64 { .comment = "op: 0xb0000020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91312000" };
    var var2_4198176_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91312000" };
    var var2_4198176_bv64: bv64 := $R0:bv64 { .comment = "op: 0x91312000" };
    $R0: bv64 := bvadd(var2_4198176_bv64:bv64, 0xc48:bv64) { .comment = "op: 0x91312000" };
    $R30: bv64 := 0x400f28:bv64 { .comment = "op: 0x94000253" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000253" };
    $_PC: bv64 := 0x401870:bv64 { .comment = "op: 0x94000253" };
    assert eq($R30:bv64, R30_begin_cat_4198032:bv64) { .comment = "R30 = R30_in" };
    call @sysfatal_4200560 ();
    goto(%cat_basil_return_1);
  ];
  block %cat_23 {.address = 0x400eec; .originalLabel = "8P9I64JjTOWsAHJ6d3mOpQ=="} [
    goto(%cat_basil_return_1);
  ];
  block %cat_25 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x400eec:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400eec:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198124_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9407bfd" };
    var var1_4198124_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x0:bv64) 64 { .comment = "op: 0xa9407bfd" };
    var var2_4198124_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9407bfd" };
    var var2_4198124_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x0:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9407bfd" };
    $R29: bv64 := var1_4198124_bv64:bv64 { .comment = "op: 0xa9407bfd" };
    $R30: bv64 := var2_4198124_bv64:bv64 { .comment = "op: 0xa9407bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R12: bv64 := 0x2030:bv64 { .comment = "op: 0xd284060c" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4198132_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4198132_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4198132_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4198132_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4198132_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198136_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf94013f5" };
    var var1_4198136_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xf94013f5" };
    $R21: bv64 := var1_4198136_bv64:bv64 { .comment = "op: 0xf94013f5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b2c63ff" };
    var var1_4198140_bv64: bv64 := $R31:bv64 { .comment = "op: 0x8b2c63ff" };
    var var2_4198140_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b2c63ff" };
    $R31: bv64 := bvadd(var1_4198140_bv64:bv64, $R12:bv64) { .comment = "op: 0x8b2c63ff" };
    var var1_4198144_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%cat_23);
  ];
  block %cat_27 {.address = 0x400ee8; .originalLabel = "6gd4z9sZT8+bEzkz/a/3Bg=="} [
    goto(%cat_21, %cat_25);
  ];
  block %cat_29 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x400ee8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400ee8:bv64)"; .label = "pc-tracking" };
    goto(%cat_27);
  ];
  block %cat_31 {.address = 0x400ed0; .originalLabel = "w3pj9UwNQs2pMCGjTFrjXw=="} [
    assert eq($_PC:bv64, 0x400ed0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400ed0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var1_4198096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4198096_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa0003f3" };
    var var2_4198096_bv64: bv64 := $R0:bv64 { .comment = "op: 0xaa0003f3" };
    $R19: bv64 := bvor(var1_4198096_bv64:bv64, bvshl(var2_4198096_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa0003f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198100_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100c3e1" };
    $R1: bv64 := bvadd($R31:bv64, 0x30:bv64) { .comment = "op: 0x9100c3e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var1_4198104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4198104_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1303e2" };
    var var2_4198104_bv64: bv64 := $R19:bv64 { .comment = "op: 0xaa1303e2" };
    $R2: bv64 := bvor(var1_4198104_bv64:bv64, bvshl(var2_4198104_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1303e2" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100027f" };
    var var2_4198112_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf100027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R19:bv64), 0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R19:bv64), 0xffffffffffffffff:bv128), 0x1:bv128)))) { .comment = "op: 0xf100027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf100027f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R19:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)) { .comment = "op: 0xf100027f" };
    goto(%cat_17, %cat_29);
  ];
  block %cat_33 {.address = 0x400ec0; .originalLabel = "gCeZg6EMRLqcAFzt7LhqIg=="} [
    assert eq($_PC:bv64, 0x400ec0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400ec0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198080_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9100c3e1" };
    $R1: bv64 := bvadd($R31:bv64, 0x30:bv64) { .comment = "op: 0x9100c3e1" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x2000:bv64 { .comment = "op: 0xd2840002" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4198088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198088_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198088_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4198088_bv32:bv32, bvshl(var2_4198088_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $R30: bv64 := 0x400ed0:bv64 { .comment = "op: 0x97ffff85" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff85" };
    $_PC: bv64 := 0x400ce0:bv64 { .comment = "op: 0x97ffff85" };
    goto(%FUN_400ce0_entry_43);
  ];
  block %_inlineret_3 {.originalLabel = "gCeZg6EMRLqcAFzt7LhqIg=="} [
    goto(%cat_31);
  ];
  block %FUN_400ce0_entry_43 {.address = 0x400ce0} [
    var R30_begin_FUN_400ce0_4197600_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400ce0:bv64);
    $_PC: bv64 := 0x400ce0:bv64;
    assert eq($_PC:bv64, 0x400ce0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400ce0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197604_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9405211" };
    var var1_4197604_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9405211" };
    var var2_4197604_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9405211" };
    var var2_4197604_bv64_3: bv64 := load le $mem bvadd(var1_4197604_bv64_2:bv64, 0xa0:bv64) 64 { .comment = "op: 0xf9405211" };
    $R17: bv64 := var2_4197604_bv64_3:bv64 { .comment = "op: 0xf9405211" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197608_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x91028210" };
    var var2_4197608_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x91028210" };
    var var2_4197608_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x91028210" };
    $R16: bv64 := bvadd(var2_4197608_bv64_5:bv64, 0xa0:bv64) { .comment = "op: 0x91028210" };
    var var1_4197612_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400ce0_4197600_1:bv64) { .comment = "R30 = R30_in" };
    call @read ();
    goto(%FUN_400ce0_basil_return_1_44);
  ];
  block %FUN_400ce0_basil_return_1_44 [
    goto(%_inlineret_3);
  ];
  block %cat_basil_return_1 [
    return ();
  ]
];


proc @p9main_4198208 () -> ()
  { .name = "p9main"; .address = 0x400f40; .returnBlock = "p9main_basil_return_1" }
  require eq($_PC:bv64, 0x400f40:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %p9main_entry {.address = 0x400f40; .originalLabel = "FGQT8qmESb6FIwl/znG8jA=="} [
    var R30_begin_p9main_4198208: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400f40:bv64);
    $_PC: bv64 := 0x400f40:bv64;
    assert eq($_PC:bv64, 0x400f40:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f40:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198208_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9bd7bfd" };
    var var1_4198208_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd($R31:bv64, 0xffffffffffffffd0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    store le $stack bvadd(bvadd($R31:bv64, 0xffffffffffffffd0:bv64), 0x8:bv64) $R30:bv64 64 { .comment = "op: 0xa9bd7bfd" };
    $R31: bv64 := bvadd(var1_4198208_bv64:bv64, 0xffffffffffffffd0:bv64) { .comment = "op: 0xa9bd7bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R3: bv64 := 0x420000:bv64 { .comment = "op: 0x90000103" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R2: bv64 := 0x405000:bv64 { .comment = "op: 0xb0000022" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198220_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x910003fd" };
    $R29: bv64 := bvadd($R31:bv64, 0x0:bv64) { .comment = "op: 0x910003fd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91318042" };
    var var2_4198224_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91318042" };
    var var2_4198224_bv64: bv64 := $R2:bv64 { .comment = "op: 0x91318042" };
    $R2: bv64 := bvadd(var2_4198224_bv64:bv64, 0xc60:bv64) { .comment = "op: 0x91318042" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198228_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9020462" };
    store le $mem bvadd($R3:bv64, 0x408:bv64) $R2:bv64 64 { .comment = "op: 0xf9020462" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198232_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100041f" };
    var var2_4198232_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x7100041f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffffffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x7100041f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32, 0, $R0:bv64)), 0xfffffffe:bv64), 0x1:bv64)))) { .comment = "op: 0x7100041f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32), 0x0:bv32)) { .comment = "op: 0x7100041f" };
    $NF: bv1 := extract(32, 31, bvadd(bvadd(extract(32, 0, $R0:bv64), 0xfffffffe:bv32), 0x1:bv32)) { .comment = "op: 0x7100041f" };
    goto(%p9main_15, %p9main_49);
  ];
  block %p9main_3 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400fa0:bv64;
    goto(%p9main_41);
  ];
  block %p9main_5 [
    guard boolnot(boolnot(eq($ZF:bv1, 0x1:bv1)));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9main_21);
  ];
  block %p9main_11 {.address = 0x400ff0; .originalLabel = "cjNLFklmS6i14I9ZHdT8hg=="} [
    assert eq($_PC:bv64, 0x400ff0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400ff0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4198384_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4198384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4198384_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4198384_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4198384_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4198384_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4198384_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4198384_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0xd2800000" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x1400004a" };
    $_PC: bv64 := 0x401120:bv64 { .comment = "op: 0x1400004a" };
    assert eq($R30:bv64, R30_begin_p9main_4198208:bv64) { .comment = "R30 = R30_in" };
    call @exits_4198688 ();
    goto(%p9main_basil_return_1);
  ];
  block %p9main_13 {.address = 0x400fe0; .originalLabel = "4YZWxyc8TdCyybK6SdWoDw=="} [
    goto(%p9main_11);
  ];
  block %p9main_15 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400fe0:bv64;
    assert eq($_PC:bv64, 0x400fe0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fe0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0x52800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x405000:bv64 { .comment = "op: 0xb0000021" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9131a021" };
    var var2_4198376_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9131a021" };
    var var2_4198376_bv64: bv64 := $R1:bv64 { .comment = "op: 0x9131a021" };
    $R1: bv64 := bvadd(var2_4198376_bv64:bv64, 0xc68:bv64) { .comment = "op: 0x9131a021" };
    $R30: bv64 := 0x400ff0:bv64 { .comment = "op: 0x97ffffa9" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffffa9" };
    $_PC: bv64 := 0x400e90:bv64 { .comment = "op: 0x97ffffa9" };
    call @cat_4198032 ();
    goto(%p9main_13);
  ];
  block %p9main_17 {.address = 0x400fd4; .originalLabel = "tR01D8ziRuu2mm0YKKj4FA=="} [
    assert eq($_PC:bv64, 0x400fd4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fd4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x0:bv64 { .comment = "op: 0xd2800000" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198360_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var1_4198360_bv64: bv64 := $R31:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4198360_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var2_4198360_bv64: bv64 := load le $stack $R31:bv64 64 { .comment = "op: 0xa8c37bfd" };
    var var3_4198360_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa8c37bfd" };
    var var3_4198360_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .comment = "op: 0xa8c37bfd" };
    $R29: bv64 := var2_4198360_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R30: bv64 := var3_4198360_bv64:bv64 { .comment = "op: 0xa8c37bfd" };
    $R31: bv64 := bvadd(var1_4198360_bv64:bv64, 0x30:bv64) { .comment = "op: 0xa8c37bfd" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000051" };
    $_PC: bv64 := 0x401120:bv64 { .comment = "op: 0x14000051" };
    assert eq($R30:bv64, R30_begin_p9main_4198208:bv64) { .comment = "R30 = R30_in" };
    call @exits_4198688 ();
    goto(%p9main_basil_return_1);
  ];
  block %p9main_19 [
    guard boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1)));
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400fd4:bv64;
    goto(%p9main_17);
  ];
  block %p9main_21 {.address = 0x400fcc; .originalLabel = "hwdDQ/+DQka+FkhMfKRXxA=="} [
    assert eq($_PC:bv64, 0x400fcc:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fcc:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var1_4198348_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x10:bv64) 64 { .comment = "op: 0xa94153f3" };
    var var2_4198348_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa94153f3" };
    var var2_4198348_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) 64 { .comment = "op: 0xa94153f3" };
    $R19: bv64 := var1_4198348_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $R20: bv64 := var2_4198348_bv64:bv64 { .comment = "op: 0xa94153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var1_4198352_bv64: bv64 := load le $stack bvadd($R31:bv64, 0x20:bv64) 64 { .comment = "op: 0xa9425bf5" };
    var var2_4198352_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xa9425bf5" };
    var var2_4198352_bv64: bv64 := load le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) 64 { .comment = "op: 0xa9425bf5" };
    $R21: bv64 := var1_4198352_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    $R22: bv64 := var2_4198352_bv64:bv64 { .comment = "op: 0xa9425bf5" };
    goto(%p9main_17);
  ];
  block %p9main_23 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400fcc:bv64;
    goto(%p9main_21);
  ];
  block %p9main_25 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    goto(%p9main_41);
  ];
  block %p9main_27 {.address = 0x400f98; .originalLabel = "jxCjDrg6RXa23M7DNGGsRA=="} [
    assert eq($_PC:bv64, 0x400f98:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f98:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb15027f" };
    var var2_4198296_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xeb15027f" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R19:bv64), sign_extend(64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb15027f" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R19:bv64), zero_extend(64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12))))), 0x1:bv128)))) { .comment = "op: 0xeb15027f" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xeb15027f" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd($R19:bv64, bvnot(bvshl($R21:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64)) { .comment = "op: 0xeb15027f" };
    goto(%p9main_23, %p9main_25);
  ];
  block %p9main_29 {.address = 0x400f8c; .originalLabel = "qYQ1xp8lRKi5XRLtQIMYPQ=="} [
    assert eq($_PC:bv64, 0x400f8c:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f8c:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002273" };
    var var2_4198284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002273" };
    var var2_4198284_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91002273" };
    $R19: bv64 := bvadd(var2_4198284_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002273" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198288_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var1_4198288_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198288_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a1403e0" };
    var var2_4198288_bv32: bv32 := extract(32, 0, $R20:bv64) { .comment = "op: 0x2a1403e0" };
    $R0: bv64 := zero_extend(32, bvor(var1_4198288_bv32:bv32, bvshl(var2_4198288_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a1403e0" };
    $R30: bv64 := 0x400f98:bv64 { .comment = "op: 0x97ffff2f" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffff2f" };
    $_PC: bv64 := 0x400c50:bv64 { .comment = "op: 0x97ffff2f" };
    goto(%FUN_400c50_entry_47);
  ];
  block %p9main_31 {.address = 0x400f88; .originalLabel = "UjbVI2O6TGqXDxxQpcxSDQ=="} [
    goto(%p9main_29);
  ];
  block %p9main_33 [
    guard eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x400f88:bv64;
    assert eq($_PC:bv64, 0x400f88:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f88:bv64)"; .label = "pc-tracking" };
    $R30: bv64 := 0x400f8c:bv64 { .comment = "op: 0x97ffffc2" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x97ffffc2" };
    $_PC: bv64 := 0x400e90:bv64 { .comment = "op: 0x97ffffc2" };
    call @cat_4198032 ();
    goto(%p9main_31);
  ];
  block %p9main_37 [
    guard boolnot(eq(extract(1, 0, extract(1, 0, bvlshr(extract(32, 0, $R0:bv64), zero_extend(20, 0x1f:bv12)))), 0x0:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x400fb8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fb8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var1_4198328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var2_4198328_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xaa1603e0" };
    var var2_4198328_bv64: bv64 := $R22:bv64 { .comment = "op: 0xaa1603e0" };
    $R0: bv64 := bvor(var1_4198328_bv64:bv64, bvshl(var2_4198328_bv64:bv64, zero_extend(52, 0x0:bv12))) { .comment = "op: 0xaa1603e0" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002273" };
    var var2_4198332_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002273" };
    var var2_4198332_bv64: bv64 := $R19:bv64 { .comment = "op: 0x91002273" };
    $R19: bv64 := bvadd(var2_4198332_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002273" };
    $R30: bv64 := 0x400fc4:bv64 { .comment = "op: 0x9400022c" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x9400022c" };
    $_PC: bv64 := 0x401870:bv64 { .comment = "op: 0x9400022c" };
    assert eq($R30:bv64, R30_begin_p9main_4198208:bv64) { .comment = "R30 = R30_in" };
    call @sysfatal_4200560 ();
    goto(%p9main_basil_return_1);
  ];
  block %p9main_39 {.address = 0x400fac; .originalLabel = "fI3mfVBnRFaPl0HXhhYenA=="} [
    assert eq($_PC:bv64, 0x400fac:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fac:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198316_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var1_4198316_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198316_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x2a0003f4" };
    var var2_4198316_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x2a0003f4" };
    $R20: bv64 := zero_extend(32, bvor(var1_4198316_bv32:bv32, bvshl(var2_4198316_bv32:bv32, zero_extend(20, 0x0:bv12)))) { .comment = "op: 0x2a0003f4" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400261" };
    var var1_4198320_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400261" };
    var var2_4198320_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400261" };
    var var2_4198320_bv64: bv64 := load le $mem bvadd(var1_4198320_bv64:bv64, 0x0:bv64) 64 { .comment = "op: 0xf9400261" };
    $R1: bv64 := var2_4198320_bv64:bv64 { .comment = "op: 0xf9400261" };
    goto(%p9main_33, %p9main_37);
  ];
  block %p9main_41 {.address = 0x400fa0; .originalLabel = "y+ao0dhoQ/KECenKw02nAg=="} [
    assert eq($_PC:bv64, 0x400fa0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400fa0:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198304_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400260" };
    var var1_4198304_bv64: bv64 := $R19:bv64 { .comment = "op: 0xf9400260" };
    var var2_4198304_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9400260" };
    var var2_4198304_bv64: bv64 := load le $mem bvadd(var1_4198304_bv64:bv64, 0x0:bv64) 64 { .comment = "op: 0xf9400260" };
    $R0: bv64 := var2_4198304_bv64:bv64 { .comment = "op: 0xf9400260" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x0:bv64 { .comment = "op: 0x52800001" };
    $R30: bv64 := 0x400fac:bv64 { .comment = "op: 0x94000082" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x94000082" };
    $_PC: bv64 := 0x4011b0:bv64 { .comment = "op: 0x94000082" };
    call @p9open_4198832 ();
    goto(%p9main_39);
  ];
  block %p9main_43 {.address = 0x400f64; .originalLabel = "ULqgO/GRSn+ZWQytjkk0zg=="} [
    goto(%p9main_41);
  ];
  block %p9main_45 [
    guard boolnot(boolnot(booland(eq($NF:bv1, $VF:bv1), eq($ZF:bv1, 0x0:bv1))));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x400f64:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f64:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x20:bv64) $R21:bv64 64 { .comment = "op: 0xa9025bf5" };
    store le $stack bvadd(bvadd($R31:bv64, 0x20:bv64), 0x8:bv64) $R22:bv64 64 { .comment = "op: 0xa9025bf5" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198248_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x51000815" };
    var var2_4198248_bv32: bv32 := 0x0:bv32 { .comment = "op: 0x51000815" };
    var var2_4198248_bv32: bv32 := extract(32, 0, $R0:bv64) { .comment = "op: 0x51000815" };
    $R21: bv64 := zero_extend(32, bvadd(bvadd(var2_4198248_bv32:bv32, 0xfffffffd:bv32), 0x1:bv32)) { .comment = "op: 0x51000815" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004020" };
    var var2_4198252_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91004020" };
    var var2_4198252_bv64: bv64 := $R1:bv64 { .comment = "op: 0x91004020" };
    $R0: bv64 := bvadd(var2_4198252_bv64:bv64, 0x10:bv64) { .comment = "op: 0x91004020" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R22: bv64 := 0x405000:bv64 { .comment = "op: 0xb0000036" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b354c15" };
    var var2_4198260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b354c15" };
    var var2_4198260_bv64: bv64 := $R0:bv64 { .comment = "op: 0x8b354c15" };
    var var3_4198260_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x8b354c15" };
    var var3_4198260_bv64: bv64 := $R21:bv64 { .comment = "op: 0x8b354c15" };
    $R21: bv64 := bvadd(var2_4198260_bv64:bv64, zero_extend(29, bvconcat(extract(32, 0, var3_4198260_bv64:bv64), 0x0:bv3))) { .comment = "op: 0x8b354c15" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9131c2d6" };
    var var2_4198264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x9131c2d6" };
    var var2_4198264_bv64: bv64 := $R22:bv64 { .comment = "op: 0x9131c2d6" };
    $R22: bv64 := bvadd(var2_4198264_bv64:bv64, 0xc70:bv64) { .comment = "op: 0x9131c2d6" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    store le $stack bvadd($R31:bv64, 0x10:bv64) $R19:bv64 64 { .comment = "op: 0xa90153f3" };
    store le $stack bvadd(bvadd($R31:bv64, 0x10:bv64), 0x8:bv64) $R20:bv64 64 { .comment = "op: 0xa90153f3" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4198272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002033" };
    var var2_4198272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0x91002033" };
    var var2_4198272_bv64: bv64 := $R1:bv64 { .comment = "op: 0x91002033" };
    $R19: bv64 := bvadd(var2_4198272_bv64:bv64, 0x8:bv64) { .comment = "op: 0x91002033" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x14000007" };
    $_PC: bv64 := 0x400fa0:bv64 { .comment = "op: 0x14000007" };
    goto(%p9main_43);
  ];
  block %p9main_47 {.address = 0x400f60; .originalLabel = "3YIf1TCFSD+c7pf4I2Xrxw=="} [
    goto(%p9main_19, %p9main_45);
  ];
  block %p9main_49 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x400f60:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400f60:bv64)"; .label = "pc-tracking" };
    goto(%p9main_47);
  ];
  block %_inlineret_3 {.originalLabel = "qYQ1xp8lRKi5XRLtQIMYPQ=="} [
    goto(%p9main_27);
  ];
  block %FUN_400c50_entry_47 {.address = 0x400c50} [
    var R30_begin_FUN_400c50_4197456_1: bv64 := $R30:bv64;
    assert eq($_PC:bv64, 0x400c50:bv64);
    $_PC: bv64 := 0x400c50:bv64;
    assert eq($_PC:bv64, 0x400c50:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x400c50:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R16: bv64 := 0x420000:bv64 { .comment = "op: 0x90000110" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197460_bv64_2: bv64 := 0x0:bv64 { .comment = "op: 0xf9402e11" };
    var var1_4197460_bv64_2: bv64 := $R16:bv64 { .comment = "op: 0xf9402e11" };
    var var2_4197460_bv64_3: bv64 := 0x0:bv64 { .comment = "op: 0xf9402e11" };
    var var2_4197460_bv64_3: bv64 := load le $mem bvadd(var1_4197460_bv64_2:bv64, 0x58:bv64) 64 { .comment = "op: 0xf9402e11" };
    $R17: bv64 := var2_4197460_bv64_3:bv64 { .comment = "op: 0xf9402e11" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4197464_bv64_4: bv64 := 0x0:bv64 { .comment = "op: 0x91016210" };
    var var2_4197464_bv64_5: bv64 := 0x0:bv64 { .comment = "op: 0x91016210" };
    var var2_4197464_bv64_5: bv64 := $R16:bv64 { .comment = "op: 0x91016210" };
    $R16: bv64 := bvadd(var2_4197464_bv64_5:bv64, 0x58:bv64) { .comment = "op: 0x91016210" };
    var var1_4197468_bv64_6: bv64 := 0x0:bv64 { .comment = "op: 0xd61f0220" };
    $BTypeNext: bv2 := 0x1:bv2 { .comment = "op: 0xd61f0220" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd61f0220" };
    $_PC: bv64 := $R17:bv64 { .comment = "op: 0xd61f0220" };
    assert eq($R30:bv64, R30_begin_FUN_400c50_4197456_1:bv64) { .comment = "R30 = R30_in" };
    call @close ();
    goto(%FUN_400c50_basil_return_1_48);
  ];
  block %FUN_400c50_basil_return_1_48 [
    goto(%_inlineret_3);
  ];
  block %p9main_basil_return_1 [
    return ();
  ]
];




prog entry @main_4197696 {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x41ffd0 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x41ffe0 };
      { .name = "__assert_fail"; .offset = 0x4200b0 };
      { .name = "__ctype_b_loc"; .offset = 0x420080 };
      { .name = "__ctype_tolower_loc"; .offset = 0x420038 };
      { .name = "__errno_location"; .offset = 0x4200b8 };
      { .name = "__gmon_start__"; .offset = 0x41ffd8 };
      { .name = "__gmon_start__"; .offset = 0x420060 };
      { .name = "__libc_start_main"; .offset = 0x420018 };
      { .name = "abort"; .offset = 0x420070 };
      { .name = "close"; .offset = 0x420058 };
      { .name = "exit"; .offset = 0x420010 };
      { .name = "fcntl64"; .offset = 0x420090 };
      { .name = "frexp"; .offset = 0x420088 };
      { .name = "getpid"; .offset = 0x420040 };
      { .name = "ldexp"; .offset = 0x420030 };
      { .name = "memccpy"; .offset = 0x420020 };
      { .name = "memcmp"; .offset = 0x420078 };
      { .name = "memmove"; .offset = 0x420000 };
      { .name = "memset"; .offset = 0x420048 };
      { .name = "open64"; .offset = 0x4200a8 };
      { .name = "read"; .offset = 0x4200a0 };
      { .name = "remove"; .offset = 0x420028 };
      { .name = "strcpy"; .offset = 0x420098 };
      { .name = "strerror"; .offset = 0x420050 };
      { .name = "strlen"; .offset = 0x420008 };
      { .name = "write"; .offset = 0x420068 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x41fdc8; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x41ffc8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x405c20; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0x4075e4; .size = 0x0 };
      { .name = "__PRETTY_FUNCTION__.0"; .address = 0x4063c0; .size = 0x48 };
      { .name = "__abi_tag"; .address = 0x4002a8; .size = 0x100 };
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x41fdc0; .size = 0x0 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x41fdb8; .size = 0x0 };
      { .name = "_lock"; .address = 0x420628; .size = 0x40 };
      { .name = "_qlock"; .address = 0x420638; .size = 0x40 };
      { .name = "_qunlock"; .address = 0x420640; .size = 0x40 };
      { .name = "_rlock"; .address = 0x420648; .size = 0x40 };
      { .name = "_rsleep"; .address = 0x420668; .size = 0x40 };
      { .name = "_runlock"; .address = 0x420650; .size = 0x40 };
      { .name = "_rwakeup"; .address = 0x420670; .size = 0x40 };
      { .name = "_syserrstr"; .address = 0x420700; .size = 0x40 };
      { .name = "_sysfatal"; .address = 0x420678; .size = 0x40 };
      { .name = "_unlock"; .address = 0x420630; .size = 0x40 };
      { .name = "_wlock"; .address = 0x420658; .size = 0x40 };
      { .name = "_wunlock"; .address = 0x420660; .size = 0x40 };
      { .name = "argv0"; .address = 0x420408; .size = 0x40 };
      { .name = "completed.0"; .address = 0x420400; .size = 0x8 };
      { .name = "fmtalloc"; .address = 0x420708; .size = 0x2040 };
      { .name = "fmtdoquote"; .address = 0x420b10; .size = 0x40 };
      { .name = "fmtlock"; .address = 0x420b18; .size = 0x20 };
      { .name = "knownfmt"; .address = 0x4200d0; .size = 0xf80 };
      { .name = "onex"; .address = 0x420418; .size = 0x1080 };
      { .name = "onexlock"; .address = 0x420410; .size = 0x20 };
      { .name = "pows10"; .address = 0x405e90; .size = 0x2800 };
      { .name = "special"; .address = 0x406390; .size = 0x180 };
      { .name = "tab1"; .address = 0x4202c0; .size = 0x500 };
      { .name = "tab2"; .address = 0x420360; .size = 0x500 };
      { .name = "xsyserr"; .address = 0x420680; .size = 0x400 }
    ];
    .funcEntries = [
      { .name = "__Inf"; .address = 0x404e70; .size = 0xe0 };
      { .name = "__NaN"; .address = 0x404e30; .size = 0x80 };
      { .name = "__badfmt"; .address = 0x403710; .size = 0x1e0 };
      { .name = "__charfmt"; .address = 0x402860; .size = 0x320 };
      { .name = "__countfmt"; .address = 0x403570; .size = 0x400 };
      { .name = "__efgfmt"; .address = 0x4040f0; .size = 0x69c0 };
      { .name = "__errfmt"; .address = 0x401cc4; .size = 0x380 };
      { .name = "__fixargv0"; .address = 0x401000; .size = 0x20 };
      { .name = "__flagfmt"; .address = 0x4035f0; .size = 0x8e0 };
      { .name = "__fmtFdFlush"; .address = 0x403b30; .size = 0x2e0 };
      { .name = "__fmtcpy"; .address = 0x402320; .size = 0x1760 };
      { .name = "__fmtdispatch"; .address = 0x403830; .size = 0x1360 };
      { .name = "__fmtflush"; .address = 0x401e30; .size = 0x460 };
      { .name = "__fmtlock"; .address = 0x403c40; .size = 0x60 };
      { .name = "__fmtpad"; .address = 0x402104; .size = 0x840 };
      { .name = "__fmtrcpy"; .address = 0x402610; .size = 0x1240 };
      { .name = "__fmtunlock"; .address = 0x403c50; .size = 0x60 };
      { .name = "__ifmt"; .address = 0x402b70; .size = 0x5000 };
      { .name = "__isInf"; .address = 0x404e90; .size = 0x220 };
      { .name = "__isNaN"; .address = 0x404e40; .size = 0x140 };
      { .name = "__needsep"; .address = 0x403be0; .size = 0x300 };
      { .name = "__percentfmt"; .address = 0x402b44; .size = 0x140 };
      { .name = "__rfmtpad"; .address = 0x402210; .size = 0x860 };
      { .name = "__runefmt"; .address = 0x4028c4; .size = 0x3a0 };
      { .name = "__runesfmt"; .address = 0x402b00; .size = 0x220 };
      { .name = "__strfmt"; .address = 0x402a24; .size = 0x220 };
      { .name = "_start"; .address = 0x400d80; .size = 0x1e0 };
      { .name = "canlock"; .address = 0x401330; .size = 0x3a0 };
      { .name = "canqlock"; .address = 0x401450; .size = 0x3a0 };
      { .name = "canrlock"; .address = 0x401570; .size = 0x3c0 };
      { .name = "canwlock"; .address = 0x4016b0; .size = 0x3e0 };
      { .name = "cat"; .address = 0x400e90; .size = 0x580 };
      { .name = "chartorune"; .address = 0x403c60; .size = 0x560 };
      { .name = "dofmt"; .address = 0x401ec0; .size = 0x1220 };
      { .name = "errstr"; .address = 0x401c44; .size = 0x400 };
      { .name = "exitcode"; .address = 0x4011a0; .size = 0x40 };
      { .name = "exits"; .address = 0x401120; .size = 0x3e0 };
      { .name = "fmtfdflush"; .address = 0x403aa0; .size = 0x1a0 };
      { .name = "fmtfdinit"; .address = 0x403ad4; .size = 0x280 };
      { .name = "fmtinstall"; .address = 0x4037f0; .size = 0x1e0 };
      { .name = "fmtlocaleinit"; .address = 0x403b90; .size = 0x280 };
      { .name = "fmtrunestrcpy"; .address = 0x402a70; .size = 0x460 };
      { .name = "fmtstrcpy"; .address = 0x402940; .size = 0x720 };
      { .name = "fmtstrtod"; .address = 0x404f74; .size = 0x4260 };
      { .name = "fprint"; .address = 0x401a00; .size = 0x340 };
      { .name = "fullrune"; .address = 0x403df0; .size = 0x1e0 };
      { .name = "getcallerpc"; .address = 0x401dc0; .size = 0x40 };
      { .name = "lock"; .address = 0x4012d0; .size = 0x2c0 };
      { .name = "main"; .address = 0x400d40; .size = 0x120 };
      { .name = "p9atexit"; .address = 0x401010; .size = 0x4e0 };
      { .name = "p9atexitdont"; .address = 0x4010b0; .size = 0x340 };
      { .name = "p9main"; .address = 0x400f40; .size = 0x5e0 };
      { .name = "p9open"; .address = 0x4011b0; .size = 0x8a0 };
      { .name = "p9write"; .address = 0x401970; .size = 0x440 };
      { .name = "qlock"; .address = 0x4013f4; .size = 0x2c0 };
      { .name = "qunlock"; .address = 0x4014c4; .size = 0x280 };
      { .name = "rerrstr"; .address = 0x401b60; .size = 0x720 };
      { .name = "rlock"; .address = 0x401514; .size = 0x2e0 };
      { .name = "rsleep"; .address = 0x401780; .size = 0x200 };
      { .name = "runelen"; .address = 0x403d80; .size = 0x100 };
      { .name = "runenlen"; .address = 0x403da0; .size = 0x260 };
      { .name = "runetochar"; .address = 0x403d10; .size = 0x360 };
      { .name = "runlock"; .address = 0x4015f0; .size = 0x2c0 };
      { .name = "rwakeup"; .address = 0x4017c0; .size = 0x2a0 };
      { .name = "rwakeupall"; .address = 0x401814; .size = 0x2a0 };
      { .name = "strecpy"; .address = 0x401dd0; .size = 0x2e0 };
      { .name = "sysfatal"; .address = 0x401870; .size = 0x800 };
      { .name = "unlock"; .address = 0x4013a4; .size = 0x280 };
      { .name = "utflen"; .address = 0x403e30; .size = 0x300 };
      { .name = "utfnlen"; .address = 0x403e90; .size = 0x460 };
      { .name = "vfprint"; .address = 0x401a70; .size = 0x340 };
      { .name = "vseprint"; .address = 0x401ae0; .size = 0x3e0 };
      { .name = "werrstr"; .address = 0x401d34; .size = 0x440 };
      { .name = "wlock"; .address = 0x401650; .size = 0x2c0 };
      { .name = "wunlock"; .address = 0x401730; .size = 0x280 }
    ];
    .globalOffsets = [  ]
  };
  .initial_memory = [
  {
    .name = ".interp";
    .address = 0x400238;
    .size = 0x6e;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/y3KURJAIBAAUBfaVkXGcRLS1GyRxO358P0ekrsxn/FYUAy59nxvZa2hT5eQNLpxf7QXdpXJEtjgJgNaH2ZT";
      "HRTyFCtBcFRusFRAsK4FqfBrGOYf/s5yZLx5AbtQp15uAAAA"
    ]
  };
  {
    .name = ".note.ABI-tag";
    .address = 0x4002a8;
    .size = 0x20;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NhYGAQAGJGIHb3C2UAAWYg5mKAAADshLlpIAAAAA==" ]
  };
  {
    .name = ".hash";
    .address = 0x4002c8;
    .size = 0xb8;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/23IWQqAMBAE0XaPa0zc9f73tMD5kgw8pqkg6cGNFQEnKn0XseNAi8v6hsX2BKf05YnWoED9695+h972gBIZ";
      "RszWX0rUu0G4AAAA"
    ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x400380;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x4003a0;
    .size = 0x288;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NgwA6qgVgIi3gzDvFEHOJLcIgH4RBnBGIFLOLbcKh3wyF+FIf4XBziL3GI38Qh/gGHuCwDdvezM2JXz4tD";
      "/BEO87twiPvgEN+LQzwKh/gMHOIlOMR1GLD7Nw2H+m84xAF+UqaxiAIAAA=="
    ]
  };
  {
    .name = ".dynstr";
    .address = 0x400628;
    .size = 0x213;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/32Py27DIBBF+SE/Yjt20mWzqCI1u+wRxmOKggcMxI9+fcFtoy7abuCKOXNmIPR8vdAOLAjpPNjr5aQ0wpW1";
      "CgilYtBInWfWU0o29FdQdbAY0tt4DjBwblbivI0XLNIHEXMOgqRnUhFtAOsqgoOeIIIKMDDcrwZoS5XmxALriABvZBcqSrb8";
      "a42BSQzVrbPn6FUwfbd6rfQMdhMEK1ir7bbPsK3lwBOutIsfCzXUEWReaiSzlR4Ia7X1JAwbUqfTOib+mV5ez88nWqS75hGL";
      "wyOWFclQLpnz2kJWNG7e78a8nGe1N1NR4lEex5XdCtGXRmAiojdhzPK3ukrueEM9Y6Ik3pdE4D0p0ipPyjoL2NMP72E0Ym2X";
      "xi3T3LRztYqlaYq3dh3fj/mE+3+MgvNkV6ZlmofHNvsTjCPJB/vQIuYTAgAA"
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x40083c;
    .size = 0x36;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgYAJDZiBmBGIWKJ8JyodAFgZWFDEAUW68aDYAAAA=" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x400878;
    .size = 0x60;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NkYGQQZmRgEGBgYFAA4ukTp7ExMLAwqAPFQICRgZlBFioPAh1geVYGI6jYFjCfmcEWyofoZ4LrBwCZngcd";
      "YAAAAA=="
    ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x4008d8;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/7vw35EBBBhZGBjYGBDgBpI4H5L4AyRxCSRxABky0ItIAAAA" ]
  };
  {
    .name = ".rela.plt";
    .address = 0x400920;
    .size = 0x240;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/03IKxfBABgA0M/MsXnO+5FEURSdpUVRFEVRFEVRFEXRz3Mk98YbUcZPkkbU4i/jE77g6/ycT/kV3+DXfJPf";
      "8Bm/5XN+x7f4im/ze77DH/guf+R7/Inv82e+4C/8gL/yQ/7Gj/g7P+Yf/IR/8lP+xc/4N7/gP/yS/wLZxSD3QAIAAA=="
    ]
  };
  {
    .name = ".init";
    .address = 0x400b60;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBOnMTBM+Vt9cMUB5vhrAFhEMmoYAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x400b80;
    .size = 0x1a0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/03NoQ3CUBhF4ddHgkCQFoFA0KYCgUAgEAggFZAgEAgEAsEaOCaAFXBMQcIOMEAnqK0h/LeE9IgrvlxxitPj";
      "XjhXRJ9VGebza+Ljd5w0Xv+FgbtEflGG3lVf5aY5hVvmDG6bj3DHfIa75hvcMz/hvjmHU/WD2gP14aH68Eh9eKw+PFEfnqoP";
      "z9SHM/V97aX68Fp9eKM+vFUf3qkP79WHD+r//AUQxD9moAEAAA=="
    ]
  };
  {
    .name = ".text";
    .address = 0x400d40;
    .size = 0x4ec0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/618f3xU1Zn3c++dJANBCPlFCDEzk6BiiluEyS+VzU3CCrtptxJHa3W3mUnQssRuHVH5EWomgLVt7FsHUtmi";
      "H5Ngbc1Udn0xbE3rlgBaW9FdCBXb0lcmCb80WPlNRpLc9/u9dyaZpKi7fd8/8pmZe855zvPj+zznec45N8MNuzqGNQk+KtLi";
      "FHlJnPOD5/DdOyVQPdyw+4VureaQw6m982l/V0ugJxd/xzQJ9Wp6pC9fgsdBU0SelP1FQQ1tNvx9xzC2dOKPY/oMYwY/ST8s";
      "clpOLY7oIp0/wvP4OUUBDUkJKvh04bNMZKBbxNOLMa6TiyM+jDmtKSFRHYc4bmJ/l8i+vKHGg+VTmppdQ+Wbd6N/H8ZWnF4c";
      "qTXHqqNjOd9wwy9NfZxLlkgaaHjV20oDIsXvgW+nBKq9akrpuWQ9Mtywx9TN0agcsb8piRt7jLq5+4YbxKJzu9JxXpOCC2kS";
      "uQA+bSLp/6ZKi0PSBspVyLFXgqps7Alr6QWPYY5z1CGe9WlpIc7XqMqZJ0YMT5MinuEGvYP0z91e3nEhTY9gnmby0KtlhEzb";
      "tc0L3gXaA+Bp9JnzxuDtePZJY4cb/qNDg5x56Et+KwI3BmttasRhE7/TJp7tmngu3KN2ZNhlqVOXYBH6ZXyhsPnQnhtN2RY4";
      "JZgEmfaA95V5EqQcn8f3RjVjIACevaoeUSDHemCKevDhd9uIURTWMkPsPxe8se9uyGjydk9FhwArww17X1gKuvheDRu+5Gq7";
      "MdgBunzO9r9DWww/8fqnPKN6h51bKlKClu4lBN5CGNzShHnTQJe2WJko0xu/JX4dtsgTPeKCjLWGsfPsCOR5dN1m9u0H33mS";
      "1szxhcsXDFbapWsf6JBf2oj6JF8mltHntWibTGibiC/a+neYpx981ukpQR90Wee1B8kX+WgUZcCrWHzVAC8+w/Dk2fWuGpF6";
      "Bd/Zp0wcg+zXS/3F4fJK+oBfn14JfTwEmVbm2YO060Xw8DPwAP0UqJj3HDBKG9FPaidzrox6+JgHOIw4peyQr0IONKrppr0e";
      "QZ9uVS/1ihRS1u+BDu2qQf7vjlh+Tv2M5+cXHbVTNqbmiTp5lC9NKSAvRTZJvWDGkMyCleIsqpCc6t3qjPm1UlIEX55fITOr";
      "a0XH9wx8z8L3B/A9E99Tq/MSpDAMzL+CeYmzgAwWpynLi8+pc4pXavOKiStik3YZbnjd1NERVfx98LX+pNbs3eCzv07WGF/D";
      "n6F1bAUdp4nT9IIGfkcsS5dAqrTND74EzJ6Cj7EtD+Oa8Pe/0OfcUHERefgy9XmF+Xo1tWCUjj4/+Czo/GFC/KC9GNvGdCMh";
      "d3plJDxDIh5FOsPPSfBljHNhzj4T02mhgFp2yJrHwpkVp6Qr/tl/h36nIjth+y4xZRJ3/HjO54vSDMNeo3gHP98HP8qn8HPF";
      "ObOsOd1RmR4Fjd5PGO+Q8bJckV7OeB2t+At19Gm0/1L9LP5L9OMcr5+i/1f9zB6vn7zP0I/YIKdNpnsT//u0EW93+hL1CPXT";
      "jnnix3HOhM/QA8Z2Oa14n+xL/B/gd854XQ0on6yrqFxLJ8r1qfTnjtfdQeUzsdUD+pH/Kf3zypj+gK/OibppMoxCzNvji9Ke";
      "iLPtyqfr9xPnnzdef09/iv6QF0Q+DQ8L3BYtrDWd50kD9B4fpZce8n4G9heUWONfBpZia2isb4zeStCjjJT1/xfNr0Zpuj6B";
      "Zsx+xl77gZOgPbA3KXhqrz34QWIg9f1pgdRYvmdfWBnpbXZ09ObbLf1ifTlfqYzmIKcWJHQMLJDIB9dddX24JrCwty6wsO9r";
      "gYX99YGFR78RWHhsZWDh8VWBhScaAgvzU6Tjmiyl48QMJXKS+gQd0uulXRL17cDYdlHKDvVhzeHvfjzv3ZsQDO9VgmzzYx1+";
      "ZRhrMvhFfvdkRXh+sB9tNltFBD6G/HhBUIe8rSJnKmTj1husGuBJcS4Inh1mrqV3jOaLkDWm25hekYec+R7yw/PIoZFP9XAN";
      "Zx5xMZrnrlSluVVNG3gbOcx6NW3fbpU5VEbBvw0hN8DYKchhuE4yx12ZGthKvMXr3FpDxz/jPBfj1szhhpc63k8IpJ6kDcDX";
      "B5VacECzBQc+r3V8kC+R9/MnXR+eEVgY3lu+vXcWdO3gd9nenw99Xwd9fw76/jz0vQBt067q6KuU4NEZUzuOO6Z1JAjz5v0T";
      "/Pf5Ds0J/Iz6jxo6D3n79qqwixQQSyl21E+wRy9wxN/hJG17IvAFXyuA3P7tyKf4/Go76wDxr0xtvRtyRnOFw+PmY73zHY25";
      "/84O1lezbXKAc3tt+nbWVVYeqYZUfCdN+ESP8ZyUHpuhdRxttHUYn5OIcY90kYeZdvphmskTaqCWsEOPYH6znuH34YZ9VowE";
      "jfh4MS6fVrODUTuHYOeC9RV6pFaVTh25IWOJ4HsN7CuidzlSUEMgr24/+a1q5ZrnHnSIUl8OWVjbtFcUNVsxLCNEO9O+iHnp";
      "t0XHnoPuON6FPNPEpL7ArIkU5MJYZyOCPJg0vJMhG2jEagfS+QboTAadWAz7HL5/0pzL0He44d876PvxMRE2LQhvgK9tUIP3";
      "UFfEIfNnyA+7FvwctYgXsocRMwWyt+GzbwP1rwa/hP650fm3QXbGG86rQgfww67hhjejtQJoAsujNUF07mlRHcTrDT7seefy";
      "mEwWVva8kKJJeswuAfCDWtXkh/26R4ydJgbj+ts0yvuTjtG4hXkHKhODJysTTJ85CZ85ibEfXAe/QbwJF0d9pzkDOrKH+jdn";
      "dvTDR3rhZ/Sj3pvhN2WIX5Xwp8Xwpyr405fgT7fj+9MzOk68IZEvQVekpaQEqp83a7jfj2JcpGZwXA2HWqYSslqx5pcd+ajf";
      "x+olBbWBifXqtdCFBl9o4zpJ/GpaKFb7NJ51lNQlygE+m1gTxesacatAm6d3qXbUqHaJJIpeSv2jNtmXkKJHFg2Vb14mtuQj";
      "8NE6UZPrZGO2Nk+6kMd0tkHHoojbm1jekd7tbi6T9IHnwHdMz5zPO1mPeKda66VV0+6J2l0JfRyNYcMNP4/jRwldqtM6LoGH";
      "LPBFP4vAHuwXRp31A/ydu68cNVtGQdgm7ocVKWwEfn2TJdiSyNo7LVQmMweWwOcyRdZQX09hTKYm7iNPib/tKvEcGVH8qNM8";
      "Ji4alOCSJGm5uEtfY9LY42yO0Zhk9kGs0GaEKqDvHbBb92TpjEzVI6SdZpcgad85bBSGKacq+yRQfvAa8HMH+PoKPrEGBR2g";
      "tTxBPOTvYVVM/VKOQvC0izwlimcXeNoex1M+eOI64gU/ZZoMbLCJ5yhkZrwrHDHc1EfTiroS34r8kjqbBFtFG0Bu5GlRbc0r";
      "8WfSH+Orqnc+4slkxAxRksPzrbxPJKuKMeBSXSV0TIz8KlqjWTKzrns4uh8jmiU38sbgf5p7K2mhPtoA/e6P9mEcYJ9DaO/D";
      "vE20B+atVdV9Auycu0/pIG45P8e9l2Duh4T0M0YsJ0m9Ej8TaVUAk6TH+pNx5Tdm/PiPcfFDTSnvwLrh/2KSeNK5B2HGa6Ug";
      "0xaoToRdYIvpsGFpH/xjl5pe342YXGkjftRQo9gGJkGXyzBvLXRWh3mJiUVi23cf9OpL1SOPgYd7JSHqFzb4xWPZdZCrCXri";
      "HkGbCr9IRbwDzRrQIx51+ExsXs7ZNGR46jAHZa4Urco336qrOKdLtGTf/PH5ecyXovtDqRGz/lZDl/EJXFSfHvWnCbrIGtOF";
      "DT51DGM+SSePANdcB8hfGDrR7dz7UUMOSTR1okvCvnujOtCggw3gcxdob0S9Qr43yobsZaZ900KuqC4oYxj6uA/YqAW9Y9B5";
      "DehRJ5XQyTLIHZub8/qGrJyIc9GfSDuml2UTdELe6iboZFlUj2dH9dFl6iNSb+vIxvOZbj0S3XMJxdbxou78ZsadQcRD+G1R";
      "9j/oXT+UlKK2WqzhmtRnHQxkt0HuUq1xk9cu7q+kSmcn5LqM3OIXkOuSllXAOdHX/wRyPfxIb0I8WWnGpHTEk1kDJ1XmiYjf";
      "h/U1CmS9lAjf18z9wVLkhfvCh2WNd6SsqMwuZ55gfgQdPpYoLQHozvTJl5Xg1fi9EjGBtGN0/2k4GjewpjNOfXsE6/I06eQ8";
      "6dA3+YvN1w7dtoHvQDRWtUNXnZO5ryXJbdDtzATpLNeyqkjrn+HXss6RFssrTL+sX9Rx+XP0zTdM/X9lknT+bGpUD6B7HnpQ";
      "onq4CvJS/8sg31HIFtZsBa1Dip968E2zdGOoykA+YtuyGVLSQv4QA9tBx6cpVW3g7RfRmEXe1iTJTs4dyyXieYrxQz3G66+Q";
      "+hs2RvX3doKlP87PuVXYKgw9yS36pqmJZv1T4N3rbDZUxFy0HUUbeV4OehtzJPWQ6XOzQr2/UIJHj8iaY6DXgP4HzJg4y7TB";
      "HOj/MuOaZunmI7TFdHoIbYGLRhGx+l9xz9Og68CH1vPfxD1/c+SzbRDVSeovJuA9hucZV8A7fWEm9PhlYH0msL7lCli/pDZu";
      "0hPE/eVk6XzoVyXN5p7G1PIO7n32Qx8IvunMRWqv1VerwBfrnPe5V2snNhX4uGbGjBgu+1BPeYEX9keuEXwOuomNWz5i4RI4";
      "NHG5DbZvh+0rgMttsP3P7LLz0+wObHc+Ah4vr0zoIP46HySfmQN94KdpqgTXqrCjhrwK2LsMXzkPW9UYiv8F+N/WTClZCX86";
      "Aj5eiOKvSbXw1xmHv3cTgL+Vf9PxHvSsl+mb1idYeAkAT61Yoyvi/PAnwxYGAvCnV6fSL6z5OuB/xA4x9DHwcwdoPAT8hEHT";
      "FbX5k8TIeQsLr8U9X8y95UHr+S/jnm/8BIzEdBPrV/xJWIJMo1jCd9L/cVx9qYUlGMsZa7P0LiVHj2xTBovz5kqw4vQ3N6k5";
      "EpmNXD0fete80tVbx7MbreBonZTCn7fEcr5FTpm+LEu6UGv750LPPpsecXXnNZ/h+nWFOWoxRz7oxs9D2sxL+hfImluNK9O+";
      "P442+5IGx3FMadyYmHwuYGdcjQe70VcEfsM9C6eWUrQRvkHaX0cet3Gdvlk1z/MknblCt1nPaSHfitoS5hA+wyi8AL8rRz/G";
      "oFtg437kSn3mGZgesfKr9NGa/q4RxhQllJ1g5Xwcs2rQ2MIzF+ZY7M9x8WOqMOYOm0xvf1TffAL6Q3w//Rz3DQMLTN1XjvBZ";
      "oCcDz46gXb1N76KOqdc9AtvdMqZTF+rJXegTr0PuS8R0yPafxeGBNbgPsY36CSuIG17EDeoGeuiHHGr0XKkC/DlEre+GDy4T";
      "fU0dfH4ZdBPWEkLvgj8nnvWhP+pGM5+tnKuv7kd7hSj7KhAD2O9t9KNclI9yUb4peMY5BqM8fZZsv/0M2d6K1p/ECjGg3WXh";
      "RQWWiZkXR8ZjZrhhe0cC8RqXY8ldVq1i8ypLfUV6hPH1x8Ax49EJ5Fi1uXqkNSB+ewp1JDu0eT86Wzf7ta0bpkmR+6Hs1BY1";
      "a76jW/GXXycexu37bh4s1iGHQA5vrkTuELPmOI087fQe1R083LaAZ8unlWmBagm4g4zlOdwXvVu6+hZIRFURb1ciD/uSRH6b";
      "ohcHjMaDqCNWSJ54LizQI0Nazj5Eg65Sc68vI9Rgk5ZLJvYyQpe+gVh3CbFmFeRfGej6gZqeukXNTr34b7ZgFvozh6IeAsl7";
      "t57QckLlyUqq/bT29BD08LCIu2yK+J1p4nk3TQq99ctL7k6S6d0XHSUG1oNa+ObaFHGvgj8F1KtTww3SNfR9NdiqZQ7oC768";
      "9gOux6t0zJmd2vsNvWtWIm2vVAl8qXcD5FmMXC9dCg+DHunGxtXDpoHEnFSRmeb+UrhB77o7aWu2c6a4wyuBTx3PPg/a/O4U";
      "f7cT9TVqceRBk4FRfxi/vbBbL9rL0K5ksd7KDF3UbCEFPOzGfO0JgeofzhD3btRwMgi7FEmkUstK7tOy4aOZ5h7DvYj7V46v";
      "B038lEpWavtVdxV1uaTwxzcMFlfCxnWwcR1s/A/CdUIpoE3gtz3EvAu27YUNfX8N3mBXx48Uvz5HPFNmI7f6tuLvvhafTyr+";
      "NuDG4VX8vmvMuvd0NzBCHBEvh53uYBhjBZgIAxOdHy0uov0uAgfEAM8rsVa1hL9hfb8ravs1eVIYs/k7yNOHgIUtwMKGCVho";
      "m/xH4CDDwsFvc55mfrEqigN9kni0yRNxkGPi4OOPjMKHkHesBRb+kCpugZ7Z/tDsecXeu/Wum0CbOJHV2amUTYHvtKzNSTWA";
      "mZXwWdonAJuQbuC8o4S22nIKuV6dGgzfrgZPtiZ19AMv8yDbydbF+I68d8Bw9wNXxNjdmpasoO7K0pRklfiCPg6hvuxGXpoG";
      "HcTGfAlzNU25rag0QwqP54+32R1Rm9H3WpgDRudOoz4/AC+g2QcaYcxJ2ndrkhzeoHdl4ZPzRC4aW774CbLUXbTq/HHyNMNf";
      "1Kg8zXqXfsFwUxY+p1yUgzJxLspFGckD53rvYlQmjHsGc1KX5v2BOD/wZlp+QKz//qRR2KLOKXYnOYsU1IgVGOPUpLp9pPGg";
      "Q5QV8ifDE4+hFXEYeuNiFEMpgrUwYx8x/QDG+0B3Hj53T7qrePfk24pPaOkF5bOWF/tylhTd6hosLsda74JufZZu18Ti2kKM";
      "icWL84j/TRnLi344UwoTr4Y95o6zR2nMHpyHOHK8qvi92eIhjmYwdgFL3R8iXkTpnQW9Q9BPMu/dJOqljm7Er0uGh7a4hDZR";
      "4DeIPU+rkupBvtzwVb2rUcuuZ9xav/fOjx+HP2yLxi0NGGbcyoAdMLCK+n3cJoV7x8Wre8x4ZcYbYEEGG81Y4jsPvDD+IFbt";
      "PmyY8ccH/puAh/fAB+U6PgU6umVMR4wZsXhxPtbnqvF9iNGYHgdGxjB64vtTr/8nYOnE9//+erlsYfWQmrGPWOV5CtuztBnJ";
      "d0ex+vewKfu+zXX3t4pfULc5woqJGeqY93MQb/ZTX1yfGH8Yb7yYk/O/+raxMxY3VNCI3/OZGCcRw/YzhpHeKC3EMJ7VkCbz";
      "H+49s708br7e6JrH/Me0L+y2iXaNYvzuZDMn8XvPWPr/CduQG7QhN+C6cf9rhmcbcoOK7mub8+N05YCeDuP3XvR9Dn0bmcP2";
      "jPUNom032trRxr2WU2fH2rYwP9OWFEWmAK/JE/EaWBPD68aJNM6M0fi+MX7uU4fH2o5g3FdU0J70Z7S7YrS/jj7fsv2Zf8FX";
      "kgpi2FgWxc+1f96vK9bnHvTZCr0+JFnFjMPUUSxud14sLqbtGbfpVzkT9PVW3xjPmcZ4Wb9weaztDxPaXoxr+z8T2p54b6zt";
      "/MT5zo+1/XiC/t66ONb274YldxjjPwl3sbVz+zBqFeSbtmi+qSIH1lTUKdE1QYvmnDJP76qQu4q3yW1FzF1Q15r7FsR2rbK8";
      "eJuypAjP1nDv7l7w9Rj44j7aW6ghm8zcNL/5T4y3glwjOg7fu7iXoCDXLOtEjLKLh3tNZc9gnU0SzynUtmXIMbvhl2VPiJ/n";
      "TAr4c8k3dyhuYf6YXvYS/BY1zFz2maf4wxzTpvh7FatvnqzcUSarzpanNG11ySpznJ3jXhS/cK6XxN8kMboPme2x+03Wswbz";
      "GeWyfj9o/r40+nud+ZtnPmWIITzbsp6vNp9/GO2XJw+Dj0eifDxith0fpbHW/N03+rvR/P3e6P7HLzvqwNPzNiuft0Xzedam";
      "rCGOoS49+jUpPVYvpZGPec7Es/Cx/F6zydI9Rmt1I2qXOdDTcZGXXnfm8N7lGU3kyTfsi7vq9JzgNidqPWna+qP91zVvdHIP";
      "Xh14AbqZzNpHt35/B78r4T/AXD3vrj3vTAnWSIJ5p63cJhHuDXvRJ2bjE6iZ3rAndemwNZ9dtva4U8efv447KyvgnuI0836B";
      "ec5VsN/ajy+YqphndgXx5zGx+2fx5y1jZ5lqgaM7YdDhts5b7tTEvflaffXLqCkafw5cAU9LoI8F08XdGBJ/O/DXXq13beuT";
      "YBvqm96pg8VKNG60I25okLutiHs8+qb+hMEiZ3JKEfPmXbWC5xIpGjYKzfyGfN+sBI/zzmCrvobz8RyGc3KPnDTaEXtEUCti";
      "HOND4x7k89w7/ZUslVsklTk9bRWbj/vh3NMm/749stSFPmWzxb8Eeq+za8l1ifjrlqWIQ4WbM/WS+D7cs+K9uJbMlq0tk+VA";
      "n43niY/ueC7K988xf2ye7qGkYrjxDj7v5LkHsKIDKwrwUAGcqPvzmiucPANQTGzkRO818vf14N9JbKgWNpzw+7BhdLr4ad5d";
      "LeO9Jv9P4a/t57iPlh53xvt69Jxa3/HcVy2+mH+auta0KoFP9OD3pVkS+TbPbsHXDF0Lyn7UXSKFaeAjPLX8FacKW2L+dszf";
      "m8h50wp03l3FGP6+NEuPMObmI0ZVxtae04ZHB4/S7Wp+HG0PoS/7KbxPAb84YGG25504f4y/74k41hK7A+DluVTc+SSxPmTW";
      "47s6liAG8qyCY69FDE0C/RPdc4M8r09okQ6ehXEfxv6Mwj2/nsR04HYe1nHiF3NYfv3n97cnnjUrAb1DFWUfz5h3C20SqPZN";
      "jt3xiZ5jFuhdHvDQBxvo560zaNLnmSfvgfLOUuy8wYVa6RqsrTasIRvb3EHG9SbECd4VScCz57vdvN+6f5us37ox7A5Cp2cU";
      "e1LHBtmwVdMlYsZStLswlnGyz5xL75ot5vnbdMaGDaB/b5ak7hpS/Muy9LXHklqzHaLVh9/lZ8IKX1xMCdjM+6nujTYJzhau";
      "T6z5lYJy0InePX9JvHOD2y5Y/Md+H4z+zsNc/eChBnNtx3oxG/Q2yszq1iHxvwB/qlmn+e/H85oh1X8D77lkqQXtiJ/UY82U";
      "mQ/yrnr5HEll7ob4mR5rA49rxu6Ejv2+xq6XHr86UB3r9zzm2oW59CdvXcu9PdLfhr+alIwHw1gvkeumetHvVFT/+agbjoLf";
      "xiHlDPn1Dd26uTZdUitk5nxXjqQ1DjnOfJFxYOgLm114Xrd81nyXd+Z80tgAbDXZpHS9XUrNvdNl2fN16y5a6Xqb9cwZ7TeG";
      "qzVn2yCjI+Xhs2HYQeyoc6P9zPNLYgx+pi1ymXvo3BujHbG+DDi5DszWV5dBt1+HD5YNOfzy24BJg+0uPIv6xegdYuY938M4";
      "+HqpqWOM/TBq7zKb+OHfpk2cv65YSzxMHD/xfDCdd/VU1D2gcwpjeS6D9cnN8+rYc/Jm7lv+wjpnb+Bdd8Towegd4PF3z141";
      "6XPvNEOUZodkDKzXeC/gyvN5Vd5btmhYd8VfM+m0q2lV3FN5zeDdFTH3QcOXJbhtxHDfE52fvPDu/AbggLkReY+umdUfRvEg";
      "2mCxY53q/yKwIOvUpfx+QwL1Z+4r7nfesnhY0b25bBO7L5ftL0Je0wf1m4Ku33mH+Hy9IoWjvonnTjw3dbpOvTGZ9Z8mVfFt";
      "Sso/5zqzvLnmuVRaIBVxr4q0vy68z4460dq3Nfur5ANjysEL5zrzKW0xHSOe+LfZrRwntobH7pK3T+Ed0vXZ7ddKCeK7uYaw";
      "9laA4fN7JYhayHPsrSeq+R289Lz+1osPeh+95ukNqtp8FDG3ArFChmo3y7rNVYqdd1GVKuYUzm6Z7j3tKHl5xCg8x/M84M0F";
      "2R9RpTqwZ0Ez3yXYg7+Daloy980qEDOPnjW2eB/VN/N9DNpjvSrNwP+BitM1JXnpUhLAGrzrzQUlY2tb1P7g95yWVkWeY2uJ";
      "hd8dHWp0/5Vyl+foXZmjZ1xi3h/hvqsgPz+5QIbvVG4rciUOFgv3U0+t26Rg/WVdI9K9sD1BWuywPXOF3gTkL3F1s1304Uas";
      "q3+Ere6UlKJ1tXrXw6jHdyUqfvp7W6aydAZ057CLeT64c71ML2aeUu7N/ZwmLbpN3MJYChuCfDB99arBQ4n6pkdAk2v5o2dN";
      "XJv3sJgDcb8wdk+pHzGR9fDJBfrwcMN/vvClQazBOtbgHGsNfjGCNdhurcG8jxHfdiqujWeM5IdxIhs8SaYU8jfX2Uzu16A+";
      "1vGM+9U7wE+Wy5s7GF1vwo9L17JE8djxzLcQvgN7zgKda/BnrEKdXamsWXMTzx753o07eAw1X5kmZ2bKD7eGtZmh4yPGluPA";
      "zLEG6GwrdJYvnl3PKv72NPE8c424W7WE+uRFyG2Qb7tkVnKrptS7fr3opiq0d+J3WEso4H5NK/D7IvTLdatY0qvaZEYy67Uh";
      "NQdjpP7N2eLBuvJSHfSskBd+704PuqQwKHphUNUD1asgm73cZ+qB+1LUQXilGvxHPA+36l0cp8JfXTp8TGpz6WezZHVuWJtV";
      "dRpyKPblufOctbmLwAff9WlIkqVsez+ubRlihvrkMvP73431m85+R+L6rUC/jzeowfNv8L5kdohjrPdEVueac8PHnPALV4k3";
      "12WvzW1VFXMd+Apq64ZKWdqrzSogfhi/Rsz3TbJ5D7jnsCotKc7lubP/CvXdPPGc36sGv1LMs7j00K1YK47DPkeOip+1R35S";
      "oLoSa1hsbN9iiezDeMH447AX9yx9S8SDOHCgTFMHFKy74b0VpQ6Ml3m8y6qX9oFeDffKuBYBG/DrUXqvRGn1gZbvVvPuE+ik";
      "D5TzLqMKn4G8qE+bXYgBZaDRzvULc1FfDpucobzHgJ2aemdJ+HG9SzTpupf57GSZHvOpS4gpMb8q4N5r6liba12szTeYjzZi";
      "7BnQtnCWUF81VTxPawlVfdoM6FILUjfE2rFm6eowdaoFnzpjbDnWrHe58Zw6GQQe6RPEsO4UT6uaU7/CASxricnk8Rnu7a7S";
      "u+BdhYdcc4pfU3NSnxJnkc1mnZdw/t2qpPZiDq5/mRlS5PsqannJqf9eOvGdU1WREqjeo6qT2adGVH8AvrBbdVAy9+7rxe27";
      "s7zjNeRyqP2DXFdfgK2R060x70QCU+EyiRiqlR9cSpSl3I+8CX1rtIwBO2J+PvrynoUT6zGxx75vwSa8r/HFq8QzVKZH2D8L";
      "+N4wQy8ZAj2O/VvaH7GJ5/j98J+PLlg5sPMq6eyHzNkY8/BUPRKj78J67NT00vCQ4R5CLKAvEBsf8/7LzeXm/ZcA27nvqOWE";
      "6Iv3DRtbntnrbC5P5jtdGQPfMe/DZYdi8/ZgzrZJ0sl5OB/3R+hH6xv1zfq+dSWO/eK3Y507puUUME59h7WJljAujryt0l7p";
      "ZtyYDB38izaj/ijikus6rN8bKkqHgAfS+faN4iENA/b+Fujswjqn5IinEXryHV50098VUn+zCoZA+595Fj8hNvFMlnh5GjkB";
      "cUw6D+JZ62LweNkw/Yq2qdDUn/LOZLEi6ZXnHSU1kj2w4Vrx6PBXRxjrCvyAuSJlQt5f+iZrX/BwA/hlDCKNb3NPDDlUb7N1";
      "T+0o7HPLRWPLUdhF1EHzvgDj/JXOpbi+8DyCa4x5j0JVklvwZwB/baeMQu9UC29Yg2ETbWA5dGAz44YSugDdEz/bFeueD/GW";
      "k2jmGGbfXytmvVtKPLSpzI+UcXj7Hup19n0V9TfxxjGWzcW8e0hZ7oDN5WOjsw42Jy32N+8JRfHlHY7Hl3U3dj2eI2cqDTj0";
      "Ei/wl2fewYvdRUkzaZeBrn7Jokua56J63Z5r6ZVycF39EXKQVHzOMvGTU787bHieSs4q+qOkJ2t4fvGIo5jPp+B5q5pQf/9k";
      "8XyQTyypQekuaWZeQdkY24bULOAuvX47eFeicc8Jnvic9E+NGDOWYb6LvA+A2H2sUQ0yrrJeUIENB/eNMqEzYKMsig0XsAFf";
      "Ki1NEv/u/zI8GzCWa/MSfB4DjT7QcCVZNNpBYxdqijbErDbQ4DtAjlfh96DDMw9d+5uP2xEXr0X/H4OmtXalh4hzrjV18M/j";
      "5j0n+iTi42neaUbsNCbymTigT7syn5cbeD6kmXf0P69Ya0T727S5FmR8aALNy4i1y8H/02pC1RDqghbw8QJ18jjWH/jmnHTS";
      "DlTfwrNHxEz6RgNir09TkhlLXa8sumnyLw3Tf7/NPfw4v+i6YPlF9ztG0U3R+BFA/GiCjSoQQ2pAn/fp6Kdzhk3fO3CCvqfJ";
      "T4fg13uia92YrNkD+cp4WYG36YhpiA1JfJ+09F1TZzkFToyjTvkc+CjlPsklPOd5SCzW1Jt3Qax4R35/EN1rCPcaZtxDXRgk";
      "/7RzvJ+w73fRty08hmn2y+BeFXhYHZVVM2PlajNWTvo97A45f/07w+OFnJSLcjIeLY+T77kpV7blK+DhWozxJjEnERMj3PcP";
      "LwYmNK303SFjy2Pcw0YfVzSGUU7Knoex11j6GJfPHEPbbzDuCzy74z3AyRKpnc934mSfDJVv5n0wrrW186XLmYi6kWegvzfc";
      "Rb+fVhSzs37BuufEmLcX89Ty3izoWPdr1X2uKA3erw3bLBrOdw135rtjNE6dH6OxAzRuZb0/bMxgjrN/2NLldabus0ProjKW";
      "RGV7F/GSsZCy5mgzkmnXCxjDO65DWlZBzNan8awffFjY531qrYDxzhsxijaP/Hnb33P9+9goemLEmo9zIbZMZ16u1+eXcD+c";
      "/kL69JnDw/ydUHADPrd8ZL2LHH0fuUdGPjor8rVnrXr2vmfVkY96xLwrpX6X+w569P2Dsrd0c09j/PsJWAvZf8TocYEG6Thf";
      "tOpctpMe++iKuLnHh7l6+A5PeEZ0LwLj4n+7BvVNE/uM3697dXS/Ij36jtXFuPcEpgKrgyseKrkPMmqCOlDLCqmOxoO1y2tX";
      "rxe96JaPzHdJImmrV78S3S+oZ836DsbcwTrWeh+mILY2xurPQutuTEH8uhlrMypnHkjgOaa5xzju/xzwPbDY3epQJr5b9zDH";
      "7lxuQO63rFuWts6GP3HfLEX8XDdqUEeW8w7Xk+uza6aIfz2+5720PruR60SyvtZnF8/ziNmkQTni6byPWNXYKf5AinhOYl1t";
      "DCBPh9/+UzK+v4i1AWPzZou7Jh12KcFcoB9A29v4q8lCTiNWjs6/O0Q6O1WJHJyaUuREvOjdq/A8jHtWBy5Bprzl3hLm/btR";
      "d0Wi73PNZVyYbf1/Bjkqn5+Ya0Bf5rtzXt7lSFfMvfvGV4Aj8LpSzZ1fg/yqI9fSQduCKH+JzOVmFmzHJ/ne/bFh8vg7nh39";
      "JNN/6pLhuQTeqIv+N0tLsAZO5x1YPR3rGugsuWh4Dk3OTGZ7H3T2lC0z+WW229G+OvfB7mxrHsQ8zxTor1aTQu5hMxa5AoX8";
      "HwhbUHcUPgx9tEyVIHUy+j7gBNk+B7p1s2VpXY6kNsKeS0Cv76zhJn0FfBPHhcg3UBeZd+ko7+7z5h6TNZ9eFOR9xu706Hx5";
      "1nxv/4n/R0I/i/qrhz7qhK+V889m7l11mfrO8eV+kr5r06RwpSrzqQOuFbw3EwFf1Fuj2niW+j2U+NTdh9SEZAM6PPIH2437";
      "kGPg0z93yPBwH4VnITcUiOewyOkGLTkYfkMxz/ALeS+iWCJHruVZzIzQH3t+kF2KeNfUuG5zraY0r633vVJu0yNZWnZyhS3Q";
      "tfZP5juPfu5Jou4KPWPulwWqD6k5VVxPFWDZOecP2cgdCq/R1CruQ1Wm6yVOu5KM9Yn5VmEE8Yxjfaq4uYftQptrteP2PIxb";
      "bxjuCNrYbu772SVZ0KagLR81dSVraucfskWUetaXXTKzqlRTk2sQ2ynjWxHD80fI+AxkvPzWE9XPIMYffuvFB29SAql3Jg0W";
      "H91bXtqKdXMJcqQLWmZVJ+rPtkfXbV6POvaxeu8r1MGxOumizJT3ryHvsTrUgzJYtBPrAfvPoT/tUoJHVXtzFurPAHzqWrHt";
      "O6RmJJdqGcmty90lGyS9GXFlE3XDe+hzhiz8BJbXlgh0JM7XKUOysu7mp11DtZtd6wJVTsmexX0D7/K8EtYWfL+iCbl0ndj3";
      "uT627hHloT91VoEx5euaxsYMOUqgj8JMrDuw5Y0F0INbwRqRiliL9eTX1l6khdPuwuAzqI/b3jcKCweMUb+4k3uvqmP+yRFz";
      "nQtuA++/Yw4KfPF3LX7/NtpGHB7Adw1z9+9VSgU22Yi8ptLcz5aqvmI9Uoe1g/aj3SnzFWxYtQHY6Ef87s4Q2F0NbWQ+FcU1";
      "sRzDNTH93fcNz8cfGltifnMI838HdE+eUILnMd/13+Rd3UmoI1CTKdb+BONrol2a/8aumvvMPvTnvkJlCupvW2LztsHGg8wB";
      "HEr6AN9bKJc6rIV1zypFJ3vy4aO99fU7eheePJuH7x826jvEXpcrWb7clOj+0FWy5lm+TxXfn+NjY05dYcwUjBn4hr7jjHZV";
      "6AMtOfRAggQ7lCnN07Aulin6WV1JaZaU7249ptkKTgCPiaf/cfPUB8oP/sr2t832ofKDfVoi8vmpoQrIBN9proAM+fjT7y9v";
      "di1vPKiJFlLvx3o89A8HiY3XkR+xNpg7CfH6fv0s92+6J0kqaBTw3VTB825F9jUlphTvAe8aYj9lEMikQAbGLulHbj2nLleX";
      "coei+3KdOd7c22ELu9Oby/O28AIZ3ozfYdSi8XHtSvVqLK6hFqr/Kcbej/XjmE0vPQE97oP9j8hVA6w1z0DO38iU5g/xeUSZ";
      "NsD7XB9Bbv5eoUxt3mlYWNwD+/1VHE655hbw7rRTgk7o4VcPlDez5iYNxaxNpxZQ/r149vhp3mWeFFKeXJaL2DNjAPRPgf71";
      "amLzm8q0Zt6xm3PJUfyf0+UAzwZjcZMx8zjmYCzrHbHuHqvImTT512dj56S2RTe/w3c3fUONB+sGHzh4jPfRX/3mwa9Bzmux";
      "xpzk7/MVofLT3zxouBvPOmGHE42Pb6qTpObGQceZD6GDjbYVZ7uTxNMqt51xZvDTe4b51RGRFUr0efeE5+VYa9PU05sCKtaK";
      "kYTQ2/w/WOrXno0/o+V55XbkK4ZDHWD+cyKpdWvv6fKQK0VCvCPBfBH54+Qyu36W9MHHJs7F/y/EueQqPJsiO/Om6JuQ+5xp";
      "By3X7yoP1s2RVJ7nelPFnfeW/rJogeraOV94eY+Uv8z3u0PghWfRryfLTpeTceRvN0Huwtpk6ayFXii3b7p4FkWMnS9L+UFT";
      "hoIv7HgG4/7LPBtXQpoqZlttxOiM8RWeYvHlTeannGnj3Vtb61Y7PsmX/XpJJS8LsEblqdLZZ3y/Rzm9e7MMPXjQPKMbqjwo";
      "ItUu+SL8tzX7nIG++9NC1J9cNAon6o/zk68/0+t++d/1lw3PT5ICPSdF2yeg5xiWM6eA8eVTZPoJ0aryzDPUQM/1zl9vLVPk";
      "zPvQvWv2G1tdMikkeKZAxlbuR6VE9XPJcFco0rncZr0XH5Nlzn57KG04IYRcr4X7R8zVTwJvfN/kmgvGzm6xfvdr9hA/+b6J";
      "8H9vQB/LYSfeh+J5W+0UZbpDUc4slkBqP/hTnXu25oka4r0dmb13K/FgnnWBT/KN2iu0ytov67lm2Og0dYx4y/tZ9yqyMw05";
      "Du2GINJSy35oO3bO6LTGQi/g5Wnux4GuqOFNZh2COMM6hOOYC6VZ9UdLNfqZOFLH4ygLbVV850Qd2sQ235Ty7+btV0O3DyWE";
      "pqNtEeeFnCshZ1ikkJgkndqCMRo38z7q3OTb5YGrb3/MGP//iwIiRchrpzmzXLku+HGb2IuUlL/KVc1neeYzUVKK9uz8l2ol";
      "5aXUbZv/9UGXXJdbgT/nHKs9IFlFyiLbNKfdotEtziJBXxV0FPYryct18jlw838Bj2NUwMBOAAA="
    ]
  };
  {
    .name = ".fini";
    .address = 0x405c00;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBP/Vh9ccYA5/hoA8Q4mSxQAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x405c20;
    .size = 0x7a9;
    .readOnly = true;
    .bytes = [
      "H4sIAAAAAAAA/1WVe1RTVxbGbwEpdhwsICBQnMgCEdrAzePmQRsEEkISSAiBEEISkpAEjJBHk4ChBUWKgxWsMsJQW5QYFrUt";
      "grWIPNRRCkoUqo5UpFUqYhREXUAFB3wwc0miU88/v7339+2zz7lr3XvfApyA5bVVpzQoEAqdTqNDyDTaIqU6FxGij0KE6Gwy";
      "YFd0Cqn8TUUmNdj0j/QGWImGc3WoAaHRKtRvtAMqqVJto0auQIDGECNCrTEg9AVarUZnUMiBfI0s70924COtTpMbDQC2TfTv";
      "ADlSgzQfrivVBvgoBdrlHptPrcyHbQCIQmOwEA5PIEqzZXJFzqt9ohz8vx4bR6bEU1/pLg5GOPiBg84O5qgMkTn5BhgRsuUc";
      "fgL5ss06xHoSIjQ3FADUUtu1AFYsy0al2j6azrKPQDoKSEcBTpVqpaHo1XwUhENDyyRCGBQcodBoEA/aQoeOhgjwqUG7DfaB";
      "eAyWgMOgCTYPCkVEg0Q0gQhBIJ7wug1AYYkgCoWDZQwBi8c5pgAAHguBEAGEiDgiGkNAv+7AYex9EAplIwFFtAU4CMIsOyA0";
      "Fk3Aw3UMgYAD8QAOjwLhCPP6HhgsGoXHo/GO3KmOX14I/SHhfNrA9qIMbQLeWDOOPDjGTr6dMXvt3NVr55YFG0vLI2KXedVT";
      "ZmP5jTobFT//vEyE2OQUB3OykIZfprnGXwUz5l49aIa5b13f6WGY2A3zeavIQOkYvqg3lgyYRnbysIVkwMLKVfU0kwFStcSa";
      "cYccU9VuDDzmTWFPjw9b/RMp/7jOdL0yU0p5yrjT74Rsp5w4+GsR2ThFqXba+EF4JSIeckZ3zLWkxTuVL1k//vXz+B2ef4uc";
      "CD0Xv/7G/WdjqLn4qSoTkR8dRg3+wW3X9B4x1Ve9or29cz+1/iI16O43Fqpz8cjU11eXqGXMfp00DpNwF1F0ZdFzc0KAkkfu";
      "9D2UcPywT/jQ5WsJgYz6uYqyt2lNwt7ZMBmJNuHnj38m0tGkprE+4/w3tCLL2qfDP96iJZVc4V+Y9qAfEpJnOvKo9AuYtEdN";
      "rsV0oelEW2j5cbrectiEunePvjfqktu2rADGV/Jt590DUhjnXo4WXpPuZIAltWsSursZ0erR/PwTM4zLF9fsqrgTnBj7wm/L";
      "A7/MxO9I7HEUe1+iF9OaGS3vS+RJDs4ySxYTVZ0u6sO3IpMoT36yWh/Ikrx/eBKYZf0yKaBe21QQeCWpWppTodQ5M+cXNz1w";
      "TiYwdQt77/Zlq5kJz4nup16amX6fWP4dduYGs+HLKKrh6F9Z8gZrs6UyjkXqHx3ujtjKWkWsrVI+O8o6Qh79z473xlnVNb8U";
      "mBt9ktu76F6VSUnJHmvcHw0f25Hsc8DjyGDAyWTBf69fPWt+mHzg7M7xjvj17O2RoTdD6rhs8fOZlOkXu9kBB3H7vX8/x86m";
      "uCx85T3P/pS74uRbgvAUFbfX445RkmIJx6b71dWkfAL1NN8+fTElvydj4C8+AKd/NuJfXwRgOcTWbpUuSMnp54etXJ3XwAkc";
      "6VI8MA9xglkbzzZWuqW2SP9orWqNTl1Vwnvsi9SnJgtbJkULR1JlbSPZBU9HU9dp+0Uruz3TQpKI7ZWbE9IiGirMrXElaSW9";
      "NSEt9B/ThHOL6rW37qfpP+7cvW7/e9xJapvPk5spXPNaya1pzt+5l9YZh5onTnE3eb0vH9DOct1HINLSYEi6J+uzQVKMIH3g";
      "3WsNG9yq05dqLiSAjPPppKhO/un6Z+k5wV6d84dBXulj3w36S3Le2OTB6dUvD/Cqjv80HxZ9lTctwuhPMF0y8iBg33opMeN8";
      "HDCn7NJknAorJYwPNWaEY00XfrOMZECxNKPHc3d+z0bkwykhmT+rW2gKwRr5LXsLV0fGtvIH/b5Xnpkc528yrel7ZPbNTLb4";
      "zR+pZGaiA8FF2tayzG3BxfgA747MQ0jBiuzfHmWWvcggl7gFCRo/jKyp350uqHrnwy4yskpQd78vlVHfIyAhTk4KnZ8KmN/e";
      "DcKWvy8E6ZdrTWipsPhm7Cna9lqhgOM55X/7krBIn3hNOwCIeOzfXZlLWJHKWksbI20R9bWKkEdzTKIC/3YCr/QXkad03FVl";
      "WpnVXMwMprjEZA3flCC5KwxZg55dxu9dv8vazpvw4dJuZx37JzsC2uMlFpy2FpVpaWLdQ9Haxqpt4tC2qOl7vm3iWfHKvNuj";
      "E+LHHQPxvOuBkjlOQ2V6E0dyPLQi4iirAn47Nkbxgs5IXn0PJSL7p22zg1oHjQ6WOrjLQbFYkZML/32A/wFW22ElqQcAAA=="
    ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x4063cc;
    .size = 0x2bc;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/xXRr08bYRzH8e/WY3SDQVnOYRAnKhEVSzYxcaJiAtEsFYiJExWVFRWV9wdMVCCQJwor2Q8KK6RsyXKAQRTW";
      "jG4r7sSyVZDQhAqSD+9Trzzf+97zfJ/P82A586L70OyNmdW2pNAx62Cf2gQTdLelO/QxlzEL0cMOFjHGday9lzaw0JYG6OMY";
      "E1xh39KO5OMAq5hghM4HzsEA3RmzIb7G/EepgSG2cYoJFj/R98gsQh+9z/RhiG1McITBLn2zzIk+TrCCxQ5zYoRnqXvcDwv7";
      "nJtljVV0v0hNbGIP613JHjMH5rFyIJVxgg10DunHAOO0jlN8fiS9ekIeX8kXS9/4nq6/S2/n2D+W/uIUs/PkeCytYvmEfTHC";
      "d1g4JS+sYzet4zD1nHOfksOF1EL/B/NiiKO0PpCuMUB3gfx/SiXMXkp1DHATY4zRHbIv1nCMIdoic6KL/i/ujx18iQNcQ++3";
      "FGCADYwxwtIf3g3zI/JI+674P0ffP+bGGrYwwh7G2Ef3P/9hC70l8rzhvTC+lZxnZvfGfsOYvAIAAA=="
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x406688;
    .size = 0xf60;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/51XXWwUVRTemU7bZbvUIquiVKhaDQ99QK2GBx+6M7PbKW2hIMWqfWgiUR4wWdSYxmBEraYPPJDM7E9/ZtIH";
      "IiioGyWmEhJRF6zIA0l/dttdSGM08YEHHvrg2/U7M3d+di2KTnKzd777nXPPOXPOuXdbQs4jvLM/JI1uE7ZGt4da8L4Fo/IJ";
      "Y8/RYrxxWww/HRjh04xJIf8hrkq/wHcGsCHin+byeNowjhDu8uLNbaZk1cm6qN28Md/syp3EOBTYYxfGKYwRYHkC5OZ8V9z8";
      "OGx9FJb1sbDxYVhOfxAejNy4uTi/0ByKN+3hM0d2FWMBshedPXeaDVZ9T0ZIi0mjTpcOLMzHlxblyM0bJJmgH/6Qv60C7D1T";
      "7S/Z3gl8APh0QKesS0adkhZfhC5uSJLPbN8PQ+YiZA5X+37Q9b0d4wQ44U8ZO1arN5EWM4Jv13nMR8ALB+xqxbgG/I9TjLU7";
      "8i2maAnd3Cf6DrewvgtyMcFeHzAj1gZVDxuNcrohU/8yWb7kmB6cO/rp23eIyIvPGBsK2KeQfX2gO2TVmSBGGMPga+C/Vcvv";
      "8fgJb6Y5E9rHgNwY5AZq5Xo9tuLuQ/wC+Kf+g11r4F//H3Z11IVC0bN3b9cw+B3gD9/ZrkTQrhPgD4E/eme7NG+W9O0qQG7m";
      "7Dr+9/59H+KvgX99Pf4d4tVOBXCuOi9r7OpeL17DkNPO3V28qEZOgH8Y/K6/8X2deXDGwDlQy0l6OntcnVSrq+CfuUu+m+ex";
      "esQHMiGnTvJS0kxaiYSuGoqSllNef6GnD0MFf+ZzxsZr91Cp0fQvLfLoY4lQKmaioPMoVQsEUh0b0Lf6udcrjotmm7V9yClk";
      "qu3zWN/5hbeerzOftZ5R9E7j6UHPFeJVwBv9gn83pTkvmPdb9yX12PNu08FDsZYa4C94v63TzzLCYKAX7AvMd7tTey8NOlJf";
      "Mnbc0TEjmDFrs6Lfa2x60Qs0xTYF3hx4KYfn9kFD8HOvN5gTM+CH815sT9aZT1lPjviNmvphgfbOV/dD2qsC/HCe15/q7KXo";
      "op21blG4eihXoo2hUA78E7W2vbBOXwg5514XZNYgo4q2zIgZtZpkPWJskLMNuXo1Hc40TkjiSxBbLpbc0L1S/UrfYBx6bn8F";
      "H4Sab5CkHHptaVFbN4eUCI6vJnlxifr7NeiY/ZqxaK0O7Z91LC3Cb/IfARw/z9gtx5eU2WxtlCcaJpHMUaNJTkcyG5RsONfY";
      "PyW9W47DhRXPh+YUUYhBBJIhYWVKeqmc/BfilETUV8t9U1JPpEZtU7wMU8YwzsC2yjeMaUHbSIVvm23qG5FqBcp03ZQ0FKmU";
      "402D5crgv9oyXUeae0igxpJKmWpz5wacNbOMHaIckZ0c2cvvD1QHA1j/Y5afLXy9n6/38bTVMEbBe+5bXnNy4FupaXHIv0P0";
      "+VOlOTS/sHjjZsL9eiRi35kK0LUAXSrPZcJKwKIXeC5z7Baw8Qs+j/wJRZAzwHYEcl7jds5SDWK9gHXiUa8RzSesxxW93Xis";
      "N/1o5pGJbZMPT7VOb92d255tE98oFdHRypXlFTfCeZGoQSbJD9vs/cXS7mxbbru4u1jqp4nCgTeLpf30uw/vxOwulqhbB/Si";
      "DmlBbUrQz1CxJMZJoLdYOkoA97cCm8MF3pM4dhvYW8BaBT8GEor5+GX3rsu/GY8BybRjfQbrOa6H9O8C1nGlWsbuFbx7ET4M";
      "jgbOESdn7fuW7N23xNcDzbQnKw0UtawkFwN7TEN+dI6xzuo9ut3+RZxL4IzPeWesfefbH7jHUk7+Bs6lOe8e4tvqn9+2n9Fo";
      "KPSnq4v73gas82fGRgJYJ7DjwKIBTMPLsRpsGC+jwM4FsBSw2FXEJICNAUsBawtgOdIHrI9j1OfPAZu96v+ncP0rAF+9ym0M";
      "9r0D/slu33/B2/KL19+7zLCFTyGpRr3eoC3My/gclLNdeoNRn5Zode/8QsCmjo04TyDvYnTGdAHbcY2xtYBONS1lEGBoOVp1";
      "j6bzOgX+Gvi7Ntr8VcFstbaq6S2ZB2T9IePBRPb+3H1T905vqtdajto573SgBo1UDE1unoiJny6v7JmITW4WL0dWltVaTsDe";
      "CvaYW2asJYDdBlZY5vXOMQkhWgXWGsC2ALu17PcKil8HsB0rjBnB+JGbsu1wVswJB2Gz3zOT/gv9hzsC+WOQ7wvb8tejinlV";
      "sH4WZH1OMH4SlPQVIXNZULIFIfejIE/8IEx+L7yHP3bBNvx2zfuhmvd9098JU5cE8X00e/ziDW2/15mh4tDWa/jlSrez6vhJ";
      "tRa7B3n/K2N0r3brRdXFV926E/d6Nwh3YsesD3Kzv/O7DX/+AuueLw1gDwAA"
    ]
  };
  {
    .name = ".init_array";
    .address = 0x41fdb8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2vgc2AAAQCCK35pCAAAAA==" ]
  };
  {
    .name = ".fini_array";
    .address = 0x41fdc0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/wvgc2AAAQCeXWNvCAAAAA==" ]
  };
  {
    .name = ".dynamic";
    .address = 0x41fdc8;
    .size = 0x200;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/7WPPRKCMBBGF1AE0UoYf5AZSw9hETsOYeENbCk5isewtPQIHsHSxlLCyD6K0LvNy8uXZLOeaC08JZCCRYGX";
      "+Aw/J6bjHJeT+hq9fY8dczyCG3gn3w7yEXz4+t6nsZcf60B9TL4P1UP8Sj7t5/GVCb6CmbgVwJfV/3BNDIsUn8Al3MXG2X9G";
      "xpmjhPGgf2N1norzFu/7vvED+b+rBQsibz0AAgAA"
    ]
  };
  {
    .name = ".got";
    .address = 0x41ffc8;
    .size = 0x20;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/zvx15EBHwAAfm2M+yAAAAA=" ]
  };
  {
    .name = ".got.plt";
    .address = 0x41ffe8;
    .size = 0xd8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4auB2GNA0A6XFuN9gAAAA=" ]
  };
  {
    .name = ".data";
    .address = 0x4200c0;
    .size = 0x340;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/13Pz0oCURgF8JnMtCgZcRGUCyHDwSlwI7gc0P4sWghu3FwZ0mwE0aEIehyXLnuEFvMAPoKP0LJl3/We4doZ";
      "OFx+fpf7HR3n/1fD+dMOd+cV+RruBcYNmgfkG/ItuQunvvFdNg+N78kP5Cd6b5D9EfQbggn8TB7DEfZPaP5C+6bkV3JMfWb0";
      "3pzmi2wOL+l+Qn6D06rxO1xvGn/Q/U8yfy7OaGTmOfyWwEeSA4kPH+NOCz6THEo6sCfJS0K4gjce4XNJQdKHLyRFyRC+xI4Y";
      "dpH9fjq1vX5630rZfvr9tbL9TiRfyvY7lXwr268k2SjbryzZKttP3/lVtp+2h/1/gN5Cp0ADAAA="
    ]
  };
  {
    .name = ".bss";
    .address = 0x420400;
    .size = 0x720;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgGAWjYBSMglEwCkYBOgAANmiqCCAHAAA=" ]
  }
]
} ;
