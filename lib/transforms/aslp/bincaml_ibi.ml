open Lang
open Common

include Bincaml_ibi_make
(** @inline *)

(** Abstract Bincaml IBI signature. Defines the input type as
    {!Lang.Common.Bitvec.t} and the output type as {!Aslp_state.aslp_diamond}
    but leaving other types opaque. *)
module type IBI = sig
  val bincaml_set_address : Lang.Common.Bitvec.t -> unit
  val bincaml_internal_emit : Aslp_state.stmt -> unit

  include
    OfflineASL_pc.Instruction_building_interface.IBI
      with type bitvector = Lang.Common.Bitvec.t
       and type ast = Aslp_state.aslp_diamond
end

(** Builds a new {!IBI} with the given initial generator state. *)
let from_generator generator : (module IBI) =
  (module Make (struct
    let initial_lifter_state = Aslp_state.empty_lifter_state ~generator ()
  end))

(** Builds a new {!IBI} where the ID generators are derived from the given
    procedure. *)
let from_bincaml_procedure proc : (module IBI) =
  let local_ids = Procedure.local_ids proc in
  from_generator (Aslp_state.aslp_ids_from_generators ~local_ids)
