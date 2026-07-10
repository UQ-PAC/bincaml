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
let group_succ_either :
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

(** Maps each statement in the given block through [f]. For each statement, [f]
    may return either zero or more "bare" statements, {i or} a first/last pair
    of new block-level control-flow. Returns [(first, last, proc)] where [proc]
    is the updated procedure and [first] / [last] is the first / last block of
    the combined map output.

    [first] and [last] may be the same. One or both of [first]/[last] may be the
    same as the original block. In particular, any bare statements returned by
    [f] for an initial segment of the block's statements will be retained in the
    original block. If [f] returns a block ID pair, then the returned block IDs
    should not be the same as the original block ID - except, perhaps, for the
    first block of the first statement.

    Additionally, redirects the original block's incoming/outgoing edges to the
    first / last block of the mapped output. *)
let flat_map_stmts
    ~(f :
       proc:_ Procedure.t ->
       _ Stmt.t ->
       (ID.t * ID.t * _ Procedure.t, _ Stmt.t list) Either.t) ~proc base_bid =
  (* TODO: do we need a new type declaration for this big Either type? *)
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
  let first, last =
    ( List.head_opt block_id_pairs |> Option.map_or fst ~default:base_bid,
      List.last_opt block_id_pairs |> Option.map_or snd ~default:base_bid )
  in
  let proc =
    proc
    |> Procedure.transplant_outgoing_edges ~from:base_bid ~to_:last
    |>
    if not ID.(equal first base_bid) then
      Procedure.add_goto ~from:base_bid ~targets:[ first ]
    else Fun.id
  in
  (* Insert gotos between mapped blocks. This must happen after transplanting
     so we do not transplant these edges. *)
  let proc =
    List.combine_gen block_id_pairs (List.drop 1 block_id_pairs)
    |> Iter.of_gen
    |> Iter.fold
         (fun proc (first, second) ->
           let _, prev = first and next, _ = second in
           Procedure.add_goto proc ~from:prev ~targets:[ next ])
         proc
  in
  (first, last, proc)
