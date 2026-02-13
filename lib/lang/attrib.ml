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

let rec attrib_pretty pretty_expr (e : 'e t) : Containers_pp.t =
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
      @@ bracket "[" (fill (text ";" ^ newline) (List.map attrib_pretty s)) "]"
  | `Assoc sm ->
      let pairs =
        StringMap.to_list sm
        |> List.map (function k, v -> text k ^ text " = " ^ attrib_pretty v)
      in
      let int = fill (text ";" ^ newline) pairs in
      nest 2 (bracket "{" int "}")

type 'e attrib_map = 'e t StringMap.t [@@deriving eq, ord]

let empty : 'e attrib_map = StringMap.empty

type loc = int * int

let attr_of_loc l =
  let s, e = l in
  `List [ `CamlInt s; `CamlInt e ]

let loc_of_attr l =
  match l with
  | `List [ `CamlInt s; `CamlInt e ] -> (s, e)
  | _ -> failwith "bad structure"

let find a (k : string) =
  (match a with
    | `Assoc ks -> List.find_opt (fun (v, vlue) -> String.equal k v) ks)
  |> Option.map snd

let merge_map_shadow (a : 'a attrib_map) (b : 'a attrib_map) =
  StringMap.merge
    (fun k l r ->
      match (l, r) with
      | _, Some a -> Some a
      | Some a, None -> Some a
      | None, None -> None)
    a b
