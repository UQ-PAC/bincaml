memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

prog entry @main_2276;

proc @main_2276
  (R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, R31_in:bv64, _PC_in:bv64)
    -> (R0_out:bv64, R17_out:bv64, R1_out:bv64, R29_out:bv64, R30_out:bv64)
  { .name = "main"; .address = 0x8e4; .returnBlock = "main_return" }
[
  block %main_entry {.address = 0x8e4; .originalLabel = "ZLfuz7OtTNOS9GLtqSI1gg=="} [
    store le $stack bvadd(R31_in:bv64, 0xffffffffffffffe0:bv64) R29_in:bv64 64 { .label = "2276_1" };
    store le $stack bvadd(R31_in:bv64, 0xffffffffffffffe8:bv64) R30_in:bv64 64 { .label = "2276_2" };
    var Exp14__5_2_1: bv64 := load le $mem 0x20010:bv64 64 { .label = "1908_0$0" };
    assert true { .comment = "R30 = R30_in" };
    var (R0_3:bv64) := call @malloc (0x1:bv64) { .label = "1916_2" };
    goto(%phi_5);
  ];
  block %phi_5 {.originalLabel = "HVqN0/3+RWiLPKsHRvUqeg==, ZLfuz7OtTNOS9GLtqSI1gg=="} [
    store le $stack bvadd(R31_in:bv64, 0xfffffffffffffff8:bv64) R0_3:bv64 64 { .label = "2292_0" };
    var Exp14__5_21_1: bv64 := load le $stack bvadd(R31_in:bv64, 0xfffffffffffffff8:bv64) 64 { .label = "2296_0$0" };
    store le $mem bvadd(Exp14__5_21_1:bv64, 0x7:bv64) 0x79:bv8 8 { .label = "2308_0" };
    var Exp14__5_22_1: bv64 := load le $stack bvadd(R31_in:bv64, 0xfffffffffffffff8:bv64) 64 { .label = "2312_0$0" };
    var Exp14__5_1_1: bv64 := load le $mem 0x20028:bv64 64 { .label = "1956_0$0" };
    assert true { .comment = "R30 = R30_in" };
    call @#free (Exp14__5_22_1:bv64) { .label = "1964_2" };
    goto(%phi_6);
  ];
  block %phi_6 {.originalLabel = "32fWxY7+R++JNJOFTmT+Sg==, HVqN0/3+RWiLPKsHRvUqeg=="} [
    var Exp16__5_24_1: bv64 := load le $stack bvadd(R31_in:bv64, 0xffffffffffffffe0:bv64) 64 { .label = "2324_0$0" };
    var Exp18__5_25_1: bv64 := load le $stack bvadd(R31_in:bv64, 0xffffffffffffffe8:bv64) 64 { .label = "2324_1$0" };
    goto(%main_return);
  ];
  block %main_return [
    return (0x0:bv64, Exp14__5_1_1:bv64, 0x79:bv64, Exp16__5_24_1:bv64, Exp18__5_25_1:bv64);
  ]
];


proc @malloc (R0_in:bv64) -> (R0_out:bv64)
  { .name = "malloc" };


proc @#free (R0_in:bv64) -> ()
  { .name = "#free" };




