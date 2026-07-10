open Common
open UnionFind
open Abstract_expr

(** Hindley-Milner type inference based on a union-find. *)

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

  (* bitvector of unknown width  *)
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

  (** Return the generic type scheme for an op. We generalise the type, and hope
      dearly that a concrete type is found by inference.

      TODO: some approach like weak type variables that makes it a type error to
      fail to instantiate. *)
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

  (** return the generic type scheme of an intrinsic operation *)
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

  (** An AbstractExpr.t with [t] used as the type. *)
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

  let infer_var univ ctx id =
    let typ = lookup_var_typ univ ctx id in
    (id, typ)

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

  let types_universe = "<types>"
  let global_universe = "<global>"

  (* declare type with name in type scheme *)
  let decl_type ctx name vt =
    let tvar = V.create types_universe name in
    TCtx.update tvar
      (function
        | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
        | None -> Some (Forall ([], vt))
        | _ -> failwith "unk")
      ctx

  (* declare var with type in type scheme *)
  let decl_var_typ univ ?(no_constraint = false) c v =
    let vvar = V.of_var univ v in
    let vt = inst_annot_v v in
    TCtx.update vvar
      (function
        | Some (Forall ([], t)) -> Some (Forall ([], unify vt t))
        | None -> Some (Forall ([], vt))
        | _ -> failwith "unk")
      c

  let rec infer_expr ~univ (hr : Lexing.position) e =
   fun (c : scheme TCtx.t) ->
    Logs.debug (fun m ->
        m "%s" @@ "infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
    let t =
      try do_infer infer_expr univ hr e c
      with TypeErr m ->
        raise (TypeErr (m ^ " : " ^ Expr.BasilExpr.to_string e))
    in
    t

  let infer ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
    infer_expr ~univ hr e c |> AbsTypingExpr.unfix |> AbstractExpr.get_typ

  let retype_var univ ctx id =
    lookup_var_typ ~no_constraint:true univ ctx id |> find |> to_basil
    |> fun typ -> Var.copy ~typ id

  (** Extract type after full inference has run. *)
  let elaborate_expr ~univ (hr : Lexing.position) e (c : scheme TCtx.t) =
    let alg e =
      let e =
        match e with
        | AbstractExpr.RVar { id; attrib; typ } ->
            (* FIXME: bad to have two type annotations *)
            let id = retype_var univ c id in
            AbstractExpr.RVar { id; attrib; typ }
        | o -> o
      in
      let t = AbstractExpr.get_typ e |> find |> to_basil in
      AbstractExpr.set_typ e t |> Expr.BasilExpr.fix
    in
    e |> TypingExpr.cata alg

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

  let elaborate_phi univ ctx (p : Var.t Block.phi list) =
    let open Block in
    List.map
      (fun { lhs; rhs } ->
        let lhs = retype_var univ ctx lhs in
        let rhs = List.map (fun (a, r) -> (a, retype_var univ ctx r)) rhs in
        { lhs; rhs })
      p

  let ctx_to_string ctx =
    TCtx.to_iter ctx
    |> Iter.to_string (fun (a, b) ->
        Printf.sprintf "%s %s" (V.to_string a) (scheme_to_string b))

  let fresh_tvar ?(n = "a") () = fix @@ Var (gen.fresh ~name:n ())

  let do_infer_stmt p univ ctx stmt =
    let open Stmt in
    let infer_ty h e = infer_expr ~univ h e ctx in

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

  let elaborate_block p univ ctx (b : ('a, 'b) Block.t) =
    Block.map ~phi:(elaborate_phi univ ctx) (elaborate_stmt univ ctx) b

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
    let spec = Procedure.specification p in
    let univ = V.proc_univ @@ Procedure.id p in
    let ibool_list b =
      List.map
        (fun a ->
          let a = infer_expr ~univ [%here] a ctx in
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
      |> Iter.map (fun (i, b) -> (i, infer_block prog univ ctx b))
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
  let infer_decl prog scheme =
    let open Program in
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
              let nb scheme =
                Function
                  {
                    attrib;
                    binding = binding scheme;
                    definition =
                      Axiom
                        (elaborate_expr ~univ:global_universe [%here] b scheme);
                  }
              in
              (scheme, `Decl (decl_id, nb))
          | Uninterpreted ->
              let nu s =
                Function
                  { binding = binding s; attrib; definition = Uninterpreted }
              in
              (scheme, `Decl (decl_id, nu))
          | Function definition ->
              let e =
                infer_expr ~univ:global_universe [%here] definition scheme
              in
              let ne scheme =
                Function
                  {
                    binding = binding scheme;
                    attrib;
                    definition =
                      Function
                        (elaborate_expr ~univ:global_universe [%here] e scheme);
                  }
              in
              (scheme, `Decl (decl_id, ne)))
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
          let nb fscheme =
            Variable
              {
                binding = binding fscheme;
                attrib;
                classification = classification fscheme;
              }
          in
          (scheme, `Decl (decl_id, nb))
      | Procedure { definition } ->
          let elaborate_proc, scheme = infer_proc prog scheme definition in
          (scheme, `Procedure (decl_id, elaborate_proc))

  (** The function that does everything *)
  let infer_program prog =
    let decls = Program.declarations prog |> Iter.to_list in
    (* We fold the inference context through every declaration and
    calling the inference functions, returning an expressions typed with the
    type expressions herein.  We also return the resulting list of elaboration
    functions, which take the final inference context and convert the HM-typed
    expressions back to bincaml typed expressions. *)
    let scheme, new_decls =
      decls |> List.fold_map (infer_decl prog) TCtx.empty
    in
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

  (**let elaborate_program prog (scheme,new_decls) = *)
end

module T = TypeInference (TypeExpr.Make ())

module type HM = module type of TypeInference (TypeExpr.Make ())

(* in order to  maintain well-typedness of rewrites we will probably want to
 inject the  global type definitions into the program, always. Otherwise we
 probably risk inferring inconsistent types. Maybe this goes for for all the
 global bindings. I.e. if we use a definition incorrectly it will end up
 ill-typed and that error will be harder to track down. Injecting all the
 bindings is somewhat giving up though. We could justifiably just require
 transforms to "know what they are doing" and inject enough type information for
 it to be well-typed coming out.  Mistakes could be found by running a global
 program typecheck after the transform. *)

(** Algebra that infers types of expressions *)
let locally_elaborate_expr (e : Expr.BasilExpr.t) =
  let open AbstractExpr in
  let open Ops.AllOps in
  let module T = TypeInference (TypeExpr.Make ()) in
  (* TODO: need mode where we absorb take the existing annotations and try to
  extend , rather than expecting everythign declared in context. *)
  let i = T.infer_expr ~univ:"expr local" [%here] e TypeExpr.TCtx.empty in
  let e = T.elaborate_expr ~univ:"expr local" [%here] i TypeExpr.TCtx.empty in
  e

(** Algebra for returning the annotated type (for use with functions like
    fold_with_type)*)
let elaborated_type_alg (e : Types.t Expr.BasilExpr.abstract_expr) =
  Expr.AbstractExpr.get_typ e

(* Partially apply args list to function type funtype and return resulting type *)
let type_applied (funtype : Types.t) (args : Types.t list) =
  let module T = TypeInference (TypeExpr.Make ()) in
  let rt = T.fresh_tvar ~n:"ret" () in
  let args = List.map T.ty_of_basil args in
  let funt = T.curry_f args rt in
  let ft = T.ty_of_basil funtype in
  try
    T.unify ~pos:[%here] ft funt |> ignore;
    Ok (T.to_basil rt)
  with T.TypeErr e -> Error e

let elaborate prog =
  (* We need to create a local typing module in order to get fresh state for the
  union find and hash cons. *)
  let module T = TypeInference (TypeExpr.Make ()) in
  let scheme, prog = T.infer_program prog in
  prog

let%expect_test "return type of function" =
  let open Types in
  let args = [ Bitvector 64 ] in
  let ft = Map (Bitvector 64, Map (Bitvector 64, Bitvector 64)) in
  Printf.printf "function type: %s\n" (Types.to_string ft);
  let _, ort = Types.uncurry ft in
  Printf.printf "uncurry ret type: %s\n" (Types.to_string ort);
  Format.force_newline ();
  Format.printf "%s%a%a" "partially apply bv64: " (Result.pp Types.pp)
    (type_applied ft args) Format.newline ();
  Format.printf "%s%a%a" "type error: " (Result.pp Types.pp)
    (type_applied ft [ Bitvector 24 ])
    Format.newline ();
  [%expect
    {|
    function type: ((bv64)->(bv64->bv64))
    uncurry ret type: bv64

    partially apply bv64: ok((bv64->bv64))
    type error: error(type_error: 64 <> 24)
    |}]
