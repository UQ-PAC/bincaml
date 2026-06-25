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

let scope = function
  | Local _ -> Var.LocalVar
  | BranchTaken | BTypeCompatible | BTypeNext -> LocalVar
  | _ -> GlobalVar

let to_var x =
  let ty = typ x and name = name x and scope = scope x in
  let name = match scope with GlobalVar -> "$" ^ name | _ -> name in
  Var.create ~scope name ty

let pc_var = to_var PC
let branchtaken_var = to_var BranchTaken
