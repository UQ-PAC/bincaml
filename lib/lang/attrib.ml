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

type 'e attrib_map = 'e t StringMap.t [@@deriving eq, ord]
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
