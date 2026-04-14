open Common
open UnionFind

type 'a tycon = 'a list * 'a
type variance = Cov | Contr | Inv
type tvar = ID.t [@@deriving eq, ord, show]

module V = struct
  (** scoped type variables *)

  type t = { univ : string; v : Var.t } [@@deriving eq, ord, show]

  let of_var p v =
    if Var.is_global v then { univ = "<global>"; v }
    else
      let univ = Procedure.id p |> ID.to_string in
      { univ; v }

  (** for testing: type inference within an expr *)
  let locally v = { univ = "<local>"; v }
end

module TCtx = Map.Make (V)

module Typ = struct
  type t = Var of tvar | TypeConstr of t list * string
  [@@deriving eq, ord, show]
end

open Typ

let occurs_in a b =
  let rec check = function
    | Var t -> equal_tvar t a
    | TypeConstr (ls, _) -> List.fold_left (fun a b -> a || check b) false ls
  in
  check b

let fun_type a b = TypeConstr ([ a; b ], "->")
let int_type = TypeConstr ([], "int")
let nat_val_type i = TypeConstr ([], Int.to_string i)
let bv_type i = TypeConstr ([ nat_val_type i ], "bv")
let bvunk i = TypeConstr ([ Var i ], "bv")
let bool_type = TypeConstr ([], "bool")
let ptr_typ a b = TypeConstr ([ a; b ], "ptr")
let unit_t = TypeConstr ([], "unit")
let top_t = TypeConstr ([], "top")
let nothing_t = TypeConstr ([], "nothing")

type scheme = Forall of tvar list * t

module U = UnionFind

