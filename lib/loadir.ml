(** Loads a initial IR from the semi-concrete AST *)

open Lang
open Value
open Expr
open Containers
module StringMap = Map.Make (String)

type load_st = {
  prog : Program.t;
  curr_proc : Program.proc option;
  params_order :
    (string, (string * Var.t) list * (string * Var.t) list) Hashtbl.t;
}

let map_prog f l = { l with prog = f l.prog }

type textRange = (int * int) option [@@deriving show { with_path = false }, eq]

module BasilASTLoader = struct
  open BasilIR.AbsBasilIR

  type loaded_block =
    | LBlock of
        (string
        * Program.stmt list
        * [ `Return of Program.e list
          | `Goto of string list
          | `None
          | `ReturnNamed of (string * Program.e) list ])

  let failure x = failwith "Undefined case." (* x discarded *)
  let stripquote s = String.sub s 1 (String.length s - 2)

  let rec transBVTYPE (x : bVTYPE) : Types.t =
    match x with
    | BVTYPE (_, string) ->
        let sz =
          String.split_on_char 'v' string |> function
          | h :: l :: _ -> int_of_string l
          | _ -> failwith "bad bv format"
        in
        Bitvector sz

  and transBIdent (x : bIdent) : string = match x with BIdent (_, id) -> id

  and transStr (x : str) : string =
    match x with Str string -> stripquote string

  and trans_program ?(name = "<module>") (x : moduleT) : load_st =
    let prog =
      {
        prog = Program.empty ~name ();
        params_order = Hashtbl.create 30;
        curr_proc = None;
      }
    in
    match x with
    | Module1 declarations ->
        List.fold_left trans_declaration prog declarations |> fun p ->
        List.fold_left trans_definition p declarations

  and trans_declaration prog (x : decl) : load_st =
    match x with
    | Decl_SharedMem (bident, type') ->
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~pure:false ~scope:Global (transType type'));
            p)
          prog
    | Decl_UnsharedMem (bident, type') ->
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~pure:true ~scope:Global (transType type'));
            p)
          prog
    | Decl_Var (bident, type') ->
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~pure:true ~scope:Global (transType type'));
            p)
          prog
    | Decl_UninterpFun (attrDefList, glident, argtypes, rettype) -> prog
    | Decl_Fun (attrList, glident, params, rt, body) -> prog
    | Decl_Axiom _ -> prog
    | Decl_ProgEmpty (ProcIdent (_, id), attr) -> prog
    | Decl_ProgWithSpec (ProcIdent (_, id), attr, _, spec, _) -> prog
    | Decl_Proc
        ( ProcIdent (id_pos, id),
          in_params,
          out_params,
          attrib,
          spec,
          ProcDef_Empty ) ->
        let formal_in_params_order = List.map param_to_formal in_params in
        let formal_out_params_order = List.map param_to_formal out_params in
        let proc_id = prog.prog.proc_names.decl_or_get id in
        Hashtbl.add prog.params_order id
          (formal_in_params_order, formal_out_params_order);
        let p = Procedure.create proc_id () in
        let prog =
          map_prog
            (fun pr -> { pr with procs = ID.Map.add proc_id p pr.procs })
            prog
        in
        prog
    | Decl_Proc
        ( ProcIdent (id_pos, id),
          in_params,
          out_params,
          attrs,
          spec_list,
          ProcDef_Some (bl, blocks, el) ) ->
        let proc_id = prog.prog.proc_names.decl_or_get id in
        let formal_in_params_order = List.map param_to_formal in_params in
        let formal_in_params = formal_in_params_order |> StringMap.of_list in
        let formal_out_params_order = List.map param_to_formal out_params in
        let formal_out_params = StringMap.of_list formal_out_params_order in
        Hashtbl.add prog.params_order id
          (formal_in_params_order, formal_out_params_order);
        let p =
          Procedure.create proc_id ~formal_in_params ~formal_out_params ()
        in
        let prog =
          map_prog
            (fun pr -> { pr with procs = ID.Map.add proc_id p pr.procs })
            prog
        in
        prog

  and trans_definition prog (x : decl) : load_st =
    match x with
    | Decl_ProgEmpty (ProcIdent (_, id), attr) ->
        map_prog
          (fun p -> { p with entry_proc = Some (p.proc_names.get_id id) })
          prog
    | Decl_ProgWithSpec (ProcIdent (_, id), attr, _, spec, _) ->
        map_prog
          (fun p -> { p with entry_proc = Some (p.proc_names.get_id id) })
          prog
    | Decl_Proc
        ( ProcIdent (id_pos, id),
          in_params,
          out_params,
          attrs,
          spec_list,
          ProcDef_Some (bl, blocks, el) ) ->
        let proc_id = prog.prog.proc_names.decl_or_get id in
        let p = ID.Map.find proc_id prog.prog.procs in
        let prog = { prog with curr_proc = Some p } in
        let blocks = List.map (trans_block prog) blocks in
        let open Procedure.Vert in
        let formal_out_params_order = List.map param_to_formal out_params in
        (* add blocks *)
        let p, blocks_id =
          List.fold_left
            (fun (p, a) b ->
              match b with
              | LBlock (name, stmts, succ) ->
                  let stmts = stmts in
                  let p, bid = Procedure.decl_block_exn p name ~stmts () in
                  (p, (name, bid) :: a))
            (p, []) blocks
        in
        let blocks_id = List.rev blocks_id in
        let block_label_id = StringMap.of_list blocks_id in
        let p =
          match List.head_opt blocks_id with
          | None -> p
          | Some (_, entry) ->
              {
                p with
                graph = Procedure.G.add_edge p.graph Entry (Begin entry);
              }
        in

        (* add intraproc edges*)
        let p =
          List.fold_left
            (fun (p : Program.proc) b ->
              match b with
              | LBlock (name, _, succ) -> (
                  match succ with
                  | `None -> p
                  | `Goto tgts ->
                      let f = StringMap.find name block_label_id in
                      let succ =
                        List.map (fun c -> StringMap.find c block_label_id) tgts
                      in
                      Procedure.add_goto p ~from:f ~targets:succ
                  | `ReturnNamed exprs ->
                      let f = StringMap.find name block_label_id in
                      let args = StringMap.of_list exprs in
                      Procedure.add_return p ~from:f ~args
                  | `Return exprs ->
                      let args =
                        List.combine formal_out_params_order exprs
                        |> List.map (function (name, var), expr -> (name, expr))
                        |> StringMap.of_list
                      in
                      let f = StringMap.find name block_label_id in
                      Procedure.add_return p ~from:f ~args))
            p blocks
        in
        map_prog
          (fun prog -> { prog with procs = ID.Map.add proc_id p prog.procs })
          prog
    | _ -> prog

  and transMapType (x : mapType) : Types.t =
    match x with MapType1 (t0, t1) -> Map (transType t0, transType t1)

  and transType (x : typeT) : Types.t =
    match x with
    | TypeIntType inttype -> Integer
    | TypeBoolType booltype -> Boolean
    | TypeMapType maptype -> transMapType maptype
    | TypeBVType (BVType1 bvtype) -> transBVTYPE bvtype

  and transIntVal (x : intVal) : PrimInt.t =
    match x with
    | IntVal_Hex (IntegerHex (_, ihex)) -> Z.of_string ihex
    | IntVal_Dec (IntegerDec (_, i)) -> Z.of_string i

  and trans_endian (x : BasilIR.AbsBasilIR.endian) =
    match x with Endian_Little -> `Big | Endian_Big -> `Little

  and trans_stmt (p_st : load_st) (x : BasilIR.AbsBasilIR.stmtWithAttrib) =
    let stmt = match x with StmtWithAttrib1 (stmt, _) -> stmt in
    let open Stmt in
    match stmt with
    | Stmt_SingleAssign (Assignment1 (lvar, expr)) ->
        `Stmt (Instr_Assign [ (transLVar p_st lvar, trans_expr expr) ])
    | Stmt_MultiAssign assigns ->
        `Stmt
          (Instr_Assign
             (assigns
             |> List.map (function Assignment1 (l, r) ->
                 (transLVar p_st l, trans_expr r))))
    | Stmt_Load (lvar, endian, bident, expr, intval) ->
        let endian = trans_endian endian in
        let mem =
          let n = unsafe_unsigil (`Global bident) in
          Option.get_exn_or ("memory undefined: " ^ n)
          @@ Var.Decls.find_opt p_st.prog.globals n
        in
        let cells = transIntVal intval |> Z.to_int in
        `Stmt
          (Instr_Load
             {
               lhs = transLVar p_st lvar;
               mem;
               addr = trans_expr expr;
               endian;
               cells;
             })
    | Stmt_Store (endian, bident, addr, value, intval) ->
        let endian = trans_endian endian in
        let cells = transIntVal intval |> Z.to_int in
        let mem =
          let n = unsafe_unsigil (`Global bident) in
          Option.get_exn_or ("memory undefined: " ^ n)
          @@ Var.Decls.find_opt p_st.prog.globals n
        in
        `Stmt
          (Instr_Store
             {
               mem;
               addr = trans_expr addr;
               value = trans_expr value;
               cells;
               endian;
             })
    | Stmt_DirectCall (calllvars, bident, exprs) ->
        let n = unsafe_unsigil (`Proc bident) in
        let procid = p_st.prog.proc_names.get_id n in
        let in_param, out_param = Hashtbl.find p_st.params_order n in
        let lhs = trans_call_lhs p_st (List.map fst out_param) calllvars in
        let args = trans_call_rhs in_param exprs in
        `Call (Instr_Call { lhs; procid; args })
    | Stmt_IndirectCall expr ->
        `Call (Instr_IndirectCall { target = trans_expr expr })
    | Stmt_Assume expr ->
        `Stmt (Instr_Assume { body = trans_expr expr; branch = false })
    | Stmt_Guard expr ->
        `Stmt (Instr_Assume { body = trans_expr expr; branch = true })
    | Stmt_Assert expr -> `Stmt (Instr_Assert { body = trans_expr expr })

  and trans_call_rhs in_param (x : callParams) =
    match x with
    | CallParams_Exprs exprs ->
        List.combine (List.map fst in_param) (List.map trans_expr exprs)
        |> StringMap.of_list
    | CallParams_Named nl ->
        nl
        |> List.map (function NamedCallArg1 (li, e) ->
            (unsafe_unsigil (`Local li), trans_expr e))
        |> StringMap.of_list

  and trans_call_lhs prog (formal_out : string list) (x : lVars) :
      Var.t StringMap.t =
    match x with
    | LVars_Empty -> StringMap.empty
    | LVars_LocalList lvars ->
        List.combine formal_out (unpackLVars lvars) |> StringMap.of_list
    | LVars_List lvars ->
        List.combine formal_out @@ List.map (transLVar prog) lvars
        |> StringMap.of_list
    | NamedLVars_List lvars ->
        lvars
        |> List.map (function NamedCallReturn1 (lVar, ident) ->
            (unsafe_unsigil (`Local ident), transLVar prog lVar))
        |> StringMap.of_list

  and unpackLVars lvs =
    List.map
      (function
        | LocalVar1 (i, t) ->
            Var.create ~scope:Local (unsafe_unsigil (`Local i)) (transType t))
      lvs

  and trans_jump (x : BasilIR.AbsBasilIR.jumpWithAttrib) =
    let jump = match x with JumpWithAttrib1 (jump, _) -> jump in
    match jump with
    | Jump_GoTo bidents ->
        let get_id = function BlockIdent (pos, g) -> g in
        `Goto (List.map get_id bidents)
    | Jump_Unreachable -> `None
    | Jump_Return exprs -> `Return (List.map trans_expr exprs)
    | Jump_ReturnNamedParams exprs ->
        let es =
          exprs
          |> List.map (function NamedCallArg1 (id, expr) ->
              (unsafe_unsigil (`Local id), trans_expr expr))
        in
        `ReturnNamed es

  and transLVar prog (x : BasilIR.AbsBasilIR.lVar) : Var.t =
    let p = Option.get_exn_or "didnt set proc" prog.curr_proc in
    match x with
    | LVar_Local (LocalVar1 (bident, type')) ->
        let v =
          Var.create ~scope:Local
            (unsafe_unsigil (`Local bident))
            (transType type')
        in
        let _ = Procedure.decl_local p v in
        v
    | LVar_Global (GlobalVar1 (bident, type')) ->
        let v =
          Var.create ~scope:Global
            (unsafe_unsigil (`Global bident))
            (transType type')
        in
        (*let _ = Program.decl_global prog.prog v in*)
        v

  and list_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginList ((i, j), l) -> i in
    let ed = match endlist with EndList ((i, j), l) -> j in
    Some (beg, ed)

  and rec_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginRec ((i, j), l) -> i in
    let ed = match endlist with EndRec ((i, j), l) -> j in
    Some (beg, ed)

  and trans_block (prog : load_st) (x : BasilIR.AbsBasilIR.block) =
    match x with
    | Block1
        ( BlockIdent (text_range, name),
          addrattr,
          beginlist,
          statements,
          jump,
          endlist ) ->
        let stmts =
          List.map (trans_stmt prog) statements
          |> List.map (function `Call c -> c | `Stmt c -> c)
        in
        let succ = trans_jump jump in
        LBlock (name, stmts, succ)

  and param_to_lvar (pp : params) : Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> Var.create id (transType t)

  and param_to_formal (pp : params) : string * Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> (id, Var.create id (transType t))

  and unsafe_unsigil g : string =
    match g with
    | `Global (GlobalIdent (pos, g)) -> g
    | `Local (LocalIdent (pos, g)) -> g
    | `Proc (ProcIdent (pos, g)) -> g
    | `Block (BlockIdent (pos, g)) -> g

  and trans_expr (x : BasilIR.AbsBasilIR.expr) : BasilExpr.t =
    let open Ops in
    match x with
    | Expr_Global (GlobalVar1 (g, type')) ->
        BasilExpr.rvar
        @@ Var.create ~scope:Global
             (unsafe_unsigil (`Global g))
             (transType type')
    | Expr_Local (LocalVar1 (g, type')) ->
        BasilExpr.rvar
        @@ Var.create ~scope:Local (unsafe_unsigil (`Local g)) (transType type')
    | Expr_Assoc (binop, rs) -> (
        match transBoolBinOp binop with
        | #AllOps.intrin as op ->
            BasilExpr.applyintrin ~op (List.map trans_expr rs)
        | _ -> failwith "non-associative operator")
    | Expr_Binary (binop, expr0, expr) -> (
        let op = transBinOp binop in
        let e1 = trans_expr expr0 in
        let e2 = trans_expr expr in
        match op with
        | #AllOps.binary as op -> BasilExpr.binexp ~op e1 e2
        | #AllOps.intrin as op -> BasilExpr.applyintrin ~op [ e1; e2 ]
        | `BVUGT -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVULE e1 e2)
        | `BVUGE -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVULT e1 e2)
        | `BVSGT -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVSLE e1 e2)
        | `BVSGE -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVSLT e1 e2)
        | `BVXNOR -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVXOR e1 e2)
        | `BVNOR -> BasilExpr.boolnot (BasilExpr.binexp ~op:`BVOR e1 e2)
        | `BVCOMP ->
            BasilExpr.unexp ~op:`BOOLTOBV1 (BasilExpr.binexp ~op:`EQ e1 e2)
        | `INTGE -> BasilExpr.boolnot (BasilExpr.binexp ~op:`INTLT e1 e2)
        | `INTGT -> BasilExpr.boolnot (BasilExpr.binexp ~op:`INTLE e1 e2))
    | Expr_Unary (unop, expr) ->
        BasilExpr.unexp ~op:(transUnOp unop) (trans_expr expr)
    | Expr_ZeroExtend (intval, expr) ->
        BasilExpr.zero_extend
          ~n_prefix_bits:(Z.to_int @@ transIntVal intval)
          (trans_expr expr)
    | Expr_SignExtend (intval, expr) ->
        BasilExpr.sign_extend
          ~n_prefix_bits:(Z.to_int @@ transIntVal intval)
          (trans_expr expr)
    | Expr_Extract (ival0, intval, expr) ->
        BasilExpr.extract
          ~hi_incl:(transIntVal ival0 |> Z.to_int)
          ~lo_excl:(transIntVal intval |> Z.to_int)
          (trans_expr expr)
    | Expr_Concat exprs ->
        BasilExpr.applyintrin ~op:`BVConcat (List.map trans_expr exprs)
    | Expr_Literal (Value_BV (BVVal1 (intval, BVType1 bvtype))) ->
        BasilExpr.bvconst
          (match transBVTYPE bvtype with
          | Bitvector size -> PrimQFBV.create ~size (transIntVal intval)
          | _ -> failwith "unreachable")
    | Expr_Literal (Value_Int intval) -> BasilExpr.intconst (transIntVal intval)
    | Expr_Literal Value_True -> BasilExpr.boolconst true
    | Expr_Literal Value_False -> BasilExpr.boolconst false
    | Expr_Old e -> BasilExpr.unexp ~op:`Old (trans_expr e)
    | Expr_Forall (LambdaDef1 (lv, _, e)) ->
        BasilExpr.forall
          ~bound:(List.map BasilExpr.rvar @@ unpackLVars lv)
          (trans_expr e)
    | Expr_Exists (LambdaDef1 (lv, _, e)) ->
        BasilExpr.exists
          ~bound:(List.map BasilExpr.rvar @@ unpackLVars lv)
          (trans_expr e)
    | Expr_FunctionOp (gi, args) ->
        BasilExpr.apply_fun
          ~name:(unsafe_unsigil (`Global gi))
          (List.map trans_expr args)

  and transBinOp (x : BasilIR.AbsBasilIR.binOp) =
    match x with
    | BinOpBVBinOp bvbinop -> transBVBinOp bvbinop
    | BinOpBVLogicalBinOp bvlogicalbinop -> transBVLogicalBinOp bvlogicalbinop
    | BinOpBoolBinOp boolbinop -> transBoolBinOp boolbinop
    | BinOpIntLogicalBinOp intlogicalbinop ->
        transIntLogicalBinOp intlogicalbinop
    | BinOpIntBinOp intbinop -> transIntBinOp intbinop
    | BinOpEqOp equop -> transEqOp equop

  and transUnOp (x : BasilIR.AbsBasilIR.unOp) =
    match x with
    | UnOpBVUnOp bvunop -> transBVUnOp bvunop
    | UnOp_boolnot -> `BoolNOT
    | UnOp_intneg -> `INTNEG
    | UnOp_booltobv1 -> `BOOLTOBV1

  and transBVUnOp (x : bVUnOp) =
    match x with BVUnOp_bvnot -> `BVNOT | BVUnOp_bvneg -> `BVNEG

  and transBVBinOp (x : BasilIR.AbsBasilIR.bVBinOp) =
    match x with
    | BVBinOp_bvand -> `BVAND
    | BVBinOp_bvor -> `BVOR
    | BVBinOp_bvadd -> `BVADD
    | BVBinOp_bvmul -> `BVMUL
    | BVBinOp_bvudiv -> `BVUDIV
    | BVBinOp_bvurem -> `BVUREM
    | BVBinOp_bvshl -> `BVSHL
    | BVBinOp_bvlshr -> `BVLSHR
    | BVBinOp_bvnand -> `BVNAND
    | BVBinOp_bvxor -> `BVXOR
    | BVBinOp_bvcomp -> `BVCOMP
    | BVBinOp_bvsub -> `BVSUB
    | BVBinOp_bvsdiv -> `BVSDIV
    | BVBinOp_bvsrem -> `BVSREM
    | BVBinOp_bvsmod -> `BVSMOD
    | BVBinOp_bvashr -> `BVASHR
    | BVBinOp_bvnor -> `BVNOR
    | BVBinOp_bvxnor -> `BVXNOR

  and transBVLogicalBinOp (x : bVLogicalBinOp) =
    match x with
    | BVLogicalBinOp_bvule -> `BVULE
    | BVLogicalBinOp_bvult -> `BVULT
    | BVLogicalBinOp_bvslt -> `BVSLT
    | BVLogicalBinOp_bvsle -> `BVSLE
    | BVLogicalBinOp_bvugt -> `BVUGT
    | BVLogicalBinOp_bvuge -> `BVUGE
    | BVLogicalBinOp_bvsgt -> `BVSGT
    | BVLogicalBinOp_bvsge -> `BVSGE

  and transEqOp (x : eqOp) = match x with EqOp_eq -> `EQ | EqOp_neq -> `NEQ

  and transIntBinOp (x : intBinOp) =
    match x with
    | IntBinOp_intadd -> `INTADD
    | IntBinOp_intmul -> `INTMUL
    | IntBinOp_intsub -> `INTSUB
    | IntBinOp_intdiv -> `INTDIV
    | IntBinOp_intmod -> `INTMOD

  and transIntLogicalBinOp (x : intLogicalBinOp) =
    match x with
    | IntLogicalBinOp_intlt -> `INTLT
    | IntLogicalBinOp_intle -> `INTLE
    | IntLogicalBinOp_intgt -> `INTGT
    | IntLogicalBinOp_intge -> `INTGE

  and transBoolBinOp (x : boolBinOp) =
    match x with
    | BoolBinOp_booland -> `AND
    | BoolBinOp_boolor -> `OR
    | BoolBinOp_boolimplies -> `IMPLIES
end

let () =
  Printexc.register_printer (function
    | BasilIR.BNFC_Util.Parse_error (b, e) ->
        let fname = b.pos_fname in
        let x = b.pos_lnum in
        let col = b.pos_cnum - b.pos_bol in
        Some (Printf.sprintf "Parse error in \"%s\" line %d col %d" fname x col)
    | _ -> None (* for other exceptions *))

let concrete_prog_ast_of_channel ?filename c =
  let open BasilIR in
  let lexbuf = Lexing.from_channel c in
  filename |> Option.iter (fun f -> Lexing.set_filename lexbuf f);
  try ParBasilIR.pModuleT LexBasilIR.token lexbuf
  with ParBasilIR.Error ->
    let start_pos = Lexing.lexeme_start_p lexbuf
    and end_pos = Lexing.lexeme_end_p lexbuf in
    raise (BNFC_Util.Parse_error (start_pos, end_pos))

let parse_proc lexbuf =
  let open BasilIR in
  try ParBasilIR.pDecl LexBasilIR.token lexbuf
  with ParBasilIR.Error ->
    let start_pos = Lexing.lexeme_start_p lexbuf
    and end_pos = Lexing.lexeme_end_p lexbuf in
    raise (BNFC_Util.Parse_error (start_pos, end_pos))

let parse_proc_string st c =
  let lexbuf = Lexing.from_channel c in
  let proc = parse_proc lexbuf in
  BasilASTLoader.trans_definition st proc

let parse_proc_channel st c =
  let lexbuf = Lexing.from_channel c in
  let proc = parse_proc lexbuf in
  BasilASTLoader.trans_definition st proc

let ast_of_concrete_ast ~name m =
  Trace.with_span ~__FILE__ ~__LINE__ "convert-concrete-ast" @@ fun f ->
  BasilASTLoader.trans_program ~name m

let ast_of_channel fname c =
  let m =
    Trace.with_span ~__FILE__ ~__LINE__ "load-concrete-ast" @@ fun f ->
    let m = concrete_prog_ast_of_channel ~filename:fname c in
    m
  in
  ast_of_concrete_ast ~name:fname m

let ast_of_fname fname = IO.with_in fname (fun c -> ast_of_channel fname c)
