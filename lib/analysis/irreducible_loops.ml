(** Build Loop tree and transform irreducible loops to reducible *)

open Lang
open Common

module type GSig = sig
  (** Minimal graph structure for computing forest *)

  type t

  module V : sig
    include Graph.Sig.COMPARABLE

    val show : t -> string
    val pp : Format.t -> t -> unit
  end

  type vertex = V.t

  module E : sig
    include Graph.Sig.EDGE with type vertex = vertex

    val show : t -> string
    val pp : Format.t -> t -> unit
  end

  type edge = E.t

  val find_edge : t -> vertex -> vertex -> edge
  val succ : t -> vertex -> vertex list
  val pred : t -> vertex -> vertex list
  val iter_vertex : (vertex -> unit) -> t -> unit
end

module type G = Graph.Sig.G

module Make (G : GSig) = struct
  module VSet = Set.Make (G.V)
  module VMap = Map.Make (G.V)

  let vset_pp fmt m =
    Format.pp_print_string fmt
      (VSet.to_string ~sep:", " ~start:"{" ~stop:"}" G.V.show m)

  (** Loop context information of a given block. *)
  type loop_info =
    | PrimaryHeader of {
        primary_header : G.V.t option;
            (** next-outermost header to this loop, if we are inside a loop *)
        headers : VSet.t; [@printer vset_pp]
            (** the set of blocks which can be used to enter the loop. a header
                is defined as dominating all non-header nodes of the loop. *)
        nodes : VSet.t; [@printer vset_pp]
            (** the set of blocks which are internal to the loop. this set forms
                a strongly-connected component. note that a block may be
                internal to multiple loops *)
      }  (** Designated primary header of a loop. *)
    | LoopParticipant of {
        primary_header : G.V.t;
            (** The block serving as the primary header for the loop we are a
                participant in *)
      }
        (** Member of a loop that is not a primary header (may be a non-primary
            header) *)
    | NonLoop
  [@@deriving show { with_path = false }, eq]

  type block_info = { block : G.V.t; dfs_pos : int; loop : loop_info }
  [@@deriving eq, show { with_path = false }]

  let classify_block b =
    match b with
    | { loop = NonLoop } -> `NonLoop
    | { loop = LoopParticipant _ } -> `LoopNode
    | { loop = PrimaryHeader { headers } } when VSet.cardinal headers = 1 ->
        `ReducibleHeader
    | { loop = PrimaryHeader { headers } } -> `IrreducibleHeader

  (** Accesses the Basil IR state to compute the set of entry edges originating
      from outside the loop and going towards *any* header of the loop. *)
  let compute_entries p = function
    | { block; loop = PrimaryHeader { headers; nodes } } ->
        Iter.(
          VSet.to_iter headers
          |> flat_map (fun h ->
              G.pred p h |> List.to_iter
              |> filter (fun a -> not @@ VSet.mem a nodes)
              |> map (fun a -> G.find_edge p a h))
          |> to_list)
    | _ -> []

  (** Accesses the Basil IR state to compute the set of back-edges. That is, the
      set of edges originating from _inside_ the loop and going towards *any*
      header of the loop. *)
  let compute_backedges p = function
    | { block; loop = PrimaryHeader { headers; nodes } } ->
        Iter.(
          VSet.to_iter headers
          |> flat_map (fun h ->
              G.pred p h |> List.to_iter
              |> filter (fun a -> VSet.mem a nodes)
              |> map (fun a -> G.find_edge p a h))
          |> to_list)
    | _ -> []

  module Implementation = struct
    (** Internal implementation of irreducible loop forest algorithm.

        The loop analysis produces a loop-nesting {e forest} where nested
        sub-loops are children of containing loops. A {e sub-loop} of a loop is
        defined as a strongly-connected component in the graph [V - {h}] where
        [V] is the set of vertices (blocks) and [h] is the header of the parent
        loop. Examples of this can be found in
        {{:http://dx.doi.org/10.1007/978-3-540-74061-2_11} the paper}.

        Note that the loop-nesting tree is based on an arbitrary depth-first
        traversal order and a CFG may have multiple valid loop-nesting trees. In
        particular, certain nodes are chosen to be primary headers based on this
        order. An irreducible loop, by definition, will have multiple potential
        headers. We call the chosen header the _primary_ header and any possible
        irreducible headers are called {e secondary} headers.

        For an overview of loop concepts and terminology, see LLVM's [Loop] and
        [Cycle] pages. Note that we do not closely follow the terminology of
        LLVM. For instance, we call both irreducible and reducible loops as
        "loops", whereas LLVM only uses loop for {e reducible} loops and uses
        cycle for reducible or irreducible.

        - the paper: {:http://dx.doi.org/10.1007/978-3-540-74061-2_11}
        - Loop: {:https://llvm.org/docs/LoopTerminology.html}
        - Cycle: {:https://llvm.org/docs/CycleTerminology.html} *)

    type block_loop_state = {
      block : G.V.t;  (** the block which this loop information concerns. *)
      mutable iloop_header : G.V.t option;
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
      mutable headers : VSet.t; [@printer vset_pp]
          (** headers of the loop headed by this block. if this block heads a
              loop, this always contains `b` as the primary header. for
              irreducible loops, it also contains secondary headers. *)
    }
    [@@deriving show { with_path = false }]

    let is_irreducible { headers } = VSet.cardinal headers > 1
    let is_reducible { headers } = VSet.cardinal headers = 1
    let is_loop_header { headers } = not @@ VSet.is_empty headers

    let is_loop_participant { headers; iloop_header } =
      Option.is_some iloop_header || (not @@ VSet.is_empty headers)

    let to_loop_info p e nodes =
      let loop =
        if is_loop_header e then
          PrimaryHeader
            { primary_header = e.iloop_header; headers = e.headers; nodes }
        else if is_loop_participant e then
          LoopParticipant
            {
              primary_header = e.iloop_header |> Option.get_exn_or "unreachable";
            }
        else NonLoop
      in
      { block = e.block; dfs_pos = e.dfsp_pos_max; loop }

    (** return loop forest in {b reverse} topological order.*)
    let compute_block_loop_info p (block_states : block_loop_state VMap.t) :
        block_info list =
      let open Iter in
      (*NOTE: loops are in *bottom-up topological order.*)
      let all_blocks =
        VMap.values block_states
        |> sort ~cmp:(fun a b -> -Int.compare a.dfsp_pos_max b.dfsp_pos_max)
      in
      let header_blocks =
        filter
          (function { headers } -> not @@ VSet.is_empty headers)
          all_blocks
        |> Iter.persistent
      in
      let (forest : VSet.t VMap.t) =
        header_blocks
        |> map (fun b -> (b.block, VSet.singleton b.block))
        |> VMap.of_iter
      in

      (* NOTE: iterates the forest in *bottom-up* topological order. this
       ensures that node-sets of sub-cycles are fully populated before
       processing their parent cycle. this avoids us having to compute
       closures of node-sets.*)
      let forest =
        all_blocks
        |> fold
             (fun forest ->
               (function
               | { iloop_header = None } -> forest
               | { iloop_header = Some h; block } ->
                   VMap.update h
                     (function
                       | None -> Some (VSet.singleton block)
                       | Some e -> Some (VSet.add block e))
                     forest))
             forest
      in
      let forest =
        header_blocks
        |> fold
             (fun forest -> function
               | { iloop_header = None } -> forest
               | { iloop_header = Some h; block } ->
                   let a = VMap.find block forest in
                   VMap.update h
                     (function
                       | None -> Some a | Some e -> Some (VSet.union a e))
                     forest)
             forest
      in
      header_blocks
      |> iter (fun b ->
          let nodes = VMap.find b.block forest in
          let bad_headers =
            VSet.filter
              (fun x ->
                not
                  (G.pred p x |> List.exists (fun b -> not @@ VSet.mem b nodes)))
              b.headers
          in
          if not @@ VSet.is_empty bad_headers then
            failwith @@ "loop has invalid headers: " ^ G.V.show b.block
            ^ " bad headers: "
            ^ VSet.to_string G.V.show bad_headers);

      let new_loops =
        all_blocks
        |> map (fun b ->
            let participants =
              VMap.find_opt b.block forest |> Option.get_or ~default:VSet.empty
            in
            to_loop_info p b participants)
      in
      to_list new_loops

    type st = {
      procedure : G.t;
      loops : block_loop_state VMap.t;
      l : G.V.t -> block_loop_state;
      succ : block_loop_state -> G.V.t list;
      pred : block_loop_state -> G.V.t list;
    }
    (** Handle for accessing the analysis state.

        Field [loops] stores the state for each block, which is mutated
        internally without modifying the map itself. *)

    (** Create the initial analysis state *)
    let create procedure =
      let loops =
        Iter.from_iter (fun f -> G.iter_vertex f procedure)
        |> Iter.map (fun bid ->
            ( bid,
              {
                block = bid;
                iloop_header = None;
                dfsp_pos = 0;
                dfsp_pos_max = 0;
                is_traversed = false;
                headers = VSet.empty;
              } ))
        |> VMap.of_iter
      in
      let l (b : G.V.t) = VMap.find b loops in
      let succ (b : block_loop_state) = G.succ procedure b.block in

      let pred (b : block_loop_state) = G.pred procedure b.block in
      { procedure; loops; l; succ; pred }

    (** Sets [h] as the loop header for the block `b` and all containing loops.
    *)
    let tag_lhead s (b : block_loop_state) (h : block_loop_state option) =
      match h with
      | Some h when not @@ G.V.equal b.block h.block -> begin
          let rec loop ~(cur1 : block_loop_state) ~(cur2 : block_loop_state) =
            match cur1.iloop_header with
            | Some ih when G.V.equal ih cur2.block -> ()
            | Some ih ->
                if (s.l ih).dfsp_pos < cur2.dfsp_pos then (
                  cur1.iloop_header <- Some cur2.block;
                  loop ~cur1:cur2 ~cur2:(s.l ih))
                else loop ~cur1:(s.l ih) ~cur2
            | None -> cur1.iloop_header <- Some cur2.block
          in
          loop ~cur1:b ~cur2:h
        end
      | _ -> ()

    (** Variant of {! List.iter} which passes the tail for each element. *)
    let rec iter_tails f l =
      match l with
      | h :: tl ->
          f tl h;
          iter_tails f tl
      | [] -> ()

    type call_arg = { block : block_loop_state; dfsp_pos : int }
    (** Arguments to a recursive call of the algorithm *)

    (** Type of continuation *)
    type call_action = Call of call_arg | Return of block_loop_state option

    type continuation_stack = (call_arg * block_loop_state list) list
    (** Stack of continuations *)

    (** Tail-recursive form of the DFS-based traversal described in the paper.

        The original algorithm has one recursive call, so its tail-recursive
        form has two "entry points" - one from the beginning of the function,
        and one when a recursive subcall has returned and wants to continue.
        This is implemented by using the {!call_action} parameter. The {! Call}
        variant denotes a normal call to the function with arguments
        {! call_arg}, and the {! Return} variant denotes a return from a
        recursive subcall, with its argument being the return value of the
        recursive subcall.

        This is combined with a stack of nested calls ({!continuation_stack}). A
        recursive "call" happens by invoking the function with {! Call} and
        pushing the current {! call_args} onto the stack. In particular, storing
        the remainder of the [it] list lets us resume the iteration at a later
        point. Upon completing execution of one call to the function, if the
        stack is non-empty, the function will "return" to the parent call by
        invoking the function with a {! Return} argument. We use local
        exceptions to represent early termination to the recursive call. *)
    let rec trav_loops st (input : call_action)
        (input_continuations : continuation_stack) =
      let open Iter in
      let exception Recurse of (call_action * continuation_stack) in
      let run () =
        let b0, dfsp_pos, it, continuations =
          match (input, input_continuations) with
          | Call { block; dfsp_pos }, conts -> begin
              (* Normal function entry. The code here is in the entry
               of the paper's algorithm, before the loop begins. *)
              block.dfsp_pos <- dfsp_pos;
              block.dfsp_pos_max <- dfsp_pos;
              block.is_traversed <- true;
              let it = st.succ block |> List.map st.l in
              (block, dfsp_pos, it, conts)
            end
          | Return nh, ({ block = b0; dfsp_pos }, it) :: rest -> begin
              (* Return from a recursive subcall with remaining call stack. This simply calls
               tag_lhead, which appears in the algorithm after the recursive
               subcall, then continues the iteration using the stored `it`. *)
              tag_lhead st b0 nh;
              (b0, dfsp_pos, it, rest)
            end
          | Return nh, [] ->
              (* this is the outermost call : we are done*)
              raise_notrace (Recurse (Return nh, []))
        in
        (* iterate the remaining blocks *)
        iter_tails
          (fun it b ->
            match b with
            | { is_traversed = false } ->
                raise_notrace
                  (Recurse
                     ( Call { block = b; dfsp_pos = dfsp_pos + 1 },
                       ({ block = b0; dfsp_pos }, it) :: continuations ))
            | { dfsp_pos } when dfsp_pos > 0 -> begin
                b.headers <- VSet.add b.block b.headers;
                tag_lhead st b0 (Some b)
              end
            | { iloop_header = None } -> ()
            | { iloop_header = Some h } -> begin
                let h = st.l h in
                if h.dfsp_pos > 0 then tag_lhead st b0 (Some h)
                else begin
                  h.headers <- VSet.add b.block h.headers;
                  let rec loop h =
                    match h.iloop_header with
                    | None -> ()
                    | Some h when (st.l h).dfsp_pos > 0 ->
                        tag_lhead st b0 (Some (st.l h))
                    | Some h ->
                        let h = st.l h in
                        h.headers <- VSet.add b.block h.headers;
                        loop h
                  in
                  loop h
                end
              end)
          it;
        b0.dfsp_pos <- 0;
        let result = Option.map st.l b0.iloop_header in
        raise_notrace (Recurse (Return result, continuations))
      in
      try run () with
      | Recurse (Return c, []) -> c
      | Recurse (c, continuations) -> trav_loops st c continuations

    let dbg_show st =
      print_endline
      @@ (VMap.to_iter st.loops
         |> Iter.to_string (fun (k, v) ->
             Printf.sprintf "%s -> %s\n" (G.V.show k) (show_block_loop_state v))
         )

    let dbg_show_r r =
      print_endline
      @@ (List.to_iter r
         |> Iter.to_string (fun v -> Printf.sprintf "%s\n" (show_block_info v))
         )
  end

  (** Returns a list representing the loop forest in topological order. *)
  let solve g entry =
    let open Implementation in
    let st = create g in
    ignore @@ trav_loops st (Call { block = st.l entry; dfsp_pos = 1 }) [];
    let r = List.rev @@ compute_block_loop_info g st.loops in
    r
end

module ProcIntra = struct
  module BlockGraph = struct
    type t = Program.proc

    module V = ID

    type vertex = ID.t

    module E = struct
      type vertex = V.t

      include Graph.Util.OTProduct (V) (V)

      let src = fst
      let dst = snd

      type label = unit

      let label _ = ()
      let create v1 () v2 = (v1, v2)
      let show e = (V.show @@ src e) ^ "->" ^ V.show (dst e)
      let pp f e = Format.pp_print_string f (show e)
    end

    type edge = E.t

    let iter_vertex f p =
      Procedure.iter_blocks_topo_fwd p |> Iter.map fst |> Iter.iter f

    let find_edge p src dest : edge =
      let open Option in
      Procedure.blocks_succ p src |> Iter.find_pred (ID.equal dest) |> function
      | Some _ -> (src, dest)
      | _ -> raise Not_found

    let succ p v = Procedure.blocks_succ p v |> Iter.to_list
    let pred p v = Procedure.blocks_pred p v |> Iter.to_list
  end

  include Make (BlockGraph)

  (** Perform irreducible loop analysis and return a list containing the loop
      information label for each block in the procedure. Returns all loop tags
      for blocks in reverse-topological order. *)
  let solve_proc p =
    Procedure.get_entry_block p
    |> Option.flat_map_l (fun entry -> solve p entry)
end
