module Value = struct
  type integer = Z.t

  let pp_integer = Z.pp_print
  let show_integer i = Z.to_string i
  let equal_integer i j = Z.equal i j

  type bitvector = int * integer [@@deriving eq]

  let bv_size b = fst b
  let bv_val b = snd b

  let show_bitvector (b : bitvector) =
    Printf.sprintf "0x%s:bv%d" (Z.format "%x" @@ bv_val b) (bv_size b)

  let pp_bitvector fmt b = Format.pp_print_string fmt (show_bitvector b)
end

module BType = struct
  type leaf = Boolean | Integer | Bitvector of int | Unit | Top | Nothing

  (*
  Nothing < Unit < {boolean, integer, bitvector} < Top
  *)
  let compare (a : leaf) (b : leaf) =
    match (a, b) with
    | Top, Top -> 0
    | Top, _ -> 1
    | _, Top -> -1
    | Nothing, Nothing -> 0
    | Nothing, _ -> -1
    | _, Nothing -> 1
    | Unit, _ -> -1
    | _, Unit -> 1
    | Boolean, Integer -> 0
    | Integer, Boolean -> 0
    | Boolean, Bitvector _ -> 0
    | Bitvector _, Boolean -> 0
    | Boolean, Boolean -> 0
    | Integer, Bitvector _ -> 0
    | Bitvector _, Integer -> 0
    | Bitvector a, Bitvector b -> Int.compare a b
    | Integer, Integer -> 0

  type lambda = Leaf of leaf | Lambda of (leaf * lambda)

  let to_string = function
    | Boolean -> "bool"
    | Integer -> "int"
    | Bitvector i -> "bv" ^ Int.to_string i
    | Unit -> "()"
    | Top -> "⊤"
    | Nothing -> "⊥"
end

(*
module QFBV : Intrins = struct
  type 'a t = [ `BVADD of int * 'a * 'a | `BVMUL of int * 'a * 'a ]

  open BType

  let get_type = function
    | `BVADD (s, a, b) ->
        Lambda (Bitvector s, Lambda (Bitvector s, Leaf (Bitvector s)))
    | `BVMUL (s, a, b) ->
        Lambda (Bitvector s, Lambda (Bitvector s, Leaf (Bitvector s)))

  let show x = "bvadd"

  let map f = function
    | `BVADD (s, a, b) -> `BVADD (s, f a, f b)
    | `BVMUL (s, a, b) -> `BVMUL (s, f a, f b)

  let fold f u = function
    | `BVADD (s, a, b) -> f (f u b) a
    | `BVMUL (s, a, b) -> f (f u b) a
end
*)

module type IntrinOp = sig
  type t

  val get_type : t -> BType.lambda
  val show : t -> string
end

