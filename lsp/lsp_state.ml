module Lsp = Linol.Lsp

let one_value_function_cache f argfun =
  let cache = CCCache.lru ~eq:CCEqual.poly 1 in
  let cached = CCCache.with_cache cache f in
  fun () -> cached (argfun ())

let parse_tokens (contents : string) =
  let lexbuf = Lexing.from_string ~with_positions:true contents in
  let tokens = Raw_tokens.extract_all_tokens lexbuf |> Iter.to_array in
  Logs.app (fun m -> m "got %d tokens" (Array.length tokens));
  tokens

let to_diagnostic (x : Raw_tokens.token_with_pos) : Lsp.Types.Diagnostic.t =
  let pos (p : Lexing.position) =
    Lsp.Types.Position.create ~character:(p.pos_cnum - p.pos_bol)
      ~line:(p.pos_lnum - 1)
  in
  let start = pos x.startpos in
  let end_ = pos x.endpos in
  let range = Lsp.Types.Range.create ~start ~end_ in
  let str = x.str in
  let severity =
    match x.token with
    | Ok _ -> Lsp.Types.DiagnosticSeverity.Information
    | Error _ -> Lsp.Types.DiagnosticSeverity.Error
  in
  Lsp.Types.Diagnostic.create ~message:(`String str) ~range ~severity ()

let completion_item_of_token (x : Raw_tokens.token_with_pos) =
  let open Linol.Lsp.Types.CompletionItemKind in
  let kind =
    match x.token with
    | Ok (TOK_ProcIdent (_, id)) -> Some (id, Method, "procedure")
    | Ok (TOK_BIdent (_, id)) -> Some (id, Text, "attribute")
    | Ok (TOK_BlockIdent (_, id)) -> Some (id, Field, "block")
    | Ok (TOK_GlobalIdent (_, id)) -> Some (id, Variable, "global")
    | Ok (TOK_LocalIdent (_, id)) -> Some (id, Field, "local")
    | _ -> None
  in
  let data =
    CCOption.return_if
      (match x.token with Ok (TOK_BIdent _) -> false | _ -> true)
      (Linol.Lsp.Types.Range.yojson_of_t (Raw_tokens.lsprange_of_token x))
  in
  match kind with
  | None -> None
  | Some (str, kind, detail) ->
      Some
        (Linol.Lsp.Types.CompletionItem.create ~kind ?data ~detail
           ~preselect:true ~label:str ())

let lsppos_of_pploc inp loc =
  let lexpos = Pp_loc.Position.to_lexing inp loc in
  Lsp.Types.Position.create
    ~character:(lexpos.pos_cnum - lexpos.pos_bol)
    ~line:(lexpos.pos_lnum - 1)

let lspsymbol_of_decl contents (decl : BasilIR.AbsBasilIR.decl) =
  let open Linol_lsp.Types.SymbolKind in
  let open BasilIR.AbsBasilIR in
  let inp = Pp_loc.Input.string contents in

  let make_range (s, e) =
    let s = Pp_loc.Position.of_offset s and e = Pp_loc.Position.of_offset e in
    let start = lsppos_of_pploc inp s and end_ = lsppos_of_pploc inp e in
    Lsp.Types.Range.create ~start ~end_
  in

  let of_gident (GlobalIdent ((s, e), ident)) = (make_range (s, e), ident) in
  let of_lident (LocalIdent ((s, e), ident)) = (make_range (s, e), ident) in
  let of_pident (ProcIdent ((s, e), ident)) = (make_range (s, e), ident) in

  let result =
    match decl with
    | Decl_Axiom (glb, _, _) -> Some (of_gident glb, Constant, [])
    | Decl_Mem (_, glb, _, _) -> Some (of_gident glb, Variable, [])
    | Decl_Var (_, glb, _, _) -> Some (of_gident glb, Variable, [])
    | Decl_UninterpFun (glb, _, _) -> Some (of_gident glb, Function, [])
    | Decl_Fun (glb, _, _, _, _) -> Some (of_gident glb, Function, [])
    | Decl_FunNoType (glb, _, _) -> Some (of_gident glb, Function, [])
    | Decl_ProgEmpty (_, _) -> None
    | Decl_ProgWithSpec (_, _, _) -> None
    | Decl_Proc (proc, _, _, _, _, _, _, _, _, _) ->
        Some (of_pident proc, Class, [])
    | Decl_RecType (TypeAssign_Sum (loc, _) :: rest) ->
        Some (of_lident loc, Struct, [])
    | Decl_RecType _ -> None (* should be impossible *)
    | Decl_Type loc -> Some (of_lident loc, Struct, [])
  in

  (* TODO: do range properly by using sliding window of 2 adjacent decls?? *)
  match result with
  | Some ((selectionRange, name), kind, children) ->
      Some
        (Linol_lsp.Types.DocumentSymbol.create ~children ~kind ~name
           ~selectionRange ~range:selectionRange ())
  | None -> None

class state ~(notify_back : Linol_lwt.Jsonrpc2.notify_back) ~uri
  (initial_contents : string) =
  object (self)
    val mutable contents = initial_contents
    val mutable debug_highlight = false
    val mutable is_too_big = false

    method lines =
      one_value_function_cache (Fun.compose Array.of_list CCString.lines)
        (fun () -> contents)

    method tokens = one_value_function_cache parse_tokens (fun () -> contents)

    method completions =
      one_value_function_cache
        (fun (tokens, lines) ->
          tokens |> Iter.of_array
          |> Iter.filter_map completion_item_of_token
          |> Iter.sort_uniq
               ~cmp:
                 (CCOrd.map
                    (fun (x : Linol_lwt.CompletionItem.t) -> x.label)
                    CCOrd.string)
          |> Iter.map (fun (comp : Linol_lwt.CompletionItem.t) ->
              let documentation =
                comp.data
                |> Option.map (fun data ->
                    let range = Linol.Lsp.Types.Range.t_of_yojson data in
                    let line = range.start.line in
                    `String lines.(line))
              in
              { comp with documentation })
          |> Iter.to_list
          |> fun x ->
          Logs.app (fun m -> m "made %d completions" (List.length x));
          x)
        (fun () -> (self#tokens (), self#lines ()))

    method parse_result =
      one_value_function_cache
        (fun (tokens, contents) ->
          let get_token, prev_token = Raw_tokens.make_token_getter tokens in
          try Ok (BasilIR.ParBasilIR.pModuleT get_token (Lexing.from_string ""))
          with e ->
            let s = Raw_tokens.lsppos_of_position !prev_token.startpos
            and e = Raw_tokens.lsppos_of_position !prev_token.endpos in
            let range = Lsp.Types.Range.create ~start:s ~end_:e in
            let message =
              Printf.sprintf "Parse error: unexpected token '%s'"
                (Raw_tokens.source_of_token contents !prev_token)
              (* (Raw_tokens.show_raw_token (Result.get_ok !prev_token.token)) *)
            in
            Error
              (Lsp.Types.Diagnostic.create ~range ~message:(`String message) ()))
        (fun () -> (self#tokens (), contents))

    method cst =
      one_value_function_cache
        (fun parse_result ->
          let prev = ref (BasilIR.AbsBasilIR.Module1 []) in
          match parse_result with
          | Ok (BasilIR.AbsBasilIR.Module1 decls as cst) ->
              Logs.app (fun m -> m "new cst with %d decls" (List.length decls));
              prev := cst;
              cst
          | Error _ ->
              Logs.app (fun m -> m "had parse error, keeping old cst");
              !prev)
        (fun () -> self#parse_result ())

    method diagnostics =
      one_value_function_cache
        (fun (is_too_big, debug_highlight, tokens, parse_result) ->
          let start = Lsp.Types.Position.create ~line:0 ~character:0
          and end_ = Lsp.Types.Position.create ~line:0 ~character:100 in
          let range = Lsp.Types.Range.create ~start ~end_ in
          let severity = Lsp.Types.DiagnosticSeverity.Warning in

          let too_big_diag =
            if is_too_big then
              [
                Lsp.Types.Diagnostic.create
                  ~message:
                    (`String
                       "File too big! On-keypress Bincaml LSP features are \
                        disabled. Save the file to manually refresh.")
                  ~range ~severity ();
              ]
            else []
          in

          let parse_diag =
            match parse_result with Error e -> [ e ] | Ok _ -> []
          in

          Logs.app (fun m -> m "making diags");
          let tokens =
            tokens |> Iter.of_array
            |> Iter.filter (fun (tok : Raw_tokens.token_with_pos) ->
                if (not debug_highlight) && Result.is_ok tok.token then false
                else true)
          in
          let diags =
            Iter.map to_diagnostic tokens
            |> Iter.to_list |> List.append too_big_diag
            |> List.append parse_diag
          in
          Linol_lwt.spawn (fun () -> notify_back#send_diagnostic diags);
          diags)
        (fun () ->
          (is_too_big, debug_highlight, self#tokens (), self#parse_result ()))

    method lspsymbols =
      one_value_function_cache
        (fun (BasilIR.AbsBasilIR.Module1 decls, contents) ->
          List.filter_map (lspsymbol_of_decl contents) decls)
        (fun () -> (self#cst (), contents))

    (** {2 Update methods} *)

    method update_contents ?(force = false) new_contents =
      ignore @@ self#cst ();
      is_too_big <- String.length new_contents > 1_000_000;
      if force || not is_too_big then contents <- new_contents

    method toggle_debug_highlight = debug_highlight <- not debug_highlight
  end
