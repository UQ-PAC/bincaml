open Lang
open Common

include Ibi
(** @inline *)

(** Abstract Bincaml IBI signature. Defines the input type as
    {!Lang.Common.Bitvec.t} and the output type as {!Aslp_state.aslp_state} but
    leaving other types opaque. *)
module type IBI = sig
  include
    OfflineASL_pc.Instruction_building_interface.IBI
      with type bitvector = Lang.Common.Bitvec.t
       and type ast = Aslp_state.aslp_state
end

(** Builds a new {!IBI} with the given initial generator state. *)
let from_generator generator : (module IBI) =
  let bincaml_lifter_state =
    ref (Aslp_state.empty_lifter_state ~generator ())
  in
  (module Make (struct
    let bincaml_lifter_state = bincaml_lifter_state
  end))

(** Builds a new {!IBI} where the ID generators are derived from the given
    procedure. *)
let from_bincaml_procedure proc : (module IBI) =
  let block_ids = Procedure.block_ids proc
  and local_ids = Procedure.local_ids proc in
  from_generator (Aslp_state.aslp_ids_from_generators ~block_ids ~local_ids)
