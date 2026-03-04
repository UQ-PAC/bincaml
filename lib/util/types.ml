open Containers

type t =
  | Boolean
  | Integer
  | Bitvector of int
  | Unit
  | Top
  | Nothing
  | Map of t * t
  | DataType of { name : string; variants : (string * t list) list }
  | Record of { name : string; fields : (string * t) list }
[@@deriving eq, ord]

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

let bit_width = function Boolean -> Some 1 | Bitvector n -> Some n | _ -> None
let mk_sort name = DataType { name; variants = [] }

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
  | (Record _ as d1), (Record _ as d2) -> if equal d1 d2 then Some 0 else None
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
  | Record { name; fields } ->
      name ^ " = "
      ^ List.to_string ~sep:"; " ~start:"{" ~stop:"}"
          (function name, t -> name ^ ": " ^ to_string t)
          fields
  | DataType { name; variants } -> (
      match variants with
      | [] -> name
      | variants ->
          name ^ " = "
          ^ List.to_string ~sep:" | " ~start:"" ~stop:""
              (function
                | name, ts -> (
                    name
                    ^
                    match ts with
                    | [] -> ""
                    | o ->
                        " of "
                        ^ List.to_string ~sep:", " ~start:"(" ~stop:")"
                            to_string o))
              variants)

let%expect_test "dtp" =
  let dt =
    Record
      {
        name = "recordn";
        fields = [ ("cons", Integer); ("id", mk_sort "String") ];
      }
  in
  let lst =
    DataType
      {
        name = "list";
        variants = [ ("cons", [ mk_sort "t"; mk_sort "list" ]); ("nil", []) ];
      }
  in
  print_endline @@ to_string dt;
  print_endline @@ to_string lst

let show (b : t) = to_string b
let pp fmt b = Format.pp_print_string fmt (show b)
