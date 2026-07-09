(** Main definition of the IBI, lifting into a structured
    {!Aslp_state.aslp_diamond}. *)

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
let from_generator ?(memory = fun () -> failwith "bincaml_memory_var undefined")
    generator : (module IBI) =
  (module Make (struct
    let initial_lifter_state = Aslp_state.empty_lifter_state ~generator ()
    let bincaml_memory_var = memory
  end))

(** Builds a new {!IBI} where the ID generators are derived from the given
    procedure. *)
let from_bincaml_procedure prog ?memory proc : (module IBI) =
  let local_var = Procedure.var_generator proc in
  let global_var = Program.var_generator prog in
  from_generator ?memory
    (Aslp_lexpr.aslp_ids_from_generators ~local_var ~global_var)
