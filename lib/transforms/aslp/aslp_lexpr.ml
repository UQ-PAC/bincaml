(** A simple abstraction of architecture and local variables which may be
    accessed by the ASLp lifter. *)

open Lang
open Common

(** A variable used by the ASLp lifter. Can be converted to a Bincaml
    {!Lang.Common.Var.t}. *)
type t =
  | Local of string * Types.t
  | PC
  | R of int option
      (** A 64-bit ordinary register. [None] is used to represent the virtual
          "array" of registers, since ASLp uses [f_gen_array_load] to access
          registers. *)
  | Z of int option  (** A 128-bit scalar register. *)
  | SP_EL0
  | FPSR
  | FPCR
  | PSTATE_C
  | PSTATE_Z
  | PSTATE_V
  | PSTATE_N
  | PSTATE_A
  | PSTATE_D
  | PSTATE_DIT
  | PSTATE_F
  | PSTATE_I
  | PSTATE_PAN
  | PSTATE_SP
  | PSTATE_SSBS
  | PSTATE_TCO
  | PSTATE_UAO
  | PSTATE_BTYPE
  | BTypeCompatible
  | BranchTaken
  | BTypeNext
  | ExclusiveLocal
[@@deriving show { with_path = false }]

let typ (x : t) =
  let bv = Types.bv in
  match x with
  | Local (_, t) -> t
  | R (Some _) -> bv 64
  | Z (Some _) -> bv 128
  | PC -> bv 64
  | SP_EL0 -> bv 64
  | FPSR -> bv 64
  | FPCR -> bv 64
  | PSTATE_C | PSTATE_Z | PSTATE_V | PSTATE_N | PSTATE_A | PSTATE_I | PSTATE_F
  | PSTATE_D | PSTATE_DIT | PSTATE_PAN | PSTATE_SP | PSTATE_SSBS | PSTATE_TCO
  | PSTATE_UAO | PSTATE_BTYPE ->
      bv 1
  | BTypeCompatible -> Types.Boolean
  | BranchTaken -> Types.Boolean
  | BTypeNext -> bv 2
  | ExclusiveLocal -> Types.Boolean
  | R None | Z None -> failwith "typeof_lexpr: array lexpr has no bincaml type"

let name = function
  | Local (v, _) -> v
  | R (Some n) -> Printf.sprintf "R%d" n
  | Z (Some n) -> Printf.sprintf "Z%d" n
  | R None | Z None -> failwith "name_of_lexpr: array lexpr has no bincaml name"
  | v -> show v

type aslp_ids = { local_var : Var.generator; global_var : Var.generator }
(** Generators for unique IDs used by the offline lifter. The {!aslp_ids} is
    stateful and the same {!aslp_ids} should be used by all opcodes within the
    same procedure, to ensure that IDs are unique.*)

(** Construct a new {!aslp_ids} with no pre-existing IDs.

    Be careful! You should use {!aslp_ids_from_generators} if you will use the
    lifted statements within an existing Bincaml IR. *)
let empty_aslp_ids () =
  let local_var = Var.mk_gen () in
  let global_var = Var.mk_gen ~scope:`Global () in
  { local_var; global_var }

(** {2 ID-generating functions} *)

(** Construct a {!aslp_ids} with the given {!Bincaml_util.ID.generator}s as
    underlying generators.

    This will ensure that ASLp's local variable and block names do not clash
    with existing names. *)
let aslp_ids_from_generators ~local_var ~global_var = { local_var; global_var }

let scope st = function
  | Local _ -> st.local_var
  | BranchTaken | BTypeCompatible | BTypeNext -> st.local_var
  | _ -> st.global_var

let to_var st x =
  let ty = typ x and name = name x and scope = scope st x in
  scope.with_name name ty

let pc_var st = to_var st PC
let branchtaken_var st = to_var st BranchTaken
