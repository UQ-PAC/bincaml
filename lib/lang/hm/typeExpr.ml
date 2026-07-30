(** Hash-consed (interned) type expresions with recusion schemes. *)

open Common

type tvar = ID.t [@@deriving eq, ord, show]
(** Type variable identifier *)

(** Type scoping is handled by "universe" name strings. Hash consing enables
    types to be canonically identified by their representation, then looked up
    in the union-find datastructure. The union-find datastructrure is used for
    type equivalence/unification solving. *)

module V = struct
  (** The keys for the typing context map. We use a simple "universe" string to
      distinguish types defined in different scopes (i.e. local variables from
      globals.) *)

  type t = { univ : string; v : string } [@@deriving eq, ord, show]

  let hash { univ; v } = Hash.pair Hash.string Hash.string (univ, v)
  let to_string { univ; v } = univ ^ "::" ^ v
  let local_univ = "<local>"
  let global_univ = "<global>"
  let proc_univ p = ID.to_string p
  let create univ v = { univ; v }

  let of_var univ v =
    if Var.is_global v then { univ = global_univ; v = Var.name v }
    else { univ; v = Var.name v }
end

module TCtx = Map.Make (V)
(** The type scheme / typing context : to store a map from scoped type variables
    to types. *)

module ATyp = struct
  (** Open recursive type expression, either a variable or type constructor. *)

  type 'a expr = Var of tvar | TypeConstr of 'a list * string
  [@@deriving eq, ord, show, map, fold]

  let hash he = function
    | Var v -> ID.hash v
    | TypeConstr (l, t) -> Hash.pair (Hash.list he) Hash.string (l, t)
end

type t = nt UnionFind.elem Fix.HashCons.cell
(** Union find and hash-consing type for representing type expressions. *)

and nt = T of t ATyp.expr  (** TODO: what is `nt` mean? *)

let equal = Fix.HashCons.equal
let compare = Fix.HashCons.compare
let map_expr = ATyp.map_expr

(** Hash cons the data underlying the UF reference so we can construct the type
    and get the UF reference. *)
module Hash_inner = struct
  type t = nt UnionFind.elem
  (** This is the type within the {!Fix.HashCons.cell}. *)

  let hash (e : t) : int =
    e |> UnionFind.get |> function T e -> ATyp.hash Fix.HashCons.hash e

  let equal (i : t) (j : t) : bool =
    match (UnionFind.get i, UnionFind.get j) with
    | T i, T j -> ATyp.equal_expr Fix.HashCons.equal i j
end

module State = struct
  type state = {
    hcons : Hash_inner.t -> t;
        (** Construct (or re-obtain) a hash-consed union-find-supporting type
            expression for the given {!nt}. *)
    gen : ID.generator;  (** Type name generator. *)
  }
  (** Union find and hash-consing state for recording type relations.

      @canonical TypeExpr.state *)

  (** Create a new union find and hash-cons state.

      This must be done each time we want to perform inference in an independent
      environment, in order to construct a fresh hash-consing and union-find
      state. *)
  let create_state () =
    let module H = Fix.HashCons.ForHashedType (Hash_inner) in
    { hcons = (fun e -> H.make e); gen = ID.make_gen () }
end

include State
(** @inline *)

let unfix : t -> t ATyp.expr =
  Fix.HashCons.data %> UnionFind.find %> UnionFind.get %> function T e -> e

let fix st (e : t ATyp.expr) : t = st.hcons (UnionFind.make (T e))

let union st (a : t) (b : t) : t =
  st.hcons @@ UnionFind.union (Fix.HashCons.data a) (Fix.HashCons.data b)

(** dubious; has invariant that H.make returns same ref as find ;
    - should be true if we don't reassign refs but *)
let find st e = Fix.HashCons.data e |> UnionFind.find |> st.hcons

let merge st f (a : t) (b : t) : t =
  st.hcons
  @@ UnionFind.merge
       (fun (T a) (T b) -> T (f a b))
       (Fix.HashCons.data a) (Fix.HashCons.data b)

(** Fold an algebra ['a expr -> 'a] through the type expression, from leaves to
    nodes, and returns the final ['a].

    This is manually implemented because it only uses {!unfix}, so it does not
    need {!state}. Whereas, recursion scheme functions which use [fix] would
    need {!state}. *)
let rec cata (alg : 'a ATyp.expr -> 'a) e =
  (unfix %> ATyp.map_expr (cata alg) %> alg) e

(** Full recursion-scheme bundle for {!t}. If you only need [cata], also see the
    separate {!cata}. *)
module Rec (S : sig
  val state : state
end) =
Bincaml_util.Recursionscheme.Recursion (struct
  type 'e expr = 'e ATyp.expr
  type nonrec t = t

  let fix = fix S.state
  let unfix = unfix
  let map_expr = ATyp.map_expr
end)
