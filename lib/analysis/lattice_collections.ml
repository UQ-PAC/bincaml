open Lattice_types
open Bincaml_util.Common
open Bincaml_util.Unicode

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
    | Top -> top_char

  let pretty = function
    | Fin s ->
        Containers_pp.(
          surround (text "{")
            (fill (text "," ^ newline) (TSet.to_list s |> List.map T.pretty))
            (text "}"))
    | Top -> Containers_pp.text top_char

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
  let narrowing a b = a
end

module type MapKey = sig
  include PatriciaTree.KEY

  val show : t -> string
  val pretty : t -> Containers_pp.t
end

(** Lattice map type with a specified Top value *)
module LatticeMap (K : MapKey) (V : TopLattice) = struct
  include (
    struct
      module KM = PatriciaTree.MakeMap (K)
      module V = V

      type val_t = V.t
      type key_t = K.t
      type t = BotMap of V.t KM.t | TopMap of V.t KM.t

      let name = V.name ^ "MapLattice"
      let bottom = BotMap KM.empty
      let top = TopMap KM.empty
      let singleton k v = BotMap (KM.singleton k v)

      let bot_v_op f _ x y =
        let x = f x y in
        if V.equal x V.bottom then None else Some x

      let top_v_op f _ x y =
        let x = f x y in
        if V.equal x V.top then None else Some x

      let underlying = function TopMap m | BotMap m -> m

      let show a =
        let m, s =
          match a with BotMap m -> (m, "") | TopMap m -> (m, "TopMap ")
        in
        "("
        ^ (Iter.from_iter (fun f ->
               KM.iter (fun k v -> f (K.show k, V.show v)) m)
          |> flip Iter.snoc
               (match a with
               | BotMap _ -> ("_", bot_char)
               | TopMap _ -> ("_", top_char))
          |> Iter.to_string ~sep:", " (fun (k, v) ->
              Printf.sprintf "%s->%s" k v))
        ^ ")"

      let pretty a =
        Containers_pp.(
          surround (text "(")
            (fill
               (text "," ^ newline)
               (KM.to_list (underlying a)
               |> List.map (fun (k, v) -> (K.pretty k, V.pretty v))
               |> List.append
                    [
                      ( text "_",
                        text
                          (match a with
                          | BotMap _ -> bot_char
                          | TopMap _ -> top_char) );
                    ]
               |> List.map (fun (k, v) -> k ^ text "->" ^ v)))
            (text ")"))

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
        | BotMap a, TopMap b -> 1
        | TopMap a, BotMap b -> -1
        | TopMap a, TopMap b -> KM.reflexive_compare V.compare a b

      let equal a b =
        match (a, b) with
        | BotMap a, BotMap b -> KM.reflexive_equal V.equal a b
        | TopMap a, TopMap b -> KM.reflexive_equal V.equal a b
        | _ -> false

      let bot_binop f a b =
        match (a, b) with
        | BotMap a, BotMap b -> BotMap (KM.idempotent_inter_filter (bot_v_op f) a b)
        | BotMap a, TopMap b | TopMap b, BotMap a ->
            BotMap (KM.difference (bot_v_op f) a b)
        | TopMap a, TopMap b ->
            TopMap (KM.idempotent_union (const f) a b)

      let top_binop f a b =
        match (a, b) with
        | BotMap a, BotMap b -> BotMap (KM.idempotent_union (const f) a b)
        | BotMap a, TopMap b | TopMap b, BotMap a ->
            TopMap (KM.difference (top_v_op f) b a)
        | TopMap a, TopMap b ->
            TopMap (KM.idempotent_inter_filter (top_v_op f) a b)

      let join = top_binop V.join
      
      let widening = top_binop V.widening
      
      let narrowing = bot_binop V.narrowing

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

      let of_list_top l =
        TopMap
          (List.filter (fun (_, x) -> not @@ V.equal x V.top) l |> KM.of_list)

      let of_list_bot l =
        BotMap
          (List.filter (fun (_, x) -> not @@ V.equal x V.bottom) l |> KM.of_list)

      let cardinal = underlying %> KM.cardinal

      let to_list = function
        | BotMap m -> (`Bottom, KM.to_list m)
        | TopMap m -> (`Top, KM.to_list m)

      let mapi f = function
        | BotMap m -> BotMap (KM.mapi f m)
        | TopMap m -> TopMap (KM.mapi f m)

      let fold f m acc =
        match m with BotMap m -> KM.fold f m acc | TopMap m -> KM.fold f m acc
    end :
      sig
        include StateAbstraction with type val_t = V.t and type key_t = K.t

        val top : t
        val of_list_top : (K.t * V.t) list -> t
        val of_list_bot : (K.t * V.t) list -> t
        val cardinal : t -> int
        val to_list : t -> [ `Bottom | `Top ] * (K.t * V.t) list
        val singleton : K.t -> V.t -> t
        val mapi : (K.t -> V.t -> V.t) -> t -> t
        val fold : (K.t -> V.t -> 'a -> 'a) -> t -> 'a -> 'a
        val bot_binop : (V.t -> V.t -> V.t) -> t -> t -> t
      end)

  module V = V
