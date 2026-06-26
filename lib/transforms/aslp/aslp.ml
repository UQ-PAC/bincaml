(** Entry-point for ASLp-based instruction lifter transformation.

    Transforms {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic calls into Bincaml
    IR constructs which perform the effect of the instruction. Instruction
    semantics are provided by the offline ASLp lifter, and this transform also
    fixes the control flow and forwards branch conditions. *)

open Lang
open Common
module Aslp_state = Aslp_state
module Aslp_lexpr = Aslp_lexpr
module Diamond = Diamond
module Diamond_ibi = Diamond_ibi
module Bincaml_ibi = Bincaml_ibi

let enumerate : ('a -> 'b) -> 'a Diamond.diamond -> ('b * 'a) Diamond.diamond =
 fun f dia -> Diamond.map (fun x -> (f x, x)) dia

let affix_successors : 'a Diamond.diamond -> ('a * 'a list) Diamond.diamond =
 fun dia ->
  let leaf x = Diamond.Leaf (x, []) in
  let diamond ~pred ~left ~right ~value =
    let value = (value, Diamond.[ fst (last left); fst (last right) ]) in
    Diamond.Diamond { pred; left; right; value }
  in
  Diamond.cata ~leaf ~diamond dia

let enumerate_with_successors f dia =
  dia |> enumerate f |> affix_successors
  |> Diamond.map (fun ((id, x), succs) -> (id, List.map fst succs, x))

let reverse_topological : 'a Diamond.diamond -> 'a Iter.t =
 fun dia ->
  let diamond ~pred ~left ~right ~value =
    Iter.append_l [ Iter.singleton value; left; right; pred ]
  in
  Diamond.cata ~leaf:Iter.singleton ~diamond dia

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

