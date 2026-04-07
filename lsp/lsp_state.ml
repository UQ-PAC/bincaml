module Lsp = Linol.Lsp

let one_value_function_cache ~eq f argfun =
  let cache = CCCache.lru ~eq 1 in
  let cached = CCCache.with_cache cache f in
  fun x -> cached (argfun x)

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

class state ~(notify_back : Linol_lwt.Jsonrpc2.notify_back) ~uri
  (initial_contents : string) =
  let () = notify_back#set_uri uri in
  let make_lines =
    one_value_function_cache ~eq:CCEqual.string (Fun.compose Array.of_list CCString.lines)
      (fun st -> st#contents)
  in
  let input =
    one_value_function_cache ~eq:CCEqual.string Pp_loc.Input.string (fun st -> st#contents)
  in
  let tokens = one_value_function_cache ~eq:CCEqual.string parse_tokens (fun st -> st#contents) in
  let completions =
    one_value_function_cache ~eq:CCEqual.(pair (array Raw_tokens.equal_token_with_pos) (array string))
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
      (fun st -> (st#tokens, st#lines))
  in
  let parse_result =
    one_value_function_cache ~eq:CCEqual.(pair (array Raw_tokens.equal_token_with_pos) string)
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
      (fun st -> (st#tokens, st#contents))
  in
  let cst =
    one_value_function_cache ~eq:(CCResult.equal ~err:CCEqual.poly CCEqual.poly)
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
      (fun st -> st#parse_result)
  in
  let diagnostics =
    one_value_function_cache ~eq:CCEqual.poly
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
          |> Iter.to_list |> List.append too_big_diag |> List.append parse_diag
        in
        Linol_lwt.spawn (fun () -> notify_back#send_diagnostic diags);
        diags)
      (fun st ->
        (st#is_too_big, st#debug_highlight, st#tokens, st#parse_result))
  in
  let lspsymbols =
    one_value_function_cache ~eq:CCEqual.poly
      (fun (BasilIR.AbsBasilIR.Module1 decls, contents, input) ->
        Lsp_symbols.lspsymbols_of_decls ~len:(String.length contents) input
          decls)
      (fun st -> (st#cst, st#contents, st#input))
  in
  object (self)
    val mutable contents = initial_contents
    val mutable debug_highlight = false
    val mutable is_too_big = false
    method contents = contents
    method debug_highlight = debug_highlight
    method is_too_big = is_too_big
    method input = input (self :> state)
    method parse_result = parse_result (self :> state)
    method lines = make_lines (self :> state)
    method tokens = tokens (self :> state)
    method cst = cst (self :> state)
    method lspsymbols = lspsymbols (self :> state)
    method completions = completions (self :> state)
    method diagnostics = diagnostics (self :> state)

    (** {2 Update methods} *)

    method update_contents ?(force = false) new_contents =
      ignore @@ self#cst;
      is_too_big <- String.length new_contents > 1_000_000;
      if force || not is_too_big then contents <- new_contents

    method toggle_debug_highlight = debug_highlight <- not debug_highlight
  end
