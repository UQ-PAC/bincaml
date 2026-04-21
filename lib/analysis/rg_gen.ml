(** Tools for generating rely-guarantee conditions. *)

open Bincaml_util.Common
open Lattice_types

(** Interference domains are like abstract domains except that instead of abstracting sets of states, they abstract
    sets of pairs of states representing state transitions. In this way, they can be viewed as abstract rely-guarantee
    conditions. Rather than defining a transfer function, interference domains define a {!stabilise} function for
    applying interferences to states, as well as a {!transitions} function for deriving elements of the interference
    domain from assignment-precondition pairs. *)
module type InterferenceDomain = functor (StateD : Domain) -> sig
  (** Lattice over transitions, i.e. sets of pairs of states. *)
  module I : Lattice
  
  (** Lattice over sets of states. *)
  module D : Lattice with type t = StateD.t

  val stabilise : I.t -> D.t -> D.t
  (** [stabilise i d] returns an abstract state weaker than [d] that captures the set of states reachable by executing
      any one step in [i] from any state in [d]. *)
  
  val transitions : (Lang.Program.stmt * D.t) list -> I.t
  (** [transitions p] takes a set of assignment-precondition pairs [p] and returns an element of the interference domain
      that over-approximates all transitions reachable by executing any assignment under its associated precondition. *)
end
