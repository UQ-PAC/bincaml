open Lang
open Common

type state = {
  new_header : ID.t;
  from_variable : Var.t;
  entry_indexes : int IDMap.t;
  preceding_indices : int list IDMap.t;
}

open Analysis.Irreducible_loops.ProcIntra

let transform_loop p l =
  let open Option in
  let header, next_h, headers, nodes, entries, backedges =
    match l with
    | { block; loop = PrimaryHeader { primary_header; headers; nodes } }
      when VSet.cardinal headers > 1 ->
        let entries = compute_entries p l in
        let backedges = compute_backedges p l in
        (block, primary_header, headers, nodes, entries, backedges)
    | _ ->
        raise
          (Invalid_argument
             "called on non-primary header / non-irreducible loop ")
  in
  let dest = BlockGraph.E.dst in
  let src = BlockGraph.E.src in
  let backedges_to_primary_header =
    List.filter (BlockGraph.E.dst %> ID.equal header) backedges
  in
  let entry_indexes =
    entries @ backedges
    |> List.mapi (fun i v -> (BlockGraph.E.src v, i))
    |> IDMap.of_list
  in

  (* included entry blocks should be a superset of (externalEntries ++ backEdgesToFirstHeader).
     in particular, it additionally includes internal edges to alternative headers.*)
  (*assert (
    Iter.append (List.to_iter entries)
      (List.to_iter backedges_to_primary_header)
    |> Iter.map BlockGraph.E.src
    |> Iter.subset ~eq:ID.equal (IDMap.keys entry_indexes));
    *)
  let preceding_indices =
    entries @ backedges
    |> List.group_by ~hash:(dest %> ID.hash) ~eq:(fun a b ->
        ID.equal (dest a) (dest b))
    |> List.map (function
      | h :: tl ->
          ( dest h,
            h :: tl |> List.map src
            |> List.map (fun a -> IDMap.find a entry_indexes)
            |> List.sort_uniq ~cmp:Int.compare )
      | _ -> failwith "emtpy")
  in
  let ctrl_sz = Types.bv_min_width_for_nat (IDSet.cardinal headers) in
  let loop_crtl_v =
    Procedure.fresh_var ~pure:true
      ~name:(ID.to_string header ^ "loop_from")
      p ctrl_sz
  in
  let open Lang.Expr in
  let bvali idx =
    let size = match ctrl_sz with Bitvector i -> i | _ -> assert false in
    BasilExpr.bvconst (Bitvec.of_int ~size idx)
  in
  (* create new primary header which jumps to all existing headers *)
  let p, n_header =
    Procedure.fresh_block
      ~name:(ID.to_string header ^ "header_loop_N")
      ~successors:(List.map dest entries) p ~stmts:[] ()
  in
  ( ( p |> fun p ->
      (* add guards to old headers to restrict their predecessors to original predecessor set *)
      List.fold_left
        (fun p (h, indices) ->
          let preds =
            List.map
              (fun i ->
                BasilExpr.binexp ~op:`EQ (BasilExpr.rvar loop_crtl_v) (bvali i))
              indices
          in
          let e = BasilExpr.applyintrin ~op:`OR preds in
          let b = Procedure.find_block p h in
          let b =
            Block.prepend_stmts b [ Instr_Assume { body = e; branch = false } ]
          in
          Procedure.update_block p h b)
        p preceding_indices )
  |> fun p ->
    (* set control var index in predecessors *)
    VMap.fold
      (fun bid idx p ->
        let b = Procedure.find_block p bid in
        let b =
          Block.append_stmts b [ Instr_Assign [ (loop_crtl_v, bvali idx) ] ]
        in
        Procedure.update_block p bid b)
      entry_indexes p )
  |> fun p ->
  (* make all headers jump to the new primary header *)
  List.fold_left
    (fun p (src, dest) ->
      Procedure.modify_succs p src ~remove:[ dest ] ~add:[ n_header ])
    p
    (entries @ backedges_to_primary_header)

let transform (p : Program.proc) =
  (* NOTE: we get the result sorted in reverse-topological order *)
  let loops =
    solve_proc p
    |> List.filter (fun b ->
        match classify_block b with `IrreducibleHeader -> true | _ -> false)
  in
  List.fold_left transform_loop p loops
