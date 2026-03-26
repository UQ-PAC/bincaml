(** Build Loop tree and transform irreducible loops to reducible *)

open Lang
open Common

(**
 * Loop identification and irreducible loop transformation.
 *
 * The [[IrreducibleLoops.transform_all_and_update]] method is the main entry
 * point for doing the identification and transformation in one step. This also
 * handles updating the loop information stored within blocks.
 *
 * Alternatively, the [[IrreducibleLoops.identify_loops]] method performs loop
 * identification, and results of this can be passed to
 * [[IrreducibleLoops.transform_loop]] to transform an irreducible loop to a
 * reducible one.
 *
 * The loop analysis produces a loop-nesting *forest* where nested sub-loops are
 * children of containing loops. A *sub-loop* of a loop is defined as a
 * strongly-connected component in the graph `V - {h}` where `V` is the set of
 * vertices (blocks) and `h` is the header of the parent loop. Examples of this
 * can be found in [the paper].
 *
 * Note that the loop-nesting tree is based on an arbitrary depth-first
 * traversal order and a CFG may have multiple valid loop-nesting trees.
 * In particular, certain nodes are chosen to be primary headers based
 * on this order. An irreducible loop, by definition, will have multiple
 * potential headers. We call the chosen header the _primary_ header
 * and any possible irreducible headers are called _secondary_ headers.
 *
 * For an overview of loop concepts and terminology, see LLVM's [Loop][]
 * and [Cycle][] pages. Note that we do not closely follow the terminology
 * of LLVM. For instance, we call both irreducible and reducible loops as
 * "loops", whereas LLVM only uses loop for *reducible* loops and uses cycle
 * for reducible or irreducible.
 *
 * [the paper]: {:http://dx.doi.org/10.1007/978-3-540-74061-2_11}
 * [Loop]: {:https://llvm.org/docs/LoopTerminology.html}
 * [Cycle]: {:https://llvm.org/docs/CycleTerminology.html}
 *)

module IrreducibleLoops = struct
  type loop_edge = { from_block : ID.t; to_block : ID.t }
  [@@deriving eq, ord, show]

  (*
  type block_loop_info = {
    block : ID.t;  (** the block which this loop information concerns. *)
    iloop_header : ID.t option;
        (** if [block] is within a loop, this records the primary header of the
            innermost loop containing [block]. Is [None] if [block] is the
            designated loop header, or [block] is not a loop participant. *)
    dfsp_pos : int;
        (** visit order index of `b` within the depth-first traversal. within
            the loop-nesting tree, parents have a _lesser_ value of `dfsp_pos`
            than all their children. *)
    headers : ID.Set.t;
        (** if [block] is a primary loop header, this stores the set of blocks
            which can be used to enter the loop. a header is defined as
            dominating all non-header nodes of the loop. *)
    nodes : ID.Set.t;
        (** if [block] is a primary loop header, this stores the set of blocks
            which are internal to the loop. this set forms a strongly-connected
            component. note that a block may be internal to multiple loops. *)
  }
  *)

  type loop_info =
    | PrimaryHeader of {
        headers : ID.Set.t;
            (** the set of blocks which can be used to enter the loop. a header
                is defined as dominating all non-header nodes of the loop. *)
        nodes : ID.Set.t;
            (** the set of blocks which are internal to the loop. this set forms
                a strongly-connected component. note that a block may be
                internal to multiple loops *)
        entries : loop_edge Iter.t Lazy.t;
            (** persistent iterator over edges which enter any header in this
                loop *)
        backedges : loop_edge Iter.t Lazy.t;
            (** persistent iterator of back-edges to any header of this loop *)
      }
    | LoopParticipant of {
        primary_header : ID.t;
            (** The block serving as the primary header for the loop we are a
                participant in *)
      }
    | NonLoop

  type block_info = { block : ID.t; dfs_pos : int; loop : loop_info }

  open struct
    (** Accesses the Basil IR state to compute the set of entry edges
        originating from outside the loop and going towards *any* header of the
        loop. *)
    let compute_entries p block headers nodes =
      lazy
        (Iter.(
           ID.Set.to_iter headers
           |> flat_map (fun h ->
               diff
                 (Procedure.blocks_pred p h |> map fst)
                 (ID.Set.to_iter nodes))
           |> map (fun from_block -> { from_block; to_block = block }))
        |> Iter.persistent)

    (** Accesses the Basil IR state to compute the set of back-edges. That is,
        the set of edges originating from _inside_ the loop and going towards
        *any* header of the loop. *)
    let compute_backedges p block headers nodes =
      lazy
        (Iter.(
           ID.Set.to_iter headers
           |> flat_map (fun h ->
               inter
                 (Procedure.blocks_pred p h |> map fst)
                 (ID.Set.to_iter nodes))
           |> map (fun from_block -> { from_block; to_block = block }))
        |> Iter.persistent)
  end

  type block_loop_state = {
    block : ID.t;  (** the block which this loop information concerns. *)
    mutable iloop_header : ID.t option;
        (** if set, header of innermost loop containing this block *)
    mutable dfsp_pos : int;
        (** if non-zero, index of this block in the current depth-first
            shortest-path. if zero, block is not visited yet or visiting the
            block has finished. *)
    mutable dfsp_pos_max : int;
        (** the non-zero value of `dfsp_pos` when it was set. this value is
            maintained even after visiting is finished. *)
    mutable is_traversed : bool;
        (** whether visiting this block has _started_. *)
    mutable headers : ID.Set.t;
        [@printer
          fun fmt m ->
            Format.pp_print_string fmt
              (ID.Set.to_string ~sep:", " ~start:"{" ~stop:"}" ID.to_string m)]
        (** headers of the loop headed by this block. if this block heads a
            loop, this always contains `b` as the primary header. for
            irreducible loops, it also contains secondary headers. *)
  }
  [@@deriving show]

  let is_irreducible { headers } = ID.Set.cardinal headers > 1
  let is_reducible { headers } = ID.Set.cardinal headers = 1
  let is_loop_header { headers } = not @@ ID.Set.is_empty headers

  let is_loop_participant { headers; iloop_header } =
    Option.is_some iloop_header || (not @@ ID.Set.is_empty headers)

  let to_loop_info p e nodes =
    let loop =
      if is_loop_header e then
        PrimaryHeader
          {
            headers = e.headers;
            nodes;
            entries = compute_entries p e.block e.headers nodes;
            backedges = compute_backedges p e.block e.headers nodes;
          }
      else if is_loop_participant e then
        LoopParticipant
          { primary_header = e.iloop_header |> Option.get_exn_or "unreachable" }
      else NonLoop
    in
    { block = e.block; dfs_pos = e.dfsp_pos_max; loop }

  let compute_block_loop_info p (block_states : block_loop_state ID.Map.t) :
      block_info list =
    let open Iter in
    let blocks =
      ID.Map.values block_states
      |> sort ~cmp:(fun a b -> -Int.compare a.dfsp_pos_max b.dfsp_pos_max)
    in
    let header_blocks =
      filter
        (function
          | { headers } when ID.Set.is_empty headers -> false | _ -> true)
        blocks
      |> Iter.persistent
    in
    let (forest : ID.Set.t ID.Map.t) =
      header_blocks
      |> map (fun b -> (b.block, ID.Set.singleton b.block))
      |> ID.Map.of_iter
    in
    let forest =
      Iter.fold
        (fun forest ->
          (function
          | { iloop_header = None } -> forest
          | { iloop_header = Some h; block } ->
              ID.Map.update h
                (function
                  | None -> Some (ID.Set.singleton block)
                  | Some e -> Some (ID.Set.add block e))
                forest))
        forest header_blocks
    in
    let forest =
      Iter.fold
        (fun forest -> function
          | { iloop_header = None } -> forest
          | { iloop_header = Some h; block } ->
              let a = ID.Map.find block forest in
              ID.Map.update h
                (function None -> Some a | Some e -> Some (ID.Set.union a e))
                forest)
        forest header_blocks
    in
    header_blocks
    |> Iter.iter (fun b ->
        let nodes = ID.Map.find b.block forest in
        let bad_headers =
          ID.Set.exists
            (fun x ->
              Procedure.blocks_pred p x
              |> exists (fun (b, _) -> not @@ ID.Set.mem b nodes))
            b.headers
        in
        if bad_headers then failwith "bad header");

    let new_loops =
      blocks
      |> map (fun b ->
          let participants =
            ID.Map.find_opt b.block forest
            |> Option.get_or ~default:ID.Set.empty
          in
          to_loop_info p b participants)
    in
    to_list new_loops
end

module TraverseLoops = struct
  open IrreducibleLoops

  type st = {
    procedure : Program.proc;
    loops : block_loop_state ID.Map.t;
    l : ID.t -> block_loop_state;
    succ : block_loop_state -> ID.t Iter.t;
    pred : block_loop_state -> ID.t Iter.t;
  }

  let create procedure =
    let loops =
      Procedure.iter_blocks_topo_fwd procedure
      |> Iter.map (fun (bid, block) ->
          ( bid,
            {
              block = bid;
              iloop_header = None;
              dfsp_pos = 0;
              dfsp_pos_max = 0;
              is_traversed = false;
              headers = ID.Set.empty;
            } ))
      |> ID.Map.of_iter
    in
    let l (b : ID.t) = ID.Map.find b loops in
    let succ (b : block_loop_state) =
      Procedure.blocks_succ procedure b.block |> Iter.map fst
    in

    let pred (b : block_loop_state) =
      Procedure.blocks_pred procedure b.block |> Iter.map fst
    in
    { procedure; loops; l; succ; pred }

  type call_arg = { block : block_loop_state; dfsp_pos : int }
  type call_action = Call of call_arg | Return of block_loop_state option
  type continuation_stack = (call_arg * block_loop_state list) list

  (** Sets `h` as the loop header for the block `b` and all containing loops. *)
  let tag_lhead s (b : block_loop_state) (h : block_loop_state option) =
    let exception Ret in
    try
      match h with
      | Some h when not @@ ID.equal b.block h.block -> begin
          let rec loop (cur1 : block_loop_state) (cur2 : block_loop_state) =
            match cur1.iloop_header with
            | Some ih when ID.equal ih cur2.block -> ()
            | Some ih ->
                if (s.l ih).dfsp_pos < cur2.dfsp_pos then (
                  cur1.iloop_header <- Some cur2.block;
                  loop cur2 (s.l ih))
                else loop (s.l ih) cur2
            | None -> ()
          in
          loop b h
        end
      | _ -> ()
    with Ret -> ()

  (** {List.iteri} but for each element we pass the tail of the list. *)
  let rec iter_tails f l =
    match l with
    | h :: tl ->
        f tl h;
        iter_tails f tl
    | [] -> ()

  (** Tail-recursive form of the DFS-based traversal described in the paper.

      The original algorithm has one recursive call, so its tail-recursive form
      has two "entry points" - one from the beginning of the function, and one
      when a recursive subcall has returned and wants to continue. This is
      implemented by using the {call_action} parameter. The [Call] variant
      denotes a normal call to the function with arguments {call_arg}, and
      the [Return] variant denotes a return from a recursive subcall,
      with its argument being the return value of the recursive subcall.

      This is combined with a stack of nested calls ({continuation_stack}). A
      recursive "call" happens by invoking the function with [Call] and pushing
      the current [call_args] onto the stack. In particular, storing the remainder of 
      the [it] list lets us resume the iteration at a later point. Upon completing
      execution of one call to the function, if the stack is non-empty, the
      function will "return" to the parent call by invoking the function with a
      `Right` argument. We use local exceptions to represent early termination 
      to the recursive call. *)
  let rec trav_loops st (input : call_action)
      (continuations : continuation_stack) =
    let open Iter in
    let exception Ret of block_loop_state option in
    let exception Recurse of (call_action * continuation_stack) in
    let run () =
      let b0, dfsp_pos, it, continuations =
        match (input, continuations) with
        | Call { block; dfsp_pos }, _ -> begin
            (* Normal function entry. The code here is in the entry
               of the paper's algorithm, before the loop begins. *)
            block.dfsp_pos <- dfsp_pos;
            block.dfsp_pos_max <- dfsp_pos;
            block.is_traversed <- true;
            let it =
              st.succ block |> map (fun b -> ID.Map.find b st.loops) |> to_list
            in
            (block, dfsp_pos, it, continuations)
          end
        | Return return, ({ block = b0; dfsp_pos }, it) :: rest -> begin
            (* Return from a recursive subcall with remaining call stack. This simply calls
               tag_lhead, which appears in the algorithm after the recursive
               subcall, then continues the iteration using the stored `it`. *)
            tag_lhead st b0 return;
            (b0, dfsp_pos, it, rest)
          end
        | Return return, [] ->
            (* this is the outermost call : we are done*)
            raise (Ret return)
      in
      (* iterate the remaining blocks *)
      it
      |> iter_tails (fun it block ->
          match block with
          | { is_traversed = true } ->
              raise
                (Recurse
                   ( Call { block; dfsp_pos = dfsp_pos + 1 },
                     ({ block = b0; dfsp_pos }, it) :: continuations ))
          | { iloop_header = Some h; block } -> begin
              if (st.l h).dfsp_pos > 0 then tag_lhead st b0 (Some (st.l h))
              else begin
                (st.l h).headers <- ID.Set.add block (st.l h).headers;
                let rec loop h =
                  match h.iloop_header with
                  | None -> ()
                  | Some h when (st.l h).dfsp_pos > 0 ->
                      tag_lhead st b0 (Some (st.l h))
                  | _ ->
                      h.headers <- ID.Set.add block h.headers;
                      loop h
                in
                loop (st.l h)
              end
            end
          | { iloop_header = None } -> ());
      b0.dfsp_pos <- 0;
      let result = Option.map st.l b0.iloop_header in
      raise (Recurse (Return result, continuations))
    in
    try run () with
    | Ret r -> r
    | Recurse (c, continuations) -> trav_loops st c continuations

  let analyse p =
    let st = create p in
    Procedure.get_entry_block p
    |> Option.iter (fun entry ->
        ignore @@ trav_loops st (Call { block = st.l entry; dfsp_pos = 1 }) []);
    IrreducibleLoops.compute_block_loop_info p st.loops
end
