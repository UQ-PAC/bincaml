open Lang
open Common

let dis_op op =
  match Capstone.disas_arm64_op (Opcode.to_le_bytes op) with
  | "" -> None
  | o -> Some o
