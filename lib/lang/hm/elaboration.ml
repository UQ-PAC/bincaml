open Common
open Abstract_expr

(** Hindley-Milner type inference based on a union-find. *)

open Hm_inference
open Hm_types
open Unification
open Inference
open Solve_bv

let retype_var st univ ctx id =
  lookup_var_typ st ~no_constraint:true univ ctx id
  |> TypeExpr.find st |> to_basil
  |> fun typ -> Var.copy ~typ id

let elaborate_phi st univ ctx (p : Var.t Block.phi list) =
  let open Block in
  List.map
    (fun { lhs; rhs } ->
      let lhs = retype_var st univ ctx lhs in
      let rhs = List.map (fun (a, r) -> (a, retype_var st univ ctx r)) rhs in
      { lhs; rhs })
    p

let ctx_to_string ctx =
  TypeExpr.TCtx.to_iter ctx
  |> Iter.to_string (fun (a, b) ->
      Printf.sprintf "%s %s" (TypeExpr.V.to_string a) (scheme_to_string b))

let unfix i = match i with Expr.BasilExpr.E i -> i
let rec cata alg e = (unfix %> AbstractExpr.map (cata alg) %> alg) e

(** Extract type after full inference has run. *)
let elaborate_expr st ~univ (hr : Lexing.position) e
    (c : scheme TypeExpr.TCtx.t) =
  let alg e =
    let e =
      match e with
      | AbstractExpr.RVar { id; attrib; typ } ->
          (* avoid looking up the id in context as we may be in a local
            binding *)
          let id = Var.copy id ~typ:(to_basil @@ TypeExpr.find st typ) in
          AbstractExpr.RVar { id; attrib; typ }
      | o -> o
    in
    let t = AbstractExpr.get_typ e |> TypeExpr.find st |> to_basil in
    AbstractExpr.set_typ e t |> Expr.BasilExpr.fix
  in
  e |> AbsTypingExpr.cata alg

let elaborate_stmt st univ ctx stmt =
  let retype_var = retype_var st univ ctx in
  Stmt.map
    ~f_expr:(fun e -> elaborate_expr st ~univ [%here] e ctx)
    ~f_lvar:retype_var ~f_rvar:retype_var stmt

let elaborate_block st p univ ctx (b : ('a, 'b) Block.t) =
  Block.map ~phi:(elaborate_phi st univ ctx) (elaborate_stmt st univ ctx) b

let assume_proc_decl st ctx ?(no_constraint = false) (p : Program.proc) =
  let globs = Var.Decls.values (Procedure.local_decls p) in
  let formals_in = Procedure.formal_in_params p |> StringMap.values in
  let formals_out = Procedure.formal_out_params p |> StringMap.values in
  let univ = TypeExpr.V.proc_univ @@ Procedure.id p in
  let ctx =
    Iter.fold
      (decl_var_typ st ~no_constraint univ)
      ctx
      (Iter.append globs @@ Iter.append formals_in formals_out)
  in
  ctx

let infer_proc st vc prog ctx ?(no_constraint = false) (p : Program.proc) =
  let spec = Procedure.specification p in
  let univ = TypeExpr.V.proc_univ @@ Procedure.id p in
  let ibool_list b =
    List.map
      (fun a ->
        let a = infer_expr st vc ~univ [%here] a ctx in
        let _ = unify st (bool_type st) (getty a) in
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
        List.map (infer_var st global_universe ctx) spec.captures_globs;
      modifies_globs =
        List.map (infer_var st global_universe ctx) spec.modifies_globs;
    }
  in

  let new_spec ctx : (Var.t, Expr.BasilExpr.t) Procedure.proc_spec =
    {
      requires =
        List.map (fun e -> elaborate_expr st ~univ [%here] e ctx) spec.requires;
      ensures =
        List.map (fun e -> elaborate_expr st ~univ [%here] e ctx) spec.ensures;
      rely = List.map (fun e -> elaborate_expr st ~univ [%here] e ctx) spec.rely;
      guarantee =
        List.map (fun e -> elaborate_expr st ~univ [%here] e ctx) spec.guarantee;
      captures_globs = spec.captures_globs |> List.map fst;
      modifies_globs = spec.modifies_globs |> List.map fst;
    }
  in

  let ctx = assume_proc_decl st ctx ~no_constraint p in
  let bvlocks =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.map (fun (i, b) -> (i, infer_block st vc prog univ ctx b))
    |> Iter.persistent
  in

  let elaborate_proc ctx =
    Procedure.set_specification p (new_spec ctx)
    |> (fun p ->
    bvlocks
    |> Iter.map (fun (bid, b) -> (bid, elaborate_block st [%here] univ ctx b))
    |> Iter.fold (fun p (bid, b) -> Procedure.update_block p bid b) p)
    |> Procedure.map_formal_in_params (StringMap.map (retype_var st univ ctx))
    |> Procedure.map_formal_out_params (StringMap.map (retype_var st univ ctx))
  in
  Logs.debug (fun m -> m "%s" (ctx_to_string ctx));
  (elaborate_proc, ctx)

