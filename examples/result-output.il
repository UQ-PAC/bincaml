memory shared $mem : (bv64 -> bv8);
var $Global_131120_131124: bv32;
var $Global_131124_131128: bv32;
var $Global_131128_131132: bv32;

prog entry @main_2148;

proc @main_2148
  (R0_in:bv64, R1_in:bv64, R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, _PC_in:bv64)
    -> (R0_out:bv64, R1_out:bv64, R29_out:bv64, R2_out:bv64)
  { .name = "main"; .address = 0x864; .returnBlock = "main_return" }
[
  block %main_entry {.address = 0x864; .originalLabel = "TxTRm4kpQiq/Xgistx+xbQ=="} [
    var Stack_n16_n8: bv64 := R29_in:bv64;
    var Stack_n8_0: bv64 := R30_in:bv64;
    $Global_131124_131128: bv32 := 0x2:bv32;
    var var2_2340_bv32_1: bv32 := $Global_131120_131124:bv32;
    var var2_2372_bv32_1: bv32 := $Global_131124_131128:bv32;
    var a:bv32 := var2_2372_bv32_1: bv32;
    store le $mem a:bv32 0x0:bv64 64 { .comment = "op: 0xf900267f" };
    $Global_131124_131128:bv32 := a: bv32;
    var R2_3: bv64 := zero_extend(32, var2_2372_bv32_1:bv32);
    var var2_2404_bv32_1: bv32 := extract(32, 0, $Global_131128_131132:bv32);
    var var2_2404_bv32_1: bv32 := extract(33, 0, $Global_131128_131132:bv32);
    var R1_3: bv64 := zero_extend(32, var2_2404_bv32_1:bv32);
    var R0_4: bv32 := bvadd(var2_2340_bv32_1:bv32, bvshl(var2_2372_bv32_1:bv32, 0x0:bv32));
    var R0_5: bv64 := zero_extend(32, bvadd(R0_4:bv32, bvshl(var2_2404_bv32_1:bv32, 0x0:bv32)));
    var var2_2500_bv64_1: bv64 := Stack_n16_n8:bv64;
    var var3_2500_bv64_1: bv64 := Stack_n8_0:bv64;
    goto(%main_return);
  ];
  block %main_return [
    assert eq(R30_in:bv64, var3_2500_bv64_1:bv64) { .comment = "R30 preserved across calls" };
    assert true { .comment = "R31 preserved across calls" };
    return (R0_5:bv64, R1_3:bv64, var2_2500_bv64_1:bv64, R2_3:bv64);
  ]
];




