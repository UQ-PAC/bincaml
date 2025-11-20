memory shared $mem : (bv64 -> bv8);
var $BTypeNext: bv2;
var $CF: bv1;
var $NF: bv1;
var $R0: bv64;
var $R1: bv64;
var $R30: bv64;
var $VF: bv1;
var $ZF: bv1;
var $_PC: bv64;
var $__BranchTaken: bv1;

prog entry @main_4196260;

proc @main_4196260 () -> ()
  { .name = "main"; .address = 0x4007a4; .returnBlock = "main_basil_return_1" }
  require eq($_PC:bv64, 0x4007a4:bv64);
  ensures eq($_PC:bv64, old($R30:bv64));
[
  block %main_entry {.address = 0x4007a4; .originalLabel = "rlVqjjqoR6uHwOYvPCS15g=="} [
    assert eq($_PC:bv64, 0x4007a4:bv64);
    $_PC: bv64 := 0x4007a4:bv64;
    assert eq($_PC:bv64, 0x4007a4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4007a4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x420000:bv64 { .comment = "op: 0x90000100" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4196264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401800" };
    var var1_4196264_bv64: bv64 := $R0:bv64 { .comment = "op: 0xf9401800" };
    var var2_4196264_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9401800" };
    var var2_4196264_bv64: bv64 := load le $mem bvadd(var1_4196264_bv64:bv64, 0x30:bv64) 64 { .comment = "op: 0xf9401800" };
    $R0: bv64 := var2_4196264_bv64:bv64 { .comment = "op: 0xf9401800" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4196268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd142e801" };
    var var2_4196268_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd142e801" };
    var var2_4196268_bv64: bv64 := $R0:bv64 { .comment = "op: 0xd142e801" };
    $R1: bv64 := bvadd(bvadd(var2_4196268_bv64:bv64, 0xfffffffffff45fff:bv64), 0x1:bv64) { .comment = "op: 0xd142e801" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4196272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf1144421" };
    var var2_4196272_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf1144421" };
    var var2_4196272_bv64: bv64 := $R1:bv64 { .comment = "op: 0xf1144421" };
    $VF: bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd(var2_4196272_bv64:bv64, 0xfffffffffffffaee:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, var2_4196272_bv64:bv64), 0xfffffffffffffffffffffffffffffaee:bv128), 0x1:bv128)))) { .comment = "op: 0xf1144421" };
    $CF: bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd(var2_4196272_bv64:bv64, 0xfffffffffffffaee:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, var2_4196272_bv64:bv64), 0xfffffffffffffaee:bv128), 0x1:bv128)))) { .comment = "op: 0xf1144421" };
    $ZF: bv1 := booltobv1(eq(bvadd(bvadd(var2_4196272_bv64:bv64, 0xfffffffffffffaee:bv64), 0x1:bv64), 0x0:bv64)) { .comment = "op: 0xf1144421" };
    $NF: bv1 := extract(64, 63, bvadd(bvadd(var2_4196272_bv64:bv64, 0xfffffffffffffaee:bv64), 0x1:bv64)) { .comment = "op: 0xf1144421" };
    $R1: bv64 := bvadd(bvadd(var2_4196272_bv64:bv64, 0xfffffffffffffaee:bv64), 0x1:bv64) { .comment = "op: 0xf1144421" };
    goto(%main_7, %main_11);
  ];
  block %main_3 {.address = 0x4007c0; .originalLabel = "wK9NYU4TTr+D8gXPiCk+7w=="} [
    assert eq($_PC:bv64, 0x4007c0:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4007c0:bv64)"; .label = "pc-tracking" };
    var var1_4196288_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xd65f03c0" };
    $BTypeNext: bv2 := 0x0:bv2 { .comment = "op: 0xd65f03c0" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0xd65f03c0" };
    $_PC: bv64 := $R30:bv64 { .comment = "op: 0xd65f03c0" };
    goto(%main_basil_return_1);
  ];
  block %main_5 {.address = 0x4007c4; .originalLabel = "Y/R8k4zNQOW7WdsmX6n3Vw=="} [
    goto(%main_3);
  ];
  block %main_7 [
    guard eq($ZF:bv1, 0x1:bv1);
    $__BranchTaken: bv1 := booltobv1(true);
    $_PC: bv64 := 0x4007c4:bv64;
    assert eq($_PC:bv64, 0x4007c4:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4007c4:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R0: bv64 := 0x30:bv64 { .comment = "op: 0xd2800600" };
    $__BranchTaken: bv1 := booltobv1(true) { .comment = "op: 0x17fffffe" };
    $_PC: bv64 := 0x4007c0:bv64 { .comment = "op: 0x17fffffe" };
    goto(%main_5);
  ];
  block %main_9 {.address = 0x4007b8; .originalLabel = "gFBdrsFTRkSCdIsDFMk6qA=="} [
    goto(%main_3);
  ];
  block %main_11 [
    guard boolnot(eq($ZF:bv1, 0x1:bv1));
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    assert eq($_PC:bv64, 0x4007b8:bv64) { .comment = "pc-tracking eq($_PC:bv64, 0x4007b8:bv64)"; .label = "pc-tracking" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    $R1: bv64 := 0x420000:bv64 { .comment = "op: 0x90000101" };
    $_PC: bv64 := bvadd($_PC:bv64, 0x4:bv64) { .label = "pc-tracking" };
    var var1_4196284_bv64: bv64 := 0x0:bv64 { .comment = "op: 0xf9001820" };
    store le $mem bvadd($R1:bv64, 0x30:bv64) $R0:bv64 64 { .comment = "op: 0xf9001820" };
    goto(%main_9);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];




prog entry @main_4196260 {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x41ffd0 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x41ffe0 };
      { .name = "__gmon_start__"; .offset = 0x41ffd8 };
      { .name = "__gmon_start__"; .offset = 0x420008 };
      { .name = "__libc_start_main"; .offset = 0x420000 };
      { .name = "abort"; .offset = 0x420010 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x41fdd8; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x41ffc8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x4007e0; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0x4008f8; .size = 0x0 };
      { .name = "__abi_tag"; .address = 0x4002a8; .size = 0x100 };
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x41fdd0; .size = 0x0 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x41fdc8; .size = 0x0 };
      { .name = "completed.0"; .address = 0x420028; .size = 0x8 };
      { .name = "x"; .address = 0x420030; .size = 0x40 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x400680; .size = 0x1e0 };
      { .name = "main"; .address = 0x4007a4; .size = 0x140 };
      { .name = "square"; .address = 0x400784; .size = 0x100 }
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
      "H4sIAAAAAAAA/y3KSxKDIAwA0F4oRDuIXAdthQwx+AMZT68L1++hUMX9SNsfy0V06thGtnZZi+4lsL8m280lyEAOPNMwgnPb";
      "GIyGLFHSKcAkuYKXDF+lGzAGn4b8e+Htak+q/dy2zzwDbgAAAA=="
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
    .size = 0x2c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NmYGBgA2JmIGYFYhYGBGBEYjMBMQC6hiNOLAAAAA==" ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x4002f8;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x400318;
    .size = 0x90;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4YgVgIi7gzUEIBi3g8DnFhHObk4VAPAM9f5UqQAAAA" ]
  };
  {
    .name = ".dynstr";
    .address = 0x4003a8;
    .size = 0x188;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/32QTW+EIBCG+UOoKLKkx+5hs0n35p0gIiI4bPFjrb++mjZN07S9TWaeeWbyIiG8rZUYJxknMUgLSNYhTujo";
      "JmNIGLq8XJ/PIk/I6assKErBruk4hajThZ64jI1v+AaF6u/SMrkuLrNeFbC1Du8oHjvtfbpbn75vbtY+qCPOc35/3T3QebO1";
      "vByWDmorsTnewFJG1TGKZ3AQHoC9hXnFBmacJzTDjP309mXk1Jm3rFt6BTk0xbKptpGyz8q45sM/RqMUJhTnWU4JIWyf1Omf";
      "9HEXiWt1E42O2thx0rG6nX0AXcnaaySEGQJ8pis+0F/Bd0dvsAiIAQAA"
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x400530;
    .size = 0xc;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgYGJgBEJmIAYAxlt4cwwAAAA=" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x400540;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGKQZGBgEGCAgOkTp7ExMDAzKEPFtoD5TAx6UHkAtunbaDAAAAA=" ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x400570;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/7vw35EBBBhZGBiYGBDgBpI4M5L4AyRxViRxAJnVS1lIAAAA" ]
  };
  {
    .name = ".rela.plt";
    .address = 0x4005b8;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgcGIAASYWBgZGBgTgQBJnRhIXQBJnQRIHAAuoUWpIAAAA" ]
  };
  {
    .name = ".init";
    .address = 0x400600;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBP1GBim/K0+uOIAc/w1AEJr0BgYAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x400620;
    .size = 0x50;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA//tQvX/lBwaGD4L/3H8KPLKfqMAkf01egfkqDAswMkwQZHL4KcDEAJYD89mAfCUkPheQ7wThAwDuTJ1aUAAA";
      "AA=="
    ]
  };
  {
    .name = ".text";
    .address = 0x400680;
    .size = 0x14c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/4WOsWoCQRiE51xJo51CJJDcrXkIkRRZJXB9sI/mNSw8axsPC1uxUuvUwaRNkxhiG5UoQixOrBY8L7MHSZHG";
      "YhjYmW//sR3xcQ5vckEtBUZzofTiEv5KwAfQxuuZL5glTR5F3Q1lk7kCssbH4m46AwJsXK2Ah1kUnZo3kxnB4h89+BZd0q+B";
      "7zFQmZORa1fXyATCGiFhTw33vy+Bl/y+8V5KN1tyX+o8sb8gWw5cfR+ziT82rD8OQ+7epaAz5Kt9VfSAwic3O/Buq30Udyml";
      "w/rz4HfjF/da6/KbvMlu2a2Yu04OOt5y4k0OzONNOaWP9X4AshVwtEwBAAA="
    ]
  };
  {
    .name = ".fini";
    .address = 0x4007cc;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBP/Vh9ccYA5/hoA8Q4mSxQAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x4007e0;
    .size = 0x4;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/2NkYGIAAPvazqsEAAAA" ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x4007e4;
    .size = 0x4c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2OUZrb2YGBg4ADiOf/+/08A0neAdAmQ/gOke4C0zv///xcA6QwgvQWkDkjfANILgPQbIH0ASDMwMjAAAEtQ";
      "eVVMAAAA"
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x400830;
    .size = 0xcc;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/xNggADGqiAGlgo5RmkeeQYBIF8CiE3+/f9vA5J0ZJcTAVI6QJwAFGNhQACQWhcgzgCKGyCJRQBxC0w/ECgA";
      "cQ4Qr4Gpc+RTmMsyj9lpMpPHvbuX+WD6JgDxHiQ7QGJLoPoUkMR2gDBQTAPJLQDLYCHWzAAAAA=="
    ]
  };
  {
    .name = ".init_array";
    .address = 0x41fdc8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2tgd2AAAQBRbub8CAAAAA==" ]
  };
  {
    .name = ".fini_array";
    .address = 0x41fdd0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA//Nhd2AAAQApPO/RCAAAAA==" ]
  };
  {
    .name = ".dynamic";
    .address = 0x41fdd8;
    .size = 0x1f0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/7WPMRKCMBBFAwioaCeDoN7B1i523AaP4VE8gkegoPAYljbM2EAY2Jci9Gzz5uVnk11PSeXwAm9wB1WkJ+zR";
      "JtZOX93dJ57wNSzgh/w8y1e235f32t5UI/94SP4KxCP8iG/xpydMbA5T5VYAv0bm8fESHmAMM/gOtXP+wO0etn8z+783so/m";
      "vsEZV/3wK/nSNQDEnbe18AEAAA=="
    ]
  };
  {
    .name = ".got";
    .address = 0x41ffc8;
    .size = 0x20;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/7vx15EBHwAAlwPV5iAAAAA=" ]
  };
  {
    .name = ".got.plt";
    .address = 0x41ffe8;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4U2Byw0gAsGVjKMAAAAA==" ]
  };
  {
    .name = ".data";
    .address = 0x420018;
    .size = 0x10;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgQAUAVUu77BAAAAA=" ]
  };
  {
    .name = ".bss";
    .address = 0x420028;
    .size = 0x10;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgQAUAVUu77BAAAAA=" ]
  }
]
} ;
