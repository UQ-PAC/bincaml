let () =
  assert (
    Capstone.disas_arm64_op (Int32.of_int 0x123444)
    = Error "capstone disassembly error");

  assert (
    Capstone.disas_arm64_op (Int32.of_int 0x8b031041)
    = Ok "add x1, x2, x3, lsl #4");

  assert (
    Capstone.disas_arm64_op (Int32.of_int 0xa9bf7bf0)
    = Ok "stp x16, x30, [sp, #-0x10]!");

  assert (
    Capstone.disas_arm64_op (Int32.of_int 0x3940a260)
    = Ok "ldrb w0, [x19, #0x28]")
