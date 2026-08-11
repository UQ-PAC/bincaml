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
type t = E of (const, Var.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
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


let type_of = unfix %> AbstractExpr.get_typ

let type_alg = AbstractExpr.get_typ

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

(** {1 Constructors}*)

module MakeConstructors (E : sig
  val elaborate_expr_type : t -> t
end) =
struct
  include R.Constructors

  let fixup_typ e = E.elaborate_expr_type e [@@inline always]

  let binexp ?typ ?attrib ~op arg1 arg2 =
    (match op with
      | #Ops.AllOps.intrin as op -> applyintrin ?typ ?attrib ~op [ arg1; arg2 ]
      | #Ops.AllOps.binary as op -> binexp ?typ ?attrib ~op arg1 arg2)
    |> fixup_typ

  let unexp ?attrib ?typ ~op arg = unexp ?attrib ?typ ~op arg |> fixup_typ

  let apply_fun ?attrib ?typ ~func args =
    apply_fun ?attrib ?typ ~func args |> fixup_typ

  let letexp ?attrib ?typ bound_vars in_body =
    letexp ?attrib ?typ bound_vars in_body |> fixup_typ

  let zero_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`ZeroExtend n_prefix_bits) e |> fixup_typ

  let field_store ?attrib ~(field : string) (record : t) (e : t) : t =
    binexp ?attrib ~op:(`WriteField field) record e |> fixup_typ

  let field_read ?attrib ~(field : string) (record : t) : t =
    unexp ?attrib ~op:(`ReadField field) record |> fixup_typ

  let sign_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`SignExtend n_prefix_bits) e |> fixup_typ

  let load ?attrib ~bits endian (m : t) (ind : t) : t =
    binexp ?attrib ~typ:(Bitvector bits) ~op:(`Load (endian, bits)) m ind

  let extract ?attrib ~hi_excl ~lo_incl (e : t) : t =
    unexp ?attrib
      ~op:(`Extract (hi_excl, lo_incl))
      e
      ~typ:(Bitvector (hi_excl - lo_incl))

  let concat ?attrib (e : t) (f : t) : t =
    applyintrin ?attrib ~op:`BVConcat [ e; f ] |> fixup_typ

  let ifthenelse ?attrib cond t e =
    applyintrin ~op:`Cases [ binexp ~op:`IfThen cond t; e ] |> fixup_typ

  let concatl ?attrib (e : t list) : t =
    applyintrin ?attrib ~op:`BVConcat e |> fixup_typ

  let forall ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Forall bound p ~typ:Boolean

  let exists ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Exists bound p ~typ:Boolean

  let lambda ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Lambda bound p |> fixup_typ

  let boolnot ?attrib e = unexp ?attrib ~op:`BoolNOT e ~typ:Boolean

  let intconst ?attrib (v : PrimInt.t) : t =
    const ?attrib ~typ:Integer (`Integer v) |> fixup_typ

  let boolconst ?attrib (v : bool) : t =
    const ?attrib ~typ:Boolean (`Bool v) |> fixup_typ

  let bvconst ?attrib (v : Bitvec.t) : t =
    const ?attrib ~typ:(Bitvector (Bitvec.size v)) (`Bitvector v)

  let rvar ?attrib v = rvar ?attrib ~typ:(Var.typ v) v
  let bv_of_int ~(size : int) (v : int) : t = bvconst (Bitvec.of_int ~size v)
  let const ?attrib ?typ v = const ?attrib ?typ v |> fixup_typ
  let fapply ?attrib ?typ func args = fapply ?attrib ?typ func args |> fixup_typ

  let applyintrin ?attrib ?typ ~op args =
    applyintrin ?attrib ?typ ~op args |> fixup_typ
end

include MakeConstructors (struct
  let elaborate_expr_type e = e
end)
