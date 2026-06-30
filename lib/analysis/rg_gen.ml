(** Tools for generating rely-guarantee conditions. *)

open Bincaml_util.Common
open Lattice_types
open Lang
open Expr

(** Utility function for getting the powerset (in list-form) of a list. Assumes list elements are unique. *)
let rec powerset = function
  | [] -> [[]]
  | x :: xs ->
    let sets_without_x = powerset xs in
    let sets_with_x = List.map (fun sublst -> x :: sublst) sets_without_x in
    sets_without_x @ sets_with_x


(** Utility function for deriving a fixpoint. *)
let rec fixpoint equal f x =
  let y = f x in
  if equal y x then y else fixpoint equal f y

(** A state domain that is compatible with rely-guarantee generation. *)
module type InterferenceStateDomain = sig
  include Lattice_types.Domain
  val meet : t -> t -> t
  val havoc : t -> VarSet.t -> t
  val filter : t -> BasilExpr.t -> t
end

module InterferenceWrappedIntervalDomain : InterferenceStateDomain = struct
  open Wrapped_intervals
  include Domain
  let meet = bot_binop WrappedIntervalsLattice.meet
  let havoc t var_set = VarSet.fold (fun var acc -> update var WrappedIntervalsLattice.top acc) var_set t
  let filter t exp = transfer t @@ Stmt.Instr_Assume { attrib = Attrib.empty; body = exp; branch = false }
end

(** A concrete interference w.r.t. some state domain is a precondition represented by that domain, and a simultaneous
    assignment that may be executed under that precondition. *)
module ConcreteInterference (D : InterferenceStateDomain) = struct
  type t = { pre: D.t; assignments: (Var.t * BasilExpr.t) list }
  [@@deriving eq, ord]

  let show t =
    let show_assignment (var, exp) = Printf.sprintf "%s := %s" (Var.show var) (BasilExpr.to_string exp) in
    let show_assignments = List.to_string ~start:"[" ~stop:"]" ~sep:", " show_assignment in
    Printf.sprintf "(%s, %s)" (D.show t.pre) (show_assignments t.assignments)
end

(** Interference domains are like abstract domains except that instead of abstracting sets of states, they abstract
    sets of pairs of states representing state transitions. In this way, they can be viewed as abstract rely-guarantee
    conditions. Rather than defining a transfer function, interference domains define a {!stabilise} function for
    applying interferences to states, as well as a {!transitions} function for deriving elements of the interference
    domain from precondition-assignment pairs. *)
module type InterferenceDomain = sig
  module D : InterferenceStateDomain
  module ConcInt : module type of ConcreteInterference(D)
  (** The underlying state domain, used by the InterferenceDomain functions, as well as the {!RelyGuaranteeGenerator}
      for generating reachable states. *)

  include Lattice
  (** Type [t] represents a set of state transitions, and is typically defined with respect to [D.t]. *)

  val stabilise : t -> D.t -> D.t
  (** [stabilise i d] returns an abstract state weaker than [d] that captures the set of states reachable by executing
      any one step in [i] from any state in [d]. *)
  
  val transitions : (ConcInt.t) list -> t
  (** [transitions p] takes a list of concrete interferences [p] and returns an element of the interference domain that
      over-approximates all transitions reachable by executing any (simultaneous) assignment under its associated
      precondition. *)
end

(** The conditional-writes domain maps each variable to the set of states under which it may be written, called its
    "write-condition". In case the target program contains simultaneous assignments, the domain of this map is sets of
    variables, rather than just variables. The map omits variable sets with write-conditions equal to bot.

    For two variable sets x and y mapping to write-conditions P and Q, we maintain the invariant that (x U y) maps to
    a write-condition stronger than P /\ Q. Thus P and Q are sufficient over-approximations of the states under which
    x and y can be written to respectively, so we avoid having to look through the write-conditions of their supersets
    when determining the conditions under which they can change. Note that (x U y) may map to a strictly stronger
    write-condition than P /\ Q, such as in the case when either x or y can change individually but never in the same
    execution trace (i.e. "at the same time").
    *)