module Unop (Ops : sig
  type t
end) =
struct
  type 'expr unop = [ `Unop of Ops.t * 'expr ]

  let map_unop f = function `Unop (op, arg) -> `Unop (op, f arg)
  let fold_unop f u = function `Unop (op, b) -> f u b
  let list_unop = function `Unop (f, a) -> [ a ]
  let iter_unop f = function `Unop (_, a) -> f a
end

module BinOp (Ops : sig
  type t
end) =
struct
  type 'expr binop = [ `BinOp of Ops.t * 'expr * 'expr ]

  let map_binop f = function `BinOp (op, a, b) -> `BinOp (op, f a, f b)

  let fold_binop f u (e : 'expr binop) =
    match e with `BinOp (op, a, b) -> f (f u b) a

  let list_binop = function `BinOp (f, a, b) -> [ a; b ]

  let iter_binop f (b : 'expr binop) =
    match b with
    | `BinOp (_, a, b) ->
        f a;
        f b
end

module FuncOp (Ops : sig
  type t
end) =
struct
  type 'expr funcop = [ `FuncOp of Ops.t * 'expr list ]

  let map_funcop f (e : 'expr funcop) =
    match e with `FuncOp (op, a) -> `FuncOp (op, List.map f a)

  let fold_funcop f u = function `FuncOp (op, l) -> List.fold_left f u l
  let iter_funcop f = function `FuncOp (op, l) -> List.iter f l
  let list_funcop = function `FuncOp (f, l) -> l
end

module GenExpType (Ops : sig
  type binops
  type unops
  type funintrins

  val hash_binop : binops -> int
  val hash_unop : unops -> int
  val hashfunintrin : funintrins -> int
end) =
struct
  open Ops

  include Unop (struct
    type t = unops
  end)

  include BinOp (struct
    type t = binops
  end)

  include FuncOp (struct
    type t = funintrins
  end)

  type 'a t =
    [ 'a unop
    | 'a binop
    | 'a funcop
    | `BVConstant of Value.bitvector
    | `IntConstant of Value.integer
    | `BoolConstant of bool ]

  let equal equal e1 e2 : bool =
    match (e1, e2) with
    | `BinOp (op1, a1, b1), `BinOp (op2, a2, b2) ->
        op1 = op2 && equal a1 a2 && equal b1 b2
    | `Unop (op, a), `Unop (op2, a2) -> op = op2 && equal a a2
    | `FuncOp (op, a), `FuncOp (op2, b) ->
        op = op2
        && List.combine a b
           |> List.fold_left (fun a (l, r) -> a && equal l r) true
    | _ -> false

  let combine acc n = (acc * 65599) + n
  let combine2 acc n1 n2 = combine (combine acc n1) n2
  let combine3 acc n1 n2 n3 = combine (combine (combine acc n1) n2) n3

  let rec combinel acc n1 =
    match n1 with [] -> acc | h :: tl -> combinel (combine acc h) tl

  let hash hash e1 : int =
    match e1 with
    | `BinOp (bop, e1, e2) -> combine2 (Ops.hash_binop bop) (hash e1) (hash e2)
    | `Unop (op, e1) -> combine (Ops.hash_unop op) (hash e1)
    | `FuncOp (op, es) -> combinel (Ops.hashfunintrin op) (List.map hash es)

  let fold =
   fun f unit e ->
    match e with
    | #binop as b -> fold_binop f unit b
    | #unop as b -> fold_unop f unit b
    | #funcop as b -> fold_funcop f unit b

  let iter =
   fun f e ->
    match e with
    | #binop as b -> iter_binop f b
    | #unop as b -> iter_unop f b
    | #funcop as b -> iter_funcop f b

  let map =
   fun f e ->
    match e with
    | #binop as b -> map_binop f b
    | #unop as b -> map_unop f b
    | #funcop as b -> map_funcop f b
end

module Prim = struct
  type assocop = [ `EQ | `NEQ | `BOOLAND | `BOOLOR ]
  [@@deriving show { with_path = false }]

  type predicatebinop =
    [ `EQ
    | `NEQ
    | `BVULT
    | `BVULE
    | `BVSLT
    | `BVSLE
    | `INTLT
    | `INTLE
    | `BOOLAND
    | `BOOLOR
    | `BOOLIMPLIES ]
  [@@deriving show { with_path = false }]

  type bitbinop =
    [ `BVAND
    | `BVOR
    | `BVADD
    | `BVMUL
    | `BVUDIV
    | `BVUREM
    | `BVSHL
    | `BVLSHR
    | `BVNAND
    | `BVNOR
    | `BVXOR
    | `BVXNOR
    | `BVCOMP
    | `BVSUB
    | `BVSDIV
    | `BVSREM
    | `BVSMOD
    | `BVASHR ]
  [@@deriving show { with_path = false }]

  type intbinop = [ `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD ]
  [@@deriving show { with_path = false }]

  type unop = [ `BITNOT | `LOGNOT | `NEG ]
  [@@deriving show { with_path = false }]

  type binop = [ predicatebinop | intbinop | bitbinop ]
  [@@deriving show { with_path = false }]

  (* expression ops with an explicit variant, this is used just for hash consing *)
  type additional_tags =
    [ `IntConst
    | `BoolConst
    | `BVConst
    | `ZeroExtend
    | `SignExtend
    | `BVConcat
    | `BVExtract
    | `FApply ]

  (* could maybe use ppx_deriving enum for this, unsure if it supports polymorphic variants though*)
  let hash_op (v : [< unop | binop | additional_tags ]) =
    match v with
    | `BVNOR -> 0
    | `BVSREM -> 1
    | `BVSDIV -> 2
    | `BVCOMP -> 4
    | `BVADD -> 5
    | `NEQ -> 6
    | `BVASHR -> 7
    | `BITNOT -> 10
    | `BVMUL -> 12
    | `BVSHL -> 13
    | `INTDIV -> 14
    | `BVXNOR -> 15
    | `EQ -> 16
    | `INTADD -> 17
    | `BVNAND -> 18
    | `NEG -> 19
    | `BVSLE -> 20
    | `BVUREM -> 21
    | `BVXOR -> 22
    | `BVOR -> 23
    | `BOOLIMPLIES -> 24
    | `BOOLOR -> 25
    | `BVSUB -> 26
    | `BVUDIV -> 27
    | `BVLSHR -> 28
    | `INTMOD -> 29
    | `BVAND -> 30
    | `INTMUL -> 31
    | `BVSMOD -> 32
    | `INTLT -> 33
    | `LOGNOT -> 35
    | `INTLE -> 36
    | `BVULT -> 37
    | `BOOLAND -> 38
    | `BVULE -> 39
    | `INTSUB -> 40
    | `BVSLT -> 41
    | `BoolConst -> 43
    | `BVExtract -> 44
    | `SignExtend -> 45
    | `ZeroExtend -> 46
    | `FApply -> 47
    | `IntConst -> 48
    | `BVConst -> 49
    | `BVConcat -> 50
end

module BasicExpr = struct
  include GenExpType (struct
    type binops = Prim.binop
    type unops = Prim.unop
    type funintrins = [ `ZeroExtend | `SignExtend | `BVConcat ]

    let hash_binop = Prim.hash_op
    let hash_unop = Prim.hash_op
    let hashfunintrin = Prim.hash_op
  end)
