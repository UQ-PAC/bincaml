(** Loads a initial IR from the semi-concrete AST *)

open Bincaml_util.Common
open Lang
open Expr
open Logs

type load_st = {
  prog : Program.t;
  curr_proc : Program.proc option;
  params_order :
    (string, (string * Var.t) list * (string * Var.t) list) Hashtbl.t;
}

let load_st_empty ?(name = "<none>") () =
  {
    prog = Program.empty ~name ();
    params_order = Hashtbl.create 30;
    curr_proc = None;
  }

exception
  LoadError of {
    token_char_offset_range : (int * int) option;
    msg : string;
    input : Pp_loc.Input.t option;
  }

let sequence_st p_st f ls =
  let f (p_st, acc) v =
    let p_st, nv = f p_st v in
    (p_st, nv :: acc)
  in
  let p_st, ls = List.fold_left f (p_st, []) ls in
  (p_st, List.rev ls)

open struct
  let map_prog f l = { l with prog = f l.prog }
  let map_curr_proc f l = { l with curr_proc = Option.map f l.curr_proc }

  let read_global p v =
    assert (Var.is_global v);
    let spec = Procedure.specification p in
    if List.exists (fun v2 -> Var.equal v v2) spec.captures_globs then p
    else
      Procedure.set_specification p
        { spec with captures_globs = v :: spec.captures_globs }

  let write_global p v =
    assert (Var.is_global v);
    let p = read_global p v in
    let spec = Procedure.specification p in
    if List.exists (fun v2 -> Var.equal v v2) spec.modifies_globs then p
    else
      Procedure.set_specification p
        { spec with modifies_globs = v :: spec.modifies_globs }
end

