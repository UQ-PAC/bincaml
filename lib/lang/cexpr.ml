open Types
open Common
open Value

module type A = sig
  type 'a t

  val add : 'a t -> 'a t -> 'a t
  val sub : 'a t -> 'a t -> 'a t
  val mul : 'a t -> 'a t -> 'a t
  val div : 'a t -> 'a t -> 'a t
end

module BV = struct
  type bvbinop = BVAADD | BVSUB | BVOR | BVAND | BVXOR
  type intbinop = INTADD | INTSUB
  type intunop = BVNEG | BVNOT
  type bvunop = INTNEG | INTNOT

  type bvcompop =
    | BVULE
    | BVUGE
    | BVSGE
    | BVSLE
    | BVULT
    | BVUGT
    | BVSGT
    | BVSLT

  type intcompop = LE | GE | LT | GT

  type 'e intexpr =
    | BVConst of Z.t
    | BVBinary of intbinop * 'e * 'e
    | BVUnary of intunop * 'e
  [@@deriving map]

  type 'e bvexpr =
    | BVConst of PrimQFBV.t
    | BVBinary of bvbinop * 'e * 'e
    | BVUnary of bvunop * 'e
  [@@deriving map]

  type 'e predicate =
    | BoolConst of bool
    | BoolOr of 'e  list
    | BoolAnd of 'e  list
    | BoolEq of 'e * 'e
    | BoolBVComp of bvcompop * 'e bvexpr * 'e bvexpr
    | BoolIntComp of intcompop * 'e * 'e
  [@@deriving map]

  type 'e t =
    | Int of 'e intexpr
    | BV of 'e bvexpr
    | Bool of 'e predicate
  [@@deriving map]
end

module Closed = Ast_sandbox.Close(BV)

module P = Ast_sandbox.Close(struct
  type 'a t = 'a BV.predicate
  let map = BV.map_predicate
end)

open Closed

let tr = BV.Bool (BoolConst false)
let trp = BV.(BoolConst false)


let rec to_pred  = function
  | (BV.BoolConst _) as t ->  t
  | (BV.BoolAnd xs) as t ->  t
  | (BV.BoolEq (x, y)) as t ->  t
  | _ -> failwith "asd"


let pto: (P.t) BV.t -> P.t  = function
  | BV.Bool b -> (P.fix b)
  | _ -> failwith "asdjio"

let otp: t BV.predicate -> t  = function
  | b -> fix @@ BV.Bool b


let eval_pred : (bool BV.predicate -> bool) = function
  | (BV.BoolConst t) -> t
  | (BoolAnd xs) -> List.fold_left (fun x y -> x && y) true @@ xs
  | (BoolEq (x, y)) -> x = y
  | _ -> failwith "aasd"



let asd: bool BV.t -> bool = function
  | BV.Bool b -> eval_pred (b)
  | _ -> failwith ""

let dsafd = cata pto

let x = cata asd @@ fix @@
  Bool (BoolAnd [fix @@ Bool (BoolConst true); BoolConst true; BoolEq (fix tr, fix tr)])


let y =
  let open P in
  cata eval_pred @@ fix @@
  (BoolAnd [BoolConst true; BoolConst false; BoolEq (fix trp, fix trp)])
