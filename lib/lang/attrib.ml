open Common

(** associative datastructure for attributes *)

type t =
  [ `String of string
  | `Assoc of t StringMap.t
  | `Bool of bool
  | `Integer of Z.t
  | `Bitvector of Bitvec.t
  | `List of t list ]
[@@deriving eq, ord]

let rec to_sexp (p : t) : Containers.Sexp.t =
  match p with
  | `String n -> `Atom (Printf.sprintf "\"%S\"" n)
  | `Assoc n ->
      StringMap.to_list n
      |> List.map (Pair.map (fun k -> `Atom k) to_sexp)
      |> List.map (fun (k, v) -> `List [ k; v ])
      |> fun l -> `List l
  | `Bool true -> `Atom "true"
  | `Bool false -> `Atom "false"
  | `Integer i -> `Atom (Z.to_string i)
  | `Bitvector i -> `Atom (Bitvec.to_string i)
  | `List ls -> `List (List.map to_sexp ls)

let rec of_sexp (p : Containers.Sexp.t) : t =
  let seq o f = match o with None -> f | Some v -> Some v in
  let otry f = try Some (f ()) with e -> None in

  let ( <|> ) = seq in
  match p with
  | `List vs ->
      let assoc =
        List.fold_left
          (function
            | None -> fun _ -> None
            | Some acc -> (
                function
                | `List [ `Atom n; v ] when String.starts_with ~prefix:"." n ->
                    Some (StringMap.add n (of_sexp v) acc)
                | _ -> None))
          (Some StringMap.empty) vs
      in
      let assoc =
        Option.map
          (fun o -> if StringMap.is_empty o then `List [] else `Assoc o)
          assoc
      in
      Option.get_or ~default:(`List (List.map of_sexp vs)) assoc
  | `Atom v ->
      let p =
        None
        <|> (match v with
          | "true" -> Some (`Bool true)
          | "false" -> Some (`Bool false)
          | _ -> None)
        <|> otry (fun () ->
            let n = Z.of_string v in
            `Integer n)
        <|> otry (fun () -> `Bitvector (Bitvec.of_string v))
        <|> Some (`String (Scanf.unescaped v))
      in
      Option.get_exn_or ("failed to parse: " ^ v) p

let is_internal_key = String.starts_with ~prefix:"__"
let location_key = "__text_range"
let triggers_key = ".triggers"

let rec attrib_pretty ?(show_internal = false) (e : t) : Containers_pp.t =
  let open Containers_pp in
  match e with
  | `String s -> text_quoted s
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

let to_attrib_map : t -> attrib_map = function
  | `Assoc x -> x
  | _ -> invalid_arg "to_attrib_map: not an `Assoc"

type loc = int * int
(** a text token range; beginchar, endchar*)

let int_val = Z.of_int %> fun c -> `Integer c

let attr_of_loc l =
  let s, e = l in
  StringMap.singleton location_key (`List [ int_val s; int_val e ])

let join_range (a, b) (c, d) =
  (List.fold_left min a [ b; c; d ], List.fold_left max a [ b; c; d ])

let join_range_z (a, b) (c, d) =
  (List.fold_left Z.min a [ b; c; d ], List.fold_left Z.max a [ b; c; d ])

let loc_of_attr l =
  match l with
  | `List [ `Integer s; `Integer e ] -> (Z.to_int s, Z.to_int e)
  | _ -> failwith "bad structure"

let join_map_locs (a : attrib_map) (b : attrib_map) =
  StringMap.merge
    (fun k l r ->
      match (l, r) with
      | ( Some (`List [ `Integer a; `Integer b ]),
          Some (`List [ `Integer c; `Integer d ]) )
        when String.equal k location_key ->
          Some
            (let a, b = join_range_z (a, b) (c, d) in
             `List [ `Integer a; `Integer b ])
      | _, Some a -> Some a
      | Some a, None -> Some a
      | None, None -> None)
    a b

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

let find_int_map k (m : attrib_map) =
  match StringMap.get k m with Some (`Integer n) -> Some n | _ -> None
