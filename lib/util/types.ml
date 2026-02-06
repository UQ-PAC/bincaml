open Containers

type t =
  | Boolean
  | Integer
  | Bitvector of int
  | Unit
  | Top
  | Nothing
  | Map of t * t
[@@deriving eq]

let bv i = Bitvector i
let int = Integer
let bool = Boolean

type func_type = { args : t list; return : t }

let bit_width = function Boolean -> Some 1 | Bitvector n -> Some n | _ -> None

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
  | Integer, Integer -> Some 0
  | Map (k, v), Map (k2, v2) -> (
      compare_partial k k2 |> function Some 0 -> compare_partial v v2 | o -> o)
  | Map _, _ -> None
  | _, Map _ -> None

let compare a b = compare_partial a b |> Option.get_or ~default:0

let rec curry ?(acc = []) (l : t) : t list * t =
  match l with Map (l, ts) -> curry ~acc:(l :: acc) ts | l -> (List.rev acc, l)

let uncurry (args : t list) (v : t) =
  match args with
  | h :: tl -> List.fold_left (fun a p -> Map (a, p)) h tl
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

let show (b : t) = to_string b
let pp fmt b = Format.pp_print_string fmt (show b)
