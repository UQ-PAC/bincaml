(** Simple SSA construction as per SSA-based compiler design:
    https://link.springer.com/book/10.1007/978-3-030-80515-9 *)

open Lang.Common
open Lang
open Containers

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

let rename ?(skipping = Skip.empty) proc v =
  if not @@ Skip.skip skipping v then
    Procedure.fresh_var ~pure:true ~name:(Var.name v) proc (Var.typ v)
  else v

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

let check_ssa ?(skipping = Skip.empty) proc =
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
  assert (VarMap.for_all (fun v i -> Skip.skip skipping v || i = 1) assigns)

module Destruction = struct
  open Procedure

  (** Simple destruction pass, replaces phi nodes with semantically equivalent
      assigns. e.g. the phi node x_3 := phi(A->x_1, B->x_2) would be removed,
      and statements var x_3 := x_1 would be added to A, and x_3 := x_2 to B. *)
  let simple_destruction (procedure : Program.proc) =
    if Procedure.graph procedure |> Option.is_none then procedure
    else
      let procedure =
        fold_blocks_topo_fwd
          (fun acc id b ->
            b.phis |> List.to_iter
            |> Iter.flat_map_l (fun ({ lhs; rhs } : Var.t Block.phi) ->
                rhs
                |> List.map (fun (src, src_var) ->
                    let stmt =
                      Stmt.Instr_Assign
                        {
                          attrib = StringMap.empty;
                          al = [ (lhs, Expr.BasilExpr.rvar src_var) ];
                        }
                    in
                    (src, stmt)))
            |> Iter.fold
                 (fun acc (id, stmt) ->
                   Procedure.modify_block acc id (fun b ->
                       Block.append_stmts b [ stmt ]))
                 acc)
          procedure procedure
      in
      (* Clear old phis afterwards. *)
      map_blocks_nondet (fun (_, b) -> { b with phis = [] }) procedure
end

module Construction = struct
  open Procedure
  module Dom = Graph.Dominator.Make (G)
  module WL = Worklist.Make (ID)
  module FL = Set.Make (Procedure.Vert)
  open Effect
  open Effect.Deep

  type _ Effect.t += AllowRename : Vert.t -> bool t
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
  let add_phis (initialised : Vert.t -> Var.t -> bool)
      (dom_frontier : Vert.t -> Vert.t list) (graph : RevG.t)
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
      (* Skip if this may read uninit. *)
      |> Iter.filter (flip initialised var)
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

  (** Unify all returning blocks so that phi nodes may be generated. *)
  let unify_returns procedure =
    let procedure, rid =
      Procedure.fresh_block ~name:"%Return" procedure
        ~stmts:
          [
            Stmt.Instr_Assign
              {
                al =
                  Procedure.formal_out_params procedure
                  |> StringMap.values
                  |> Iter.map (fun v -> (v, Expr.BasilExpr.rvar v))
                  |> Iter.to_list;
                attrib = StringMap.empty;
              };
          ]
        ()
    in
    let procedure =
      procedure
      |> map_graph (fun g ->
          (* Connect the pre-return block. *)
          let returns = G.pred g Return in
          let g = G.add_edge g (End rid) Return in

          List.fold_left
            (fun acc v ->
              let acc = G.remove_edge acc v Return in
              G.add_edge acc v (Begin rid))
            g returns)
    in
    (procedure, rid)

  (** Helper to modify a block at id *)
  let modify_block g id f =
    let _, e, _ = G.find_edge g (Begin id) (End id) in
    let block = match e with Block block -> block | Jump -> raise Not_found in
    let block = f block in
    let g = G.remove_edge g (Begin id) (End id) in
    let g = G.add_edge_e g (Begin id, Edge.Block block, End id) in
    g

  (** Map vertices in preorder dfs traversal of dominator tree. *)
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

  let rename_lvar is_phi vert lvar =
    if is_phi || (perform @@ AllowRename vert) then (
      let rdef = perform @@ GetReachingDef (lvar, vert) in
      (* Create a renamed lvar *)
      let lvar' = perform @@ CreateFreshDef (lvar, vert) in
      (* Point it to the rdef of original *)
      perform @@ SetReachingDef (lvar', rdef);
      (* Redirect original to this *)
      perform @@ SetReachingDef (lvar, lvar');
      lvar')
    else lvar

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
               { phi with lhs = rename_lvar true vert phi.lhs }))
        Fun.id block
    in
    (* Update a statement. Two passes, first update rvars then lvars. *)
    Block.map ~phi:Fun.id
      (Stmt.map ~f_expr:(rename_expr vert) ~f_rvar:(rename_rvar vert)
         ~f_lvar:Fun.id
      %> Stmt.map ~f_expr:Fun.id ~f_rvar:Fun.id ~f_lvar:(rename_lvar false vert)
      )
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

  (** Update the reaching def of var by climbing up the reaching def tree until
      a definition which dominates vert is found. Requires traversal in preorder
      dfs of dominator tree (and topological) so that the reaching def for a
      variable will only ever need to move up to parents or stay fixed. *)
  let rec update_reaching_def ?r doms defs reaching_defs (var : Var.t)
      (vert : Vert.t) =
    let r = Option.or_ r ~else_:(VarMap.get var reaching_defs) in
    let r' = Option.flat_map (flip VarMap.get reaching_defs) r in

    if
      r
      (* Is the definition site of r dominated by vert? *)
      |> Option.flat_map (flip VarMap.get defs %> Option.map (flip doms vert))
      (* Negate that *)
      |> Option.get_or ~default:true %> not
      (* Also require that r has changed to avoid infinite loops. *)
      && (not @@ Option.equal Var.equal r r')
    then update_reaching_def ?r:r' doms defs reaching_defs var vert
    else VarMap.update var (fun _ -> r) reaching_defs

  (** Rename all variables in a procedure to be in SSA form. *)
  let rename_procedure ?(skipping = Skip.empty) rid (procedure : Program.proc)
      (g : RevG.t) tree doms =
    (* Workaround not having stmt level cfg. Given a block
       is linear/has no control flow, it is enough if a and b
       belong to the same block. *)
    let doms a b = doms a b || Vert.equal a b in

    let reaching_defs : Var.t VarMap.t ref = ref VarMap.empty in
    let defs = ref VarMap.empty in

    (* Traverse the procedure renaming variables.
       Handle reaching defs and renaming via effects for caching. *)
    try fst @@ traversal rename_block rename_succ tree (g, FL.empty) Entry with
    | effect GetReachingDef (var, vert), k ->
        (* Get the reaching def of a variable from a vertex.
           Also updates the reaching def, cached for future use. *)
        if not @@ Skip.skip skipping var then
          reaching_defs :=
            update_reaching_def doms !defs !reaching_defs var vert;
        continue k (VarMap.get_or ~default:var var !reaching_defs)
    | effect SetReachingDef (var, new_var), k ->
        (* Set the reaching def of a var. *)
        if not @@ Skip.skip skipping var then
          reaching_defs := VarMap.add var new_var !reaching_defs;
        continue k ()
    | effect CreateFreshDef (var, vert), k ->
        (* Get a fresh name (if not skipping). *)
        let var' = rename ~skipping procedure var in

        (* Add definition to defs. *)
        defs := VarMap.add var' vert !defs;
        continue k var'
    | effect AllowRename vert, k ->
        continue k (not @@ Vert.equal vert (Begin rid))

  (** Transform a procedure into SSA form. *)
  let ssa_proc ?(skipping = Skip.empty) (procedure : Program.proc) =
    let procedure = intro_ssi_assigns procedure (Skip.keep skipping) in
    if Procedure.graph procedure |> Option.is_some then
      (* Destruct any previous phi nodes. Hacky but ideally
         reconstruction is used instead of repeated SSA anyway. *)
      let procedure = Destruction.simple_destruction procedure in

      (* Unify all return nodes into a single one. *)
      let procedure, rid = unify_returns procedure in

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

          (* MayReadUninit analysis *)
          let initialised =
            let analysis = May_read_uninit.A.analyse procedure in
            fun vert var ->
              May_read_uninit.A.A.M.find vert analysis
              |> May_read_uninit.ReadUninitAnalysis.read_var var
              |> function
              | Val (_, May_read_uninit.ReadUninit.Happy) -> true
              | _ -> false
          in

          (* Insert phis nodes. *)
          let g =
            VarMap.to_iter defs
            |> Iter.fold (add_phis initialised dom_frontier) g
          in

          (* Rename variables. Skip renaming special return block. *)
          rename_procedure ~skipping rid procedure g tree doms)
      (* |> tap (check_ssa ~skipping) *)
    else procedure
end

module Reconstruction = struct
  (** SSA Reconstruction. Alternative to fully re-running construction when a
      transform has *partially* invalidated the SSA single definition property.

      How reconstruction works? For a variable violating SSA (multiple assigns),
      we replace each definition with a fresh variable.

      Then, for each use of the same variable we climb up the immediate
      dominators statement by statement until we find a definition, and replace
      the use with that definition. Only loooking at idoms ensures it is
      reachable on all paths.

      If a block is seen during this traversal which is in the iterated
      dominance frontier, then we insert a fresh definition as a phi node and
      use that. This ensures we will never have multiple reaching defs.

      Introducing a phi node in this way does create new uses of the variable in
      the rhs of the phi node, which are immediately updated in the same way as
      any other use of the variable we are updating. *)

  open Procedure
  module Dom = Graph.Dominator.Make (G)
  module WL = Worklist.Make (ID)
  module FL = Set.Make (Procedure.Vert)

  type usedef = Def of Var.t | Use of int * Var.t

  (** Compute the iterated dominance frontier (transitive closure). *)
  let iterated_df (df : Vert.t -> Vert.t list) (iter : Vert.t Iter.t)
      (f : Vert.t -> unit) : unit =
    let seen = Hashtbl.create 0 in
    let rec iterated_df' (x : Vert.t) : unit =
      if Hashtbl.mem seen x then ()
      else (
        f x;
        Hashtbl.replace seen x ();
        (df x |> Iter.of_list) iterated_df')
    in
    iter iterated_df'

  (** Find the first reaching definition of var from the top of a block. Insert
      phi nodes along the way at dominance frontier blocks. *)
  let rec find_def_from_top (procedure : Program.proc)
      (definitions : VarSet.t ref) (dfplus : IDSet.t) (idom : Vert.t -> Vert.t)
      (var : Var.t) (bid : ID.t) =
    if
      Procedure.blocks_pred procedure bid |> Iter.is_empty
      || (not @@ IDSet.mem bid dfplus)
    then
      (* If not a member of iterated dominance frontier, proceed from bottom
         of immediate dominator. *)
      match idom @@ Vert.Begin bid with
      | Vert.Entry ->
          (* Needs to be a formal in param. *)
          (procedure, var)
      | Begin pred | End pred ->
          find_def_from_bottom procedure definitions dfplus idom var pred
      | _ -> failwith "idom should be Begin/End vertex."
    else
      (* In iterated dominance frontier. Thus a phi node needs insertion. *)
      let lhs = rename procedure var in
      (* This is fresh, be sure to add it to the definitions variables. *)
      definitions := VarSet.add lhs !definitions;

      (* Find def from bottom of each immediate parent. *)
      let procedure, rhs =
        Procedure.blocks_pred procedure bid
        |> Iter.fold
             (fun (procedure, rhs) (par_id, _) ->
               let procedure', def =
                 find_def_from_bottom procedure definitions dfplus idom var
                   par_id
               in
               (procedure', (par_id, def) :: rhs))
             (procedure, [])
      in

      let def : Var.t Block.phi = { lhs; rhs } in

      (* Add phi node to procedure, removing any old one: *)
      let procedure =
        if List.length rhs > 0 then
          Procedure.modify_block procedure bid (fun block ->
              let phis =
                List.filter
                  (fun (p : Var.t Block.phi) -> not @@ Var.equal p.lhs var)
                  block.phis
              in
              { block with phis = def :: phis })
        else procedure
      in

      (* Now simply use the lvar of the new phi node as our reaching def. *)
      (procedure, lhs)

  (** Find the first reaching definition of var from the top of a block. *)
  and find_def_from_bottom (procedure : Program.proc)
      (definitions : VarSet.t ref) (dfplus : IDSet.t) (idom : Vert.t -> Vert.t)
      (var : Var.t) (bid : ID.t) =
    (* Get the last definition (or phi) in the block, if it exists. *)
    let def =
      Procedure.get_block procedure bid
      |> Option.flat_map (fun b ->
          let open Option in
          let first_stmt =
            b |> Block.stmts_iter |> Iter.rev |> Iter.map Stmt.iter_lvar
            |> Iter.find_map (Iter.find_pred (flip VarSet.mem !definitions))
          in
          let first_phi =
            b.phis |> List.to_iter
            |> Iter.map (fun (phi : Var.t Block.phi) -> phi.lhs)
            |> Iter.find_pred (flip VarSet.mem !definitions)
          in
          first_stmt <+> first_phi)
    in
    match def with
    | Some v -> (procedure, v)
    | None -> find_def_from_top procedure definitions dfplus idom var bid

  (** Repair SSA for a variable, var, which breaks SSA. Requires defs is ordered
      from last to first. *)
  let make_fresh procedure definitions var =
    procedure
    |> Procedure.map_blocks_nondet (fun (bid, block) ->
        Block.map
          ~phi:
            (List.map (fun ({ lhs; rhs } : Var.t Block.phi) ->
                 let lhs =
                   if Var.equal lhs var then (
                     let rn = rename procedure lhs in
                     definitions := VarSet.add rn !definitions;
                     rn)
                   else lhs
                 in
                 ({ lhs; rhs } : Var.t Block.phi)))
          (Stmt.map
             ~f_lvar:(fun lhs ->
               if Var.equal lhs var then (
                 let rn = rename procedure lhs in
                 definitions := VarSet.add rn !definitions;
                 rn)
               else lhs)
             ~f_rvar:Fun.id ~f_expr:Fun.id)
          block)

  (** Reconstruction for var appearing in rhs of phi nodes. *)
  let reconstruct_phis definitions dfplus idom var (block : Program.bloc)
      program bid =
    let program, phis =
      List.fold_left
        (fun (acc, phis) (phi : Var.t Block.phi) ->
          let acc, rhs =
            phi.rhs |> List.to_iter
            |> Iter.fold
                 (fun (acc, rhs) (source, rv) ->
                   if Var.equal var rv then
                     let acc, def =
                       find_def_from_bottom acc definitions dfplus idom var
                         source
                     in
                     (acc, (source, def) :: rhs)
                   else (acc, (source, rv) :: rhs))
                 (acc, [])
          in
          (acc, ({ lhs = phi.lhs; rhs } : Var.t Block.phi) :: phis))
        (program, []) block.phis
    in
    Procedure.modify_block program bid (fun block -> { block with phis })

  (** Reconstruction of stmts top to bottom. *)
  let reconstruct_stmts definitions dfplus idom var (block : Program.bloc)
      program bid =
    let use_defs =
      Block.stmts_iter_i block
      |> Iter.flat_map_l (fun (i, stmt) ->
          let use =
            if Stmt.free_vars_iter stmt |> Iter.exists (Var.equal var) then
              [ Use (i, var) ]
            else []
          in
          let def =
            Stmt.iter_lvar stmt
            |> Iter.find_pred (flip VarSet.mem !definitions)
            |> Option.map (fun var ->
                Def var)
            |> Option.to_list
          in
          use @ def)
    in

    (* Fold forwards over uses and defs, tracking the last definition for substitution. *)
    let stmts = Vector.copy block.stmts in
    let program, _ =
      use_defs
      |> Iter.fold
           (fun (acc, def) usedef ->
             match usedef with
             | Use (idx, use) ->
                 (* Variable is used. Get the reaching def (maybe look up). *)
                 let acc, def =
                   def
                   |> Option.map (fun def -> (acc, def))
                   |> Option.get_lazy (fun _ ->
                       find_def_from_top acc definitions dfplus idom var bid)
                 in
                 (* Update stmt at idx with def. *)
                 let stmt =
                   Vector.get stmts idx
                   |> Stmt.map ~f_lvar:Fun.id
                        ~f_expr:
                          (Expr.BasilExpr.substitute (fun v ->
                               if Var.equal v var then
                                 Some (Expr.BasilExpr.rvar def)
                               else None))
                        ~f_rvar:(fun v -> if Var.equal v var then def else v)
                 in
                 Vector.set stmts idx stmt;
                 (acc, Some def)
             | Def def ->
                 (* New definition replaces old def. *)
                 (acc, Some def))
           (program, None)
    in
    Procedure.modify_block program bid (fun block ->
        { block with stmts = Vector.freeze stmts })

  (** Reconstruct block bid for variable var, updating program. *)
  let reconstruct_block definitions dfplus idom var program bid =
    let block : Program.bloc =
      Procedure.get_block program bid |> Option.get_exn_or "Missing block."
    in

    (* Top to bottom, so phis go first. *)
    let program =
      reconstruct_phis definitions dfplus idom var block program bid
    in

    (* Then stmts... *)
    reconstruct_stmts definitions dfplus idom var block program bid

  let driver (var : Var.t) (procedure : Program.proc) (initial_defs : IDSet.t) =
    let definitions = ref VarSet.empty in

    (* Map each lvar to a fresh var. *)
    let procedure = make_fresh procedure definitions var in

    let g =
      Procedure.graph procedure
      |> Option.get_exn_or "Expected procedure to have graph."
    in
    let idom = Dom.compute_idom g Entry in
    let tree = Dom.idom_to_dom_tree g idom in
    let df = Dom.compute_dom_frontier g tree idom in

    (* Compute the iterated dominance frontier as a set of IDs, not verts. *)
    let dfplus =
      initial_defs |> IDSet.to_iter
      |> Iter.map (fun id -> Vert.Begin id)
      |> iterated_df df
      |> Iter.filter_map (function
        | Vert.Begin id | Vert.End id -> Some id
        | _ -> None)
      |> IDSet.of_iter
    in

    Procedure.iter_blocks procedure
    |> Iter.map fst
    |> Iter.fold (reconstruct_block definitions dfplus idom var) procedure

  (** Find SSA-violating variables in a procedure. (anything assigned more than
      once) *)
  let find_invalid ?(skipping = Skip.empty) (procedure : Program.proc) =
    let defs = ref VarMap.empty in
    let seen = ref VarSet.empty in
    let invalid = ref VarSet.empty in
    Procedure.iter_blocks procedure
    |> Iter.flat_map (fun (id, b) ->
        b |> Block.stmts_iter
        |> Iter.flat_map Stmt.iter_assigned
        |> Iter.map (fun var -> (id, var)))
    |> flip Iter.for_each (fun (bid, var) ->
        if VarSet.mem var !seen then invalid := VarSet.add var !invalid;
        seen := VarSet.add var !seen;
        defs :=
          VarMap.update var
            (Option.map_or (IDSet.add bid) ~default:(IDSet.singleton bid)
            %> Option.some)
            !defs);
    VarMap.filter (flip VarSet.mem !invalid %> const) !defs

  (** Reconstruct SSA for a procedure. *)
  let reconstruct_proc ?(skipping = Skip.empty) (procedure : Program.proc) =
    let defs = find_invalid ~skipping procedure in
    VarMap.fold (fun var bids acc -> driver var acc bids) defs procedure
    |> tap check_ssa
end

(** Transform a program into SSA form. *)
let ssa_prog ?(skipping = Skip.empty) (program : Program.t) =
  Program.map_procedures (const @@ Construction.ssa_proc ~skipping) program
