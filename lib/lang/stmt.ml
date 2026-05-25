open Common
open Containers
open Types
open Expr

type endian = [ `Big | `Little ] [@@deriving eq, ord]
type ident = string

module Intrinsic = struct
  type t =
    | Havoc
    (* void -> any list , ad hoc polymorphic, random a rendom value *)
    | Malloc (* size -> ptr, allocate nondet memoty *)
    | Free (*ptr -> void , free memory *)
    | Calloc (* size -> ptr allocate zeroed memory *)
    | AllocStack (* size -> ptr allocate stack memory *)
    | FreeStack (* ptr -> void free , stack memory *)
  [@@deriving eq, ord, show]

  let of_string e =
    match e with
    | "@_havoc" -> Some Havoc
    | "@_malloc" -> Some Malloc
    | "@_calloc" -> Some Calloc
    | "@_free" -> Some Free
    | "@_allcoa" -> Some AllocStack
    | "@_free_alloca" -> Some FreeStack
    | _ -> None

  let to_string e =
    match e with
    | Havoc -> "@_havoc"
    | Malloc -> "@_malloc"
    | Calloc -> "@_calloc"
    | Free -> "@_free"
    | AllocStack -> "@_allcoa"
    | FreeStack -> "@_free_alloca"

  let pretty = Containers_pp.text % to_string
end

let show_endian = function `Big -> "be" | `Little -> "le"
let pp_endian fmt e = Format.pp_print_string fmt (show_endian e)

type 'e access = Scalar | Addr of { addr : 'e; size : int; endian : endian }
[@@deriving eq, ord, show, map]

