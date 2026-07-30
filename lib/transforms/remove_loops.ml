open Lang
open Common
open Analysis.Irreducible_loops

(* Makes reducible loops acyclic according to the algorithm described in
  https://dx.doi.org/10.1145/1108768.1108813 *)

let transform_loop (prog : Program.t) (proc : Program.proc)
    (loop : ProcIntra.block_info) =
  let header, next_h, headers, nodes, entries, backedges =
    match loop with
    | { block; loop = PrimaryHeader { primary_header; headers; nodes } } ->
        let entries = ProcIntra.compute_entries proc loop in
        let backedges = ProcIntra.compute_backedges proc loop in
        (block, primary_header, headers, nodes, entries, backedges)
    | _ ->
        raise
          (Invalid_argument
             "called on non-primary header / non-irreducible loop ")
  in
  let header_block = Procedure.get_block proc header |> Option.get in

  let dest = ProcIntra.BlockGraph.E.dst in
  let src = ProcIntra.BlockGraph.E.src in

  (* Treat any assertions in the header as invariants. *)
  let invariants =
    Block.fold_forwards ~phi:const
      ~f:(fun acc stmt ->
        match stmt with Stmt.Instr_Assert { body } -> body :: acc | _ -> acc)
      [] header_block
  in

  (* Add havoc statements. *)
  let havocs =
    Block.free_vars header_block
    |> flip
         (VarSet.fold (fun var acc -> acc))
         (Stmt.Instr_IntrinCall
            {
              attrib = Attrib.empty;
              lhs = [];
              name = Stmt.Intrinsic.Havoc;
              args = [];
            })
  in
  let proc = Procedure.

  (* Add invariants to a backedge, subbing phi node vars. *)
  let add_invariants block =
    let phis =
      header_block.phis
      |> List.map (fun (phi : 'v Block.phi) ->
          let rhs =
            List.find_map
              (fun (id, v) ->
                if ID.equal id header then Some (Expr.BasilExpr.rvar v)
                else None)
              phi.rhs
          in
          (phi.lhs, rhs))
      |> VarMap.of_list
    in
    let invariants =
      invariants
      |> List.map
         @@ Expr.BasilExpr.substitute (Option.flatten % flip VarMap.get phis)
      |> List.map (fun inv ->
          Stmt.Instr_Assert { body = inv; attrib = Attrib.empty })
    in
    let block = Block.append_stmts block invariants in
    block
  in

  let proc =
    backedges
    |> List.fold_left
         (fun acc edge ->
           let src_id : IDSet.elt = src edge in
           let dest_id : IDSet.elt = dest edge in
           let block = Procedure.get_block acc src_id |> Option.get in
           (* Update all entry nodes on back edges to assert invariants. *)
           let acc = Procedure.update_block acc src_id (add_invariants block) in
           (* Remove the back edge. *)
           Procedure.map_graph
             (fun g ->
               Procedure.G.remove_edge g (Procedure.Vert.End src_id)
                 (Procedure.Vert.Begin dest_id))
             acc)
         proc
  in

  (* Remove back edges *)
  proc

let transform_proc (prog : Program.t) (proc_id : IDSet.elt)
    (proc : Program.proc) =
  let block_infos =
    Procedure.get_entry_block proc
    |> Option.flat_map_l (fun entry -> ProcIntra.solve proc entry)
  in
  let loops =
    block_infos
    |> List.filter (fun block ->
        match ProcIntra.classify_block block with
        | `ReducibleHeader -> true
        | _ -> false)
  in
  Printf.printf "length: %d\n" @@ List.length loops;
  List.fold_left (transform_loop prog) proc loops

(* let transform_proc (prog : Program.t) (proc_id : IDSet.elt) *)
(* (proc : Program.proc) = *)
(* Block info for each block. *)
(* let block_infos = *)
(* Procedure.get_entry_block proc *)
(* |> Option.flat_map_l (fun entry -> ProcIntra.solve proc entry) *)
(* |> List.map (fun (block_info : ProcIntra.block_info) -> *)
(* (block_info.block, block_info)) *)
(* |> IDMap.of_list *)
(* in *)

(* Map each block to all back edge head nodes. *)
(* let back_edges = ProcIntra.compute_backedges proc in *)
(* let back_edges = *)
(* IDMap.map *)
(* (fun block_info -> back_edges block_info |> List.map fst |> IDSet.of_list) *)
(* block_infos *)
(* in *)

(* let _ = *)
(* block_infos |> IDMap.to_list |> List.map snd *)
(* |> List.map (fun block_info -> *)
(* print_endline @@ ProcIntra.show_block_info block_info) *)
(* in *)
(* proc *)
(* |> Procedure.map_blocks_nondet (fun (id, block) -> *)
(* match IDMap.get id block_infos with *)
(* | Some { loop = ProcIntra.PrimaryHeader { primary_header; headers } } -> *)
(* (* Get all variables touched in the loop and havoc them. *)
             (* Then assume the invariant. *) *)
(* block *)
(* | Some { loop } -> *)
(* Non headers assert invariants if they *)
(* | Some { loop = ProcIntra.LoopParticipant { primary_header } } *)
(* when IDMap.get_or ~default:IDSet.empty primary_header back_edges *)
(* |> IDSet.mem id -> *)
(* If this is the head of a backedge, assert the invariant. *)
(* block *)
(* | None -> block) *)

let transform (prog : Program.t) =
  Program.map_procedures (transform_proc prog) prog

(* Logs.info (fun m -> *)
(* m "found %d loops, %d irreducible" (List.length block_infos) *)
(* (List.count *)
(* (( function `IrreducibleHeader -> true | _ -> false ) *)
(* % classify_block) *)
(* block_infos)); *)

(* let loops = *)
(* solve_proc proc *)
(* |> List.filter (fun b -> *)
(* match classify_block b with `IrreducibleHeader -> true | _ -> false) *)
(* in *)