type textRange = (int * int) option [@@deriving show { with_path = false }, eq]

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

  and trans_program ?(lst : load_st option) ?(name = "<module>") (x : moduleT) :
      load_st =
    let prog =
      match lst with Some lst -> lst | None -> load_st_empty ~name ()
    in
    let prog =
      match x with
      | Module1 declarations ->
          List.fold_left trans_declaration prog declarations |> fun p ->
          List.fold_left trans_definition p declarations
    in
    map_prog (fun prog -> Spec_modifies.set_modsets ~add_only:true prog) prog

  and var_modifiers_shared (m : varModifiers list) =
    if not @@ List.exists (function Shared | Observable -> true) m then
      Var.GlobalVar
    else Var.GlobalVarShared

  and trans_varspec prog (v : varSpec) =
    let trans_one v =
      match v with
      | VarSpec_Classification v ->
          [ ("classification", `Expr (trans_expr prog v)) ]
      | VarSpec_Empty -> []
    in
    trans_one v

  and trans_typedecl t =
    match t with
    | TypeAssign_Sum (localIdent, typeT) ->
        let n = unsafe_unsigil (`Type localIdent) in
        ( n,
          Types.mk_adt n
            (typeT
            |> List.map (function
              | SortType variant ->
                  (unsafe_unsigil (`TypeConstructor variant), [])
              | VariantCase (variant, _, fields, _) ->
                  ( unsafe_unsigil (`TypeConstructor variant),
                    List.map trans_recordfield fields ))) )

  (** First pass; process like forward declaration: only add the information
      needed to do non-local reslolution of names such as for procedure calls *)
  and trans_declaration prog (x : decl) : load_st =
    match x with
    | Decl_Type sort ->
        let name = unsafe_unsigil (`Type sort) in
        let typ = Types.mk_sort name in
        map_prog (fun prog -> Program.decl_typ prog typ) prog
    | Decl_RecType types ->
        let types = List.map trans_typedecl types in
        List.fold_left
          (fun prog (binding, typ) ->
            map_prog (fun prog -> Program.decl_typ prog typ) prog)
          prog types
    | Decl_Mem (modifiers, bident, type', spec) ->
        let attrib = StringMap.of_list (trans_varspec prog spec) in
        let scope = var_modifiers_shared modifiers in
        map_prog
          (fun p ->
            Program.decl_global p ~attrib
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~scope (trans_type type')))
          prog
    | Decl_Var (modifiers, bident, type', spec) ->
        let attrib = StringMap.of_list (trans_varspec prog spec) in
        let scope = var_modifiers_shared modifiers in
        map_prog
          (fun p ->
            Program.decl_global p ~attrib
              (Var.create
                 (unsafe_unsigil (`Global bident))
                 ~scope (trans_type type')))
          prog
    | Decl_ProgEmpty (ProcIdent (_, id), attr) -> prog
    | Decl_ProgWithSpec (ProcIdent (_, id), attr, spec) -> prog
    | Decl_UninterpFun (glident, _, rettype) ->
        let ftype = trans_type rettype in
        map_prog
          (fun p ->
            Program.decl_global p
              (Var.create
                 (unsafe_unsigil (`Global glident))
                 ~scope:GlobalConst ftype))
          prog
    | Decl_FunNoType (glident, _, _) -> prog
    | Decl_Fun (glident, params, _, typ, _) ->
        let bound = unpac_lambdaparen ~bound:StringMap.empty prog params in
        let arg_types = List.map Var.typ bound in
        let rtype = Types.curry arg_types (trans_type typ) in
        let bvar =
          Var.create (unsafe_unsigil (`Global glident)) ~scope:GlobalConst rtype
        in
        let fundef : Program.declaration =
          Function
            {
              attrib = StringMap.empty;
              binding = bvar;
              definition = Uninterpreted;
            }
        in
        map_prog (fun prog -> Program.add_decl prog fundef) prog
    | Decl_Axiom (name, _, _) ->
        let bvar =
          Var.create (unsafe_unsigil (`Global name)) ~scope:GlobalConst Boolean
        in

        let fundef : Program.declaration =
          Function
            {
              attrib = StringMap.empty;
              binding = bvar;
              definition = Uninterpreted;
            }
        in
        map_prog (fun prog -> Program.add_decl prog fundef) prog
    | Decl_Proc
        ( ProcIdent (id_pos, id),
          _,
          in_params,
          _,
          _,
          out_params,
          _,
          attrib,
          spec,
          definition ) ->
        let proc_id = Program.declare_name id prog.prog in
        let formal_in_params_order = List.map param_to_formal in_params in
        let formal_in_params = formal_in_params_order |> StringMap.of_list in
        let formal_out_params_order = List.map param_to_formal out_params in
        let formal_out_params = StringMap.of_list formal_out_params_order in
        let attrib = trans_attrib_set prog ~binds:formal_in_params attrib in
        Hashtbl.add prog.params_order id
          (formal_in_params_order, formal_out_params_order);
        let is_stub = Stdlib.(definition = ProcDef_Empty) in
        let p =
          Procedure.create proc_id ~attrib ~is_stub ~formal_in_params
            ~formal_out_params ()
        in
        let prog = map_prog (Program.add_proc p) prog in
        prog

  and trans_progspec p_st (p : progSpec) =
    p_st
    |> map_prog (fun prog ->
        let spec = Program.spec prog in
        match p with
        | ProgSpec_Rely (_, b) ->
            Program.set_spec
              { spec with rely = trans_expr p_st b :: spec.rely }
              prog
        | ProgSpec_Guarantee (_, b) ->
            Program.set_spec
              { spec with guarantee = trans_expr p_st b :: spec.guarantee }
              prog)

  (** desugar let definition function *)
  and create_fun prog glident args attrList typ body =
    let bound = unpac_lambdaparen ~bound:StringMap.empty prog args in
    let definition : Program.func_type =
      match body with
      | Some e -> (
          match bound with
          | [] -> Function (trans_expr prog e)
          | args ->
              let binds =
                StringMap.of_list (List.map (fun v -> (Var.name v, v)) args)
              in
              let body =
                BasilExpr.lambda ~bound:args (trans_expr ~binds prog e)
              in
              Function body)
      | None -> Uninterpreted
    in
    let rtype =
      match typ with
      | Some typ ->
          let arg_types = List.map Var.typ bound in
          Types.curry arg_types (trans_type typ)
      | None -> (
          match definition with
          | Function e -> BasilExpr.type_of e
          | _ ->
              raise
                (LoadError
                   {
                     input = None;
                     token_char_offset_range =
                       Some (get_bident_loc (`Global glident));
                     msg = Printf.sprintf "no type defined";
                   }))
    in
    let attrib = trans_attrib_set ~binds:StringMap.empty prog attrList in
    let binding =
      Var.create (unsafe_unsigil (`Global glident)) ~scope:GlobalConst rtype
    in

    let fundef : Program.declaration =
      Function { attrib; binding; definition }
    in
    map_prog (fun prog -> Program.add_decl prog fundef) prog

  (** Second pass: resolve the full definition of all declarations. *)
  and trans_definition prog (x : decl) : load_st =
    match x with
    | Decl_UninterpFun (glident, attrDefList, rettype) ->
        create_fun prog glident [] attrDefList (Some rettype) None
    | Decl_FunNoType (glident, attrList, body) ->
        create_fun prog glident [] attrList None (Some body)
    | Decl_Fun (glident, args, attrList, typ, body) ->
        create_fun prog glident args attrList (Some typ) (Some body)
    | Decl_Axiom (name, attr, body) ->
        let attrib = trans_attrib_set ~binds:StringMap.empty prog attr in
        let body = trans_expr prog body in
        let bvar =
          Var.create (unsafe_unsigil (`Global name)) ~scope:GlobalConst Boolean
        in

        let fundef : Program.declaration =
          Function { attrib; binding = bvar; definition = Axiom body }
        in
        map_prog (fun prog -> Program.add_decl prog fundef) prog
    | Decl_ProgEmpty (ProcIdent (_, id), attr) ->
        let nattrib = trans_attrib_set ~binds:StringMap.empty prog attr in
        prog
        |> map_prog (fun p ->
            Program.set_attrib
              (Attrib.merge_map_shadow (Program.attrib p) nattrib)
              p)
        |> map_prog (fun p ->
            Program.set_entry_proc (Program.get_id_by_name id p) p)
    | Decl_ProgWithSpec (ProcIdent (_, id), attr, spec) ->
        let nattrib = trans_attrib_set ~binds:StringMap.empty prog attr in
        let prog = List.fold_left trans_progspec prog spec in
        prog
        |> map_prog (fun p ->
            Program.set_attrib
              (Attrib.merge_map_shadow (Program.attrib p) nattrib)
              p)
        |> map_prog (fun p ->
            Program.set_entry_proc (Program.get_id_by_name id p) p)
    | Decl_Proc
        ( ProcIdent (id_pos, id),
          _,
          in_params,
          _,
          _,
          out_params,
          _,
          attrs,
          spec_list,
          proc_def ) ->
        let p = Program.get_proc_by_name id prog.prog in
        let prog = { prog with curr_proc = Some p } in
        let prog, blocks =
          match proc_def with
          | ProcDef_Some (bl, blocks, el) -> sequence_st prog trans_block blocks
          | ProcDef_Empty -> (prog, [])
        in
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

        let spec = Procedure.specification p in
        let spec =
          List.fold_left
            (trans_funspec prog (StringMap.of_list formal_out_params_order))
            spec spec_list
        in
        let p = Procedure.set_specification p spec in

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
        map_prog (fun prog -> Program.add_proc p prog) prog
    | Decl_Mem _ | Decl_Var _ | Decl_RecType _ | Decl_Type _ ->
        (* declarations only: handled by first pass *)
        prog

  and transMapType (x : mapType) : Types.t =
    match x with MapType1 (t0, t1) -> Map (trans_type t0, trans_type t1)

  and trans_recordfield field =
    match field with
    | RecordField1 (id, ty) ->
        Types.mk_field (unsafe_unsigil (`Type id)) (trans_type ty)

  and transRECORDTYPE (fields : field list) =
    Types.Struct
      (StringMap.of_list
         ((List.map (function Field1 (field_name, _, t, offset, _) ->
              ( transStr field_name,
                ({ typ = trans_type t; offset = transIntVal offset }
                  : Types.record_field) )))
            fields))

  and transPOINTERTYPE (l : typeT) (u : typeT) =
    Types.Pointer { lower = trans_type l; upper = trans_type u }

  and trans_type (x : typeT) : Types.t =
    match x with
    | TypeIntType inttype -> Integer
    | TypeBoolType booltype -> Boolean
    | TypeMapType maptype -> transMapType maptype
    | TypeBVType (BVType1 bvtype) -> transBVTYPE bvtype
    | TypeParen (_, typeT, _) -> trans_type typeT
    | TypeVarType name -> Types.Variable (unsafe_unsigil (`Type name))
    | TypeRecordType (RecordType1 (_, fields, _)) -> transRECORDTYPE fields
    | TypePointerType (PointerType1 (_, l, u, _)) -> transPOINTERTYPE l u

  and transIntVal (x : intVal) : PrimInt.t =
    match x with
    | IntVal_Hex (IntegerHex (_, ihex)) -> Z.of_string ihex
    | IntVal_Dec (IntegerDec (_, i)) -> Z.of_string i

  and trans_endian (x : BasilIR.AbsBasilIR.endian) =
    match x with Endian_Little -> `Little | Endian_Big -> `Big

  and trans_var ?(binds = StringMap.empty) p_st (v : var) =
    match v with
    | VarLocalVar (LocalTyped (localVar, ty)) -> (
        try lookup_local_decl ~binds localVar p_st
        with e ->
          let v =
            Var.create ~scope:LocalVar
              (unsafe_unsigil (`Local localVar))
              (trans_type ty)
          in
          Logs.warn (fun m ->
              m "global undeclared %s. assuming mutable unshared" @@ Var.name v);
          v)
    | VarLocalVar (LocalUntyped localVar) ->
        lookup_local_decl ~binds localVar p_st
    | VarGlobalVar (GlobalTyped (globalVar, ty)) -> (
        try lookup_global_decl globalVar p_st
        with e ->
          let v =
            Var.create ~scope:GlobalVar
              (unsafe_unsigil (`Global globalVar))
              (trans_type ty)
          in
          Logs.warn (fun m ->
              m "Warn: global undeclared %s. assuming mutable unshared"
                (Var.name v));
          v)
    | VarGlobalVar (GlobalUntyped globalVar) ->
        lookup_global_decl globalVar p_st

  and trans_attr_kv ~binds p_st kv : Expr.BasilExpr.t Attrib.attrib_map =
    List.map
      (function
        | AttrKeyValue1 (bident, attr) ->
            (unsafe_unsigil (`Attr bident), trans_attr ~binds p_st attr))
      kv
    |> StringMap.of_list

  and trans_str (s : str) = match s with Str s -> stripquote s

  and trans_attr p_st ~binds (attr : attr) : [> Expr.BasilExpr.t Attrib.t ] =
    match attr with
    | Attr_Map (_, keyvals, _) -> `Assoc (trans_attr_kv ~binds p_st keyvals)
    | Attr_List (_, ls, _) -> `List (List.map (trans_attr ~binds p_st) ls)
    | Attr_Expr expr -> `Expr (trans_expr ~binds p_st expr)
    | Attr_Str s -> `String (trans_str s)

  and trans_attrib_set ~binds p_st (atrs : attribSet) :
      Expr.BasilExpr.t Attrib.attrib_map =
    match atrs with
    | AttribSet_Empty -> StringMap.empty
    | AttribSet_Some (_, attrKeyValue, _) ->
        trans_attr_kv ~binds p_st attrKeyValue

  and trans_stmt (p_st : load_st) (x : BasilIR.AbsBasilIR.stmtWithAttrib) :
      load_st
      * [> `Call of (Var.t, 'a, BasilExpr.t) Stmt.t
        | `None
        | `Stmt of (Var.t, Var.t, BasilExpr.t) Stmt.t ] =
    let stmt = match x with StmtWithAttrib1 (stmt, _) -> stmt in
    let open Stmt in
    match stmt with
    | Stmt_Nop -> (p_st, `None)
    | Stmt_Load_Var (lvar, endian, var, expr, intval) ->
        let endian = trans_endian endian in
        let rhs = trans_var p_st var in
        let size = transIntVal intval |> Z.to_int in
        let p_st, lhs = trans_lvar p_st lvar in
        ( p_st,
          `Stmt
            (Instr_Load
               {
                 lhs;
                 rhs;
                 addr = Addr { addr = trans_expr p_st expr; endian; size };
               }) )
    | Stmt_Store_Var (lhs, endian, var, addr, value, intval) ->
        let endian = trans_endian endian in
        let size = transIntVal intval |> Z.to_int in
        let rhs = trans_var p_st var in
        let p_st, lhs = trans_lvar p_st lhs in
        ( p_st,
          `Stmt
            (Instr_Store
               {
                 lhs;
                 rhs;
                 value = trans_expr p_st value;
                 addr = Addr { addr = trans_expr p_st addr; size; endian };
               }) )
    | Stmt_Store (endian, bident, addr, value, intval) ->
        let endian = trans_endian endian in
        let size = transIntVal intval |> Z.to_int in
        let mem = lookup_global_decl bident p_st in
        ( p_st,
          `Stmt
            (Instr_Store
               {
                 lhs = mem;
                 rhs = mem;
                 value = trans_expr p_st value;
                 addr = Addr { addr = trans_expr p_st addr; size; endian };
               }) )
    | Stmt_SingleAssign (Assignment1 (lvar, expr)) ->
        let expr = trans_expr p_st expr in
        let p_st, lv = trans_lvar p_st lvar in
        (p_st, `Stmt (Instr_Assign [ (lv, expr) ]))
    | Stmt_MemAssign (lvar, expr) ->
        let expr = trans_expr p_st expr in
        let p_st, lv = trans_lvar p_st lvar in
        ( p_st,
          `Stmt
            (Instr_Store { lhs = lv; rhs = lv; value = expr; addr = Scalar }) )
    | Stmt_ScalarStore (lvar, expr) ->
        let expr = trans_expr p_st expr in
        let p_st, lv = trans_lvar p_st lvar in
        ( p_st,
          `Stmt
            (Instr_Store { lhs = lv; rhs = lv; value = expr; addr = Scalar }) )
    | Stmt_ScalarLoad (lvar, rvar) ->
        let rhs = trans_var p_st rvar in
        let p_st, lv = trans_lvar p_st lvar in
        (p_st, `Stmt (Instr_Load { lhs = lv; rhs; addr = Scalar }))
    | Stmt_MultiAssign (o, assigns, c) ->
        let f (p_st, assigns) v =
          match v with
          | Assignment1 (l, r) ->
              let e = trans_expr p_st r in
              let p_st, d = trans_lvar p_st l in
              (p_st, (d, e) :: assigns)
        in
        let p_st, assigns = List.fold_left f (p_st, []) assigns in
        (p_st, `Stmt (Instr_Assign (List.rev assigns)))
    | Stmt_DirectCall (calllvars, bident, o, exprs, c)
      when Option.is_some @@ Intrinsic.of_string (unsafe_unsigil (`Proc bident))
      ->
        let p_st, lhs = trans_intrin_lhs p_st calllvars in
        let name =
          Intrinsic.of_string (unsafe_unsigil (`Proc bident))
          |> Option.get_exn_or "unreachable"
        in
        let args =
          match exprs with
          | CallParams_Exprs e -> List.map (trans_expr p_st) e
          | CallParams_Named _ -> failwith "intrin args are ordered not named"
        in
        (p_st, `Call (Instr_IntrinCall { lhs; name; args }))
    | Stmt_DirectCall (calllvars, bident, o, exprs, c) ->
        let n = unsafe_unsigil (`Proc bident) in
        let procid =
          try Procedure.id @@ Program.get_proc_by_name n p_st.prog
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
        let p_st, lhs =
          trans_call_lhs p_st (List.map fst out_param) calllvars
        in
        let args = trans_call_rhs p_st in_param exprs in
        (p_st, `Call (Instr_Call { lhs; procid; args }))
    | Stmt_IndirectCall expr ->
        (p_st, `Call (Instr_IndirectCall { target = trans_expr p_st expr }))
    | Stmt_Assume expr ->
        ( p_st,
          `Stmt (Instr_Assume { body = trans_expr p_st expr; branch = false })
        )
    | Stmt_Guard expr ->
        ( p_st,
          `Stmt (Instr_Assume { body = trans_expr p_st expr; branch = true }) )
    | Stmt_Assert expr ->
        (p_st, `Stmt (Instr_Assert { body = trans_expr p_st expr }))

  and trans_call_rhs p_st in_param (x : callParams) =
    let trans_expr = trans_expr p_st in
    match x with
    | CallParams_Exprs exprs ->
        List.combine (List.map fst in_param) (List.map trans_expr exprs)
        |> StringMap.of_list
    | CallParams_Named nl ->
        nl
        |> List.map (function NamedCallArg1 (li, e) ->
            (unsafe_unsigil (`Local li), trans_expr e))
        |> StringMap.of_list

  and trans_intrin_lhs prog (x : lVars) : load_st * Var.t list =
    let vars : Var.t list =
      match x with
      | LVars_Empty -> []
      | LVars_LocalList (_, lvars, _) -> unpack_local_lvars prog false lvars
      | LVars_LocalConstList (_, lvars, _) -> unpack_local_lvars prog true lvars
      | LVars_List (_, lvars, _) ->
          let f (prog, lvars) v =
            let prog, lvar = trans_lvar prog v in
            (prog, lvar :: lvars)
          in
          let prog, lvars = List.fold_left f (prog, []) lvars in
          List.rev lvars
      | _ -> failwith "intrinsic params are ordered not named"
    in
    let prog = vars |> List.fold_left (fun a b -> assign_var a b |> fst) prog in
    (prog, vars)

  and trans_call_lhs prog (formal_out : string list) (x : lVars) :
      load_st * Var.t StringMap.t =
    let vars =
      match x with
      | LVars_Empty -> StringMap.empty
      | LVars_LocalList (_, lvars, _) ->
          List.combine formal_out (unpack_local_lvars prog false lvars)
          |> StringMap.of_list
      | LVars_LocalConstList (_, lvars, _) ->
          List.combine formal_out (unpack_local_lvars prog true lvars)
          |> StringMap.of_list
      | LVars_List (_, lvars, _) ->
          let f (prog, lvars) v =
            let prog, lvar = trans_lvar prog v in
            (prog, lvar :: lvars)
          in
          let prog, lvars = List.fold_left f (prog, []) lvars in
          List.combine formal_out (List.rev lvars) |> StringMap.of_list
      | NamedLVars_List (_, lvars, _) ->
          let f (p_st, ls) v =
            match v with
            | NamedCallReturn1 (lVar, ident) ->
                let p_st, v = trans_lvar prog lVar in
                (p_st, (unsafe_unsigil (`Local ident), v) :: ls)
          in
          let p_st, lvars = lvars |> List.fold_left f (prog, []) in
          StringMap.of_list lvars
    in
    let prog =
      StringMap.values vars |> Iter.fold (fun a b -> assign_var a b |> fst) prog
    in
    (prog, vars)

  and unpack_local_lvars ?(bound = StringMap.empty) p_st const lvs : Var.t list
      =
    let scope = if const then Var.LocalConst else LocalVar in
    lvs
    |> List.map (function
      | LocalTyped (i, t) ->
          Var.create ~scope (unsafe_unsigil (`Local i)) (trans_type t)
      | LocalUntyped i -> lookup_local_decl ~binds:bound i p_st)

  and unpac_lambdaparen ?(bound = StringMap.empty) p_st lvs : Var.t list =
    unpack_local_lvars ~bound p_st true
    @@ List.map
         (function LocalVarParen1 (_, i, t, _) -> LocalTyped (i, t))
         lvs

  and trans_jump p_st (x : BasilIR.AbsBasilIR.jumpWithAttrib) =
    let jump = match x with JumpWithAttrib1 (jump, _) -> jump in
    match jump with
    | Jump_GoTo (_, bidents, _) -> `Goto bidents
    | Jump_Unreachable -> `None
    | Jump_Return (_, exprs, _) -> `Return (List.map (trans_expr p_st) exprs)
    | Jump_ProcReturn -> `ProcReturn

  and assign_var (prog : load_st) v =
    let p = Option.get_exn_or "no active proc" prog.curr_proc in
    match Var.scope v with
    | Var.LocalVar | Var.LocalConst ->
        (prog, Procedure.decl_local p v) (* decl is side-effecting *)
    | Var.GlobalVar | Var.GlobalVarShared ->
        (map_curr_proc (fun p -> write_global p v) prog, v)
    | Var.GlobalConst -> failwith "assignment to global constant"

  and trans_lvar prog (x : BasilIR.AbsBasilIR.lVar) : load_st * Var.t =
    match x with
    | LVar_Local (LocalTyped (bident, type')) ->
        assign_var prog
          (Var.create ~scope:LocalVar
             (unsafe_unsigil (`Local bident))
             (trans_type type'))
    | LVar_LocalConst (LocalTyped (bident, type')) ->
        assign_var prog
          (Var.create ~scope:LocalConst
             (unsafe_unsigil (`Local bident))
             (trans_type type'))
    | LVar_LocalConst (LocalUntyped _) -> failwith "type annotation needed"
    | LVar_Global (GlobalTyped (bident, type')) ->
        let v =
          try lookup_global_decl bident prog
          with e ->
            let v =
              Var.create ~scope:GlobalVar
                (unsafe_unsigil (`Global bident))
                (trans_type type')
            in
            print_endline @@ "Warn: global undeclared " ^ Var.name v
            ^ " assuming mutable unshared";
            v
        in
        assign_var prog v
    | LVar_Local (LocalUntyped bident) ->
        let v = lookup_local_decl bident prog in
        assign_var prog v
    | LVar_Global (GlobalUntyped bident) ->
        let v = lookup_global_decl bident prog in
        assign_var prog v

  and list_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginList ((i, j), l) -> i in
    let ed = match endlist with EndList ((i, j), l) -> j in
    Some (beg, ed)

  and rec_begin_end_to_textrange beginlist endlist : textRange =
    let beg = match beginlist with BeginRec ((i, j), l) -> i in
    let ed = match endlist with EndRec ((i, j), l) -> j in
    Some (beg, ed)

  and expr_range_attr bl el : Expr.BasilExpr.t Lang.Attrib.t =
    match (bl, el) with
    | OpenParen ((a, _), _), CloseParen ((_, b), _) -> Attrib.attr_of_loc (a, b)

  and join_ranges bl el : Expr.BasilExpr.t Lang.Attrib.t =
    match (Attrib.find_loc_opt bl, Attrib.find_loc_opt el) with
    | Some (b, _), Some (_, e) -> Attrib.attr_of_loc (b, e)
    | _ -> `Assoc StringMap.empty

  and trans_block (prog : load_st) (x : BasilIR.AbsBasilIR.block) =
    let tx name (phis : phiAssign list) statements jump =
      let find_block_ident name =
        (Procedure.block_ids
           (prog.curr_proc |> Option.get_exn_or "currproc not set"))
          .decl_or_get
          name
      in
      let tx_phi p_st e : load_st * Var.t Block.phi =
        match e with
        | PhiAssign1 (v, _, phexprs, _) ->
            let rhs =
              List.map
                (function
                  | PhiExpr1 (blockIdent, var) ->
                      ( find_block_ident (unsafe_unsigil (`Block blockIdent)),
                        trans_var prog var ))
                phexprs
            in
            let p_st, lhs = trans_lvar prog v in
            (p_st, { lhs; rhs })
      in
      let p_st, phis = sequence_st prog tx_phi phis in
      let prog, stmts = sequence_st prog trans_stmt statements in
      let stmts =
        List.filter_map
          (function
            | `Call c -> Some (`Stmt c)
            | `Stmt c -> Some (`Stmt c)
            | `None -> None)
          stmts
      in
      let succ = trans_jump prog jump in
      let succ, stmts =
        match (succ, stmts) with
        | (`Return _ as r), s -> (`Return, s @ [ r ])
        | `ProcReturn, s -> (`Return, s)
        | `None, s -> (`None, s)
        | `Goto g, s -> (`Goto g, s)
      in
      (p_st, LBlock (name, phis, stmts, succ))
    in
    match x with
    | Block_NoPhi
        ( BlockIdent (text_range, name),
          addrattr,
          BeginList _,
          statements,
          jump,
          EndList _ ) ->
        tx name [] statements jump
    | Block_Phi
        ( BlockIdent (text_range, name),
          addrattr,
          OpenParen _,
          phi,
          CloseParen _,
          BeginList _,
          statements,
          jump,
          EndList _ ) ->
        tx name phi statements jump

  and param_to_lvar (pp : params) : Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> Var.create id (trans_type t)

  and param_to_formal (pp : params) : string * Var.t =
    match pp with
    | Params1 (LocalIdent (pos, id), t) -> (id, Var.create id (trans_type t))

  and trans_funspec prog bound_post
      (spec : (Var.t, BasilExpr.t) Procedure.proc_spec) (s : funSpec) :
      (Var.t, BasilExpr.t) Procedure.proc_spec =
    match s with
    | FunSpec_Require (_, e) ->
        { spec with requires = trans_expr prog e :: spec.requires }
    | FunSpec_Ensure (_, e) ->
        {
          spec with
          ensures = trans_expr ~binds:bound_post prog e :: spec.ensures;
        }
    | FunSpec_Rely (_, e) -> { spec with rely = trans_expr prog e :: spec.rely }
    | FunSpec_Guar (_, e) -> { spec with rely = trans_expr prog e :: spec.rely }
    | FunSpec_Captures v ->
        {
          spec with
          captures_globs =
            List.map (fun v -> trans_var prog (VarGlobalVar v)) v
            @ spec.captures_globs;
        }
    | FunSpec_Modifies v ->
        {
          spec with
          modifies_globs =
            List.map (fun v -> trans_var prog (VarGlobalVar v)) v
            @ spec.modifies_globs;
        }
    | FunSpec_Invariant (_, _) -> spec

  and get_bident_loc g =
    match g with
    | `Global (GlobalIdent (pos, g)) -> pos
    | `Local (LocalIdent (pos, g)) -> pos
    | `Proc (ProcIdent (pos, g)) -> pos
    | `Block (BlockIdent (pos, g)) -> pos

  and lookup_local_decl ?(binds = StringMap.empty) ident p_st =
    let vn = unsafe_unsigil (`Local ident) in
    let token_char_offset_range = Some (get_bident_loc (`Local ident)) in
    try
      match StringMap.find_opt vn binds with
      | Some v -> v
      | None -> (
          match Program.get_implicit_decl_by_name vn p_st.prog with
          | Some (VariantCase { constructor }) -> constructor
          | None ->
              Procedure.lookup_local_decl
                (Option.get_exn_or "variable not bound and not in proc scope"
                   p_st.curr_proc)
                vn
              |> Option.get_exn_or "no declaration")
    with
    | Not_found ->
        let msg = "local variable used before declaration : " ^ vn in
        raise (LoadError { token_char_offset_range; msg; input = None })
    | Invalid_argument m ->
        let msg = m ^ " " ^ vn in
        raise (LoadError { token_char_offset_range; msg; input = None })

  and lookup_constructor p_st ident =
    let vn = unsafe_unsigil (`Local ident) in
    match Program.get_implicit_decl_by_name vn p_st.prog with
    | Program.(Some (VariantCase { constructor })) -> constructor
    | _ ->
        let token_char_offset_range = Some (get_bident_loc (`Local ident)) in
        let msg = "Unable to find constructor for:" ^ vn in
        raise (LoadError { token_char_offset_range; msg; input = None })

  and lookup_type p_st ident =
    let vn = unsafe_unsigil (`Local ident) in
    let token_char_offset_range = Some (get_bident_loc (`Local ident)) in
    let fail () =
      let msg = "Unable to find type declaration for:" ^ vn in
      raise (LoadError { token_char_offset_range; msg; input = None })
    in
    match Program.get_decl_by_name vn p_st.prog with
    | Some (Type { typ }) -> typ
    | None -> (
        match Program.get_implicit_decl_by_name vn p_st.prog with
        | Program.(Some (VariantCase { belongs_to })) -> belongs_to
        | _ -> fail ())
    | _ -> fail ()

  and lookup_global_decl ident p_st =
    let vn = unsafe_unsigil (`Global ident) in
    let token_char_offset_range = Some (get_bident_loc (`Global ident)) in
    match Program.get_decl_by_name vn p_st.prog with
    | Some (Variable { binding }) -> binding
    | Some (Function { binding }) -> binding
    | Some (Type _) ->
        let msg = "found type declaration when looking for variable:" ^ vn in
        raise (LoadError { token_char_offset_range; msg; input = None })
    | None -> (
        match Program.get_implicit_decl_by_name vn p_st.prog with
        | Some (VariantCase { constructor }) -> constructor
        | None ->
            let msg = "global variable used before declaration : " ^ vn in
            raise (LoadError { token_char_offset_range; msg; input = None }))
    | Some (Procedure _) -> failwith ""

  and trans_bv_val v : Bitvec.t =
    match v with
    | BVVal1 (intval, BVType1 bvtype) -> (
        match transBVTYPE bvtype with
        | Bitvector size -> Bitvec.create ~size (transIntVal intval)
        | _ -> failwith "unreachable")

  and trans_value v : Ops.AllOps.const =
    match v with
    | Value_BV v -> `Bitvector (trans_bv_val v)
    | Value_Int intval -> `Integer (transIntVal intval)
    | Value_True -> `Bool true
    | Value_False -> `Bool false
    | Value_Pointer (_, v, PointerType1 (_, l, u, _), _) ->
        `Pointer (trans_bv_val v, { lower = trans_type l; upper = trans_type u })
    | Value_Record (_, _, fields, _, typ, _) ->
        `Record
          ( StringMap.of_list
              (List.map
                 (function
                   | FieldVal1 (_, offset, value, typ, _) ->
                       ( transStr offset,
                         ({ value = trans_bv_val value; typ = trans_type typ }
                           : Ops.Record.field) ))
                 fields),
            trans_type typ )

  and unsafe_unsigil g : string =
    match g with
    | `Type (LocalIdent (pos, g)) ->
        if String.take 1 g |> String.for_all Char.is_lowercase_ascii then g
        else failwith ("Invalid type name: " ^ g ^ " must start with lowercase.")
    | `TypeConstructor (LocalIdent (pos, g)) ->
        if String.take 1 g |> String.for_all Char.is_uppercase_ascii then g
        else
          failwith
            ("Invalid type constuctor name: " ^ g
           ^ " must start with lowercase.")
    | `Global (GlobalIdent (pos, g)) -> g
    | `Local (LocalIdent (pos, g)) -> g
    | `Proc (ProcIdent (pos, g)) -> g
    | `Block (BlockIdent (pos, g)) -> g
    | `Attr (BIdent (pos, g)) -> g

  and trans_cases p_st c =
    let cases =
      c
      |> List.map (function
        | CaseCase (o, e) ->
            BasilExpr.binexp ~op:`IfThen (trans_expr p_st o) (trans_expr p_st e)
        | CaseDefault e ->
            BasilExpr.binexp ~op:`IfThen (BasilExpr.boolconst true)
              (trans_expr p_st e))
    in
    BasilExpr.applyintrin ~op:`Cases cases

  and trans_match p_st arg c =
    let cases =
      c
      |> List.map (function
        | CaseCase (o, e) ->
            BasilExpr.binexp ~op:`IfThen
              (BasilExpr.binexp ~op:`EQ arg (trans_expr p_st o))
              (trans_expr p_st e)
        | CaseDefault e ->
            BasilExpr.binexp ~op:`IfThen (BasilExpr.boolconst true)
              (trans_expr p_st e))
    in
    BasilExpr.applyintrin ~op:`Cases cases

  and trans_field_assign trans_expr (f : fieldAssign) =
    match f with
    | FieldAssign1 (k, v) -> (unsafe_unsigil (`Local k), trans_expr v)

  and trans_expr ?(binds = StringMap.empty) (p_st : load_st)
      (x : BasilIR.AbsBasilIR.expr) : BasilExpr.t =
    let trans_expr ?(nbinds = []) =
      trans_expr
        ~binds:
          (StringMap.add_list binds
             (List.map (fun v -> (Var.name v, v)) nbinds))
        p_st
    in
    let open Ops in
    match x with
    | Expr_Match (e, o, cases, c) ->
        let e = trans_expr e in
        trans_match p_st e cases
    | Expr_Cases (o, cases, c) -> trans_cases p_st cases
    | Expr_Paren (o, e, c) ->
        trans_expr e |> BasilExpr.unfix
        |> AbstractExpr.map_attrib (function
          | None -> Some (expr_range_attr o c)
          | Some e -> Some (Attrib.merge_assoc_shadow e (expr_range_attr o c)))
        |> BasilExpr.fix
    | Expr_Global (GlobalUntyped g) ->
        BasilExpr.rvar @@ lookup_global_decl g p_st
    | Expr_Global (GlobalTyped (g, type')) ->
        let v =
          try lookup_global_decl g p_st
          with e ->
            let v =
              Var.create ~scope:GlobalVar
                (unsafe_unsigil (`Global g))
                (trans_type type')
            in
            Logs.warn (fun m ->
                m "Warn: undeclared global referenced in expr, %s"
                  (Var.to_string v));
            v
        in
        BasilExpr.rvar v
    | Expr_Local (LocalUntyped g) ->
        BasilExpr.rvar @@ lookup_local_decl ~binds g p_st
    | Expr_Local (LocalTyped (g, type')) -> (
        try BasilExpr.rvar @@ lookup_local_decl ~binds g p_st
        with Not_found | LoadError _ ->
          let v =
            Var.create ~scope:LocalVar
              (unsafe_unsigil (`Local g))
              (trans_type type')
          in
          (*print_endline @@ "warn: local use before def: " ^ Var.to_string v;*)
          BasilExpr.rvar v)
    | Expr_Assoc (binop, _, rs, _) -> (
        match trans_intrinop binop with
        | #AllOps.intrin as op ->
            BasilExpr.applyintrin ~op (List.map trans_expr rs)
        | _ -> failwith "non-associative operator")
    | Expr_Binary (binop, _, expr0, expr, _) -> (
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
    | Expr_Unary (unop, o, expr, c) ->
        BasilExpr.unexp ~attrib:(expr_range_attr o c) ~op:(transUnOp unop)
          (trans_expr expr)
    | Expr_ZeroExtend (o, intval, expr, c) ->
        BasilExpr.zero_extend ~attrib:(expr_range_attr o c)
          ~n_prefix_bits:(Z.to_int @@ transIntVal intval)
          (trans_expr expr)
    | Expr_SignExtend (o, intval, expr, c) ->
        BasilExpr.sign_extend ~attrib:(expr_range_attr o c)
          ~n_prefix_bits:(Z.to_int @@ transIntVal intval)
          (trans_expr expr)
    | Expr_Extract (o, ival0, intval, expr, c) ->
        BasilExpr.extract ~attrib:(expr_range_attr o c)
          ~hi_excl:(transIntVal ival0 |> Z.to_int)
          ~lo_incl:(transIntVal intval |> Z.to_int)
          (trans_expr expr)
    | Expr_FieldSet (record, fname, value) ->
        let fname = unsafe_unsigil (`Local fname) in
        BasilExpr.field_store ~field:fname (trans_expr record)
          (trans_expr value)
    | Expr_Field (record, fname) ->
        let fname =
          String.chop_prefix ~pre:"." @@ unsafe_unsigil (`Attr fname)
          |> Option.get_exn_or "safe by parser"
        in
        BasilExpr.field_read ~field:fname (trans_expr record)
    | SortValRec (variant, bi, fields, ei) ->
        let f = BasilExpr.rvar @@ lookup_constructor p_st variant in
        BasilExpr.apply_fun ~func:f
          (List.map (trans_field_assign trans_expr) fields |> List.map snd)
    | Expr_Ite (cond, t, e) ->
        BasilExpr.ifthenelse (trans_expr cond) (trans_expr t) (trans_expr e)
    | Expr_LoadLe (o, intval, a1, a2, c) ->
        BasilExpr.load ~attrib:(expr_range_attr o c)
          ~bits:(Z.to_int @@ transIntVal intval)
          `Little (trans_expr a1) (trans_expr a2)
    | Expr_LoadBe (o, intval, a1, a2, c) ->
        BasilExpr.load ~attrib:(expr_range_attr o c)
          ~bits:(Z.to_int @@ transIntVal intval)
          `Big (trans_expr a1) (trans_expr a2)
    | Expr_Literal v -> (
        match trans_value v with #BasilExpr.const as v -> BasilExpr.const v)
    | Expr_Old (o, e, c) ->
        BasilExpr.unexp ~attrib:(expr_range_attr o c) ~op:`Old (trans_expr e)
    | Expr_Forall (attrs, LambdaDef1 (lv, _, e)) ->
        let bound = unpac_lambdaparen ~bound:StringMap.empty p_st lv in
        let binds =
          StringMap.add_list binds (List.map (fun v -> (Var.name v, v)) bound)
        in
        let attrib = `Assoc (trans_attrib_set ~binds p_st attrs) in
        BasilExpr.forall ~attrib ~bound (trans_expr ~nbinds:bound e)
    | Expr_Lambda (attrs, LambdaDef1 (lv, _, e)) ->
        let bound = unpac_lambdaparen ~bound:StringMap.empty p_st lv in
        let binds =
          StringMap.add_list binds (List.map (fun v -> (Var.name v, v)) bound)
        in
        let attrib = `Assoc (trans_attrib_set ~binds p_st attrs) in
        BasilExpr.lambda ~attrib ~bound (trans_expr ~nbinds:bound e)
    | Expr_Let (id, param, rt, body, in_expr) ->
        let id = unsafe_unsigil (`Local id) in
        let bound = unpac_lambdaparen ~bound:StringMap.empty p_st param in
        let funct = Types.curry (List.map Var.typ bound) (trans_type rt) in
        let funvar = Var.create id funct ~scope:LocalConst in
        let func =
          match bound with
          | [] -> trans_expr ~nbinds:bound body
          | args -> BasilExpr.lambda ~bound (trans_expr ~nbinds:bound body)
        in
        let in_expr = trans_expr ~nbinds:[ funvar ] in_expr in
        BasilExpr.letexp [ (funvar, func) ] in_expr
    | Expr_Exists (attrs, LambdaDef1 (lv, _, e)) ->
        let bound = unpac_lambdaparen ~bound:StringMap.empty p_st lv in
        let binds =
          StringMap.add_list binds (List.map (fun v -> (Var.name v, v)) bound)
        in
        let attrib = `Assoc (trans_attrib_set ~binds p_st attrs) in
        BasilExpr.exists ~attrib ~bound (trans_expr ~nbinds:bound e)
    | Expr_FunctionOp (func, o, args, c) ->
        let func = trans_expr func in
        BasilExpr.apply_fun ~func ~attrib:(expr_range_attr o c)
          (List.map trans_expr args)

  and transBinOp (x : BasilIR.AbsBasilIR.binOp) =
    match x with
    | BinOpBVBinOp bvbinop -> transBVBinOp bvbinop
    | BinOpBVLogicalBinOp bvlogicalbinop -> transBVLogicalBinOp bvlogicalbinop
    | BinOpIntLogicalBinOp intlogicalbinop ->
        transIntLogicalBinOp intlogicalbinop
    | BinOpIntBinOp intbinop -> transIntBinOp intbinop
    | BinOpEqOp equop -> transEqOp equop
    | BinOpPointerBinOp pointerBinOp -> transPointerBinOp pointerBinOp
    | BinOp_implies -> `IMPLIES

  and transUnOp (x : BasilIR.AbsBasilIR.unOp) =
    match x with
    | UnOpBVUnOp bvunop -> transBVUnOp bvunop
    | UnOp_boolnot -> `BoolNOT
    | UnOp_intneg -> `INTNEG
    | UnOp_booltobv1 -> `BOOLTOBV1
    | UnOp_gamma -> `Gamma
    | UnOp_classification -> `Classification

  and transBVUnOp (x : bVUnOp) =
    match x with BVUnOp_bvnot -> `BVNOT | BVUnOp_bvneg -> `BVNEG

  and transBVBinOp (x : BasilIR.AbsBasilIR.bVBinOp) =
    match x with
    | BVBinOp_bvudiv -> `BVUDIV
    | BVBinOp_bvurem -> `BVUREM
    | BVBinOp_bvshl -> `BVSHL
    | BVBinOp_bvlshr -> `BVLSHR
    | BVBinOp_bvnand -> `BVNAND
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

  and transPointerBinOp (x : pointerBinOp) =
    match x with PointerBinOp_ptradd -> `PTRADD

  and transIntLogicalBinOp (x : intLogicalBinOp) =
    match x with
    | IntLogicalBinOp_intlt -> `INTLT
    | IntLogicalBinOp_intle -> `INTLE
    | IntLogicalBinOp_intgt -> `INTGT
    | IntLogicalBinOp_intge -> `INTGE

  and trans_intrinop (x : intrinOp) =
    match x with
    | IntrinOp_booland -> `AND
    | IntrinOp_boolor -> `OR
    | IntrinOp_bvand -> `BVAND
    | IntrinOp_bvor -> `BVOR
    | IntrinOp_bvadd -> `BVADD
    | IntrinOp_bvxor -> `BVXOR
    | IntrinOp_bvconcat -> `BVConcat
    | IntrinOp_bvmul -> `BVMUL
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
  let e = parse_expr ~input lexbuf in
  BasilASTLoader.trans_expr (load_st_empty ()) e

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
  let st, bl = BasilASTLoader.trans_block st block in
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
  let bl = Procedure.get_block proc bid |> Option.get_exn_or "" in
  let inparam =
    Block.free_vars bl |> VarSet.filter Var.is_local |> VarSet.to_list
    |> List.map (fun x -> (Var.name x, x))
    |> StringMap.of_list
  in
  let proc = Procedure.map_formal_in_params (fun _ -> inparam) proc in
  let prog = Program.add_proc proc prog in
  let prog =
    Iter.append (Block.read_vars_iter bl) (Block.assigned_vars_iter bl)
    |> Iter.filter Var.is_global
    |> Iter.fold
         (fun prog v ->
           Program.add_decl prog
             (Program.Variable { binding = v; attrib = StringMap.empty }))
         prog
  in
  (prog, proc, bl)

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

let ast_of_concrete_ast ?(lst : load_st option) ~name m =
  Trace_core.with_span ~__FILE__ ~__LINE__ "convert-concrete-ast" @@ fun f ->
  let e = BasilASTLoader.trans_program ?lst ~name m in
  Program.procs e.prog |> Iter.map snd |> Iter.iter Lang.Check.wf_checks;
  e

let ast_of_string ?(lst : load_st option) ?__LINE__ ?__FILE__ ?__FUNCTION__
    string =
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
  try ast_of_concrete_ast ?lst ~name conc
  with LoadError { token_char_offset_range; msg } ->
    raise (LoadError { input = Some input; token_char_offset_range; msg })

let ast_of_channel ?(lst : load_st option) ?input fname c =
  let m =
    Trace_core.with_span ~__FILE__ ~__LINE__ "load-concrete-ast" @@ fun f ->
    let m = concrete_prog_ast_of_channel ?input ~filename:fname c in
    m
  in
  try ast_of_concrete_ast ?lst ~name:fname m
  with LoadError { token_char_offset_range; msg } ->
    raise (LoadError { input; token_char_offset_range; msg })

let ast_of_fname ?(lst : load_st option) fname =
  IO.with_in fname (fun c ->
      ast_of_channel ?lst ~input:(Pp_loc.Input.file fname) fname c)

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
    :bv1 := 1:bv1;
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
  ( "Parse error:  <string>:8\
   \n8 |     :bv1 := 1:bv1;\
   \n        \027[1;31m^\027[0m\
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
    {| Module1 ([Decl_ProgEmpty (ProcIdent "@f", AttribSet_Empty); Decl_Proc (ProcIdent "@f", OpenParen "(", [Params1 (LocalIdent "ZF_in", TypeBVType (BVType1 (BVTYPE "bv1"))); Params1 (LocalIdent "VF_in", TypeBVType (BVType1 (BVTYPE "bv1")))], CloseParen ")", OpenParen "(", [], CloseParen ")", AttribSet_Empty, [], ProcDef_Empty)]) |}];

  let ast = ast_of_concrete_ast ~name:"boop" prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Program.prog_pretty ast.prog);
  [%expect
    {|
    proc @f(VF_in:bv1, ZF_in:bv1)  -> () {  }

    ;
    prog entry @f;
    |}]

let%expect_test "prop type from decl" =
  let p =
    ast_of_string
      {|
var $NF: bv1;
var $ZF: bv1;
prog entry @main_4196260;
proc @main_4196260 () -> ()
[
  block %main_entry [
    $NF := 1:bv1;
    $ZF :=  $NF;
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];
    |}
  in
  Program.pretty_to_chan stdout p.prog;
  ();
  [%expect
    {|
    var $NF:bv1;
    var $ZF:bv1;
    proc @main_4196260()  -> () {  }
      modifies $NF:bv1, $ZF:bv1
      captures $NF:bv1, $ZF:bv1

    [
       block %main_entry [
         $NF:bv1 := 0x1:bv1;
         $ZF:bv1 := $NF;
         goto (%main_basil_return_1);
       ];
       block %main_basil_return_1 [ nop; return; ]
    ];
    prog entry @main_4196260;
    |}]

let%expect_test "callstuff" =
  let open Spec_modifies in
  let prog =
    ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__
      {|
var $R0: bv64;
var $R1: bv64;
prog entry @entry;
memory shared $mem : (bv64 -> bv8);

proc @entry() -> ()
[
  block %entry  [
    call @b();
    var c:bv64 := 1:bv64;
    var b:bv64 := c:bv64;
    return ();
  ]
];
proc @b() -> ()
[
  block %entry  [
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    var beans:bv64 := 0x1:bv64;
    store le $mem $R1:bv64 0x0:bv32 32;
    call @c();
    return ();
  ]
];
proc @c() -> ()
[
  block %entry  [
    store le $mem $R0:bv64 0x0:bv32 32;
    return ();
  ]
];
|}
  in
  let res = analyse prog.prog in
  Iter.iter
    (fun (pid, proc) ->
      print_endline (ID.to_string pid ^ ":\n" ^ (res pid |> RWSets.to_string)))
    (Program.procs prog.prog);
  [%expect
    {|
    @entry:
    read: $R0:bv64,$R1:bv64,$mem:(bv64->bv8)
    written: $R0:bv64,$mem:(bv64->bv8)
    @b:
    read: $R0:bv64,$R1:bv64,$mem:(bv64->bv8)
    written: $R0:bv64,$mem:(bv64->bv8)
    @c:
    read: $R0:bv64,$mem:(bv64->bv8)
    written: $mem:(bv64->bv8)
    |}]

let%test_unit "parses parenthesised lambda param" =
  let s =
    {|
    let $memory_load32_le : (bv64 -> bv8) -> bv64 -> bv32 = fun (#memory: bv64 -> bv8), (#index: bv64) ::
      (bvconcat(load_le(8, #memory, bvadd(#index, 3:bv64)),
        bvconcat((load_le(8, #memory, bvadd(#index, 2:bv64))),
        bvconcat((load_le(8, #memory, bvadd(#index, 1:bv64))),
        load_le(8, #memory, #index)))));
    |}
  in
  let _ = ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__ s in
  ()

let%expect_test "proc declaration without body" =
  let p =
    ast_of_string
      {|
var $R0: bv64;
var $R1: bv64;

proc @test1() -> ()
	{ .name = "test1" }
	modifies $R0
	ensures eq($R1, 0x0:bv64)
	requires eq($R1, 0x0:bv64);

    |}
  in
  Program.pretty_to_chan stdout p.prog;
  ();
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    proc @test1()  -> () { .name = "test1" }
      modifies $R0:bv64, $R1:bv64
      captures $R0:bv64, $R1:bv64
      requires eq($R1, 0x0:bv64)
      ensures eq($R1, 0x0:bv64)
    ;
    |}]
