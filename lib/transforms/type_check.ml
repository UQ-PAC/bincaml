(** Type Checking **)

open Bincaml_util.Common
open Lang
open Expr

type type_error = TypeError of { text : string }

let type_err fmt stmt_id block_id =
  Printf.ksprintf
    (fun text ->
      TypeError
        {
          text = Printf.sprintf "%s at statement %d in %s" text stmt_id block_id;
        })
    fmt

let show_type_error err = match err with TypeError { text } -> text

let print_type_errors errs =
  Iter.to_string ~sep:"\n" show_type_error errs |> print_string

let type_check stmt_id block_id expr =
  let type_err fmt = type_err fmt stmt_id block_id in
  let check_unary (op : Ops.AllOps.unary) (arg : Types.t) : type_error list =
    let open Ops in
    match op with
    | `Classification -> []
    | `Gamma -> []
    | `BoolNOT | `BOOLTOBV1 ->
        if Types.equal arg Types.Boolean then []
        else [ type_err "%s body is not a boolean" @@ AllOps.to_string op ]
    | `INTNEG ->
        if Types.equal arg Types.Integer then []
        else [ type_err "%s body is not a integer" @@ AllOps.to_string op ]
    | `BVNOT | `BVNEG | `ZeroExtend _ | `SignExtend _ -> (
        match arg with
        | Bitvector _ -> []
        | _ -> [ type_err "%s body is not a bitvector" @@ AllOps.to_string op ])
    | `Extract (hi, _) -> (
        match arg with
        | Bitvector sz -> (
            match sz >= hi with
            | true -> []
            | _ ->
                [
                  type_err
                    "%s needs to have a bitvector of at least it's hi value"
                  @@ AllOps.to_string op;
                ])
        | _ -> [ type_err "%s body is not a bitvector" @@ AllOps.to_string op ])
    | `Old -> []
    | `Forall | `Exists | `Lambda -> []
  in

  let check_binary (op : Ops.AllOps.binary) (arg1 : Types.t) (arg2 : Types.t) :
      type_error list =
    let binary_same_types (expected_type : Types.t) arg1 arg2 =
      match (arg1, arg2) with
      | tl, tr when Types.equal tl expected_type && Types.equal tr expected_type
        ->
          []
      | _, tr when Types.equal tr expected_type ->
          [
            type_err "%s is not the correct type of %s for %s"
              (Types.to_string arg1)
              (Types.to_string expected_type)
              (Ops.AllOps.to_string op);
          ]
      | tl, _ when Types.equal tl expected_type ->
          [
            type_err "%s is not the correct type of %s for %s"
              (Types.to_string arg2)
              (Types.to_string expected_type)
              (Ops.AllOps.to_string op);
          ]
      | _, _ ->
          [
            type_err "%s and %s is not the correct type of %s for %s"
              (Types.to_string arg1) (Types.to_string arg2)
              (Types.to_string expected_type)
              (Ops.AllOps.to_string op);
          ]
    in
    let binary_int_types = binary_same_types Types.Integer in
    let binary_bool_types = binary_same_types Types.Boolean in
    let open Ops in
    match op with
    | `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD | `INTLT | `INTLE ->
        binary_int_types arg1 arg2
    | (`EQ | `NEQ) as op ->
        if Types.equal arg1 arg2 then []
        else
          [
            type_err "Arguments are not of the same type in %s"
            @@ AllOps.to_string op;
          ]
    | `Load (e, sz) -> []
    | `MapAccess -> (
        let a, r = Types.uncurry arg1 in
        match a with
        | [ arg ] when not (Types.equal arg arg2) ->
            [
              type_err "Argument does not match map type %s"
              @@ AllOps.to_string op;
            ]
        | _ -> [])
    | `IMPLIES -> binary_bool_types arg1 arg2
    | `BVSREM | `BVSDIV | `BVADD | `BVASHR | `BVMUL | `BVSHL | `BVNAND | `BVSLE
    | `BVUREM | `BVXOR | `BVOR | `BVSUB | `BVUDIV | `BVLSHR | `BVAND | `BVSMOD
    | `BVULT | `BVULE | `BVSLT -> (
        match arg1 with
        | Bitvector sz as typ -> binary_same_types arg1 arg2 typ
        | _ ->
            [
              type_err "%s is not of bitvector type in %s"
                (Types.to_string arg1) (Ops.AllOps.to_string op);
            ])
    | `IfThen ->
        if not @@ Types.equal Types.Boolean arg1 then
          [ type_err "condition is not boolean" ]
        else []
  in

  let check_intrin (op : Ops.AllOps.intrin) (args : Types.t list) :
      type_error list =
    match op with
    | `BVADD | `BVXOR | `BVOR | `BVAND ->
        let correct_type = List.hd args in
        List.fold_left
          (fun acc typ ->
            if Types.equal correct_type typ then acc
            else
              type_err "%s is not a bitvector type in %s" (Types.to_string typ)
                (Ops.AllOps.to_string op)
              :: acc)
          [] args
    | `BVConcat ->
        (* Just make sure everything is a BV dont care about size *)
        List.fold_left
          (fun acc typ ->
            match typ with
            | Types.Bitvector _ -> acc
            | _ ->
                type_err "%s is not a bitvector type in %s"
                  (Types.to_string typ) (Ops.AllOps.to_string op)
                :: acc)
          [] args
    | `OR | `AND ->
        List.fold_left
          (fun acc typ ->
            if Types.equal Types.Boolean typ then acc
            else
              type_err "%s is not a boolean in %s" (Types.to_string typ)
                (Ops.AllOps.to_string op)
              :: acc)
          [] args
    | `Cases -> (
        match args with
        | [] -> []
        | h :: tl ->
            fst
            @@ List.fold_left
                 (fun (errs, ty) b ->
                   if Types.equal ty b then (errs, ty)
                   else
                     ( type_err "non-equal branch : %s %s" (Types.to_string ty)
                         (Types.to_string b)
                       :: errs,
                       ty ))
                 ([], h) tl)
  in

  let type_error_alg e =
    let open Ops.AllOps in
    let open AbstractExpr in
    let errors =
      AbstractExpr.map fst e
      |> AbstractExpr.fold (fun acc f -> List.append f acc) []
    in
    let get_ty o =
      match o with
      | Fun { ret } -> ([], ret)
      | Conflict c ->
          ([ type_err "Nothing type encountered in operator" ], Nothing)
    in
    let inf_errors, rtype =
      match AbstractExpr.map snd e with
      | RVar { id = r } -> ([], Var.typ r)
      | Constant { const = op } -> ret_type_const op |> get_ty
      | UnaryExpr { op; arg = a } -> ret_type_unary op a |> get_ty
      | BinaryExpr { op; arg1 = l; arg2 = r } -> ret_type_bin op l r |> get_ty
      | ApplyIntrin { op; args } -> ret_type_intrin op args |> get_ty
      | ApplyFun { func; args } ->
          let _, rt = Types.uncurry func in
          ([], rt)
      | Binding { bound = vars; in_body = b } ->
          ([], Types.curry (List.map Var.typ vars) b)
    in
    let typed_expr = AbstractExpr.map snd e in
    let new_errors : type_error list =
      match typed_expr with
      | RVar _ -> []
      | Constant _ -> []
      | ApplyFun _ -> []
      | Binding _ -> []
      | UnaryExpr { op; arg } -> check_unary op arg
      | BinaryExpr { op; arg1 = l; arg2 = r } -> check_binary op l r
      | ApplyIntrin { op; args } -> check_intrin op args
    in
    (inf_errors @ new_errors @ errors, rtype)
  in
  BasilExpr.cata type_error_alg expr

