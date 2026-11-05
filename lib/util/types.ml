open Containers
open Fun
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
  | Map of t * t  (** abstrct map type *)
  | Function of t * t  (** function type *)
  | Record of (string * t) list
  | Variant of (string * t list) list
  | NewType of t list * string (* opaque type constructor *)
  | Variable of string (* Possibly a name of a type declartion *)
[@@deriving eq, ord]

(* named type *)
type type_decl = string * t
type mem_layout = Scalar of int | Vector of mem_layout list

module TS = List.Traverse (Option)

let rec size_of_layout vs =
  match vs with
  | Scalar s -> s
  | Vector vs -> List.fold_left (fun acc v -> acc + size_of_layout v) 0 vs

let variant_to_record (cases : (string * t list) list) =
  let tag_bits = Z.of_int @@ List.length cases |> Z.numbits in
  let fs = [ ("tag", Bitvector tag_bits) ] in
  let cases =
    List.map
      (fun (k, v) ->
        let fs =
          List.mapi (fun ind t -> (Int.to_string ind, t)) v |> fun x -> Record x
        in
        (k, fs))
      cases
  in
  Record (fs @ cases)

let rec layout_of_typ t =
  match t with
  | Boolean -> Some (Scalar 1)
  | Bitvector n -> Some (Scalar n)
  | Record fields ->
      TS.map_m (fun (fname, ftyp) -> layout_of_typ ftyp) fields
      |> Option.map (fun m -> Vector m)
  | Map _ | Integer | Variant _ -> None
  | Unit | Nothing | Top | Function _ | NewType _ | Variable _ -> None

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

(** Get the type for an opaque sort *)
let mk_sort name = NewType ([], name)

(* ADT not Record type *)
let mk_field field typ = (field, typ)
let mk_variant name fields = (name, fields)

let mk_enum (cases : string list) =
  Variant (List.map (fun variant -> (variant, [])) cases)

let mk_adt_record name (fields : (string * t) list) = Record fields

let adt_record_field name t =
  match t with
  | Record fields ->
      fields
      |> List.find_map (function
        | field, typ when String.equal field name -> Some typ
        | _ -> None)
  | _ -> None

let mk_adt (variants : (string * t list) list) = Variant variants
let bv_min_width_for_nat n = Bitvector (Z.of_int n |> Z.numbits)
let bit_width = layout_of_typ %> Option.map size_of_layout

(*
  Nothing < Unit < {boolean, integer, bitvector, record, pointer} < Top
  *)
let rec compare_partial (a : t) (b : t) =
  let equal a b = compare_partial a b |> Option.equal Int.equal (Some 0) in
  match (a, b) with
  | Top, Top -> Some 0
  | Top, _ -> Some 1
  | _, Top -> Some (-1)
  | Nothing, Nothing -> Some 0
  | Nothing, _ -> Some (-1)
  | _, Nothing -> Some 1
  | Unit, _ -> Some (-1)
  | _, Unit -> Some 1
  | Bitvector a, Bitvector b -> Some (Int.compare a b)
  | Integer, Integer -> Some 0
  | Map (k, v), Map (k2, v2) -> (
      compare_partial k k2 |> function Some 0 -> compare_partial v v2 | o -> o)
  | Function (k, v), Function (k2, v2) -> (
      compare_partial k k2 |> function Some 0 -> compare_partial v v2 | o -> o)
  | NewType (ts, n), NewType (ts', n') ->
      if
        List.length ts = List.length ts'
        && String.equal n n' && List.equal equal ts ts'
      then Some 0
      else None
  | Record fields, Record fields' ->
      if List.equal (Pair.equal String.equal equal) fields fields' then Some 0
      else None
  | Variant fields, Variant fields' ->
      if List.equal (Pair.equal String.equal (List.equal equal)) fields fields'
      then Some 0
      else None
  | _, _ -> None

let leq a b =
  compare_partial a b |> function Some a when a <= 0 -> true | _ -> false

let rec uncurry ?(acc = []) (l : t) : t list * t =
  match l with
  | Function (l, ts) -> uncurry ~acc:(l :: acc) ts
  | l -> (List.rev acc, l)

let curry (args : t list) (v : t) =
  List.fold_left (fun a p -> Function (p, a)) v args

let rec to_string = function
  | Boolean -> "bool"
  | Integer -> "int"
  | Bitvector i -> "bv" ^ Int.to_string i
  | Unit -> "()"
  | Top -> "⊤"
  | Nothing -> "⊥"
  | Variable name -> name
  | Map (b, a) -> "(" ^ to_string b ^ "[" ^ to_string a ^ "])"
  | Function ((Function _ as a), (Function _ as b)) ->
      "(" ^ "(" ^ to_string a ^ ")" ^ "->" ^ "(" ^ to_string b ^ ")" ^ ")"
  | Function ((Function _ as a), b) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Function (a, (Function _ as b)) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Function (a, b) -> "(" ^ (to_string a ^ "->" ^ to_string b) ^ ")"
  | NewType ([], name) -> name
  | NewType (ls, name) ->
      List.to_string ~start:"(" ~stop:")" to_string ls ^ " " ^ name
  | Record fields ->
      List.to_string ~sep:"; " ~start:"{" ~stop:"}"
        (function field, typ -> field ^ ": " ^ to_string typ)
        fields
  | Variant variants ->
      let pcase vs =
        List.to_string ~start:"(" ~stop:")" ~sep:", " to_string vs
      in
      let fsort name variants =
        name ^ match variants with [] -> "" | o -> " of " ^ pcase o
      in
      List.to_string ~sep:" | " ~start:"" ~stop:""
        (function variant, fields -> fsort variant fields)
        variants

let to_string_decl name typ = "type " ^ name ^ " = " ^ to_string typ
let to_string_rexp ty = to_string ty

let%expect_test "dtp" =
  let lst =
    let lst t = NewType ([ t ], "list") in
    let vt = NewType ([], "E") in
    Variant
      [ ("cons", [ Record [ ("head", vt); ("tail", lst vt) ] ]); ("nil", []) ]
  in
  let rc =
    mk_adt_record "recs" [ mk_field "a" (Bitvector 12); mk_field "b" Boolean ]
  in
  print_endline @@ to_string lst;
  print_endline @@ to_string rc;
  [%expect
    {|
    cons of ({head: E; tail: (E) list}) | nil
    {a: bv12; b: bool}
    |}]

let show (b : t) = to_string b

let%expect_test "complex_type" =
  print_endline @@ to_string
  @@ Variant
       [
         ( "MemEncoding",
           [
             Record
               [
                 mk_field "alloc_live" (Map (Bitvector 64, Bitvector 2));
                 mk_field "alloc_size" (Map (Bitvector 64, Bitvector 64));
                 mk_field "addr_is_heap" (Map (Bitvector 64, Boolean));
               ];
           ] );
       ];
  [%expect
    {| MemEncoding of ({alloc_live: (bv64[bv2]); alloc_size: (bv64[bv64]); addr_is_heap: (bv64[bool])}) |}]

let show_pointer = function
  | NewType ([ lo; hi ], "ptr") ->
      Printf.sprintf "{ lower = %s; upper = %s }" (show lo) (show hi)
  | _ -> failwith "not ptr"

let pp fmt b = Format.pp_print_string fmt (show b)
let pp_pointer fmt p = Format.fprintf fmt "%s" (show_pointer p)
