(** fix up ssa form *)

open Lang.Common
open Lang
open Containers
module VM = Map.Make (Var)
module VS = Set.Make (Var)

type t = Var.t VM.t

let set_params (p : Program.t) =
  let globs =
    p.globals |> Var.Decls.to_iter |> Iter.filter (fun (i, v) -> Var.pure v)
  in
  let procs =
    p.procs
    |> ID.Map.mapi (fun procid proc ->
        let inparam =
          globs
          |> Iter.map (fun (n, i) ->
              let name = n ^ "_in" in
              let v = Procedure.fresh_var ~name proc (Var.typ i) in
              (name, i, v))
          |> Iter.persistent
          (* don't re-increment on next iteration *)
        in
        let outparam =
          globs
          |> Iter.map (fun (n, i) ->
              let name = n ^ "_out" in
              (name, i, Procedure.fresh_var ~name proc (Var.typ i)))
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
        let proc, inbl =
          Procedure.fresh_block ~name:"%inputs" proc ~stmts:assigns_in ()
        in
        let proc, outbl =
          Procedure.fresh_block ~name:"%returns" proc ~stmts:assigns_out ()
        in
        let graph = Procedure.graph proc in
        let graph =
          let edges = Procedure.G.succ_e graph Procedure.Vert.Entry in
          let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
          let new_edges =
            List.map (fun (b, l, e) -> (Procedure.Vert.(End inbl), l, e)) edges
          in
          let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
          Procedure.G.add_edge graph Entry (Begin inbl)
        in
        let graph =
          let edges = Procedure.G.pred_e graph Procedure.Vert.Return in
          let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
          let new_edges =
            List.map (fun (b, l, e) -> (b, l, Procedure.Vert.Begin outbl)) edges
          in
          let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
          Procedure.G.add_edge graph (End outbl) Return
        in
        let proc = Procedure.set_graph graph proc in
        let proc =
          Procedure.map_formal_in_params (fun i -> to_formal inparam) proc
        in
        let proc =
          Procedure.map_formal_out_params (fun i -> to_formal outparam) proc
        in
        proc)
  in
  { p with procs }

let ssa (in_proc : Program.proc) =
  let lives = Livevars.run in_proc in
  CCIO.with_out
    ("live" ^ (Procedure.id in_proc |> ID.to_string) ^ ".dot")
    (fun o -> Livevars.print_live_vars_dot (Format.of_chan o) in_proc);
  let rename r v : Var.t =
    let nv = Procedure.fresh_var ~name:(Var.name v) in_proc (Var.typ v) in
    r := (v, nv) :: !r;
    nv
  in
  let rn_stmt rr (stmt : ('v, 'v, 'e) Stmt.t) : Var.t VM.t * ('v, 'v, 'e) Stmt.t
      =
    let new_renames = ref [] in
    let stmt =
      Stmt.map
        ~f_lvar:(fun v -> v)
        ~f_rvar:(fun v -> VM.get_or ~default:v v rr)
        ~f_expr:(fun e ->
          Expr.BasilExpr.substitute
            (fun v ->
              try Some (Expr.BasilExpr.rvar (VM.find v rr)) with
              | Not_found
                when StringMap.exists
                       (fun i j -> Var.equal j v)
                       (Procedure.formal_out_params in_proc)
                     || StringMap.exists
                          (fun i j -> Var.equal j v)
                          (Procedure.formal_in_params in_proc) ->
                  Some (Expr.BasilExpr.rvar v)
              | Not_found ->
                  failwith @@ "not found: " ^ Var.to_string v
                  ^ " likely a read-uninitialised variable")
            e)
        stmt
    in
    let stmt =
      Stmt.map ~f_lvar:(rename new_renames) ~f_rvar:identity ~f_expr:identity
        stmt
    in
    (List.fold_left (fun m (v, nv) -> VM.add v nv m) rr !new_renames, stmt)
  in
  let st = Hashtbl.create 100 in
  let phis = Hashtbl.create 100 in

  let phi_to_def joined_phis =
    VM.values joined_phis
    |> Iter.map (function lhs, rhs -> Block.{ lhs; rhs })
    |> Iter.to_list
  in
  let merge_existing_phi target_block block v r =
    match r with
    | `Both ((phi, defs), b) -> Some (phi, (block, b) :: defs)
    | `Left phi -> Some phi
    | `Right rn ->
        failwith @@ "cannot join as no phi defined for variable : "
        ^ Var.to_string v ^ " " ^ " block phi " ^ ID.to_string target_block
        ^ ID.to_string block
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
          Hashtbl.add phis id VM.empty;
          delayed_phis := ID.Set.add id !delayed_phis;
          VM.empty
    in
    let renames, bl_phis =
      match pred with
      | [] ->
          Hashtbl.add phis block_id VM.empty;
          (VM.empty, [])
      | [ (id, _) ] -> (Hashtbl.find st id, [])
      | inc ->
          let joined_phis =
            List.map
              (fun (id, _) ->
                ( id,
                  (*VM.filter (fun v _ -> VS.mem v (lives (Begin id)))
                  @@*)
                  get_st_pred id ))
              inc
            |> List.fold_left
                 (fun phim (block, rn) ->
                   (*print_endline @@ "live " ^ [%derive.show: Var.t list]
                   @@ VS.to_list (lives (Begin block_id));*)
                   let rn =
                     VM.filter (fun v _ -> VS.mem v (lives (Begin block_id))) rn
                   in
                   VM.merge_safe ~f:(merge_phi block) phim rn)
                 VM.empty
            (*|> VM.filter (fun v (l, ins) ->
                match ins with
                | (h, i) :: tl ->
                    not (List.for_all (fun (_, v) -> Var.equal v i) tl)
                | _ -> true)
                *)
          in
          (* TODO: this will join everything, we should only join things with diff definitions *)
          Hashtbl.add phis block_id joined_phis;

          (*let sh =
            [%derive.show: (Var.t * (Var.t * (ID.t * Var.t) list)) list]
          in
          let l = VM.to_list joined_phis in
          print_endline (sh l);*)
          let renames = VM.mapi (fun i (v, t) -> v) joined_phis in
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
      (*print_endline @@ "live " ^ [%derive.show: Var.t list] @@ VS.to_list l;*)
      VM.filter (fun v a -> VS.mem v l) renames
    in
    Hashtbl.add st block_id renames;
    (*print_endline
      ("set " ^ ID.to_string block_id ^ "  "
      ^ (VM.cardinal renames |> Int.to_string));*)
    Procedure.update_block proc block_id { nb with phis = bl_phis }
  in

  let proc = Procedure.fold_blocks_topo_fwd tf_block in_proc in_proc in

  let fixup_delayed block_id proc =
    let renames = Hashtbl.find st block_id in
    if ID.Set.mem block_id !delayed_phis then
      Procedure.blocks_succ proc block_id
      |> Iter.filter (fun (bid, _) ->
          let pred = Procedure.G.pred (Procedure.graph proc) (Begin bid) in
          List.length pred > 1)
      |> Iter.fold
           (fun proc (succ_bid, _) ->
             let phis =
               VM.merge_safe
                 ~f:((merge_existing_phi succ_bid) block_id)
                 (Hashtbl.get_or ~default:VM.empty phis succ_bid)
                 renames
               |> phi_to_def
             in
             let b =
               Procedure.get_block proc succ_bid
               |> Option.get_exn_or "block not exist"
             in
             Procedure.update_block proc succ_bid { b with phis })
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
    |> List.for_all identity
  in
  assert (Procedure.iter_blocks_topo_fwd proc |> Iter.for_all check_bl);
  proc
