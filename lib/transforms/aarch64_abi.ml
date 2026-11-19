(** TODO: THE REST OF THE ABI. at the moment, this just implements removing of
    parameters from modsets which are callee-preserved.

    At the moment, it also pre-supposes parameter form. However, parameter form
    inference should actually be moved into here since it depends very much on
    the calling convention. *)

open Bincaml_util.Common

(** {:https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#id49}

    TODO: move this to its own module *)
let callee_saved_names =
  let gpregs =
    Iter.int_range ~start:19 ~stop:31 |> Iter.map (Printf.sprintf "$R%d")
  and special_regs = Iter.of_array [| "$SP"; "$LR"; "$FP" |] in
  Iter.append gpregs special_regs |> Iter.to_array

let variable_is_callee_saved v = Array.mem (Var.name v) callee_saved_names

let transform_program prog = prog
  |> Lang.Program.map_procedures (fun pid proc ->
      let { captures_glob; modifies_glob } = failwith "blah"
    )
