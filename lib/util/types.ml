open Containers

(** This represents type right expressions (i.e. not declarations), we expand
    this in the future to allow declarations to be polymorphic.

    Scalar types: [Boolean], [Integer], [Bitvector], [Unit]

    Opaque uninterpreted sort: [Datatype {name; []}]

    [Top] type: greater than all other types

    [Nothing] type: less than all other types: inhabited by no values
    (synonymous with a type conflict/error)

    Function type: [Map]: used to represent maps and arrays as well

    Records/Datatypes/Sort are designed to fit the nonstandard extension SMTLib
    theory of datatypes:

    {:https://cvc5.github.io/docs/cvc5-1.2.1/theories/datatypes.html}

    {:https://microsoft.github.io/z3guide/docs/theories/Datatypes/}

    For now we don't define polymorphic sorts or datatype: i.e. declarations of
    the form [(declare-sort Name 3)] and uses [(Name Int Int Bool)]. *)

type t =
  | Boolean
  | Integer
  | Bitvector of int
  | Unit
  | Top
  | Nothing
  | Map of t * t
  | Sort of string * variant list
  | Record of field2 list
  | Pointer of t * t

and variant = { variant : string; fields : field list }
and field = { field : string; typ : t } [@@deriving eq, ord]

and field2 = { offset : Z.t; size : int; t : t }

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

let bit_width = function Boolean -> Some 1 | Bitvector n -> Some n | _ -> None

(** Get the type for an opaque sort *)
let mk_sort name = Sort (name, [])

let mk_field field typ = { field; typ }
let mk_variant name fields = { variant = name; fields }

let mk_enum name (cases : string list) =
  Sort (name, List.map (fun variant -> { variant; fields = [] }) cases)

let mk_record name (fields : field list) =
  Sort (name, [ mk_variant ("Record" ^ name) fields ])

let record_field name t =
  match t with
  | Sort (sort_name, [ { variant; fields } ])
    when String.equal variant ("Record" ^ sort_name) ->
      fields
      |> List.find_map (function
        | { field; typ } when String.equal field name -> Some typ
        | _ -> None)
  | _ -> None

let mk_adt name (variants : (string * field list) list) =
  Sort
    (name, variants |> List.map (fun (variant, fields) -> { variant; fields }))

let get_field offset1 record : field2 option =
  match record with
  | Record fields ->
      List.find_opt (fun { offset; _ } -> Z.equal offset offset1) fields
  | _ -> failwith "Not record type"

(*
  Nothing < Unit < {boolean, integer, bitvector, record, pointer} < Top
  *)
let rec compare_partial (a : t) (b : t) =
  match (a, b) with
  | Top, Top -> Some 0
  | Top, _ -> Some 1
  | _, Top -> Some (-1)
  | Nothing, Nothing -> Some 0
  | Nothing, _ -> Some (-1)
  | _, Nothing -> Some 1
  | Unit, _ -> Some (-1)
  | _, Unit -> Some 1
  | Pointer (l, u), Pointer (l2, u2) -> (
      compare_partial l l2 |> function Some 0 -> compare_partial u u2 | o -> o)
  | Record fields, Record fields2 ->
      Some
        (List.compare
           (fun a b ->
             match field_equal_partial a b with Some a -> a | None -> -1)
           fields fields2)
  | Bitvector a, Bitvector b -> Some (Int.compare a b)
  | Sort (n1, _), Sort (n2, _) -> if String.equal n1 n2 then Some 0 else None
  | Integer, Integer -> Some 0
  | Map (k, v), Map (k2, v2) -> (
      compare_partial k k2 |> function Some 0 -> compare_partial v v2 | o -> o)
  | _, _ -> None

and field_equal_partial { offset; size; t }
    { offset = offset1; size = size1; t = t1 } =
  if Z.compare offset1 offset <> 0 then
    if Int.compare size size1 <> 0 then compare_partial t t1 else Some 0
  else Some 0

let leq a b =
  compare_partial a b |> function Some a when a <= 0 -> true | _ -> false

let rec uncurry ?(acc = []) (l : t) : t list * t =
  match l with
  | Map (l, ts) -> uncurry ~acc:(l :: acc) ts
  | l -> (List.rev acc, l)

let curry (args : t list) (v : t) =
  match args with
  | h :: tl -> Map (List.fold_left (fun a p -> Map (a, p)) h tl, v)
  | [] -> v

let rec to_string = function
  | Boolean -> "bool"
  | Integer -> "int"
  | Bitvector i -> "bv" ^ Int.to_string i
  | Unit -> "()"
  | Top -> "⊤"
  | Nothing -> "⊥"
  | Pointer (l, u) -> Printf.sprintf "ptr(%s, %s)" (to_string l) (to_string u)
  | Record fields ->
      List.fold_left
        (fun acc { offset; size; t } ->
          acc
          ^ Printf.sprintf "(%s, %d) : %s" (Z.to_string offset) size
              (to_string t))
        "{" fields
      ^ "}"
  | Map ((Map _ as a), (Map _ as b)) ->
      "(" ^ "(" ^ to_string a ^ ")" ^ "->" ^ "(" ^ to_string b ^ ")" ^ ")"
  | Map ((Map _ as a), b) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, (Map _ as b)) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, b) -> "(" ^ (to_string a ^ "->" ^ to_string b) ^ ")"
  | Sort (name, []) -> name
  | Sort (name, variants) ->
      let pfields fields =
        List.to_string ~sep:"; " ~start:"{" ~stop:"}"
          (function { field; typ } -> field ^ ": " ^ to_string typ)
          fields
      in
      let fsort name variants =
        name ^ match variants with [] -> "" | o -> " of " ^ pfields o
      in

      name ^ " = "
      ^ List.to_string ~sep:" | " ~start:"" ~stop:""
          (function { variant; fields } -> fsort variant fields)
          variants

let%expect_test "dtp" =
  let lst =
    Sort
      ( "list",
        [
          {
            variant = "cons";
            fields =
              [
                { field = "head"; typ = mk_sort "E" };
                { field = "tail"; typ = mk_sort "list" };
              ];
          };
          { variant = "nil"; fields = [] };
        ] )
  in
  let rc =
    mk_record "recs" [ mk_field "a" (Bitvector 12); mk_field "b" Boolean ]
  in
  print_endline @@ to_string lst;
  print_endline @@ to_string rc;
  [%expect {|
    list = cons of {head: E; tail: list} | nil
    recs = Recordrecs of {a: bv12; b: bool}
    |}]

let show (b : t) = to_string b
let pp fmt b = Format.pp_print_string fmt (show b)
