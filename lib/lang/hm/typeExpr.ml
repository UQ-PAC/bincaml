(** Hash-consed (interned) type expresions with recusion schemes. *)

open Common
open UnionFind

(** Type variable identifier *)
type tvar = ID.t [@@deriving eq, ord, show]

(** Type scoping is handled by "universe" name strings. Hash consing enables
    types to be canonically identified by their representation, then looked up
    in the union-find datastructure. The union-find datastructrure is used for
    type equivalence/unification solving. *)

module V = struct
  (** The keys for the typing context map. 
  We use a simple "universe" string to distinguish types defined in different
  scopes (i.e. local variables from globals.)
   *)

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

(** The type scheme / typing context : to store a map from scoped type variables to types. *)
module TCtx = Map.Make (V)

module ATyp = struct
  (** Open recursive type expression, either a variable or type constructor. *)

  type 'a expr = Var of tvar | TypeConstr of 'a list * string
  [@@deriving eq, ord, show, map, fold]

  let hash he = function
    | Var v -> ID.hash v
    | TypeConstr (l, t) -> Hash.pair (Hash.list he) Hash.string (l, t)
end

(** Type of mutable type context union find *)
module type TypeContext = sig
  val compare : 'a Fix.HashCons.cell -> 'a Fix.HashCons.cell -> int
  val equal : 'a Fix.HashCons.cell -> 'a Fix.HashCons.cell -> bool

  module Typ : sig
    type 'a expr = 'a ATyp.expr = Var of tvar | TypeConstr of 'a list * string

    val equal_expr : ('a -> 'a -> bool) -> 'a expr -> 'a expr -> bool
    val compare_expr : ('a -> 'a -> int) -> 'a expr -> 'a expr -> int

    val pp_expr :
      (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a expr -> unit

    val show_expr : (Format.formatter -> 'a -> unit) -> 'a expr -> string
    val map_expr : ('a -> 'b) -> 'a expr -> 'b expr
    val fold_expr : ('a -> 'b -> 'a) -> 'a -> 'b expr -> 'a
    val hash : 'a Hash.t -> 'a expr -> int

    type t = nt elem Fix.HashCons.cell
    and nt = T of t expr

    module Hashed : sig
      type t = nt elem

      val hash : t -> int
      val equal : t -> t -> bool
    end

    module H : sig
      type data = Hashed.t

      val make : data -> data Fix.HashCons.cell
    end

    val unfix : nt elem Fix.HashCons.cell -> t expr
    val fix : t expr -> H.data Fix.HashCons.cell
    val union : t -> t -> t
    val find : nt elem Fix.HashCons.cell -> H.data Fix.HashCons.cell
    val merge : (t expr -> t expr -> t expr) -> t -> t -> t
  end

  module Rec : sig
    module O : sig
      type 'e expr = 'e ATyp.expr
      type t = Typ.t

      val fix : t expr -> t
      val unfix : t -> t expr
      val map_expr : ('b -> 'a) -> 'b expr -> 'a expr
    end

    type 'a alg = 'a ATyp.expr -> 'a
    type 'a coalg = 'a -> 'a ATyp.expr

    val cata : 'a alg -> Typ.t -> 'a
    val ana : 'a coalg -> 'a -> Typ.t

    val map_fold :
      f:('a -> Typ.t ATyp.expr -> 'a) ->
      alg:('a -> 'b ATyp.expr -> 'b) ->
      'a ->
      Typ.t ->
      'b

    val rw_recurse_down : f:(Typ.t ATyp.expr -> Typ.t) -> Typ.t -> Typ.t

    val mutu :
      ?cata:(('a * 'b) alg -> Typ.t -> 'a * 'b) ->
      (('a * 'b) ATyp.expr -> 'a) ->
      (('a * 'b) ATyp.expr -> 'b) ->
      (Typ.t -> 'a) * (Typ.t -> 'b)

    val zygo :
      ?cata:(('a * 'b) alg -> Typ.t -> 'a * 'b) ->
      'a alg ->
      (('a * 'b) ATyp.expr -> 'b) ->
      Typ.t ->
      'b

    val zygo_l :
      ?cata:(('b * 'a) alg -> Typ.t -> 'b * 'a) ->
      'a alg ->
      (('b * 'a) ATyp.expr -> 'b) ->
      Typ.t ->
      'b

    val map_fold2 :
      f:('a -> Typ.t ATyp.expr -> 'a) ->
      alg1:('a -> ('b * 'c) ATyp.expr -> 'b) ->
      alg2:'c alg ->
      'a ->
      Typ.t ->
      'b

    val para_f : (('a * 'b) ATyp.expr -> 'b) -> (Typ.t -> 'a) -> Typ.t -> 'b
    val para : ((Typ.t * 'a) ATyp.expr -> 'a) -> Typ.t -> 'a

    val cata_context :
      ((Typ.t ATyp.expr ATyp.expr * 'a) ATyp.expr -> 'a) -> Typ.t -> 'a

    val iter_children : (Typ.t ATyp.expr -> unit) -> Typ.t -> unit
    val children_iter : Typ.t -> Typ.t ATyp.expr Iter.t
  end
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
