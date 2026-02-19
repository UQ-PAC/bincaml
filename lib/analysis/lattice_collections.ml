open Lattice_types
open Bincaml_util.Common

module type TopLattice = sig
  include Lattice

  val top : t
end

module type SetElem = sig
  include Set.OrderedType

  val name : string
  val show : t -> string
  val pretty : t -> Containers_pp.t
end

(** LatticeSet with specified top value representing the universe *)
module LatticeSet (T : SetElem) = struct
  module TSet = Set.Make (T)

  type t = Fin of TSet.t | Top [@@deriving eq, ord]

  module T = T

  let name = T.name ^ "LatticeSet"

  let show = function
    | Fin s -> TSet.to_string ~start:"{" ~stop:"}" T.show s
    | Top -> "Top"

  let pretty = function
    | Fin s ->
        Containers_pp.(
          text "Fin" ^ fill (text ",") (TSet.to_list s |> List.map T.pretty))
    | Top -> Containers_pp.text "Top"

  let mem x = function Top -> true | Fin s -> TSet.mem x s
  let singleton x = Fin (TSet.singleton x)
  let bottom = Fin TSet.empty
  let top = Top

  let join a b =
    match (a, b) with
    | Fin a, Fin b -> Fin (TSet.union a b)
    | Top, Fin _ | _, Top -> Top

  let leq a b =
    match (a, b) with
    | Fin a, Fin b -> TSet.subset a b
    | Top, Fin _ -> false
    | _, Top -> true

  let widening = join
end

module type MapKey = sig
  include PatriciaTree.KEY

  val show : t -> string
  val pretty : t -> Containers_pp.t
end

(** Lattice map type with a specified Top value *)
module LatticeMap (K : MapKey) (V : TopLattice) = struct
  module KM = PatriciaTree.MakeMap (K)
  module V = V

  type t = BotMap of V.t KM.t | TopMap of V.t KM.t

  let name = V.name ^ "maplattice"
  let bottom = BotMap KM.empty

  let top_vjoin _ x y =
    let j = V.join x y in
    if V.equal j V.top then None else Some j

  let top_vwidening _ x y =
    let j = V.widening x y in
    if V.equal j V.top then None else Some j

  let show a =
    let m, s =
      match a with BotMap m -> (m, "BotMap ") | TopMap m -> (m, "TopMap ")
    in
    s
    ^ (Iter.from_iter (fun f -> KM.iter (fun k v -> f (k, v)) m)
      |> Iter.to_string ~sep:", " (fun (k, v) ->
          Printf.sprintf "%s->%s" (K.show k) (V.show v)))

  let pretty a =
    Containers_pp.(
      let m, s =
        match a with BotMap m -> (m, "BotMap ") | TopMap m -> (m, "TopMap ")
      in
      text s
      ^ fill (text ",")
          (KM.to_list m
          |> List.map (fun (k, v) -> K.pretty k ^ text "->" ^ V.pretty v)))

  let underlying = function TopMap m | BotMap m -> m

  let leq a b =
    let am, bm = (underlying a, underlying b) in
    let a_overlap = KM.idempotent_inter (fun _ x _ -> x) am bm in
    match (a, b) with
    | BotMap a, BotMap b ->
        let a_left = KM.difference (fun _ _ _ -> None) am bm in
        KM.reflexive_subset_domain_for_all2 (const V.leq) a_overlap b
        && KM.for_all (fun _ x -> V.equal x V.bottom) a_left
    | BotMap a, TopMap b ->
        KM.reflexive_subset_domain_for_all2 (const V.leq) a_overlap b
    | TopMap a, TopMap b ->
        let b_left = KM.difference (fun _ _ _ -> None) bm am in
        KM.reflexive_subset_domain_for_all2 (const V.leq) a_overlap b
        && KM.for_all (fun _ x -> V.equal x V.top) b_left
    | TopMap _, BotMap _ -> false

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

  let read k = function
    | BotMap m -> KM.find_opt k m |> Option.get_or ~default:V.bottom
    | TopMap m -> KM.find_opt k m |> Option.get_or ~default:V.top

  let update k v = function
    | BotMap m when V.equal v V.bottom -> BotMap (KM.remove k m)
    | TopMap m when V.equal v V.top -> TopMap (KM.remove k m)
    | BotMap m -> BotMap (KM.add k v m)
    | TopMap m -> TopMap (KM.add k v m)

  let to_iter = function
    | BotMap m | TopMap m ->
        Iter.from_iter (fun f -> KM.iter (fun k v -> f (k, v)) m)
end

module LatticeMapState (V : TopLattice) = struct
  include
    LatticeMap
      (struct
        include Var

        let show = name
      end)
      (V)

  type val_t = V.t
  type key_t = Var.t

  module V = V
  open V
end
