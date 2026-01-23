open Bincaml_util.Common

type c_type = C_Int | C_Int64 | C_Float [@@deriving show]

(* TODO: Define fold / map if they seem useful and define a show / pretty *)
type ty =
  | Top
  | Bottom
  | Paren of ty
  | Union of ty * ty (* type ∪ type *)
  | Sect of ty * ty (* type ∩ type *)
  | Pointer of ty * ty (* ptr(lb, ub) *)
  | Function of ty list * ty list (* list of inputs and list of outputs *)
  | Record of field list (* A list of fields in the record *)
  | Var of ID.t
  | Recursive of ID.t
  | Atom of c_type

and field = { offset : int; size : int; ty : ty }

let rec show_ty = function
  | Top -> "⊤"
  | Bottom -> "⊥"
  | Atom c -> show_c_type c
  | Var id -> ID.to_string id
  | Recursive id -> ID.to_string id
  | Paren ty -> Printf.sprintf "(%s)" @@ show_ty ty
  | Union (t1, t2) -> Printf.sprintf "%s ∪ %s" (show_ty t1) (show_ty t2)
  | Sect (t1, t2) -> Printf.sprintf "%s ∩ %s" (show_ty t1) (show_ty t2)
  | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show_ty lb) (show_ty ub)
  | Function (ins, outs) ->
      Printf.sprintf "(%s) → (%s)"
        (List.to_string show_ty ins)
        (List.to_string show_ty outs)
  | Record fields -> Printf.sprintf "{ %s }" @@ List.to_string show_field fields

and show_field { offset; size; ty } =
  Printf.sprintf "(%d, %d): %s" offset size (show_ty ty)

let rec fold_ty f acc ty =
  let acc = f acc ty in
  match ty with
  | Top | Bottom | Atom _ | Var _ | Recursive _ -> acc
  | Paren t -> fold_ty f acc t
  | Union (a, b)
  | Sect (a, b) ->
      fold_ty f (fold_ty f acc a) b
  | Pointer (lb, ub) ->
      fold_ty f (fold_ty f acc lb) ub
  | Function (ins, outs) ->
      let acc = List.fold_left (fold_ty f) acc ins in
      List.fold_left (fold_ty f) acc outs
  | Record fields ->
      List.fold_left (fun acc {ty} -> fold_ty f acc ty) acc fields

(* left hand side maps to left hand side ty <= ty *)
type type_constraint = Constraint of { lb : ty; ub : ty }

let show_type_constraint (Constraint { lb; ub }) =
  Printf.sprintf "%s <= %s" (show_ty lb) (show_ty ub)
