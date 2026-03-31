module Lsp = Linol.Lsp
module TokenSet = Raw_tokens.TokenSet

type t = {
  notify_back : Linol_lwt.Jsonrpc2.notify_back;
  contents : string ref;
  tokens : unit -> TokenSet.t;
  diagnostics : unit -> Lsp.Types.Diagnostic.t list;
  completions : unit -> Linol.Lsp.Types.CompletionItem.t list;
  debug_highlight : bool ref;
}

let parse_tokens (contents : string) =
  let lexbuf = Lexing.from_string ~with_positions:true contents in
  Raw_tokens.extract_all_tokens lexbuf |> Iter.to_set (module TokenSet)

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
    | Ok (TOK_BlockIdent (_, id)) -> Some (id, Method, "block")
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

let one_value_function_cache f argfun =
  let cache = CCCache.lru ~eq:CCEqual.poly 1 in
  let cached = CCCache.with_cache cache f in
  fun () -> cached (argfun ())

let new_state ~(notify_back : Linol_lwt.Jsonrpc2.notify_back)
    (contents : string) : t =
  let contents = ref contents in
  let debug_highlight = ref false in

  let lines =
    one_value_function_cache (Fun.compose Array.of_list CCString.lines)
      (fun () -> !contents)
  in

  let is_too_big =
    one_value_function_cache
      (fun contents -> String.length contents > 1_000_000)
      (fun () -> !contents)
  in

  let tokens =
    one_value_function_cache
      (fun (is_too_big, contents) ->
        if is_too_big then TokenSet.empty else parse_tokens contents)
      (fun () -> (is_too_big (), !contents))
  in

  let diagnostics =
    one_value_function_cache
      (function
        | true, _, _ ->
            let start = Lsp.Types.Position.create ~line:0 ~character:0
            and end_ = Lsp.Types.Position.create ~line:0  ~character:100 in
            let range = Lsp.Types.Range.create ~start ~end_ in
            let severity = Lsp.Types.DiagnosticSeverity.Warning in

            let diags =
              [
                Lsp.Types.Diagnostic.create
                  ~message:
                    (`String
                       "File too big! On-keypress Bincaml LSP features are \
                        disabled. Save the file to manually refresh.")
                  ~range ~severity ();
              ]
            in
            Linol_lwt.spawn (fun () -> notify_back#send_diagnostic diags);
            diags
        | false, debug_highlight, tokens ->
            Logs.app (fun m -> m "making diags");
            let tokens =
              Iter.of_set (module TokenSet) tokens
              |> Iter.filter (fun (tok : Raw_tokens.token_with_pos) ->
                  if (not debug_highlight) && Result.is_ok tok.token then false
                  else true)
            in
            let diags = Iter.map to_diagnostic tokens |> Iter.to_list in
            Linol_lwt.spawn (fun () -> notify_back#send_diagnostic diags);
            diags)
      (fun () -> (is_too_big (), !debug_highlight, tokens ()))
  in

  let completions =
    one_value_function_cache
      (fun (tokens, lines) ->
        tokens
        |> Iter.of_set (module TokenSet)
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
        |> Iter.to_list)
      (fun () -> (tokens (), lines ()))
  in
  { notify_back; contents; tokens; debug_highlight; diagnostics; completions }

let completions_for_prefix st lsppos prefix =
  let tokens = st.tokens () in
  Iter.of_set (module TokenSet) tokens
  |> Iter.filter (fun tok ->
      not Raw_tokens.(lsprange_contains (lsprange_of_token tok) lsppos))
  |> Iter.filter (fun x ->
      Option.fold ~none:false
        ~some:(String.starts_with ~prefix)
        (Raw_tokens.ident_of_token x))
  |> Iter.sort |> Iter.uniq |> Iter.to_list
