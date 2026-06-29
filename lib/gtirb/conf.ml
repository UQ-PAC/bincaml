open Lang.Common

type config = {
  opcode_length : int;  (** arm64 opcode size constant *)
  pc_var : string * Types.t; (* variable to use as PC*)
  disas : bool;  (** include disassembly of opcodes if llvm-mc is available *)
  direct : bool;
      (** when true, don't attempt to perform any cleanup of gtirb's cfg *)
}

let conf =
  let pc_var = ("$PC", Types.(Bitvector 64)) in
  { opcode_length = 4; pc_var; disas = true; direct = false }
