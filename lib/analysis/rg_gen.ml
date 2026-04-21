(** Tools for generating rely-guarantee conditions. *)

open Bincaml_util.Common
open Lattice_types

(** Interference domains are like abstract domains except that instead of abstracting sets of states, they abstract
    sets of pairs of states representing state transitions. In this way, they can be viewed as abstract rely-guarantee
    conditions. Rather than defining a transfer function, interference domains define a {!stabilise} function for
    applying interferences to states, as well as a {!transitions} function for deriving elements of the interference
    domain from assignment-precondition pairs. *)
module type InterferenceDomain = sig
  module Make (D : Domain) : sig
    (** Lattice over transitions, i.e. sets of pairs of states. *)
    module I : Lattice

    val stabilise : I.t -> D.t -> D.t
    (** [stabilise i d] returns an abstract state weaker than [d] that captures the set of states reachable by executing
        any one step in [i] from any state in [d]. *)
    
    val transitions : (Lang.Program.stmt * D.t) list -> I.t
    (** [transitions p] takes a set of assignment-precondition pairs [p] and returns an element of the interference
        domain that over-approximates all transitions reachable by executing any assignment under its associated
        precondition. *)
  end
end

(** The domain of Conditional Restricted Updates (CRUs). Defined over the lattice:
    {math V\in\mathcal{P}(\mathcal{V})\to\mathcal{D}\times(V\to\mathcal{P}(\mathcal{A}))}
    where:
    - {m \mathcal{P}} gives the powerset of a set.
    - {m \mathcal{V}} is the set of program variables.
    - {m \mathcal{D}} is the set of abstract states.
    - {m \mathcal{A}} is a given set of transitive binary relations.

    An element {m i} of this lattice maps each {b set} of variables {m V} to a tuple
    {m (d,m)} where {m d} represents the set of states under which all
    variables in {m V} may be updated within one step of {m i}, and whenever such an update occurs, {m R(x',x)} holds for
    each {m x\in V} and relation {m R\in m(x)}. Updates to {m V} are thus "conditional" in the sense that they may only
    occur when {m d} holds, and "restricted" in the sense that certain restrictions may be inferred in the form of sets
    of relations that hold between a variable's future value and its current value.
*)
module CruDomain : InterferenceDomain = struct
  module Make (D : Domain) = struct
      module I: Lattice = struct
        module StmtSet = Set.Make(struct
          type t = Lang.Program.stmt
          let compare = Lang.Program.compare_stmt
        end)
        type constraints = { pre : D.t; rel : StmtSet.t VarMap.t }

        type t = constraints VarMap.t

        let name = "CruLattice"

        (* {x} -> (P, [x -> {<}]), {y} -> (Q, [y -> {}]), {x, y} -> (R, [x -> {<}, y -> {}]) ... *)
        (* let show (i : t) : string =
          let map_entry_str = (fun (var constraints) ->
            let pre_str = D.show constraints.pre in
            let rel_str = StmtSet.to_string Lang.Program.show_stmt constraints.rel in
            Printf.sprintf "%s -> { pre: %s, rel: {%s} }" (Var.show var) pre_str rel_str) in
          VarMap.to_list i
          |> List.to_string
            ~start:""
            ~stop:""
            ~sep:", "
            map_entry_str *)

        let show (i : t) : string = ""
        
        let pretty t = Containers_pp.text (show t)
        let top = VarMap.empty
        let bottom = VarMap.empty
        let join t1 t2 = t1
        let equal t1 t2 = true
        let leq t1 t2 = true
        let widening t1 t2 = t1
        let compare = VarMap.compare (fun e1 e2 ->
          let c = D.compare e1.pre e2.pre in
          if c <> 0 then c
          else VarMap.compare StmtSet.compare e1.rel e2.rel
        )
      end

    let stabilise i d = d

    let transitions p = I.bottom
  end
end
