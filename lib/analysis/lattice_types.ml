open Lang
open Common

module type Lattice = sig
  val name : string

  include ORD_TYPE
  include PRETTY with type t := t

  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
  val leq : t -> t -> bool
  val widening : t -> t -> t
end

(** an abstract value providing opertions of basil ir *)
module type ValueAbstraction = sig
  include Lattice
  module E : Expr.ExprType

  (** evaluate operators *)

  val eval_const : E.const -> t
  val eval_unop : E.unary -> t -> t
  val eval_binop : E.binary -> t -> t -> t
  val eval_intrin : E.intrin -> t list -> t
end

module type TypedValueAbstraction = sig
  (** A value abstraction that takes type information *)

  include Lattice
  module E : Expr.ExprType

  (** evaluate operators *)

  val eval_const : E.const -> E.ty -> t
  (** Return an abstract value for a constant: [eval_const op rt]

      @param op const op
      @param rt type of constant [const]
      @return abstract value for constant *)

  val eval_unop : E.unary -> t * E.ty -> E.ty -> t
  (** Abstract a unary op expression [eval_unop op arg rt]

      @param op unary operator
      @param arg tuple (argument value, type)
      @param rt operation return type
      @return abstract value operation result *)

  val eval_binop : E.binary -> t * E.ty -> t * E.ty -> E.ty -> t
  (** Abstract a binary expression [eval_binop op arg1 arg2 rt]

      @param op binary operator
      @param arg1 first arg tuple (abstract value, type)
      @param arg2 second arg tuple (abstract value, type)
      @param rt operation return type
      @return abstract value result of operation *)

  val eval_intrin : E.intrin -> (t * E.ty) list -> E.ty -> t
  (** Abstract an n-ary intrinsic op [eval_intrin op args rt]

      @param op operator
      @param args argument list of tuples (abstract value, type)
      @param rt operation return type
      @return abstract value result of operation *)
end

(** a value abstraction providing variable store/load operations *)
module type StateAbstraction = sig
  type val_t
  type key_t

  module V : Lattice with type t = val_t
  include Lattice

  val read : key_t -> t -> val_t
  val update : key_t -> val_t -> t -> t
  val to_iter : t -> (key_t * val_t) Iter.t
end

module type Domain = sig
  include Lattice

  val transfer : t -> Program.stmt -> t
  val init : Program.proc -> t
end

module FlatLattice (L : sig
  include ORD_TYPE

  val name : string
end) =
struct
  type t = Top | V of L.t | Bot [@@deriving eq, ord]

  let name = L.name ^ ".flat_lattice"
  let bottom = Bot

  let show a =
    match a with
    | Top -> Bincaml_util.Unicode.top_char
    | Bot -> Bincaml_util.Unicode.bot_char
    | V t -> L.show t

  let pretty a =
    Containers_pp.text
    @@
    match a with
    | Top -> Bincaml_util.Unicode.top_char
    | Bot -> Bincaml_util.Unicode.bot_char
    | V t -> L.show t

  let bind f a = match a with V x -> f x | o -> o

  let bind2 f a b =
    match (a, b) with
    | V l, V r -> f l r
    | Bot, _ -> Bot
    | _, Bot -> Bot
    | _ -> Top

  let map f a = bind (fun x -> V (f x)) a
  let map2 f a b = bind2 (fun x y -> V (f x y)) a b
  let join a b = match (a, b) with Top, _ -> Top | _, Top -> Top | _ -> Bot

  let leq a b =
    match (a, b) with
    | a, b when equal a b -> true
    | Bot, _ | _, Top -> true
    | _, Bot | Top, _ -> false
    | _ -> false

  let widening a b = join a b
end

module LiftLattice (L : Lattice) : Lattice = struct
  include FlatLattice (L)

  let name = L.name ^ ".lift_lattice"
  let widening a b = map2 L.widening a b

  let join a b =
    match (a, b) with
    | Top, _ -> Top
    | _, Top -> Top
    | Bot, _ -> Bot
    | _, Bot -> Bot
    | V a, V b -> V (L.join a b)
end

(*
module BitWidthLattice (L : Lattice) : TypedValueAbstraction = struct
  module IL = FlatLattice (struct
    include Int

    let show = Int.to_string
    let name = "int63"
  end)

  include IL
  module E = Expr.BasilExpr

  let width o =
    match o with
    | Ops.AllOps.Fun { ret } -> Types.bit_width ret
    | _ -> failwith "type error"

  type ty = Types.t
  type t = IL.t * L.t

  let eval_const op = Ops.AllOps.ret_type_const
end
*)
