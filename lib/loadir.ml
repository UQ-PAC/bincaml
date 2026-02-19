(** Loads a initial IR from the semi-concrete AST *)

open Bincaml_util.Common
open Lang
open Expr

type load_st = {
  prog : Program.t;
  curr_proc : Program.proc option;
  params_order :
    (string, (string * Var.t) list * (string * Var.t) list) Hashtbl.t;
}

open struct
  let map_prog f l = { l with prog = f l.prog }
end

type textRange = (int * int) option [@@deriving show { with_path = false }, eq]

exception
  LoadError of {
    token_char_offset_range : (int * int) option;
    msg : string;
    input : Pp_loc.Input.t option;
  }

module BasilASTLoader = struct
  open BasilIR.AbsBasilIR

  type loaded_block =
    | LBlock of
        (string
        * Var.t Block.phi list
        * [ `Stmt of Program.stmt | `Return of Program.e list ] list
        * [ `Goto of blockIdent list | `None | `Return ])

  let conv_lblock formal_out_params_order p = function
    | LBlock (name, phis, stmts, succ) ->
        let stmts = stmts in
        let stmts =
          stmts
          |> List.map (function
            | `Stmt s -> s
            | `Return exprs ->
                let args =
                  List.combine formal_out_params_order exprs
                  |> List.map (function (name, var), expr -> (var, expr))
                in
                Stmt.(Instr_Assign args))
        in
        stmts

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
                 ~pure:false ~scope:Global (trans_type type'));
            p)
          prog
    | Decl_UnsharedMem (bident, type') ->
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~pure:false ~scope:Global (trans_type type'));
            p)
          prog
    | Decl_Var (bident, type') ->
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~pure:true ~scope:Global (trans_type type'));
            p)
          prog
    | Decl_UninterpFun (attrDefList, glident, argtypes, rettype) -> prog
    | Decl_Fun (attrList, glident, params, rt, body) -> prog
    | Decl_Axiom _ -> prog
    | Decl_ProgEmpty (ProcIdent (_, id), attr) -> prog
    | Decl_ProgWithSpec (ProcIdent (_, id), attr, _, spec, _) -> prog
    | Decl_Proc
        (ProcIdent (id_pos, id), in_params, out_params, attrib, spec, definition)
      ->
        let proc_id = prog.prog.proc_names.decl_or_get id in
        let formal_in_params_order = List.map param_to_formal in_params in
        let formal_in_params = formal_in_params_order |> StringMap.of_list in
        let formal_out_params_order = List.map param_to_formal out_params in
        let formal_out_params = StringMap.of_list formal_out_params_order in
        Hashtbl.add prog.params_order id
          (formal_in_params_order, formal_out_params_order);
        let is_stub = Stdlib.(definition = ProcDef_Empty) in
        let p =
          Procedure.create proc_id ~is_stub ~formal_in_params ~formal_out_params
            ()
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
        let p =
          if List.is_empty blocks then p else Procedure.add_empty_impl p
        in
        let open Procedure.Vert in
        let formal_out_params_order = List.map param_to_formal out_params in
        (* add blocks *)
        let p, blocks_id =
          List.fold_left
            (fun (p, a) b ->
              match b with
              | LBlock (name, phis, stmts, succ) ->
                  let stmts = conv_lblock formal_out_params_order p b in
                  let p, bid =
                    Procedure.decl_block_exn p name ~stmts ~phis ()
                  in
                  (p, (name, bid) :: a))
            (p, []) blocks
        in
        let blocks_id = List.rev blocks_id in
        let block_label_id = StringMap.of_list blocks_id in
        let p =
          match List.head_opt blocks_id with
          | None -> p
          | Some (_, entry) ->
              p
              |> Procedure.map_graph (fun g ->
                  Procedure.G.add_edge g Entry (Begin entry))
        in

        (* add intraproc edges*)
        let p =
          List.fold_left
            (fun (p : Program.proc) b ->
              match b with
              | LBlock (name, _, _, succ) -> (
                  match succ with
                  | `None -> p
                  | `Return ->
                      let f = StringMap.find name block_label_id in
                      Procedure.map_graph
                        (fun g -> Procedure.G.add_edge g (End f) Return)
                        p
                  | `Goto tgts ->
                      let f = StringMap.find name block_label_id in
                      let succ =
                        tgts
                        |> List.map (function BlockIdent (pos, c) ->
                            (match StringMap.find_opt c block_label_id with
                            | Some b -> b
                            | None ->
                                raise
                                  (LoadError
                                     {
                                       input = None;
                                       token_char_offset_range = Some pos;
                                       msg =
                                         Printf.sprintf "no such block: %s" c;
                                     })))
                      in
                      Procedure.add_goto p ~from:f ~targets:succ))
            p blocks
        in
        map_prog
          (fun prog -> { prog with procs = ID.Map.add proc_id p prog.procs })
          prog
    | _ -> prog

  and transMapType (x : mapType) : Types.t =
    match x with MapType1 (t0, t1) -> Map (trans_type t0, trans_type t1)

  and trans_type (x : typeT) : Types.t =
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
    match x with Endian_Little -> `Little | Endian_Big -> `Big

  and trans_var p_st (v : var) =
    match v with
    | VarLocalVar (LocalVar1 (localVar, ty)) ->
        decl p_st (unsafe_unsigil (`Local localVar)) (trans_type ty) Var.Local
    | VarGlobalVar (GlobalVar1 (globalVar, ty)) ->
        decl p_st
          (unsafe_unsigil (`Global globalVar))
          (trans_type ty) Var.Global

  and trans_stmt (p_st : load_st) (x : BasilIR.AbsBasilIR.stmtWithAttrib) =
    let stmt = match x with StmtWithAttrib1 (stmt, _) -> stmt in
    let open Stmt in
    match stmt with
    | Stmt_Nop -> `None
    | Stmt_Load_Var (lvar, endian, var, expr, intval) ->
        let endian = trans_endian endian in
        let mem = trans_var p_st var in
        let cells = transIntVal intval |> Z.to_int in
        `Stmt
          (Instr_Load
             {
               lhs = trans_lvar p_st lvar;
               mem;
               addr = trans_expr expr;
               endian;
               cells;
             })
    | Stmt_Store_Var (lhs, endian, var, addr, value, intval) ->
        let endian = trans_endian endian in
        let cells = transIntVal intval |> Z.to_int in
        let mem = trans_var p_st var in
        let lhs = trans_lvar p_st lhs in
        `Stmt
          (Instr_Store
             {
               lhs;
               mem;
               addr = trans_expr addr;
               value = trans_expr value;
               cells;
               endian;
             })
    | Stmt_SingleAssign (Assignment1 (lvar, expr)) ->
        `Stmt (Instr_Assign [ (trans_lvar p_st lvar, trans_expr expr) ])
    | Stmt_MultiAssign assigns ->
        `Stmt
          (Instr_Assign
             (assigns
             |> List.map (function Assignment1 (l, r) ->
                 (trans_lvar p_st l, trans_expr r))))
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
               lhs = trans_lvar p_st lvar;
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
               lhs = mem;
               mem;
               addr = trans_expr addr;
               value = trans_expr value;
               cells;
               endian;
             })
    | Stmt_DirectCall (calllvars, bident, exprs) ->
        let n = unsafe_unsigil (`Proc bident) in
        let procid =
          try p_st.prog.proc_names.get_id n
          with Not_found ->
            raise
              (LoadError
                 {
                   input = None;
                   token_char_offset_range =
                     Some (get_bident_loc (`Proc bident));
                   msg = "no such procedure: " ^ n;
                 })
        in
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
        List.combine formal_out @@ List.map (trans_lvar prog) lvars
        |> StringMap.of_list
    | NamedLVars_List lvars ->
        lvars
        |> List.map (function NamedCallReturn1 (lVar, ident) ->
            (unsafe_unsigil (`Local ident), trans_lvar prog lVar))
        |> StringMap.of_list

  and unpackLVars lvs =
    List.map
      (function
        | LocalVar1 (i, t) ->
            Var.create ~scope:Local (unsafe_unsigil (`Local i)) (trans_type t))
      lvs

  and trans_jump (x : BasilIR.AbsBasilIR.jumpWithAttrib) =
    let jump = match x with JumpWithAttrib1 (jump, _) -> jump in
    match jump with
    | Jump_GoTo bidents -> `Goto bidents
    | Jump_Unreachable -> `None
    | Jump_Return exprs -> `Return (List.map trans_expr exprs)
    | Jump_ProcReturn -> `ProcReturn

  and decl prog name ty scope =
    let p = Option.get_exn_or "didnt set proc" prog.curr_proc in
    match scope with
    | Var.Local ->
        let v = Var.create ~scope:Local name ty in
        let _ = Procedure.decl_local p v in
        v
    | Var.Global ->
        let v = Var.create ~scope:Global name ty in
        v

  and trans_lvar prog (x : BasilIR.AbsBasilIR.lVar) : Var.t =
    match x with
    | LVar_Local (LocalVar1 (bident, type')) ->
        decl prog (unsafe_unsigil (`Local bident)) (trans_type type') Local
    | LVar_Global (GlobalVar1 (bident, type')) ->
        decl prog (unsafe_unsigil (`Global bident)) (trans_type type') Global

  and list_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginList ((i, j), l) -> i in
    let ed = match endlist with EndList ((i, j), l) -> j in
    Some (beg, ed)

  and rec_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginRec ((i, j), l) -> i in
    let ed = match endlist with EndRec ((i, j), l) -> j in
    Some (beg, ed)

  and trans_block (prog : load_st) (x : BasilIR.AbsBasilIR.block) =
    let tx name (phis : phiAssign list) statements jump =
      let stmts =
        List.map (trans_stmt prog) statements
        |> List.filter_map (function
          | `Call c -> Some (`Stmt c)
          | `Stmt c -> Some (`Stmt c)
          | `None -> None)
      in
      let find_block_ident name =
        (Procedure.block_ids
           (prog.curr_proc |> Option.get_exn_or "currproc not set"))
          .decl_or_get
          name
      in
      let tx_phi e : Var.t Block.phi =
        match e with
        | PhiAssign1 (v, phexprs) ->
            let rhs =
              List.map
                (function
                  | PhiExpr1 (blockIdent, var) ->
                      ( find_block_ident (unsafe_unsigil (`Block blockIdent)),
                        trans_var prog var ))
                phexprs
            in

            { lhs = trans_lvar prog v; rhs }
      in
      let phis = List.map tx_phi phis in
      let succ = trans_jump jump in
      let succ, stmts =
        match (succ, stmts) with
        | (`Return _ as r), s -> (`Return, s @ [ r ])
        | `ProcReturn, s -> (`Return, s)
        | `None, s -> (`None, s)
        | `Goto g, s -> (`Goto g, s)
      in
      LBlock (name, phis, stmts, succ)
    in
    match x with
    | Block_NoPhi
        ( BlockIdent (text_range, name),
          addrattr,
          beginlist,
          statements,
          jump,
          endlist ) ->
        tx name [] statements jump
    | Block_Phi
        ( BlockIdent (text_range, name),
          addrattr,
          beginlist,
          phi,
          statements,
          jump,
          endlist ) ->
        tx name phi statements jump

  and param_to_lvar (pp : params) : Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> Var.create id (trans_type t)

  and param_to_formal (pp : params) : string * Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> (id, Var.create id (trans_type t))

  and get_bident_loc g =
    match g with
    | `Global (GlobalIdent (pos, g)) -> pos
    | `Local (LocalIdent (pos, g)) -> pos
    | `Proc (ProcIdent (pos, g)) -> pos
    | `Block (BlockIdent (pos, g)) -> pos

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
             (trans_type type')
    | Expr_Local (LocalVar1 (g, type')) ->
        BasilExpr.rvar
        @@ Var.create ~scope:Local
             (unsafe_unsigil (`Local g))
             (trans_type type')
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
          ~hi_excl:(transIntVal ival0 |> Z.to_int)
          ~lo_incl:(transIntVal intval |> Z.to_int)
          (trans_expr expr)
    | Expr_Concat exprs ->
        BasilExpr.applyintrin ~op:`BVConcat (List.map trans_expr exprs)
    | Expr_Literal (Value_BV (BVVal1 (intval, BVType1 bvtype))) ->
        BasilExpr.bvconst
          (match transBVTYPE bvtype with
          | Bitvector size -> Bitvec.create ~size (transIntVal intval)
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

exception ILBParseError of { input : Pp_loc.Input.t; lexbuf : Lexing.lexbuf }

let format_ploc input =
 fun f ->
  Pp_loc.setup_highlight_tags f
    ~single_line_underline:
      {
        open_tag =
          (fun _ -> Format.ANSI_codes.string_of_style_list [ `Bold; `FG `Red ]);
        close_tag = (fun _ -> Format.ANSI_codes.string_of_style `Reset);
      }
    ();

  Pp_loc.pp ~input ~max_lines:5 f

let show_ilbparseerror e =
  match e with
  | LoadError { input = None; msg } -> msg
  | LoadError
      { input = Some input; msg; token_char_offset_range = Some (btok, etok) }
    ->
      let o =
        Format.asprintf "Error: %s%a%a" msg Format.pp_print_newline ()
          (format_ploc input)
          [ (Pp_loc.Position.of_offset btok, Pp_loc.Position.of_offset etok) ]
      in
      o
  | ILBParseError { input; lexbuf } ->
      let loc =
        [
          ( Pp_loc.Position.of_lexing @@ Lexing.lexeme_start_p lexbuf,
            Pp_loc.Position.of_lexing @@ Lexing.lexeme_end_p lexbuf );
        ]
      in
      let fname = (Lexing.lexeme_end_p lexbuf).pos_fname in
      let lnum = (Lexing.lexeme_end_p lexbuf).pos_lnum in
      let o =
        Format.asprintf "Parse error:  %s:%d%a%a" fname lnum
          Format.pp_print_newline () (format_ploc input) loc
      in
      o
  | _ -> failwith "diff error"

let () =
  Printexc.register_printer (function
    | BasilIR.BNFC_Util.Parse_error (b, e) ->
        let fname = b.pos_fname in
        let x = b.pos_lnum in
        let col = b.pos_cnum - b.pos_bol in
        Some (Printf.sprintf "Parse error in \"%s\" line %d col %d" fname x col)
    | ILBParseError _ as e -> Some (show_ilbparseerror e)
    | LoadError _ as e -> Some (show_ilbparseerror e)
    | _ -> None (* for other exceptions *))

let concrete_prog_ast_of_channel ?input ?filename c =
  let open BasilIR in
  let input = Option.get_or ~default:(Pp_loc.Input.in_channel c) input in
  let lexbuf = Lexing.from_channel ~with_positions:true c in
  filename |> Option.iter (fun f -> Lexing.set_filename lexbuf f);
  try ParBasilIR.pModuleT LexBasilIR.token lexbuf
  with ParBasilIR.Error -> raise (ILBParseError { input; lexbuf })

let concrete_prog_ast_of_string ?input ?filename str =
  let open BasilIR in
  let input = Option.get_or ~default:(Pp_loc.Input.string str) input in
  let lexbuf = Lexing.from_string ~with_positions:true str in
  filename |> Option.iter (fun f -> Lexing.set_filename lexbuf f);
  try ParBasilIR.pModuleT LexBasilIR.token lexbuf
  with ParBasilIR.Error -> raise (ILBParseError { input; lexbuf })

let parse_proc ?input lexbuf =
  let open BasilIR in
  try ParBasilIR.pDecl LexBasilIR.token lexbuf
  with ParBasilIR.Error -> (
    let start_pos = Lexing.lexeme_start_p lexbuf
    and end_pos = Lexing.lexeme_end_p lexbuf in
    match input with
    | Some input -> raise (ILBParseError { input; lexbuf })
    | None -> raise (BNFC_Util.Parse_error (start_pos, end_pos)))

let parse_expr ?input lexbuf =
  let open BasilIR in
  try ParBasilIR.pExpr LexBasilIR.token lexbuf
  with ParBasilIR.Error -> (
    let start_pos = Lexing.lexeme_start_p lexbuf
    and end_pos = Lexing.lexeme_end_p lexbuf in
    match input with
    | Some input -> raise (ILBParseError { input; lexbuf })
    | None -> raise (BNFC_Util.Parse_error (start_pos, end_pos)))

let parse_proc_string st c =
  let lexbuf = Lexing.from_string ~with_positions:true c in
  let input = Pp_loc.Input.string c in
  let proc = parse_proc ~input lexbuf in
  BasilASTLoader.trans_definition st proc

let parse_proc_channel st c =
  let lexbuf = Lexing.from_channel ~with_positions:true c in
  let proc = parse_proc lexbuf in
  BasilASTLoader.trans_definition st proc

let parse_expr_string s =
  let lexbuf = Lexing.from_string ~with_positions:true s in
  let input = Pp_loc.Input.string s in
  let proc = parse_expr ~input lexbuf in
  BasilASTLoader.trans_expr proc

let protect_parse parsefun =
  let parse input lexbuf =
    let open BasilIR in
    try parsefun LexBasilIR.token lexbuf
    with ParBasilIR.Error -> (
      let start_pos = Lexing.lexeme_start_p lexbuf
      and end_pos = Lexing.lexeme_end_p lexbuf in
      match input with
      | Some input -> raise (ILBParseError { input; lexbuf })
      | None -> raise (BNFC_Util.Parse_error (start_pos, end_pos)))
  in
  parse

(** Loads a single block in isolation in a proceudre and returns it, does not
    support procedure calls or returns *)
let load_single_block_proc ?(proc = "<proc>") ?input lexbuf =
  let block = protect_parse BasilIR.ParBasilIR.pBlock input lexbuf in
  let prog, proc = Program.create_single_proc ~name:proc () in
  let st = { prog; params_order = Hashtbl.create 30; curr_proc = Some proc } in
  let bl = BasilASTLoader.trans_block st block in
  let bl = BasilASTLoader.conv_lblock [] proc bl in
  let proc, bid =
    Procedure.fresh_block proc ~name:"blah" ~stmts:bl ~phis:[] ()
  in
  let proc =
    Procedure.map_graph
      (fun g ->
        let g = Procedure.G.add_edge g Entry (Begin bid) in
        Procedure.G.add_edge g (End bid) Return)
      proc
  in
  let prog =
    { prog with procs = ID.Map.add (Procedure.id proc) proc prog.procs }
  in
  let bl = Procedure.get_block proc bid |> Option.get_exn_or "" in
  let globals =
    Iter.append (Block.read_vars_iter bl) (Block.assigned_vars_iter bl)
    |> Iter.filter Var.is_global
    |> Iter.map (fun v -> (Var.name v, v))
    |> Var.Decls.of_iter
  in
  ({ prog with globals }, proc, bl)

let load_single_block ?proc ~input lexbuf =
  let _, _, block = load_single_block_proc ?proc ~input lexbuf in
  block

let parse_single_block_proc ?proc s =
  let lexbuf = Lexing.from_string ~with_positions:true s in
  let input = Pp_loc.Input.string s in
  load_single_block_proc ?proc ~input lexbuf

let parse_single_block s : Program.bloc =
  let lexbuf = Lexing.from_string ~with_positions:true s in
  let input = Pp_loc.Input.string s in
  load_single_block ~input lexbuf

let ast_of_concrete_ast ~name m =
  Trace_core.with_span ~__FILE__ ~__LINE__ "convert-concrete-ast" @@ fun f ->
  BasilASTLoader.trans_program ~name m

let ast_of_string ?__LINE__ ?__FILE__ ?__FUNCTION__ string =
  let name =
    let open Option.Infix in
    let* line = __LINE__ >|= Int.to_string in
    let* file = __FILE__ in
    let func = Option.get_or ~default:"" (__FUNCTION__ >|= fun c -> "::" ^ c) in
    Some ("string at " ^ file ^ ":" ^ line ^ func)
  in
  let name = Option.get_or ~default:"<string>" name in
  let input = Pp_loc.Input.string string in
  let conc = concrete_prog_ast_of_string ~input ~filename:name string in
  try ast_of_concrete_ast ~name conc
  with LoadError { token_char_offset_range; msg } ->
    raise (LoadError { input = Some input; token_char_offset_range; msg })

let ast_of_channel ?input fname c =
  let m =
    Trace_core.with_span ~__FILE__ ~__LINE__ "load-concrete-ast" @@ fun f ->
    let m = concrete_prog_ast_of_channel ?input ~filename:fname c in
    m
  in
  try ast_of_concrete_ast ~name:fname m
  with LoadError { token_char_offset_range; msg } ->
    raise (LoadError { input; token_char_offset_range; msg })

let ast_of_fname fname =
  IO.with_in fname (fun c ->
      ast_of_channel ~input:(Pp_loc.Input.file fname) fname c)

let%expect_test "missing block" =
  let run () =
    ast_of_string
      {|
var $NF: bv1;
var $ZF: bv1;

prog entry @main_4196260;

proc @main_4196260 () -> ()
[
  block %main_entry [
    $NF:bv1 := 1:bv1;
    $ZF:bv1 := 1:bv1;
    goto(%main_7, %main_11);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];
    |}
  in
  ignore @@ disable_backtrace_in run;
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  ( "Error: no such block: %main_7\
   \n12 |     goto(%main_7, %main_11);\
   \n              \027[1;31m^^^^^^^\027[0m\
   \n")
  |}]

let%expect_test "missing proc" =
  let run () =
    ast_of_string
      {|
prog entry @main_4196260;

proc @main_4196260 () -> ()
[
  block %main_entry [
    call @cat_4198032();
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];
    |}
  in
  ignore @@ disable_backtrace_in run;
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  ( "Error: no such procedure: @cat_4198032\
   \n7 |     call @cat_4198032();\
   \n             \027[1;31m^^^^^^^^^^^^\027[0m\
   \n")
  |}]

let%expect_test "syntax error" =
  let run () =
    ast_of_string
      {|
var $NF: bv1;
var $ZF: bv1;
prog entry @main_4196260;
proc @main_4196260 () -> ()
[
  block %main_entry [
    $NF:bv1 := 1:bv1;
    $ZF:bv1 1:bv1;
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];
    |}
  in
  ignore @@ disable_backtrace_in run;
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  ( "Parse error:  <string>:9\
   \n9 |     $ZF:bv1 1:bv1;\
   \n                \027[1;31m^\027[0m\
   \n")
  |}]

let%expect_test "proc without body" =
  let s = {|
prog entry @f;
proc @f (ZF_in:bv1, VF_in:bv1) -> ();
    |} in
  let prog = concrete_prog_ast_of_string s in

  let buf = Buffer.create 100 in
  BasilIR.ShowBasilIR.showModuleT prog buf;
  Buffer.output_buffer stdout buf;
  [%expect
    {| Module1 ([Decl_ProgEmpty (ProcIdent "@f", AttribSet_Empty); Decl_Proc (ProcIdent "@f", [Params1 (LocalIdent "ZF_in", TypeBVType (BVType1 (BVTYPE "bv1"))); Params1 (LocalIdent "VF_in", TypeBVType (BVType1 (BVTYPE "bv1")))], [], AttribSet_Empty, [], ProcDef_Empty)]) |}];

  let ast = ast_of_concrete_ast ~name:"boop" prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Program.prog_pretty ast.prog);
  [%expect
    {|
    prog entry @f;
    proc @f(VF_in:bv1, ZF_in:bv1)  -> ();
    |}]
