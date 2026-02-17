open Lattice_types
open Bincaml_util.Common

module type TopLattice = sig
  include Lattice

  val top : t
end

module type MapKey = sig
  include PatriciaTree.KEY

  val show : t -> string
  val pretty : t -> Containers_pp.t
end

(** Lattice map type with a specified Top value *)
module LatticeMap (K : MapKey) (V : TopLattice) = struct
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

  let show a =
    let m, s =
      match a with BotMap m -> (m, "BotMap ") | TopMap m -> (m, "Topmap ")
    in
    s
    ^ (Iter.from_iter (fun f -> KM.iter (fun k v -> f (k, v)) m)
      |> Iter.to_string ~sep:", " (fun (k, v) ->
          Printf.sprintf "%s->%s" (K.show k) (V.show v)))

  let pretty = Containers_pp.text % show

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

module LatticeMapState (V : TopLattice) = struct
  module M = LatticeMap (Var) (V)

  type val_t = V.t
  type key_t = Var.t

  open V

  let read k = function
    | M.BotMap m -> M.KM.find_opt k m |> Option.get_or ~default:V.bottom
    | M.TopMap m -> M.KM.find_opt k m |> Option.get_or ~default:V.top

  let update k v = function
    | M.BotMap m -> M.BotMap (M.KM.add k v m)
    | M.TopMap m -> M.TopMap (M.KM.add k v m)

  let to_iter = function
    | M.BotMap m | M.TopMap m ->
        Iter.from_iter (fun f -> M.KM.iter (fun k v -> f (k, v)) m)
end
