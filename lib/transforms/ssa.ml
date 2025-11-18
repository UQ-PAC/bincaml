(** fix up ssa form *)

open Lang
open Containers
module VM = Map.Make (Var)
module VS = Set.Make (Var)

type t = Var.t VM.t

let ssa (proc : Program.proc) =
  let lives = Livevars.run proc in
  let rename r v : Var.t =
    let nv = Procedure.fresh_var ~name:(Var.name v) proc (Var.typ v) in
    r := (v, nv) :: !r;
    nv
  in
  let rn_stmt rr (stmt : ('v, 'v, 'e) Stmt.t) : Var.t VM.t * ('v, 'v, 'e) Stmt.t
      =
    let new_renames = ref [] in
    let ns =
      Stmt.map ~f_lvar:(rename new_renames)
        ~f_rvar:(fun v -> VM.get_or ~default:v v rr)
        ~f_expr:(fun e ->
          Expr.BasilExpr.substitute
            (fun v -> VM.find_opt v rr |> Option.map Expr.BasilExpr.rvar)
            e)
        stmt
    in
    (List.fold_left (fun m (v, nv) -> VM.add v nv m) rr !new_renames, ns)
  in
  let st = Hashtbl.create 100 in
  let phis = Hashtbl.create 100 in

  let phi_to_def joined_phis =
    VM.values joined_phis
    |> Iter.map (function lhs, rhs -> Block.{ lhs; rhs })
    |> Iter.to_list
  in
  let merge_phi block v r =
    match r with
    | `Both ((phi, defs), b) -> Some (phi, (block, b) :: defs)
    | `Left phi -> Some phi
    | `Right rn ->
        Some
          ( Procedure.fresh_var proc ~name:(Var.name v) (Var.typ v),
            [ (block, rn) ] )
  in
  let delayed_phis = ref ID.Set.empty in

  let tf_block =
   fun proc (block_id, b) ->
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
      | [ (id, _) ] -> (get_st_pred id, [])
      | inc ->
          let joined_phis =
            List.map
              (fun (id, _) ->
                ( id,
                  VM.filter (fun v _ -> VS.mem v (lives (Begin id)))
                  @@ get_st_pred id ))
              inc
            |> List.fold_left
                 (fun phim (block, rn) ->
                   let rn =
                     VM.filter (fun v _ -> VS.mem v (lives (Begin block_id))) rn
                   in
                   VM.merge_safe ~f:(merge_phi block) phim rn)
                 VM.empty
          in
          (* TODO: this will join everything, we should only join things with diff definitions *)
          Hashtbl.add phis block_id joined_phis;
          let renames = VM.map (fun (v, _) -> v) joined_phis in
          (renames, phi_to_def joined_phis)
    in

    let renames, nb =
      Block.map_fold_forwards
        ~phi:(fun i j -> (i, j))
        ~f:(fun i a -> rn_stmt i a)
        renames b
    in
    let renames =
      VM.filter (fun v a -> VS.mem v (lives (End block_id))) renames
    in
    Hashtbl.add st block_id renames;
    Procedure.update_block proc block_id { nb with phis = bl_phis }
  in

  let proc = Procedure.iter_blocks_topo_fwd proc |> Iter.fold tf_block proc in

  let fixup_delayed block_id proc =
    let renames = Hashtbl.find st block_id in
    if ID.Set.mem block_id !delayed_phis then
      Procedure.blocks_succ proc block_id
      |> Iter.fold
           (fun proc (succ_bid, _) ->
             let phis =
               VM.merge_safe ~f:(merge_phi succ_bid)
                 (* FIXME: this default might be unsafe*)
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
  ID.Set.fold fixup_delayed !delayed_phis proc
