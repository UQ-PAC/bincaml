(** Naive parameter and SSA transform *)

open Lang.Common
open Lang
open Containers

let debug = ref false
let dbg_print = if !debug then print_endline else fun s -> ()
let dbg f = if !debug then f () else ()

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

(** Introduce a self-copy before every assume or assert that contains one
    variable, so that ssa has branch condition flow-sensitivity.

    https://dspace.mit.edu/bitstream/handle/1721.1/86578/48072795-MIT.pdf *)
let intro_ssi_assigns proc (should_lift : Var.t -> bool) =
  let fix_block (_, b) =
    b
    |> Block.flat_map ~phi:id
         Stmt.(
           function
           | (Instr_Assert { body; attrib } | Instr_Assume { body; attrib }) as
             a ->
               let fv =
                 Expr.BasilExpr.free_vars body |> VarSet.filter should_lift
               in
               if VarSet.cardinal fv > 0 then
                 Iter.doubleton
                   (Instr_Assign
                      {
                        al =
                          VarSet.to_list fv
                          |> List.map (fun v -> (v, Expr.BasilExpr.rvar v));
                        attrib;
                      })
                   a
               else Iter.singleton a
           | b -> Iter.singleton b)
  in
  Procedure.map_blocks_nondet fix_block proc

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
    Program.procs p
    |> Iter.fold
         (fun acc (i, p) ->
           VarSet.union acc (drop_unused_var_declarations_proc p))
         VarSet.empty
  in
  Program.filter_map_decls
    (fun _ v ->
      match v with
      | Program.(Variable { binding } as b) ->
          if VarSet.mem binding used then Some b else None
      | o -> Some o)
    p

let should_lift ~skip_observable ~skip_maps v =
  let skip =
    (skip_observable && Var.is_shared v)
    || (skip_maps && Var.typ v |> function Map _ -> true | _ -> false)
    || (Var.is_global v && Var.is_constant v)
  in
  not skip

let check_ssa ~skip_observable ~skip_maps proc =
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
  assert (
    VarMap.for_all
      (fun v i -> (not (should_lift ~skip_observable ~skip_maps v)) || i = 1)
      assigns)

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

module Skip = struct
  module S = struct
    type t = Observable | Map [@@deriving show { with_path = false }, eq, ord]
  end

  include Set.Make (S)

  let full = empty |> add Observable |> add Map

  let skip (set : t) (v : Var.t) =
    (mem Observable set && Var.is_shared v)
    || (mem Map set && Var.typ v |> function Map _ -> true | _ -> false)
    (* Always skip globals and constants. *)
    || (Var.is_global v && Var.is_constant v)

  let keep s v = not @@ skip s v
end

module Construction = struct
  open Procedure
  module Dom = Graph.Dominator.Make (G)
  module WL = Worklist.Make (ID)
  module FL = Set.Make (Procedure.Vert)
  open Effect
  open Effect.Deep

  type _ Effect.t += GetReachingDef : Var.t * Vert.t -> Var.t t
  type _ Effect.t += SetReachingDef : Var.t * Var.t -> unit t
  type _ Effect.t += CreateFreshDef : Var.t * Vert.t -> Var.t t

  (** Map variables to assignment locations. *)
  let defs ?(skipping = Skip.empty) procedure =
    Procedure.iter_blocks procedure
    |> Iter.flat_map (fun (id, b) ->
        Block.assigned_vars_iter b
        (* Filter out irrelevant variables. *)
        |> Iter.filter (Skip.keep skipping)
        |> Iter.map (fun v -> (id, v)))
    |> Iter.fold
         (fun acc (id, var) ->
           VarMap.update var
             (function
               | None -> Some (IDSet.of_list [ id ])
               | Some ids -> Some (IDSet.add id ids))
             acc)
         VarMap.empty

  (** Adds phis for single var to graph given the dominance frontier and initial
      definitions of v in blocks listed in defs. *)
  let add_phis (dom_frontier : Vert.t -> Vert.t list) (graph : RevG.t)
      ((var, defs) : Var.t * IDSet.t) : RevG.t =
    (* Init the worklist to all initial define sites. *)
    let worklist = WL.create () in
    WL.add_iter worklist (IDSet.to_iter defs);

    (* fl flags blocks with added phi nodes. *)
    let flags = ref FL.empty in

    let graph = ref graph in
    while WL.non_empty worklist do
      let x = WL.pop worklist in
      dom_frontier (Vert.Begin x)
      |> List.to_iter
      (* Skip flagged blocks. *)
      |> Iter.filter (flip FL.mem !flags %> not)
      |> flip Iter.for_each (function
        | Vert.Begin id as y ->
            (* Flag the block as seen. *)
            flags := FL.add y !flags;

            (* Add to worklist if not in initial_blocks. *)
            if not @@ IDSet.mem id defs then WL.add worklist id;

            (* Add phi node for var to y. *)
            let phi : Var.t Block.phi =
              {
                lhs = var;
                rhs =
                  G.pred !graph y
                  |> List.filter_map (function
                    | Vert.End id -> Some (id, var)
                    | _ -> None);
              }
            in
            let block =
              match G.find_edge !graph (Vert.Begin id) (Vert.End id) with
              | _, Block b, _ -> b
              | _ -> raise Not_found
            in
            let block = { block with phis = phi :: block.phis } in
            graph := G.remove_edge !graph (Begin id) (End id);
            graph := G.add_edge_e !graph (Begin id, Block block, End id)
        | _ -> ())
    done;
    !graph

  (* Helper to modify a block at id *)
  let modify_block g id f =
    let _, e, _ = G.find_edge g (Begin id) (End id) in
    let block = match e with Block block -> block | Jump -> raise Not_found in
    let block = f block in
    let g = G.remove_edge g (Begin id) (End id) in
    let g = G.add_edge_e g (Begin id, Edge.Block block, End id) in
    g

  (* Map vertices in preorder dfs traversal of dominator tree. *)
  let rec traversal update_block update_succ dom_tree ((g, fl) : G.t * FL.t)
      (vert : Vert.t) =
    if FL.mem vert fl then (g, fl)
    else
      let fl = FL.add vert fl in
      let g =
        match vert with
        | Begin id ->
            (* Updating the block. First need to get the edge: *)
            modify_block g id (update_block vert)
        | End id ->
            (* Updating successor blocks: *)
            G.succ g vert
            |> List.fold_left
                 (fun g succ ->
                   match succ with
                   | Vert.Begin succ_id ->
                       modify_block g succ_id (update_succ succ_id id)
                   | _ -> g)
                 g
        | _ -> g
      in
      dom_tree vert
      |> List.fold_left (traversal update_block update_succ dom_tree) (g, fl)

  let rename_lvar vert lvar =
    let rdef = perform @@ GetReachingDef (lvar, vert) in
    (* Create a renamed lvar *)
    let lvar' = perform @@ CreateFreshDef (lvar, vert) in
    (* Point it to the rdef of original *)
    perform @@ SetReachingDef (lvar', rdef);
    (* Redirect original to this *)
    perform @@ SetReachingDef (lvar, lvar');
    lvar'

  let rename_expr vert expr =
    Expr.BasilExpr.substitute
      (fun rv ->
        Some (Expr.BasilExpr.rvar @@ perform @@ GetReachingDef (rv, vert)))
      expr

  let rename_rvar vert rvar = perform @@ GetReachingDef (rvar, vert)

  let rename_block vert block =
    (* Rename lvars in phi nodes. *)
    let block =
      Block.map
        ~phi:
          (List.map (fun (phi : Var.t Block.phi) ->
               { phi with lhs = rename_lvar vert phi.lhs }))
        Fun.id block
    in
    (* Update a statement. Two passes, first update rvars then lvars. *)
    Block.map ~phi:Fun.id
      (Stmt.map ~f_expr:(rename_expr vert) ~f_rvar:(rename_rvar vert)
         ~f_lvar:Fun.id
      %> Stmt.map ~f_expr:Fun.id ~f_rvar:Fun.id ~f_lvar:(rename_lvar vert))
      block

  let rename_succ succ_id par_id block =
    Block.map
      ~phi:
        (List.map (fun (phi : Var.t Block.phi) ->
             let rhs =
               phi.rhs
               |> List.map (function
                 | id, rvar when ID.equal id par_id ->
                     (id, rename_rvar (End par_id) rvar)
                 | o -> o)
             in
             { phi with rhs }))
      Fun.id block

  let rename_procedure ?(skipping = Skip.empty) (procedure : Program.proc)
      (g : RevG.t) tree doms =
    (* Hacky workaround not having stmt level cfg. *)
    let doms a b = doms a b || Vert.equal a b in

    (* Given a vertex, update the reaching def of the variable
       such that it is the least element which dominates the existing
       reaching def value. If no reaching def exists, set it to the
       current location. *)
    let rec update_reaching_def ?r defs reaching_defs (var : Var.t)
        (vert : Vert.t) =
      let r = Option.or_ r ~else_:(VarMap.get var reaching_defs) in
      let r' = Option.flat_map (flip VarMap.get reaching_defs) r in

      if
        r
        |> Option.flat_map (flip VarMap.get defs %> Option.map (flip doms vert))
        |> Option.get_or ~default:true %> not
      then update_reaching_def ?r:r' defs reaching_defs var vert
      else VarMap.update var (fun _ -> r) reaching_defs
    in

    let reaching_defs : Var.t VarMap.t ref = ref VarMap.empty in
    let defs = ref VarMap.empty in

    (* Traverse the procedure renaming variables.
       Handle reaching defs and renaming via effects for caching. *)
    try fst @@ traversal rename_block rename_succ tree (g, FL.empty) Entry with
    | effect GetReachingDef (var, vert), k ->
        (* Get the reaching def of a variable from a vertex.
           Also updates the reaching def, cached for future use. *)
        reaching_defs := update_reaching_def !defs !reaching_defs var vert;
        continue k (VarMap.get_or ~default:var var !reaching_defs)
    | effect SetReachingDef (var, new_var), k ->
        (* Set the reaching def of a var. *)
        reaching_defs := VarMap.add var new_var !reaching_defs;
        continue k ()
    | effect CreateFreshDef (var, vert), k ->
        (* Get a fresh name (if not skipping). *)
        let var' =
          if not @@ Skip.skip skipping var then
            Procedure.fresh_var ~pure:true ~name:(Var.name var) procedure
              (Var.typ var)
          else var
        in

        (* Add definition to defs. *)
        defs := VarMap.add var' vert !defs;
        continue k var'

  let ssa_proc ?(skipping = Skip.empty) (procedure : Program.proc) =
    let procedure =
      map_blocks_nondet (fun (_, b) -> { b with phis = [] }) procedure
    in

    (* let reaching_defs = Analysis.Reaching_defs.IntraAnalysis.analyse procedure in *)
    (* Procedure.iter_blocks *)

    (* Update the procedure. *)
    procedure
    |> map_graph (fun g ->
        (* Dominator frontier per block: *)
        let idom = Dom.compute_idom g Entry in
        let doms = Dom.idom_to_dom idom in
        let tree = Dom.idom_to_dom_tree g idom in
        let dom_frontier = Dom.compute_dom_frontier g tree idom in

        (* Map each variable to it's definition. *)
        let defs = defs ~skipping procedure in

        (* Insert phis nodes. *)
        let g = VarMap.to_iter defs |> Iter.fold (add_phis dom_frontier) g in

        (* Rename variables. *)
        rename_procedure ~skipping procedure g tree doms)
end

let ssa_prog ?(skipping = Skip.empty) (program : Program.t) =
  Program.map_procedures (const @@ Construction.ssa_proc ~skipping) program
