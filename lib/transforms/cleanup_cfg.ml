open Lang

let reachable proc =
  ID.Set.of_list
    (Procedure.fold_blocks_topo_fwd (fun acc id b -> id :: acc) [] proc)

let remove_blocks_unreachable_from_entry proc =
  let reachable = reachable proc in
  let unreachable =
    Procedure.blocks_to_list proc
    |> List.filter_map (function
      | Procedure.Vert.Begin i, b ->
          if ID.Set.mem i reachable then None else Some i
      | _ -> None)
  in
  unreachable |> List.fold_left Procedure.remove_block proc
