open Common

(** associative datastructure for attributes *)

type t =
  [ `String of string
  | `Assoc of t StringMap.t
  | `Bool of bool
  | `Integer of Z.t
  | `CamlInt of int
  | `Bitvector of Bitvec.t
  | `List of t list ]
[@@deriving eq, ord]

let is_internal_key = String.starts_with ~prefix:"__"
let location_key = "__text_range"
let triggers_key = ".triggers"

let rec attrib_pretty ?(show_internal = false) (e : t) : Containers_pp.t =
  let open Containers_pp in
  match e with
  | `String s -> text_quoted s
  | `CamlInt s -> int s
  | `Bool b -> bool b
  | `Bitvector bv -> text @@ Bitvec.to_string bv
  | `Integer bv -> text @@ Z.to_string bv
  | `List s ->
      nest 2
      @@ bracket "[ "
           (fill
              (text ";" ^ newline)
              (List.map (attrib_pretty ~show_internal) s))
           " ]"
  | `Assoc sm ->
      let pairs =
        sm
        |> StringMap.filter (fun i _ ->
            show_internal || (not @@ is_internal_key i))
        |> StringMap.bindings
        |> List.map (function k, v ->
            text k ^ text " = " ^ (attrib_pretty ~show_internal) v)
      in
      let int = fill (text ";" ^ newline) pairs in
      nest 2 (bracket "{ " int " }")

type attrib_map = t StringMap.t [@@deriving eq, ord]

let to_string ?show_internal e =
  attrib_pretty ?show_internal e |> Containers_pp.Pretty.to_string ~width:80

let empty : attrib_map = StringMap.empty

type loc = int * int

let attr_of_loc l =
  let s, e = l in
  StringMap.singleton location_key (`List [ `CamlInt s; `CamlInt e ])

let loc_of_attr l =
  match l with
  | `List [ `CamlInt s; `CamlInt e ] -> (s, e)
  | _ -> failwith "bad structure"

let merge_map_shadow (a : attrib_map) (b : attrib_map) =
  StringMap.merge
    (fun _ l r ->
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

let find_opt k (e : t option) =
  Option.bind e (function `Assoc es -> StringMap.find_opt k es | _ -> None)

let find_str_opt k (e : t option) =
  let open Option in
  (e >>= function `Assoc es -> StringMap.find_opt k es | _ -> None)
  >>= function
  | `String s -> Some s
  | _ -> None

let find_int_opt k (e : t option) =
  let open Option in
  (e >>= function `Assoc es -> StringMap.find_opt k es | _ -> None)
  >>= function
  | `Integer i -> Some i
  | _ -> None

let find_loc_opt (e : t option) =
  find_opt location_key e |> Option.map loc_of_attr
