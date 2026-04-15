open Bincaml_util.Common
open Lang
open UnionFind

type 'a tycon = 'a list * 'a
type variance = Cov | Contr | Inv
type tvar = ID.t [@@deriving eq, ord, show]

module V = struct
  (** scoped type variables *)

  type t = { univ : string; v : string } [@@deriving eq, ord, show]

  let hash { univ; v } = Hash.pair Hash.string Hash.string (univ, v)
  let to_string { univ; v } = univ ^ "::" ^ v
  let local_univ = "<local>"
  let global_univ = "<global>"
  let proc_univ p = ID.to_string p

  let of_var univ v =
    if Var.is_global v then { univ = global_univ; v = Var.name v }
    else { univ; v = Var.name v }
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
  | TypeConstr ([ l ], e) -> l ^ " " ^ e
  | TypeConstr ([ a; b ], "->") -> a ^ " -> " ^ b
  | TypeConstr ([], e) -> e
  | TypeConstr (ls, e) ->
      List.to_string ~start:"(" ~stop:")" ~sep:"," Fun.id ls ^ " " ^ e

let type_to_string t = Rec.cata printer_alg t

let occurs_in a b =
  let check = function
    | Var t -> equal_tvar t a
    | TypeConstr (ls, _) -> List.fold_left ( || ) false ls
  in
  Rec.cata check b

let tmod_const a = TypeConstr ([ a ], "const")
let tmod_shared a = TypeConstr ([ a ], "shared")
let fun_type a b = TypeConstr ([ a; b ], "->")
let int_type = TypeConstr ([], "int")
let nat_val_type i = TypeConstr ([], Int.to_string i)
let bv_type i = map_expr fix @@ TypeConstr ([ nat_val_type i ], "bv")
let bvunk i = TypeConstr ([ Var i ], "bv")
let bool_type = TypeConstr ([], "bool")
let unit_t = TypeConstr ([], "unit")
let top_t = TypeConstr ([], "top")
let nothing_t = TypeConstr ([], "nothing")
let ptr_typ_sub a b = TypeConstr ([ a; b ], "ptr")
let ptr_typ = bv_type 64

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
  | Forall (tl, t) ->
      List.to_string ID.to_string tl ^ ". " ^ type_to_string (find t)

module U = UnionFind

let plpos (l : Lexing.position) = Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

exception TypeErr of string

let type_error a b =
  let a = find a in
  let b = find b in
  raise
    (TypeErr ("type_error: " ^ type_to_string a ^ " <> " ^ type_to_string b))