prog entry @main_2148 {
  .symbols = {
    .externalFunctions = [
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x1ffc0 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x1ffe0 };
      { .name = "__cxa_finalize"; .offset = 0x1ffc8 };
      { .name = "__cxa_finalize"; .offset = 0x20008 };
      { .name = "__gmon_start__"; .offset = 0x1ffd0 };
      { .name = "__gmon_start__"; .offset = 0x20010 };
      { .name = "__libc_start_main"; .offset = 0x20000 };
      { .name = "abort"; .offset = 0x20018 }
    ];
    .globals = [
      { .name = "_DYNAMIC"; .address = 0x1fdb8; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x1ffb8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x8b0; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0x998; .size = 0x0 };
      { .name = "__abi_tag"; .address = 0x99c; .size = 0x100 };
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x1fdb0; .size = 0x0 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x1fda8; .size = 0x0 };
      { .name = "array"; .address = 0x20030; .size = 0x60 };
      { .name = "completed.0"; .address = 0x2003c; .size = 0x8 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x740; .size = 0x1a0 };
      { .name = "main"; .address = 0x864; .size = 0x1a0 }
    ];
    .globalOffsets = [ [ 0x1fda8; 0x860 ]; [ 0x1fdb0; 0x80c ]; [ 0x1ffd8; 0x864 ]; [ 0x20028; 0x20028 ] ]
  };
  .initial_memory = [
  {
    .name = ".interp";
    .address = 0x238;
    .size = 0x6e;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/y3K0RJFIBAAUD+07Vgrcz8nohrZ7iDi63nwfA5KKLjtaR3R+ePfW6N1cyyTJkdkfxd3d9tenpsi4GLoBzBm";
      "HbxmyDJLOgVikFzASQZSTMAdvg2j/eDrakuqrh6zoL2WbgAAAA=="
    ]
  };
  {
    .name = ".hash";
    .address = 0x2a8;
    .size = 0x38;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NmYGDgBGI2IOYAYnYGTMCMxGYFYhYgBgDgCbzxOAAAAA==" ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x2e0;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x300;
    .size = 0xd8;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2NgwA2YGbgYZrBhExdnUGBgQhFjBGIhLGYIAyUUsIkDsRIWcX0c6pVwmG+HQz0AXSa/DdgAAAA="
    ]
  };
  {
    .name = ".dynstr";
    .address = 0x3d8;
    .size = 0x158;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/32Qy26DMBRE/UO2gzGm6bJZVJGaHfsrYxxjYa5T8wjk6wtqVXXRdjcaHZ2RhgAEXxsYRp1G6LVHAmAWDVeP";
      "OviHJbqOaSQ7xIbIFHl9O7+cQLCs/I65JBz9wocxJstdO9/qRiuVz/1VCSdEc1xl+SiKtZX5gtTtMqp1Mq2SdMIO4x1p8Dgt";
      "1OFEBZOCypJv2PNPb1i1eTLzvQh91ob3TIZVJXlUPty6rDv8Y3TG0Kxggh22suZ/gvskgXN1gcYm6/ww2lRdTiGirXQd7PaN";
      "6yN+vQWf6K/gB4lUvYZYAQAA"
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x530;
    .size = 0x12;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgAAEmBkYGZigGAAVwnyoSAAAA" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x548;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NkYGLQYGBgEGCAgOkTp7ExMDAzGEHFtoD5TAy2UHkAYm7JxDAAAAA=" ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x578;
    .size = 0xc0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/1vxl5EBBJhZwBRDAgeE3oAmzgMVv/EfVTwFKq7BwIQiDuMfgKpnBIpDpcDgBJI4K5L4BSRxNiTxB0jiHEji";
      "ADmTapDAAAAA"
    ]
  };
  {
    .name = ".rela.plt";
    .address = 0x638;
    .size = 0x60;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgYGIAASYWBgZmBgTgQBJnRRIXQBJnQxKXQBJnRxIHAI69AOVgAAAA" ]
  };
  {
    .name = ".init";
    .address = 0x698;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/7NXZr76t3r/yr/MDBNNGBim/K0+uGI/UOwAc/w1ACpSifEcAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x6c0;
    .size = 0x60;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA//tQvX/lBwaGD4L/3H8KPLKfqMAkf01egfkqDAswMkwQZHL4KcDEAJYD89mAfCUkPheQ74TE5wPykyB8ALED";
      "WOBgAAAA"
    ]
  };
  {
    .name = ".text";
    .address = 0x740;
    .size = 0x158;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/22PMUsDQRSEZ2+vEM5OwUqTPf0BdpLKlzTbi31i/sYVnnUaDwv/gqawsrlGL7Z2SgKCwiXEEEiKI6kWslxe";
      "trAIFsOD3ZmPmeaJ7B8i/jhi/Up0h5LM6BjJRCLJgQJzbST/+ayfsryfstz7VBsCnvOyPMhkc1Cpyv5/gsAtIBLBV/E9B2YZ";
      "cDlkhsq1uWJGIUUXXmWw4Wz7FfAerq4/67s3HbWq3/XYP+Jso9Cm7bLeX9ZGL4+Wey8DmD3OtxZUI4Ez13esTcx+x98n88Q7";
      "vlhVxBetBWrLgIyN3h62t3zzPhu9Ou4mKzIkDc6EPlKcUhr6lKodSgEv4N6BjXqOsQao3n8YWAEAAA=="
    ]
  };
  {
    .name = ".fini";
    .address = 0x898;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/7NXZr76t3r/yr/MDBP/Vh9csR/IP8Acfw0AdjFaHxgAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x8b0;
    .size = 0x4;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/2NkYGIAAPvazqsEAAAA" ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x8b4;
    .size = 0x3c;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/2OUZra2YGBgYAPinn///wcA6TdAOgVIy/z//78CSEcA6R4gvQZIbwDSG4D0ESANAFvEJ7I8AAAA"
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x8f0;
    .size = 0xac;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/xNggADGqiAGlgo5RmkeeQYBIF8CiE3+/f9vApJ0ZJcDiekAcQNQzACqByTmAMRzgGI2UDEFIA4B4iNAMQ+w";
      "Xj6FuSzzmJ0mM/ndu3uZD6avAoi/ANWwQPXJAHEPED+B28knMJdpHqP3vbt8UCUMAClFh+OsAAAA"
    ]
  };
  {
    .name = ".note.ABI-tag";
    .address = 0x99c;
    .size = 0x20;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NhYGAQAGJGIHb3C2UAAWYg5mKAAADshLlpIAAAAA==" ]
  };
  {
    .name = ".init_array";
    .address = 0x1fda8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/0vgYAADALUxJoYIAAAA" ]
  };
  {
    .name = ".fini_array";
    .address = 0x1fdb0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/+PhYAADAEGEYgEIAAAA" ]
  };
  {
    .name = ".dynamic";
    .address = 0x1fdb8;
    .size = 0x200;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAA/62QLRLCMBBGv1Ja/h1MoYBHIjlCj4DkBliOwhGQHKHHQCKRmIoOQ8PAvohUs+bNy5fNJolktYFrWMAxPKfG";
      "ife+cYFf3tGPS5xYObySr1p51/d3jFXjjl/e8YT8Fhu5hoQP0b0drxE+hzOFRZsezhoYowOcwh7M4C4N109J+I4SDlrzX87e";
      "47c2eEG/w7m+nviWvMb9P/27PlO/XaUAAgAA"
    ]
  };
  {
    .name = ".got";
    .address = 0x1ffb8;
    .size = 0x30;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAA/9vxl5EBH0jhQOUDAOxmJSkwAAAA" ]
  };
  {
    .name = ".got.plt";
    .address = 0x1ffe8;
    .size = 0x38;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgwA4OsOGnARfblqU4AAAA" ]
  };
  {
    .name = ".data";
    .address = 0x20020;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NggAANBiYGGGAEYhAPAMZSIGQcAAAA" ]
  };
  {
    .name = ".bss";
    .address = 0x2003c;
    .size = 0x4;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAA/2NgYGAAABzfRCEEAAAA" ]
  }
]
} ;
