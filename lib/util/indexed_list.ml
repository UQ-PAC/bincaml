(** Sequential and associative datastructure with fast iteration, appending, and
    O(logn) indexing.

    Basically, this can be used when you want an associative map but with a
    manually-specified iteration order. *)

open Containers
open Containers.Fun

open struct
  module FQ = struct
    include CCFQueue

    (** Prepends the given list to the given queue. *)
    let cons_l l q = List.fold_right CCFQueue.cons l q
  end
end

module Make (K : Mtypes.ORD_TYPE) = struct
  module S = Set.Make (K)
  module M = Map.Make (K)

  type 'a t = { order : K.t FQ.t; values : 'a M.t }
  (** invariant : \forall x . x \in order == x \in M.keys values

      [order] must be a permutation of the keys of [values]. *)

  let empty = { order = FQ.empty; values = M.empty }
  let singleton k v = { order = FQ.singleton k; values = M.singleton k v }

  (** [append k v m] replaces [k -> v] in m, in-place if it is already defined.
      Otherwise it is appended. This operation is the fastest insertion
      operation (O(1)). *)
  let append k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else { order = FQ.snoc order k; values = M.add k v values }

  let of_iter m = Iter.fold (fun m (k, v) -> append k v m) empty m
  let of_list m = List.to_iter m |> of_iter

  (** Get in-order iterator of keys *)
  let keys { order } = FQ.to_iter order

  (** Get in-order iterator of key-value pairs *)
  let to_iter { order; values } =
    FQ.to_iter order |> Iter.map (fun k -> (k, M.find k values))

  (** Get in-order list of pairs of keys and values *)
  let to_list m = m |> to_iter |> Iter.to_list

  (** Values iterator in-order *)
  let values m = to_iter m |> Iter.map snd

  (** Values iterator out-of-order *)
  let values_nondet { values } = M.values values

  (** [add k v m] replaces k -> v in m, in-place if it is already defined.
      Otherwise it is appended. This operation is the fastest insertion
      operation (O(1)). Identical to {!append}*)
  let add k v m = append k v m

  let prepend k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else { order = FQ.cons k order; values = M.add k v values }

  let insert_before ~before k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else
      let before, after =
        FQ.take_front_while (fun k -> not (before k (M.find k values))) order
      in
      let order = FQ.cons_l before (FQ.cons k after) in
      { order; values = M.add k v values }

  let insert_before_key ~before k v m =
    insert_before ~before:(fun k _ -> K.equal before k) k v m

  (** Insert value at absolute index. Negative indices count inwards from the
      end of the list, idices greater than the length append. *)
  let insert_at_index ~before_index k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else
      let before, after = FQ.take_front_l before_index order in
      let order = FQ.cons_l before (FQ.cons k after) in
      { order; values = M.add k v values }

  (** Relatively efficient: cons *)
  let append_list news m = List.fold_left (fun acc (k, v) -> add k v acc) m news

  let insert_list_before ~before news { values; order } =
    (* ignore pre-existing keys and only use leftmost position of each new key. *)
    let _, new_keys =
      let old_keys_set = S.of_iter (Iter.map fst (M.to_iter values)) in
      List.fold_filter_map
        (fun seen k -> (S.add k seen, if S.mem k seen then None else Some k))
        old_keys_set (List.map fst news)
    in

    let before, after =
      FQ.take_front_while (fun k -> before k (M.find k values)) order
    in
    let order = FQ.cons_l before (FQ.cons_l new_keys after) in
    { order; values = M.add_list values news }

  (** Lookup key, throwing [Not_found] if it does not exists. *)
  let find k { values } = M.find k values

  (** Lookup key, returning [Some] if it exists. O(log n) *)
  let find_opt k { values } = M.find_opt k values

  (** Lookup key, returning [Some] if it exists. O(log n) *)
  let get k { values } = M.find_opt k values

  (** Lookup key, throwing [Not_found] if it does not exist *)
  let get_exn k { values } = M.find k values

  (** Out-of-order map *)
  let map f { order; values } = { order; values = M.map f values }

  (** In-order map with both positional index and key *)
  let mapi f m =
    to_iter m |> Iter.mapi (fun ind (k, v) -> (k, f ind k v)) |> of_iter

  let remove k { order; values } =
    let values' = M.remove k values in
    let order =
      if not (Equal.physical values' values) then
        order |> FQ.to_iter |> Iter.filter (not % K.equal k) |> FQ.of_iter
      else order
    in
    { order; values = values' }

  let update k f m =
    match f (find k m) with
    | Some new_val -> add k new_val m
    | None -> remove k m

  (** Re-orders keys using a comparison function on keys. *)
  let sort_by_keys compar { order; values } =
    let order = order |> FQ.to_list |> List.sort compar |> FQ.of_list in
    { order; values }

  (** Re-orders keys using a comparison function on `(key, value)`. *)
  let sort (compar : (K.t * 'a) Ord.t) { order; values } =
    let cmp = Ord.opp (Ord.map (fun k -> (k, M.find k values)) compar) in
    let order = order |> FQ.to_list |> List.sort cmp |> FQ.of_list in
    { order; values }
end