end

module ExprType = struct
  open Value
  open Prim

  type btype = BType.leaf

  type ('v, 'e) expr_node =
    | RVar of 'v * btype
    | AssocExpr of assocop * 'e list
    | BinaryExpr of binop * 'e * 'e
    | UnaryExpr of unop * 'e
    | BVZeroExtend of int * 'e
    | BVSignExtend of int * 'e
    | BVExtract of integer * integer * 'e
    | BVConcat of 'e * 'e
    | BVConst of bitvector
    | IntConst of integer
    | BoolConst of bool
    | Old of 'e
    | FApply of string * 'e list * btype
  (* store, load *)

  let equal equal e1 e2 : bool =
    match (e1, e2) with
    | RVar (i, t), RVar (i2, t2) -> i = i2 && t = t2
    | BinaryExpr (bop, e1, e2), BinaryExpr (bop2, e12, e22) ->
        bop = bop2 && equal e1 e12 && equal e2 e22
    | UnaryExpr (op1, e1), UnaryExpr (op2, e2) -> op1 = op2 && equal e1 e2
    | BVZeroExtend (sz, e1), BVZeroExtend (sz2, e2) -> sz = sz2 && equal e1 e2
    | BVSignExtend (sz, e1), BVSignExtend (sz2, e2) -> sz = sz2 && equal e1 e2
    | BVExtract (hi1, lo1, e1), BVExtract (hi2, lo2, e2) ->
        hi1 = hi2 && lo1 = lo2 && equal e1 e2
    | BVConcat (e11, e12), BVConcat (e21, e22) -> equal e11 e21 && equal e12 e22
    | BVConst bv1, BVConst bv2 -> equal_bitvector bv1 bv2
    | IntConst i, IntConst i2 -> equal_integer i i2
    | BoolConst i, BoolConst i2 -> i = i2
    | _ -> false

  let combine acc n = (acc * 65599) + n
  let combine2 acc n1 n2 = combine (combine acc n1) n2
  let combine3 acc n1 n2 n3 = combine (combine (combine acc n1) n2) n3

  let rec combinel acc n1 =
    match n1 with [] -> acc | h :: tl -> combinel (combine acc h) tl

  let hash hash e1 : int =
    match e1 with
    | AssocExpr (bop, es) -> combinel (hash_op bop) (List.map hash es)
    | BinaryExpr (bop, e1, e2) -> combine2 (hash_op bop) (hash e1) (hash e2)
    | UnaryExpr (uop, e1) ->
        combine2 (hash_op `SignExtend) (hash e1) (hash_op uop)
    | BVZeroExtend (i, e) ->
        combine2 (hash_op `ZeroExtend) (hash e) (Hashtbl.hash i)
    | BVSignExtend (i, e) ->
        combine2 (hash_op `SignExtend) (hash e) (Hashtbl.hash i)
    | BVExtract (hi, lo, e) ->
        combine3 (hash_op `BVExtract) (hash e) (Hashtbl.hash hi)
          (Hashtbl.hash lo)
    | BVConcat (e1, e2) -> combine2 (hash_op `BVConcat) (hash e1) (hash e2)
    | RVar (i, t) -> combine (Hashtbl.hash i) (Hashtbl.hash t)
    | BVConst bv ->
        combine2 (hash_op `BVConst)
          (Hashtbl.hash (bv_size bv))
          (Z.hash @@ bv_val bv)
    | IntConst i -> combine (hash_op `IntConst) (Hashtbl.hash i)
    | BoolConst b -> combine (hash_op `BoolConst) (Hashtbl.hash b)
    | Old b -> hash b
    | FApply (id, params, rt) ->
        combine (Hashtbl.hash id)
          (combinel (Hashtbl.hash rt) (List.map hash params))

  let fold :
      'a 'b 'acc. ('acc -> 'b -> 'acc) -> 'acc -> ('a, 'b) expr_node -> 'acc =
   fun f unit e ->
    match e with
    | AssocExpr (op, es) -> List.fold_left f unit es
    | BinaryExpr (op, e1, e2) -> f (f unit e1) e2
    | UnaryExpr (op, e1) -> f unit e1
    | BVZeroExtend (i, e) -> f unit e
    | BVSignExtend (i, e) -> f unit e
    | BVExtract (hi, lo, e) -> f unit e
    | BVConcat (e1, e2) -> f (f unit e1) e2
    | Old b -> f unit b
    | FApply (id, params, rt) -> List.fold_left f unit params
    | RVar (i, t) -> unit
    | BVConst bv -> unit
    | IntConst i -> unit
    | BoolConst b -> unit

  let iter : 'a 'b 'acc. ('b -> unit) -> ('a, 'b) expr_node -> unit =
   fun f e ->
    match e with
    | AssocExpr (op, es) -> List.iter f es
    | BinaryExpr (op, e1, e2) ->
        f e1;
        f e2
    | UnaryExpr (op, e1) -> f e1
    | BVZeroExtend (i, e) -> f e
    | BVSignExtend (i, e) -> f e
    | BVExtract (hi, lo, e) -> f e
    | BVConcat (e1, e2) ->
        f e1;
        f e2
    | Old b -> f b
    | FApply (id, params, rt) -> List.iter f params
    | RVar (i, t) -> ()
    | BVConst bv -> ()
    | IntConst i -> ()
    | BoolConst b -> ()

  let map : 'a 'b 'c. ('b -> 'c) -> ('a, 'b) expr_node -> ('a, 'c) expr_node =
   fun f e ->
    match e with
    | AssocExpr (op, es) -> AssocExpr (op, List.map f es)
    | BinaryExpr (op, e1, e2) -> BinaryExpr (op, f e1, f e2)
    | UnaryExpr (op, e1) -> UnaryExpr (op, f e1)
    | BVZeroExtend (i, e) -> BVZeroExtend (i, f e)
    | BVSignExtend (i, e) -> BVSignExtend (i, f e)
    | BVExtract (hi, lo, e) -> BVExtract (hi, lo, f e)
    | BVConcat (e1, e2) -> BVConcat (f e1, f e2)
    | Old b -> Old (f b)
    | FApply (id, params, rt) -> FApply (id, List.map f params, rt)
    | RVar (i, t) -> RVar (i, t)
    | BVConst bv -> BVConst bv
    | IntConst i -> IntConst i
    | BoolConst b -> BoolConst b
