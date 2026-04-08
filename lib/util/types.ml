open Containers
module StringMap = Map.Make (String)

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
  | Integer  (** mathematical integer type (Z)*)
  | Bitvector of int  (** bitvector of a given width *)
  | Unit  (** type inhabited by unit value *)
  | Top  (** greatest type *)
  | Nothing  (** least type / empty set *)
  | Map of t * t  (** function type *)
  | Sort of string * variant list  (** An Algebraic datatype *)
  | Struct of string * record_field StringMap.t
      (** a struct is a product type of a known layout that is representible as
          a finite byte/bit sequence *)
  | Pointer of pointer  (** pointer type *)
  | Variable of string (* Possibly a name of a type declartion *)

and variant = { variant : string; fields : field list }
and field = { field : string; typ : t } [@@deriving eq, ord]
and record_field = { offset : Z.t; typ : t } [@@deriving eq, ord]

(*
  Lower type represents types the pointer could load
  Upper type represents types the pointer could store
*)
and pointer = { name : string; lower : t; upper : t } [@@deriving eq, ord]

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

let bit_width = function Boolean -> Some 1 | Bitvector n -> Some n | _ -> None

(** Get the type for an opaque sort *)
let mk_sort name = Sort (name, [])

(* ADT not Record type *)
let mk_field field typ = { field; typ }
let mk_variant name fields = { variant = name; fields }

let mk_enum name (cases : string list) =
  Sort (name, List.map (fun variant -> { variant; fields = [] }) cases)

let mk_adt_record name (fields : field list) =
  Sort (name, [ mk_variant ("Record" ^ name) fields ])

let adt_record_field name t =
  match t with
  | Sort (_, [ { fields; _ } ]) ->
      fields
      |> List.find_map (function
        | { field; typ } when String.equal field name -> Some typ
        | _ -> None)
  | _ -> None

let mk_adt name (variants : (string * field list) list) =
  Sort
    (name, variants |> List.map (fun (variant, fields) -> { variant; fields }))

let bv_min_width_for_nat n = Bitvector (Z.of_int n |> Z.numbits)

let struct_field field_name record : record_field =
  match record with
  | Struct (_, fields) -> (
      match StringMap.find_opt field_name fields with
      | None -> failwith @@ "No field at offset " ^ field_name
      | Some t -> t)
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
  | Pointer { lower; upper; _ }, Pointer { lower = lower1; upper = upper1; _ }
    -> (
      compare_partial lower lower1 |> function
      | Some 0 -> compare_partial upper upper1
      | o -> o)
  | Struct (_, fields), Struct (_, fields2) ->
      Some
        (StringMap.compare
           (fun ({ typ = a; _ } : record_field) { typ = b; _ } ->
             match compare_partial a b with Some a -> a | None -> -1)
           fields fields2)
  | Bitvector a, Bitvector b -> Some (Int.compare a b)
  | Sort (n1, _), Sort (n2, _) -> if String.equal n1 n2 then Some 0 else None
  | Integer, Integer -> Some 0
  | Map (k, v), Map (k2, v2) -> (
      compare_partial k k2 |> function Some 0 -> compare_partial v v2 | o -> o)
  | _, _ -> None

let leq a b =
  compare_partial a b |> function Some a when a <= 0 -> true | _ -> false

let rec uncurry ?(acc = []) (l : t) : t list * t =
  match l with
  | Map (l, ts) -> uncurry ~acc:(l :: acc) ts
  | l -> (List.rev acc, l)

let curry (args : t list) (v : t) =
  List.fold_left (fun a p -> Map (p, a)) v args

let rec to_string = function
  | Boolean -> "bool"
  | Integer -> "int"
  | Bitvector i -> "bv" ^ Int.to_string i
  | Unit -> "()"
  | Top -> "⊤"
  | Nothing -> "⊥"
  | Variable name -> name
  | Pointer { lower; upper; _ } ->
      Printf.sprintf "ptr(%s, %s)" (to_string lower) (to_string upper)
  | Struct (_, record) ->
      "{"
      ^ (StringMap.bindings record
        |> List.map (fun (k, ({ typ = v; offset } : record_field)) ->
            Printf.sprintf "\"%s\": (%s, %s)" k (to_string v)
              (Z.to_string offset))
        |> String.concat ", ")
      ^ "}"
  | Map ((Map _ as a), (Map _ as b)) ->
      "(" ^ "(" ^ to_string a ^ ")" ^ "->" ^ "(" ^ to_string b ^ ")" ^ ")"
  | Map ((Map _ as a), b) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, (Map _ as b)) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, b) -> "(" ^ (to_string a ^ "->" ^ to_string b) ^ ")"
  | Sort (name, _) -> name

let to_string_decl = function
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
  | a -> to_string a

let to_string_rexp = function
  | ( Boolean | Integer | Bitvector _ | Unit | Top | Nothing | Variable _
    | Pointer _ | Struct _ | Map _ ) as e ->
      to_string e
  | Sort (name, _) -> name

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
    mk_adt_record "recs" [ mk_field "a" (Bitvector 12); mk_field "b" Boolean ]
  in
  print_endline @@ to_string lst;
  print_endline @@ to_string rc;
  [%expect {|
    list
    recs
    |}]

let show (b : t) = to_string b

let show_pointer { lower; upper; name } =
  Printf.sprintf "%s : { lower = %s; upper = %s }" name (show lower)
    (show upper)

let pp fmt b = Format.pp_print_string fmt (show b)

let pp_pointer fmt { lower; upper; name } =
  Format.fprintf fmt "%s : { lower = %s; upper = %s }" name (show lower)
    (show upper)
