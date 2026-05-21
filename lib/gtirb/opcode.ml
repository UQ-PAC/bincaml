open Bincaml_util.Common

type t = Int32.t

let to_hex_string (opcode : t) : string = Printf.sprintf "0x%08lx" opcode

let to_le_bytes (opcode : t) : string =
  let bytes = Bytes.create 4 in
  Bytes.set_int32_le bytes 0 opcode;
  String.of_bytes bytes

let pp fmt f = Format.pp_print_string fmt (to_hex_string f)
let of_be_bytes (bytes : string) : t = String.get_int32_be bytes 0

let pp_bytes_le (opcode : t) : string =
  let opcode_le = to_le_bytes opcode in
  let p_byte (b : char) = Printf.sprintf "%02X" (Char.code b) in
  List.of_seq (String.to_seq opcode_le) |> List.map p_byte |> String.concat " "

let parse_ops n =
  let open Angstrom in
  let one_op = BE.any_int32 in
  count n one_op

let parse n b = Angstrom.parse_string ~consume:All (parse_ops n) b

let parse_exn n b =
  Angstrom.parse_string ~consume:All (parse_ops n) b |> Result.get_exn
