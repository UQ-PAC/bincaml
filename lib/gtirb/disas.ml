open Lang
open Common

let dis_op op = Capstone.disas_arm64_op (Opcode.to_int op)
