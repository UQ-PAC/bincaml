(* Lattice map type with a specified Top value *)

open Lattice_types
open Bincaml_util.Common

module LatticeMap (K : PatriciaTree.KEY) (V : Lattice) = struct
  module KM = PatriciaTree.MakeMap (K)

  type t = BotMap of V.t KM.t | TopMap of V.t KM.t

  let name = V.name ^ "maplattice"
  let bottom = BotMap KM.empty

  let top_vjoin _ x y =
    let j = V.join x y in
    (* if j = top then None else Some j but what is top... *)
    Some j

  let top_vwidening _ x y =
    let j = V.widening x y in
    (* if j = top then None else Some j *)
    Some j

  let show a = ""

  let pretty a = Containers_pp.text ""

  let compare a b =
    match (a, b) with
    | BotMap a, BotMap b -> KM.reflexive_compare V.compare a b
    | BotMap a, TopMap b -> KM.reflexive_compare V.compare a b
    | TopMap a, BotMap b -> -KM.reflexive_compare V.compare b a
    | TopMap a, TopMap b -> KM.reflexive_compare V.compare a b

  let equal a b =
    match (a, b) with
    | BotMap a, BotMap b -> KM.reflexive_equal V.equal a b
    | TopMap a, TopMap b -> KM.reflexive_equal V.equal a b
    | _ -> false

  let join a b =
    match (a, b) with
    | BotMap a, BotMap b -> BotMap (KM.idempotent_union (const V.join) a b)
    | BotMap a, TopMap b | TopMap b, BotMap a ->
        TopMap (KM.difference top_vjoin b a)
    | TopMap a, TopMap b -> TopMap (KM.idempotent_inter_filter top_vjoin a b)

  let widening a b =
    match (a, b) with
    | BotMap a, BotMap b -> BotMap (KM.idempotent_union (const V.widening) a b)
    | BotMap a, TopMap b | TopMap b, BotMap a ->
        TopMap (KM.difference top_vwidening b a)
    | TopMap a, TopMap b ->
        TopMap (KM.idempotent_inter_filter top_vwidening a b)
end
