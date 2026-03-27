module Lsp = Linol.Lsp
module TokenSet = Raw_tokens.TokenSet

type t = {
  notify_back : Linol_lwt.Jsonrpc2.notify_back;
  contents : string ref;
  tokens : unit -> TokenSet.t;
  diagnostics : unit -> Lsp.Types.Diagnostic.t list;
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

let one_value_function_cache f argfun =
  let cache = CCCache.lru ~eq:CCEqual.poly 1 in
  let cached = CCCache.with_cache cache f in
  fun () -> cached (argfun ())

let new_state ~(notify_back : Linol_lwt.Jsonrpc2.notify_back)
    (contents : string) : t =
  let contents = ref contents in
  let debug_highlight = ref false in
  let tokens = one_value_function_cache parse_tokens (fun () -> !contents) in
  let diagnostics =
    one_value_function_cache
      (fun (debug_highlight, tokens) ->
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
      (fun () -> (!debug_highlight, tokens ()))
  in
  { notify_back; contents; tokens; debug_highlight; diagnostics }

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

let completion_item_of_token (x : Raw_tokens.token_with_pos) =
  let open Linol.Lsp.Types.CompletionItemKind in
  let kind =
    match x.token with
    | Ok (TOK_ProcIdent (_, id)) -> Some (id, Class)
    | Ok (TOK_BIdent (_, id)) -> Some (id, Variable)
    | Ok (TOK_BlockIdent (_, id)) -> Some (id, Method)
    | Ok (TOK_GlobalIdent (_, id)) -> Some (id, Constant)
    | Ok (TOK_LocalIdent (_, id)) -> Some (id, Variable)
    | _ -> None
  in
  match kind with
  | None -> None
  | Some (str, kind) ->
      Some
        (Linol.Lsp.Types.CompletionItem.create ~kind
           ~labelDetails:(Linol.Lsp.Types.CompletionItemLabelDetails.create ())
           ~label:str ())

