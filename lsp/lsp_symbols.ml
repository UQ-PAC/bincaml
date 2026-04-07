module Lsp = Linol.Lsp

let lsppos_of_pploc inp loc =
  let lexpos = Pp_loc.Position.to_lexing inp loc in
  Lsp.Types.Position.create
    ~character:(lexpos.pos_cnum - lexpos.pos_bol)
    ~line:(lexpos.pos_lnum - 1)

let lsppos_of_prev_endline inp loc =
  let lexpos = Pp_loc.Position.to_lexing inp loc in
  let bol = { lexpos with pos_cnum = lexpos.pos_bol } in
  bol |> Pp_loc.Position.of_lexing
  |> Fun.flip Pp_loc.Position.shift (-1)
  |> lsppos_of_pploc inp

let lsprange_of_offsets input (s, e) =
  let s = Pp_loc.Position.of_offset s and e = Pp_loc.Position.of_offset e in
  let start = lsppos_of_pploc input s and end_ = lsppos_of_pploc input e in
  Lsp.Types.Range.create ~start ~end_

type ident_kind = [ `Block | `Proc | `Local | `Global | `Attrib ]
type ident = { kind : ident_kind; offsets : int * int; text : string }
type symbol = Linol_lsp.Types.DocumentSymbol.t

let ident_of_token (x : Raw_tokens.token_with_pos) =
  let ident kind offsets text = { kind; offsets; text } in
  match x.token with
  | Ok (TOK_ProcIdent (offs, id)) -> Some (ident `Proc offs id)
  | Ok (TOK_BIdent (offs, id)) -> Some (ident `Attrib offs id)
  | Ok (TOK_BlockIdent (offs, id)) -> Some (ident `Block offs id)
  | Ok (TOK_GlobalIdent (offs, id)) -> Some (ident `Global offs id)
  | Ok (TOK_LocalIdent (offs, id)) -> Some (ident `Local offs id)
  | _ -> None

let elided_of_block (block : BasilIR.AbsBasilIR.block) =
  let open BasilIR.AbsBasilIR in
  let elided_stmts stmts =
    let ellipsis = GlobalUntyped (GlobalIdent ((0, 0), "...")) in
    List.filter
      (function StmtWithAttrib1 (Stmt_Guard _, _) -> true | _ -> false)
      stmts
    @ [
        StmtWithAttrib1
          ( Stmt_SingleAssign
              (Assignment1 (LVar_Global ellipsis, Expr_Global ellipsis)),
            AttribSet_Empty );
      ]
  in

  match block with
  | Block_NoPhi (a, b, c, stmts, d, e) ->
      let stmts = elided_stmts stmts in
      Block_NoPhi (a, AttribSet_Empty, c, stmts, d, e)
  | Block_Phi (a, b, c, d, e, f, stmts, g, h) ->
      let stmts = elided_stmts stmts in
      Block_Phi (a, AttribSet_Empty, c, d, e, f, stmts, g, h)

let elided_of_decl (decl : BasilIR.AbsBasilIR.decl) =
  let open BasilIR.AbsBasilIR in
  match decl with
  | Decl_Axiom (a, b, c) -> decl
  | Decl_Mem (a, b, c, d) -> decl
  | Decl_Var (a, b, c, d) -> decl
  | Decl_UninterpFun (a, b, c) -> decl
  | Decl_Fun (a, b, c, d, e) -> decl
  | Decl_FunNoType (a, b, c) -> decl
  | Decl_ProgEmpty (a, b) -> decl
  | Decl_ProgWithSpec (a, b, c) -> decl
  | Decl_Proc (a, b, c, d, e, f, g, h, i, j) ->
      Decl_Proc (a, b, c, d, e, f, g, h, i, ProcDef_Empty)
  | Decl_RecType _ -> decl
  | Decl_Type _ -> decl

