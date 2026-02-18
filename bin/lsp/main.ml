open Yojson
open Lexing
open Basilloader.BasilVisitor
open Lwt.Infix
open Lsp.Types
open BasilIR
open Basillang
open Basillsp.Tokens
open Basillsp.Semantic_tokens
open Basillsp.Process_doc
open Common.Util

let debug = true
let oc = if debug then Some (open_out ".basillsplog") else None

let log (s : string) =
  Option.iter
    (fun oc ->
      output_string oc (s ^ "\n");
      flush oc)
    oc

let showTree (t : AbsBasilIR.moduleT) : string =
  "[Linearized tree]\n\n"
  ^ PrintBasilIR.printTree PrintBasilIR.prtModuleT t
  ^ "\n"

type doc_ast =
  | SyntaxError of (string * position * position)
  | Ast of AbsBasilIR.moduleT * Processor.symbs

type state_after_processing = {
  linebreaks : linebreaks;
  ast : doc_ast;
  procs : BasilAST.BasilAST.proc list;
  graphs : (unit -> Cfg.procedure_rec) StringMap.t;
}

let process (s : string) : state_after_processing =
  let lexbuf = Lexing.from_string s in
  let linebreaks = linebreaks s in
  try
    let prog = ParBasilIR.pModuleT LexBasilIR.token lexbuf in
    let syms = Processor.process_cast linebreaks prog in
    let tokens = SemanticTokensProcessor.lex_tokens_of_string linebreaks s in
    let syms =
      {
        syms with
        all_tokens =
          TokenMap.union (fun i a b -> Some a) syms.all_tokens tokens;
      }
    in
    let procs =
      try Ast_loader.ast_of_concrete_ast prog
      with exn ->
        let e = Printexc.to_string exn in
        log (Printf.sprintf "%s:\n" e);
        Option.iter Printexc.print_backtrace oc;
        []
    in
    let graphs =
      List.map
        (fun (proc : BasilAST.BasilAST.proc) ->
          (proc.label, fun () -> Cfg.graph_of_proc proc))
        procs
      |> StringMap.of_list
    in
    (*Processor.print_syms syms; *)
    { linebreaks; ast = Ast (prog, syms); procs; graphs }
  with ParBasilIR.Error ->
    let start_pos = Lexing.lexeme_start_p lexbuf
    and end_pos = Lexing.lexeme_end_p lexbuf in
    {
      linebreaks;
      ast = SyntaxError (lexeme lexbuf, start_pos, end_pos);
      procs = [];
      graphs = StringMap.empty;
    }

let process_some_input_file (_file_contents : string) :
    state_after_processing =
  process _file_contents

