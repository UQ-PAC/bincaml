(** Lambda lifting: remove non-const globals by converting them into explicit
    in/out parameters, driven by each procedure's captures/modifies spec.

    For each procedure:
    - Every global in [captures_globs] becomes an in-parameter.
      If the global is also in [modifies_globs] the in-param key gets an [_in]
      suffix (e.g. [R0_in]) so it is distinct from the out-param.
    - Every global in [modifies_globs] becomes an out-parameter (keeping the
      original variable, e.g. [R0]).
    - A fresh initialisation block is spliced in after Entry that assigns each
      captured global its in-param value ([R0 := R0_in]), so the body continues
      to read/write the original variable throughout.

    Call sites are updated to:
    - Pass the current value of each captured global as an argument.
    - Receive each modified global back as an lhs assignment target.

    After transformation [captures_globs]/[modifies_globs] are cleared and all
    [Variable] globals are removed from the program. *)

open Lang
open Lang.Common
open Containers

(** In-param key for global [g] given a procedure's set of modified globals. *)
let in_key g mods =
  if VarSet.mem g mods then Var.name g ^ "_in" else Var.name g

let transform (p : Program.t) : Program.t =
  (* ------------------------------------------------------------------ *)
  (* Pass 1 – update signatures and insert initialisation blocks        *)
  (* ------------------------------------------------------------------ *)
  let procs =
    ID.Map.map
      (fun proc ->
        let spec = Procedure.specification proc in
        let mods = VarSet.of_list spec.modifies_globs in

        (* For each captured global build an in-param triple
           (param_key, param_var, original_global).
           - Modified globals: fresh immutable local [g_in]; the body uses [g]
             (the out-param) after an init assignment [g := g_in].
           - Read-only globals: [g] itself is the in-param; no assignment
             needed since the body already reads [g] directly. *)
        let in_triples =
          List.map
            (fun g ->
              let key = in_key g mods in
              let v =
                if VarSet.mem g mods
                then Procedure.fresh_var ~name:key proc (Var.typ g)
                else g
              in
              (key, v, g))
            spec.captures_globs
        in

        (* Add one formal in-param per captured global. *)
        let proc =
          Procedure.map_formal_in_params
            (fun fip ->
              List.fold_left
                (fun m (key, v, _) -> StringMap.add key v m)
                fip in_triples)
            proc
        in

        (* Add one formal out-param per modified global (original Var.t). *)
        let proc =
          Procedure.map_formal_out_params
            (fun fop ->
              List.fold_left
                (fun m g -> StringMap.add (Var.name g) g m)
                fop spec.modifies_globs)
            proc
        in

        (* Init assignments: only for modified globals.
           [g := g_in] seeds the mutable out-param from the immutable in-param.
           Read-only globals are already their own in-param; no copy needed. *)
        let init_assigns =
          List.filter_map
            (fun (_, v, g) ->
              if VarSet.mem g mods then Some (g, Expr.BasilExpr.rvar v)
              else None)
            in_triples
        in

        (* Splice init block between Entry and its old successors. *)
        let proc =
          if List.is_empty init_assigns || Option.is_none (Procedure.graph proc)
          then proc
          else
            Procedure.map_graph
              (fun graph ->
                let graph, init_id =
                  Procedure.fresh_block_graph proc graph ~name:"%ll_init"
                    ~stmts:[ Stmt.Instr_Assign init_assigns ]
                    ()
                in
                let open Procedure.Vert in
                let entry_edges = Procedure.G.succ_e graph Entry in
                let graph =
                  List.fold_left Procedure.G.remove_edge_e graph entry_edges
                in
                let graph = Procedure.G.add_edge graph Entry (Begin init_id) in
                let graph =
                  List.fold_left
                    (fun g (_, lbl, dst) ->
                      Procedure.G.add_edge_e g (End init_id, lbl, dst))
                    graph entry_edges
                in
                graph)
              proc
        in
        proc)
      p.procs
  in

  (* ------------------------------------------------------------------ *)
  (* Pass 2 – update call sites                                         *)
  (* ------------------------------------------------------------------ *)
  let procs =
    ID.Map.map
      (fun proc ->
        Procedure.map_blocks_topo_fwd
          (fun _bid (b : Program.bloc) ->
            Block.map ~phi:Fun.id
              (fun stmt ->
                match stmt with
                | Stmt.Instr_Call { procid; lhs; args } -> (
                    match ID.Map.find_opt procid procs with
                    | None -> stmt (* external callee – leave as-is *)
                    | Some callee ->
                        let cspec = Procedure.specification callee in
                        let cmods = VarSet.of_list cspec.modifies_globs in
                        (* Pass current value of each captured global. *)
                        let new_args =
                          List.fold_left
                            (fun m g ->
                              StringMap.add (in_key g cmods)
                                (Expr.BasilExpr.rvar g)
                                m)
                            args cspec.captures_globs
                        in
                        (* Receive each modified global back. *)
                        let new_lhs =
                          List.fold_left
                            (fun m g -> StringMap.add (Var.name g) g m)
                            lhs cspec.modifies_globs
                        in
                        Stmt.Instr_Call
                          { procid; lhs = new_lhs; args = new_args })
                | s -> s)
              b)
          proc)
      procs
  in

  (* ------------------------------------------------------------------ *)
  (* Final – clear specs and remove Variable globals                    *)
  (* ------------------------------------------------------------------ *)
  let procs =
    ID.Map.map
      (fun proc ->
        let spec = Procedure.specification proc in
        Procedure.set_specification proc
          { spec with captures_globs = []; modifies_globs = [] })
      procs
  in

  let globals =
    StringMap.filter
      (fun _ decl ->
        match decl with Program.Variable _ -> false | _ -> true)
      p.globals
  in

  { p with procs; globals }
