open Bincaml_util.Common

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
  let monomorphize_builtin (op : builtin) (ret : Types.t) =
    Printf.sprintf "%s_%s"
      (String.replace ~sub:" " ~by:"_" (builtin_name op))
      (Types.to_string ret)

  let name
      (op :
        [< Lang.Ops.AllOps.binary
        | Lang.Ops.AllOps.unary
        | Lang.Ops.AllOps.intrin
        | builtin ]) (ret : Types.t) =
    match op with
    | #builtin as op -> Function (monomorphize_builtin op ret)
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
    | `Extract (hi, lo) -> Postfix (Printf.sprintf "[%d:%d]" hi lo)
    | `BOOLTOBV1 -> Function "bool_to_bv1"
    | #Lang.Ops.AllOps.binary | #Lang.Ops.AllOps.unary | #Lang.Ops.AllOps.intrin
      ->
        Unsup

  let type_alg f (e : Types.t Lang.Expr.BasilExpr.abstract_expr) =
    let open Lang.Expr.AbstractExpr in
    let open Lang.Ops.AllOps in
    let get_ty (op : [ const | unary | binary | intrin ]) o =
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
    | Binding { bound = vars; in_body = b; _ } ->
        Types.curry (List.map Var.typ vars) b

  let istmt f (s : Lang.Program.stmt) =
    Lang.Stmt.iter_rexpr s (function
      | `Expr e -> Lang.Expr.BasilExpr.cata (type_alg f) e |> ignore
      | _ -> ())

  let iprog f (p : Lang.Program.t) =
    ID.Map.values p.procs
    |> Iter.flat_map Lang.Procedure.iter_stmt_topo_fwd
    |> Iter.iter (istmt f)

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
               (match name op ret with Function s -> s | _ -> "")
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
             | Lang.Program.Function { binding } -> binding
             | Lang.Program.Variable { binding } -> binding)
             d)
         p
end

module Instructions = struct
  let unique_stores_loads (prog : Lang.Program.t) =
    let visit_procs proc = Lang.Procedure.iter_stmt_topo_fwd proc in
    let procs = ID.Map.values prog.procs in
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
    Lang.Expr.BasilExpr.binding [ memory; index; value ] body

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
    Lang.Expr.BasilExpr.binding [ memory; index ] body

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
             | Lang.Program.Function { binding } -> binding
             | Lang.Program.Variable { binding } -> binding)
             d)
         prog
end

let transform (p : Lang.Program.t) =
  (* let _ = Instructions.unique_stores_loads p in *)
  let p = Builtins.transform_add_builtin_decls p in
  let p = Instructions.transform_add_store_load_decls p in
  p
