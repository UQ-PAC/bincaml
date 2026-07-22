open Common
open Abstract_expr

(** Hindley-Milner type inference based on a union-find. *)

module TypeInference (T : TypeExpr.TypeContext) = struct
  open Hm_types.Make (T)
  open Unification.Make (T)
  open Inference.Make (T)
  open Solve_bv.Make (T)
  open T
  open T.Typ

  let retype_var univ ctx id =
    lookup_var_typ ~no_constraint:true univ ctx id |> find |> to_basil
    |> fun typ -> Var.copy ~typ id

  let elaborate_phi univ ctx (p : Var.t Block.phi list) =
    let open Block in
    List.map
      (fun { lhs; rhs } ->
        let lhs = retype_var univ ctx lhs in
        let rhs = List.map (fun (a, r) -> (a, retype_var univ ctx r)) rhs in
        { lhs; rhs })
      p

  let ctx_to_string ctx =
    TypeExpr.TCtx.to_iter ctx
    |> Iter.to_string (fun (a, b) ->
        Printf.sprintf "%s %s" (TypeExpr.V.to_string a) (scheme_to_string b))

  let fresh_tvar ?(n = "a") () = fix @@ Var (gen.fresh ~name:n ())
  let unfix i = match i with Expr.BasilExpr.E i -> i
  let rec cata alg e = (unfix %> AbstractExpr.map (cata alg) %> alg) e

  (** Extract type after full inference has run. *)
  let elaborate_expr ~univ (hr : Lexing.position) e (c : scheme TypeExpr.TCtx.t)
      =
    let alg e =
      let e =
        match e with
        | AbstractExpr.RVar { id; attrib; typ } ->
            (* avoid looking up the id in context as we may be in a local
            binding *)
            let id = Var.copy id ~typ:(to_basil @@ find typ) in
            AbstractExpr.RVar { id; attrib; typ }
        | o -> o
      in
      let t = AbstractExpr.get_typ e |> find |> to_basil in
      AbstractExpr.set_typ e t |> Expr.BasilExpr.fix
    in
    e |> TypingExpr.cata alg

  let elaborate_stmt univ ctx stmt =
    let retype_var v =
      let typ =
        lookup_var_typ ~no_constraint:true univ ctx v |> find |> to_basil
      in
      Var.copy ~typ v
    in
    Stmt.map
      ~f_expr:(fun e -> elaborate_expr ~univ [%here] e ctx)
      ~f_lvar:retype_var ~f_rvar:retype_var stmt

  let elaborate_block p univ ctx (b : ('a, 'b) Block.t) =
    Block.map ~phi:(elaborate_phi univ ctx) (elaborate_stmt univ ctx) b

  let assume_proc_decl ctx ?(no_constraint = false) (p : Program.proc) =
    let globs = Var.Decls.values (Procedure.local_decls p) in
    let formals_in = Procedure.formal_in_params p |> StringMap.values in
    let formals_out = Procedure.formal_out_params p |> StringMap.values in
    let univ = TypeExpr.V.proc_univ @@ Procedure.id p in
    let ctx =
      Iter.fold
        (decl_var_typ ~no_constraint univ)
        ctx
        (Iter.append globs @@ Iter.append formals_in formals_out)
    in
    ctx

  let infer_proc vc prog ctx ?(no_constraint = false) (p : Program.proc) =
    let spec = Procedure.specification p in
    let univ = TypeExpr.V.proc_univ @@ Procedure.id p in
    let ibool_list b =
      List.map
        (fun a ->
          let a = infer_expr vc ~univ [%here] a ctx in
          let _ = unify (fix bool_type) (getty a) in
          a)
        b
    in
    let spec : ('a, 'b) Procedure.proc_spec =
      {
        requires = ibool_list spec.requires;
        ensures = ibool_list spec.ensures;
        rely = ibool_list spec.rely;
        guarantee = ibool_list spec.guarantee;
        captures_globs =
          List.map (infer_var global_universe ctx) spec.captures_globs;
        modifies_globs =
          List.map (infer_var global_universe ctx) spec.modifies_globs;
      }
    in

    let new_spec ctx : (Var.t, Expr.BasilExpr.t) Procedure.proc_spec =
      {
        requires =
          List.map (fun e -> elaborate_expr ~univ [%here] e ctx) spec.requires;
        ensures =
          List.map (fun e -> elaborate_expr ~univ [%here] e ctx) spec.ensures;
        rely = List.map (fun e -> elaborate_expr ~univ [%here] e ctx) spec.rely;
        guarantee =
          List.map (fun e -> elaborate_expr ~univ [%here] e ctx) spec.guarantee;
        captures_globs = spec.captures_globs |> List.map fst;
        modifies_globs = spec.modifies_globs |> List.map fst;
      }
    in

    let ctx = assume_proc_decl ctx ~no_constraint p in
    let bvlocks =
      Procedure.iter_blocks_topo_fwd p
      |> Iter.map (fun (i, b) -> (i, infer_block vc prog univ ctx b))
      |> Iter.persistent
    in

    let elaborate_proc ctx =
      Procedure.set_specification p (new_spec ctx)
      |> (fun p ->
      bvlocks
      |> Iter.map (fun (bid, b) -> (bid, elaborate_block [%here] univ ctx b))
      |> Iter.fold (fun p (bid, b) -> Procedure.update_block p bid b) p)
      |> Procedure.map_formal_in_params (StringMap.map (retype_var univ ctx))
      |> Procedure.map_formal_out_params (StringMap.map (retype_var univ ctx))
    in
    Logs.debug (fun m -> m "%s" (ctx_to_string ctx));
    (elaborate_proc, ctx)

  (** Run type inference on a declaration, returning an updated typing scheme,
      and elaboration function*)
  let infer_decl visit_constraint prog scheme =
    let open Program in
    let infer_expr = infer_expr visit_constraint in
    let infer_proc = infer_proc visit_constraint in
    (* We have to be careful that inference is run immediately, not delayed until elaboration. *)
    fun (decl_id, d) ->
      match d with
      | Type { binding; typ } ->
          let ty = ty_of_basil typ in
          let scheme = decl_type scheme binding ty in
          let nty scheme = Type { binding; typ = to_basil (find ty) } in
          (scheme, `Decl (decl_id, nty))
      | Function { binding; definition; attrib } -> (
          (* elaboration of var binding *)
          let scheme = decl_var_typ global_universe scheme binding in
          let binding s = retype_var global_universe s binding in
          match definition with
          | Axiom b ->
              let bt = fix bool_type in
              let b = infer_expr ~univ:global_universe [%here] b scheme in
              let _ = unify (getty b) bt in
              let new_axiom scheme =
                Function
                  {
                    attrib;
                    binding = binding scheme;
                    definition =
                      Axiom
                        (elaborate_expr ~univ:global_universe [%here] b scheme);
                  }
              in
              (scheme, `Decl (decl_id, new_axiom))
          | Uninterpreted ->
              let new_uf s =
                Function
                  { binding = binding s; attrib; definition = Uninterpreted }
              in
              (scheme, `Decl (decl_id, new_uf))
          | Function definition ->
              let e =
                infer_expr ~univ:global_universe [%here] definition scheme
              in
              let new_fundef scheme =
                Function
                  {
                    binding = binding scheme;
                    attrib;
                    definition =
                      Function
                        (elaborate_expr ~univ:global_universe [%here] e scheme);
                  }
              in
              (scheme, `Decl (decl_id, new_fundef)))
      | Variable { binding; attrib; classification } ->
          let scheme = decl_var_typ global_universe scheme binding in
          let binding s = retype_var global_universe s binding in
          let classification =
            let tyv =
              classification
              |> Option.map (fun classi ->
                  infer_expr ~univ:global_universe [%here] classi scheme)
            in
            fun final_scheme ->
              tyv
              |> Option.map (fun e ->
                  elaborate_expr ~univ:global_universe [%here] e final_scheme)
          in
          let new_vardef fscheme =
            Variable
              {
                binding = binding fscheme;
                attrib;
                classification = classification fscheme;
              }
          in
          (scheme, `Decl (decl_id, new_vardef))
      | Procedure { definition } ->
          let elaborate_proc, scheme = infer_proc prog scheme definition in
          (scheme, `Procedure (decl_id, elaborate_proc))

  (** The function that does everything *)
  let infer_program prog =
    let decls = Program.declarations prog |> Iter.to_list in
    let constraints = ref [] in
    let visit_constraint c = constraints := c :: !constraints in
    (* We fold the inference context through every declaration and
    calling the inference functions, returning an expressions typed with the
    type expressions herein.  We also return the resulting list of elaboration
    functions, which take the final inference context and convert the HM-typed
    expressions back to bincaml typed expressions. *)
    let scheme, new_decls =
      decls
      |> List.fold_map (infer_decl visit_constraint prog) TypeExpr.TCtx.empty
    in
    let _ = solve_constraints ~max_iters:50 !constraints in
    (* TODO: implicit decls; constructors need to be added after the types they
    construct, probably simples to do implicits immediately after the thing they
    relate to. Maybe they should just appear this way in the declaration
    list. *)
    let prog =
      List.fold_left
        (fun prog -> function
          | `Decl (id, ndecl) ->
              let decl = ndecl scheme in
              (* assuming the id is the same (it has to be) *)
              Program.update_decl prog decl
          | `Procedure (id, nproc) ->
              let proc = nproc scheme in
              (* assuming the id is the same (it has to be) *)
              let prog = Program.update_proc id (fun _ -> Some proc) prog in
              prog)
        prog new_decls
    in
    (scheme, prog)
end
