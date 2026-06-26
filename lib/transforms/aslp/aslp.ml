(** Entry-point for ASLp-based instruction lifter transformation.

    Transforms {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic calls into Bincaml
    IR constructs which perform the effect of the instruction. Instruction
    semantics are provided by the offline ASLp lifter, and this transform also
    fixes the control flow and forwards branch conditions. *)

open Lang
open Common
module Aslp_state = Aslp_state
module Aslp_lexpr = Aslp_lexpr
module Bincaml_ibi = Bincaml_ibi
module Diamond = Diamond

let ensure_aslp_globals_exist prog = 9

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_opcode (module I : Bincaml_ibi.IBI) ~address opcode =
  Fun.protect ~finally:I.reset_ir (fun () ->
      I.bincaml_set_address address;
      OfflineASL_pc.Offline.f_A64_decoder (module I) opcode address;
      I.get_ir ())

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_empty (module I : Bincaml_ibi.IBI) ~address () =
  Fun.protect ~finally:I.reset_ir (fun () ->
      I.bincaml_set_address address;
      I.get_ir ())

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_code_block (module I : Bincaml_ibi.IBI) ~address opcodes =
  opcodes
  |> Iter.mapi (fun i op ->
      let address = Bitvec.add (Bitvec.create ~size:64 Z.(~$4 * ~$i)) address in
      lift_opcode (module I) ~address op)
  |> Iter.to_list