module ConditionalWritesDomain (D : InterferenceStateDomain) : InterferenceDomain = struct
  module VarSetMap = Map.Make(VarSet)

  module D = D
  module ConcInt = ConcreteInterference(D)

  type t = Top | Val of D.t VarSetMap.t

  let name = "ConditionalWritesDomain"

  let top = Top
  
  let bottom = Val VarSetMap.empty
  (** Variables not appearing in the map are implicitly mapped to D.bottom, meaning they are never written to. *)
  
  let join i1 i2 = match i1, i2 with
    | Val m1, Val m2 -> Val (VarSetMap.union (fun _key d1 d2 -> Some (D.join d1 d2)) m1 m2)
    | _ -> Top
  (** Joins are defined component-wise over the map entries. *)
  
  let equal i1 i2 = match i1, i2 with
    | Top, Top -> true
    | Val m1, Val m2 -> VarSetMap.equal D.equal m1 m2
    | _ -> false
  
  let leq i1 i2 = equal i2 (join i1 i2)
  (** This could probably be optimised. *)
  
  let widening = join

  let narrowing = failwith "Narrowing is not implemented for the ConditionalWritesDomain"
  
  let show i = match i with
    | Top -> Bincaml_util.Unicode.top_char
    | Val m -> if VarSetMap.is_empty m then Bincaml_util.Unicode.bot_char else
      let entry_to_str = (fun (var_set, d) ->
        let var_set_str = VarSet.to_string ~start:"{" ~stop:"}" ~sep:", " Var.to_string var_set in
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
  
  let stabilise i d = match i with
    | Top -> D.top
    | Val m -> VarSetMap.fold
      (fun var_set write_cond -> D.join @@ D.havoc (D.meet d write_cond) var_set) m d
  (** For each entry (var_set, write_cond) in the map, take the meet of d and write_cond to get the states in which
      all variables in var_set may update in one step. From the resulting intersection, havoc var_set to simulate an
      update. Do this for each entry, then join all the results together with d. *)
    
  let transitions (lst: ConcInt.t list) = match lst with
    | [] -> bottom
    | { pre; assignments } :: xs ->
      (* true iff v := e may modify v under pre *)
      let var_modified (v, e) =
        (* FIXME: create fresh var with type equal to v's type *)
        let v' = Var.create "DUMMY" Types.Integer in
        (* wrap in rvar before using in expr, i think *)
        let v_exp = BasilExpr.rvar v in
        let v'_exp = BasilExpr.rvar v' in
        (* apply v' := e to get the value of v after the assignment *)
        let assign_v' = D.transfer pre (Stmt.Instr_Assign { attrib = Attrib.empty; al = [(v', e)] }) in
        (* create the expression v' != v *)
        let v_not_eq_v' = BasilExpr.binexp ~op:`EQ v_exp v'_exp in
        (* apply filter v' != v to the state resulting from v' := e *)
        let filtered = D.filter assign_v' v_not_eq_v' in
        (* if the result is bot, then v' == v must always hold after v' := e, meaning v := e doesn't change v *)
        not (D.equal filtered D.bottom)
      (* retrieve those assignments that affect the value of the assigned variable *)
      in let write_conditions =
        List.filter var_modified assignments
        (* get just the variables *)
        |> List.map fst
        (* map each subset of the resulting set of variables to 'pre' *)
        |> powerset
        |> List.map (fun sublst -> (VarSet.of_list sublst, pre))
        |> VarSetMap.of_list
      in Val write_conditions
end


module RelyGuaranteeGenerator (I : InterferenceDomain) = struct
  module D = I.D
  module ConcInt = I.ConcInt

  module type RGDomain = sig
    include Intra_analysis.IntraDomain
    val interferences: t -> ConcInt.t list
  end

  let make_domain rely : (module RGDomain) = (module struct
    let name = "RelyGuaranteeDomain"

    type t = {
      state : D.t;
      interferences : ConcInt.t list;
    }

    (* fixme *)
    let transfer_phi t p = t

    let top = failwith "top is not defined for the RelyGuaranteeDomain"
    
    let bottom = { state = D.bottom; interferences = [] }
    
    let join t1 t2 = { state = D.join t1.state t2.state; interferences = t1.interferences @ t2.interferences }
    
    let equal t1 t2 = (D.equal t1.state t2.state) && (List.equal ConcInt.equal t1.interferences t2.interferences)
    
    let leq t1 t2 = (D.leq t1.state t2.state) && (List.subset ~eq:ConcInt.equal t1.interferences t2.interferences)
    
    (* todo *)
    let widening = join

    (* todo *)
    let narrowing = failwith "Narrowing is not defined for the rely-guarantee domain."

    let transfer t stmt =
      (* stabilise t; note the stabilise function computes one environment step, so we need to do a fixpoint here *)
      let stable_pre = fixpoint D.equal (I.stabilise rely) t.state in
      (* capture transitions *)
      let interferences =
        match stmt with
        | Stmt.Instr_Assign { attrib; al } ->
          let global_assigns = List.filter (fun a -> fst a |> Var.is_global) al in
          ConcInt.{ pre = stable_pre; assignments = global_assigns } :: t.interferences
        | _ -> t.interferences
      in
      (* transfer state *)
      let post = D.transfer stable_pre stmt in
      { state = post; interferences }

    let init ?(vertex = None) p = { state = D.init p; interferences = List.empty }

    let compare t1 t2 =
      let compare_state = D.compare t1.state t2.state in
      if compare_state <> 0 then compare_state else List.compare ConcInt.compare t1.interferences t2.interferences
    
    let show t = Printf.sprintf "State: %s | Interferences: %s" (D.show t.state)
      (List.to_string ~sep:", " ConcInt.show t.interferences)
    
    let pretty t = Containers_pp.text (show t)

    let interferences t = t.interferences
  end)
  
  let derive_guar rely proc =
    let (module RGDom) = make_domain rely in
    let module Analysis = Intra_analysis.Forwards(RGDom) in
    let proof_outline = Analysis.analyse proc in
    let post_state = Analysis.A.M.find_opt Procedure.Vert.Return proof_outline in
    match post_state with
    | Some t -> I.transitions (RGDom.interferences t)
    | None ->
      let proc_name = ID.to_string (Procedure.id proc) in
      failwith (Printf.sprintf "Could not find return node for procedure %s." proc_name)
  
  let derive_rely thread guars =
    List.fold_left (fun acc (t, g) ->
      if (ID.equal (Procedure.id thread) (Procedure.id t)) then acc
      else I.join g acc) I.bottom guars
  
  let generate_rg_conditions threads =
    let initial_guars = List.map (fun thread -> (thread, I.bottom)) threads in
    let rederive_guars guars = List.map (fun thread ->
      let rely = derive_rely thread guars in
      let guar = derive_guar rely thread in
      (thread, guar)) threads
    in
    (* note: this equality function assumes that 'rederive_guars' preserves the ordering of threads in its given list *)
    (* this only holds here because 'initial_guars' orders threads identically to the 'threads' formal parameter *)
    fixpoint (List.equal (fun (_, g1) (_, g2) -> I.equal g1 g2)) rederive_guars initial_guars
end
