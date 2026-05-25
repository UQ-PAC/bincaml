open struct
  external disas_arm64_op : string -> string = "disas_arm64_op"
end

let disas_arm64_op (opcode : Int32.t) : string option =
  let bytes = Bytes.create 4 in
  Bytes.set_int32_le bytes 0 opcode;
  let b = String.of_bytes bytes in
  disas_arm64_op b |> function "" -> None | o -> Some o
