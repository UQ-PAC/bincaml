open Common
open Abstract_expr
open Hm_types
open Unification
open Solve_bv

(** Hindley-Milner type inference based on a union-find. *)

(** An AbstractExpr.t with [t] used as the type. *)
module AbsTypingExpr = struct
  open Ops.AllOps

  type var = Var.t

  type t =
    | E of (const, Var.t, unary, binary, intrin, TypeExpr.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  let top_typ = top_t
  let fix i = E i
  let unfix i = match i with E i -> i

  type 'e expr =
    (const, Var.t, unary, binary, intrin, TypeExpr.t, 'e) AbstractExpr.t

  let rec cata (alg : 'a expr -> 'a) e =
    (unfix %> AbstractExpr.map (cata alg) %> alg) e
end

let getty = AbsTypingExpr.unfix %> Expr.AbstractExpr.get_typ

let infer_var st univ ctx id =
  let typ = lookup_var_typ st univ ctx id in
  (id, typ)

(** Return the generic type scheme for an op. We generalise the type, and hope
    dearly that a concrete type is found by inference.

    TODO: some approach like weak type variables that makes it a type error to
    fail to instantiate. *)
let scheme_of_op st ~visit_constraint (gen : ID.generator)
    (o : [ Ops.AllOps.const | Ops.AllOps.unary | Ops.AllOps.binary ]) =
  let open (val Hm_types.smart_constructors st) in
  let fv () = TypeExpr.fix st @@ Var (gen.fresh ~name:"a" ()) in
  match o with
  | `Extract (hi, lo) -> curry_f [ bvunk (fv ()) ] (bv_type (hi - lo))
  | `SignExtend bits ->
      let a = fv () in
      let equ = fv () in
      let r = curry_f [ bvunk a ] (bvunk equ) in
      visit_constraint @@ AddConst { a; b = bits; equ };
      r
  | `ZeroExtend bits ->
      let a = fv () and equ = fv () in
      visit_constraint @@ AddConst { a; b = bits; equ };
      curry_f [ bvunk a ] (bvunk equ)
  | `BOOLTOBV1 -> curry_f [ bool_type ] (bv_type 1)
  | `Bitvector b -> bv_type (Bitvec.size b)
  | #Ops.BVOps.binary_unif ->
      let a = fv () in
      curry_f [ bvunk a; bvunk a ] (bvunk a)
  | #Ops.BVOps.binary_pred ->
      let a = fv () in
      curry_f [ bvunk a; bvunk a ] bool_type
  | #Ops.BVOps.unary_unif ->
      let a = fv () in
      curry_f [ bvunk a ] (bvunk a)
  | `INTNEG -> curry_f [ int_type ] int_type
  | #Ops.IntOps.binary_pred -> curry_f [ int_type; int_type ] bool_type
  | #Ops.IntOps.const -> int_type
  | #Ops.IntOps.binary_unif -> curry_f [ int_type; int_type ] int_type
  | #Ops.LogicalOps.binary -> curry_f [ bool_type; bool_type ] bool_type
  | #Ops.LogicalOps.unary -> curry_f [ bool_type ] bool_type
  | #Ops.LogicalOps.const -> bool_type
  | `Old ->
      let a = fv () in
      curry_f [ a ] a
  | #Ops.AllOps.binary as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o
  | #Ops.AllOps.unary as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o
  | #Ops.AllOps.const as o ->
      failwith @@ "unsupported op" ^ Ops.AllOps.to_string o

(** return the generic type scheme of an intrinsic operation *)
let scheme_of_intrin st ?(visit_constraint = fun a -> ()) (gen : ID.generator)
    (o : Ops.AllOps.intrin) args =
  let fv () = TypeExpr.fix st @@ Var (gen.fresh ~name:"a" ()) in
  match o with
  | `BVADD | `BVMUL | `BVOR | `BVXOR | `BVAND ->
      let a = fv () in
      curry_f st (List.init args (fun _ -> a)) a
  | `BVConcat ->
      let args = List.init args (fun _ -> fv ()) in
      let rs =
        List.reduce_exn
          (fun a b ->
            let equ = fv () in
            visit_constraint (Add { a; b; equ });
            equ)
          args
      in
      let rs = bvunk st rs in
      let args = List.map (bvunk st) args in
      curry_f st args rs
  | `OR | `AND ->
      curry_f st (List.init args (fun _ -> bool_type st)) (bool_type st)
  | `MapUpdate ->
      let a = fv () in
      let b = fv () in
      let m = curry_f st [ a ] b in
      curry_f st [ m; a; b ] m
  | `Cases -> fv ()
  | `IfThen -> fv ()

let do_infer st ~visit_constraint
    (infer :
      univ:string ->
      Lexing.position ->
      Program.e ->
      scheme TypeExpr.TCtx.t ->
      AbsTypingExpr.t) univ hr e c : AbsTypingExpr.t =
  let unify = Unification.unify st
  and curry_f = Hm_types.curry_f st
  and scheme_of_op = scheme_of_op st
  and scheme_of_intrin = scheme_of_intrin st
  and gen = st.gen in

  let mkv v = TypeExpr.V.of_var univ v in
  let r = TypeExpr.fix st @@ Var (st.gen.fresh ()) in
  let open Abstract_expr.AbstractExpr in
  let e = Expr.BasilExpr.unfix e in
  let e = set_typ e r in
  match e with
  | RVar { id; attrib } ->
      let typ = lookup_var_typ st univ c id in
      AbsTypingExpr.fix (RVar { attrib; id; typ })
  | Lambda { op; bound_vars; in_body; attrib; triggers } -> begin
      let tvars = List.map (fun v -> (v, inst_annot_v st v)) bound_vars in
      let ictx =
        List.map (fun (v, t) -> (mkv v, Forall ([], t))) tvars
        |> TypeExpr.TCtx.add_list c
      in
      let bdty = infer ~univ [%here] in_body ictx in
      let typ =
        match op with
        | `Lambda -> getty bdty
        | `Forall | `Exists -> unify (getty bdty) (bool_type st)
      in
      ignore @@ unify r (curry_f (List.map snd tvars) (getty bdty));
      let triggers =
        List.map (List.map (fun e -> infer ~univ [%here] e ictx)) triggers
      in
      AbsTypingExpr.fix
        (Lambda { op; bound_vars; in_body = bdty; attrib; typ; triggers })
    end
  | Constant { const = #Ops.AllOps.const as op; attrib } -> begin
      let f = scheme_of_op ~visit_constraint gen op in
      let r = unify r f in
      AbsTypingExpr.fix (Constant { typ = r; const = op; attrib })
    end
  | UnaryExpr { op = #Ops.AllOps.unary as op; arg; attrib } -> begin
      let f = scheme_of_op ~visit_constraint gen op in
      let arg = infer ~univ [%here] arg c in
      ignore @@ unify f (curry_f [ getty arg ] r);
      AbsTypingExpr.fix (UnaryExpr { typ = r; op; attrib; arg })
    end
  | BinaryExpr { op = #Ops.AllOps.binary as op; arg1; arg2; attrib } -> begin
      let f = scheme_of_op ~visit_constraint gen op in
      let arg1 = infer ~univ [%here] arg1 c in
      let arg2 = infer ~univ [%here] arg2 c in
      ignore @@ unify f (curry_f [ getty arg1; getty arg2 ] r);
      AbsTypingExpr.fix (BinaryExpr { typ = r; op; attrib; arg1; arg2 })
    end
  | ApplyIntrin { op = #Ops.AllOps.intrin as op; args; attrib } -> begin
      let f = scheme_of_intrin ~visit_constraint gen op (List.length args) in
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

let rec infer_expr st visit_constraint ~univ (hr : Lexing.position) e =
 fun (c : scheme TypeExpr.TCtx.t) ->
  Logs.debug (fun m ->
      m "%s" @@ "infer " ^ plpos hr ^ " " ^ Expr.BasilExpr.to_string e);
  let t =
    try
      do_infer st ~visit_constraint (infer_expr st visit_constraint) univ hr e c
    with TypeErr m -> raise (TypeErr (m ^ " : " ^ Expr.BasilExpr.to_string e))
  in
  t

let infer st visit_constraint ~univ (hr : Lexing.position) e
    (c : scheme TypeExpr.TCtx.t) =
  let nexpr =
    infer_expr st visit_constraint ~univ hr e c
    |> AbsTypingExpr.unfix |> AbstractExpr.get_typ
  in
  nexpr

let unfix i = match i with Expr.BasilExpr.E i -> i
let rec cata alg e = (unfix %> AbstractExpr.map (cata alg) %> alg) e

let infer_phi st visit_constraint univ ctx (p : Var.t Block.phi list) =
  let infer = infer st visit_constraint in
  let open Block in
  let r = TypeExpr.fix st @@ Var (st.gen.fresh ()) in
  List.fold_left
    (fun acc { lhs; rhs } ->
      let lhs = infer [%here] ~univ (Expr.BasilExpr.rvar lhs) ctx in
      let e =
        List.fold_left
          (fun a (_, r) ->
            let r = infer [%here] ~univ (Expr.BasilExpr.rvar r) ctx in
            Unification.unify st a r)
          lhs rhs
      in
      Unification.unify st acc e)
    r p

let ctx_to_string ctx =
  TypeExpr.TCtx.to_iter ctx
  |> Iter.to_string (fun (a, b) ->
      Printf.sprintf "%s %s" (TypeExpr.V.to_string a) (scheme_to_string b))

let fresh_tvar st ?(n = "a") () =
  TypeExpr.fix st @@ Var (st.gen.fresh ~name:n ())

let do_infer_stmt st visit_constraint p univ ctx stmt =
  let open Stmt in
  let infer_ty h e = infer_expr st visit_constraint ~univ h e ctx
  and infer = infer st visit_constraint
  and unify = unify st in

  (*let r = fix @@ Var (gen.fresh ()) in*)
  match stmt with
  | Instr_IntrinCall _ -> failwith "intrin unsupported"
  | Instr_Assume { body; branch; attrib } ->
      let body = infer_ty [%here] body in
      ignore @@ unify (bool_type st) (getty body);
      Instr_Assume { body; branch; attrib }
  | Instr_Assert { body; attrib } ->
      let body = infer_ty [%here] body in
      ignore @@ unify (bool_type st) (getty body);
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
        infer
          ~univ:(TypeExpr.V.proc_univ procid)
          [%here] (Expr.BasilExpr.rvar p) ctx
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
      ignore @@ unify (getty target) (ptr_typ st);
      Instr_IndirectCall { target; attrib }
  | Instr_Load { lhs; rhs; addr = Scalar; attrib } ->
      let lhs' = infer_ty [%here] (Expr.BasilExpr.rvar lhs) in
      let rhs' = infer_ty [%here] (Expr.BasilExpr.rvar rhs) in
      let _ = unify (getty lhs') (getty rhs') in
      Instr_Load { lhs; rhs; addr = Scalar; attrib }
  | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib } ->
      let addr = infer_ty [%here] addr in
      let _ = unify (ptr_typ st) (getty addr) in
      let mapt = fun_type st (getty addr) (fresh_tvar st ()) in
      let _ = unify (lookup_var_typ st univ ctx rhs) mapt in
      let _ =
        unify
          (infer_ty [%here] (Expr.BasilExpr.rvar lhs) |> getty)
          (bv_type st size)
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
  | Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib }
    ->
      let addr = infer_ty [%here] addr in
      let _ = unify (ptr_typ st) (getty addr) in
      let mapt = fun_type st (getty addr) ((fresh_tvar st) ()) in
      let _ = unify mapt (infer ~univ [%here] (Expr.BasilExpr.rvar lhs) ctx) in
      let _ = unify (lookup_var_typ st univ ctx rhs) mapt in
      let value = infer_ty [%here] value in
      let _ = unify (getty value) (bv_type st size) in
      Instr_Store
        { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib }

let infer_stmt st vc p univ ctx s =
  try do_infer_stmt st vc p univ ctx s
  with TypeErr m ->
    raise
      (TypeErr
         (m ^ " " ^ Stmt.to_string Var.pretty Var.pretty Expr.BasilExpr.pretty s))

let infer_block st vc p univ ctx (b : Program.bloc) =
  let _ = infer_phi st vc univ ctx b.phis in
  Block.map ~phi:Fun.id (infer_stmt st vc p univ ctx) b
