open struct
  external disas_arm64_op_ffi : string -> string = "disas_arm64_op"
end

let disas_arm64_op (opcode : Int32.t) : (string, string) result =
  let bytes = Bytes.create 4 in
  Bytes.set_int32_le bytes 0 opcode;
  let b = String.of_bytes bytes in
  try Ok (disas_arm64_op_ffi b) with Failure m -> Error m
