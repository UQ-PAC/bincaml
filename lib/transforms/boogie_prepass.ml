open Bincaml_util.Common

let function_name name =
  let name =
    if String.starts_with ~prefix:"$" name then String.concat "" [ "f"; name ]
    else name
  in
  name

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
    | `SignExtend of int
    | `Load of Lang.Ops.Maps.endian * int ]
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
    let args = String.concat "_" (List.map Types.to_string targs) in
    Printf.sprintf "%s_%s"
      (String.replace ~sub:" " ~by:"_" (builtin_name op))
      args

  let name
      (op :
        [< Lang.Ops.AllOps.binary
        | Lang.Ops.AllOps.unary
        | Lang.Ops.AllOps.intrin
        | builtin ]) args =
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
    | `Extract (hi, lo) -> Postfix (Printf.sprintf "[%d:%d]" hi lo)
    | `BOOLTOBV1 -> Function "bool_to_bv1"
    | #Lang.Ops.AllOps.binary | #Lang.Ops.AllOps.unary | #Lang.Ops.AllOps.intrin
      ->
        Unsup

  let visit_expr_ops f (e : Types.t Lang.Expr.BasilExpr.abstract_expr) =
    let open Lang.Expr.AbstractExpr in
    let open Lang.Ops.AllOps in
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

  let iexpr f e = Lang.Expr.BasilExpr.cata (visit_expr_ops f) e |> ignore

  let istmt f (s : Lang.Program.stmt) =
    Lang.Stmt.iter_rexpr s (function `Expr e -> iexpr f e | _ -> ())

  let iprog f (p : Lang.Program.t) =
    IDMap.values p.procs
    |> Iter.flat_map Lang.Procedure.iter_stmt_topo_fwd
    |> Iter.iter (istmt f);
    StringMap.values p.globals
    |> Iter.iter (function
      | Lang.Program.Function { definition = Axiom e } -> (iexpr f) e
      | Lang.Program.Function { definition = Function e } -> (iexpr f) e
      | _ -> ());
    p.procs |> IDMap.values
    |> Iter.iter (fun v ->
        let spec = Lang.Procedure.specification v in
        List.iter (iexpr f) spec.requires;
        List.iter (iexpr f) spec.ensures;
        List.iter (iexpr f) spec.rely;
        List.iter (iexpr f) spec.guarantee);
    p.spec.rely |> List.iter (iexpr f);
    p.spec.guarantee |> List.iter (iexpr f)

  let transform_op_to_decl op args ret =
    let boogie_attribs =
      StringMap.of_list
        [
          (".extern", `List []);
          ( ".bvbuiltin",
            `List [ `String (Printf.sprintf "\"%s\"" @@ builtin_name op) ] );
        ]
    in
    let attribs = StringMap.of_list [ (".boogie", `Assoc boogie_attribs) ] in
    Some
      (Function
         {
           attrib = attribs;
           binding =
             Var.create
               (match name op (args @ [ ret ]) with Function s -> s | _ -> "")
               (Types.curry args ret);
           definition = Uninterpreted;
         }
        : Lang.Program.declaration)

  let used_ops (p : Lang.Program.t) =
    Iter.from_iter (fun f -> iprog f p)
    |> Iter.sort_uniq
    |> Iter.filter_map (function op, args, ret ->
        (match op with
        | #builtin as op -> transform_op_to_decl op args ret
        | _ -> None))
    |> Iter.to_list

  let transform_add_builtin_decls (p : Lang.Program.t) : Lang.Program.t =
    used_ops p
    |> List.fold_left
         (fun acc d ->
           Lang.Program.add_decl acc
             (match d with
             | Lang.Program.Function { binding } -> Var.name binding
             | Lang.Program.Variable { binding } -> Var.name binding
             | Lang.Program.Type { binding } -> binding)
             d)
         p
end

module Instructions = struct
  let unique_stores_loads (prog : Lang.Program.t) =
    let visit_procs proc = Lang.Procedure.iter_stmt_topo_fwd proc in
    let procs = IDMap.values prog.procs in
    procs |> Iter.flat_map visit_procs
    |> Iter.filter (function
      | Lang.Stmt.Instr_Store { lhs; rhs; value; addr = Scalar } -> true
      | Lang.Stmt.Instr_Store
          { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
          true
      | Lang.Stmt.Instr_Load { lhs; rhs; addr = Scalar } -> true
      | Lang.Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
          true
      | _ -> false)
    |> Iter.sort_uniq

  let store_body ?(be = false) mem_typ val_size addr_size =
    let memory = Var.create ~scope:Var.Local "#memory" mem_typ in
    let value =
      Var.create ~scope:Var.Local "#value" (Types.Bitvector val_size)
    in
    let index =
      Var.create ~scope:Var.Local "#index" (Types.Bitvector addr_size)
    in
    (* TODO: maybe generalize to non 8 bit stores, based on mem typ value? *)
    let steps = val_size / 8 in
    let body =
      List.range 0 (steps - 1)
      |> List.fold_left
           (fun acc i ->
             Lang.Expr.BasilExpr.applyintrin ~op:`MapUpdate
               [
                 acc;
                 (if Stdlib.( == ) i 0 then Lang.Expr.BasilExpr.rvar index
                  else
                    Lang.Expr.BasilExpr.binexp ~op:`BVADD
                      (Lang.Expr.BasilExpr.rvar index)
                      (Lang.Expr.BasilExpr.bvconst
                         (Bitvec.of_int ~size:addr_size i)));
                 Lang.Expr.BasilExpr.extract
                   ~hi_excl:
                     (if be then ((val_size / 8) - i) * 8 else (i + 1) * 8)
                   ~lo_incl:(if be then ((val_size / 8) - i - 1) * 8 else i * 8)
                   (Lang.Expr.BasilExpr.rvar value);
               ])
           (Lang.Expr.BasilExpr.rvar memory)
    in
    Lang.Expr.BasilExpr.binding ~op:`Lambda [ memory; index; value ] body

  let load_body ?(be = false) mem_typ val_size addr_size =
    let memory = Var.create ~scope:Var.Local "#memory" mem_typ in
    let index =
      Var.create ~scope:Var.Local "#index" (Types.Bitvector addr_size)
    in
    let steps = val_size / 8 in
    let body =
      (if be then List.range (steps - 1) 0 else List.range 0 (steps - 1))
      |> List.tl
      |> List.fold_left
           (fun acc i ->
             Lang.Expr.BasilExpr.applyintrin ~op:`BVConcat
               [
                 acc;
                 Lang.Expr.BasilExpr.binexp ~op:`MapAccess
                   (Lang.Expr.BasilExpr.rvar memory)
                   (Lang.Expr.BasilExpr.binexp ~op:`BVADD
                      (Lang.Expr.BasilExpr.rvar index)
                      (Lang.Expr.BasilExpr.bvconst
                         (Bitvec.of_int ~size:addr_size i)));
               ])
           (Lang.Expr.BasilExpr.binexp ~op:`MapAccess
              (Lang.Expr.BasilExpr.rvar memory)
              (Lang.Expr.BasilExpr.binexp ~op:`BVADD
                 (Lang.Expr.BasilExpr.rvar index)
                 (Lang.Expr.BasilExpr.bvconst
                    (Bitvec.of_int ~size:addr_size
                       (if be then steps - 1 else 0)))))
    in
    Lang.Expr.BasilExpr.binding ~op:`Lambda [ memory; index ] body

  let store_load_decl (s : Lang.Program.stmt) =
    match s with
    | Lang.Stmt.Instr_Store
        { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
        let boogie_attribs =
          StringMap.of_list [ (".extern", `List []); (".define", `List []) ]
        in
        let attribs = StringMap.singleton ".boogie" (`Assoc boogie_attribs) in
        Some
          (Function
             {
               attrib = attribs;
               binding =
                 Var.create
                   (Printf.sprintf "store%d_%s" size
                      (Lang.Stmt.show_endian endian))
                   (Var.typ lhs);
               definition =
                 Function
                   (store_body (Var.typ rhs)
                      (match Lang.Expr.BasilExpr.type_of value with
                      | Types.Bitvector s -> s
                      | _ -> failwith "Expected bitvec type")
                      (match Lang.Expr.BasilExpr.type_of addr with
                      | Types.Bitvector s -> s
                      | _ -> failwith "Expected bitvec type"));
             }
            : Lang.Program.declaration)
    | Lang.Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
        let boogie_attribs = StringMap.of_list [ (".extern", `List []) ] in
        let attribs =
          StringMap.of_list [ (".boogie", `Assoc boogie_attribs) ]
        in
        Some
          (Function
             {
               attrib = attribs;
               binding =
                 Var.create
                   (Printf.sprintf "load%d_%s" size
                      (Lang.Stmt.show_endian endian))
                   (Var.typ lhs);
               definition =
                 Function
                   (load_body (Var.typ rhs)
                      (match Var.typ lhs with
                      | Types.Bitvector s -> s
                      | _ -> failwith "Expected bitvec type")
                      (match Lang.Expr.BasilExpr.type_of addr with
                      | Types.Bitvector s -> s
                      | _ -> failwith "Expected bitvec type"));
             }
            : Lang.Program.declaration)
    | _ -> None

  let transform_add_store_load_decls (prog : Lang.Program.t) =
    unique_stores_loads prog
    |> Iter.filter_map store_load_decl
    |> Iter.to_list
    |> List.fold_left
         (fun acc d ->
           Lang.Program.add_decl acc
             (match d with
             | Lang.Program.Function { binding } -> Var.name binding
             | Lang.Program.Variable { binding } -> Var.name binding
             | Lang.Program.Type { binding } -> binding)
             d)
         prog
end

module Normalise = struct
  open Lang
  open Expr
  open AbstractExpr
  open BasilExpr
  open Bitvec

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
        | RVar { attrib; id } when Stdlib.( == ) (Var.scope id) Var.Global ->
            replace [%here]
              (BasilExpr.apply_fun ?attrib
                 ~func:
                   (BasilExpr.rvar ?attrib
                      (Var.create
                         (function_name @@ Var.name id)
                         ~pure:(Var.pure id) ~scope:(Var.scope id) (Var.typ id)))
                 args)
        | _ -> replace [%here] (apply_fun_to_map func args))
    | ApplyIntrin { op = `AND; args } ->
        replace [%here]
          ((normalise_intrinsic `AND (BasilExpr.boolconst true)) args)
    | ApplyIntrin { op = `OR; args } ->
        replace [%here]
          ((normalise_intrinsic `OR (BasilExpr.boolconst false)) args)
    | ApplyIntrin { op = `BVConcat; args } ->
        replace [%here]
          (normalise_intrinsic `BVConcat
             (BasilExpr.bvconst (Bitvec.zero ~size:0))
             args)
    | ApplyIntrin { op = `BVOR; args } ->
        replace [%here]
          (normalise_intrinsic `BVOR
             (BasilExpr.bvconst (Bitvec.zero ~size:0))
             args)
    | ApplyIntrin { op = `BVAND; args } ->
        replace [%here]
          (normalise_intrinsic `BVAND
             (BasilExpr.bvconst (Bitvec.zero ~size:0))
             args)
    | ApplyIntrin { op = `BVXOR; args } ->
        replace [%here]
          (normalise_intrinsic `BVXOR
             (BasilExpr.bvconst (Bitvec.zero ~size:0))
             args)
    | _ -> Keep

  open Stmt

  let replace_stmt (s : Program.stmt) =
    match s with
    | Instr_IndirectCall _ -> Instr_Assert { body = BasilExpr.boolconst false }
    | Instr_Load { lhs; rhs; addr = Scalar } ->
        Instr_Assign [ (lhs, BasilExpr.rvar rhs) ]
    | Instr_Store { lhs; value; addr = Scalar } -> Instr_Assign [ (lhs, value) ]
    | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
        let fn_name =
          Printf.sprintf "load%d_%s" size (Lang.Stmt.show_endian endian)
        in
        Instr_Assign
          [
            ( lhs,
              Lang.Expr.BasilExpr.fapply
                (Lang.Expr.BasilExpr.rvar (Var.create fn_name (Var.typ lhs)))
                [ Lang.Expr.BasilExpr.rvar rhs; addr ] );
          ]
    | Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
        let fn_name =
          Printf.sprintf "store%d_%s" size (Lang.Stmt.show_endian endian)
        in
        Lang.Stmt.Instr_Assign
          [
            ( lhs,
              Lang.Expr.BasilExpr.fapply
                (Lang.Expr.BasilExpr.rvar (Var.create fn_name (Var.typ lhs)))
                [ Lang.Expr.BasilExpr.rvar rhs; addr; value ] );
          ]
    | o -> o

  let rewriter = BasilExpr.rewrite ~rw_fun:replace_expr

  let replace_exprs =
    (* have to inline let because rewriter converts to map access *)
    Cf_tx.simplify_prog_spec_exprs Algsimp.inline_let
    %> Cf_tx.simplify_prog_exprs Algsimp.inline_let
    %> Cf_tx.simplify_prog_spec_exprs rewriter
    %> Cf_tx.simplify_prog_exprs rewriter

  let replace_functions (p : Program.t) =
    let globals =
      p.globals |> StringMap.to_iter
      |> Iter.flat_map
           Program.(
             function
             | k, Function { binding; attrib; definition } -> (
                 let keep =
                   Iter.singleton (k, Function { binding; attrib; definition })
                 in
                 match definition with
                 | Function b -> (
                     match BasilExpr.unfix b with
                     | Lambda { bound_vars; in_body } -> keep
                     | body ->
                         let axiom_name = k ^ "_funvalue" in
                         Iter.doubleton
                           ( k,
                             Function
                               { binding; definition = Uninterpreted; attrib }
                           )
                           ( axiom_name,
                             Function
                               {
                                 binding = Var.copy ~name:axiom_name binding;
                                 definition =
                                   Axiom
                                     (BasilExpr.binexp ~op:`EQ
                                        (BasilExpr.rvar binding)
                                        (BasilExpr.fix body));
                                 attrib;
                               } ))
                 | o -> keep)
             | e -> Iter.singleton e)
      |> StringMap.of_iter
    in
    { p with globals }

  let replace_stmts (p : Program.t) =
    let procs =
      p.procs
      |> IDMap.map (fun p ->
          Procedure.map_blocks_nondet
            (fun (id, b) -> Block.map ~phi:Fun.id replace_stmt b)
            p)
    in
    { p with procs }
end

let transform (p : Lang.Program.t) =
  p |> Normalise.replace_functions |> Normalise.replace_exprs
  |> Instructions.transform_add_store_load_decls |> Normalise.replace_stmts
  |> Builtins.transform_add_builtin_decls
