(** Naive lambda lifting. *)

open Lang.Common
open Lang
open Containers

(** How a variable introduced by lambda-lifting relates to the original global
    it stands for. *)
type lifted_kind =
  | In_param
      (** formal in-parameter carrying the global's procedure-entry value *)
  | Out_param
      (** formal out-parameter carrying the global's procedure-exit value *)
  | Body_local  (** body-local that replaced the global at its use sites *)

type proc_lift_map = (lifted_kind * Var.t) VarMap.t
(** Maps each variable {!lift_procedure_params} introduces back to the original
    global it stands for, tagged with how it was introduced. Used to translate
    invariants expressed over the lifted program back into the original
    program's globals (see {!Chc_infer}). *)

type program_lift_map = proc_lift_map IDMap.t
(** Per-procedure {!proc_lift_map}, keyed by procedure id. *)


let should_lift ~skip_observable ~skip_maps v =
  let skip =
    (skip_observable && Var.is_shared v)
    || (skip_maps && Var.typ v |> function Map _ -> true | _ -> false)
    || (Var.is_global v && Var.is_constant v)
  in
  not skip

let param_name suffix g =
  String.drop_while (function '$' -> true | _ -> false) (Var.name g) ^ suffix

let lift_procedure_params prog ~skip_observable ~skip_maps all_lifted procid
    proc =
  let spec = Procedure.specification proc in
  (* We cannot lift variables in rely/guarantee clauses. This check
        assumes that only observable variables appear in these clauses. *)
  if not skip_observable then begin
    if not (List.is_empty spec.rely) then
      failwith
        (Printf.sprintf
           "set_params: procedure %s has non-empty rely clause (unsupported)"
           (ID.name procid));
    if not (List.is_empty spec.guarantee) then
      failwith
        (Printf.sprintf
           "set_params: procedure %s has non-empty guarantee clause \
            (unsupported)"
           (ID.name procid))
  end;
  let captures =
    List.filter (should_lift ~skip_observable ~skip_maps) spec.captures_globs
  in
  let modifies =
    List.filter (should_lift ~skip_observable ~skip_maps) spec.modifies_globs
  in
  (* (param_key, original_global, fresh_param_var) triples *)
  let inparam =
    List.map
      (fun g ->
        let name = param_name "_in" g in
        (name, g, Procedure.fresh_var ~pure:true ~name proc (Var.typ g)))
      captures
  in
  let outparam =
    List.map
      (fun g ->
        let name = param_name "_out" g in
        (name, g, Procedure.fresh_var ~pure:true ~name proc (Var.typ g)))
      modifies
  in
  (* Fresh local variable for each captured global – replaces the global
           in the procedure body so it is no longer referenced as a global. *)
  let glob_to_local =
    List.map
      (fun g ->
        let name = param_name "" g in
        (g, Procedure.fresh_var ~pure:false ~name proc (Var.typ g)))
      captures
  in
  let glob_to_local_map =
    List.fold_left
      (fun m (g, lv) -> StringMap.add (Var.name g) lv m)
      StringMap.empty glob_to_local
  in
  let local_of g = StringMap.find (Var.name g) glob_to_local_map in
  let to_formal triples =
    List.fold_left
      (fun m (name, _, v) -> StringMap.add name v m)
      StringMap.empty triples
  in
  (* %inputs block: g_local := g_in for each captured global *)
  let assigns_in =
    List.map (fun (_, g, v) -> (local_of g, Expr.BasilExpr.rvar v)) inparam
  in
  (* %returns block: g_out := g_local for each modified global *)
  let assigns_out =
    List.map (fun (_, g, v) -> (v, Expr.BasilExpr.rvar (local_of g))) outparam
  in

  let add_input_and_output_vars graph =
    let graph =
      if List.is_empty assigns_in then graph
      else
        let graph, inbl =
          Procedure.fresh_block_graph proc graph ~name:"%inputs"
            ~stmts:
              [ Stmt.Instr_Assign { al = assigns_in; attrib = Attrib.empty } ]
            ()
        in
        let open Procedure.Vert in
        let edges = Procedure.G.succ_e graph Entry in
        let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
        let new_edges = List.map (fun (_, l, e) -> (End inbl, l, e)) edges in
        let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
        Procedure.G.add_edge graph Entry (Begin inbl)
    in
    let graph =
      if List.is_empty assigns_out then graph
      else
        let graph, outbl =
          Procedure.fresh_block_graph proc graph ~name:"%returns"
            ~stmts:
              [ Stmt.Instr_Assign { al = assigns_out; attrib = Attrib.empty } ]
            ()
        in
        let open Procedure.Vert in
        let edges = Procedure.G.pred_e graph Return in
        let graph = List.fold_left Procedure.G.remove_edge_e graph edges in
        let new_edges = List.map (fun (b, l, _) -> (b, l, Begin outbl)) edges in
        let graph = List.fold_left Procedure.G.add_edge_e graph new_edges in
        Procedure.G.add_edge graph (End outbl) Return
    in
    graph
  in

  let proc = Procedure.map_graph add_input_and_output_vars proc in
  let proc =
    proc
    |> Procedure.map_formal_in_params (fun fip ->
        StringMap.union
          (fun n _ _ -> failwith @@ "Existing param with name: " ^ n)
          fip (to_formal inparam))
    |> Procedure.map_formal_out_params (fun fop ->
        StringMap.union
          (fun n _ _ -> failwith @@ "Existing param with name: " ^ n)
          fop (to_formal outparam))
  in
  (* Maps from global name to in-/out-param vars, used for spec rewriting *)
  let glob_to_inparam =
    List.fold_left
      (fun m (_, g, v) -> StringMap.add (Var.name g) v m)
      StringMap.empty inparam
  in
  let glob_to_outparam =
    List.fold_left
      (fun m (_, g, v) -> StringMap.add (Var.name g) v m)
      StringMap.empty outparam
  in
  let skip_any = skip_observable || skip_maps in
  (* replace all variables with their equivalent in the pre-state *)
  let rewrite_old_expr expr =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    let alg node =
      match node with
      | UnaryExpr { op = `Old; arg } -> replace [%here] arg
      | RVar { id } when Var.is_constant id -> Keep
      | RVar { id } -> (
          match StringMap.find_opt (Var.name id) glob_to_inparam with
          | Some v -> replace [%here] (rvar v)
          | None (* identity function *)
            when StringMap.exists
                   (fun _ n -> Var.equal id n)
                   (Procedure.formal_in_params proc) ->
              Keep
          | None when skip_any ->
              failwith
                ("Variable in contract but is not a parameter, or global \
                  captured or modified by procedure: " ^ Var.name id)
          | None -> Keep)
      | _ -> Keep
    in
    rewrite ~rw_fun:alg expr
  in
  (* Rewrite requires: replace all captured globals with in-params and
           strip any Old wrappers (all refs already denote the pre-state) *)
  let rewrite_ensures_expr expr =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    (* Rewrite ensures: Old(g) → g_in (entry value); bare modified g →
           g_out (exit value); bare captured-only g → g_in (unchanged).
           Old(g) is handled first so the bare-g pass doesn't clobber it. *)
    let fvs = Expr.BasilExpr.free_vars expr in
    let alg node =
      match node with
      | UnaryExpr { op = `Old; arg } -> replace [%here] (rewrite_old_expr arg)
      | RVar { id } when Var.is_constant id || (not @@ VarSet.mem id fvs) ->
          Keep
      | RVar { id } -> (
          match StringMap.find_opt (Var.name id) glob_to_outparam with
          | Some v -> replace [%here] (rvar v)
          | None
            when Iter.exists
                   (fun n -> Var.equal id n)
                   (StringMap.values (Procedure.formal_out_params proc)
                   |> Iter.append
                        (Procedure.formal_in_params proc |> StringMap.values))
            ->
              Keep
          | None -> (
              match StringMap.find_opt (Var.name id) glob_to_inparam with
              | Some v -> replace [%here] (rvar v)
              | None when skip_any ->
                  failwith
                    ("Variable in contract but is not captured or modified by \
                      procedure: " ^ Var.name id)
              | None -> Keep))
      | _ -> Keep
    in
    rewrite_down ~rw_fun:alg expr
  in
  let rewrite_internal_expr_old expr =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    let alg node =
      match node with
      | UnaryExpr { op = `Old; arg } -> replace [%here] (rewrite_old_expr arg)
      | _ -> Keep
    in
    rewrite_down ~rw_fun:alg expr
  in
  let rewrite_requires_expr expr = rewrite_old_expr expr in
  let proc =
    let spec = Procedure.specification proc in
    Procedure.set_specification proc
      {
        spec with
        requires = List.map rewrite_requires_expr spec.requires;
        ensures = List.map rewrite_ensures_expr spec.ensures;
      }
  in
  let proc =
    Procedure.map_blocks_topo_fwd
      (fun _bid b ->
        Block.map ~phi:Fun.id
          (Stmt.map ~f_lvar:Fun.id ~f_expr:rewrite_internal_expr_old
             ~f_rvar:Fun.id)
          b)
      proc
  in
  (* Rewrite call sites using the original p.procs specs, emitting
           g (the global) in args/lhs.  The body substitution below then
           turns those into g_local automatically. *)
  let proc =
    Procedure.map_blocks_topo_fwd
      (fun _bid b ->
        Block.map ~phi:Fun.id
          (function
            | Stmt.Instr_Call { procid; lhs; args; attrib } as stmt -> (
                match Program.proc_opt prog procid with
                | None -> stmt
                | Some callee ->
                    let cspec = Procedure.specification callee in
                    let new_args =
                      List.fold_left
                        (fun m g ->
                          if should_lift ~skip_observable ~skip_maps g then
                            StringMap.add (param_name "_in" g)
                              (Expr.BasilExpr.rvar g) m
                          else m)
                        args cspec.captures_globs
                    in
                    let new_lhs =
                      List.fold_left
                        (fun m g ->
                          if should_lift ~skip_observable ~skip_maps g then
                            StringMap.add (param_name "_out" g) g m
                          else m)
                        lhs cspec.modifies_globs
                    in
                    Stmt.Instr_Call
                      { procid; lhs = new_lhs; args = new_args; attrib })
            | s -> s)
          b)
      proc
  in
  (* Substitute g → g_local throughout the body (including the call
           args/lhs emitted above), eliminating all global references. *)
  let subst_var v =
    Option.value ~default:v (StringMap.find_opt (Var.name v) glob_to_local_map)
  in
  let subst_expr e =
    Expr.BasilExpr.substitute
      (fun v ->
        Option.map Expr.BasilExpr.rvar
          (StringMap.find_opt (Var.name v) glob_to_local_map))
      e
  in
  let proc =
    Procedure.map_blocks_topo_fwd
      (fun _bid b ->
        Block.map ~phi:Fun.id
          (Stmt.map ~f_lvar:subst_var ~f_expr:subst_expr ~f_rvar:subst_var)
          b)
      proc
  in
  (* Record how each introduced variable maps back to its original global, so
     callers can translate invariants over the lifted program back into the
     original program's globals. *)
  let lift_map =
    let add_param kind acc triples =
      List.fold_left (fun m (_, g, v) -> VarMap.add v (kind, g) m) acc triples
    in
    VarMap.empty
    |> Fun.flip (add_param In_param) inparam
    |> Fun.flip (add_param Out_param) outparam
    |> fun m ->
    List.fold_left
      (fun m (g, lv) -> VarMap.add lv (Body_local, g) m)
      m glob_to_local
  in
  (proc, lift_map)

let set_params_with_map ?(skip_observable = true) ?(skip_maps = true)
    (p : Program.t) : Program.t * program_lift_map =
  (* Collect all globals being lifted, for removal from p.globals at the end *)
  let globals_to_param_lift =
    Program.procs p
    |> Iter.fold
         (fun acc (_, proc) ->
           List.fold_left
             (fun s g ->
               if should_lift ~skip_observable ~skip_maps g then g :: s else s)
             acc (Procedure.specification proc).captures_globs)
         []
  in

  (* remove lifted from modifies specification *)
  let fix_specification _ proc =
    let spec = Procedure.specification proc in
    Procedure.set_specification proc
      {
        spec with
        captures_globs =
          List.filter
            (fun g -> not (should_lift ~skip_observable ~skip_maps g))
            spec.captures_globs;
        modifies_globs =
          List.filter
            (fun g -> not (should_lift ~skip_observable ~skip_maps g))
            spec.modifies_globs;
      }
  in

  let lift_maps = ref IDMap.empty in
  let lift procid proc =
    let proc, m =
      lift_procedure_params p ~skip_observable ~skip_maps globals_to_param_lift
        procid proc
    in
    lift_maps := IDMap.add procid m !lift_maps;
    proc
  in
  let p =
    p
    |> Program.map_procedures lift
    |> Program.map_procedures fix_specification
    |> Program.filter_decls (fun _ -> function
      | Program.Variable { binding } ->
          not (List.exists (Var.equal binding) globals_to_param_lift)
      | _ -> true)
  in
  (p, !lift_maps)

(** Lambda-lifting: replace captured globals with explicit parameters. Discards
    the back-translation map; use {!set_params_with_map} to keep it. *)
let set_params ?skip_observable ?skip_maps (p : Program.t) : Program.t =
  fst (set_params_with_map ?skip_observable ?skip_maps p)

