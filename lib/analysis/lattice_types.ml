open Lang
open Common
open Containers

module type Lattice = sig
  val name : string

  include ORD_TYPE
  include PRETTY with type t := t

  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
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
