open Common
open Containers
open Types
open Expr

type endian = [ `Big | `Little ] [@@deriving eq, ord]
type ident = string

let show_endian = function `Big -> "be" | `Little -> "le"
let pp_endian fmt e = Format.pp_print_string fmt (show_endian e)

type ('lvar, 'var, 'expr) t =
  | Instr_Assign of ('lvar * 'expr) list
      (** simultaneous assignment of expr snd to lvar fst*)
  | Instr_Assert of { body : 'expr }  (** assertions *)
  | Instr_Assume of { body : 'expr; branch : bool }
      (** assumption; or branch guard *)
  | Instr_Load of {
      lhs : 'lvar;
      mem : 'var;
      addr : 'expr;
      cells : int;
      endian : endian;
    }
      (** a load from memory index [addr] up to of [addr] + [cells] (byte
          swapped depending on endiannesss, and concatenated and stored into
          [lhs]*)
  | Instr_Store of {
      mem : 'var;
      addr : 'expr;
      value : 'expr;
      cells : int;
      endian : endian;
    }
      (** a store into memory indexes [addr] up to of [addr] + [cells] (of
          [value] byte swapped depending on endiannesss*)
  | Instr_IntrinCall of {
      lhs : 'lvar StringMap.t;
      name : string;
      args : 'expr StringMap.t;
    }  (** effectful operation calling a named intrinsic*)
  | Instr_Return of { args : 'expr StringMap.t }
      (** return to caller with [args] as return values (bound to the formal out
          parameters of this procedure)*)
  | Instr_Call of {
      lhs : 'lvar StringMap.t;
      procid : ID.t;
      args : 'expr StringMap.t;
    }
      (** call a procedure with the args, assigning its return parameters to lhs
      *)
  | Instr_IndirectCall of { target : 'expr }
      (** call to the address of a procedure or block stored in [target], due to
          its nature local behaviour is not captured and hence will have
          incorrect semantics unless all behaviour in the IR is encoded as
          global effects *)
[@@deriving eq, ord, map]

let map ~f_lvar ~f_expr ~f_rvar e = map f_lvar f_rvar f_expr e

(** return an iterator over any memory field in the statement (read or written)
*)
let iter_mem_access stmt =
  match stmt with
  | Instr_Load { lhs; mem; addr; endian } -> Iter.singleton mem
  | Instr_Store { mem; addr; value; endian } -> Iter.singleton mem
  | _ -> Iter.empty

(** return an iterator containing the memory written to by the statement *)
let iter_mem_store stmt =
  match stmt with
  | Instr_Store { mem; addr; value; endian } -> Iter.singleton mem
  | _ -> Iter.empty

(** get an iterator over the expresions in the RHS of the statement *)
let iter_rexpr stmt =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign ls -> List.to_iter ls >|= snd
  | Instr_Assert { body } -> Iter.singleton body
  | Instr_Assume { body } -> Iter.singleton body
  | Instr_Load { lhs; mem; addr; endian } -> Iter.singleton addr
  | Instr_Store { mem; addr; value; endian } ->
      Iter.singleton value <+> Iter.singleton addr
  | Instr_IntrinCall { lhs; name; args } -> StringMap.to_iter args >|= snd
  | Instr_IndirectCall { target } -> Iter.singleton target
  | Instr_Call { lhs; procid; args } -> StringMap.to_iter args >|= snd
  | Instr_Return { args } -> StringMap.to_iter args >|= snd

(** get an iterator over the variables in the LHS of the statement *)
let iter_lvar stmt =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign ls -> List.to_iter ls >|= fst
  | Instr_Assert { body } -> Iter.empty
  | Instr_Assume { body } -> Iter.empty
  | Instr_Load { lhs; mem; addr; endian } -> Iter.singleton lhs
  | Instr_Store { mem; addr; value; endian } -> Iter.singleton mem
  | Instr_IntrinCall { lhs; name; args } -> StringMap.to_iter lhs >|= snd
  | Instr_IndirectCall { target } -> Iter.empty
  | Instr_Call { lhs; procid; args } -> StringMap.to_iter lhs >|= snd
  | Instr_Return { args } -> Iter.empty

(** Get pretty-printer for il format*)
let pretty show_lvar show_var show_expr s =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let r_param_list l =
    if StringMap.is_empty l then text "()"
    else
      let l =
        StringMap.to_list l |> List.map (fun (i, t) -> text i ^ text "=" ^ t)
      in
      bracket "(" (nest 2 (fill (text "," ^ newline_or_spaces 1) l)) ")"
  in
  let l_param_list l =
    if StringMap.is_empty l then text ""
    else
      let l =
        StringMap.to_list l |> List.map (fun (i, t) -> t ^ text "=" ^ text i)
      in
      bracket "(" (nest 2 (fill (text "," ^ newline_or_spaces 1) l)) ") := "
  in
  let e = map ~f_lvar:show_lvar ~f_expr:show_expr ~f_rvar:show_var s in
  match e with
  | Instr_Assign ls ->
      let ls = List.map (function lhs, rhs -> lhs ^ text " := " ^ rhs) ls in
      let b = fill (text "," ^ newline) ls in
      if List.length ls > 1 then bracket "(" b ")" else b
  | Instr_Assert { body } -> text "assert " ^ body
  | Instr_Assume { body; branch = false } -> text "assume " ^ body
  | Instr_Assume { body; branch = true } -> text "guard " ^ body
  | Instr_Load { lhs; mem; addr; cells; endian } ->
      lhs ^ text " := " ^ text "load "
      ^ text (show_endian endian)
      ^ text " " ^ mem ^ text " " ^ addr ^ text " " ^ int cells
  | Instr_Store { mem; addr; value; cells; endian } ->
      text "store "
      ^ text (show_endian endian)
      ^ text " " ^ mem ^ text " " ^ addr ^ text " " ^ value ^ text " "
      ^ int cells
  | Instr_IntrinCall { lhs; name; args } when StringMap.cardinal lhs = 0 ->
      append_l ~sep:nil [ text "call "; text name; r_param_list args ]
  | Instr_IntrinCall { lhs; name; args } ->
      append_l ~sep:nil
        [
          l_param_list lhs; newline ^ text "call "; text name; r_param_list args;
        ]
  | Instr_Call { lhs; procid; args } ->
      let n = ID.to_string procid in
      append_l ~sep:nil
        [ l_param_list lhs; newline ^ text "call "; text n; r_param_list args ]
  | Instr_Return { args } -> text "return " ^ r_param_list args
  | Instr_IndirectCall { target } -> text "indirect_call " ^ target

(** Pretty print to il format*)
let to_string ?width show_lvar show_var show_expr
    (s : (Var.t, Var.t, BasilExpr.t) t) =
  let width = Option.get_or ~default:80 width in
  let d = pretty show_lvar show_var show_expr s in
  Containers_pp.Pretty.to_string ~width d
