(** Utils used in {!Aslp} which might be useful elsewhere. If the need arises,
    these should be moved to a more accessible place! *)

open Lang
open Common

(** Returns [Some (hd x, tl x)] if [x] is non-empty, otherwise returns [None].
*)
let uncons = function [] -> None | hd :: tl -> Some (hd, tl)

(** [span_while_some f xs] returns the longest prefix of [xs] where the elements
    yield [Some] when mapped through [f].

    These [Some] values are returned in the first tuple element. Upon reaching a
    value which yields [None], that value and values after it are returned in
    the second tuple element. *)
let span_while_some f =
  let rec step f rev_somes all =
    let x, rest = match all with [] -> (None, []) | hd :: tl -> (f hd, tl) in
    match x with
    | None -> (List.rev rev_somes, all)
    | Some x -> (step [@tailcall]) f (x :: rev_somes) rest
  in
  step f []

(** Groups successive list elements based on whether they are [Left] or [Right],
    maintaining relative order.

    [Left] and [Right] values within the returned list contain values like
    [('a * 'a list)] to represent a non-empty list. *)
let[@tail_mod_cons] group_succ_either :
    ('a, 'b) Either.t list -> ('a * 'a list, 'b * 'b list) Either.t list =
  let[@tail_mod_cons] rec while_left xs =
    let xs, rest = span_while_some Either.find_left xs in
    match xs with
    | [] -> while_right rest (* in case the input list starts with Right *)
    | h :: xs -> Either.Left (h, xs) :: while_right rest
  and[@tail_mod_cons] while_right xs =
    let xs, rest = span_while_some Either.find_right xs in
    match xs with
    | [] -> []
    | h :: xs -> Either.Right (h, xs) :: while_left rest
  in
  while_left

(* TODO: these could be made lazy by using Seq.t rather than list *)

(** Iterates over global variables in the given program, including both read and
    assigned variables. Order is unspecified and may have duplicates. *)
let referenced_vars_of_prog =
  Program.procs
  %> Iter.flat_map
       (snd %> Procedure.iter_blocks
       %> Iter.flat_map (fun (_, b) ->
           Iter.append (Block.read_vars_iter b) (Block.assigned_vars_iter b)))
  %> Iter.filter Var.is_global

(** Isolates statements satisfying the given predicate into their own block,
    while maintaining sequential control-flow between them. *)
let isolate_stmts_of_block ?(label = "%singleton") ~proc f bid =
  let stmts =
    Procedure.get_block proc bid |> Option.get_exn_or "block not found"
    |> fun b -> CCVector.to_list b.stmts
  in

  (* Group, then flatten isolated statements into their own list. *)
  let (grouped_stmts : _ Stmt.t list list) =
    List.group_succ ~eq:(CCFun.compose_binop f Bool.equal) stmts
    |> List.flat_map (function
      | hd :: _ as xs when f hd -> List.map List.pure xs
      | xs -> List.pure xs)
  in

  (* Insert disconnected blocks for each group, reusing [bid] for the first group. *)
  let proc, block_ids =
    grouped_stmts
    |> List.fold_map_i
         (fun proc i stmts ->
           if i = 0 then
             let stmts = CCVector.of_list stmts in
             (Procedure.modify_block proc bid (fun b -> { b with stmts }), bid)
           else Procedure.fresh_block proc ~name:label ~stmts ())
         proc
  in

  let proc =
    match List.last_opt block_ids with
    | Some to_ -> Procedure.transplant_outgoing_edges proc ~from:bid ~to_
    | None -> proc
  in

  match block_ids with
  | [] -> proc
  | hd :: tl ->
      List.fold_left
        (fun (proc, from) next ->
          (Procedure.add_goto proc ~from ~targets:[ next ], next))
        (proc, hd) tl
      |> fst

(** Replaces uses of the old block ID with the new [(first, last)] block IDs.
    The incoming edges to [old] will be redirected to [first] and the outgoing
    edges of [old] will be rebased to originate from [last].

    [first] and [last] may be the same. One or both of [first]/[last] may be the
    same as [old]. If neither is the same as [old], [old] will be removed from
    the procedure. *)
let replace_block ~old ~new_:(new_first, new_last) proc =
  proc
  |> Procedure.transplant_incoming_edges ~from:old ~to_:new_first
  |> Procedure.transplant_outgoing_edges ~from:old ~to_:new_last
  |>
  if ID.equal old new_first || ID.equal old new_last then Fun.id
  else Fun.flip Procedure.remove_block old

let flat_map_stmts
    (f :
      proc:_ Procedure.t ->
      _ Stmt.t ->
      (ID.t * ID.t * _ Procedure.t, _ Stmt.t list) Either.t) ~proc base_bid =
  let open Either in
  let b = Procedure.get_block proc base_bid |> Option.get_exn_or "not found" in
  let stmts = CCVector.to_list b.stmts and base_name = ID.name base_bid in

  (* Map, while generating block names for bare statements returned by the mapping function. *)
  let (_, proc), mapped =
    stmts
    |> List.fold_map
         (fun (bid, proc) stmt ->
           match (bid, f ~proc stmt) with
           | _, Left (first, last, proc) -> ((None, proc), Left (first, last))
           | None, Right s ->
               let name = base_name in
               let proc, bid = Procedure.fresh_block proc ~name ~stmts:[] () in
               ((Some bid, proc), Right (bid, Iter.of_list s))
           | Some bid, Right s -> ((Some bid, proc), Right (bid, Iter.of_list s)))
         (Some base_bid, proc)
  in
  let proc =
    Procedure.modify_block proc base_bid (Block.fmap_stmts_copy CCVector.clear)
  in
  (* Collects adjacent bare statements into a basic block, and inserts those statements. *)
  let proc, block_id_pairs =
    group_succ_either mapped
    |> List.fold_flat_map
         (fun proc -> function
           | Left (hd, tl) -> (proc, hd :: tl)
           | Right ((bid, hd), rest) ->
               let stmts =
                 Iter.(append hd (flat_map snd (of_list rest)))
                 |> CCVector.of_iter |> CCVector.freeze
               in
               ( Procedure.modify_block proc bid (fun b -> { b with stmts }),
                 [ (bid, bid) ] ))
         proc
  in
  (* Transplant predecessors and successors of the original block as needed. *)
  let proc =
    proc
    |> (match List.last_opt block_id_pairs with
      | Some (_, to_) -> Procedure.transplant_outgoing_edges ~from:base_bid ~to_
      | None -> Fun.id)
    |>
    match List.head_opt block_id_pairs with
    | Some (hd, _) when not ID.(equal hd base_bid) ->
        Procedure.add_goto ~from:base_bid ~targets:[ hd ]
    | _ -> Fun.id
  in
  (* Insert gotos between mapped blocks. This must happen after transplanting
     so we do not transplant these edges. *)
  List.combine_gen block_id_pairs (List.drop 1 block_id_pairs)
  |> Iter.of_gen
  |> Iter.fold
       (fun proc (first, second) ->
         let _, prev = first and next, _ = second in
         Procedure.add_goto proc ~from:prev ~targets:[ next ])
       proc

let flat_map_blocks
    (f : proc:_ Procedure.t -> ID.t -> _ Block.t -> ID.t * ID.t * _ Procedure.t)
    proc =
  Procedure.fold_blocks_topo_fwd
    (fun proc bid block ->
      let first, last, proc = f ~proc bid block in
      proc |> replace_block ~old:bid ~new_:(first, last))
    proc proc