let children_lspsymbols_of_decl input (decl : BasilIR.AbsBasilIR.decl) =
  let open Linol_lsp.Types.SymbolKind in
  let open BasilIR.AbsBasilIR in
  let of_bident (BlockIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in
  let of_lident (LocalIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in
  let of_localvar = function
    | LocalTyped (lid, _) | LocalUntyped lid -> Iter.singleton (of_lident lid)
  in
  let of_lvar = function
    | LVar_Global _ -> Iter.empty
    | LVar_Local localvar -> of_localvar localvar
  in
  let of_lvars = function
    | LVars_Empty -> Iter.empty
    | LVars_LocalList (_, localvars, _) ->
        Iter.of_list localvars |> Iter.flat_map of_localvar
    | LVars_List (_, lvars, _) -> Iter.of_list lvars |> Iter.flat_map of_lvar
    | NamedLVars_List (_, named, _) ->
        Iter.of_list named
        |> Iter.flat_map (function NamedCallReturn1 (lvar, _) -> of_lvar lvar)
  in

  let fence = Printf.sprintf "```basilir\n%s\n```" in

  let of_stmt stmt =
    (match stmt with
      | Stmt_Load_Var (lvar, _, _, _, _) -> of_lvar lvar
      | Stmt_ScalarLoad (lvar, _) -> of_lvar lvar
      | Stmt_SingleAssign (Assignment1 (lvar, _)) -> of_lvar lvar
      | Stmt_MultiAssign (_, assigns, _) ->
          Iter.of_list assigns
          |> Iter.flat_map (function Assignment1 (lvar, _) -> of_lvar lvar)
      | Stmt_DirectCall (lvars, _, _, _, _) -> of_lvars lvars
      | _ -> Iter.empty)
    |> Iter.map (fun stmt_info ->
        let context = BasilIR.PrintBasilIR.(printTree prtStmt) stmt in
        (stmt_info, [ fence context ]))
  in

  let block_context block =
    [
      block |> elided_of_block
      |> BasilIR.PrintBasilIR.(printTree prtBlock)
      |> fence;
    ]
  in

  let of_block block =
    let bcontext = block_context block in
    (match block with
      | Block_NoPhi (bid, _, _, stmts, _, _) ->
          Iter.of_list stmts
          |> Iter.flat_map (function StmtWithAttrib1 (stmt, _) -> of_stmt stmt)
      | Block_Phi (bid, _, _, phis, _, _, stmts, _, _) ->
          Iter.of_list stmts
          |> Iter.flat_map (function StmtWithAttrib1 (stmt, _) -> of_stmt stmt))
    |> Iter.map (fun ((range, name), context) ->
        ((range, name), Field, context @ ("within block" :: bcontext)))
  in

  (match decl with
    | Decl_Fun (_, params, _, _, _) ->
        params |> Iter.of_list
        |> Iter.map (function LocalVarParen1 (_, lid, _, _) ->
            (of_lident lid, Field, []))
    | Decl_Proc (proc, _, params, _, _, _, _, _, _, ProcDef_Some (_, blocks, _))
      ->
        let paramsyms =
          params |> Iter.of_list
          |> Iter.map (function Params1 (lid, _ty) as p ->
              let context = BasilIR.PrintBasilIR.(printTree prtParams) p in
              (of_lident lid, Field, [ fence context; "within parameters" ]))
        and blocksyms =
          blocks |> Iter.of_list
          |> Iter.map (fun block ->
              match block with
              | Block_NoPhi (bid, _, _, _, _, _)
              | Block_Phi (bid, _, _, _, _, _, _, _, _) ->
                  (of_bident bid, Property, block_context block))
        and localsyms = blocks |> Iter.of_list |> Iter.flat_map of_block in
        blocksyms |> Iter.append paramsyms |> Iter.append localsyms
    | _ -> Iter.empty)
  |> Iter.map (function (selectionRange, name), kind, context ->
      let procdetail =
        elided_of_decl decl |> BasilIR.PrintBasilIR.(printTree prtDecl)
      in
      let context = match context with [] -> [ fence name ] | x -> x in
      let context = context @ [ "within procedure"; fence procdetail ] in
      let detail =
        context |> List.map (Fun.flip CCString.cat "\n\n") |> CCString.concat ""
      in
      Linol_lsp.Types.DocumentSymbol.create ~kind ~name ~selectionRange ~detail
        ~range:selectionRange ~children:[] ())
  |> Iter.to_list

let lspsymbol_of_decl input (decl : BasilIR.AbsBasilIR.decl) =
  let open Linol_lsp.Types.SymbolKind in
  let open BasilIR.AbsBasilIR in
  let of_gident (GlobalIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in
  let of_lident (LocalIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in
  let of_pident (ProcIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in

  (match decl with
    | Decl_Axiom (glb, _, _) -> Some (of_gident glb, Constant)
    | Decl_Mem (_, glb, _, _) -> Some (of_gident glb, Variable)
    | Decl_Var (_, glb, _, _) -> Some (of_gident glb, Variable)
    | Decl_UninterpFun (glb, _, _) -> Some (of_gident glb, Function)
    | Decl_Fun (glb, _, _, _, _) -> Some (of_gident glb, Function)
    | Decl_FunNoType (glb, _, _) -> Some (of_gident glb, Function)
    | Decl_ProgEmpty (_, _) -> None
    | Decl_ProgWithSpec (_, _, _) -> None
    | Decl_Proc (proc, _, _, _, _, _, _, _, _, _) -> Some (of_pident proc, Class)
    | Decl_RecType (TypeAssign_Sum (loc, _) :: rest) ->
        Some (of_lident loc, Struct)
    | Decl_RecType _ -> None (* should be impossible *)
    | Decl_Type loc -> Some (of_lident loc, Struct))
  |> function
  | Some ((selectionRange, name), kind) ->
      let children = children_lspsymbols_of_decl input decl in
      let detail =
        Printf.sprintf {|```basilir
%s
```

global declaration|}
          (elided_of_decl decl |> BasilIR.PrintBasilIR.(printTree prtDecl))
      in
      Some
        (Linol_lsp.Types.DocumentSymbol.create ~children ~kind ~name ~detail
           ~selectionRange ~range:selectionRange ())
  | None -> None

let lspsymbols_of_decls ~len input decls =
  let open Linol_lsp.Types.DocumentSymbol in
  let end_ = Pp_loc.Position.of_offset len |> lsppos_of_pploc input in

  decls
  |> List.filter_map (lspsymbol_of_decl input)
  |> CCListLabels.fold_right
       ~f:(fun decl (end_, rest) ->
         let range = { decl.range with end_ } in
         (decl.range.start, { decl with range } :: rest))
       ~init:(end_, [])
  |> snd

let proc_lspsymbol_at_pos ~lspsymbols lsppos =
  lspsymbols
  |> List.find_opt (fun (sym : symbol) ->
      Raw_tokens.lsprange_contains sym.range lsppos)

let lspsymbols_with_kind ~lspsymbols ~lsppos (kind : ident_kind) : symbol Iter.t
    =
  let locals () =
    Iter.of_opt (proc_lspsymbol_at_pos ~lspsymbols lsppos)
    |> Iter.flat_map_l (fun (x : symbol) -> Option.value ~default:[] x.children)
  in
  match kind with
  | `Attrib -> Iter.empty
  | `Proc | `Global -> Iter.of_list lspsymbols
  | `Block | `Local -> locals ()

let lspsymbol_of_ident ~lspsymbols ~lsppos ident =
  lspsymbols_with_kind ~lspsymbols ~lsppos ident.kind
  |> Iter.filter (fun (x : symbol) ->
      (* Logs.app (fun m -> m "%s" x.name); *)
      String.equal x.name ident.text)
