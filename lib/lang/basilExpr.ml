
open Common
open Containers
open Ops
include Abstract_expr

type const = Ops.AllOps.const
type unary = Ops.AllOps.unary
type binary = Ops.AllOps.binary
type intrin = Ops.AllOps.intrin
type var = Var.t

let hash_const = function
| `Bitvector b -> Hash.combine2 2 (Bitvec.hash b)
| `Boolean b -> Hash.combine2 3 (if b then 11 else 13)

let top_typ = Types.Nothing

module Var = Var
open Ops.AllOps

(** Fixed type of basil expressions: an expression of type {!t} whose
    subexpressions are also expressions of type {!t} *)
type t =
| E of (const, Var.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
[@@unboxed] [@@deriving eq, ord]

type typ = Types.t

(** {1 Expression recursions}

    We define the {! fix} and {!unfix} functions in order to derive traversal
    operations using recursion schemes, for more explanation on this see:
    {!Bincaml_util.Recursionscheme.Recursion}. *)

(** create fixed type from abstract type *)
let fix i = E i

(** create abstract type from fixed type *)
let unfix i = match i with E i -> i

let unfix2 e = AbstractExpr.map unfix (unfix e)
let unfix3 e = AbstractExpr.map unfix2 (unfix e)

open struct
module E = struct
    include AllOps

    type outer = t
    type t = outer
    type var = Var.t
    type typ = Types.t

    module Var = Var

    let fix i = fix i
    let unfix i = unfix i
    let top_typ = Types.Top
end

module R = Make (E)
end

include R


let rec hash e : int =
match e with
| E e ->
    let h = Hash.poly in
    AbstractExpr.hash h Var.hash h h h Hashtbl.hash hash e

let rec equal (i : t) (j : t) : bool =
match (i, j) with
| E i', E j' ->
    let e =
        AbstractExpr.equal equal_const Var.equal equal_unary equal_binary
        equal_intrin Types.equal equal i' j'
    in
    e

let show_abstract pp_e e =
AbstractExpr.show Ops.AllOps.pp_const Var.pp Ops.AllOps.pp_unary
    Ops.AllOps.pp_binary Ops.AllOps.pp_intrin Types.pp pp_e e


  let drop_attrib a =
    let a =
      rewrite ~rw_fun:(AbstractExpr.drop_attrib %> fix %> replace [%here]) a
    in
    a
