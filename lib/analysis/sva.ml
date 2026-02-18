(** SVA analysis *)

open Lang
open Containers
open Common
open Wrapped_intervals
module BVSet = Set.Make (Bitvec)
module IntervalLatticeSet = Set.Make (WrappedIntervalsLattice)

module SymBase = struct
  type t =
    | Stack of string
    | Heap of { name : string; label : string }
    | GlobSym of { interval : WrappedIntervalsLattice.t }
    | Constant
    | Par of { name : string; param_name : string }
    | Ret of {
        name : string;
        target_name : string;
        label : string;
        param_name : string;
      }
    | Loaded of { name : string; label : string }

  let show = function
    | Stack name -> Printf.sprintf "Stack(%s)" name
    | Heap { name; label } -> Printf.sprintf "Heap(%s_%s)" name label
    | GlobSym _ -> "Global"
    | Constant -> "Constant"
    | Par { name; param_name } -> Printf.sprintf "Par(%s_%s)" name param_name
    | Ret { name; target_name; label; param_name } ->
        Printf.sprintf "Ret(%s_%s_%s_%s)" name target_name label param_name
    | Loaded { name; label } -> Printf.sprintf "Loaded(%s_%s)" name label

  let place_holder = function
    | Stack _ | Heap _ | GlobSym _ | Constant -> false
    | Ret _ | Par _ | Loaded _ -> true
end

module type Offsets = sig
  val toOffsets : BVSet.t
  val toIntervals : IntervalLatticeSet.t
end

module type OffsetDomain = sig
  type t

  val init : Bitvec.t -> t
  val init_set : BVSet.t -> t
  val should_widen : t -> bool
  val transform : t -> (Bitvec.t -> Bitvec.t) -> t
  val transform_t : t -> (t -> t) -> t
  val add : bool -> t -> t -> t
end

module IntervalDomain : OffsetDomain = struct
  open WrappedIntervalsLattice

  type t = WrappedIntervalsLattice.t

  let init i = interval i i
  let init_set set = interval (BVSet.min_elt set) @@ BVSet.max_elt set
  let should_widen t = false

  let transform t f =
    match t with
    | Top | Bot -> t
    | Interval { lower; upper } -> Interval { lower = f lower; upper = f upper }

  let transform_t t f = f t

  let add neg t t' =
    match (t, t') with
    | Top, _ | _, Top -> Top
    | a, Bot | Bot, a -> a
    | Interval { lower; upper }, Interval { lower = lower2; upper = upper2 } ->
        let lower2, upper2 =
          if neg then (Bitvec.neg lower2, Bitvec.neg upper2)
          else (lower2, upper2)
        in
        let o1 = Bitvec.add lower upper2 in
        let o2 = Bitvec.add lower lower2 in
        let o3 = Bitvec.add upper upper2 in
        let o4 = Bitvec.add upper lower2 in
        init_set @@ BVSet.of_list [ o1; o2; o3; o4 ]
end
