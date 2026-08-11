open Bincaml_util.Common
open Lang

module Builtins = struct
  type t =
    | Function of string
    | Infix of string
    | Prefix of string
    | Postfix of string
    | Unsup

  type builtin =
    [ `BVAND
    | `BVOR
    | `BVADD
    | `BVMUL
    | `BVUDIV
    | `BVUREM
    | `BVSHL
    | `BVLSHR
    | `BVNAND
    | `BVXOR
    | `BVSUB
    | `BVSDIV
    | `BVSREM
    | `BVSMOD
    | `BVASHR
    | `BVULT
    | `BVULE
    | `BVSLT
    | `BVSLE
    | `BVNOT
    | `BVNEG
    | `ZeroExtend of int
    | `Load of Ops.Maps.endian * int
    | `SignExtend of int ]
  (** Subset of binary/unary/intrinsic ops which have builtins. (":builtin X" in
      boogie) *)

  (** Returns the boogie builtin name for an op *)
  let builtin_name (op : builtin) =
    match op with
    | `BVAND -> "bvand"
    | `BVOR -> "bvor"
    | `BVADD -> "bvadd"
    | `BVMUL -> "bvmul"
    | `BVUDIV -> "bvudiv"
    | `BVUREM -> "bvurem"
    | `BVSHL -> "bvshl"
    | `BVLSHR -> "bvlshr"
    | `BVNAND -> "bvnand"
    | `BVXOR -> "bvxor"
    | `BVSUB -> "bvsub"
    | `BVSDIV -> "bvsdiv"
    | `BVSREM -> "bvsrem"
    | `BVSMOD -> "bvsmod"
    | `BVASHR -> "bvashr"
    | `BVULT -> "bvult"
    | `BVULE -> "bvule"
    | `BVSLT -> "bvslt"
    | `BVSLE -> "bvsle"
    | `BVNOT -> "bvnot"
    | `BVNEG -> "bvneg"
    | `ZeroExtend sz -> Printf.sprintf "zero_extend %d" sz
    | `SignExtend sz -> Printf.sprintf "sign_extend %d" sz
    | `Load (`Big, i) -> Printf.sprintf "load%d_be" i
    | `Load (`Little, i) -> Printf.sprintf "load%d_le" i

  (** Returns the monomorphized builtin name *)
  let monomorphize_builtin (op : builtin) targs =
    match op with
    | _ ->
        let args = String.concat "_" (List.map Types.to_string targs) in
        Printf.sprintf "%s_%s"
          (String.replace ~sub:" " ~by:"_" (builtin_name op))
          args

  let name
      (op :
        [< Ops.AllOps.binary | Ops.AllOps.unary | Ops.AllOps.intrin | builtin ])
      args =
    match op with
    | (`BVADD | `BVAND | `BVNOT | `BVNEG | `BVMUL | `BVOR) as op ->
        Function (monomorphize_builtin op (List.take 1 args))
    | #builtin as op -> Function (monomorphize_builtin op args)
    | `EQ -> Infix "=="
    | `NEQ -> Infix "!="
    | `INTADD -> Infix "+"
    | `INTMUL -> Infix "*"
    | `INTSUB -> Infix "-"
    | `INTDIV -> Infix "/"
    | `INTMOD -> Infix "%"
    | `INTLT -> Infix "<"
    | `INTLE -> Infix "<="
    | `INTNEG -> Prefix "-"
    | `BVConcat -> Infix "++"
    | `IMPLIES -> Infix "==>"
    | `ReadField s -> Postfix (Printf.sprintf "->%s" s)
    | `Extract (hi, lo) -> Postfix (Printf.sprintf "[%d:%d]" hi lo)
    | `BOOLTOBV1 -> Function "bool_to_bv1"
    | #Ops.AllOps.binary | #Ops.AllOps.unary | #Ops.AllOps.intrin -> Unsup

  let visit_expr_ops f (e : Types.t Expr.BasilExpr.abstract_expr) =
    let open Expr.AbstractExpr in
    let open Ops.AllOps in
    let get_ty (op : [ const | unary | binary | intrin | lambda ]) o =
      match o with
      | Fun { ret; args } ->
          f (op, args, ret);
          ret
      | _ -> failwith "Conflict"
    in
    match e with
    | RVar { id; _ } -> Var.typ id
    | Constant { const = #const as op; _ } -> ret_type_const op |> get_ty op
    | UnaryExpr { op = #unary as op; arg; _ } ->
        ret_type_unary op arg |> get_ty op
    | BinaryExpr { op = #binary as op; arg1 = l; arg2 = r; _ } ->
        ret_type_bin op l r |> get_ty op
    | ApplyIntrin { op = #intrin as op; args; _ } ->
        ret_type_intrin op args |> get_ty op
    | ApplyFun { func; _ } ->
        let _, rt = Types.uncurry func in
        rt
    | Lambda { op = #lambda as op; bound_vars; in_body; _ } ->
        ret_type_lambda op (List.map Var.typ bound_vars) in_body |> get_ty op
    | Let _ -> failwith "unsupported: prepass remove"

  let iexpr f e = Expr.BasilExpr.cata (visit_expr_ops f) e |> ignore

  let istmt f (s : Program.stmt) =
    Stmt.iter_rexpr s (function `Expr e -> iexpr f e | _ -> ())

  let iprog f (p : Program.t) =
    Program.procs p |> Iter.map snd
    |> Iter.flat_map Procedure.iter_stmt_topo_fwd
    |> Iter.iter (istmt f);
    Program.declarations p |> Iter.map snd
    |> Iter.iter (function
      | Program.Function { definition = Axiom e } -> (iexpr f) e
      | Program.Function { definition = Function e } -> (iexpr f) e
      | _ -> ());
    Program.procs p |> Iter.map snd
    |> Iter.iter (fun v ->
        let spec = Procedure.specification v in
        List.iter (iexpr f) spec.requires;
        List.iter (iexpr f) spec.ensures;
        List.iter (iexpr f) spec.rely;
        List.iter (iexpr f) spec.guarantee);
    let s = Program.spec p in
    s.rely |> List.iter (iexpr f);
    s.guarantee |> List.iter (iexpr f)

  let function_for_op op args ret =
    Var.create ~scope:Var.GlobalConst
      (match name op (args @ [ ret ]) with
      | Function s -> s
      | _ -> failwith "unexpected")
      (Types.curry args ret)

  let transform_op_to_decl op args ret =
    let boogie_attribs =
      StringMap.of_list
        [
          (".extern", `List []);
          (".bvbuiltin", `List [ `String (builtin_name op) ]);
        ]
    in
    let attribs = StringMap.of_list [ (".boogie", `Assoc boogie_attribs) ] in
    Some
      (Function
         {
           attrib = attribs;
           binding = function_for_op op args ret;
           definition = Uninterpreted;
         }
        : Program.declaration)

  let used_ops (p : Program.t) =
    Iter.from_iter (fun f -> iprog f p) |> Iter.sort_uniq

  let transform_add_builtin_decls (p : Program.t) : Program.t =
    used_ops p
    |> Iter.filter_map (function op, args, ret ->
        (match op with
        | `Load _ -> None
        | #builtin as op -> transform_op_to_decl op args ret
        | _ -> None))
    |> Iter.to_list
    |> List.fold_left Program.add_decl p
end

module Instructions = struct
  let unique_stores_loads (prog : Program.t) =
    let visit_procs proc = Procedure.iter_stmt_topo_fwd proc in
    let load_exprs : (Var.t, Var.t, Program.e) Stmt.t Iter.t =
      Builtins.used_ops prog
      |> Iter.filter_map (function op, args, ret ->
          (match op with
          | `Load (endian, size) ->
              let lhs = Var.create "" ret in
              let rhs = Var.create "" (List.hd args) in
              let addr =
                Expr.BasilExpr.rvar @@ Var.create "" (List.hd @@ List.tl args)
              in
              Some
                (Stmt.Instr_Load
                   {
                     lhs;
                     rhs;
                     addr = Addr { addr; size; endian };
                     attrib = Attrib.empty;
                   })
          | _ -> None))
    in
    let procs = Program.procs prog |> Iter.map snd in
    procs |> Iter.flat_map visit_procs |> Iter.append load_exprs
    |> Iter.filter (function
      | Stmt.Instr_Store { lhs; rhs; value; addr = Scalar } -> true
      | Stmt.Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } }
        ->
          true
      | Stmt.Instr_Load { lhs; rhs; addr = Scalar } -> true
      | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } -> true
      | _ -> false)
    |> Iter.sort_uniq

  let store_body ?(be = false) mem_typ val_size addr_size =
    let memory = Var.create ~scope:Var.LocalVar "#memory" mem_typ in
    let value =
      Var.create ~scope:Var.LocalVar "#value" (Types.Bitvector val_size)
    in
    let index =
      Var.create ~scope:Var.LocalVar "#index" (Types.Bitvector addr_size)
    in
    (* TODO: maybe generalize to non 8 bit stores, based on mem typ value? *)
    let steps = val_size / 8 in
    let body =
      List.range 0 (steps - 1)
      |> List.fold_left
           (fun acc i ->
             Expr.BasilExpr.applyintrin ~op:`MapUpdate
               [
                 acc;
                 (if Stdlib.( == ) i 0 then Expr.BasilExpr.rvar index
                  else
                    Expr.BasilExpr.binexp ~op:`BVADD
                      (Expr.BasilExpr.rvar index)
                      (Expr.BasilExpr.bvconst (Bitvec.of_int ~size:addr_size i)));
                 Expr.BasilExpr.extract
                   ~hi_excl:
                     (if be then ((val_size / 8) - i) * 8 else (i + 1) * 8)
                   ~lo_incl:(if be then ((val_size / 8) - i - 1) * 8 else i * 8)
                   (Expr.BasilExpr.rvar value);
               ])
           (Expr.BasilExpr.rvar memory)
    in
    Expr.BasilExpr.lambda ~bound:[ memory; index; value ] body

  let load_body ?(be = false) mem_typ val_size addr_size =
    let memory = Var.create ~scope:Var.LocalVar "#memory" mem_typ in
    let index =
      Var.create ~scope:Var.LocalVar "#index" (Types.Bitvector addr_size)
    in
    let steps = val_size / 8 in
    let body =
      (if be then List.range 0 (steps - 1) else List.range (steps - 1) 0)
      |> List.tl
      |> List.fold_left
           (fun acc i ->
             Expr.BasilExpr.applyintrin ~op:`BVConcat
               [
                 acc;
                 Expr.BasilExpr.binexp ~op:`MapAccess
                   (Expr.BasilExpr.rvar memory)
                   (Expr.BasilExpr.binexp ~op:`BVADD
                      (Expr.BasilExpr.rvar index)
                      (Expr.BasilExpr.bvconst (Bitvec.of_int ~size:addr_size i)));
               ])
           (Expr.BasilExpr.binexp ~op:`MapAccess
              (Expr.BasilExpr.rvar memory)
              (Expr.BasilExpr.binexp ~op:`BVADD
                 (Expr.BasilExpr.rvar index)
                 (Expr.BasilExpr.bvconst
                    (Bitvec.of_int ~size:addr_size
                       (if be then 0 else steps - 1)))))
    in
    Expr.BasilExpr.lambda ~bound:[ memory; index ] body

  let store_load_decl (s : Program.stmt) =
    match s with
    | Stmt.Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } }
      ->
        let boogie_attribs =
          StringMap.of_list [ (".extern", `List []); (".define", `List []) ]
        in
        let attribs = StringMap.singleton ".boogie" (`Assoc boogie_attribs) in
        let body =
          store_body (Var.typ rhs)
            (match Expr.BasilExpr.type_of value with
            | Types.Bitvector s -> s
            | _ -> failwith "Expected bitvec type")
            (match Expr.BasilExpr.type_of addr with
            | Types.Bitvector s -> s
            | _ -> failwith "Expected bitvec type")
        in
        Some
          (Function
             {
               attrib = attribs;
               binding =
                 Var.create ~scope:Var.GlobalConst
                   (Printf.sprintf "store%d_%s" size
                      (Lang.Stmt.show_endian endian))
                   (Lang.Expr.BasilExpr.type_of value);
               definition = Lang.Program.Function body;
             }
            : Program.declaration)
    | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
        let boogie_attribs = StringMap.of_list [ (".extern", `List []) ] in
        let attribs =
          StringMap.of_list [ (".boogie", `Assoc boogie_attribs) ]
        in
        let body =
          load_body (Var.typ rhs)
            (match Var.typ lhs with
            | Types.Bitvector s -> s
            | _ -> failwith "Expected bitvec type")
            (match Lang.Expr.BasilExpr.type_of addr with
            | Types.Bitvector s -> s
            | _ -> failwith "Expected bitvec type")
        in
        Some
          (Function
             {
               attrib = attribs;
               binding =
                 Var.create ~scope:Var.GlobalConst
                   (Printf.sprintf "load%d_%s" size (Stmt.show_endian endian))
                   (Var.typ lhs);
               definition = Function body;
             }
            : Program.declaration)
    | _ -> None

  let transform_add_store_load_decls (prog : Program.t) =
    unique_stores_loads prog
    |> Iter.filter_map store_load_decl
    |> Iter.fold Program.add_decl prog
end

module Normalise = struct
  open Lang
  open Abstract_expr.AbstractExpr
  open BasilExpr
  open Expr_rewrite

  let replace_expr (e : BasilExpr.t BasilExpr.abstract_expr) =
    let normalise_intrinsic op base args =
      match args with
      | [] -> base
      | h :: tl ->
          List.fold_left (fun a b -> BasilExpr.applyintrin ~op [ a; b ]) h tl
    in

    let rec apply_fun_to_map base args =
      match args with
      | [] -> base
      | h :: tl -> BasilExpr.binexp ~op:`MapAccess (apply_fun_to_map base tl) h
    in

    match e with
    (* function application in boogie becomes a map access when on lambdas (identified by local vars) *)
    | ApplyFun { func; args } -> (
        match unfix func with
        | RVar { attrib; id } when Var.is_global id ->
            replace [%here]
              (BasilExpr.apply_fun ~attrib
                 ~func:
                   (BasilExpr.rvar ~attrib (Var.copy ~name:(Var.name id) id))
                 args)
        | _ -> replace [%here] (apply_fun_to_map func args))
    | ApplyIntrin { op = `AND; args } ->
        replace [%here]
          ((normalise_intrinsic `AND (BasilExpr.boolconst true)) args)
    | ApplyIntrin { op = `OR; args } ->
        replace [%here]
          ((normalise_intrinsic `OR (BasilExpr.boolconst false)) args)
    | ApplyIntrin { op = (`BVOR | `BVADD | `BVConcat | `BVXOR) as op; args } ->
        replace [%here]
          (normalise_intrinsic op
             (BasilExpr.bvconst (Bitvec.zero ~size:0))
             args)
    | ApplyIntrin { op = (`BVAND | `BVMUL) as op; args } ->
        replace [%here]
          (normalise_intrinsic op
             (BasilExpr.bvconst (Bitvec.ones ~size:0))
             args)
    | _ -> Keep

  open Stmt

  let replace_stmt (s : Program.stmt) =
    match s with
    | Instr_IndirectCall { attrib } ->
        Instr_Assert
          {
            body = BasilExpr.boolconst false;
            attrib = StringMap.add "comment" (`String "indirect call") attrib;
          }
    | Instr_Load { lhs; rhs; addr = Scalar; attrib } ->
        Instr_Assign { al = [ (lhs, BasilExpr.rvar rhs) ]; attrib }
    | Instr_Store { lhs; value; addr = Scalar; attrib } ->
        Instr_Assign { al = [ (lhs, value) ]; attrib }
    | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib } ->
        let fn_name =
          Printf.sprintf "load%d_%s" size (Stmt.show_endian endian)
        in
        Instr_Assign
          {
            al =
              [
                ( lhs,
                  Expr.BasilExpr.fapply
                    (Expr.BasilExpr.rvar
                       (Var.create ~scope:Var.GlobalConst fn_name (Var.typ lhs)))
                    [ Expr.BasilExpr.rvar rhs; addr ] );
              ];
            attrib;
          }
    | Instr_Store
        { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib } ->
        let fn_name =
          Printf.sprintf "store%d_%s" size (Stmt.show_endian endian)
        in
        Stmt.Instr_Assign
          {
            al =
              [
                ( lhs,
                  Expr.BasilExpr.fapply
                    (Expr.BasilExpr.rvar
                       (Var.create ~scope:Var.GlobalConst fn_name (Var.typ lhs)))
                    [ Expr.BasilExpr.rvar rhs; addr; value ] );
              ];
            attrib;
          }
    | o -> o

  let rewriter = Expr_rewrite.rewrite ~err_to_string:Expr_pretty.to_string ~rw_fun:replace_expr

  let replace_exprs =
    (* have to inline let because rewriter converts to map access *)
    Cf_tx.simplify_prog_spec_exprs Algsimp.inline_let
    %> Cf_tx.simplify_prog_exprs Algsimp.inline_let
    %> Cf_tx.simplify_prog_spec_exprs rewriter
    %> Cf_tx.simplify_prog_exprs rewriter

  let replace_functions (p : Program.t) =
    let open Program in
    let prog =
      Program.flat_map_decls
        (fun k -> function
          | Function { binding; attrib; definition } -> (
              let keep =
                Iter.singleton (Function { binding; attrib; definition })
              in
              match definition with
              | Function b -> (
                  match BasilExpr.unfix b with
                  | Lambda { bound_vars; in_body } -> keep
                  | body ->
                      let axiom_name =
                        Program.declare_name_exn (ID.name k ^ "_funvalue") p
                      in
                      Iter.doubleton
                        (Function
                           { binding; definition = Uninterpreted; attrib })
                        (Function
                           {
                             binding =
                               Var.copy ~name:(ID.name axiom_name) binding;
                             definition =
                               Axiom
                                 (BasilExpr.binexp ~op:`EQ
                                    (BasilExpr.rvar binding)
                                    (BasilExpr.fix body));
                             attrib;
                           }))
              | o -> keep)
          | e -> Iter.singleton e)
        p
    in
    prog

  let replace_stmts (p : Program.t) =
    Program.map_procedures
      (fun _ p ->
        Procedure.map_blocks_nondet
          (fun (id, b) -> Block.map ~phi:Fun.id replace_stmt b)
          p)
      p
end

let transform (p : Program.t) =
  p |> Normalise.replace_functions |> Normalise.replace_exprs
  |> Instructions.transform_add_store_load_decls |> Normalise.replace_stmts
  |> Builtins.transform_add_builtin_decls