let check_stmt_types (stmt : Program.stmt) (pt : Program.t) stmt_id block_id =
  let type_err fmt = type_err fmt stmt_id block_id in
  let expect_equal msg a b (s : type_error list) =
    if Types.equal a b then s
    else
      type_err "%s : (%s != %s)" msg (Types.to_string a) (Types.to_string b)
      :: s
  in
  let type_check = type_check stmt_id block_id in
  match stmt with
  | Stmt.Instr_IntrinCall _ -> []
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun acc (lvar, e) ->
          let expr_errors, rtype = type_check e in
          let acc = List.append acc expr_errors in
          if Types.equal rtype (Var.typ lvar) then acc
          else
            type_err
              "Paramters for the function has a type mismatch: type of %s != \
               type of %s (%s != %s)"
              (BasilExpr.to_string e) (Var.to_string lvar)
              (Types.to_string rtype)
              (Types.to_string (Var.typ lvar))
            :: acc)
        [] ls
  | Stmt.Instr_Store { lhs; rhs; value; addr = Scalar } ->
      let terror, rtype = type_check value in
      terror
      |> expect_equal "rhs value not equal to lhs" rtype (Var.typ lhs)
      |> expect_equal "rhs value not equal to rhs mem" rtype (Var.typ rhs)
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
      []
      |> expect_equal "lhs type not equal to rhs type" (Var.typ lhs)
           (Var.typ rhs)
  | Stmt.Instr_Assert { body = e } | Stmt.Instr_Assume { body = e } ->
      let expr_errors, rtype = type_check e in
      if Types.equal rtype Types.Boolean then expr_errors
      else
        type_err "Body of %s is not a Boolean" (BasilExpr.to_string e)
        :: expr_errors
  | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size } } -> (
      let errors, rtype = type_check addr in
      let errors =
        if Types.equal (Var.typ lhs) (Types.bv size) then errors
        else
          type_err "Load size (%d) doesn't match lhs (%s) type" size
            (Var.to_string lhs)
          :: errors
      in
      match Var.typ rhs with
      | Map (Bitvector addressSize, _)
        when Types.equal (Types.bv addressSize) rtype ->
          errors
      | Map (Bitvector addressSize, _) ->
          type_err "Address loading data (%s) does not match address size (%d)"
            (BasilExpr.to_string addr) addressSize
          :: errors
      | _ ->
          (type_err "Invalid field for addressSize in mem %s"
          @@ Var.to_string rhs)
          :: errors)
  | Stmt.Instr_Store { lhs; value; rhs; addr = Addr { addr; size } } -> (
      let val_errors, val_rtype = type_check value in
      let addr_errors, addr_rtype = type_check addr in
      let errors = List.append addr_errors val_errors in
      let errors =
        if Types.equal val_rtype (Types.bv size) then errors
        else
          type_err "Store size (%s) doesn't match lhs (%s) type"
            (Types.to_string (Types.bv size))
            (Types.to_string val_rtype)
          :: errors
      in
      match Var.typ rhs with
      | Map (Bitvector addressSize, _)
        when Types.equal (Types.bv addressSize) addr_rtype ->
          errors
      | Map (Bitvector addressSize, _) ->
          type_err "Address loading data (%s) does not match address size (%d)"
            (BasilExpr.to_string addr) addressSize
          :: errors
      | _ ->
          (type_err "Invalid field for addressSize in mem %s"
          @@ Var.to_string rhs)
          :: errors)
  | Stmt.Instr_IndirectCall { target } ->
      let expr_errors, rtype = type_check target in
      if Types.equal rtype (Types.bv 64) then expr_errors
      else
        type_err
          "Indirect call target (%s) must be an address (i.e. Bitvector 64)"
          (BasilExpr.to_string target)
        :: expr_errors
  | Stmt.Instr_Call { lhs; procid; args } ->
      let compare_stringmaps ty_a str_a a ty_b str_b b =
        StringMap.merge
          (fun k arg real ->
            match (arg, real) with
            | None, _ | _, None -> Some (type_err "missing: %s" k)
            | Some arg, Some real ->
                if Types.equal (ty_a arg) (ty_b real) then None
                else
                  Some
                    (type_err "Type mismatch in arguments %s and %s" (str_a arg)
                       (str_b real)))
          a b
        |> StringMap.values |> Iter.to_list
      in
      let target_proc = ID.Map.find procid pt.procs in
      let real_args = Procedure.formal_in_params target_proc in
      let output = Procedure.formal_out_params target_proc in

      let args = StringMap.map (fun v -> snd (type_check v)) args in
      let params_check =
        List.append
          (compare_stringmaps id Types.to_string args Var.typ Var.to_string
             real_args)
          (compare_stringmaps Var.typ Var.to_string lhs Var.typ Var.to_string
             output)
      in
      params_check

let check_block prog (id, b) =
  Block.stmts_iter b
  |> Iter.mapi (fun i stmt -> (i, stmt))
  |> Iter.flat_map (fun (i, stmt) ->
      List.to_iter (check_stmt_types stmt prog i @@ ID.name id))

let check_proc prog p =
  Procedure.iter_blocks_topo_fwd p |> Iter.flat_map (check_block prog)

let check prog p =
  let errs = check_proc prog p in
  print_type_errors errs;
  not (Iter.is_empty errs)