let rec unify t t' =
  let tt : t = U.get @@ U.find t in
  let tt' : t = U.get @@ U.find t' in
  match (tt, tt') with
  | Var x, _ when occurs_in x tt' -> failwith "recursive type"
  | Var _, TypeConstr _ -> U.union t t'
  | _, Var x -> unify t' t
  | TypeConstr (ars, n), TypeConstr (ars', n') when not (String.equal n n') ->
      failwith "false"
  | TypeConstr (ars, n), TypeConstr (ars', n')
    when List.length ars <> List.length ars' ->
      failwith "false"
  | TypeConstr (ars, n), TypeConstr (ars', n') ->
      let args =
        List.combine ars ars'
        |> List.map (fun (a, b) -> unify (U.make a) (U.make b))
      in
      U.merge (fun a b -> TypeConstr (List.map U.get args, n)) t t'

let gen = ID.make_gen ()

let rec ty_of_basil (t : Types.t) : t =
  match t with
  | Types.Boolean -> bool_type
  | Types.Integer -> int_type
  | Types.Bitvector i -> bv_type i
  | Types.Unit -> unit_t
  | Types.Top -> top_t
  | Types.Nothing -> nothing_t
  | Types.Map (a, b) -> fun_type (ty_of_basil a) (ty_of_basil b)
  | Types.Sort (n, _) -> TypeConstr ([], n)
  | Types.Struct _ -> failwith "unsupp"
  | Types.Pointer { lower; upper } ->
      ptr_typ (ty_of_basil lower) (ty_of_basil upper)
  | Types.Variable n -> Var (gen.fresh ~name:n ())

let curry (args : t list) (v : t) =
  List.fold_left (fun a p -> fun_type p a) v args

(** Instantiate type scheme for intrinsics *)
let scheme_of_op (gen : ID.generator)
    (o : Ops.AllOps.([ const | unary | binary ])) =
  let fv () = gen.fresh ~name:"ɑ" () in
  match o with
  | `BOOLTOBV1 -> curry [ bool_type ] (bv_type 1)
  | `Bitvector b -> bv_type (Bitvec.size b)
  | #Ops.BVOps.binary_unif ->
      let a = fv () in
      curry [ bvunk a; bvunk a ] (bvunk a)
  | #Ops.BVOps.binary_pred ->
      let a = fv () in
      curry [ bvunk a; bvunk a ] bool_type
  | #Ops.BVOps.unary_unif ->
      let a = fv () in
      curry [ bvunk a ] (bvunk a)
  | `INTNEG -> curry [ int_type ] int_type
  | #Ops.IntOps.binary_pred -> curry [ int_type; int_type ] bool_type
  | #Ops.IntOps.const -> int_type
  | #Ops.IntOps.binary_unif -> curry [ int_type; int_type ] bool_type
  | #Ops.LogicalOps.binary -> curry [ bool_type; bool_type ] bool_type
  | #Ops.LogicalOps.unary -> curry [ bool_type ] bool_type
  | #Ops.LogicalOps.const -> bool_type
  | `Old -> Var (fv ())
  | o -> failwith @@ "unsupported op"

let scheme_of_intrin (gen : ID.generator) (o : Ops.AllOps.(intrin)) args =
  let fv () = gen.fresh ~name:"ɑ" () in
  match o with
  | `BVADD | `BVMUL | `BVOR | `BVXOR | `BVAND ->
      let a = fv () in
      curry (List.init args (fun _ -> Var a)) (Var a)
  | `BVConcat -> curry (List.init args (fun _ -> Var (fv ()))) (Var (fv ()))
  | `OR | `AND -> curry (List.init args (fun _ -> bool_type)) bool_type
  | `MapUpdate ->
      let a = fv () in
      let b = fv () in
      let m = curry [ Var a ] (Var b) in
      curry [ m; Var a; Var b ] m
  | `Cases -> Var (fv ())

let rec infer e (c : scheme TCtx.t) =
  let mkv v = V.locally v in
  let inst_annot_v v =
    match Var.typ v with
    | Top -> Var (gen.fresh ~name:(Var.name v) ())
    | o -> ty_of_basil o
  in
  let r = U.make @@ Var (gen.fresh ()) in
  let open Expr.AbstractExpr in
  match Expr.BasilExpr.unfix e with
  | RVar { id } -> begin
      let a = TCtx.find (mkv id) c in
      match a with Forall (_, ty) -> U.union (U.make ty) r
    end
  | Lambda { op; bound_vars; in_body } -> begin
      let tvars = List.map (fun v -> (v, inst_annot_v v)) bound_vars in
      let ictx =
        List.map (fun (v, t) -> (mkv v, Forall ([], t))) tvars
        |> TCtx.add_list c
      in
      let bdty = U.get @@ infer in_body ictx in
      let r =
        match op with
        | `Lambda -> U.make bdty
        | `Forall | `Exists -> unify (U.make bdty) (U.make bool_type)
      in
      ignore @@ unify r (U.make @@ curry (List.map snd tvars) bdty);
      U.find r
    end
  | Constant { const = #Ops.AllOps.const as op } -> begin
      let f = U.make @@ scheme_of_op gen op in
      unify r f
    end
  | UnaryExpr { op = #Ops.AllOps.unary as op; arg } -> begin
      let f = U.make @@ scheme_of_op gen op in
      let arg = infer arg c in
      ignore @@ unify f (U.make @@ curry [ U.get @@ arg ] (U.get @@ r));
      r
    end
  | BinaryExpr { op = #Ops.AllOps.binary as op; arg1; arg2 } -> begin
      let f = U.make @@ scheme_of_op gen op in
      let arg1 = infer arg1 c in
      let arg2 = infer arg2 c in
      ignore
      @@ unify f (U.make @@ curry [ U.get @@ arg1; U.get arg2 ] (U.get @@ r));
      r
    end
  | ApplyIntrin { op = #Ops.AllOps.intrin as op; args } -> begin
      let f = U.make @@ scheme_of_intrin gen op (List.length args) in
      let args = List.map (fun a -> U.get @@ infer a c) args in
      ignore @@ unify f (U.make @@ curry args (U.get @@ r));
      r
    end
  | ApplyFun { func; args } ->
      let f = infer func c in
      let args = List.map (fun a -> U.get @@ infer a c) args in
      ignore @@ unify f (U.make @@ curry args (U.get @@ r));
      r
  | Let _ -> failwith ""
