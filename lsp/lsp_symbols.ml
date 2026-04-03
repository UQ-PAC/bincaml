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

type ident =
  [ `Block of BasilIR.AbsBasilIR.blockIdent
  | `Proc of BasilIR.AbsBasilIR.procIdent
  | `Local of BasilIR.AbsBasilIR.localIdent
  | `Global of BasilIR.AbsBasilIR.globalIdent ]

let children_lspsymbols_of_decl input (decl : BasilIR.AbsBasilIR.decl) =
  let open Linol_lsp.Types.SymbolKind in
  let open BasilIR.AbsBasilIR in
  let of_bident (BlockIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in
  let of_lident (LocalIdent ((s, e), ident)) =
    (lsprange_of_offsets input (s, e), ident)
  in

  (match decl with
    | Decl_Fun (_, params, _, _, _) ->
        params |> Iter.of_list
        |> Iter.map (function LocalVarParen1 (_, lid, _, _) ->
            (of_lident lid, Field))
    | Decl_Proc (proc, _, params, _, _, _, _, _, _, ProcDef_Some (_, blocks, _))
      ->
        let paramsyms =
          params |> Iter.of_list
          |> Iter.map (function Params1 (lid, _ty) -> (of_lident lid, Field))
        and blocksyms =
          blocks |> Iter.of_list
          |> Iter.map (function
              | Block_NoPhi (bid, _, _, _, _, _)
              | Block_Phi (bid, _, _, _, _, _, _, _, _)
              -> (of_bident bid, Property))
        in
        Iter.append paramsyms blocksyms
    | _ -> Iter.empty)
  |> Iter.map (function (selectionRange, name), kind ->
      Linol_lsp.Types.DocumentSymbol.create ~kind ~name ~selectionRange
        ~range:selectionRange ~children:[] ())
  |> Iter.to_list

let elided_of_decl (decl : BasilIR.AbsBasilIR.decl) =
  let open BasilIR.AbsBasilIR in
  let ellipsis = Expr_Local (LocalUntyped (LocalIdent ((0, 0), "..."))) in
  match decl with
  | Decl_Axiom (a, b, c) -> decl
  | Decl_Mem (a, b, c, d) -> decl
  | Decl_Var (a, b, c, d) -> decl
  | Decl_UninterpFun (a, b, c) -> decl
  | Decl_Fun (a, b, c, d, e) -> Decl_Fun (a, b, c, d, ellipsis)
  | Decl_FunNoType (a, b, c) -> Decl_FunNoType (a, b, ellipsis)
  | Decl_ProgEmpty (a, b) -> decl
  | Decl_ProgWithSpec (a, b, c) -> decl
  | Decl_Proc (a, b, c, d, e, f, g, h, i, j) ->
      Decl_Proc (a, b, c, d, e, f, g, AttribSet_Empty, i, ProcDef_Empty)
  | Decl_RecType _ -> decl
  | Decl_Type _ -> decl

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
  (* TODO: do range properly by using sliding window of 2 adjacent decls?? *)
  |> function
  | Some ((selectionRange, name), kind) ->
      let children = children_lspsymbols_of_decl input decl in
      let detail =
        elided_of_decl decl |> BasilIR.PrintBasilIR.(printTree prtDecl)
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

let lspsymbol_with_name ~lspsymbols ?lsppos ident = 2