type ('lvar, 'var, 'expr) t =
  | Instr_Assign of { attrib : Attrib.attrib_map; al : ('lvar * 'expr) list }
      (** simultaneous assignment of expr snd to lvar fst*)
  | Instr_Assert of { attrib : Attrib.attrib_map; body : 'expr }
      (** assertions *)
  | Instr_Assume of { attrib : Attrib.attrib_map; body : 'expr; branch : bool }
      (** assumption; or branch guard *)
  | Instr_Load of {
      attrib : Attrib.attrib_map;
      lhs : 'lvar;  (** load destination variable *)
      rhs : 'var;  (** variable loading from *)
      addr : 'expr access;  (** load index *)
    }  (** a load from memory [rhs] at index [addr] *)
  | Instr_Store of {
      attrib : Attrib.attrib_map;
      lhs : 'lvar;  (** store destination variable *)
      rhs : 'var;  (** store source variable *)
      value : 'expr;  (** value to store value (may be combined with [rhs]) *)
      addr : 'expr access;  (** store address *)
    }
      (** a store into memory indexes [addr] up to of [addr] + [cells] (of
          [value] byte swapped depending on endiannesss*)
  | Instr_IntrinCall of {
      attrib : Attrib.attrib_map;
      lhs : 'lvar list;
      name : Intrinsic.t;
      args : 'expr list;
    }  (** effectful operation calling a named intrinsic*)
  | Instr_Call of {
      attrib : Attrib.attrib_map;
      lhs : 'lvar StringMap.t;
      procid : ID.t;
      args : 'expr StringMap.t;
    }
      (** call a procedure with the args, assigning its return parameters to lhs
      *)
  | Instr_IndirectCall of { attrib : Attrib.attrib_map; target : 'expr }
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
  | Instr_Load { lhs; rhs; addr } -> Iter.singleton rhs
  | Instr_Store { rhs; addr; value } -> Iter.singleton rhs
  | _ -> Iter.empty

(** return an iterator containing the memory written to by the statement *)
let iter_mem_store stmt =
  match stmt with
  | Instr_Store { lhs; addr; value } -> Iter.singleton lhs
  | _ -> Iter.empty

(** get an iterator over the expresions in the RHS of the statement *)
let iter_rexpr stmt =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign { al } -> List.to_iter al >|= snd >|= fun v -> `Expr v
  | Instr_Assert { body } -> Iter.singleton (`Expr body)
  | Instr_Assume { body } -> Iter.singleton (`Expr body)
  | Instr_Load { lhs; rhs; addr = Addr { addr } } ->
      Iter.doubleton (`Expr addr) (`Var rhs)
  | Instr_Load { lhs; rhs; addr = Scalar } -> Iter.singleton (`Var rhs)
  | Instr_Store { lhs; rhs; addr = Addr { addr }; value } ->
      Iter.of_list [ `Expr value; `Expr addr; `Var rhs ]
  | Instr_Store { lhs; rhs; addr = Scalar; value } ->
      Iter.of_list [ `Expr value; `Var rhs ]
  | Instr_IntrinCall { lhs; name; args } ->
      List.to_iter args >|= fun e -> `Expr e
  | Instr_IndirectCall { target } -> Iter.singleton (`Expr target)
  | Instr_Call { lhs; procid; args } ->
      StringMap.to_iter args >|= snd >|= fun e -> `Expr e

(** get an iterator over the variables in the LHS of the statement *)
let iter_lvar stmt =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign { al } -> List.to_iter al >|= fst
  | Instr_Assert { body } -> Iter.empty
  | Instr_Assume { body } -> Iter.empty
  | Instr_Load { lhs; rhs; addr } -> Iter.singleton lhs
  | Instr_Store { lhs; rhs; addr; value } -> Iter.singleton lhs
  | Instr_IntrinCall { lhs; name; args } -> List.to_iter lhs
  | Instr_IndirectCall { target } -> Iter.empty
  | Instr_Call { lhs; procid; args } -> StringMap.to_iter lhs >|= snd

let attrib stmt =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign { attrib } -> attrib
  | Instr_Assert { attrib } -> attrib
  | Instr_Assume { attrib } -> attrib
  | Instr_Load { attrib } -> attrib
  | Instr_Store { attrib } -> attrib
  | Instr_IntrinCall { attrib } -> attrib
  | Instr_IndirectCall { attrib } -> attrib
  | Instr_Call { attrib } -> attrib

let set_attrib stmt attrib =
  let open Iter.Infix in
  match stmt with
  | Instr_Assign a -> Instr_Assign { a with attrib }
  | Instr_Assert a -> Instr_Assert { a with attrib }
  | Instr_Assume a -> Instr_Assume { a with attrib }
  | Instr_Load a -> Instr_Load { a with attrib }
  | Instr_Store a -> Instr_Store { a with attrib }
  | Instr_IntrinCall a -> Instr_IntrinCall { a with attrib }
  | Instr_IndirectCall a -> Instr_IndirectCall { a with attrib }
  | Instr_Call a -> Instr_Call { a with attrib }

let drop_attrib stmt = set_attrib stmt Attrib.empty

(** Get pretty-printer for il format*)
let pretty show_lvar show_var show_expr s =
  let attrib = Expr.BasilExpr.pretty_attr (attrib s) in
  Trace_core.with_span ~__FILE__ ~__LINE__ "pretty-stmt" @@ fun _ ->
  let open Containers_pp in
  let open Containers_pp.Infix in
  let r_param_list l =
    if StringMap.is_empty l then text "()"
    else
      let l =
        StringMap.bindings l |> List.map (fun (i, t) -> text i ^ text "=" ^ t)
      in
      bracket "(" (nest 2 (fill (text "," ^ newline_or_spaces 1) l)) ")"
  in
  let intrin_plist l =
    bracket "(" (nest 2 (fill (text "," ^ newline_or_spaces 1) l)) ")"
  in
  let l_param_list l =
    if StringMap.is_empty l then text ""
    else
      let l =
        StringMap.bindings l |> List.map (fun (i, t) -> t ^ text "=" ^ text i)
      in
      bracket "(" (nest 2 (fill (text "," ^ newline_or_spaces 1) l)) ") := "
  in
  let e = map ~f_lvar:show_lvar ~f_expr:show_expr ~f_rvar:show_var s in
  match e with
  | Instr_Assign { al = [] } -> text "nop" ^ attrib
  | Instr_Assign { al = ls } ->
      let ls = List.map (function lhs, rhs -> lhs ^ text " := " ^ rhs) ls in
      let b = fill (text "," ^ newline) ls in
      (if List.length ls > 1 then bracket "(" b ")" else b) ^ attrib
  | Instr_Assert { body } -> text "assert " ^ body ^ attrib
  | Instr_Assume { body; branch = false } -> text "assume " ^ body ^ attrib
  | Instr_Assume { body; branch = true } -> text "guard " ^ body ^ attrib
  | Instr_Load { lhs; rhs; addr = Scalar } ->
      lhs ^ text " := " ^ text "load " ^ text " " ^ rhs
  | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
      lhs ^ text " := " ^ text "load "
      ^ text (show_endian endian)
      ^ text " " ^ rhs ^ text " " ^ addr ^ text " " ^ int size ^ attrib
  | Instr_Store { lhs; rhs; value; addr = Scalar } ->
      lhs ^ text " := " ^ text "store " ^ text " " ^ value ^ attrib
  | Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
      lhs ^ text " := " ^ text "store "
      ^ text (show_endian endian)
      ^ text " " ^ rhs ^ text " " ^ addr ^ text " " ^ value ^ text " "
      ^ int size ^ attrib
  | Instr_IntrinCall { lhs; name; args } when List.length lhs = 0 ->
      append_l ~sep:nil
        [ text "call "; Intrinsic.pretty name; intrin_plist args ]
      ^ attrib
  | Instr_IntrinCall { lhs; name; args } ->
      append_l ~sep:nil
        [
          intrin_plist lhs;
          text ":= call ";
          Intrinsic.pretty name;
          intrin_plist args;
        ]
      ^ attrib
  | Instr_Call { lhs; procid; args } ->
      let n = ID.to_string procid in
      append_l ~sep:nil
        [ l_param_list lhs; text "call "; text n; r_param_list args ]
      ^ attrib
  | Instr_IndirectCall { target } -> text "indirect call " ^ target ^ attrib

(** Pretty print to il format*)
let to_string ?width show_lvar show_var show_expr
    (s : (Var.t, Var.t, BasilExpr.t) t) =
  let width = Option.get_or ~default:80 width in
  let d = pretty show_lvar show_var show_expr s in
  Containers_pp.Pretty.to_string ~width d

let show_stmt_basil =
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  to_string show_lvar show_var show_expr

let pp_stmt_basil fmt s = Format.pp_print_string fmt (show_stmt_basil s)

let assigned (init : VarSet.t) s : VarSet.t =
  let f_lvar a v = VarSet.add v a in
  iter_lvar s |> Iter.fold f_lvar init

let iter_assigned = iter_lvar

let free_vars_iter (s : (Var.t, Var.t, BasilExpr.t) t) : Var.t Iter.t =
  let f_expr v =
    match v with
    | `Expr v -> BasilExpr.free_vars_iter v
    | `Var v -> Iter.singleton v
  in
  iter_rexpr s |> Iter.flat_map f_expr

(** free variables, also known as live variables. Given the initial free
    variables init following this statement*)
let free_vars ?(init = VarSet.empty) s =
  let assigns = VarSet.diff init (assigned VarSet.empty s) in
  (fun (init : VarSet.t) (s : (Var.t, Var.t, BasilExpr.t) t) : VarSet.t ->
    let f_expr a v =
      match v with
      | `Expr v -> VarSet.union (BasilExpr.free_vars v) a
      | `Var v -> VarSet.add v a
    in
    iter_rexpr s |> Iter.fold f_expr init)
    assigns s
