open Common
open Value

module type CONST = sig
  type const

  val show_const : const -> string
  val equal_const : const -> const -> bool
  val hash_const : const -> int
end

module type UNARY = sig
  type unary

  val show_unary : unary -> string
  val equal_unary : unary -> unary -> bool
  val hash_unary : unary -> int
end

module type BINARY = sig
  type 'a binary = [> `A ] as 'a

  val show_binary : 'a binary -> string
  val equal_binary : 'a binary -> 'a binary -> bool
  val hash_binary : 'a binary -> int
end

module type INTRIN = sig
  type intrin

  val show_intrin : intrin -> string
  val equal_intrin : intrin -> intrin -> bool
  val hash_intrin : intrin -> int
end

module AbstractExpr = struct
  type ('const, 'var, 'unary, 'binary, 'intrin, 'e) t =
    | RVar of 'var  (** variables *)
    | Constant of 'const
        (** constants; a pure intrinsic function with zero arguments *)
    | UnaryExpr of 'unary * 'e
        (** application of a pure intrinsic function with one arguments *)
    | BinaryExpr of 'binary * 'e * 'e
        (** application of a pure intrinsic function with two arguments *)
    | ApplyIntrin of 'intrin * 'e list
        (** application of a pure intrinsic function with n arguments *)
    | ApplyFun of string * 'e list
        (** application of a pure runtime-defined function with n arguments *)
    | Binding of 'var list * 'e  (** syntactic binding in a nested scope *)
  [@@deriving eq, fold, map, iter]

  let id a b = a
  let ofold = fold
  let fold f b o = ofold id id id id id f b o
  let omap = map

  let map f e =
    let id a = a in
    omap id id id id id f e

  let hash hash e1 =
    let hash_const = Hashtbl.hash in
    let hash_var = Hashtbl.hash in
    let hash_unary = Hashtbl.hash in
    let hash_binary = Hashtbl.hash in
    let hash_intrin = Hashtbl.hash in
    let open HashHelper in
    match e1 with
    | RVar r -> combine 1 (hash_var r)
    | UnaryExpr (op, a) -> combine2 3 (hash_unary op) (hash a)
    | BinaryExpr (op, l, r) -> combine3 5 (hash_binary op) (hash l) (hash r)
    | Constant c -> combine 7 (hash_const c)
    | ApplyIntrin (i, args) ->
        combine 11 (combinel (hash_intrin i) (List.map hash args))
    | ApplyFun (n, args) ->
        combine 13 (combinel (String.hash n) (List.map hash args))
    | Binding (args, body) ->
        combine 17 (combinel (hash body) (List.map hash_var args))
end

module Var = struct
  type t = Int.t

  let equal = Int.equal
  let hash = Int.hash
  let show = Int.to_string
  let compare = Int.compare
end

module Unary = struct
  type unary = [ `BITNOT | `LOGNOT | `NEG ]
  [@@deriving show { with_path = false }, eq, enum]

  let hash_unary = unary_to_enum
end

type boolop_binary =
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
[@@deriving show { with_path = false }, eq]

let hash_boolop = Hashtbl.hash

type bvop_binary =
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
[@@deriving show { with_path = false }, eq, enum]

let hash_binary_bv = bvop_binary_to_enum

type intop_binary = [ `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD ]
[@@deriving show { with_path = false }, eq, enum]

let hash_binary_intop = intop_binary_to_enum

let show_binop = function
  | #boolop_binary as b -> show_boolop_binary b
  | #bvop_binary as b -> show_bvop_binary b
  | #intop_binary as b -> show_intop_binary b

type any_binary = [ bvop_binary | intop_binary | boolop_binary ]

let hash_any_binary a =
  match a with
  | #bvop_binary as a -> hash_binary_bv a
  | #boolop_binary as a -> hash_boolop a
  | #intop_binary as a -> hash_binary_intop a

