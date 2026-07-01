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
  | SP_EL0 -> "SP"
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

let predefined =
  [
    PC; SP_EL0;

    R (Some 0); R (Some 1); R (Some 2); R (Some 3); R (Some 4); R (Some 5); R (Some 6);
    R (Some 7); R (Some 8); R (Some 9); R (Some 10); R (Some 11); R (Some 12);
    R (Some 13); R (Some 14); R (Some 15); R (Some 16); R (Some 17); R (Some 18);
    R (Some 19); R (Some 20); R (Some 21); R (Some 22); R (Some 23); R (Some 24);
    R (Some 25); R (Some 26); R (Some 27); R (Some 28); R (Some 29); R (Some 30);
    Z (Some 0); Z (Some 1); Z (Some 2); Z (Some 3); Z (Some 4); Z (Some 5); Z (Some 6);
    Z (Some 7); Z (Some 8); Z (Some 9); Z (Some 10); Z (Some 11); Z (Some 12);
    Z (Some 13); Z (Some 14); Z (Some 15); Z (Some 16); Z (Some 17); Z (Some 18);
    Z (Some 19); Z (Some 20); Z (Some 21); Z (Some 22); Z (Some 23); Z (Some 24);
    Z (Some 25); Z (Some 26); Z (Some 27); Z (Some 28); Z (Some 29); Z (Some 30);

    FPSR; FPCR;
    PSTATE_C; PSTATE_Z; PSTATE_V; PSTATE_N;
    PSTATE_A; PSTATE_D; PSTATE_DIT; PSTATE_F; PSTATE_I; PSTATE_PAN; PSTATE_SP;
    PSTATE_SSBS; PSTATE_TCO; PSTATE_UAO; PSTATE_BTYPE;

    BTypeCompatible; BranchTaken; BTypeNext; ExclusiveLocal;
  ] [@@ocamlformat "disable"]

let global_vars () =
  List.filter_map
    (fun v ->
      Option.if_
        (fun v -> match Var.scope v with GlobalVar -> true | _ -> false)
        (to_var v))
    predefined
