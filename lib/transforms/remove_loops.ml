open Lang
open Common
open Analysis.Irreducible_loops
open Expr

(* Makes reducible loops acyclic according to the algorithm described in
  https://dx.doi.org/10.1145/1108768.1108813.

  The only difference is that we put asserts at top of loop header block
  instead of at the ends of non-entry blocks. *)

let transform_loop (prog : Program.t) (proc : Program.proc)
    (loop : ProcIntra.block_info) =
  let header, next_h, headers, nodes, entries, backedges =
    match loop with
    | { block; loop = PrimaryHeader { primary_header; headers; nodes } } ->
        let entries = ProcIntra.compute_entries proc loop in
        let backedges = ProcIntra.compute_backedges proc loop in
        (block, primary_header, headers, nodes, entries, backedges)
    | _ -> raise (Invalid_argument "called on non-primary header")
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
    |> VarSet.to_list
    |> List.map (fun var ->
        Stmt.Instr_IntrinCall
          {
            attrib = Attrib.empty;
            lhs = [ var ];
            name = Stmt.Intrinsic.Havoc;
            args = [];
          })
  in

  (* Assume the invariant after havocing. *)
  let assumes =
    invariants
    |> List.map (fun inv ->
        Stmt.Instr_Assume { body = inv; attrib = Attrib.empty; branch = false })
  in

  (* Update header with new statements. *)
  let header_block = Block.append_stmts header_block (havocs @ assumes) in
  let proc = Procedure.update_block proc header header_block in

  (* Add invariants to a backedge, subbing phi node vars. *)
  let add_invariants =
    let phis =
      header_block.phis
      |> List.map (fun (phi : 'v Block.phi) ->
          let rhs =
            List.find_map
              (fun (id, v) ->
                if ID.equal id header then Some (BasilExpr.rvar v) else None)
              phi.rhs
          in
          (phi.lhs, rhs))
      |> VarMap.of_list
    in
    let invariants =
      invariants
      |> List.map @@ BasilExpr.substitute (Option.flatten % flip VarMap.get phis)
      |> List.map (fun inv ->
          Stmt.Instr_Assert { body = inv; attrib = Attrib.empty })
    in
    fun block ->
      let block = Block.append_stmts block invariants in
      block
  in

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

let transform (prog : Program.t) =
  Program.map_procedures (transform_proc prog) prog
