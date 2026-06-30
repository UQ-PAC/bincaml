let rec holes = function
  | [] -> []
  | hd :: tl -> (hd, tl) :: List.map (CCPair.map_snd (List.cons hd)) (holes tl)

module Make (S : sig
  type direction
  type state

  val succs : state -> direction list
  val move : direction -> state -> state option
end) =
struct
  let adjacents_with_succs st =
    S.succs st |> holes
    |> List.filter_map (fun (d, succs) ->
        S.move d st |> Option.map (fun x -> (d, (succs, x))))

  (** Iterates over all {!zipper} positions within the full diamond of the
      current zipper, expanding {i outwards} through the nested diamonds. *)
  let rec iter_bfs k (q : (S.direction list * S.state) CCSimple_queue.t) =
    match CCSimple_queue.pop q with
    | None -> ()
    | Some ((succs, zip), rest) ->
        k zip;
        iter_bfs k rest
end
