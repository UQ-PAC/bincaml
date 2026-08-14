open Containers

module Make (K : Mtypes.ORD_TYPE) = struct
  module M = Map.Make (K)

  (* Order stored reverse *)

  type 'a t = { order : K.t list; values : 'a M.t }
  (** invariant : \forall x . x \in order == x \in M.keys values *)

  let empty = { order = []; values = M.empty }
  let singleton k v = { order = [ k ]; values = M.singleton k v }

  let of_iter m =
    let m = Iter.persistent m in
    let values = M.of_iter m in
    (* we store in reverse order  *)
    let order = m |> Iter.map fst |> Iter.to_rev_list in
    (* no duplicate keys  *)
    assert (Int.equal (M.cardinal values) (List.length order));
    { values; order }

  let of_list m = List.to_iter m |> of_iter

  (* Get in-order iterator of keys *)
  let keys { order } = List.to_iter order |> Iter.rev

  (* Get in-order iterator of key-value pairs  *)
  let to_iter { order; values } =
    List.to_iter order |> Iter.rev |> Iter.map (fun k -> (k, M.find k values))

  (* Get in-order list of pairs of keys and values *)
  let to_list m = m |> to_iter |> Iter.to_list

  (* Values iterator in-order  *)
  let values m = to_iter m |> Iter.map snd

  (* Values iterator out-of-order *)
  let values_nondet { values } = M.values values

  (** [append k v m] replaces k -> v in m, in-place if it is already defined.
      Otherwise it is appended. This operation is the fastest insertion
      operation (O(1)). *)
  let append k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else { order = k :: order; values = M.add k v values }

  (** [add k v m] replaces k -> v in m, in-place if it is already defined.
      Otherwise it is appended. This operation is the fastest insertion
      operation (O(1)). *)
  let add k v m = append k v m

  let prepend k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else { order = order @ [ k ]; values = M.add k v values }

  let insert_before ~before k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else
      let order = List.rev order in
      let idx =
        List.find_index (fun k -> before k (M.find k values)) order
        |> Option.get_or ~default:(-1)
      in
      let order = List.insert_at_idx idx k order |> List.rev in
      { order; values = M.add k v values }

  let insert_before_key ~before k v m =
    insert_before ~before:(fun k _ -> K.equal before k) k v m

  (** Insert value at absolute index. Index is clamped to [0..len-1]. *)
  let insert_at_index ~before_index k v { order; values } =
    if M.mem k values then { order; values = M.add k v values }
    else
      let idx = List.length order - before_index in
      let order = List.insert_at_idx idx k order in
      { order; values = M.add k v values }

  (** Relatively efficient: cons *)
  let append_list news m = List.fold_left (fun acc (k, v) -> add k v acc) m news

  let insert_list_before ~before news m =
    let { values; order } = m in
    let order = List.rev order in
    let idx =
      List.find_index (fun k -> before k (M.find k values)) order
      |> Option.get_or ~default:(-1)
    in
    let add_ord =
      List.filter (fun (id, _) -> not @@ M.mem id values) news |> List.map fst
    in
    let pre, post = List.take_drop idx order in
    let order = List.rev @@ pre @ add_ord @ post in
    (* update all values  *)
    let values = List.fold_left (fun acc (k, v) -> M.add k v acc) values news in
    { order; values }

  let find k { values } = M.find k values
  let find_opt k { values } = M.find_opt k values
  let get k { values } = M.find_opt k values

  (** Out-of-order map *)
  let map f { order; values } = { order; values = M.map f values }

  (** In-order map with both positional index and key *)
  let mapi f m =
    to_iter m |> Iter.mapi (fun ind (k, v) -> (k, f ind k v)) |> of_iter

  let remove k { order; values } =
    let values' = M.remove k values in
    let order =
      if not @@ Equal.physical values' values then
        List.remove_one ~eq:K.equal k order
      else order
    in
    { order; values = values' }

  let update k f { order; values } =
    match f (M.find_opt k values) with
    | Some new_val -> { order; values = M.add k new_val values }
    | None ->
        let order = List.remove_one ~eq:K.equal k order in
        let values = M.remove k values in
        { order; values }

  (** Sort keys: just List.sort *)
  let sort_by_keys compar { order; values } =
    let order = List.sort (Ord.opp compar) order in
    { order; values }

  (** less efficient sort on values; copies index *)
  let sort (compar : (K.t * 'a) Ord.t) ({ order; values } : 'a t) =
    let ord a b =
      Ord.opp (Ord.map (fun k -> (k, M.find k values)) compar) a b
    in
    let order = List.sort ord order in
    { order; values }
end
