(** Unification of type expressions *)

open Common
open Abstract_expr

let type_error st a b =
  let a, b = TypeExpr.(find st a, find st b) in
  raise
    (Hm_types.TypeErr
       ("type_error: " ^ Hm_types.type_to_string a ^ " <> "
      ^ Hm_types.type_to_string b))

let recursion_error st a b =
  let b = TypeExpr.find st b in
  raise
    (Hm_types.TypeErr
       ("recursive: tvar " ^ ID.to_string a ^ " occurs in "
      ^ Hm_types.type_to_string b))

(** Check for type recursion: recursion is failure. *)
let occurs_in a b =
  let check = function
    | TypeExpr.ATyp.Var t -> TypeExpr.equal_tvar t a
    | TypeConstr (ls, _) -> List.exists Fun.id ls
  in
  TypeExpr.cata check b

(** Type unification.*)
let rec unify st ?(pos = Lexing.dummy_pos) t t' =
  let fix, find = (TypeExpr.fix st, TypeExpr.find st) in

  Logs.debug (fun m ->
      m "%s"
        ("unify: " ^ Hm_types.plpos pos ^ " "
        ^ Hm_types.type_to_string (find t)
        ^ " with "
        ^ Hm_types.type_to_string (find t')));
  match TypeExpr.(map_expr unfix @@ unfix t, map_expr unfix @@ unfix t') with
  | TypeConstr ([], "nothing"), _ -> t
  | _, TypeConstr ([], "nothing") -> t'
  | Var x, Var y -> TypeExpr.union st t t'
  | Var x, _ when occurs_in x t' -> recursion_error st x t'
  | Var _, TypeConstr _ -> TypeExpr.merge st (fun a b -> b) t t'
  | _, Var x -> unify st ~pos:[%here] t' t
  | TypeConstr (ars, n), TypeConstr (ars', n') when not (String.equal n n') ->
      type_error st t t'
  | TypeConstr (ars, n), TypeConstr (ars', n')
    when List.length ars <> List.length ars' ->
      type_error st t t'
  | ( TypeConstr ([ (Var v as vr) ], "bv"),
      TypeConstr ([ (TypeConstr ([], a) as cst) ], "bv") )
  | ( TypeConstr ([ (TypeConstr ([], a) as cst) ], "bv"),
      TypeConstr ([ (Var v as vr) ], "bv") ) ->
      (* prioritise bitvec consts *)
      let v = TypeExpr.merge st (fun _ c -> c) (fix vr) (fix cst) in
      fix @@ TypeConstr ([ v ], "bv")
  | TypeConstr (ars, n), TypeConstr (ars', n') ->
      let args =
        List.combine ars ars'
        |> List.map (fun (a, b) -> unify st ~pos:[%here] (fix a) (fix b))
      in
      TypeExpr.merge st (fun a b -> TypeConstr (args, n)) t t'

(** instantiate typescheme for a single type-annotated variable *)
let inst_annot_v st ?(no_constraint = false) v =
  let ty =
    match (no_constraint, Var.typ v) with
    | true, _ | _, Nothing ->
        TypeExpr.fix st @@ Var (st.gen.fresh ~name:(Var.name v) ())
    | _, o -> Hm_types.ty_of_basil st o
  in
  ty

(** lookup var and add unify with its type annotation *)
let lookup_var_typ st univ ?(no_constraint = false) c v =
  let vt = inst_annot_v st v in
  let a =
    let v = TypeExpr.V.of_var univ v in
    TypeExpr.TCtx.find_opt v c |> function
    | Some v -> v
    | None -> failwith ("var not found: " ^ TypeExpr.V.to_string v)
  in
  match a with Hm_types.Forall (_, ty) -> TypeExpr.union st ty vt

(** declare type with name in type scheme *)
let decl_type st ctx name vt =
  let tvar = TypeExpr.V.create Hm_types.types_universe name in
  TypeExpr.TCtx.update tvar
    (function
      | Some (Hm_types.Forall ([], t)) -> Some (Forall ([], unify st vt t))
      | None -> Some (Forall ([], vt))
      | _ -> failwith "unk")
    ctx

(** declare var with type in type scheme *)
let decl_var_typ st univ ?(no_constraint = false) c v =
  let vvar = TypeExpr.V.of_var univ v in
  let vt = inst_annot_v st v in
  TypeExpr.TCtx.update vvar
    (function
      | Some (Hm_types.Forall ([], t)) -> Some (Forall ([], unify st vt t))
      | None -> Some (Forall ([], vt))
      | _ -> failwith "unk")
    c
