open Bincaml_util.Common

module Polarity = struct
  type t = Pos | Neg [@@deriving ord, eq, show]

  let not p = match p with Pos -> Neg | Neg -> Pos
  let positive = equal Pos
end

module CType = struct
  type t = C_Int | C_BV of int | C_Float | C_Bool [@@deriving ord, eq]

  let show = function
    | C_Int -> "int"
    | C_BV size -> "bv" ^ string_of_int size
    | C_Float -> "float"
    | C_Bool -> "bool"
end

module InferredType = struct
  type t =
    | Top
    | Bottom
    | Union of t * t (* type ∪ type *)
    | Sect of t * t (* type ∩ type *)
    | Pointer of t * t (* ptr(lb, ub) *)
    | Function of
        string
        * t StringMap.t
        * t StringMap.t (* list of inputs and list of outputs *)
    | Field of field
    | Record of field list (* A list of fields in the record *)
    | TypeVar of string
    | Recursive of t * t
    | Atom of CType.t

  and field = { offset : int; size : int; ty : t }

  let rec show = function
    | Top -> "⊤"
    | Bottom -> "⊥"
    | Atom c -> CType.show c
    | TypeVar id -> Printf.sprintf "TypeVar %s" id
    | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (show t1) (show t2)
    | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show t1) (show t2)
    | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show t1) (show t2)
    | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show lb) (show ub)
    | Function (name, ins, outs) ->
        Printf.sprintf "(%s) → (%s)"
          (Iter.to_string show (StringMap.values ins))
          (Iter.to_string show (StringMap.values outs))
    | Field field -> show_field field
    | Record fields ->
        Printf.sprintf "{ %s }" @@ List.to_string show_field fields

  and show_field { offset; size; ty } =
    Printf.sprintf "(%d, %d): %s" offset size (show ty)

  let rec compare type1 type2 =
    match (type1, type2) with
    | Top, Top | Bottom, Bottom -> 0
    | Atom a, Atom b -> CType.compare a b
    | TypeVar a, TypeVar b -> String.compare a b
    | Recursive (a, b), Recursive (c, d) ->
        let c = compare a c in
        if c <> 0 then c else compare b d
    | Union (a, b), Union (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Sect (a, b), Sect (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Pointer (a, b), Pointer (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Function (name, ins, outs), Function (name2, ins2, outs2) ->
        let c = String.compare name name2 in
        if c <> 0 then c
        else
          let c = StringMap.compare compare ins ins2 in
          if c <> 0 then c else StringMap.compare compare outs outs2
    | ( Field { offset; size; ty },
        Field { offset = offset2; size = size2; ty = ty2 } ) ->
        let c = Int.compare offset offset2 in
        if c <> 0 then c
        else
          let c = Int.compare size size2 in
          if c <> 0 then c else compare ty ty2
    | Record fields, Record fields2 ->
        List.compare (fun { ty } { ty = ty2 } -> compare ty ty2) fields fields2
    | _ -> 1

  let equal a b = Stdlib.( == ) 0 @@ compare a b

  let rec fold f acc (ty : t) =
    let acc = f acc ty in
    match ty with
    | Top | Bottom | Atom _ | TypeVar _ | Recursive _ -> acc
    | Union (a, b) | Sect (a, b) -> fold f (fold f acc a) b
    | Pointer (lb, ub) -> fold f (fold f acc lb) ub
    | Function (_, ins, outs) ->
        let acc = StringMap.fold (fun _ v acc -> fold f acc v) ins acc in
        StringMap.fold (fun _ v acc -> fold f acc v) outs acc
    | Field { ty } -> fold f acc ty
    | Record fields ->
        List.fold_left (fun acc { ty } -> fold f acc ty) acc fields

  let rec iter f (ty : t) =
    f ty;
    match ty with
    | Top | Bottom | Atom _ | TypeVar _ | Recursive _ -> ()
    | Union (a, b) | Sect (a, b) ->
        iter f b;
        iter f a
    | Pointer (lb, ub) ->
        iter f ub;
        iter f lb
    | Function (_, ins, outs) ->
        StringMap.iter (fun _ v -> iter f v) ins;
        StringMap.iter (fun _ v -> iter f v) outs
    | Field { ty } -> iter f ty
    | Record fields -> List.iter (fun { ty } -> iter f ty) fields
end

module TySet = struct
  module S = Set.Make (struct
    type t = InferredType.t

    let compare = InferredType.compare
  end)

  include S

  let show ts = to_list ts |> List.map InferredType.show |> String.concat ", "
end

module ConstraintState = struct
  module TypeConstraint = struct
    type t = { lb : TySet.t; ub : TySet.t }

    let equal { lb; ub } { lb = lb2; ub = ub2 } =
      TySet.equal lb lb2 && TySet.equal ub ub2
  end

  type t = TypeConstraint.t StringMap.t

  let equal = StringMap.equal TypeConstraint.equal

  let show m =
    StringMap.bindings m
    |> List.map (fun (name, ({ lb; ub } : TypeConstraint.t)) ->
        Printf.sprintf "%s: lower [%s], upper [%s]" name (TySet.show lb)
          (TySet.show ub))
    |> String.concat "\n"

  let add_ub st name ty =
    StringMap.update name
      (function
        | None ->
            Some
              ({ lb = TySet.empty; ub = TySet.singleton ty } : TypeConstraint.t)
        | Some c -> Some { c with ub = TySet.add ty c.ub })
      st

  let add_lb st name ty =
    StringMap.update name
      (function
        | None ->
            Some
              ({ ub = TySet.empty; lb = TySet.singleton ty } : TypeConstraint.t)
        | Some c -> Some { c with lb = TySet.add ty c.lb })
      st
end