end

module type TYPE = sig
  type t

  val show : t -> string
  val compare : t -> t -> int
  val default : t
end

module Recursion (E : sig
  type 'e node

  val fix : 'e node -> 'e
  val unfix : 'a -> 'a node
  val map : ('a -> 'b) -> 'a node -> 'b node
end) =
struct
  let ( >> ) = fun f g x -> g (f x)

  let rec cata : 'b. ('b E.node -> 'b) -> 'e -> 'b =
   fun alg -> E.unfix >> E.map (cata alg) >> alg
end

module Expr (V : TYPE) = struct
  open ExprType

  type expr = expr_node_v Fix.HashCons.cell
  and expr_node_v = E of (V.t, expr) ExprType.expr_node [@@unboxed]

  module ExprHashType = struct
    type t = expr_node_v

    let equal (e1 : t) (e2 : t) =
      match (e1, e2) with
      | E e1, E e2 -> ExprType.equal Fix.HashCons.equal e1 e2

    let hash = function E e -> ExprType.hash Fix.HashCons.hash e
  end

  module M = Fix.HashCons.ForHashedTypeWeak (ExprHashType)

  let fix (e : (V.t, expr) ExprType.expr_node) = M.make (E e)

  let unfix (e : expr) : (V.t, expr) ExprType.expr_node =
    match e.data with E e -> e

  (* smart constructors *)
  let intconst v = fix (IntConst v)
  let bvconst ~(width : int) v = fix (BVConst (width, v))
  let assocexp ~op ls = fix (AssocExpr (op, ls))
  let binexp ~op l r = fix (BinaryExpr (op, l, r))
  let unexp ~op arg = fix (UnaryExpr (op, arg))
  let zero_extend ~n_prefix_bits arg = fix (BVZeroExtend (n_prefix_bits, arg))
  let sign_extend ~n_prefix_bits arg = fix (BVSignExtend (n_prefix_bits, arg))
  let old e = fix (Old e)
  let fapply id ~return_type params = fix (FApply (id, params, return_type))
  let bvextract ~hi_incl ~lo_excl arg = fix (BVExtract (hi_incl, lo_excl, arg))
  let bvconcat arg1 arg2 = fix (BVConcat (arg1, arg2))
  let bvconst bv = fix (BVConst bv)
  let intconst i = fix (IntConst i)
  let boolconst b = fix (BoolConst b)

  (* this map definition embeds unfix *)
  let map f e = ExprType.map f e
  let ( >> ) = fun f g x -> g (f x)
  let rec cata alg e = (unfix >> map (cata alg) >> alg) e

  module Memoiser = Fix.Memoize.ForHashedType (struct
    type t = expr

    let equal = Fix.HashCons.equal
    let hash = Fix.HashCons.hash
  end)

  let cata_memo (alg : (V.t, 'a) expr_node -> 'a) =
    let g r t = map r (unfix t) |> alg in
    Memoiser.fix g

  module S = Set.Make (V)

  let printer_alg e =
    match (e : (V.t, 'a) expr_node) with
    | RVar (id, t) -> V.show id ^ ":" ^ BType.to_string t
    | AssocExpr (op, args) ->
        Format.sprintf "%s(%s)" (Prim.show_assocop op) (String.concat ", " args)
    | BinaryExpr (op, l, r) ->
        Format.sprintf "%s(%s, %s)" (Prim.show_binop op) l r
    | UnaryExpr (op, a) -> Format.sprintf "%s(%s)" (Prim.show_unop op) a
    | BVZeroExtend (n, a) -> Format.sprintf "zero_extend(%d, %s)" n a
    | BVSignExtend (n, a) -> Format.sprintf "sign_extend(%d, %s)" n a
    | BVExtract (hi, lo, a) ->
        Format.sprintf "bvextract(%s, %s, %s)" (Z.to_string hi) (Z.to_string lo)
          a
    | BVConcat (l, r) -> Format.sprintf "concat(%s, %s)" l r
    | BVConst i -> Value.show_bitvector i
    | IntConst i -> Value.show_integer i
    | BoolConst true -> "true"
    | BoolConst false -> "false"
    | Old e -> Format.sprintf "old(%s)" e
    | FApply (i, a, r) ->
        Format.sprintf "%s(%s):%s" i (String.concat "," a) (BType.to_string r)

  let to_string =
    let alg e = printer_alg e in
    cata alg

  let free_vars e =
    let alg = function
      | RVar (id, t) -> S.singleton id
      | o -> ExprType.fold S.union S.empty o
    in
    cata alg e

  let substitute e =
    let alg = function
      | RVar (i, t) -> fix (RVar (V.default, t))
      | t -> fix t
    in
    cata alg e

  let%expect_test _ =
    print_string @@ to_string
    @@ binexp ~op:`INTADD (intconst (Z.of_int 50)) (intconst (Z.of_int 100));
    [%expect "\n      `INTADD(50, 100)"]

  let exp () =
    binexp ~op:`INTADD
      (intconst (Z.of_int 50))
      (binexp ~op:`INTADD
         (intconst (Z.of_int 50))
         (binexp ~op:`INTADD
            (intconst (Z.of_int 50))
            (binexp ~op:`INTADD
               (intconst (Z.of_int 50))
               (intconst (Z.of_int 5)))))

  let%expect_test _ =
    let alg e =
      let s = printer_alg e in
      print_endline s;
      s
    in
    let p = cata alg in
    ignore (p @@ exp ());
    [%expect
      {|
      5
      50
      `INTADD(50, 5)
      50
      `INTADD(50, `INTADD(50, 5))
      50
      `INTADD(50, `INTADD(50, `INTADD(50, 5)))
      50
      `INTADD(50, `INTADD(50, `INTADD(50, `INTADD(50, 5))))|}]

  let%expect_test _ =
    let alg e =
      let s = printer_alg e in
      print_endline s;
      s
    in
    let p = cata_memo alg in
    ignore (p @@ exp ());
    [%expect
      {|
    5
    50
    `INTADD(50, 5)
    `INTADD(50, `INTADD(50, 5))
    `INTADD(50, `INTADD(50, `INTADD(50, 5)))
    `INTADD(50, `INTADD(50, `INTADD(50, `INTADD(50, 5)))) |}]
end

let () = Printexc.record_backtrace true

module E = Expr (struct
  type t = string

  let show x = x
  let compare = String.compare
  let default = "none"
end)
