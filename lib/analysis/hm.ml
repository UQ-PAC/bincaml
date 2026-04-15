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

  let of_var univ v =
    if Var.is_global v then { univ = "<global>"; v = Var.name v }
    else { univ; v = Var.name v }

  let local_univ = "<local>"
  let global_univ = "<global>"
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
  | TypeConstr ([], e) -> e
  | TypeConstr (ls, e) ->
      List.to_string ~start:"(" ~stop:")" ~sep:" " Fun.id ls ^ " " ^ e

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

(* instantiate typescheme for a single type-annotated variable *)
let inst_annot_v ?(no_constraint = false) v =
  let ty =
    match Var.typ v with
    | _ when no_constraint -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | Nothing -> fix @@ Var (gen.fresh ~name:(Var.name v) ())
    | o -> ty_of_basil o
  in
  ty

let rec infer ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
  print_endline ("infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
  try do_infer univ hr e c
  with TypeErr m ->
    print_endline m;
    ty_of_basil Nothing

and do_infer univ hr e c =
  let mkv v = V.of_var univ v in
  let r = fix @@ Var (gen.fresh ()) in
  let open Expr.AbstractExpr in
  match Expr.BasilExpr.unfix e with
  | RVar { id } -> begin
      let v = mkv id in
      let a =
        TCtx.find_opt v c |> function
        | Some v -> v
        | None -> failwith ("var not found: " ^ V.to_string v)
      in
      match a with Forall (_, ty) -> union ty r
    end
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

let infer_stmt univ ctx stmt =
  let open Stmt in
  (*let r = fix @@ Var (gen.fresh ()) in*)
  match stmt with
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
  | Instr_Call _ -> ()
  | Instr_IndirectCall _ -> ()
  | Instr_IntrinCall _ -> ()
  | Instr_Load _ -> ()
  | Instr_Store _ -> ()

let infer_block univ ctx (b : Program.bloc) =
  let _ = infer_phi univ ctx b.phis in
  Block.stmts_iter b
  |> Iter.iter (fun s ->
      let _ = infer_stmt univ ctx s in
      ())

let lproc =
  Loader.Loadir.ast_of_string
    {|
prog entry @main;
proc @main(b:bv64, global_in:bv64, y:bv64)  -> () {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
   block %main_entry [
     (var a:bv64=out2) := 
     call @fun2(f=b:bv64, global_in=global_1:bv64);
     (var x:bv64=out) :=  call @fun1(c=a:bv64, d=b:bv64, global_in=global_1:bv64);
     (var b_1:bv64 := b:bv64, var x_1:bv64 := x:bv64);
     assert eq(x_1:bv64, bvadd(b_1:bv64, b_1:bv64));
     var y_1 := y;
     assert eq(y_1:bv64, 0);
     nop;
     return;
   ]
];
proc @fun1(c:bv64, d:bv64, global_in:bv64)  -> (out:bv64) {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
   block %fun1_entry [
     (var e:bv64=out2) := 
     call @fun2(f=d:bv64, global_in=global_1:bv64);
     let out:bv64 := bvsub(c:bv64, e:bv64);
     return;
   ]
];
proc @fun2(f:bv64, global_in:bv64)  -> (out2:bv64) {  }
  

[
   block %inputs [ var global_1:= global_in; goto (%fun2_entry); ];
   block %fun2_entry [ goto (%fun2_b,%fun2_a); ];
   block %fun2_a [
     var f_2 := f;
     guard bvsle(f_2, 0:bv64);
     (var g_2 =out) := 
     call @fun1(c=f_2, d=1:bv64, global_in=global_1);
     goto (%fun2_return);
   ];
   block %fun2_b [
     var f_1 := f:bv64;
     guard boolnot(bvsle(f_1:bv64, 0:bv64));
     var g_1 := global_1;
     goto (%fun2_return);
   ];
   block %fun2_return (
     var f_3 := phi(%fun2_b -> f_1, %fun2_a -> f_2),
     var g_3 := phi(%fun2_b -> g_1, %fun2_a -> g_2)
   ) [ var out2:bv64 := bvadd(f_3, g_3); return; ]
];
    |}

let assume_proc_decl ctx ?(no_constraint = false) (p : Program.proc) =
  let globs = Var.Decls.values (Procedure.local_decls p) in
  let formals_in = Procedure.formal_in_params p |> StringMap.values in
  let formals_out = Procedure.formal_out_params p |> StringMap.values in
  let univ = ID.to_string @@ Procedure.id p in
  let ctx =
    Iter.fold
      (decl_var_typ ~no_constraint univ)
      ctx
      (Iter.append globs @@ Iter.append formals_in formals_out)
  in
  ctx

let infer_proc ctx ?(no_constraint = false) (p : Program.proc) =
  let univ = ID.to_string @@ Procedure.id p in
  Procedure.iter_blocks_topo_fwd p
  |> Iter.iter (fun (_, b) -> infer_block univ ctx b);
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
  IDMap.values p.procs |> Iter.fold (infer_proc ~no_constraint) ctx

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
  let ctx_b =
    BasilExpr.free_vars_iter e
    |> Iter.fold (decl_var_typ V.local_univ ~no_constraint:true) TCtx.empty
  in
  let ctx = infer_prog ~no_constraint:false lproc.prog in
  let e = infer [%here] e ctx in
  let _ =
    TCtx.to_iter ctx
    |> Iter.to_string (fun (a, b) ->
        Printf.sprintf "%s %s" (V.to_string a) (scheme_to_string b))
    |> print_endline
  in
  (*print_endline (Types.to_string @@ to_basil e);*)
  ()
