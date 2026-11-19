(** TODO: THE REST OF THE ABI. at the moment, this just implements removing of
    parameters from modsets which are callee-preserved.

    At the moment, it also pre-supposes parameter form. However, parameter form
    inference should actually be moved into here since it depends very much on
    the calling convention. *)

let transform_program prog = prog