let rec unify ?(pos = Lexing.dummy_pos) t t' =
  print_endline
    ("unify: " ^ plpos pos ^ " "
    ^ type_to_string (find t)
    ^ " with "
    ^ type_to_string (find t'));
  match (map_expr unfix @@ Typ.unfix t, map_expr unfix @@ Typ.unfix t') with
  | TypeConstr ([], "nothing"), _ -> t
  | _, TypeConstr ([], "nothing") -> t'
  | Var x, Var y -> union t t'
  | Var x, _ when occurs_in x t' -> failwith "recursive type"
  | Var _, TypeConstr _ -> merge (fun a b -> b) t t'
  | _, Var x -> unify ~pos:[%here] t' t
  | TypeConstr ([ a ], "const"), TypeConstr ([ b ], "const") ->
      let x = unify ~pos:[%here] (fix a) (fix b) in
      fix @@ TypeConstr ([ x ], "const")
  | TypeConstr ([ a ], "shared"), TypeConstr ([ b ], "shared") ->
      let x = unify ~pos:[%here] (fix a) (fix b) in
      fix @@ TypeConstr ([ x ], "const")
  | o, TypeConstr ([ b ], "shared") | o, TypeConstr ([ b ], "const") ->
      unify ~pos:[%here] t' t
  | TypeConstr ([ b ], "shared"), o ->
      let b = unify ~pos:[%here] (fix b) (fix (map_expr fix o)) in
      fix @@ TypeConstr ([ b ], "shared")
  | TypeConstr ([ b ], "const"), o ->
      let b = unify ~pos:[%here] (fix b) (fix (map_expr fix o)) in
      fix @@ TypeConstr ([ b ], "const")
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

let gen = ID.make_gen ()
let bv_type i = bv_type i
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
        ptr_typ_sub (ty_of_basil lower) (ty_of_basil upper)
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
  | `Extract (hi, lo) -> curry [ bvunk (fv ()) ] (bv_type (hi - lo))
  | `SignExtend bits -> curry [ bvunk (fv ()) ] (bvunk (fv ()))
  | `ZeroExtend bits -> curry [ bvunk (fv ()) ] (bvunk (fv ()))
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
  | #Ops.AllOps.binary as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o
  | #Ops.AllOps.unary as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o
  | #Ops.AllOps.const as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o

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

(* instantiate typescheme for a single type-annotated variable *)
let inst_annot_v ?(no_constraint = false) v =
  let ty =
    match Var.typ v with
    | _ when no_constraint -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | Nothing -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | o -> ty_of_basil o
  in
  ty

(* lookup var and add unify with its type annotation *)
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

let rec infer ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
  print_endline ("infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
  try do_infer univ hr e c
  with TypeErr m -> raise (TypeErr (m ^ " : " ^ Expr.BasilExpr.to_string e))

and do_infer univ hr e c =
  let mkv v = V.of_var univ v in
  let r = fix @@ Var (gen.fresh ()) in
  let open Expr.AbstractExpr in
  match Expr.BasilExpr.unfix e with
  | RVar { id } -> lookup_var_typ univ c id
  | Lambda { op; bound_vars; in_body } -> begin
      let tvars = List.map (fun v -> (v, inst_annot_v v)) bound_vars in
      let ictx =
        List.map (fun (v, t) -> (mkv v, Forall ([], t))) tvars
        |> TCtx.add_list c
      in
      let bdty = infer ~univ [%here] in_body ictx in
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
      let arg = infer ~univ [%here] arg c in
      ignore @@ unify f (curry_f [ arg ] r);
      r
    end
  | BinaryExpr { op = #Ops.AllOps.binary as op; arg1; arg2 } -> begin
      let f = scheme_of_op gen op in
      let arg1 = infer ~univ [%here] arg1 c in
      let arg2 = infer ~univ [%here] arg2 c in
      ignore @@ unify f (curry_f [ arg1; arg2 ] r);
      r
    end
  | ApplyIntrin { op = #Ops.AllOps.intrin as op; args } -> begin
      let f = scheme_of_intrin gen op (List.length args) in
      let args = List.map (fun a -> infer ~univ [%here] a c) args in
      ignore @@ unify f (curry_f args r);
      r
    end
  | ApplyFun { func; args } ->
      let f = infer ~univ [%here] func c in
      let args = List.map (fun a -> infer ~univ [%here] a c) args in
      ignore @@ unify f (curry_f args r);
      r
  | Let _ -> failwith ""

let decl_var_typ univ ?(no_constraint = false) c v =
  let vvar = V.of_var univ v in
  let vt = inst_annot_v v in
  TCtx.update vvar
    (function
      | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
      | None -> Some (Forall ([], vt))
      | _ -> failwith "unk")
    c

let infer_phi univ ctx (p : Var.t Block.phi list) =
  let open Block in
  let r = fix @@ Var (gen.fresh ()) in
  List.fold_left
    (fun acc { lhs; rhs } ->
      let lhs = infer [%here] ~univ (Expr.BasilExpr.rvar lhs) ctx in
      let e =
        List.fold_left
          (fun a (_, r) ->
            let r = infer [%here] ~univ (Expr.BasilExpr.rvar r) ctx in
            unify a r)
          lhs rhs
      in
      unify acc e)
    r p

let ctx_to_string ctx =
  TCtx.to_iter ctx
  |> Iter.to_string (fun (a, b) ->
      Printf.sprintf "%s %s" (V.to_string a) (scheme_to_string b))

let fresh_tvar ?(n = "a") () = fix @@ Var (gen.fresh ~name:n ())

let do_infer_stmt p univ ctx stmt =
  let open Stmt in
  (*let r = fix @@ Var (gen.fresh ()) in*)
  match stmt with
  | Instr_IntrinCall _ -> failwith "intrin unsupported"
  | Instr_Assume { body } | Instr_Assert { body } ->
      let b = infer ~univ [%here] body ctx in
      ignore @@ unify (fix bool_type) b;
      ()
  | Instr_Assign ls ->
      let ls =
        List.map
          (fun (l, r) ->
            ( infer ~univ [%here] (Expr.BasilExpr.rvar l) ctx,
              infer ~univ [%here] r ctx ))
          ls
      in
      let _ = List.iter (fun (l, r) -> ignore @@ unify l r) ls in
      ()
  | Instr_Call { lhs; procid; args } ->
      let p = Program.proc p procid in
      let infer_param p =
        infer ~univ:(V.proc_univ procid) [%here] (Expr.BasilExpr.rvar p) ctx
      in
      StringMap.to_iter args
      |> Iter.map (fun (param, a) ->
          ( infer_param (StringMap.find param (Procedure.formal_in_params p)),
            infer ~univ [%here] a ctx ))
      |> Iter.iter (fun (form, act) -> ignore @@ unify form act);
      StringMap.to_iter lhs
      |> Iter.map (fun (param, a) ->
          ( infer_param (StringMap.find param @@ Procedure.formal_out_params p),
            infer ~univ [%here] (Expr.BasilExpr.rvar a) ctx ))
      |> Iter.iter (fun (form, act) -> ignore @@ unify form act);
      ()
  | Instr_IndirectCall { target } ->
      let _ = unify (fix @@ ptr_typ) (infer ~univ [%here] target ctx) in
      ()
  | Instr_Load { lhs; rhs; addr = Scalar } ->
      let _ =
        unify
          (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx)
          (infer ~univ [%here] (Expr.BasilExpr.rvar rhs) ctx)
      in
      ()
  | Instr_Load { lhs; rhs; addr = Addr { addr; size } } ->
      let addr = infer ~univ [%here] addr ctx in
      let _ = unify (fix @@ ptr_typ) addr in
      let mapt = fix @@ fun_type addr (fresh_tvar ()) in
      let _ = unify (lookup_var_typ univ ctx rhs) mapt in
      let _ =
        unify
          (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx)
          (fix @@ bv_type size)
      in
      ()
  | Instr_Store { lhs; rhs; value; addr = Scalar } ->
      let _ =
        unify (infer ~univ [%here] value ctx)
        @@ unify
             (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx)
             (infer ~univ [%here] (Expr.BasilExpr.rvar rhs) ctx)
      in
      ()
  | Instr_Store { lhs; rhs; value; addr = Addr { addr; size } } ->
      let addr = infer ~univ [%here] addr ctx in
      let _ = unify (fix @@ ptr_typ) addr in
      let mapt = fix @@ fun_type addr (fresh_tvar ()) in
      let _ = unify mapt (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx) in
      let _ = unify (lookup_var_typ univ ctx rhs) mapt in
      let _ = unify (infer ~univ [%here] value ctx) (fix @@ bv_type size) in
      ()

let infer_stmt p univ ctx s =
  try do_infer_stmt p univ ctx s
  with TypeErr m ->
    raise
      (TypeErr
         (m ^ " " ^ Stmt.to_string Var.pretty Var.pretty Expr.BasilExpr.pretty s))

let infer_block p univ ctx (b : Program.bloc) =
  let _ = infer_phi univ ctx b.phis in
  Block.stmts_iter b
  |> Iter.iter (fun s ->
      let _ = infer_stmt p univ ctx s in
      ())

let assume_proc_decl ctx ?(no_constraint = false) (p : Program.proc) =
  let globs = Var.Decls.values (Procedure.local_decls p) in
  let formals_in = Procedure.formal_in_params p |> StringMap.values in
  let formals_out = Procedure.formal_out_params p |> StringMap.values in
  let univ = V.proc_univ @@ Procedure.id p in
  let ctx =
    Iter.fold
      (decl_var_typ ~no_constraint univ)
      ctx
      (Iter.append globs @@ Iter.append formals_in formals_out)
  in
  ctx

let infer_proc prog ctx ?(no_constraint = false) (p : Program.proc) =
  let univ = V.proc_univ @@ Procedure.id p in
  Procedure.iter_blocks_topo_fwd p
  |> Iter.iter (fun (_, b) -> infer_block prog univ ctx b);
  print_endline univ;
  print_endline @@ ctx_to_string ctx;
  ctx

let infer_prog ~no_constraint p =
  let b = Program.global_vars p in
  (* instantiate type variables *)
  let ctx =
    Iter.fold (decl_var_typ ~no_constraint V.global_univ) TCtx.empty b
  in
  let ctx =
    IDMap.values p.procs |> Iter.fold (assume_proc_decl ~no_constraint) ctx
  in
  (* solve types *)
  IDMap.values p.procs |> Iter.fold (infer_proc p ~no_constraint) ctx

let infer_prog_test p =
  let ctx = infer_prog p ~no_constraint:false in
  print_endline (ctx_to_string ctx);
  p

let%expect_test "test 2" =
  let a = U.make "a" in
  let b = U.make "b" in
  let c = U.union b a in
  print_endline (U.get c);
  let d = U.make "a" in
  let f = U.find d in
  print_endline (U.get f);
  ()
