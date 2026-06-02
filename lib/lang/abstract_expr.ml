open Common
open Containers
open Ops

module AbstractExpr = struct
  open Attrib

  let pp_attrib_map fm m =
    let m = Attrib.to_string ~show_internal:true (`Assoc m) in
    Format.pp_print_string fm m

  type ('const, 'var, 'unary, 'binary, 'intrin, 'typ, 'e) t =
    | RVar of { attrib : attrib_map; id : 'var; typ : 'typ }  (** variables *)
    | Constant of { attrib : attrib_map; const : 'const; typ : 'typ }
        (** constants; a pure intrinsic function with zero arguments *)
    | UnaryExpr of { attrib : attrib_map; op : 'unary; arg : 'e; typ : 'typ }
        (** application of a pure intrinsic function with one arguments *)
    | BinaryExpr of {
        attrib : attrib_map;
        op : 'binary;
        arg1 : 'e;
        arg2 : 'e;
        typ : 'typ;
      }  (** application of a pure intrinsic function with two arguments *)
    | ApplyIntrin of {
        attrib : attrib_map;
        op : 'intrin;
        args : 'e list;
        typ : 'typ;
      }  (** application of a pure intrinsic function with n arguments *)
    | ApplyFun of { attrib : attrib_map; func : 'e; args : 'e list; typ : 'typ }
        (** application of a pure runtime-defined function with n arguments *)
    | Lambda of {
        op : Ops.AllOps.lambda;
        attrib : attrib_map;
        triggers : 'e list list;
        bound_vars : 'var list;
        in_body : 'e;
        typ : 'typ;
      }  (** syntactic binding in a nested scope *)
    | Let of {
        attrib : attrib_map;
        bound_vars : ('var * 'e) list;
        in_body : 'e;
        typ : 'typ;
      }  (** syntactic binding in a nested scope *)
  [@@deriving eq, ord, fold, map, iter, show { with_path = false }]

  let to_iter e =
    let ignore e = () in
    let i e = fun f -> iter ignore ignore ignore ignore ignore ignore f e in
    Iter.from_iter (fun f -> i e f)

  let get_typ x =
    match x with
    | RVar { typ } -> typ
    | Constant { typ } -> typ
    | UnaryExpr { typ } -> typ
    | BinaryExpr { typ } -> typ
    | ApplyIntrin { typ } -> typ
    | ApplyFun { typ } -> typ
    | Lambda { typ } -> typ
    | Let { typ } -> typ

  let set_typ x typ =
    match x with
    | RVar x -> RVar { x with typ }
    | Constant x -> Constant { x with typ }
    | UnaryExpr x -> UnaryExpr { x with typ }
    | BinaryExpr x -> BinaryExpr { x with typ }
    | ApplyIntrin x -> ApplyIntrin { x with typ }
    | ApplyFun x -> ApplyFun { x with typ }
    | Lambda x -> Lambda { x with typ }
    | Let x -> Let { x with typ }

  let map_attrib f x =
    match x with
    | RVar x -> RVar { x with attrib = f x.attrib }
    | Constant x -> Constant { x with attrib = f x.attrib }
    | UnaryExpr x -> UnaryExpr { x with attrib = f x.attrib }
    | BinaryExpr x -> BinaryExpr { x with attrib = f x.attrib }
    | ApplyIntrin x -> ApplyIntrin { x with attrib = f x.attrib }
    | ApplyFun x -> ApplyFun { x with attrib = f x.attrib }
    | Lambda x -> Lambda { x with attrib = f x.attrib }
    | Let x -> Let { x with attrib = f x.attrib }

  let get_attrib x =
    match x with
    | RVar { attrib } -> attrib
    | Constant { attrib } -> attrib
    | UnaryExpr { attrib } -> attrib
    | BinaryExpr { attrib } -> attrib
    | ApplyIntrin { attrib } -> attrib
    | ApplyFun { attrib } -> attrib
    | Let { attrib } -> attrib
    | Lambda { attrib } -> attrib

  let drop_attrib x =
    match x with
    | RVar v -> RVar { v with attrib = Attrib.empty }
    | Constant v -> Constant { v with attrib = Attrib.empty }
    | UnaryExpr v -> UnaryExpr { v with attrib = Attrib.empty }
    | BinaryExpr v -> BinaryExpr { v with attrib = Attrib.empty }
    | ApplyIntrin v -> ApplyIntrin { v with attrib = Attrib.empty }
    | ApplyFun v -> ApplyFun { v with attrib = Attrib.empty }
    | Lambda v -> Lambda { v with attrib = Attrib.empty }
    | Let v -> Let { v with attrib = Attrib.empty }

  let id a b = a
  let fold f b o = fold id id id id id id f b o

  let map f e =
    let id a = a in
    map id id id id id id f e

  let hash hash_const hash_v hash_unary hash_bin hash_intrin hash_typ hash e1 :
      int =
    match e1 with
    | Constant { const = c; typ } ->
        Hash.(combine3 7 (hash_const c) (hash_typ typ))
    | RVar { id; typ } -> Hash.(combine3 2 (hash_v id) (hash_typ typ))
    | UnaryExpr { op; arg; typ } ->
        Hash.(combine4 3 (hash_unary op) (hash arg) (hash_typ typ))
    | BinaryExpr { op; arg1; arg2; typ } ->
        Hash.(combine5 5 (hash_bin op) (hash arg1) (hash arg2) (hash_typ typ))
    | ApplyIntrin { op; args; typ } ->
        Hash.(combine4 11 (hash_intrin op) (list hash args) (hash_typ typ))
    | ApplyFun { func; args; typ } ->
        Hash.(combine4 13 (hash func) (list hash args) (hash_typ typ))
    | Lambda { bound_vars; in_body; typ } ->
        Hash.(
          combine4 17 (list hash_v bound_vars) (hash in_body) (hash_typ typ))
    | Let { bound_vars; in_body; typ } ->
        Hash.(
          combine4 23
            ((list (pair hash_v hash)) bound_vars)
            (hash in_body) (hash_typ typ))
end

module Alges = struct
  open AbstractExpr

  let children_alg a =
    let alg a = fold (fun acc a -> a @ acc) [] a in
    alg
end

module type Fix = sig
  type const
  (** Type of constants*)

  type var
  (** Type of variables *)

  type unary
  (** Unary operators *)

  type binary
  (** Binary operators *)

  type intrin
  (** Nary operators *)

  type typ

  type t
  (** Fixed type *)

  val top_typ : typ

  module Var : HASH_TYPE with type t = var

  val fix : (const, var, unary, binary, intrin, typ, t) AbstractExpr.t -> t
  val unfix : t -> (const, var, unary, binary, intrin, typ, t) AbstractExpr.t
end

module Make (O : Fix) = struct
  open Fun.Infix
  open O

  type 'e abstract_expr =
    (const, Var.t, unary, binary, intrin, Types.t, 'e) AbstractExpr.t

  include Bincaml_util.Recursionscheme.Recursion (struct
    include O

    type 'e expr = (const, Var.t, unary, binary, intrin, typ, 'e) AbstractExpr.t

    let map_expr = AbstractExpr.map
  end)

  let get_typ e = unfix e |> AbstractExpr.get_typ

  module Constructors = struct
    let rvar ?(attrib = Attrib.empty) ?(typ = top_typ) id =
      fix (RVar { attrib; id; typ })

    let const ?(attrib = Attrib.empty) ?(typ = top_typ) const =
      fix (Constant { attrib; const; typ })

    let binexp ?(attrib = Attrib.empty) ?(typ = top_typ) ~op arg1 arg2 =
      fix (BinaryExpr { attrib; op; arg1; arg2; typ })

    let unexp ?(attrib = Attrib.empty) ?(typ = top_typ) ~op arg =
      fix (UnaryExpr { attrib; op; arg; typ })

    let fapply ?(attrib = Attrib.empty) ?(typ = top_typ) func args =
      fix (ApplyFun { attrib; func; args; typ })

    let lambda ?(attrib = Attrib.empty) ?(triggers = []) ?(typ = top_typ) ~op
        bound_vars in_body =
      fix (Lambda { attrib; op; bound_vars; in_body; typ; triggers })

    let letexp ?(attrib = Attrib.empty) ?(typ = top_typ) bound_vars in_body =
      fix (Let { attrib; bound_vars; in_body; typ })

    let applyintrin ?(attrib = Attrib.empty) ?(typ = top_typ) ~op args =
      fix (ApplyIntrin { attrib; op; args; typ })

    let apply_fun ?(attrib = Attrib.empty) ?(typ = top_typ) ~func args =
      fix (ApplyFun { attrib; func; args; typ })

    let attrib e = unfix e |> AbstractExpr.get_attrib
  end

  (* dont know
  let bind_match ~fconst ~frvar ~funi ~fbin ~fbind ~fintrin ~ffun
      (e : 'e abstract_expr) : 'a =
    let open AbstractExpr in
    match e with
    | RVar v -> frvar v
    | Constant c -> fconst c
    | UnaryExpr (op, e) -> funi op e
    | BinaryExpr (op, a, b) -> fbin op a b
    | Lambda (a, b) -> fbind a b
    | ApplyIntrin (a, b) -> fintrin a b
    | ApplyFun (a, b) -> ffun a b
    *)

  (**helpers*)

  open struct
    module VarSet = Set.Make (Var)
  end

  (** get free vars of exprs *)
  let free_vars (e : t) =
    let open AbstractExpr in
    let alg e =
      match e with
      | RVar { id } -> VarSet.singleton id
      | Let { bound_vars; in_body } ->
          let bindees =
            List.fold_left VarSet.union VarSet.empty (List.map snd bound_vars)
          in
          let bound_vars = List.map fst bound_vars in
          VarSet.union bindees
            (VarSet.diff in_body (VarSet.add_list VarSet.empty bound_vars))
      | Lambda { bound_vars; in_body } ->
          VarSet.diff in_body (VarSet.add_list VarSet.empty bound_vars)
      | o -> fold (fun acc a -> VarSet.union a acc) VarSet.empty o
    in
    cata alg e

  let free_vars_iter (e : t) = free_vars e |> VarSet.to_iter

  (* substite variables for expressions *)
  let substitute (sub : var -> t option) (e : t) =
    let open AbstractExpr in
    let rec subst bound orig =
      let exp = unfix orig in
      match exp with
      | RVar { id } when VarSet.find_opt id bound |> Option.is_none -> (
          match sub id with Some r -> r | None -> orig)
      | Lambda { op; bound_vars; in_body; attrib; typ; triggers } ->
          (* exprs to bind are evaluated outside the bound *)
          let triggers = List.map (List.map (subst bound)) triggers in
          let bound = VarSet.add_list bound bound_vars in
          let in_body = subst bound in_body in
          fix (Lambda { op; bound_vars; in_body; attrib; typ; triggers })
      | Let { bound_vars; in_body; attrib; typ } ->
          (* exprs to bind are evaluated outside the bound *)
          let bound = VarSet.add_list bound (List.map fst bound_vars) in
          let in_body = subst bound in_body in
          fix (Let { bound_vars; in_body; attrib; typ })
      | o -> fix @@ AbstractExpr.map (subst bound) o
    in
    subst VarSet.empty e

  (** get list of child expressions *)
  let children e = cata Alges.children_alg e
end

module type ExprType = sig
  include Fix

  type 'e abstract_expr

  include
    Bincaml_util.Recursionscheme.Recurseable
      with type 'a O.expr =
        (const, var, unary, binary, intrin, typ, 'a) AbstractExpr.t

  val type_alg : typ O.expr -> typ
end
