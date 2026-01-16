memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);
var $CF: bv1;
var $NF: bv1;
var $R0: bv64;
var $R1: bv64;
var $R29: bv64;
var $R30: bv64;
var $R31: bv64;
var $VF: bv1;
var $ZF: bv1;

prog entry @main_1876;

proc @main_1876 () -> ()
  { .name = "main"; .address = 0x754; .returnBlock = "main_basil_return_1" }
[
  block %main_entry {.address = 0x754} [
    $NF: bool := eq(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := neq(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := eq(true, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := neq(true, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := eq(1, true) { .label = "%00000408" };
    $NF: bool := neq(1, true) { .label = "%00000408" };


    $NF: bv1 := intneg(0x1:bv32) { .label = "%00000408" };
    
    $NF: int := intadd(1, 0x1:bv32) { .label = "%00000408" };
    $NF: int := intdiv(1, 0x1:bv32) { .label = "%00000408" };
    $NF: int := intmod(1, 0x1:bv32) { .label = "%00000408" };
    $NF: int := intmul(1, 0x1:bv32) { .label = "%00000408" };
    $NF: int := intsub(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := intlt(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := intle(1, 0x1:bv32) { .label = "%00000408" };

    $NF: bv1 := bvnot(1) { .label = "%0000048" };
    $NF: bv1 := bvneg(1) { .label = "%0000048" };
    $NF: bv64 := zero_extend(32, 2) { .label = "%000003a4$1" };
    $NF: bv64 := sign_extend(32, 2) { .label = "%000003a4$1" };
    $NF: bv1 := extract(32, 31, 2) { .label = "%00000408" };
    
    $NF: bool := bvsle(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvslt(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvsle(0x1:bv64, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvslt(0x1:bv64, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvult(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvule(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvand(1, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvor(true, 0x1:bv32) { .label = "%00000408" };
    $NF: bool := bvadd(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvadd($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvmul(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvmul($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvudiv(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvudiv($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvurem(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvurem($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvshl(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvshl($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvlshr(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvlshr($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvnand(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvnand($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvxor(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvxor($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvsub(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvsub($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvsdiv(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvsdiv($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvsrem(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvsrem($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvsmod(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvsmod($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };
    $NF: bool := bvashr(true, 0x1:bv32) { .label = "%00000408" };
    var #4: bv64 := bvashr($R31:bv64, 0xffffffffffffffe0:bv32) { .label = "%0000035a" };


    var load18: bv32 := load le $mem $R0:bv64 32 { .label = "%000003a4$0" };
    store le $stack #4:bv32 $R29:bv64 64 { .label = "%00000360" };

    goto(%main_23, %main_27);
  ];
  block %main_3 {.address = 0x7a0} [
    $R0: bv64 := 0x20000:bv64 { .label = "%00000428" };
    $R0: bv64 := bvadd($R0:bv64, 0x3c:bv64) { .label = "%0000042e" };
    var load19: bv32 := load le $mem $R0:bv64 32 { .label = "%00000435$0" };
    $R0: bv64 := zero_extend(32, load19:bv32) { .label = "%00000435$1" };
    $R1: bv64 := zero_extend(32, bvadd(extract(32, 0, $R0:bv64), 0x1:bv32)) { .label = "%0000043b" };
    $R0: bv64 := 0x20000:bv64 { .label = "%00000440" };
    $R0: bv64 := bvadd($R0:bv64, 0x3c:bv64) { .label = "%00000446" };
    store le $mem $R0:bv64 extract(32, 0, $R1:bv64) 32 { .label = "%0000044e" };
    goto(%main_19);
  ];
  block %main_5 {.address = 0x794} [
    $R0: bv64 := 0x0:bv64 { .label = "%00000416" };
    $R0: bv64 := bvadd($R0:bv64, 0x820:bv64) { .label = "%0000041c" };
    $R30: bv64 := 0x7a0:bv64 { .label = "%00000421" };
    goto(%main_3);
  ];
  block %main_7 {.address = 0x790} [
    goto(%main_5);
  ];
  block %main_9 [
    guard booltobv1(0x7a0:bv64);
    goto(%main_7);
  ];
  block %main_11 {.address = 0x7f4} [
    $R0: bv64 := 0x0:bv64 { .label = "%0000046b" };
    var load21: bv64 := load le $stack $R31:bv64 64 { .label = "%00000472$0" };
    $R29: bv64 := load21:bv64 { .label = "%00000472$1" };
    var load22: bv64 := load le $stack bvadd($R31:bv64, 0x8:bv64) 64 { .label = "%00000477$0" };
    $R30: bv64 := load22:bv64 { .label = "%00000477$1" };
    $R31: bv64 := bvadd($R31:bv64, 0x20:bv64) { .label = "%0000047b" };
    goto(%main_basil_return_1);
  ];
  block %main_13 {.address = 0x7e4} [
    goto(%main_11);
  ];
  block %main_15 [
    guard eq(bvnot(bvcomp($ZF:bv1, 0x1:bv1)), 0x0:bv1);
    $R0: bv64 := 0x0:bv64 { .label = "%00000459" };
    $R0: bv64 := bvadd($R0:bv64, 0x828:bv64) { .label = "%0000045f" };
    $R30: bv64 := 0x7f4:bv64 { .label = "%00000464" };
    goto(%main_13);
  ];
  block %main_17 {.address = 0x7d0} [
    $R0: bv64 := 0x20000:bv64 { .label = "%000003e3" };
    $R0: bv64 := bvadd($R0:bv64, 0x3c:bv64) { .label = "%000003e9" };
    var load20: bv32 := load le $mem $R0:bv64 32 { .label = "%000003f0$0" };
    $R0: bv64 := zero_extend(32, load20:bv32) { .label = "%000003f0$1" };
    var #6: bv32 := bvadd(extract(32, 0, $R0:bv64), 0xfffffffa:bv32) { .label = "%000003f6" };
    $VF: bv1 := bvnot(bvcomp(sign_extend(1, bvadd(#6:bv32, 0x1:bv32)), bvadd(sign_extend(1, extract(32, 0, $R0:bv64)), 0x1fffffffb:bv33))) { .label = "%000003fb" };
    $CF: bv1 := bvnot(bvcomp(zero_extend(1, bvadd(#6:bv32, 0x1:bv32)), bvadd(zero_extend(1, extract(32, 0, $R0:bv64)), 0xfffffffb:bv33))) { .label = "%00000400" };
    $ZF: bv1 := bvcomp(bvadd(#6:bv32, 0x1:bv32), 0x0:bv32) { .label = "%00000404" };
    goto(%main_9, %main_15);
  ];
  block %main_19 {.address = 0x7c4} [
    $R0: bv64 := 0x0:bv64 { .label = "%000003d0" };
    $R0: bv64 := bvadd($R0:bv64, 0x820:bv64) { .label = "%000003d6" };
    $R30: bv64 := 0x7d0:bv64 { .label = "%000003db" };
    goto(%main_17);
  ];
  block %main_21 {.address = 0x7c0} [
    goto(%main_19);
  ];
  block %main_23 [
    guard neq(bvcomp($ZF:bv1, 0x1:bv1), 0x0:bv1);
    goto(%main_21);
  ];
  block %main_25 {.address = 0x788} [
    goto(%main_5);
  ];
  block %main_27 [
    guard eq(bvcomp($ZF:bv1, 0x1:bv1), 0x0:bv1);
    goto(%main_25);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];


proc @puts_1584 (R0_in:bv32) -> ()
  { .name = "puts"; .address = 0x630 };


prog entry @main_1876 {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x1ffc0 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x1ffe0 };
      { .name = "__cxa_finalize"; .offset = 0x1ffc8 };
      { .name = "__cxa_finalize"; .offset = 0x20008 };
      { .name = "__gmon_start__"; .offset = 0x1ffd0 };
      { .name = "__gmon_start__"; .offset = 0x20010 };
      { .name = "__libc_start_main@GLIBC_2.34"; .offset = 0x20000 };
      { .name = "abort"; .offset = 0x20018 };
      { .name = "puts"; .offset = 0x20020 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x1fdd8; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x1ffb8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x818; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0x918; .size = 0x0 };
      { .name = "__abi_tag"; .address = 0x278; .size = 0x100 };
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x1fdd0; .size = 0x0 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x1fdc8; .size = 0x0 };
      { .name = "completed.0"; .address = 0x20038; .size = 0x8 };
      { .name = "i"; .address = 0x2003c; .size = 0x20 };
      { .name = "x"; .address = 0x20040; .size = 0x20 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x640; .size = 0x1a0 };
      { .name = "main"; .address = 0x754; .size = 0x560 }
    ];
    .globalOffsets = [ [ 0x1fdc8; 0x750 ]; [ 0x1fdd0; 0x700 ]; [ 0x1ffd8; 0x754 ]; [ 0x20030; 0x20030 ] ]
  };
  .initial_memory = [
  {
    .name = ".comment";
    .address = 0x0;
    .size = 0x1e;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/6t39XFjYmRkgAFmhu0MIJ4DG4gHAOusqRweAAAA" ]
  };
  {
    .name = ".interp";
    .address = 0x238;
    .size = 0x1b;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/9PPyUzSz0nRzcnMK63QTUwsSs4wM9ErztczZAAA7nBxrxsAAAA=" ]
  };
  {
    .name = ".note.gnu.build-id";
    .address = 0x254;
    .size = 0x24;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NhYGAQAWJmIHb3C2WY6H6Jx+XupYc5Ty98mfO1++MB10NpAKZMdaUkAAAA" ]
  };
  {
    .name = ".note.ABI-tag";
    .address = 0x278;
    .size = 0x20;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NhYGAQAGJGIHb3C2UAAWYgZmeAAAA9kbzyIAAAAA==" ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x298;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x2b8;
    .size = 0xf0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NgwA2YGbgZdrBiExdn0GBgQhFjA2IhLGb4ArECFnEJIFbCIp6JQ706DvMZcYhX4DAHAKc0Q7vwAAAA"
    ]
  };
  {
    .name = ".dynstr";
    .address = 0x3a8;
    .size = 0x92;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2MoKC0pZoiPz8lMSo4vLkksKonPTczMA4okVyTGp2XmJeZkVqUyJCblF5UwgBTpFefrmTG4+3g6Occb6Rma";
      "w5nGJgzxniG+8SmpRanpmcUlqUUhvs45+XmpIYlJOalAA9Nz8/OgVsRDlGJVCAAewwD6kgAAAA=="
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x43a;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgAAEmBkYGZjAGkQDTRLnfFAAAAA==" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x450;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGLQZWBgEGCAgOkTp7ExMDAzmEPFtoD5TAxOUHkAzM8S2zAAAAA=" ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x480;
    .size = 0xc0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/zvxl5EBBJhZwBRDADuEvoAmzgAVv/EfVTwEKm7AwIQiDuMfgKpnBIrDjAKBE0jirEjiF5DE2ZDEHyCJcyKJ";
      "AwBASa6wwAAAAA=="
    ]
  };
  {
    .name = ".rela.plt";
    .address = 0x540;
    .size = 0x78;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgYGIAASYWBgZmBgTgQBJnRRIXQBJnQxKXQBJnRxJXQBLnQBIHANqSMhh4AAAA" ]
  };
  {
    .name = ".init";
    .address = 0x5b8;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBN1GBim/K0+uOIAc/w1AN316/QYAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x5d0;
    .size = 0x70;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA//tQvX/lBwaGD4L/3H8KPLKfqMAkf01egfkqDAswMkwQZHL4KcDEAJYD89mAfCUkPheQ74TE5wPyk5D4QkB+";
      "E4QPAHQ88URwAAAA"
    ]
  };
  {
    .name = ".text";
    .address = 0x640;
    .size = 0x1c0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/12QsUvDQBjF3+W61UUt6KKX6B8hnby6ZJfstv4HnTuYzi49HMTNRdDOOmSR6uqmWBwcklBFsEOg00HD+d1B";
      "imR4XO7yfu97d8Ln7zuIX3dJXxzjjEud70N9c6gUKDAPNad/DVJmzOWc5M5/Qi2B+5kxWxN+MhWUYwWGEVIoRmtA6yHwOwGi";
      "jJggDXWPmIKzMTwxtVzdHwAve8uzt87a8DxYdi6eyJ8Te1SE+tSx3oq188rB411JXRdN6E3K6OayLRkOXMdZqGNi3IxtqR+o";
      "+wfJR3zczdFeNKUuB8+3//t/0n2qzFQgySjX8QWUABL3DaYAmQDYoLN+yhBZ1gNa7g1AnthXNzSrYq2fNbBe7Rll1f1XNb9o";
      "oT8sTbTyXPtqZD3Uv+r9B2r/ioLAAQAA"
    ]
  };
  {
    .name = ".fini";
    .address = 0x800;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBP/Vh9ccYA5/hoA8Q4mSxQAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x818;
    .size = 0x18;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/2NkYGIAgUwGCEityCxJTeFiAACXQWI1GAAAAA==" ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x830;
    .size = 0x3c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2OUZra2YWBgYANigX///4cA6QQgnQGkJwDpGiB9AUhPANIK////3wKkVYD0CSANAE6je248AAAA"
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x870;
    .size = 0xac;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/xNggADGqiAGlgo5RmkeeQYBIF8CiLf8/f/fBCTpyC4HEtMB4g9AMQOoHpCYAxDz/Pv/3wYqpgDEIUBsARTz";
      "AOvlU5jLMo/ZaTKT3727l/lg+iqAOAWohgWqTwaIe0B6gWJrkPRl3rvLB1XCAACy7vZwrAAAAA=="
    ]
  };
  {
    .name = ".init_array";
    .address = 0x1fdc8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/wtgZwADACESo/UIAAAA" ]
  };
  {
    .name = ".fini_array";
    .address = 0x1fdd0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgZwADAOfhhaAIAAAA" ]
  };
  {
    .name = ".dynamic";
    .address = 0x1fdd8;
    .size = 0x1e0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NkgABdKM0DpXewQmheKJ+BA0JJQrkn/jKCaWlUaQYpKH0BKi+DJv/13/98ED2DCcKHWsOwghlCs8Hsh8pz";
      "QfmToDQ3lJaA0qIMqABqDMOL/xD7ocYwVEBpESjNDqXFobQDK6p4Awuquw9AaU40+3//h/gHpvQflB8A1f8fymeEKvoA5VtB";
      "5X9C+SwMtAEALdclUuABAAA="
    ]
  };
  {
    .name = ".got";
    .address = 0x1ffb8;
    .size = 0x30;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/7vxl5EBHwhhR+UDAF9hzjswAAAA" ]
  };
  {
    .name = ".got.plt";
    .address = 0x1ffe8;
    .size = 0x40;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4usBJHAwCfVpxKQAAAAA==" ]
  };
  {
    .name = ".data";
    .address = 0x20028;
    .size = 0x10;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NggAADBiYwDQAjub4kEAAAAA==" ]
  }
]
} ;
