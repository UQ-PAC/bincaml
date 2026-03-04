memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

prog entry @main_4196164;

proc @main_4196164
  (R0_in:bv64, R1_in:bv64, R30_in:bv64, R31_in:bv64, _PC_in:bv64)
    -> (R0_out:bv64, R1_out:bv64, _PC_out:bv64)
  { .name = "main"; .address = 0x400744 }
  require bvsge(R31_in:bv64, bvsub(R31_in:bv64, 0x10:bv64));
[
  block %main_entry {.address = 0x400744; .originalLabel = "G8B0Q6XuSneDgqpNFr1sUQ=="} [
    store le $stack bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) extract(32, 0, R0_in:bv64) 32 { .label = "4196168_0" };
    store le $stack bvadd(R31_in:bv64, 0xfffffffffffffff0:bv64) R1_in:bv64 64 { .label = "4196172_0" };
    var load43_1: bv32 := load le $stack bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) 32 { .label = "4196184_0_0" };
    var R1_2: bv64 := zero_extend(32, load43_1:bv32) { .label = "4196184_0_1" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_2:bv64) 32 { .label = "4196188_0" };
    var load44_1: bv32 := load le $stack bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) 32 { .label = "4196192_0_0" };
    var R1_3: bv64 := zero_extend(32, load44_1:bv32) { .label = "4196192_0_1" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_3:bv64) 32 { .label = "4196204_0" };
    var load45_1: bv32 := load le $stack bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) 32 { .label = "4196208_0_0" };
    var R1_4: bv64 := zero_extend(32, load45_1:bv32) { .label = "4196208_0_1" };
    store le $mem 0x420034:bv64 extract(32, 0, R1_4:bv64) 32 { .label = "4196220_0" };
    var load46_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196232_0_0" };
    var R0_10: bv64 := zero_extend(32, load46_1:bv32) { .label = "4196232_0_1" };
    goto(%phi_3, %phi_4);
  ];
  block %main_4 {.address = 0x400bf8; .originalLabel = "5CfXAPNBQB2e77UBP6Ks5Q=="} [
    goto(%main_return);
  ];
  block %main_12 {.address = 0x400bb0; .originalLabel = "Nv41aCJAThKCmcy3dqynCA=="} [
    var R0_190: bv64 := 0x420000:bv64 { .label = "4197296_0" };
    var load41_1: bv32 := load le $mem bvadd(R0_190:bv64, 0x38:bv64) 32 { .label = "4197304_0_0" };
    var R1_43: bv64 := zero_extend(32, load41_1:bv32) { .label = "4197304_0_1" };
    var R0_192: bv64 := 0x420000:bv64 { .label = "4197308_0" };
    var load42_1: bv32 := load le $mem bvadd(R0_192:bv64, 0x34:bv64) 32 { .label = "4197316_0_0" };
    var R0_194: bv64 := zero_extend(32, load42_1:bv32) { .label = "4197316_0_1" };
    goto(%phi_99, %phi_100);
  ];
  block %main_20 {.address = 0x400b68; .originalLabel = "p1LO5tZgQgK+XrC1DJVhdg=="} [
    var R0_178: bv64 := 0x420000:bv64 { .label = "4197224_0" };
    var load15_1: bv32 := load le $mem bvadd(R0_178:bv64, 0x38:bv64) 32 { .label = "4197232_0_0" };
    var R1_40: bv64 := zero_extend(32, load15_1:bv32) { .label = "4197232_0_1" };
    var R0_180: bv64 := 0x420000:bv64 { .label = "4197236_0" };
    var load16_1: bv32 := load le $mem bvadd(R0_180:bv64, 0x34:bv64) 32 { .label = "4197244_0_0" };
    var R0_182: bv64 := zero_extend(32, load16_1:bv32) { .label = "4197244_0_1" };
    goto(%phi_93, %phi_94);
  ];
  block %main_28 {.address = 0x400b20; .originalLabel = "i5Y2P2N2QF+TUs0EYa5wMQ=="} [
    var R0_166: bv64 := 0x420000:bv64 { .label = "4197152_0" };
    var load26_1: bv32 := load le $mem bvadd(R0_166:bv64, 0x38:bv64) 32 { .label = "4197160_0_0" };
    var R1_37: bv64 := zero_extend(32, load26_1:bv32) { .label = "4197160_0_1" };
    var R0_168: bv64 := 0x420000:bv64 { .label = "4197164_0" };
    var load27_1: bv32 := load le $mem bvadd(R0_168:bv64, 0x34:bv64) 32 { .label = "4197172_0_0" };
    var R0_170: bv64 := zero_extend(32, load27_1:bv32) { .label = "4197172_0_1" };
    goto(%phi_87, %phi_88);
  ];
  block %main_36 {.address = 0x400ad8; .originalLabel = "hlfcgga4RFeskMeaki4k4g=="} [
    var R0_154: bv64 := 0x420000:bv64 { .label = "4197080_0" };
    var load5_1: bv32 := load le $mem bvadd(R0_154:bv64, 0x38:bv64) 32 { .label = "4197088_0_0" };
    var R1_34: bv64 := zero_extend(32, load5_1:bv32) { .label = "4197088_0_1" };
    var R0_156: bv64 := 0x420000:bv64 { .label = "4197092_0" };
    var load6_1: bv32 := load le $mem bvadd(R0_156:bv64, 0x34:bv64) 32 { .label = "4197100_0_0" };
    var R0_158: bv64 := zero_extend(32, load6_1:bv32) { .label = "4197100_0_1" };
    goto(%phi_81, %phi_82);
  ];
  block %main_44 {.address = 0x400aa8; .originalLabel = "ZvpzAn+YR72GcXp9aL9QTw=="} [
    var R0_146: bv64 := 0x420000:bv64 { .label = "4197032_0" };
    var load57_1: bv32 := load le $mem bvadd(R0_146:bv64, 0x38:bv64) 32 { .label = "4197040_0_0" };
    var R0_148: bv64 := zero_extend(32, load57_1:bv32) { .label = "4197040_0_1" };
    goto(%phi_75, %phi_76);
  ];
  block %main_52 {.address = 0x400a78; .originalLabel = "zmSDQG5DTj6xF13dCFmcVA=="} [
    var R0_138: bv64 := 0x420000:bv64 { .label = "4196984_0" };
    var load22_1: bv32 := load le $mem bvadd(R0_138:bv64, 0x38:bv64) 32 { .label = "4196992_0_0" };
    var R0_140: bv64 := zero_extend(32, load22_1:bv32) { .label = "4196992_0_1" };
    goto(%phi_69, %phi_70);
  ];
  block %main_60 {.address = 0x400a3c; .originalLabel = "MSWxcqboSUuxZzlToa2cQA=="} [
    var R0_127: bv64 := 0x420000:bv64 { .label = "4196924_0" };
    var load28_1: bv32 := load le $mem bvadd(R0_127:bv64, 0x38:bv64) 32 { .label = "4196932_0_0" };
    var R0_130: bv64 := 0x420000:bv64 { .label = "4196936_0" };
    var load29_1: bv32 := load le $mem bvadd(R0_130:bv64, 0x38:bv64) 32 { .label = "4196944_0_0" };
    var R0_132: bv64 := zero_extend(32, load29_1:bv32) { .label = "4196944_0_1" };
    goto(%phi_63, %phi_64);
  ];
  block %main_68 {.address = 0x4009e0; .originalLabel = "PUc4pAeZQ96nIuDgBUzegQ=="} [
    var R0_111: bv64 := 0x420000:bv64 { .label = "4196832_0" };
    var load30_1: bv32 := load le $mem bvadd(R0_111:bv64, 0x30:bv64) 32 { .label = "4196840_0_0" };
    var R0_113: bv64 := zero_extend(32, load30_1:bv32) { .label = "4196840_0_1" };
    var R1_27: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_113:bv64), 0x7cf:bv32)) { .label = "4196844_0" };
    var R0_114: bv64 := 0x420000:bv64 { .label = "4196848_0" };
    var load31_1: bv32 := load le $mem bvadd(R0_114:bv64, 0x2c:bv64) 32 { .label = "4196856_0_0" };
    var R0_116: bv64 := zero_extend(32, load31_1:bv32) { .label = "4196856_0_1" };
    goto(%phi_57, %phi_58);
  ];
  block %main_76 {.address = 0x400980; .originalLabel = "i6s1qCKKRkqGc3uaaZRhhw=="} [
    var R0_94: bv64 := 0x420000:bv64 { .label = "4196736_0" };
    var load20_1: bv32 := load le $mem bvadd(R0_94:bv64, 0x30:bv64) 32 { .label = "4196744_0_0" };
    var R0_96: bv64 := zero_extend(32, load20_1:bv32) { .label = "4196744_0_1" };
    var R1_23: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_96:bv64), 0x3e8:bv32)) { .label = "4196748_0" };
    var R0_97: bv64 := 0x420000:bv64 { .label = "4196752_0" };
    var load21_1: bv32 := load le $mem bvadd(R0_97:bv64, 0x2c:bv64) 32 { .label = "4196760_0_0" };
    var R0_99: bv64 := zero_extend(32, load21_1:bv32) { .label = "4196760_0_1" };
    goto(%phi_51, %phi_52);
  ];
  block %main_84 {.address = 0x400924; .originalLabel = "FNH06BikSbOPfBDq1qUXGw=="} [
    var R0_78: bv64 := 0x420000:bv64 { .label = "4196644_0" };
    var load34_1: bv32 := load le $mem bvadd(R0_78:bv64, 0x30:bv64) 32 { .label = "4196652_0_0" };
    var R0_80: bv64 := zero_extend(32, load34_1:bv32) { .label = "4196652_0_1" };
    var R1_19: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_80:bv64), 0x64:bv32)) { .label = "4196656_0" };
    var R0_81: bv64 := 0x420000:bv64 { .label = "4196660_0" };
    var load35_1: bv32 := load le $mem bvadd(R0_81:bv64, 0x2c:bv64) 32 { .label = "4196668_0_0" };
    var R0_83: bv64 := zero_extend(32, load35_1:bv32) { .label = "4196668_0_1" };
    goto(%phi_45, %phi_46);
  ];
  block %main_92 {.address = 0x4008c8; .originalLabel = "Mt/HgSrNROG1nV+aSMnrFw=="} [
    var R0_62: bv64 := 0x420000:bv64 { .label = "4196552_0" };
    var load18_1: bv32 := load le $mem bvadd(R0_62:bv64, 0x2c:bv64) 32 { .label = "4196560_0_0" };
    var R1_15: bv64 := zero_extend(32, load18_1:bv32) { .label = "4196560_0_1" };
    var R0_64: bv64 := 0x420000:bv64 { .label = "4196564_0" };
    var load19_1: bv32 := load le $mem bvadd(R0_64:bv64, 0x30:bv64) 32 { .label = "4196572_0_0" };
    var R0_66: bv64 := zero_extend(32, load19_1:bv32) { .label = "4196572_0_1" };
    goto(%phi_39, %phi_40);
  ];
  block %main_100 {.address = 0x40088c; .originalLabel = "KFYnMf9FR+mvpPmOjgfaPQ=="} [
    var R0_52: bv64 := 0x420000:bv64 { .label = "4196492_0" };
    var load58_1: bv32 := load le $mem bvadd(R0_52:bv64, 0x2c:bv64) 32 { .label = "4196500_0_0" };
    var R0_54: bv64 := zero_extend(32, load58_1:bv32) { .label = "4196500_0_1" };
    goto(%phi_33, %phi_34);
  ];
  block %main_108 {.address = 0x400850; .originalLabel = "ZmScqqSOQ6a4xrzQQeU8ow=="} [
    var R0_42: bv64 := 0x420000:bv64 { .label = "4196432_0" };
    var load48_1: bv32 := load le $mem bvadd(R0_42:bv64, 0x2c:bv64) 32 { .label = "4196440_0_0" };
    var R0_44: bv64 := zero_extend(32, load48_1:bv32) { .label = "4196440_0_1" };
    goto(%phi_27, %phi_28);
  ];
  block %main_116 {.address = 0x400814; .originalLabel = "DcY/NYRpQHqnhTJ+XJtUfg=="} [
    var R0_32: bv64 := 0x420000:bv64 { .label = "4196372_0" };
    var load56_1: bv32 := load le $mem bvadd(R0_32:bv64, 0x2c:bv64) 32 { .label = "4196380_0_0" };
    var R0_34: bv64 := zero_extend(32, load56_1:bv32) { .label = "4196380_0_1" };
    goto(%phi_21, %phi_22);
  ];
  block %main_124 {.address = 0x4007d8; .originalLabel = "xOvY1HtEQnyJaoRUhGFb2Q=="} [
    var R0_22: bv64 := 0x420000:bv64 { .label = "4196312_0" };
    var load47_1: bv32 := load le $mem bvadd(R0_22:bv64, 0x2c:bv64) 32 { .label = "4196320_0_0" };
    var R0_24: bv64 := zero_extend(32, load47_1:bv32) { .label = "4196320_0_1" };
    goto(%phi_15, %phi_16);
  ];
  block %main_132 {.address = 0x4007ac; .originalLabel = "EK8NkoKeRje41ZiEkMd+wg=="} [
    var R0_15: bv64 := 0x420000:bv64 { .label = "4196268_0" };
    var load11_1: bv32 := load le $mem bvadd(R0_15:bv64, 0x2c:bv64) 32 { .label = "4196276_0_0" };
    var R0_17: bv64 := zero_extend(32, load11_1:bv32) { .label = "4196276_0_1" };
    goto(%phi_9, %phi_10);
  ];
  block %phi_3 {.originalLabel = "G8B0Q6XuSneDgqpNFr1sUQ=="} [
    guard bvsge(extract(32, 0, R0_10:bv64), 0x0:bv32);
    goto(%main_132);
  ];
  block %phi_4 {.originalLabel = "G8B0Q6XuSneDgqpNFr1sUQ=="} [
    guard bvslt(extract(32, 0, R0_10:bv64), 0x0:bv32);
    var load51_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196252_0_0" };
    var R1_5: bv64 := zero_extend(32, load51_1:bv32) { .label = "4196252_0_1" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_5:bv64) 32 { .label = "4196264_0" };
    goto(%main_132);
  ];
  block %phi_9 {.originalLabel = "EK8NkoKeRje41ZiEkMd+wg=="} [
    guard bvsle(extract(32, 0, R0_17:bv64), 0x0:bv32);
    goto(%main_124);
  ];
  block %phi_10 {.originalLabel = "EK8NkoKeRje41ZiEkMd+wg=="} [
    guard bvsgt(extract(32, 0, R0_17:bv64), 0x0:bv32);
    var load17_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196296_0_0" };
    var R1_6: bv64 := zero_extend(32, load17_1:bv32) { .label = "4196296_0_1" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_6:bv64) 32 { .label = "4196308_0" };
    goto(%main_124);
  ];
  block %phi_15 {.originalLabel = "xOvY1HtEQnyJaoRUhGFb2Q=="} [
    guard bvsgt(extract(32, 0, R0_24:bv64), 0x4:bv32);
    goto(%main_116);
  ];
  block %phi_16 {.originalLabel = "xOvY1HtEQnyJaoRUhGFb2Q=="} [
    guard bvsle(extract(32, 0, R0_24:bv64), 0x4:bv32);
    var load3_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196340_0_0" };
    var R1_7: bv64 := zero_extend(32, load3_1:bv32) { .label = "4196340_0_1" };
    var load4_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196352_0_0" };
    var R0_29: bv64 := zero_extend(32, load4_1:bv32) { .label = "4196352_0_1" };
    var R1_8: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_7:bv64), extract(32, 0, R0_29:bv64))) { .label = "4196356_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_8:bv64) 32 { .label = "4196368_0" };
    goto(%main_116);
  ];
  block %phi_21 {.originalLabel = "DcY/NYRpQHqnhTJ+XJtUfg=="} [
    guard bvsgt(extract(32, 0, R0_34:bv64), 0x8:bv32);
    goto(%main_108);
  ];
  block %phi_22 {.originalLabel = "DcY/NYRpQHqnhTJ+XJtUfg=="} [
    guard bvsle(extract(32, 0, R0_34:bv64), 0x8:bv32);
    var load49_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196400_0_0" };
    var R1_9: bv64 := zero_extend(32, load49_1:bv32) { .label = "4196400_0_1" };
    var load50_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196412_0_0" };
    var R0_39: bv64 := zero_extend(32, load50_1:bv32) { .label = "4196412_0_1" };
    var R1_10: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_9:bv64), extract(32, 0, R0_39:bv64))) { .label = "4196416_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_10:bv64) 32 { .label = "4196428_0" };
    goto(%main_108);
  ];
  block %phi_27 {.originalLabel = "ZmScqqSOQ6a4xrzQQeU8ow=="} [
    guard bvsle(extract(32, 0, R0_44:bv64), 0x63:bv32);
    goto(%main_100);
  ];
  block %phi_28 {.originalLabel = "ZmScqqSOQ6a4xrzQQeU8ow=="} [
    guard bvsgt(extract(32, 0, R0_44:bv64), 0x63:bv32);
    var load59_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196460_0_0" };
    var R1_11: bv64 := zero_extend(32, load59_1:bv32) { .label = "4196460_0_1" };
    var load60_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196472_0_0" };
    var R0_49: bv64 := zero_extend(32, load60_1:bv32) { .label = "4196472_0_1" };
    var R1_12: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_11:bv64), extract(32, 0, R0_49:bv64))) { .label = "4196476_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_12:bv64) 32 { .label = "4196488_0" };
    goto(%main_100);
  ];
  block %phi_33 {.originalLabel = "KFYnMf9FR+mvpPmOjgfaPQ=="} [
    guard bvsle(extract(32, 0, R0_54:bv64), 0x3e8:bv32);
    goto(%main_92);
  ];
  block %phi_34 {.originalLabel = "KFYnMf9FR+mvpPmOjgfaPQ=="} [
    guard bvsgt(extract(32, 0, R0_54:bv64), 0x3e8:bv32);
    var load9_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196520_0_0" };
    var R1_13: bv64 := zero_extend(32, load9_1:bv32) { .label = "4196520_0_1" };
    var load10_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196532_0_0" };
    var R0_59: bv64 := zero_extend(32, load10_1:bv32) { .label = "4196532_0_1" };
    var R1_14: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_13:bv64), extract(32, 0, R0_59:bv64))) { .label = "4196536_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_14:bv64) 32 { .label = "4196548_0" };
    goto(%main_92);
  ];
  block %phi_39 {.originalLabel = "Mt/HgSrNROG1nV+aSMnrFw=="} [
    guard bvsge(extract(32, 0, R1_15:bv64), extract(32, 0, R0_66:bv64));
    goto(%main_84);
  ];
  block %phi_40 {.originalLabel = "Mt/HgSrNROG1nV+aSMnrFw=="} [
    guard bvslt(extract(32, 0, R1_15:bv64), extract(32, 0, R0_66:bv64));
    var load0_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196592_0_0" };
    var R1_16: bv64 := zero_extend(32, load0_1:bv32) { .label = "4196592_0_1" };
    var R0_69: bv64 := zero_extend(32, extract(32, 0, R1_16:bv64)) { .label = "4196596_0" };
    var R0_70: bv64 := zero_extend(32, bvshl(zero_extend(2, extract(30, 0, R0_69:bv64)), 0x2:bv32)) { .label = "4196600_0" };
    var R0_71: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_70:bv64), extract(32, 0, R1_16:bv64))) { .label = "4196604_0" };
    var R0_72: bv64 := zero_extend(32, bvshl(zero_extend(1, extract(31, 0, R0_71:bv64)), 0x1:bv32)) { .label = "4196608_0" };
    var R1_17: bv64 := zero_extend(32, extract(32, 0, R0_72:bv64)) { .label = "4196612_0" };
    var load1_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196624_0_0" };
    var R0_75: bv64 := zero_extend(32, load1_1:bv32) { .label = "4196624_0_1" };
    var R1_18: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_17:bv64), extract(32, 0, R0_75:bv64))) { .label = "4196628_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_18:bv64) 32 { .label = "4196640_0" };
    goto(%main_84);
  ];
  block %phi_45 {.originalLabel = "FNH06BikSbOPfBDq1qUXGw=="} [
    guard bvslt(extract(32, 0, R1_19:bv64), extract(32, 0, R0_83:bv64));
    goto(%main_76);
  ];
  block %phi_46 {.originalLabel = "FNH06BikSbOPfBDq1qUXGw=="} [
    guard bvsge(extract(32, 0, R1_19:bv64), extract(32, 0, R0_83:bv64));
    var load53_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196688_0_0" };
    var R1_20: bv64 := zero_extend(32, load53_1:bv32) { .label = "4196688_0_1" };
    var load54_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196700_0_0" };
    var R0_88: bv64 := zero_extend(32, load54_1:bv32) { .label = "4196700_0_1" };
    var R1_21: bv64 := zero_extend(32, extract(32, 0, bvmul(zero_extend(32, extract(32, 0, R1_20:bv64)), zero_extend(32, extract(32, 0, R0_88:bv64))))) { .label = "4196704_0" };
    var load55_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196716_0_0" };
    var R0_91: bv64 := zero_extend(32, load55_1:bv32) { .label = "4196716_0_1" };
    var R1_22: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_21:bv64), extract(32, 0, R0_91:bv64))) { .label = "4196720_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_22:bv64) 32 { .label = "4196732_0" };
    goto(%main_76);
  ];
  block %phi_51 {.originalLabel = "i6s1qCKKRkqGc3uaaZRhhw=="} [
    guard bvsge(extract(32, 0, R1_23:bv64), extract(32, 0, R0_99:bv64));
    goto(%main_68);
  ];
  block %phi_52 {.originalLabel = "i6s1qCKKRkqGc3uaaZRhhw=="} [
    guard bvslt(extract(32, 0, R1_23:bv64), extract(32, 0, R0_99:bv64));
    var load12_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196780_0_0" };
    var R0_102: bv64 := zero_extend(32, load12_1:bv32) { .label = "4196780_0_1" };
    var R1_24: bv64 := zero_extend(32, bvshl(zero_extend(1, extract(31, 0, R0_102:bv64)), 0x1:bv32)) { .label = "4196784_0" };
    var load13_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196796_0_0" };
    var R0_105: bv64 := zero_extend(32, load13_1:bv32) { .label = "4196796_0_1" };
    var R1_25: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_24:bv64), extract(32, 0, R0_105:bv64))) { .label = "4196800_0" };
    var load14_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196812_0_0" };
    var R0_108: bv64 := zero_extend(32, load14_1:bv32) { .label = "4196812_0_1" };
    var R1_26: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_25:bv64), extract(32, 0, R0_108:bv64))) { .label = "4196816_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_26:bv64) 32 { .label = "4196828_0" };
    goto(%main_68);
  ];
  block %phi_57 {.originalLabel = "PUc4pAeZQ96nIuDgBUzegQ=="} [
    guard bvsge(extract(32, 0, R1_27:bv64), extract(32, 0, R0_116:bv64));
    goto(%main_60);
  ];
  block %phi_58 {.originalLabel = "PUc4pAeZQ96nIuDgBUzegQ=="} [
    guard bvslt(extract(32, 0, R1_27:bv64), extract(32, 0, R0_116:bv64));
    var load36_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196876_0_0" };
    var R1_28: bv64 := zero_extend(32, load36_1:bv32) { .label = "4196876_0_1" };
    var load37_1: bv32 := load le $mem 0x420030:bv64 32 { .label = "4196888_0_0" };
    var R0_121: bv64 := zero_extend(32, load37_1:bv32) { .label = "4196888_0_1" };
    var R1_29: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_28:bv64), extract(32, 0, R0_121:bv64))) { .label = "4196892_0" };
    var load38_1: bv32 := load le $mem 0x42002c:bv64 32 { .label = "4196904_0_0" };
    var R0_124: bv64 := zero_extend(32, load38_1:bv32) { .label = "4196904_0_1" };
    var R1_30: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_29:bv64), extract(32, 0, R0_124:bv64))) { .label = "4196908_0" };
    store le $mem 0x42002c:bv64 extract(32, 0, R1_30:bv64) 32 { .label = "4196920_0" };
    goto(%main_60);
  ];
  block %phi_63 {.originalLabel = "MSWxcqboSUuxZzlToa2cQA=="} [
    guard boolnot(eq(extract(32, 0, R0_132:bv64), 0x0:bv32));
    goto(%main_52);
  ];
  block %phi_64 {.originalLabel = "MSWxcqboSUuxZzlToa2cQA=="} [
    guard eq(extract(32, 0, R0_132:bv64), 0x0:bv32);
    var load52_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4196964_0_0" };
    var R0_135: bv64 := zero_extend(32, load52_1:bv32) { .label = "4196964_0_1" };
    var R1_31: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_135:bv64), 0x2:bv32)) { .label = "4196968_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_31:bv64) 32 { .label = "4196980_0" };
    goto(%main_52);
  ];
  block %phi_69 {.originalLabel = "zmSDQG5DTj6xF13dCFmcVA=="} [
    guard bvugt(extract(32, 0, R0_140:bv64), 0x3e8:bv32);
    goto(%main_44);
  ];
  block %phi_70 {.originalLabel = "zmSDQG5DTj6xF13dCFmcVA=="} [
    guard bvule(extract(32, 0, R0_140:bv64), 0x3e8:bv32);
    var load2_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197012_0_0" };
    var R0_143: bv64 := zero_extend(32, load2_1:bv32) { .label = "4197012_0_1" };
    var R1_32: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_143:bv64), 0x1:bv32)) { .label = "4197016_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_32:bv64) 32 { .label = "4197028_0" };
    goto(%main_44);
  ];
  block %phi_75 {.originalLabel = "ZvpzAn+YR72GcXp9aL9QTw=="} [
    guard boolnot(eq(extract(32, 0, R0_148:bv64), 0xffffffff:bv32));
    goto(%main_36);
  ];
  block %phi_76 {.originalLabel = "ZvpzAn+YR72GcXp9aL9QTw=="} [
    guard eq(extract(32, 0, R0_148:bv64), 0xffffffff:bv32);
    var load25_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197060_0_0" };
    var R0_151: bv64 := zero_extend(32, load25_1:bv32) { .label = "4197060_0_1" };
    var R1_33: bv64 := zero_extend(32, bvadd(extract(32, 0, R0_151:bv64), 0x1:bv32)) { .label = "4197064_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_33:bv64) 32 { .label = "4197076_0" };
    goto(%main_36);
  ];
  block %phi_81 {.originalLabel = "hlfcgga4RFeskMeaki4k4g=="} [
    guard bvult(extract(32, 0, R1_34:bv64), extract(32, 0, R0_158:bv64));
    goto(%main_28);
  ];
  block %phi_82 {.originalLabel = "hlfcgga4RFeskMeaki4k4g=="} [
    guard bvuge(extract(32, 0, R1_34:bv64), extract(32, 0, R0_158:bv64));
    var load39_1: bv32 := load le $mem 0x420034:bv64 32 { .label = "4197120_0_0" };
    var R1_35: bv64 := zero_extend(32, load39_1:bv32) { .label = "4197120_0_1" };
    var load40_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197132_0_0" };
    var R0_163: bv64 := zero_extend(32, load40_1:bv32) { .label = "4197132_0_1" };
    var R1_36: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_35:bv64), extract(32, 0, R0_163:bv64))) { .label = "4197136_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_36:bv64) 32 { .label = "4197148_0" };
    goto(%main_28);
  ];
  block %phi_87 {.originalLabel = "i5Y2P2N2QF+TUs0EYa5wMQ=="} [
    guard bvugt(extract(32, 0, R1_37:bv64), extract(32, 0, R0_170:bv64));
    goto(%main_20);
  ];
  block %phi_88 {.originalLabel = "i5Y2P2N2QF+TUs0EYa5wMQ=="} [
    guard bvule(extract(32, 0, R1_37:bv64), extract(32, 0, R0_170:bv64));
    var load23_1: bv32 := load le $mem 0x420034:bv64 32 { .label = "4197192_0_0" };
    var R1_38: bv64 := zero_extend(32, load23_1:bv32) { .label = "4197192_0_1" };
    var load24_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197204_0_0" };
    var R0_175: bv64 := zero_extend(32, load24_1:bv32) { .label = "4197204_0_1" };
    var R1_39: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_38:bv64), extract(32, 0, R0_175:bv64))) { .label = "4197208_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_39:bv64) 32 { .label = "4197220_0" };
    goto(%main_20);
  ];
  block %phi_93 {.originalLabel = "p1LO5tZgQgK+XrC1DJVhdg=="} [
    guard bvuge(extract(32, 0, R1_40:bv64), extract(32, 0, R0_182:bv64));
    goto(%main_12);
  ];
  block %phi_94 {.originalLabel = "p1LO5tZgQgK+XrC1DJVhdg=="} [
    guard bvult(extract(32, 0, R1_40:bv64), extract(32, 0, R0_182:bv64));
    var load32_1: bv32 := load le $mem 0x420034:bv64 32 { .label = "4197264_0_0" };
    var R1_41: bv64 := zero_extend(32, load32_1:bv32) { .label = "4197264_0_1" };
    var load33_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197276_0_0" };
    var R0_187: bv64 := zero_extend(32, load33_1:bv32) { .label = "4197276_0_1" };
    var R1_42: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_41:bv64), extract(32, 0, R0_187:bv64))) { .label = "4197280_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_42:bv64) 32 { .label = "4197292_0" };
    goto(%main_12);
  ];
  block %phi_99 {.originalLabel = "Nv41aCJAThKCmcy3dqynCA=="} [
    guard bvule(extract(32, 0, R1_43:bv64), extract(32, 0, R0_194:bv64));
    goto(%phi_back_103);
  ];
  block %phi_100 {.originalLabel = "Nv41aCJAThKCmcy3dqynCA=="} [
    guard bvugt(extract(32, 0, R1_43:bv64), extract(32, 0, R0_194:bv64));
    var load7_1: bv32 := load le $mem 0x420034:bv64 32 { .label = "4197336_0_0" };
    var R1_46: bv64 := zero_extend(32, load7_1:bv32) { .label = "4197336_0_1" };
    var load8_1: bv32 := load le $mem 0x420038:bv64 32 { .label = "4197348_0_0" };
    var R0_199: bv64 := zero_extend(32, load8_1:bv32) { .label = "4197348_0_1" };
    var R1_47: bv64 := zero_extend(32, bvadd(extract(32, 0, R1_46:bv64), extract(32, 0, R0_199:bv64))) { .label = "4197352_0" };
    store le $mem 0x420038:bv64 extract(32, 0, R1_47:bv64) 32 { .label = "4197364_0" };
    goto(%phi_back_104);
  ];
  block %phi_back_103 {.originalLabel = "5CfXAPNBQB2e77UBP6Ks5Q=="} [
    var R1_50: bv64 := R1_43:bv64 { .label = "phiback" };
    goto(%main_4);
  ];
  block %phi_back_104 {.originalLabel = "5CfXAPNBQB2e77UBP6Ks5Q=="} [
    var R1_50: bv64 := R1_47:bv64 { .label = "phiback" };
    goto(%main_4);
  ];
  block %main_return [
    assert true { .comment = "R31 preserved across calls"; .label = "callerpreserved1" };
    return (0x0:bv64, R1_50:bv64, _PC_in:bv64);
  ]
];




