open struct
  external disas_arm64_op_ffi : string -> string = "disas_arm64_op"
end

let disas_arm64_op (opcode : Int32.t) : (string, string) result =
  let bytes = Bytes.create 4 in
  Bytes.set_int32_le bytes 0 opcode;
  let b = String.of_bytes bytes in
  try Ok (disas_arm64_op_ffi b) with Failure m -> Error m

let%expect_test "invalid" =
  Result.iter_error print_endline (disas_arm64_op @@ Int32.of_int 0x123444);
  [%expect {| add x1, x2, x3, lsl #4 |}]

let%expect_test "invalid" =
  try print_endline (disas_arm64_op_ffi "ab")
  with Failure m ->
    print_endline m;
    [%expect {| add x1, x2, x3, lsl #4 |}]

let%expect_test "disas add" =
  Result.iter print_endline (disas_arm64_op @@ Int32.of_int 0x8b031041);
  [%expect {| add x1, x2, x3, lsl #4 |}]

let%expect_test "dsas stp" =
  Result.iter print_endline (disas_arm64_op @@ Int32.of_int 0xa9bf7bf0);
  [%expect {| stp x16, x30, [sp, #-0x10]! |}]

let%expect_test "disas ldrb" =
  Result.iter print_endline (disas_arm64_op (Int32.of_int 0x3940a260));
  [%expect {| ldrb w0, [x19, #0x28] |}]
