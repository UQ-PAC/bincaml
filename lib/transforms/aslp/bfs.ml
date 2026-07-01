type ('d, 's) successors_fn = ?from:'d -> 's -> ('d * 's) list

(** Creates a {!successors_fn} for a fractal-like structure.

    A fractal structure is one like:
    {v
        |
       -+-
        |
     |  |  |
    -+--@--+-
     |  |  |
        |
       -+-
        |
    v}
    where descending deeper will never re-encounter nodes from other branches.

    In a fractal structure, the only risk of cycles is from traversing backwards
    along an edge opposite to the one we came from. To prevent this, the
    [is_opposite] parameter is used. For the example above, we would define up
    and down, and left and right, as opposites. *)
let fractal_successors (type dir) (type st) ~(is_opposite : dir -> dir -> bool)
    ~(move : dir -> st -> st option) ~(directions : dir list) :
    (dir, st) successors_fn =
 fun ?from st ->
  directions
  |> (match from with
    | Some from -> List.filter (fun d -> not (is_opposite from d))
    | None -> Fun.id)
  |> List.filter_map (fun d -> move d st |> Option.map (CCPair.make d))

(** Makes a breadth-first search function using the given
    {!Params.successors_of} to move to adjacent positions.

    If necessary, it is the responsibility of the {!Params} implementation to
    avoid cycles and repeated visits to the same position, by filtering the
    returned successors. *)
module Make (S : Params) = struct
  open struct
    type queue = (S.direction option * S.state) CCSimple_queue.t
  end

  let rec bfs_step (q : queue) : (S.state * queue) option =
    match CCSimple_queue.pop q with
    | None -> None
    | Some ((from, st), q) ->
        let q =
          S.successors_of ?from st
          |> List.map (CCPair.map_fst Option.some)
          |> CCSimple_queue.add_list q
        in
        Some (st, q)

  let bfs st : S.state Iter.t =
    Iter.unfoldr bfs_step (CCSimple_queue.of_list [ (None, st) ])
end
