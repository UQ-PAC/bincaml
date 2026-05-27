open Lang.Common

type config = { opcode_length : int; pc_var : Var.t; disas : bool }

let conf =
  let pc_var = Var.create "$PC" ~scope:Var.GlobalVar (Bitvector 64) in
  { opcode_length = 4; pc_var; disas = false }
