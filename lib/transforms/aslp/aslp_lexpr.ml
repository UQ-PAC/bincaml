(** A simple abstraction of architecture and local variables which may be
    accessed by the ASLp lifter. *)

open Lang
open Common

(** A variable used by the ASLp lifter. Can be converted to a Bincaml
    {!Lang.Common.Var.t}. *)
type t =
  | Local of string * Types.t
  | Memory
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
  | Memory -> Types.Map (Types.Bitvector 64, Types.Bitvector 8)
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

let scope : t -> Var.scope = function
  | Local _ -> Var.LocalVar
  | BranchTaken | BTypeCompatible | BTypeNext -> LocalVar
  | Memory -> GlobalVarShared
  | _ -> GlobalVar

let is_global = function
  | Var.GlobalVarShared | GlobalVar | GlobalConst -> true
  | LocalVar | LocalConst -> false

(** Includes sigil for global variables. *)
let name lexpr =
  (match lexpr with
    | Local (v, _) -> v
    | Memory -> "mem"
    | SP_EL0 -> "SP"
    | R (Some n) -> Printf.sprintf "R%d" n
    | Z (Some n) -> Printf.sprintf "Z%d" n
    | R None | Z None ->
        failwith "name_of_lexpr: array lexpr has no bincaml name"
    | v -> show v)
  |> if is_global (scope lexpr) then ( ^ ) "$" else Fun.id

let to_var x = Var.create ~scope:(scope x) (name x) (typ x)
let pc_var = to_var PC
let branchtaken_var = to_var BranchTaken

let predefined : t list Lazy.t =
  lazy
    ([ Memory; PC; SP_EL0 ]
    @ List.init 31 (fun i -> R (Some i))
    @ List.init 31 (fun i -> Z (Some i))
    @ [ FPSR; FPCR; PSTATE_N; PSTATE_Z; PSTATE_C; PSTATE_V ]
    @ [ PSTATE_A; PSTATE_D; PSTATE_DIT; PSTATE_F; PSTATE_I ]
    @ [
        PSTATE_PAN; PSTATE_SP; PSTATE_SSBS; PSTATE_TCO; PSTATE_UAO; PSTATE_BTYPE;
      ]
    @ [ BTypeCompatible; BranchTaken; BTypeNext; ExclusiveLocal ])

let globals : t list Lazy.t =
  predefined |> Lazy.map (List.filter (scope %> is_global))

(** Checks that if the given {!Aslp_lexpr.t} global has already been declared in
    the program, that it has the same type as {!Aslp_lexpr.typ}. *)
let check_decl_type prog var =
  match Program.get_decl_by_name (name var) prog with
  | Some (Variable { binding }) when Types.equal (Var.typ binding) (typ var) ->
      ()
  | Some (Variable { binding }) ->
      Logs.warn (fun m ->
          m
            "Aslp variable %a is already declared but has unexpected type: %a. \
             Lifter output may be incorrect."
            pp var Var.pp binding)
  | Some _ -> failwith (name var ^ " already declared as non-variable")
  | None -> () (* var is not declared yet. this is fine. *)
