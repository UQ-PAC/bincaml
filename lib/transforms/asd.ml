open Bincaml_util.Common

(* |add_unique| -- adds e to list l only if it is not already in l *)
let add_unique e l = if List.mem e l then l else e :: l

(* |list_union| -- returns union of the two input lists *)
let rec list_union l1 = function
  | [] -> l1
  | x :: xs -> list_union (add_unique x l1) xs

(* |index| -- finds Some index of x in xs, otherwise returns None *)
let index x xs =
  let rec aux c = function
    | [] -> None
    | y :: ys -> if x = y then Some c else aux (c + 1) ys
  in
  aux 0 xs

type c_type = C_Int | C_BV of int | C_Float | C_Bool [@@deriving ord, eq]

let show_c_type = function
  | C_Int -> "int"
  | C_BV size -> "bv" ^ string_of_int size
  | C_Float -> "float"
  | C_Bool -> "bool"

type ty =
  | Top
  | Bottom
  | Paren of ty
  | Union of ty * ty (* type ∪ type *)
  | Sect of ty * ty (* type ∩ type *)
  | Pointer of ty * ty (* ptr(lb, ub) *)
  | Function of
      string
      * ty StringMap.t
      * ty StringMap.t (* list of inputs and list of outputs *)
  | Field of field
  | Record of field list (* A list of fields in the record *)
  | TypeVar of string
  | Recursive of ty * ty
  | Atom of c_type

and field = { offset : int; size : int; ty : ty }

let rec show_ty = function
  | Top -> "⊤"
  | Bottom -> "⊥"
  | Atom c -> show_c_type c
  | TypeVar id -> Printf.sprintf "TypeVar %s" id
  | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (show_ty t1) (show_ty t2)
  | Paren ty -> Printf.sprintf "(%s)" @@ show_ty ty
  | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show_ty t1) (show_ty t2)
  | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show_ty t1) (show_ty t2)
  | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show_ty lb) (show_ty ub)
  | Function (name, ins, outs) ->
      Printf.sprintf "(%s) → (%s)"
        (Iter.to_string show_ty (StringMap.values ins))
        (Iter.to_string show_ty (StringMap.values outs))
  | Field field -> show_field field
  | Record fields -> Printf.sprintf "{ %s }" @@ List.to_string show_field fields

and show_field { offset; size; ty } =
  Printf.sprintf "(%d, %d): %s" offset size (show_ty ty)

let rec compare_ty type1 type2 =
  match (type1, type2) with
  | Top, Top | Bottom, Bottom -> 0
  | Atom a, Atom b -> compare_c_type a b
  | TypeVar a, TypeVar b -> String.compare a b
  | Recursive (a, b), Recursive (c, d) ->
      let c = compare_ty a c in
      if c <> 0 then c else compare_ty b d
  | Paren a, Paren b -> compare_ty a b
  | Union (a, b), Union (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Sect (a, b), Sect (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Pointer (a, b), Pointer (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Function (name, ins, outs), Function (name2, ins2, outs2) ->
      let c = String.compare name name2 in
      if c <> 0 then c
      else
        let c = StringMap.compare compare_ty ins ins2 in
        if c <> 0 then c else StringMap.compare compare_ty outs outs2
  | ( Field { offset; size; ty },
      Field { offset = offset2; size = size2; ty = ty2 } ) ->
      let c = compare offset offset2 in
      if c <> 0 then c
      else
        let c = compare size size2 in
        if c <> 0 then c else compare_ty ty ty2
  | Record fields, Record fields2 ->
      List.compare (fun { ty } { ty = ty2 } -> compare_ty ty ty2) fields fields2
  | _ -> 1

(* left hand side maps to left hand side ty <= ty *)
module TySet = Set.Make (struct
  type t = ty

  let compare = compare_ty
end)

type type_constraint = { lb : TySet.t; ub : TySet.t }
type constraint_state = type_constraint StringMap.t

let constraint_state_equals { lb; ub } { lb = lb2; ub = ub2 } =
  if TySet.equal lb lb2 then if TySet.equal ub ub2 then true else false
  else false

let show_ty_set ts = TySet.to_list ts |> List.map show_ty |> String.concat ", "

let show_constraint_state (m : type_constraint StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, { lb; ub }) ->
      Printf.sprintf "%s: lower [%s], upper [%s]" name (show_ty_set lb)
        (show_ty_set ub))
  |> String.concat "\n"

(* Helpers to actually add something to the upper / lower bounds *)
let add_ub st name ty =
  StringMap.update name
    (function
      | None -> Some { lb = TySet.empty; ub = TySet.singleton ty }
      | Some c -> Some { c with ub = TySet.add ty c.ub })
    st

let add_lb st name ty =
  StringMap.update name
    (function
      | None -> Some { ub = TySet.empty; lb = TySet.singleton ty }
      | Some c -> Some { c with lb = TySet.add ty c.lb })
    st
