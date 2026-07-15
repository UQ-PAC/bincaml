(** Unification of type expressions *)

open Common
open Abstract_expr

module Make (T : TypeExpr.TypeContext) = struct
  open TypeExpr
  include T
  include Typ
  open Hm_types
  include Hm_types.Make (T)

  let type_error a b =
    let a = find a in
    let b = find b in
    raise
      (TypeErr ("type_error: " ^ type_to_string a ^ " <> " ^ type_to_string b))

  let recursion_error a b =
    let b = find b in
    raise
      (TypeErr
         ("recursive: tvar " ^ ID.to_string a ^ " occurs in " ^ type_to_string b))

  (** Check for type recursion: recursion is failure. *)
  let occurs_in a b =
    let check = function
      | Var t -> equal_tvar t a
      | TypeConstr (ls, _) -> List.for_all Fun.id ls
    in
    Rec.cata check b

  (** Type unification.*)
  let rec unify ?(pos = Lexing.dummy_pos) t t' =
    Logs.debug (fun m ->
        m "%s"
          ("unify: " ^ plpos pos ^ " "
          ^ type_to_string (find t)
          ^ " with "
          ^ type_to_string (find t')));
    match (map_expr unfix @@ Typ.unfix t, map_expr unfix @@ Typ.unfix t') with
    | TypeConstr ([], "nothing"), _ -> t
    | _, TypeConstr ([], "nothing") -> t'
    | Var x, Var y -> Typ.union t t'
    | Var x, _ when occurs_in x t' -> recursion_error x t'
    | Var _, TypeConstr _ -> merge (fun a b -> b) t t'
    | _, Var x -> unify ~pos:[%here] t' t
    | TypeConstr (ars, n), TypeConstr (ars', n') when not (String.equal n n') ->
        type_error t t'
    | TypeConstr (ars, n), TypeConstr (ars', n')
      when List.length ars <> List.length ars' ->
        type_error t t'
    | ( TypeConstr ([ (Var v as vr) ], "bv"),
        TypeConstr ([ (TypeConstr ([], a) as cst) ], "bv") )
    | ( TypeConstr ([ (TypeConstr ([], a) as cst) ], "bv"),
        TypeConstr ([ (Var v as vr) ], "bv") ) ->
        (* prioritise bitvec consts *)
        let v = merge (fun _ c -> c) (fix vr) (fix cst) in
        fix @@ TypeConstr ([ v ], "bv")
    | TypeConstr (ars, n), TypeConstr (ars', n') ->
        let args =
          List.combine ars ars'
          |> List.map (fun (a, b) -> unify ~pos:[%here] (fix a) (fix b))
        in
        merge (fun a b -> TypeConstr (args, n)) t t'

  (** instantiate typescheme for a single type-annotated variable *)
  let inst_annot_v ?(no_constraint = false) v =
    let ty =
      match Var.typ v with
      | _ when no_constraint -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
      | Nothing -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
      | o -> ty_of_basil o
    in
    ty

  (** lookup var and add unify with its type annotation *)
  let lookup_var_typ univ ?(no_constraint = false) c v =
    let vt = inst_annot_v v in
    let a =
      let v = V.of_var univ v in
      TCtx.find_opt v c |> function
      | Some v -> v
      | None -> failwith ("var not found: " ^ V.to_string v)
    in
    let tt = match a with Forall (_, ty) -> union ty vt in
    tt

  (** declare type with name in type scheme *)
  let decl_type ctx name vt =
    let tvar = V.create types_universe name in
    TCtx.update tvar
      (function
        | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
        | None -> Some (Forall ([], vt))
        | _ -> failwith "unk")
      ctx

  (** declare var with type in type scheme *)
  let decl_var_typ univ ?(no_constraint = false) c v =
    let vvar = V.of_var univ v in
    let vt = inst_annot_v v in
    TCtx.update vvar
      (function
        | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
        | None -> Some (Forall ([], vt))
        | _ -> failwith "unk")
      c
end