prog entry @main_4196164 {
  .symbols = {
    .externalFunctions = [
      { .name = "abort"; .offset = 0x420010 };
      { .name = "__gmon_start__"; .offset = 0x420008 };
      { .name = "__gmon_start__"; .offset = 0x41ffd8 };
      { .name = "__libc_start_main@GLIBC_2.34"; .offset = 0x420000 };
      { .name = "_ITM_registerTMCloneTable"; .offset = 0x41ffe0 };
      { .name = "_ITM_deregisterTMCloneTable"; .offset = 0x41ffd0 }
    ];
    .globals = [
      { .name = "__do_global_dtors_aux_fini_array_entry"; .address = 0x41fdd0; .size = 0x0 };
      { .name = "_GLOBAL_OFFSET_TABLE_"; .address = 0x41ffc8; .size = 0x0 };
      { .name = "_IO_stdin_used"; .address = 0x400c18; .size = 0x20 };
      { .name = "y"; .address = 0x420038; .size = 0x20 };
      { .name = "x"; .address = 0x42002c; .size = 0x20 };
      { .name = "z"; .address = 0x420034; .size = 0x20 };
      { .name = "completed.0"; .address = 0x420028; .size = 0x8 };
      { .name = "__frame_dummy_init_array_entry"; .address = 0x41fdc8; .size = 0x0 };
      { .name = "_DYNAMIC"; .address = 0x41fdd8; .size = 0x0 };
      { .name = "__abi_tag"; .address = 0x4002a8; .size = 0x100 };
      { .name = "r"; .address = 0x420030; .size = 0x20 };
      { .name = "__FRAME_END__"; .address = 0x400d1c; .size = 0x0 }
    ];
    .funcEntries = [
      { .name = "_start"; .address = 0x400640; .size = 0x1e0 };
      { .name = "main"; .address = 0x400744; .size = 0x2600 }
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
      "H4sIAAAAAAAAAC3KURJAIBAAUBfaVopxnSWTHdko0fH58P0eClfMV0wLkjakT+42OanNTvt776uxR+rN41sO4ANPMxCleR0s";
      "FNkkPgKBpVTwUqBTZgRr8WsY3A9/Vzkq3bxkcoKqbgAAAA=="
    ]
  };
  {
    .name = ".note.ABI-tag";
    .address = 0x4002a8;
    .size = 0x20;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNhYGAQAGJGIHb3C2UAAWYg5mKAAADshLlpIAAAAA==" ]
  };
  {
    .name = ".hash";
    .address = 0x4002c8;
    .size = 0x2c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNmYGBgA2JmIGYFYhYGBGBEYjMBMQC6hiNOLAAAAA==" ]
  };
  {
    .name = ".gnu.hash";
    .address = 0x4002f8;
    .size = 0x1c;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNkYGBghGJ0AACV1IdlHAAAAA==" ]
  };
  {
    .name = ".dynsym";
    .address = 0x400318;
    .size = 0x90;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgwA4YgVgIizgLUEIBi7gCDnFhHObo41APABuAC8WQAAAA" ]
  };
  {
    .name = ".dynstr";
    .address = 0x4003a8;
    .size = 0x149;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAAH2QPW/DIABE+UN8GXDqjslQRWo27wgIJSgYCODE/fe11arq0HY7nZ7eSQekDF4bWZsqTU7KR6B0Kg1sLaoJ";
      "9eDl9bg/yA7R3XdkHODoF1xbKhYryhS9+e4ab4rUM3X3SSyM5yLYwxEfoNtkUKliLj2Hc7zG9Igw+Dgv0MUZrsInyDlesecf";
      "3pwHKrKYLlr3dEeMcW/Ei6HLgtzfh6H7x+iMgZShDpG11PhPcJsE8jie5NkW63xttoynQ0jRjkoHC6R0U4pf98hP9FfwAzuv";
      "x6ZJAQAA"
    ]
  };
  {
    .name = ".gnu.version";
    .address = 0x4004f2;
    .size = 0xc;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgYGJgBEJmIAYAxlt4cwwAAAA=" ]
  };
  {
    .name = ".gnu.version_r";
    .address = 0x400500;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNkYGKQZGBgEGCAgOkTp7ExMDAzKEPFtoD5TAx6UHkAtunbaDAAAAA=" ]
  };
  {
    .name = ".rela.dyn";
    .address = 0x400530;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAALvw35EBBBhZGBiYGBDgBpI4M5L4AyRxViRxAJnVS1lIAAAA" ]
  };
  {
    .name = ".rela.plt";
    .address = 0x400578;
    .size = 0x48;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgcGIAASYWBgZGBgTgQBJnRhIXQBJnQRIHAAuoUWpIAAAA" ]
  };
  {
    .name = ".init";
    .address = 0x4005c0;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAJNXYL76t3r/yr/MDBP1GBim/K0+uOIAc/w1AEJr0BgYAAAA" ]
  };
  {
    .name = ".plt";
    .address = 0x4005e0;
    .size = 0x50;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAAPtQvX/lBwaGD4L/3H8KPLKfqMAkf01egfkqDAswMkwQZHL4KcDEAJYD89mAfCUkPheQ7wThAwDuTJ1aUAAA";
      "AA=="
    ]
  };
  {
    .name = ".text";
    .address = 0x400640;
    .size = 0x5c4;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAAK2UPUjDQBTH/9frIFaIoiAiNo1ubuIgBcFUh+7qbtVFUYeCg6BgnXUwOLiWTurk4NJFoqtLVewoSVERP6Dg";
      "FLDEd2kb0w9t/RiOy733///uvVxycojf9CFxFaRxz3FkctXKDUB74NAA7CLTo3HK+UXetvdfaMjkGQa6xKzzmawB5PEStVTg";
      "xLDtbhETOTHAiJGExmhWaB4DnnVg2iSP8hi1ZsmT5+wIPjkrfNV6Bbjof9+8jrRtbSvvkb0z0ufIO56PWnOO1+d6xX6F9dPD";
      "AtX+FoDVSYxYSg0ngJFbqjuExGQshfBbQLUK6+cHwnNH9doTuDQkpE0Oy9n/GJopqWkGitHsxAyqybvOFNdlPaCmZSD+RL05";
      "MV3kVTdfT/varLYd8WVWXyvy9I4CX3pDf/DusPjKb71J6VdeV6cXdfS9LLX6KjkGZ4NYDU4BLIA1eYrObbAhu8Rju6zDqxX8";
      "53p1lvTKBnqbZielGra3dkdD9VbwPbyG/FG5hv/0Xe3NsI1izvssvk1W5pZirAUd3v+gQk9n3VKt93+j92Oohv+F3u0p89nz";
      "fNmb8eSNqh6b4Cz8E2funziLP+HQXUb3libusA9CxPaLxAUAAA=="
    ]
  };
  {
    .name = ".fini";
    .address = 0x400c04;
    .size = 0x14;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAJNXYL76t3r/yr/MDBP/Vh9ccYA5/hoA8Q4mSxQAAAA=" ]
  };
  {
    .name = ".rodata";
    .address = 0x400c18;
    .size = 0x4;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAAAGNkYGIAAPvazqsEAAAA" ]
  };
  {
    .name = ".eh_frame_hdr";
    .address = 0x400c1c;
    .size = 0x44;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAAGOUZrZ2YGBgYAdilV///0cA6RQgnQOkW4B0C5DeAqRnAOkvQHoNSN3v//8vAGkNIP0ESAMAO58JUUQAAAA="
    ]
  };
  {
    .name = ".eh_frame";
    .address = 0x400c60;
    .size = 0xc0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAABNggADGqiAGlgo5RmkeeQYBIF8CiI/8/P/fBiTpyC4nAqR0gPgDUIyFAQFAal2A+AdQ3ABJLAKIRX5B9QOB";
      "AhDnALHDL6g6Rz6FuSzzmJ0mM3ncu3uZD6ZvAhD7/ELYAXLHEiC2AYodYAHrE2DWY+SD2Q8ABUxxK8AAAAA="
    ]
  };
  {
    .name = ".init_array";
    .address = 0x41fdc8;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAHNgd2AAAQBmKUCGCAAAAA==" ]
  };
  {
    .name = ".fini_array";
    .address = 0x41fdd0;
    .size = 0x8;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAABNgd2AAAQCg2mbTCAAAAA==" ]
  };
  {
    .name = ".dynamic";
    .address = 0x41fdd8;
    .size = 0x1f0;
    .readOnly = false;
    .bytes = [
      "H4sIAAAAAAAAAL2PPQ6CQBBGB1hUFDsJ/t7B1m7t9DS2HsljWFJyDEtjYmIjS2TeFHAAp3l5++3szkSitYI7eIA5vKe+4xx3";
      "ue/1Vd9jxw0+gWtYk28HubP+WN97N+Hy4wdPyW+J+ghf4lP8HClnlsNC+pXAR9B5YvwEF3AMS3hlfzvf47aH9WeD/5ug+wj3";
      "A8648sRfzss/qgUP5Iz68AEAAA=="
    ]
  };
  {
    .name = ".got";
    .address = 0x41ffc8;
    .size = 0x20;
    .readOnly = true;
    .bytes = [ "H4sIAAAAAAAAALvx15EBHwAAlwPV5iAAAAA=" ]
  };
  {
    .name = ".got.plt";
    .address = 0x41ffe8;
    .size = 0x30;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgwA4esDpgpQETA2j/MAAAAA==" ]
  };
  {
    .name = ".data";
    .address = 0x420018;
    .size = 0x10;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgQAUAVUu77BAAAAA=" ]
  };
  {
    .name = ".bss";
    .address = 0x420028;
    .size = 0x18;
    .readOnly = false;
    .bytes = [ "H4sIAAAAAAAAAGNgwA4AIMrBoxgAAAA=" ]
  }
]
} ;