let diagnostics (_state : state_after_processing) :
    Linol_lsp.Types.Diagnostic.t list =
  match _state.ast with
  | Ast _ -> []
  | SyntaxError (l, p1, p2) ->
      [
        Linol_lsp.Types.Diagnostic.create
          ~message:(`String ("Syntax error: '" ^ l ^ "'"))
          ~range:(range_of_position _state.linebreaks p1 p2)
          ~severity:Linol_lsp.Types.DiagnosticSeverity.Error ();
      ]

open Linol_lwt.Locations
open Linol_lwt

class lsp_server =
  object (self)
    inherit Linol_lwt.Jsonrpc2.server

    val buffers
        : (Linol_lsp.Types.DocumentUri.t, state_after_processing) Hashtbl.t =
      Hashtbl.create 32

    method spawn_query_handler f = Linol_lwt.spawn f
    method! config_definition = Some (`Bool true)

    method! config_code_lens_options =
      Some (Linol_lsp.Lsp.Types.CodeLensOptions.create ())

    method! config_symbol =
      Some
        (`DocumentSymbolOptions
           (DocumentSymbolOptions.create ~label:"symbols"
              ~workDoneProgress:true ()))

    method private _on_doc ~(notify_back : Linol_lwt.Jsonrpc2.notify_back)
        (uri : Linol_lsp.Types.DocumentUri.t) (contents : string) =
      let new_state = process_some_input_file contents in
      Hashtbl.replace buffers uri new_state;
      let diags = diagnostics new_state in
      notify_back#send_diagnostic diags

    method on_notif_doc_did_open ~notify_back d ~content : unit Linol_lwt.t =
      self#_on_doc ~notify_back d.uri content

    method on_notif_doc_did_change ~notify_back d _c ~old_content:_old
        ~new_content =
      self#_on_doc ~notify_back d.uri new_content

    method on_req_hover ~notify_back ~id ~uri ~pos ~workDoneToken
        (d : Linol_lwt.doc_state) =
      Lwt.return None

    method! on_req_code_lens_resolve ~notify_back ~id code_lens =
      (* our code lenses are cheap so probably fine to resolve in one
         stage *)
      Lwt.return code_lens

    method! config_list_commands = [ "show_cfg" ]

    method! on_req_execute_command ~notify_back ~id ~workDoneToken cmd args =
      (match args with
      | Some [ uri; `String proc ] ->
          Some (Linol_lsp.Uri0.t_of_yojson uri, proc)
      | _ -> None)
      |> Option.map (fun (uri, proc_label) ->
             let state = Hashtbl.find buffers uri in
             let pg = StringMap.find proc_label state.graphs in
             let g = pg () in
             Cfg.display_with_viewer g)
      |> ignore;
      Lwt.return (`String "ok")

    method! on_req_code_lens ~notify_back ~id ~uri ~workDoneToken
        ~partialResultToken ds =
      let state = Hashtbl.find buffers uri in
      let p =
        state.procs
        |> List.map (fun (p : BasilAST.BasilAST.proc) ->
               let b, e = p.label_lexical_range |> Option.get in
               let range =
                 token_of_char_range state.linebreaks b e |> Token.to_range
               in
               let command : Linol_lsp.Types.Command.t =
                 {
                   arguments =
                     Some [ Linol_lsp.Uri0.yojson_of_t uri; `String p.label ];
                   command = "show_cfg";
                   title = "Show CFG";
                 }
               in
               let codelens =
                 Linol_lsp.Types.CodeLens.create ~command ~range ()
               in
               codelens)
      in
      Lwt.return p

    (* `Location of Location.t list *)
    method on_req_definition ~notify_back ~id ~uri ~pos ~workDoneToken
        ~partialResultToken d : Linol_lwt.Locations.t option Lwt.t =
      log "req_definition ";
      (match (Hashtbl.find buffers d.uri).ast with
      | Ast (p, syms) ->
          log
            ("get definition : " ^ string_of_int pos.line ^ " "
            ^ string_of_int pos.character);
          Processor.find_definition syms pos.line pos.character
      | _ -> None)
      |> Option.map (fun def ->
             `Location
               [
                 Linol_lwt.Location.create
                   ~range:(Token.to_range def.label_tok)
                   ~uri;
               ])
      |> Lwt.return

    method on_req_symbol ~notify_back ~id ~uri ~workDoneToken
        ~partialResultToken e =
      log "req syms";
      let r =
        (match (Hashtbl.find buffers uri).ast with
        | Ast (p, syms) -> Some syms
        | _ -> None)
        |> Option.map (fun s -> Processor.get_syms s)
        |> Option.map (fun x -> `DocumentSymbol x)
      in
      (function Some x -> log "syms" | None -> log "no syms") r;
      Lwt.return r

    method on_notif_doc_did_close ~notify_back:_ d : unit Linol_lwt.t =
      Hashtbl.remove buffers d.uri;
      Linol_lwt.return ()

    method config_modify_capabilities (c : ServerCapabilities.t) :
        ServerCapabilities.t =
      {
        c with
        semanticTokensProvider =
          Some
            (`SemanticTokensRegistrationOptions
               SemanticTokensProcessor.semantic_tokens_config);
      }

    method on_request_unhandled : type r.
        notify_back:Linol_lwt.Jsonrpc2.notify_back ->
        id:Linol_lwt.Jsonrpc2.Req_id.t ->
        r Linol.Lsp.Client_request.t ->
        r Linol_lwt.Jsonrpc2.IO.t =
      fun ~notify_back:(_ : Linol_lwt.Jsonrpc2.notify_back) ~id:_ _r ->
        match _r with
        | Linol_lsp.Client_request.SemanticTokensRange
            { partialResultToken; range; textDocument; workDoneToken } ->
            log "semantic token range";
            let begin_range : Token.t =
              (LineCol.of_position range.start, 0)
            in
            let end_range : Token.t = (LineCol.of_position range.end_, -1) in
            let m =
              (match (Hashtbl.find buffers textDocument.uri).ast with
              | Ast (p, syms) -> Some syms.all_tokens
              | _ -> None)
              |> Option.map (fun m ->
                     match TokenMap.split begin_range m with
                     | l, data, r -> r)
              |> Option.map (fun m ->
                     match TokenMap.split end_range m with l, data, r -> l)
              |> Option.map SemanticTokensProcessor.to_semantic_tokens_full
            in
            Lwt.return m
        | Linol_lsp.Client_request.SemanticTokensFull
            { partialResultToken; textDocument; workDoneToken } ->
            let uri = textDocument.uri in
            (match (Hashtbl.find buffers uri).ast with
            | Ast (p, syms) -> Some syms
            | _ -> None)
            |> Option.map Processor.to_semantic_highlight_data
            |> fun i -> Lwt.return i
        | _ -> Lwt.fail_with "TODO: handle this request"
  end

let run () =
  log "start";
  let s = new lsp_server in
  let server = Linol_lwt.Jsonrpc2.create_stdio ~env:() s in
  let task =
    let shutdown () = s#get_status = `ReceivedExit in
    Linol_lwt.Jsonrpc2.run ~shutdown server
  in
  match Linol_lwt.run task with
  | () -> ()
  | exception e ->
      let e = Printexc.to_string e in
      Option.iter (fun oc -> Printf.fprintf oc "error: %s\n%!" e) oc;
      exit 1

let () =
  Option.iter
    (fun oc ->
      Printexc.record_backtrace true;
      Printexc.register_printer (function e ->
          Some
            (Printexc.print_backtrace oc;
             "")))
    oc;
  run ()
