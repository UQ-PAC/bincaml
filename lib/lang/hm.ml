open Common
open UnionFind
open Abstract_expr

module TypeInference (T : TypeExpr.TypeContext) = struct
  open TypeExpr
  include T
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

  let plpos (l : Lexing.position) =
    Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

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
      (o : [ Ops.AllOps.const | Ops.AllOps.unary | Ops.AllOps.binary ]) =
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

  let scheme_of_intrin (gen : ID.generator) (o : Ops.AllOps.intrin) args =
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

  type typ = t [@@deriving eq, ord]

  module AbsTypingExpr = struct
    open Ops
    include AllOps
    module Var = Var

    type var = Var.t

    type t = E of (const, Var.t, unary, binary, intrin, typ, t) AbstractExpr.t
    [@@unboxed] [@@deriving eq, ord]

    type nonrec typ = typ

    let top_typ = fix @@ top_t
    let fix i = E i
    let unfix i = match i with E i -> i
  end

  module TypingExpr = Expr.Make (AbsTypingExpr)

  let getty = AbsTypingExpr.unfix %> Expr.AbstractExpr.get_typ

  let do_infer
      (infer :
        univ:string ->
        Lexing.position ->
        Program.e ->
        scheme TCtx.t ->
        AbsTypingExpr.t) univ hr e c : AbsTypingExpr.t =
    let mkv v = V.of_var univ v in
    let r = fix @@ Var (gen.fresh ()) in
    let open Abstract_expr.AbstractExpr in
    let e = Expr.BasilExpr.unfix e in
    let e = set_typ e r in
    match e with
    | RVar { id; attrib } ->
        let typ = lookup_var_typ univ c id in
        AbsTypingExpr.fix (RVar { attrib; id; typ })
    | Lambda { op; bound_vars; in_body; attrib; triggers } -> begin
        let tvars = List.map (fun v -> (v, inst_annot_v v)) bound_vars in
        let ictx =
          List.map (fun (v, t) -> (mkv v, Forall ([], t))) tvars
          |> TCtx.add_list c
        in
        let bdty = infer ~univ [%here] in_body ictx in
        let typ =
          match op with
          | `Lambda -> getty bdty
          | `Forall | `Exists -> unify (getty bdty) (fix bool_type)
        in
        ignore @@ unify r (curry_f (List.map snd tvars) (getty bdty));
        (* FIXME: probably inferring in the wrong context *)
        let triggers =
          List.map (List.map (fun e -> infer ~univ [%here] e ictx)) triggers
        in
        AbsTypingExpr.fix
          (Lambda { op; bound_vars; in_body = bdty; attrib; typ; triggers })
      end
    | Constant { const = #Ops.AllOps.const as op; attrib } -> begin
        let f = scheme_of_op gen op in
        let r = unify r f in
        AbsTypingExpr.fix (Constant { typ = r; const = op; attrib })
      end
    | UnaryExpr { op = #Ops.AllOps.unary as op; arg; attrib } -> begin
        let f = scheme_of_op gen op in
        let arg = infer ~univ [%here] arg c in
        ignore @@ unify f (curry_f [ getty arg ] r);
        AbsTypingExpr.fix (UnaryExpr { typ = r; op; attrib; arg })
      end
    | BinaryExpr { op = #Ops.AllOps.binary as op; arg1; arg2; attrib } -> begin
        let f = scheme_of_op gen op in
        let arg1 = infer ~univ [%here] arg1 c in
        let arg2 = infer ~univ [%here] arg2 c in
        ignore @@ unify f (curry_f [ getty arg1; getty arg2 ] r);
        AbsTypingExpr.fix (BinaryExpr { typ = r; op; attrib; arg1; arg2 })
      end
    | ApplyIntrin { op = #Ops.AllOps.intrin as op; args; attrib } -> begin
        let f = scheme_of_intrin gen op (List.length args) in
        let args = List.map (fun a -> infer ~univ [%here] a c) args in
        ignore @@ unify f (curry_f (List.map getty args) r);
        AbsTypingExpr.fix (ApplyIntrin { typ = r; op; attrib; args })
      end
    | ApplyFun { func; args; attrib } ->
        let f = infer ~univ [%here] func c in
        let args = List.map (fun a -> infer ~univ [%here] a c) args in
        ignore @@ unify (getty f) (curry_f (List.map getty args) r);
        AbsTypingExpr.fix (ApplyFun { typ = r; func = f; attrib; args })
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

  let rec infer_ty ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
    print_endline ("infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
    let t =
      try do_infer infer_ty univ hr e c
      with TypeErr m ->
        raise (TypeErr (m ^ " : " ^ Expr.BasilExpr.to_string e))
    in
    t

  let infer ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
    infer_ty ~univ hr e c |> AbsTypingExpr.unfix |> AbstractExpr.get_typ

  (** extract type after full inference has run *)
  let elaborate ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
    let alg e =
      let e =
        match e with
        | AbstractExpr.RVar { id; attrib; typ } ->
            (* FIXME: bad to have two type annotations *)
            let id =
              lookup_var_typ ~no_constraint:true univ c id |> find |> to_basil
              |> fun typ -> Var.copy ~typ id
            in
            AbstractExpr.RVar { id; attrib; typ }
        | o -> o
      in
      let t = AbstractExpr.get_typ e |> find |> to_basil in
      AbstractExpr.set_typ e t |> Expr.BasilExpr.fix
    in
    infer_ty ~univ hr e c |> TypingExpr.cata alg

  let unfix i = match i with Expr.BasilExpr.E i -> i
  let rec cata alg e = (unfix %> AbstractExpr.map (cata alg) %> alg) e

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
    let infer_ty h e = infer_ty ~univ h e ctx in

    (*let r = fix @@ Var (gen.fresh ()) in*)
    match stmt with
    | Instr_IntrinCall _ -> failwith "intrin unsupported"
    | Instr_Assume { body; branch; attrib } ->
        let body = infer_ty [%here] body in
        ignore @@ unify (fix bool_type) (getty body);
        Instr_Assume { body; branch; attrib }
    | Instr_Assert { body; attrib } ->
        let body = infer_ty [%here] body in
        ignore @@ unify (fix bool_type) (getty body);
        Instr_Assert { body; attrib }
    | Instr_Assign { al = ls; attrib } ->
        let ls = List.map (fun (l, r) -> (l, infer_ty [%here] r)) ls in
        List.iter
          (fun (l, r) ->
            ignore
            @@ unify (infer ~univ [%here] (Expr.BasilExpr.rvar l) ctx) (getty r))
          ls;
        Instr_Assign { al = ls; attrib }
    | Instr_Call { lhs; procid; args; attrib } ->
        let p = Program.proc p procid in
        let infer_param p =
          infer ~univ:(V.proc_univ procid) [%here] (Expr.BasilExpr.rvar p) ctx
        in
        let args = StringMap.mapi (fun param a -> infer_ty [%here] a) args in
        StringMap.iter
          (fun parm act ->
            let form =
              infer_param (StringMap.find parm (Procedure.formal_in_params p))
            in
            ignore @@ unify form (getty act))
          args;
        lhs
        |> StringMap.map (fun a -> infer_ty [%here] (Expr.BasilExpr.rvar a))
        |> StringMap.iter (fun param act ->
            let form =
              infer_param (StringMap.find param @@ Procedure.formal_out_params p)
            in
            ignore @@ unify form (getty act));
        Instr_Call { lhs; procid; args; attrib }
    | Instr_IndirectCall { target; attrib } ->
        let target = infer_ty [%here] target in
        ignore @@ unify (getty target) (fix ptr_typ);
        Instr_IndirectCall { target; attrib }
    | Instr_Load { lhs; rhs; addr = Scalar; attrib } ->
        let lhs' = infer_ty [%here] (Expr.BasilExpr.rvar lhs) in
        let rhs' = infer_ty [%here] (Expr.BasilExpr.rvar rhs) in
        let _ = unify (getty lhs') (getty rhs') in
        Instr_Load { lhs; rhs; addr = Scalar; attrib }
    | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib } ->
        let addr = infer_ty [%here] addr in
        let _ = unify (fix @@ ptr_typ) (getty addr) in
        let mapt = fix @@ fun_type (getty addr) (fresh_tvar ()) in
        let _ = unify (lookup_var_typ univ ctx rhs) mapt in
        let _ =
          unify
            (infer_ty [%here] (Expr.BasilExpr.rvar lhs) |> getty)
            (fix @@ bv_type size)
        in
        Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib }
    | Instr_Store { lhs; rhs; value; addr = Scalar; attrib } ->
        let value = infer_ty [%here] value in
        let _ =
          unify (getty value)
          @@ unify
               (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx)
               (infer ~univ [%here] (Expr.BasilExpr.rvar rhs) ctx)
        in
        Instr_Store { lhs; rhs; value; addr = Scalar; attrib }
    | Instr_Store
        { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib } ->
        let addr = infer_ty [%here] addr in
        let _ = unify (fix @@ ptr_typ) (getty addr) in
        let mapt = fix @@ fun_type (getty addr) (fresh_tvar ()) in
        let _ =
          unify mapt (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx)
        in
        let _ = unify (lookup_var_typ univ ctx rhs) mapt in
        let value = infer_ty [%here] value in
        let _ = unify (getty value) (fix @@ bv_type size) in
        Instr_Store
          { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib }

  let elaborate_stmt p univ ctx stmt =
    let retype_var v =
      let typ =
        lookup_var_typ ~no_constraint:true univ ctx v |> find |> to_basil
      in
      Var.copy ~typ v
    in
    Stmt.map
      ~f_expr:(fun e -> elaborate ~univ [%here] e ctx)
      ~f_lvar:retype_var ~f_rvar:retype_var

  let infer_stmt p univ ctx s =
    try do_infer_stmt p univ ctx s
    with TypeErr m ->
      raise
        (TypeErr
           (m ^ " "
           ^ Stmt.to_string Var.pretty Var.pretty Expr.BasilExpr.pretty s))

  let infer_block p univ ctx (b : Program.bloc) =
    let _ = infer_phi univ ctx b.phis in
    Block.map ~phi:Fun.id (infer_stmt p univ ctx) b

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
    let p =
      Procedure.iter_blocks_topo_fwd p
      |> Iter.map (fun (i, b) -> (i, infer_block prog univ ctx b))
      |> Iter.persistent
    in
    print_endline univ;
    print_endline @@ ctx_to_string ctx;
    (p, ctx)
end

module T = TypeInference (TypeExpr.Make ())