prog entry @main_2276 {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x1ffc0 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x1ffe0 };
      { .name = "__cxa_finalize"; .offset = 0x1ffc8 };
      { .name = "__cxa_finalize"; .offset = 0x20008 };
      { .name = "__gmon_start__"; .offset = 0x1ffd0 };
      { .name = "__gmon_start__"; .offset = 0x20018 };
      { .name = "__libc_start_main"; .offset = 0x20000 };
      { .name = "abort"; .offset = 0x20020 };
      { .name = "free"; .offset = 0x20028 };
      { .name = "malloc"; .offset = 0x20010 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x1fdb8; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x1ffb8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x930; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0xa18; .size = 0x0 };
      { .name = "__abi_tag"; .address = 0xa1c; .size = 0x100 };
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x1fdb0; .size = 0x0 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x1fda8; .size = 0x0 };
      { .name = "completed.0"; .address = 0x20040; .size = 0x8 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x7c0; .size = 0x1a0 };
      { .name = "main"; .address = 0x8e4; .size = 0x1c0 }
    ];
    .globalOffsets = [ [ 0x1fda8; 0x8e0 ]; [ 0x1fdb0; 0x88c ]; [ 0x1ffd8; 0x8e4 ]; [ 0x20038; 0x20038 ] ]
  };
  .initial_memory = [
  {
    .name = ".interp";
    .address = 0x238;
    .size = 0x6e;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/y3KSQ7DIAwAwH7IuI0sJJ5j0pKaxQhSVPL75JDzDKpM3H+1f7DFRSg15sIhWiehHMk7T4lKOdxssGXxKzD3";
      "9WsJhiatf4UsOiZsOmAx9ARr8WqY3zfc3ezVvB4nF5QsKG4AAAA="
    ]
  };
  {
    .name = ".hash";
    .address = 0x2a8;
    .size = 0x40;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NmYGDgBmJ2IOYCYg4GTMAMpVmhNBsQswAxJxADAPnRrSlAAAAA" ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x2e8;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x308;
    .size = 0x108;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NgwA2YGbgYBNixiYszGDAwoYjxArEQFjPkGRkYFLCJA7ESFnE2HOZY4zBHD4d6RhziXjjMAQAVCkG3CAEA";
      "AA=="
    ]
  };
  {
    .name = ".dynstr";
    .address = 0x410;
    .size = 0x164;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/32Qy26DMBRE/UM2jzoOdNksqkjNjr11bQwx2NfCQAN8fUGtqi7a7kajozPSkCYaQzw4FzSR0lml5ThBnKQH";
      "i3ujF5CNRXB2MwRUiBM5IDYGJsjr2/XlInOWnb/jEycJ2iUZpxBNMnS55f0A4KHpRGkbv/aqVLzn3q/lMtD2kFGAqO+C0xl7";
      "DA+kzuK80BZnmjOeUiGSHXv+4b1zyIr3TW9rrWv3OBX33ndagC/wvA0+/cfYak2zE8tZupcq+RM8Jom8VjdZm2haO04mVreL";
      "C2gqUM7s37Q+4Ndb8hP9FfwAfvdaCWQBAAA="
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x574;
    .size = 0x16;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgAAEmBkYGZiCEkQCZ8L9vFgAAAA==" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x590;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGIwYWBgEGCAgOkTp7ExMDAz2EHFtoD5TAyeUHkA0/tYujAAAAA=" ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x5c0;
    .size = 0xc0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/1vxl5EBBJhZwBTDAw4IvQFNvAcqfuM/qvgTqLgFAxOKOIx/AKqeESgOlQKDE0jirEjiF5DE2ZHEHyCJcyGJ";
      "AwCxyMi5wAAAAA=="
    ]
  };
  {
    .name = ".rela.plt";
    .address = 0x680;
    .size = 0x90;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/03IKQ4AIBDAwGa5HRKJ5P8vJCg6ciB4IkPi6/qin/qqX/qm3/quP/qhv/tWWaiQAAAA"
    ]
  };
  {
    .name = ".init";
    .address = 0x710;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBPNGBim/K0+uOIAc/w1AEDwxBIYAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x730;
    .size = 0x80;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA//tQvX/lBwaGD4L/3H8KPLKfqMAkf01egfkqDAswMkwQZHL4KcDEAJYD89mAfCUkPheQ74TE5wPyk5D4QkB+";
      "ExJfDMhfBOEDADC+jJiAAAAA"
    ]
  };
  {
    .name = ".text";
    .address = 0x7c0;
    .size = 0x15c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/22PMUvDUBSFz8tzq5DBwaU1ffZHSCZfXN5e3Fv9Gx2Ms0uDg6uLoJmdpbq6VSwIDmmpUtAh0OlCQ3oSqENx";
      "OFzeu+d83BO09XsL8fiA+tJIp9rKrIPkWyPJgBy/TjR3O9RHWd4sqPp/4cQCj1lZ7o90bxKQ85+gMARUojgN5zHwMwJOp2SY";
      "zMkZGblWKbxgUnG2/QZ4PVxdvEW7l1dmFV0/0z9j9iR3cl5nvb9sMXh6KHj3sgHZY77vRaFVOKrvnTuJ6a/5TSspe1R92oi7";
      "fU+Fy4aVYvByv93lk/02XHrHt1V/H5L5VtBEYvy4q4Cwet9xB/I2nDUFlHDbXAEAAA=="
    ]
  };
  {
    .name = ".fini";
    .address = 0x91c;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/5NXYL76t3r/yr/MDBP/Vh9ccYA5/hoA8Q4mSxQAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x930;
    .size = 0x4;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/2NkYGIAAPvazqsEAAAA" ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x934;
    .size = 0x3c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2OUZra2YGBgYAPinn///wcA6TdAOgVIy/z//78CSEcA6R4gvQZIbwDSG4D0ESANAFvEJ7I8AAAA"
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x970;
    .size = 0xac;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/xNggADGqiAGlgo5RmkeeQYBIF8CiE3+/f9vApJ0ZJcDiekAcQNQzACqByTmAMRzgGI2UDEFIA4B4iNAMQ+w";
      "Xj6FuSzzmJ0mM/ndu3uZD6avAoi/ANWwQPXJAHEPED8Bilkg6fO5d5cPqoQBAHnEQFesAAAA"
    ]
  };
  {
    .name = ".note.ABI-tag";
    .address = 0xa1c;
    .size = 0x20;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NhYGAQAGJGIHb3C2UAAWYg5mKAAADshLlpIAAAAA==" ]
  };
  {
    .name = ".init_array";
    .address = 0x1fda8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/3vAwQAGAG+0HdUIAAAA" ]
  };
  {
    .name = ".fini_array";
    .address = 0x1fdb0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/+vhYAADAJsBWVIIAAAA" ]
  };
  {
    .name = ".dynamic";
    .address = 0x1fdb8;
    .size = 0x200;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/62QvRGCQBBG91TQ82fGQAd/sAtLsQRzEwuwBMogtATKITQxYBw5B/ZtcMRu8uax97G350TrDE/wApdwPVWu";
      "8Nwr93j5dT2P+Awe4JN+PuhPLD9Svttw61jjic3nYGr5sXKOX/X3ssB3cCtxEZM6aIAxUsANZF3J4CONv1dJvEcF/WD+J+g+";
      "drTFC/IB5/rywu/0G9ze6d/1AxafZfIAAgAA"
    ]
  };
  {
    .name = ".got";
    .address = 0x1ffb8;
    .size = 0x30;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/9vxl5EBH3jCgcoHABiL2HUwAAAA" ]
  };
  {
    .name = ".got.plt";
    .address = 0x1ffe8;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4M2EmjAVzvZFpIAAAA" ]
  };
  {
    .name = ".data";
    .address = 0x20030;
    .size = 0x10;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NggAALBiYwDQCWolv3EAAAAA==" ]
  };
  {
    .name = ".bss";
    .address = 0x20040;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NggAAAad8iZQgAAAA=" ]
  }
]
} ;

