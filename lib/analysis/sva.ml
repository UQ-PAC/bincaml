(** SVA analysis *)

open Lang
open Containers
open Common
open Wrapped_intervals
module BVSet = Set.Make (Bitvec)

module type OffsetDomain = sig
  type t

  val init : Bitvec.t -> t
  val init_set : BVSet.t -> t
  val should_widen : t -> bool
  val transform : t -> (Bitvec.t -> Bitvec.t) -> t
  val transform_t : t -> (t -> t) -> t
  val add : t -> t -> bool -> t
end

module IntervalDomain : OffsetDomain = struct
  include WrappedIntervalsLattice

  let init i = interval i i
  let init_set set = interval (BVSet.min_elt set) @@ BVSet.max_elt set
  let should_widen t = true
  let transform t f = t
  let transform_t t f = t
  let add t t' neg = match (t, t') with
    | Top, _ | _, Top -> Top
    | _, _ -> Bot
end
