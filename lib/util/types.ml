open Containers

(** This represents type right expressions (i.e. not declarations), we expand
    this in the future to allow declarations to be polymorphic.

    Scalar types: [Boolean], [Integer], [Bitvector], [Unit]

    Opaque uninterpreted sort: [Datatype {name; []}]

    [Top] type: greater than all other types

    [Nothing] type: less than all other types: inhabited by no values
    (synonymous with a type conflict/error)

    Function type: [Map]: used to represent maps and arrays as well

    Sum type: [DataType]

    Product type: [Record]

    Records/Datatypes are designed to fit the nonstandard extension SMTLib
    theory of datatypes:

    {:https://cvc5.github.io/docs/cvc5-1.2.1/theories/datatypes.html}

    {:https://microsoft.github.io/z3guide/docs/theories/Datatypes/} *)

type t =
  | Boolean
  | Integer
  | Bitvector of int
  | Unit
  | Top
  | Nothing
  | Map of t * t
  | DataType of (string * (string * t) list) list
[@@deriving eq, ord]

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

let bit_width = function Boolean -> Some 1 | Bitvector n -> Some n | _ -> None

(** Get the type for an opaque sort *)
let mk_sort name = DataType [ (name, []) ]

(*
  Nothing < Unit < {boolean, integer, bitvector} < Top
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
  | Boolean, Integer -> None
  | Integer, Boolean -> None
  | Boolean, Bitvector _ -> None
  | Bitvector _, Boolean -> None
  | Boolean, Boolean -> None
  | Integer, Bitvector _ -> None
  | Bitvector _, Integer -> None
  | Bitvector a, Bitvector b -> Some (Int.compare a b)
  | (DataType _ as d1), (DataType _ as d2) ->
      if equal d1 d2 then Some 0 else None
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
  | Map ((Map _ as a), (Map _ as b)) ->
      "(" ^ "(" ^ to_string a ^ ")" ^ "->" ^ "(" ^ to_string b ^ ")" ^ ")"
  | Map ((Map _ as a), b) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, (Map _ as b)) ->
      "(" ^ ("(" ^ to_string a ^ ")" ^ "->" ^ to_string b) ^ ")"
  | Map (a, b) -> "(" ^ (to_string a ^ "->" ^ to_string b) ^ ")"
  | DataType variants ->
      let pfields fields =
        List.to_string ~sep:"; " ~start:"{" ~stop:"}"
          (function name, t -> name ^ ": " ^ to_string t)
          fields
      in
      let fsort name variants =
        name ^ match variants with [] -> "" | o -> " of " ^ pfields o
      in

      List.to_string ~sep:" | " ~start:"" ~stop:""
        (function name, variants -> fsort name variants)
        variants

let%expect_test "dtp" =
  let lst =
    DataType
      [
        ("cons", [ ("head", mk_sort "E"); ("tail", mk_sort "list") ]);
        ("nil", []);
      ]
  in
  print_endline @@ to_string lst;
  [%expect {| cons of {head: E; tail: list} | nil |}]

let show (b : t) = to_string b
let pp fmt b = Format.pp_print_string fmt (show b)
