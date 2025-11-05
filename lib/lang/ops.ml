open Common
open Containers
open Value

module Maps = struct
  (* map, value -> result *)
  type binary = [ `MapIndex ] [@@deriving show { with_path = false }, eq, ord]
  type intrin = [ `MapUpdate ] [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #binary as b -> show_binary b
    | #intrin as b -> show_intrin b

  let hash = Hashtbl.hash
end

module LogicalOps = struct
  type const = [ `Bool of bool ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `BoolNOT ] [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `EQ | `NEQ | `IMPLIES ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `AND | `OR ] [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b

  let eval_const = function `Bool b -> b
  let eval_unary op = match op with `BoolNOT -> not

  let eval_binary (op : binary) =
    match op with
    | `EQ -> Bool.equal
    | `NEQ -> fun a b -> not (Bool.equal a b)
    | `IMPLIES -> fun a b -> b || not a

  let eval_intrin (op : intrin) =
    match op with
    | `OR -> List.fold_left (fun a b -> a || b) false
    | `AND -> List.fold_left (fun a b -> a && b) true

  let hash_boolop = Hashtbl.hash
end

module BVOps = struct
  type const = [ `Bitvector of PrimQFBV.t ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_const = function `Bitvector b -> b

  type unary_bool = [ `BOOLTOBV1 ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary_unif =
    [ `BVNOT
    | `BVNEG
    | `ZeroExtend of int
    | `SignExtend of int
    | `Extract of int * int ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ unary_bool | unary_unif ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_unary_bool (o : unary_bool) =
    match o with
    | `BOOLTOBV1 -> (
        function true -> PrimQFBV.true_bv | false -> PrimQFBV.false_bv)

  let eval_unary_unif (o : unary_unif) =
    match o with
    | `BVNEG -> PrimQFBV.neg
    | `SignExtend sz -> PrimQFBV.sign_extend ~extension:sz
    | `BVNOT -> PrimQFBV.bitnot
    | `ZeroExtend sz -> PrimQFBV.zero_extend ~extension:sz
    | `Extract (hi, lo) -> fun b -> PrimQFBV.extract hi lo b

  let eval_unary_bv (o : unary_unif) =
    match o with
    | `BVNEG -> PrimQFBV.neg
    | `SignExtend sz -> PrimQFBV.sign_extend ~extension:sz
    | `BVNOT -> PrimQFBV.bitnot
    | `ZeroExtend sz -> PrimQFBV.zero_extend ~extension:sz
    | `Extract (hi, lo) -> fun b -> PrimQFBV.extract hi lo b

  type binary_pred = [ `EQ | `BVULT | `BVULE | `BVSLT | `BVSLE ]
  [@@deriving show { with_path = false }, eq, ord]
  (** ops with type bv -> bv -> bool *)

  let eval_binary_pred (op : [< binary_pred ]) =
    match op with
    | `EQ -> PrimQFBV.equal
    | `BVSLE -> PrimQFBV.sle
    | `BVULT -> PrimQFBV.ult
    | `BVULE -> PrimQFBV.ule
    | `BVSLT -> PrimQFBV.slt

  type binary_unif =
    [ `BVAND
    | `BVOR
    | `BVADD
    | `BVMUL
    | `BVUDIV
    | `BVUREM
    | `BVSHL
    | `BVLSHR
    | `BVNAND
    | `BVXOR
    | `BVSUB
    | `BVSDIV
    | `BVSREM
    | `BVSMOD
    | `BVASHR ]
  [@@deriving show { with_path = false }, eq, ord]
  (** ops with type bv -> bv -> bv *)

  let eval_binary_unif (op : binary_unif) =
    let open PrimQFBV in
    match op with
    | `BVSREM -> srem
    | `BVSDIV -> sdiv
    | `BVADD -> add
    | `BVASHR -> ashr
    | `BVSMOD -> smod
    | `BVSHL -> shl
    | `BVNAND -> fun a b -> bitnot (bitand a b)
    | `BVUREM -> urem
    | `BVXOR -> bitxor
    | `BVOR -> bitor
    | `BVSUB -> sub
    | `BVUDIV -> udiv
    | `BVLSHR -> lshr
    | `BVAND -> bitand
    | `BVMUL -> mul

  type binary = [ binary_pred | binary_unif ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `BVAND | `BVOR | `BVADD | `BVXOR | `BVConcat ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_intrin (op : intrin) args =
    let ev f =
      match args with
      | h :: tl -> List.fold_left f h args
      | _ -> raise (Invalid_argument "op needs at least two args")
    in
    match op with
    | `BVADD -> ev PrimQFBV.add
    | `BVXOR -> ev PrimQFBV.bitxor
    | `BVOR -> ev PrimQFBV.bitor
    | `BVAND -> ev PrimQFBV.bitand
    | `BVConcat -> ev PrimQFBV.concat

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b
end

module IntOps = struct
  type const = [ `Integer of PrimInt.t ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `INTNEG ] [@@deriving show { with_path = false }, eq, ord]

  let eval_unary (u : unary) = match u with `INTNEG -> Z.neg

  type binary_unif = [ `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary_pred = [ `EQ | `INTLT | `INTLE ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_binary_unif (op : binary_unif) =
    match op with
    | `INTDIV -> Z.div
    | `INTADD -> Z.add
    | `INTMOD -> Z.( mod )
    | `INTMUL -> Z.mul
    | `INTSUB -> Z.sub

  let eval_binary_pred (op : binary_pred) =
    match op with `EQ -> Z.equal | `INTLT -> Z.lt | `INTLE -> Z.leq

  type binary = [ binary_unif | binary_pred ]
  [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b
end

module Spec = struct
  type unary = [ `Forall | `Old | `Exists ]
  [@@deriving show { with_path = false }, eq, ord]

  let hash_intrin a = Hashtbl.hash a
end

module AllOps = struct
  type const = [ IntOps.const | BVOps.const | LogicalOps.const ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ IntOps.unary | BVOps.unary | Spec.unary | LogicalOps.unary ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary = [ IntOps.binary | BVOps.binary | LogicalOps.binary ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ BVOps.intrin | LogicalOps.intrin ]
  [@@deriving show { with_path = false }, eq, ord]

  type op_fun_type =
    | Fun of { args : Types.t list; ret : Types.t }
    (* list of expected type equalities *)
    | Conflict of (Types.t * string) list

  let ret_type_const (o : const) =
    let open Types in
    let return ret = Fun { args = []; ret } in
    match o with
    | `Bool _ -> return Boolean
    | `Integer _ -> return Integer
    | `Bitvector v -> return (Bitvector (PrimQFBV.size v))

  let ret_type_unary (o : unary) a =
    let open Types in
    let return ret = Fun { args = [ a ]; ret } in
    match o with
    | `SignExtend sz -> (
        match a with
        | Bitvector s -> return @@ Bitvector (sz + s)
        | o -> Conflict [ (o, "<bitvector") ])
    | `ZeroExtend sz -> (
        match a with
        | Bitvector s -> return @@ Bitvector (sz + s)
        | o -> Conflict [ (o, "<bitvector") ])
    | `Forall -> return Boolean
    | `BVNEG -> return a
    | `INTNEG -> return Integer
    | `Old -> return a
    | `BoolNOT -> return Boolean
    | `Exists -> return Boolean
    | `BVNOT -> return a
    | `BOOLTOBV1 -> return @@ Bitvector 1
    | `Extract (hi, lo) -> return (Bitvector (hi - lo))

  let ret_type_bin (o : binary) l r =
    let open Types in
    let return ret = Fun { args = [ l; r ]; ret } in
    match o with
    | `EQ | `NEQ | `BVULT | `BVULE | `BVSLT | `BVSLE | `INTLT | `IMPLIES
    | `INTLE ->
        return Boolean
    | `INTDIV | `INTADD | `INTMUL | `INTSUB | `INTMOD -> return Integer
    | `BVAND | `BVOR | `BVADD | `BVMUL | `BVUDIV | `BVUREM | `BVSHL | `BVLSHR
    | `BVNAND | `BVXOR | `BVSUB | `BVSDIV | `BVSREM | `BVSMOD | `BVASHR ->
        return l

  let ret_type_intrin (o : intrin) args =
    let open Types in
    let return ret = Fun { args; ret } in
    match o with
    | `BVADD -> return @@ List.hd args
    | `BVOR -> return @@ List.hd args
    | `BVXOR -> return @@ List.hd args
    | `BVAND -> return @@ List.hd args
    | `OR -> return Boolean
    | `AND -> return Boolean
    | `BVConcat ->
        let x =
          List.filter_map
            (function Bitvector _ -> None | o -> Some (o, "<bitvector"))
            args
        in
        if List.length x > 0 then Conflict x
        else
          let w =
            List.fold_left
              (fun (a : int) (i : Types.t) ->
                match i with
                | Bitvector i -> a + i
                | _ -> failwith "unreachable")
              0 args
          in
          return (Bitvector w)

  (** ops returning booleans *)

  let to_string (op : [< const | unary | binary | intrin ]) =
    match op with
    | `BVADD -> "bvadd"
    | `BVSREM -> "bvsrem"
    | `BVSDIV -> "bvsdiv"
    | `Forall -> "forall"
    | `BVNEG -> "bvneg"
    | `Bool true -> "true"
    | `Bool false -> "false"
    | `BVASHR -> "bvashr"
    | `NEQ -> "neq"
    | `INTNEG -> "intneg"
    | `Old -> "old"
    | `BVMUL -> "bvmul"
    | `BVSHL -> "bvshl"
    | `Extract (hi, lo) -> Printf.sprintf "extract_%d_%d " hi lo
    | `INTDIV -> "intdiv"
    | `Exists -> "exists"
    | `SignExtend n -> Printf.sprintf "sign_extend_%d" n
    | `ZeroExtend n -> Printf.sprintf "zero_extend_%d" n
    | `EQ -> "eq"
    | `INTADD -> "intadd"
    | `BVNAND -> "bvnand"
    | `BVSLE -> "bvsle"
    | `BVUREM -> "bvurem"
    | `BVNOT -> "bvnot"
    | `Integer i -> PrimInt.to_string i
    | `BVXOR -> "bvxor"
    | `BVOR -> "bvor"
    | `BVConcat -> "bvconcat"
    | `BVSUB -> "bvsub"
    | `BVUDIV -> "bvudiv"
    | `BVLSHR -> "bvlshr"
    | `INTMOD -> "intmod"
    | `BVAND -> "bvand"
    | `INTMUL -> "intmul"
    | `Bitvector z -> PrimQFBV.to_string z
    | `BVSMOD -> "bvsmod"
    | `INTLT -> "intlt"
    | `IMPLIES -> "implies"
    | `OR -> "boolor"
    | `INTLE -> "intle"
    | `BVULT -> "bvult"
    | `AND -> "booland"
    | `INTSUB -> "intsub"
    | `BVULE -> "bvule"
    | `BOOLTOBV1 -> "booltobv1"
    | `BoolNOT -> "boolnot"
    | `BVSLT -> "bvslt"

  let eval_equal (a : const) (b : const) =
    match (a, b) with
    | `Bitvector a, `Bitvector b -> PrimQFBV.equal a b
    | `Integer a, `Integer b -> Z.equal a b
    | `Bool a, `Bool b -> Bool.equal a b
    | _, _ -> false

  let hash_const = Hashtbl.hash
  let hash_unary = Hashtbl.hash
  let hash_binary = Hashtbl.hash
  let hash_intrin = Hashtbl.hash
end
