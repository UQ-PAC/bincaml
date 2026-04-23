(** Remove empty and unreachable CFG basic-blocks *)

open Lang
open Lang.Common

let reachable proc =
  IDSet.of_list
    (Procedure.fold_blocks_topo_fwd (fun acc id b -> id :: acc) [] proc)

let remove_blocks_unreachable_from_entry proc =
  let reachable = reachable proc in
  let unreachable =
    Procedure.blocks_to_list proc
    |> List.filter_map (function
      | Procedure.Vert.Begin i, b ->
          if IDSet.mem i reachable then None else Some i
      | _ -> None)
  in
  unreachable |> List.fold_left Procedure.remove_block proc

let collapse_empty_blocks proc =
  (* Iteratates over all blocks, and if one is empty we remove all jumps into
     this block and add jumps from those vertices to the gotos of this block,
     minus the block itself (in case of a loop on the block itself) *)
  let is_empty (block : Program.bloc) =
    Vector.is_empty block.stmts && List.is_empty block.phis
  in
  Procedure.fold_blocks_topo_fwd
    (fun proc bid block ->
      if is_empty block then
        let succ =
          Procedure.blocks_succ proc bid |> Iter.map fst |> List.of_iter
        in
        if Procedure.is_entry_block proc bid then
          (* If this is an entry then set the successor to entry if it's unique *)
          if List.length succ = 1 then
            Procedure.set_entry_block proc (List.hd succ)
          else proc
        else if List.is_empty succ then
          (* Don't collapse terminal edges for now *)
          proc
        else
          let proc =
            Procedure.blocks_pred proc bid
            |> Iter.fold
                 (fun proc (pbid, pblock) ->
                   Procedure.add_goto proc ~from:pbid ~targets:succ)
                 proc
          in
          let proc = Procedure.remove_block proc bid in
          proc
      else proc)
    proc proc

let cleanup_cfg proc =
  collapse_empty_blocks proc |> remove_blocks_unreachable_from_entry
