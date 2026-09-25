(** Simple transform to drop unused variable declarations. *)

open Lang.Common
open Lang

(** Gets the used variable declarations in a procedure. *)
let used_var_declarations p =
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

(* Transform the program, removing unused variable declarations. *)
let drop_unused_var_declarations_prog (p : Program.t) =
  let used =
    Program.procs p
    |> Iter.fold
         (fun acc (i, p) ->
           VarSet.union acc (used_var_declarations p))
         VarSet.empty
  in
  Program.filter_map_decls
    (fun _ v ->
      match v with
      | Program.(Variable { binding } as b) ->
          if VarSet.mem binding used then Some b else None
      | o -> Some o)
    p

