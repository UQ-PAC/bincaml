open struct
  external disas_arm64_op_ffi : string -> string = "disas_arm64_op"
end

let disas_arm64_op (opcode : Int32.t) : string option =
  let bytes = Bytes.create 4 in
  Bytes.set_int32_le bytes 0 opcode;
  let b = String.of_bytes bytes in
  disas_arm64_op_ffi b |> function "" -> None | o -> Some o

let%expect_test "disas add" =
  Option.iter print_endline (disas_arm64_op @@ Int32.of_int 0x8b031041);
  [%expect {| add x1, x2, x3, lsl #4 |}]

let%expect_test "dsas stp" =
  Option.iter print_endline (disas_arm64_op @@ Int32.of_int 0xa9bf7bf0);
  [%expect {| stp x16, x30, [sp, #-0x10]! |}]

let%expect_test "disas ldrb" =
  Option.iter print_endline (disas_arm64_op (Int32.of_int 0x3940a260));
  [%expect {| ldrb w0, [x19, #0x28] |}]
