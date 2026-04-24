(** Tools for generating rely-guarantee conditions. *)

open Bincaml_util.Common
open Lattice_types

(** Interference domains are parameterised by state domains which must implement the {!meet} and {!havoc} functions. *)
module type CompatibleStateLattice = sig
  include Lattice
  val meet : t -> t -> t
  val havoc : t -> VarSet.t -> t
end

(** See {!CompatibleStateLattice}. *)
module type CompatibleStateDomain = sig
  include CompatibleStateLattice
  (* val filter : t -> Lang.Program.e -> t *)
end

(** Interference domains are like abstract domains except that instead of abstracting sets of states, they abstract
    sets of pairs of states representing state transitions. In this way, they can be viewed as abstract rely-guarantee
    conditions. Rather than defining a transfer function, interference domains define a {!stabilise} function for
    applying interferences to states, as well as a {!transitions} function for deriving elements of the interference
    domain from assignment-precondition pairs. *)
module type InterferenceDomain = sig
  module Make (D : CompatibleStateDomain) : sig
    (** Lattice over transitions, i.e. sets of pairs of states. *)
    module I : Lattice

    val stabilise : I.t -> D.t -> D.t
    (** [stabilise i d] returns an abstract state weaker than [d] that captures the set of states reachable by executing
        any one step in [i] from any state in [d]. *)
    
    val transitions : (Lang.Program.stmt * D.t) list -> I.t
    (** [transitions p] takes a set of assignment-precondition pairs [p] and returns an element of the interference
        domain that over-approximates all transitions reachable by executing any assignment under its associated
        precondition. Implementations should ignore non-assignment statements, but these also should be ignored by the
        higher-level analysis algorithm that calls {!transitions}. *)
  end
end

(** The conditional-writes domain maps each variable to the set of states under which it may be written, called its
    "write-condition". In case the target program contains simultaneous assignments, the domain of this map is sets of
    variables, rather than just variables. The map omits variable sets with write-conditions equal to bot. *)
module ConditionalWritesDomain : InterferenceDomain = struct
  module Make (D : CompatibleStateDomain) = struct
    module VarSetMap = Map.Make(VarSet)
    module I = struct
      type t = Top | Val of D.t VarSetMap.t
      
      let name = "ConditionalWritesLattice"
      
      let top = Top
      (** This has to be a special value because we don't know the set of variables we may encounter upfront, so we
          can't just map every variable to D.top. It also might be more efficient than that, because we only ever
          reach this value when we have to throw our hands up, and arbitrarily returning a map containing every
          variable is cringe. *)
      
      let bottom = Val VarSetMap.empty
      (** Implicitly maps every variable in the universe to D.bottom, meaning no variable is ever written to. *)
      
      let join i1 i2 = match i1, i2 with
        | Top, _ | _, Top -> Top
        | Val m1, Val m2 -> Val (VarSetMap.union (fun _key d1 d2 -> Some (D.join d1 d2)) m1 m2)
      (** Joins are derived component-wise. *)
      
      let equal i1 i2 = match i1, i2 with
        | Top, Top -> true
        | Val m1, Val m2 -> VarSetMap.equal D.equal m1 m2
        | _ -> false
      
      let leq i1 i2 = equal i2 (join i1 i2)
      
      let widening = join
      
      let show i = match i with
        | Top -> Bincaml_util.Unicode.top_char
        | Val m -> if VarSetMap.is_empty m then Bincaml_util.Unicode.bot_char else
          let entry_to_str = (fun (var_set, d) ->
            let var_set_str = VarSet.to_string Var.to_string var_set in
            let d_str = D.show d in
            Printf.sprintf "%s -> %s" var_set_str d_str
          ) in VarSetMap.to_list m
          |> List.to_string
            ~start:""
            ~stop:""
            ~sep:", "
            entry_to_str
      (** For example: "{x} -> P, {y} -> Q, {x, y} -> R, ..." *)
      
      let pretty i = Containers_pp.text (show i)

      let compare i1 i2 = match i1, i2 with
        | Top, Top -> 0
        | Top, Val _ -> 1
        | Val _, Top -> -1
        | Val m1, Val m2 -> VarSetMap.compare D.compare m1 m2
    end
    
    let stabilise i d = match i with
      | I.Top -> D.top
      | Val m -> VarSetMap.fold
        (fun var_set write_cond -> D.join @@ D.havoc (D.meet d write_cond) var_set) m d
    (** For each entry (var_set, write_cond) in the map, take the meet of d and write_cond to get the states in which
        all variables in V may update in one step. From the resulting intersection, havoc V to simulate an update.
        Do this for each entry, then join all the results together with d. *)
    
    let transitions lst =
      let aux (stmt, d) = match stmt with
        | Lang.Stmt.Instr_Assign assignments ->
          let var_set =  List.map fst assignments |> VarSet.of_list in
          I.Val (VarSetMap.add var_set d VarSetMap.empty)
        | _ -> I.bottom
      in List.map aux lst |> List.fold_left I.join I.bottom
    (** Map every set of variables appearing on the lhs of an assignment to the precondition of that assignment. *)
  end
end
