open Common

(** associative datastructure for attributes *)

type 'e t =
  [ `String of string
  | `Assoc of 'e t StringMap.t
  | `Expr of 'e
  | `Bool of bool
  | `Integer of Z.t
  | `CamlInt of int
  | `Bitvector of Bitvec.t
  | `List of 'e t list ]
[@@deriving eq, ord]

let location_key = "text_range"

let rec attrib_pretty ?(internal = [ location_key ]) pretty_expr (e : 'e t) :
    Containers_pp.t =
  let open Containers_pp in
  let attrib_pretty = attrib_pretty pretty_expr in
  match e with
  | `String s -> text_quoted s
  | `CamlInt s -> int s
  | `Bool b -> bool b
  | `Expr e -> pretty_expr e
  | `Bitvector bv -> text @@ Bitvec.to_string bv
  | `Integer bv -> text @@ Z.to_string bv
  | `List s ->
      nest 2
      @@ bracket "[ "
           (fill (text ";" ^ newline) (List.map attrib_pretty s))
           " ]"
  | `Assoc sm ->
      let pairs =
        sm
        |> StringMap.filter (fun i _ ->
            not @@ List.exists (String.equal i) internal)
        |> StringMap.bindings
        |> List.map (function k, v -> text k ^ text " = " ^ attrib_pretty v)
      in
      let int = fill (text ";" ^ newline) pairs in
      nest 2 (bracket "{ " int " }")

type 'e attrib_map = 'e t StringMap.t [@@deriving eq, ord]

let empty : 'e attrib_map = StringMap.empty

type loc = int * int

let attr_of_loc l =
  let s, e = l in
  `Assoc (StringMap.singleton location_key (`List [ `CamlInt s; `CamlInt e ]))

let loc_of_attr l =
  match l with
  | `List [ `CamlInt s; `CamlInt e ] -> (s, e)
  | _ -> failwith "bad structure"

let merge_map_shadow (a : 'a attrib_map) (b : 'a attrib_map) =
  StringMap.merge
    (fun k l r ->
      match (l, r) with
      | _, Some a -> Some a
      | Some a, None -> Some a
      | None, None -> None)
    a b

let merge_assoc_shadow a b =
  match (a, b) with
  | `Assoc a, `Assoc b -> `Assoc (merge_map_shadow a b)
  | _ -> failwith "not an assoc"

let set_assoc k v a =
  match a with
  | `Assoc a -> `Assoc (StringMap.add k v a)
  | _ -> failwith "not an assoc"

let find_opt k (e : 'a t option) =
  Option.bind e (function `Assoc es -> StringMap.find_opt k es | _ -> None)

let find_loc_opt (e : 'a t option) =
  find_opt location_key e |> Option.map loc_of_attr
