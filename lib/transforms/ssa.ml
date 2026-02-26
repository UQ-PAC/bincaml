(** Naive paramerter and SSA transform *)

open Lang.Common
open Lang
open Containers

(** FIXME: param form doesn't correct call site*)

let debug = ref false
let dbg_print = if !debug then print_endline else fun s -> ()
let dbg f = if !debug then f () else ()

(** Introduce a self-copy before every assume or assert that contains one
    variable, so that ssa has branch condition flow-sensitivity.

    https://dspace.mit.edu/bitstream/handle/1721.1/86578/48072795-MIT.pdf *)
let intro_ssi_assigns proc =
  let f b =
    b
    |> Block.flat_map ~phi:id
         Stmt.(
           function
           | (Instr_Assert { body } | Instr_Assume { body }) as a ->
               let fv = Expr.BasilExpr.free_vars body in
               if fv |> VarSet.cardinal |> Int.equal 1 then
                 let v = VarSet.choose fv in
                 Iter.doubleton (Instr_Assign [ (v, Expr.BasilExpr.rvar v) ]) a
               else Iter.singleton a
           | b -> Iter.singleton b)
  in
  Procedure.map_blocks_nondet (function id, b -> f b) proc

let check_ssa proc =
  let add_assign m v =
    VarMap.get_or ~default:0 v m |> fun n -> VarMap.add v (n + 1) m
  in
  let assigns =
    Procedure.fold_blocks_topo_fwd
      (fun acc idbl bl ->
        let acc =
          List.fold_left
            (fun acc (phi : Var.t Block.phi) -> add_assign acc phi.lhs)
            acc bl.phis
        in
        Block.stmts_iter bl
        |> Iter.fold
             (fun acc stmt -> Stmt.iter_lvar stmt |> Iter.fold add_assign acc)
             acc)
      VarMap.empty proc
  in
  assert (VarMap.for_all (fun v i -> (not (Var.pure v)) || i = 1) assigns)

let drop_unused_var_declarations_proc p =
  let used =
    Procedure.fold_blocks_topo_fwd
      (fun acc id bl ->
        Iter.append (Block.read_vars_iter bl) (Block.assigned_vars_iter bl)
        |> Iter.fold (fun acc i -> VarSet.add i acc) acc)
      VarSet.empty p
  in
  Var.Decls.filter_map_inplace
    (fun _ v -> if VarSet.mem v used then Some v else None)
    (Procedure.local_decls p);
  VarSet.filter Var.is_global used

let drop_unused_var_declarations_prog (p : Program.t) =
  let used =
    ID.Map.fold
      (fun i p acc -> VarSet.union acc (drop_unused_var_declarations_proc p))
      p.procs VarSet.empty
  in
  let globals =
    StringMap.filter_map
      (fun _ v ->
        match v with
        | Program.(Variable { binding } as b) ->
            if VarSet.mem binding used then Some b else None
        | o -> Some o)
      p.globals
  in
  { p with globals }

let set_params (p : Program.t) =
  let globs =
    p.globals |> StringMap.to_iter
    |> Iter.filter_map (function
      | i, Program.(Variable { binding }) ->
          if Var.pure binding then Some (i, binding) else None
      | _ -> None)
  in

  let inparam =
    globs
    |> Iter.map (fun (n, global) ->
        let name =
          String.drop_while (function '$' -> true | _ -> false) n ^ "_in"
        in
        (name, global))
  in
  let outparam =
    globs
    |> Iter.map (fun (n, global) ->
        let name =
          String.drop_while (function '$' -> true | _ -> false) n ^ "_out"
        in
        (name, global))
  in

  let actual_lhs = StringMap.of_iter outparam in
  let actual_rhs =
    inparam
    |> Iter.map (fun (i, j) -> (i, Expr.BasilExpr.rvar j))
    |> StringMap.of_iter
  in
  let set_params_calls_block blockid (b : Program.bloc) =
    let lhs = actual_lhs in
    let args = actual_rhs in
    Block.map ~phi:id
      (function
        | Stmt.Instr_Call { procid } -> Instr_Call { lhs; args; procid }
        | i -> i)
      b
  in
  let procs =
    p.procs
    |> ID.Map.mapi (fun procid proc ->
        let inparam =
          inparam
          |> Iter.map (fun (name, global) ->
              let v = Procedure.fresh_var ~name proc (Var.typ global) in
              (name, global, v))
          |> Iter.persistent
          (* don't re-increment on next iteration *)
        in
        let outparam =
          outparam
          |> Iter.map (fun (name, global) ->
              (name, global, Procedure.fresh_var ~name proc (Var.typ global)))
          |> Iter.persistent
          (* don't re-increment on next iteration *)
        in
        let to_block l = [ Stmt.Instr_Assign l ] in
        let to_formal param =
          param
          |> Iter.map (function name, orig, param -> (name, param))
          |> StringMap.of_iter
        in
        let assigns_in =
          inparam
          |> Iter.map (function name, orig, param ->
              (orig, Expr.BasilExpr.rvar param))
          |> Iter.to_list |> to_block
        in
        let assigns_out =
          outparam
          |> Iter.map (function name, orig, param ->
              (param, Expr.BasilExpr.rvar orig))
          |> Iter.to_list |> to_block
        in

        let add_formal_assigns graph =
          let graph, inbl =
            Procedure.fresh_block_graph proc graph ~name:"%inputs"
              ~stmts:assigns_in ()
          in
          let graph, outbl =
            Procedure.fresh_block_graph proc graph ~name:"%returns"
              ~stmts:assigns_out ()
          in
          let graph =
            let edges = Procedure.G.succ_e graph Procedure.Vert.Entry in
            let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
            let new_edges =
              List.map
                (fun (b, l, e) -> (Procedure.Vert.(End inbl), l, e))
                edges
            in
            let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
            Procedure.G.add_edge graph Entry (Begin inbl)
          in
          let graph =
            let edges = Procedure.G.pred_e graph Procedure.Vert.Return in
            let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
            let new_edges =
              List.map
                (fun (b, l, e) -> (b, l, Procedure.Vert.Begin outbl))
                edges
            in
            let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
            Procedure.G.add_edge graph (End outbl) Return
          in
          graph
        in
        let proc = Procedure.map_graph add_formal_assigns proc in
        let proc =
          Procedure.map_formal_in_params
            (fun i ->
              StringMap.union
                (fun n i j -> failwith @@ "Existing param with name: " ^ n)
                i
              @@ to_formal inparam)
            proc
        in
        let proc =
          Procedure.map_formal_out_params
            (fun i ->
              StringMap.union
                (fun n i j -> failwith @@ "Existing param with name: " ^ n)
                i (to_formal outparam))
            proc
        in
        proc)
  in
  let procs =
    procs
    |> ID.Map.mapi (fun procid proc ->
        Procedure.map_blocks_topo_fwd set_params_calls_block proc)
  in
  { p with procs }

let ssa ?(skip_observable = true) (in_proc : Program.proc) =
  let in_proc = intro_ssi_assigns in_proc in
  let lives = Livevars.run in_proc in
  let rename r v : Var.t =
    if
      (* don't rename formal out params; should only be assigned once anyway*)
      (skip_observable && not (Var.pure v))
      || Procedure.formal_out_params in_proc
         |> StringMap.exists (fun _ i -> Var.equal i v)
    then v
    else
      let nv = Procedure.fresh_var ~name:(Var.name v) in_proc (Var.typ v) in
      r := (v, nv) :: !r;
      nv
  in
  let rn_stmt rr (stmt : ('v, 'v, 'e) Stmt.t) :
      Var.t VarMap.t * ('v, 'v, 'e) Stmt.t =
    let read v =
      try VarMap.find v rr with
      | Not_found
        when (not @@ Var.pure v)
             || StringMap.exists
                  (fun i j -> Var.equal j v)
                  (Procedure.formal_out_params in_proc)
             || StringMap.exists
                  (fun i j -> Var.equal j v)
                  (Procedure.formal_in_params in_proc) ->
          v
      | Not_found ->
          failwith @@ "not found: " ^ Var.to_string v
          ^ " likely a read-uninitialised variable"
    in
    let new_renames = ref [] in
    let stmt =
      Stmt.map ~f_lvar:(rename new_renames) ~f_rvar:read
        ~f_expr:(fun e ->
          Expr.BasilExpr.substitute
            (fun v -> Some (Expr.BasilExpr.rvar @@ read v))
            e)
        stmt
    in
    let vm =
      (List.fold_left (fun m (v, nv) -> VarMap.add v nv m) rr !new_renames, stmt)
    in
    vm
  in
  let st = Hashtbl.create 100 in

  (* map from block -> (orig var  -> (var * (block * var)) list) *)
  (* block -> orig var -> phis list *)
  let (phis
        : ( IDSet.elt,
            (Var.t * (IDSet.elt * Var.t) list) VarMap.t )
          Stdlib.Hashtbl.t) =
    Hashtbl.create 100
  in

  let phi_to_def (joined_phis : (Var.t * (IDSet.elt * Var.t) list) VarMap.t) =
    VarMap.values joined_phis
    |> Iter.map (function lhs, rhs -> Block.{ lhs; rhs })
    |> Iter.to_list
  in

  let merge_existing_phi (target_block : ID.t) (block : ID.t) (v : Var.t) r =
    match r with
    | `Both ((phi, existing_phi_defs), b) ->
        Some (phi, (block, b) :: existing_phi_defs)
    | `Left phi ->
        failwith @@ "undef pred" ^ Var.to_string v ^ "  " ^ ID.to_string block
    | `Right rn ->
        dbg (fun () ->
            print_endline
            @@ "cannot join as no phi defined for variable -> should be dead \
                :: : " ^ Var.to_string v ^ " " ^ " block phi "
            ^ ID.to_string target_block ^ ID.to_string block);
        None
  in

  let merge_phi block v r =
    match r with
    | `Both ((phi, defs), b) -> Some (phi, (block, b) :: defs)
    | `Left phi -> Some phi
    | `Right rn ->
        Some
          ( Procedure.fresh_var in_proc ~name:(Var.name v) (Var.typ v),
            [ (block, rn) ] )
  in
  let delayed_phis = ref ID.Set.empty in

  let tf_block proc block_id b =
    let pred = Procedure.blocks_pred proc block_id |> Iter.to_list in
    let get_st_pred id =
      Hashtbl.get st id |> function
      | Some v -> v
      | None ->
          Hashtbl.add phis id VarMap.empty;
          delayed_phis := ID.Set.add id !delayed_phis;
          VarMap.empty
    in
    let renames, bl_phis =
      match pred with
      | [] ->
          Hashtbl.add phis block_id VarMap.empty;
          (VarMap.empty, [])
      | [ (id, _) ] -> (Hashtbl.find st id, [])
      | inc ->
          let joined_phis =
            List.map (fun (id, _) -> (id, get_st_pred id)) inc
            |> List.fold_left
                 (fun phim (block, rn) ->
                   let rn =
                     VarMap.filter
                       (fun v _ -> VarSet.mem v (lives (Begin block_id)))
                       rn
                   in
                   VarMap.merge_safe ~f:(merge_phi block) phim rn)
                 VarMap.empty
          in
          (* TODO: this will join everything, we should only join things with diff definitions *)
          Hashtbl.add phis block_id joined_phis;

          let renames = VarMap.mapi (fun i (v, t) -> v) joined_phis in
          (renames, phi_to_def joined_phis)
    in

    let renames, nb =
      Block.map_fold_forwards
        ~phi:(fun i j -> (i, j))
        ~f:(fun i a -> rn_stmt i a)
        renames b
    in
    let renames =
      let l = lives (End block_id) in
      VarMap.filter (fun v a -> VarSet.mem v l) renames
    in
    Hashtbl.add st block_id renames;
    Procedure.update_block proc block_id { nb with phis = bl_phis }
  in

  let proc = Procedure.fold_blocks_topo_fwd tf_block in_proc in_proc in

  let fixup_delayed block_id proc =
    let renames = Hashtbl.find st block_id in
    if ID.Set.mem block_id !delayed_phis then
      Procedure.blocks_succ proc block_id
      |> Iter.filter (fun (bid, _) ->
          let pred =
            Procedure.G.pred
              (Option.get_exn_or "unreachable" @@ Procedure.graph proc)
              (Begin bid)
          in
          List.length pred > 1)
      |> Iter.fold
           (fun proc (succ_bid, _) ->
             let eblock =
               Procedure.get_block proc succ_bid
               |> Option.get_exn_or "block not exist"
             in
             dbg (fun f ->
                 print_endline @@ "   updating " ^ ID.to_string succ_bid;
                 print_endline @@ "     phis"
                 ^ Iter.to_string (function a, b ->
                     Var.to_string a ^ "->" ^ Var.to_string b)
                 @@ VarMap.to_iter renames);
             let renames : Var.t VarMap.t = renames in
             let (existing : (Var.t * (ID.t * Var.t) list) VarMap.t) =
               Hashtbl.get_or ~default:VarMap.empty phis succ_bid
             in
             let nphis =
               VarMap.merge_safe
                 ~f:((merge_existing_phi succ_bid) block_id)
                 existing renames
             in
             Hashtbl.add phis succ_bid nphis;
             dbg (fun f ->
                 print_endline @@ " new PHIS "
                 ^ (nphis |> VarMap.to_iter
                   |> Iter.to_string (function v, (v2, defs) ->
                       Var.to_string v ^ "->" ^ Var.to_string v2 ^ "->"
                       ^ List.to_string
                           (function
                             | a, b -> ID.to_string a ^ "->" ^ Var.to_string b)
                           defs)));
             let phis = phi_to_def nphis in
             dbg (fun f ->
                 print_endline @@ " new PHIS "
                 ^ (phis
                   |> List.to_string (fun b -> (Block.show_phi Var.pretty) b)));
             Procedure.update_block proc succ_bid { eblock with phis })
           proc
    else proc
  in
  let proc = ID.Set.fold fixup_delayed !delayed_phis proc in
  let check_bl (block_id, (block : Program.bloc)) =
    let pred =
      Procedure.blocks_pred proc block_id |> Iter.map (fun (i, _) -> i)
    in
    let npred = Iter.length pred in
    block.phis
    |> List.map (fun (p : Var.t Block.phi) ->
        List.to_iter p.rhs |> Iter.map (fun (b, _) -> b) |> fun bs ->
        let preg = Iter.length (Iter.inter bs pred) = npred in
        let bad = Iter.diff pred bs |> Iter.to_string ~sep:", " ID.to_string in
        if not preg then
          print_endline @@ "bad: " ^ ID.to_string block_id ^ "; missing " ^ bad;
        preg)
    |> List.for_all id
  in
  assert (Procedure.iter_blocks_topo_fwd proc |> Iter.for_all check_bl);
  check_ssa proc;
  proc