end

(** A partial mapping from variables x_i to abstract values v_i represented by V.

    Represents the set of states where each x_i has any value in v_i, and each unmapped variable has any value. That is
    to say that unmapped variables are implicitly mapped to [V.top]. This is a refinement of {!LatticeMap}, where any
    BotMap value, or TopMap value containing a variable mapped to bot, is canonicalised to [bottom]. Users can therefore
    check if an element concretises to bottom with [equals bottom].

    The join and meet functions are defined component-wise. Thus, the join function returns an over-approximation of the
    set of states represented by the operands, as it derives a Cartesian product. For example, join [(x,0)] [(y,0)]
    yields TopMap [], i.e. top. The meet function is precise with respect to the given meet function for [V]. That is,
    if the latter is precise, an under-approximation, or an over-approximation, then the former is respectively precise,
    an under-approximation, or an over-approximation. *)
module ValueLattice (V : Lattice) = struct
  module KM = PatriciaTree.MakeMap (Var)
  module V = V

  type t = Bot | Map of V.t KM.t

  (* --- Domain-Specific Functions --- *)

  (* Return a map with a single entry from [k] to [v]. *)
  let singleton k v = Map (KM.singleton k v)

  (* Helper function for [join] and [widening]: Converts f into a function that takes 3 args instead of 2, ignores the
     first arg, and returns None if f x y evaluates to V.top. Useful for rapidly filtering out entries mapped to top. *)
  let top_v_op f _ x y =
    let x = f x y in
    if V.equal x V.top then None else Some x

  (* --- Lattice Functions --- *)

  let name = V.name ^ "TopMapLattice"

  let top = Map KM.empty
  
  let bottom = Bot

  (* assumes V.join V.top _ == V.join _ V.top == V.top *)
  let join = KM.idempotent_inter_filter (top_v_op V.join)

  let equal a b = KM.reflexive_equal V.equal a b

  let leq a b =
    match a, b with
    | Bot, _ -> true
    | Map _, Bot -> false
    | Map m1, Map m2 ->
      (* m1 leq m2 iff all variables constrained by m2 have tighter constraints in m1 *)
      m2 |> KM.for_all (fun k v ->
        match KM.find_opt k m1 with
        (* variable k is not contrained by m1 *)
        | None -> false
        (* variable k has a constraint other_v; we require it to be stronger than the constraint v in m2 *)
        | Some other_v -> V.leq other_v v)

  (* assumes V.widening V.top _ == V.widening _ V.top == V.top *)
  let widening = KM.idempotent_inter_filter (top_v_op V.widening)

  (* assumes V.narrowing x V.top == x *)
  let narrowing a b =
    let c =
      b
      |> KM.mapi (fun k v ->
        match KM.find_opt k a with
        | None -> V.narrowing V.top v
        | Some v_a -> V.narrowing v_a v)
      |> KM.filter (fun _ v -> not @@ V.equal v V.top)
    in
    if (KM.for_all (fun _ v -> not @@ V.equal v V.bottom)) c then
      Map (KM.idempotent_union (fun k v_a v_c -> v_c) a c)
    else Bot
  
  let compare a b = KM.reflexive_compare V.compare a b

  let show = function
    | Bot -> bot_char
    | Map m ->
      KM.to_list m
      |> List.to_string
        ~start:"("
        ~stop:(", _->" ^ top_char ^ ")")
        ~sep:", "
        (fun (k, v) -> (Var.show k) ^ "->" ^ (V.show v))

  let pretty = let open Containers_pp in function
    | Bot -> text bot_char
    | Map m ->
      bracket
        "("
        (fill
          (text "," ^ newline)
          (KM.to_list m
          |> List.map (fun (k, v) -> (Var.pretty k, V.pretty v))
          |> List.append [ (text "_", text top_char) ]
          |> List.map (fun (k, v) -> k ^ text "->" ^ v)))
        ")"
end