module Intrin = struct
  type intrin =
    [ `ZeroExtend of int
    | `SignExtend of int
    | `BITConcat
    | `Old
    | `BitExtract of int * int
    | `EQ
    | `NEQ
    | `BOOLAND
    | `BOOLOR ]
  [@@deriving show { with_path = false }, eq]

  let hash_intrin a = Hashtbl.hash a
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

module Expr = struct
  module EX = AbstractExpr

  type ('a, 'b, 'c, 'd, 'e) expr = ('a, 'b, 'c, 'd, 'e) expr_node_v

  and ('a, 'b, 'c, 'd, 'e) expr_node_v =
    | E of ('a, 'b, 'c, 'd, 'e, ('a, 'b, 'c, 'd, 'e) expr) EX.t

  let fix (e : ('a, 'b, 'c, 'd, 'e, ('a, 'b, 'c, 'd, 'e) expr) EX.t) = E e

  let unfix (e : ('a, 'b, 'c, 'd, 'e) expr) :
      ('a, 'b, 'c, 'd, 'e, ('a, 'b, 'c, 'd, 'e) expr) EX.t =
    match e with E e -> e

  (* smart constructors *)
  let const v = fix (Constant v)
  let intconst v = fix (Constant (Value.Integer v))
  let binexp ~op l r = fix (BinaryExpr (op, l, r))
  let unexp ~op arg = fix (UnaryExpr (op, arg))
  let fapply id params = fix (ApplyFun (id, params))
  let applyintrin id params = fix (ApplyIntrin (id, params))
  let identity x = x

  (* this map definition embeds unfix *)
  let map f e = EX.map f e
  let ( >> ) = fun f g x -> g (f x)
  let rec cata alg e = (unfix >> map (cata alg) >> alg) e

  module S = Set.Make (Var)

  let idf a b = a

  let free_vars e =
    let alg = function
      | EX.RVar id -> S.singleton id
      | o -> EX.fold S.union S.empty o
    in
    cata alg e

  let substitute e =
    let open EX in
    let alg = function RVar i -> fix (RVar 0) | t -> fix t in
    cata alg e
end

let printer_alg e =
  let open AbstractExpr in
  match e with
  | RVar id -> Var.show id
  | BinaryExpr (op, l, r) -> Format.sprintf "%s(%s, %s)" (show_binop op) l r
  | UnaryExpr (op, a) -> Format.sprintf "%s(%s)" (Unary.show_unary op) a
  | Constant i -> Value.show_const i
  | ApplyIntrin (intrin, args) ->
      Format.sprintf "%s(%s)"
        (Intrin.show_intrin intrin)
        (String.concat ", " args)
  | ApplyFun (n, args) -> Format.sprintf "%s(%s)" n (String.concat ", " args)
  | Binding (vars, body) ->
      Format.sprintf "((%s) -> %s)"
        (String.concat ", " (List.map Var.show vars))
        body

let log_alg =
  let alg e =
    let s = printer_alg e in
    print_endline s;
    s
  in
  alg

let%expect_test _ =
  let open AbstractExpr in
  let open Expr in
  let to_string =
    let alg e = printer_alg e in
    cata alg
  in
  let e = fix @@ Constant (Value.Integer (Z.of_int 50)) in
  print_string @@ to_string @@ binexp ~op:`INTADD e e;
  [%expect {|`INTADD((Value.Value.Integer 50), (Value.Value.Integer 50)) |}]

let exp_bool () =
  let open Expr in
  binexp ~op:`BOOLAND
    (intconst (Z.of_int 50))
    (binexp ~op:`BOOLAND
       (intconst (Z.of_int 50))
       (binexp ~op:`BOOLAND
          (intconst (Z.of_int 50))
          (binexp ~op:`BOOLAND (intconst (Z.of_int 50)) (intconst (Z.of_int 5)))))

let exp_all () =
  let open Expr in
  binexp ~op:`INTADD
    (intconst (Z.of_int 50))
    (binexp ~op:`INTADD
       (intconst (Z.of_int 50))
       (binexp ~op:`INTADD
          (intconst (Z.of_int 50))
          (binexp ~op:`INTADD (intconst (Z.of_int 50)) (intconst (Z.of_int 5)))))

let%expect_test _ =
  let alg = log_alg in
  let open Expr in
  let p = cata alg in
  ignore (p @@ exp_all ());
  [%expect
    {|
  (Value.Value.Integer 5)
  (Value.Value.Integer 50)
  `INTADD((Value.Value.Integer 50), (Value.Value.Integer 5))
  (Value.Value.Integer 50)
  `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), (Value.Value.Integer 5)))
  (Value.Value.Integer 50)
  `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), (Value.Value.Integer 5))))
  (Value.Value.Integer 50)
  `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), `INTADD((Value.Value.Integer 50), (Value.Value.Integer 5)))))|}]

let%expect_test _ =
  let alg = log_alg in
  let open Expr in
  let p = cata alg in
  ignore (p @@ exp_bool ());
  [%expect
    {|
      (Value.Value.Integer 5)
      (Value.Value.Integer 50)
      `BOOLAND((Value.Value.Integer 50), (Value.Value.Integer 5))
      (Value.Value.Integer 50)
      `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), (Value.Value.Integer 5)))
      (Value.Value.Integer 50)
      `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), (Value.Value.Integer 5))))
      (Value.Value.Integer 50)
      `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), `BOOLAND((Value.Value.Integer 50), (Value.Value.Integer 5)))))
    |}]

let () = Printexc.record_backtrace true