(** Run type inference on a declaration, returning an updated typing scheme, and
    elaboration function*)
let infer_decl st visit_constraint prog scheme =
  let open Program in
  let infer_expr = infer_expr st visit_constraint in
  let infer_proc = infer_proc st visit_constraint in

  let scheme =
    Program.declarations prog
    |> Iter.fold
         (fun scheme (_, d) ->
           match d with
           | Type { binding; typ } ->
               let ty = ty_of_basil st typ in
               let scheme = decl_type st scheme binding ty in
               scheme
           | Variable { binding } ->
               let scheme = decl_var_typ st global_universe scheme binding in
               scheme
           | Implicit (VariantCase { constructor; variant; belongs_to }) ->
               let scheme =
                 decl_var_typ st global_universe scheme constructor
               in
               scheme
           | Function { binding; definition; attrib } ->
               let scheme = decl_var_typ st global_universe scheme binding in
               scheme
           | Procedure { definition } ->
               let univ = TypeExpr.V.proc_univ (Procedure.id definition) in
               let inp =
                 Procedure.formal_in_params definition |> StringMap.values
               in
               let outp =
                 Procedure.formal_out_params definition |> StringMap.values
               in
               Iter.append inp outp
               |> Iter.fold
                    (fun scheme v -> decl_var_typ st univ scheme v)
                    scheme
)
         scheme
  in

  (* We have to be careful that inference is run immediately, not delayed until elaboration. *)
  fun (decl_id, d) ->
    match d with
    | Type { binding; typ } ->
        let ty = ty_of_basil st typ in
        let nty scheme =
          Type { binding; typ = to_basil (TypeExpr.find st ty) }
        in
        (scheme, `Decl (decl_id, nty))
    | Implicit (VariantCase { constructor; variant; belongs_to }) ->
        let scheme = decl_var_typ st global_universe scheme constructor in
        let binding s = retype_var st global_universe s constructor in
        let ret_type () =
          (* I'd hope this doesn't change... should equal return type of binding *)
          ty_of_basil st belongs_to |> TypeExpr.find st |> to_basil
        in
        let new_def fscheme =
          Implicit
            (VariantCase
               {
                 constructor = binding fscheme;
                 belongs_to = ret_type ();
                 variant;
               })
        in
        (scheme, `Decl (decl_id, new_def))
    | Function { binding; definition; attrib } -> (
        (* elaboration of var binding *)
        let binding s = retype_var st global_universe s binding in
        match definition with
        | Axiom b ->
            let b = infer_expr ~univ:global_universe [%here] b scheme in
            let _ = unify st (getty b) (bool_type st) in
            let new_axiom scheme =
              Function
                {
                  attrib;
                  binding = binding scheme;
                  definition =
                    Axiom
                      (elaborate_expr st ~univ:global_universe [%here] b scheme);
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
                      (elaborate_expr st ~univ:global_universe [%here] e scheme);
                }
            in
            (scheme, `Decl (decl_id, new_fundef)))
    | Variable { binding; attrib; classification } ->
        let scheme = decl_var_typ st global_universe scheme binding in
        let binding s = retype_var st global_universe s binding in
        let classification =
          let tyv =
            classification
            |> Option.map (fun classi ->
                infer_expr ~univ:global_universe [%here] classi scheme)
          in
          fun final_scheme ->
            tyv
            |> Option.map (fun e ->
                elaborate_expr st ~univ:global_universe [%here] e final_scheme)
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
let infer_program st prog =
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
    |> List.fold_map (infer_decl st visit_constraint prog) TypeExpr.TCtx.empty
  in
  let _ = solve_constraints st ~max_iters:50 !constraints in
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
