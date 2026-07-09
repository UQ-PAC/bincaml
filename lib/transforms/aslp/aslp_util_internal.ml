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

(** Maps each statement inside the given block ID into a sequence of blocks,
    then links those blocks sequentially in control-flow. *)
let flat_map_block ~proc f bid =
  let b = Procedure.get_block proc bid |> Option.get_exn_or "block not found" in
  let new_blocks : (ID.t * _ Block.t) list = f b in
  List.fold_left
    (fun proc (bid, b) ->
      let ({ attrib; phis; stmts } : _ Block.t) = b in
      Procedure.add_block proc bid ~attrib ~phis ~stmts:(Vector.to_list stmts)
        ())
    proc new_blocks
