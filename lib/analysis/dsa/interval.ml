open Lang
open Common
open Wrapped_intervals

(* Offset interval should never overflow in userspace code, so it is fine to
   not use wrapped intervals within the DS graph itself. *)

type t = Top | Interval of Z.t * Z.t | Bot
[@@deriving eq, ord, show { with_path = false }]

open Z

let show = function
  | Top -> "Top"
  | Bot -> "Bot"
  | Interval (a, b) -> Printf.sprintf "[%s, %s]" (Z.to_string a) (Z.to_string b)

let dbg = function
  | Top -> "Top"
  | Bot -> "Bot"
  | Interval (a, b) ->
      Printf.sprintf "Interval.Interval (Z.of_int (%s), Z.of_int (%s))"
        (Z.to_string a) (Z.to_string b)

let start = function Top | Bot -> None | Interval (a, _) -> Some a

let of_wint (i : WrappedIntervalsLattice.t) =
  match i with
  | Bot -> Bot
  | Interval { lower; upper } when Bitvec.sle lower upper ->
      Interval (Bitvec.to_signed_bigint lower, Bitvec.to_signed_bigint upper)
  | _ -> Top

let pad_with_size size = function
  | Interval (a, b) -> Interval (a, b + Z.of_int (Int.( / ) size 8) - Z.one)
  | otherwise -> otherwise

let left_of i j =
  match (i, j) with
  | Bot, _ | Top, _ | _, Bot | _, Top -> false
  | Interval (_, b), Interval (c, _) -> lt b c

let right_of i j = left_of j i
let disjoint i j = left_of i j || right_of i j
let overlap i j = not @@ disjoint i j

let elem x i =
  match i with
  | Bot -> false
  | Top -> true
  | Interval (a, b) -> Z.leq a x && Z.leq x b

let subset i j =
  match (i, j) with
  | Bot, Bot | Top, Top | Bot, _ | _, Top -> true
  | _, Bot | Top, _ -> false
  | Interval (a, b), Interval (c, d) ->
      Z.leq c a && Z.leq a d && Z.leq c b && Z.leq b d

let join i j =
  match (i, j) with
  | Bot, i | i, Bot -> i
  | Top, _ | _, Top -> Top
  | Interval (a, b), Interval (c, d) -> Interval (min a c, max b d)

let shift off = function
  | Bot -> Bot
  | Top -> Top
  | Interval (a, b) -> Interval (a + off, b + off)

let width = function
  | Bot -> None
  | Top -> None
  | Interval (a, b) -> Some (Z.to_int (b - a + one))
