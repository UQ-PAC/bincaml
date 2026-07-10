(** Hash-consed (interned) type expresions with recusion schemes. *)

open Common
open UnionFind

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

(** Create the union find and hash-consing structure for recording type
    relations. This must be done each time we want to perform inference in an
    independent environment, in order to construct a fresh hash-consing and
    union-find state. *)
module Make () = struct
  module Typ = struct
    include ATyp

    type t = nt UnionFind.elem Fix.HashCons.cell
    and nt = T of t expr

    module Hashed = struct
      type t = nt elem
      (* we hash cons the data underlying the uf reference so we can construct the
       type and get the UF reference *)

      let hash (e : t) : int =
        e |> UnionFind.get |> function T e -> ATyp.hash Fix.HashCons.hash e

      let equal (i : t) (j : t) : bool =
        match (UnionFind.get i, UnionFind.get j) with
        | T i, T j -> ATyp.equal_expr Fix.HashCons.equal i j
    end

    open struct
      module M = Fix.Memoize.ForHashedType (Hashed)
      (** we need to make *)
    end

    module H = Fix.HashCons.Make (M)

    let unfix =
      Fix.HashCons.data %> UnionFind.find %> UnionFind.get %> function
      | T e -> e

    let fix e = H.make (UnionFind.make (T e))

    let union (a : t) (b : t) : t =
      H.make @@ UnionFind.union (Fix.HashCons.data a) (Fix.HashCons.data b)

    (** dubious; has invariant that H.make returns same ref as find ;
        - should be true if we don't reassign refs but *)
    let find e = Fix.HashCons.data e |> UnionFind.find |> H.make

    let merge f (a : t) (b : t) : t =
      H.make
      @@ UnionFind.merge
           (fun (T a) (T b) -> T (f a b))
           (Fix.HashCons.data a) (Fix.HashCons.data b)
  end

  let compare a b = Fix.HashCons.compare a b
  let equal a b = Fix.HashCons.equal a b

  module Rec = Bincaml_util.Recursionscheme.Recursion (Typ)
end

module type TypeContext = module type of Make ()
(** Type of mutable type context union find *)
