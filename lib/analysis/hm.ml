open Bincaml_util.Common
open Lang
open UnionFind

type 'a tycon = 'a list * 'a
type variance = Cov | Contr | Inv
type tvar = ID.t [@@deriving eq, ord, show]

module V = struct
  (** scoped type variables *)

  type t = { univ : string; v : Var.t } [@@deriving eq, ord, show]

  let hash { univ; v } = Hash.pair Hash.string Var.hash (univ, v)

  let of_var p v =
    if Var.is_global v then { univ = "<global>"; v }
    else
      let univ = Procedure.id p |> ID.to_string in
      { univ; v }

  (** for testing: type inference within an expr *)
  let locally v = { univ = "<local>"; v }
end

module TCtx = Map.Make (V)

module ATyp = struct
  type 'a expr = Var of tvar | TypeConstr of 'a list * string
  [@@deriving eq, ord, show, map, fold]

  let hash he = function
    | Var v -> ID.hash v
    | TypeConstr (l, t) -> Hash.pair (Hash.list he) Hash.string (l, t)
end

module Typ = struct
  include ATyp

  type t = nt UnionFind.elem Fix.HashCons.cell
  and nt = T of t expr

  module Hashed = struct
    type t = nt elem
    (* we hash cons the data underlying the uf reference so we can construct the
       type and get the UF reference *)

    let hash (e : t) : int =
      e |> UnionFind.get |> function T e -> ATyp.hash Fix.HashCons.hash e

    let equal (i : t) (j : t) : bool =
      match (UnionFind.get i, UnionFind.get j) with
      | T i, T j -> ATyp.equal_expr Fix.HashCons.equal i j
  end

  module H = Fix.HashCons.ForHashedTypeWeak (Hashed)

  let unfix =
    Fix.HashCons.data %> UnionFind.find %> UnionFind.get %> function T e -> e

  let fix e = H.make (UnionFind.make (T e))

  let union (a : t) (b : t) : t =
    H.make @@ UnionFind.union (Fix.HashCons.data a) (Fix.HashCons.data b)

  (** dubious; has invariant that H.make returns same ref as find ;
      - should be true if we don't reassign refs but *)
  let find e = Fix.HashCons.data e |> UnionFind.find |> H.make

  let merge f (a : t) (b : t) : t =
    H.make
    @@ UnionFind.merge
         (fun (T a) (T b) -> T (f a b))
         (Fix.HashCons.data a) (Fix.HashCons.data b)
end

module Rec = Bincaml_util.Recursionscheme.Recursion (Typ)
open Typ

let printer_alg = function
  | Var e -> ID.to_string e
  | TypeConstr ([ l ], e) -> " " ^ e
  | TypeConstr (ls, e) ->
      List.to_string ~start:"(" ~stop:")" ~sep:", " Fun.id ls ^ " " ^ e

let type_to_string t = Rec.cata printer_alg t

let occurs_in a b =
  let check = function
    | Var t -> equal_tvar t a
    | TypeConstr (ls, _) -> List.fold_left ( || ) false ls
  in
  Rec.cata check b

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

let rec to_basil (t : t) : Types.t =
  let open Types in
  match unfix t with
  | TypeConstr ([ a; b ], "->") -> Map (to_basil a, to_basil b)
  | TypeConstr ([ w ], "bv") -> (
      match unfix w with
      | TypeConstr ([], a) -> (
          match Int.of_string a with
          | Some i -> Bitvector i
          | None -> Sort (a ^ "bv", []))
      | _ -> failwith "generic bv")
  | TypeConstr ([], "unit") -> Unit
  | TypeConstr ([], "bool") -> Boolean
  | TypeConstr ([], "int") -> Integer
  | TypeConstr ([], "top") -> Top
  | TypeConstr ([], "nothing") -> Nothing
  | TypeConstr ([], o) -> Sort (o, [])
  | _ -> failwith "not impl"

type scheme = Forall of tvar list * t

let scheme_to_string = function
  | Forall (tl, t) -> List.to_string ID.to_string tl ^ " . " ^ type_to_string t

module U = UnionFind

let plpos (l : Lexing.position) = Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

let rec unify ?(pos = Lexing.dummy_pos) t t' =
  print_endline
    ("unify: " ^ plpos pos ^ " "
    ^ type_to_string (find t)
    ^ " with "
    ^ type_to_string (find t'));
  match (map_expr unfix @@ Typ.unfix t, map_expr unfix @@ Typ.unfix t') with
  | Var x, _ when occurs_in x t' -> failwith "recursive type"
  | Var _, TypeConstr _ -> merge (fun a b -> b) t t'
  | Var x, Var y -> union t t'
  | _, Var x -> unify ~pos:[%here] t' t
  | TypeConstr (ars, n), TypeConstr (ars', n') when not (String.equal n n') ->
      failwith "false"
  | TypeConstr (ars, n), TypeConstr (ars', n')
    when List.length ars <> List.length ars' ->
      failwith "false"
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

let gen = ID.make_gen ()
let bv_type i = map_expr fix @@ bv_type i
let bvunk i = map_expr fix @@ TypeConstr ([ Var i ], "bv")

let rec ty_of_basil (t : Types.t) : t =
  let e =
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
  in
  fix e

let curry (args : t expr list) (v : t expr) =
  List.fold_left (fun a p -> fix @@ fun_type (fix p) a) (fix v) args

let curry_f (args : t list) (v : t) =
  List.fold_left (fun a p -> fix @@ fun_type p a) v args

(** Instantiate type scheme for intrinsics *)
let scheme_of_op (gen : ID.generator)
    (o : Ops.AllOps.([ const | unary | binary ])) =
  let fv () = gen.fresh ~name:"ɑ" () in
  match o with
  | `BOOLTOBV1 -> curry [ bool_type ] (bv_type 1)
  | `Bitvector b -> fix @@ bv_type (Bitvec.size b)
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
  | #Ops.IntOps.const -> fix @@ int_type
  | #Ops.IntOps.binary_unif -> curry [ int_type; int_type ] bool_type
  | #Ops.LogicalOps.binary -> curry [ bool_type; bool_type ] bool_type
  | #Ops.LogicalOps.unary -> curry [ bool_type ] bool_type
  | #Ops.LogicalOps.const -> fix @@ bool_type
  | `Old -> fix @@ Var (fv ())
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
      curry_f [ m; fix @@ Var a; fix @@ Var b ] m
  | `Cases -> fix @@ Var (fv ())

let rec infer (hr : Lexing.position) e (c : scheme TCtx.t) =
  print_endline ("infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
  let mkv v = V.locally v in
  let inst_annot_v v =
    match Var.typ v with
    | Top -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | o -> ty_of_basil o
  in
  let r = fix @@ Var (gen.fresh ()) in
  let open Expr.AbstractExpr in
  match Expr.BasilExpr.unfix e with
  | RVar { id } -> begin
      let a = TCtx.find (mkv id) c in
      match a with Forall (_, ty) -> union ty r
    end
  | Lambda { op; bound_vars; in_body } -> begin
      let tvars = List.map (fun v -> (v, inst_annot_v v)) bound_vars in
      let ictx =
        List.map (fun (v, t) -> (mkv v, Forall ([], t))) tvars
        |> TCtx.add_list c
      in
      let bdty = infer [%here] in_body ictx in
      let r =
        match op with
        | `Lambda -> bdty
        | `Forall | `Exists -> unify bdty (fix bool_type)
      in
      ignore @@ unify r (curry_f (List.map snd tvars) bdty);
      r
    end
  | Constant { const = #Ops.AllOps.const as op } -> begin
      let f = scheme_of_op gen op in
      unify r f
    end
  | UnaryExpr { op = #Ops.AllOps.unary as op; arg } -> begin
      let f = scheme_of_op gen op in
      let arg = infer [%here] arg c in
      ignore @@ unify f (curry_f [ arg ] r);
      r
    end
  | BinaryExpr { op = #Ops.AllOps.binary as op; arg1; arg2 } -> begin
      let f = scheme_of_op gen op in
      let arg1 = infer [%here] arg1 c in
      let arg2 = infer [%here] arg2 c in
      ignore @@ unify f (curry_f [ arg1; arg2 ] r);
      r
    end
  | ApplyIntrin { op = #Ops.AllOps.intrin as op; args } -> begin
      let f = scheme_of_intrin gen op (List.length args) in
      let args = List.map (fun a -> infer [%here] a c) args in
      ignore @@ unify f (curry_f args r);
      r
    end
  | ApplyFun { func; args } ->
      let f = infer [%here] func c in
      let args = List.map (fun a -> infer [%here] a c) args in
      ignore @@ unify f (curry_f args r);
      r
  | Let _ -> failwith ""

let decl_var_typ ?(no_constraint = false) c v =
  let vvar = V.locally v in
  let inst_annot_v v =
    match Var.typ v with
    | _ when no_constraint -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | Top -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | o -> ty_of_basil o
  in
  let vt = inst_annot_v v in
  TCtx.update vvar
    (function
      | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
      | None -> Some (Forall ([], vt))
      | _ -> failwith "unk")
    c

let%expect_test "test 2" =
  let a = U.make "a" in
  let b = U.make "b" in
  let c = U.union b a in
  print_endline (U.get c);
  let d = U.make "a" in
  let f = U.find d in
  print_endline (U.get f);
  ()

let testa () =
  print_endline "alsdkldjalk jdalkj";
  Logs.err (fun m -> m "run test ");
  let open Expr in
  let e =
    BasilExpr.boolnot @@ BasilExpr.boolnot @@ BasilExpr.boolnot
    @@ BasilExpr.applyintrin ~op:`AND
         [
           BasilExpr.boolnot
             (BasilExpr.boolnot (BasilExpr.rvar (Var.create "b" Boolean)));
           BasilExpr.rvar (Var.create "a" Boolean);
         ]
  in
  let ctx =
    BasilExpr.free_vars_iter e
    |> Iter.fold (decl_var_typ ~no_constraint:true) TCtx.empty
  in
  let e = infer [%here] e ctx in
  let _ =
    TCtx.to_iter ctx
    |> Iter.to_string (fun (a, b) ->
        Printf.sprintf "%s %s" (V.show a) (scheme_to_string b))
    |> print_endline
  in
  (*print_endline (Types.to_string @@ to_basil e);*)
  ()
