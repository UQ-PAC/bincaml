(* This file is free software, part of linol. See file "LICENSE" for more information *)

(* Some user code

   The code here is just a placeholder to make this file compile, it is expected
   that users have an implementation of a processing function for input contents.

   Here we expect a few things:
   - a type to represent a state/environment that results from processing an
     input file
   - a function processing an input file (given the file contents as a string),
     which return a state/environment
   - a function to extract a list of diagnostics from a state/environment.
     Diagnostics includes all the warnings, errors and messages that the processing
     of a document are expected to be able to return.
*)

module Lsp = Linol.Lsp

(* type state_after_processing = Bincaml_lsp.Raw_tokens.raw_token list *)
type state_after_processing = {
  notify_back : Linol_lwt.Jsonrpc2.notify_back;
  contents : string Lwt_react.signal;
  set_contents : string -> unit;
  tokens : Bincaml_lsp.Raw_tokens.token_with_pos list Lwt_react.signal;
  debug_highlight_signal : bool Lwt_react.signal;
  set_debug_highlight : bool -> unit;
  diagnostics : Lsp.Types.Diagnostic.t list Lwt_react.signal;
}

let parse_tokens (contents : string) : 'a list =
  let lexbuf = Lexing.from_string ~with_positions:true contents in
  Bincaml_lsp.Raw_tokens.extract_all_tokens lexbuf |> Iter.to_list

let to_diagnostic (x : Bincaml_lsp.Raw_tokens.token_with_pos) :
    Lsp.Types.Diagnostic.t =
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

let new_state ~notify_back (contents : string) : state_after_processing =
  let contents, set_contents = Lwt_react.S.create contents in
  let debug_highlight_signal, set_debug_highlight = Lwt_react.S.create false in
  let debug_highlight_signal =
    Lwt_react.S.map
      (fun x ->
        Logs.app (fun m -> m "debug highlight set");
        x)
      debug_highlight_signal
  in
  let tokens = Lwt_react.S.map parse_tokens contents in
  let diagnostics =
    Lwt_react.S.l2
      (fun debug_highlight tokens ->
        let tokens =
          List.filter
            (fun (tok : Bincaml_lsp.Raw_tokens.token_with_pos) ->
              if (not debug_highlight) && Result.is_ok tok.token then false
              else true)
            tokens
        in
        List.map to_diagnostic tokens)
      debug_highlight_signal tokens
  in
  let diagnostics =
    Lwt_react.S.trace
      (fun diags ->
        Linol_lwt.spawn @@ fun () -> notify_back#send_diagnostic diags)
      diagnostics
  in
  {
    notify_back;
    contents;
    set_contents;
    tokens;
    debug_highlight_signal;
    set_debug_highlight;
    diagnostics;
  }

(* Lsp server class

   This is the main point of interaction beetween the code checking documents
   (parsing, typing, etc...), and the code of linol.

   The [Linol_lwt.Jsonrpc2.server] class defines a method for each of the action
   that the lsp server receives, such as opening of a document, when a document
   changes, etc.. By default, the method predefined does nothing (or errors out ?),
   so that users only need to override methods that they want the server to
   actually meaningfully interpret and respond to.

    https://c-cube.github.io/linol/linol/Linol/Jsonrpc2/module-type-S/class-server/index.html
*)
class lsp_server =
  object (self)
    inherit Linol_lwt.Jsonrpc2.server as super

    (* one env per document *)
    val buffers : (Lsp.Types.DocumentUri.t, state_after_processing) Hashtbl.t =
      Hashtbl.create 32

    method get uri = Hashtbl.find buffers uri
    method spawn_query_handler f = Linol_lwt.spawn f

    (* We define here a helper method that will:
       - process a document
       - store the state resulting from the processing
       - return the diagnostics from the new state
    *)
    method private _on_doc ~(notify_back : Linol_lwt.Jsonrpc2.notify_back)
        (uri : Lsp.Types.DocumentUri.t) (contents : string) =
      let st =
        match Hashtbl.find_opt buffers uri with
        | Some st ->
            Logs.app (fun m -> m "setting new contents");
            st.set_contents contents;
            st
        | None -> new_state ~notify_back contents
      in
      Hashtbl.replace buffers uri st;
      Lwt.return ()

    (* We now override the [on_notify_doc_did_open] method that will be called
       by the server each time a new document is opened. *)
    method on_notif_doc_did_open ~notify_back d ~content : unit Linol_lwt.t =
      self#_on_doc ~notify_back d.uri content

    (* Similarly, we also override the [on_notify_doc_did_change] method that will be called
       by the server each time a new document is opened. *)
    method on_notif_doc_did_change ~notify_back d _c ~old_content:_old
        ~new_content =
      self#_on_doc ~notify_back d.uri new_content

    (* On document closes, we remove the state associated to the file from the global
       hashtable state, to avoid leaking memory. *)
    method on_notif_doc_did_close ~notify_back:_ d : unit Linol_lwt.t =
      Hashtbl.remove buffers d.uri;
      Linol_lwt.return ()

    method! config_code_lens_options =
      Some (Linol_lsp.Lsp.Types.CodeLensOptions.create ())

    method toggle_highlight_command ~uri () =
      Linol_lsp.Lsp.Types.Command.create ~command:"toggle-highlight"
        ~title:"Toggle debug token highlighting"
        ~arguments:[ Linol_lsp.Lsp.Types.DocumentUri.yojson_of_t uri ]
        ()

    method toggle_highlight_code_action ~uri () =
      let open Linol_lsp.Lsp.Types.CodeActionKind in
      Linol_lsp.Lsp.Types.CodeAction.create ~kind:Empty
        ~command:(self#toggle_highlight_command ~uri ())
        ~title:(self#toggle_highlight_command ~uri ()).title ()

    method! config_list_commands = [ "toggle-highlight" ]
    method! config_code_action_provider = `Bool true

    method! config_completion =
      Some
        (Linol_lwt.CompletionOptions.create
           ~triggerCharacters:[ "."; "$"; "@"; "#" ] ())

    method! on_req_execute_command ~notify_back ~id ~workDoneToken cmd args =
      let open Lwt.Infix in
      Logs.app (fun m -> m "execute");
      match (cmd, args) with
      | "toggle-highlight", Some [ uri ] ->
          let uri = Linol_lsp.Lsp.Types.DocumentUri.t_of_yojson uri in
          let st = self#get uri in
          (* let _ = *)
          (*   st.diagnostics |> Lwt_react.S.changes |> Lwt_react.E.next *)
          (*   >>= notify_back#send_diagnostic *)
          (*   >|= Fun.const Yojson.Safe.(`Null) *)
          (* in *)
          st.set_debug_highlight (not (React.S.value st.debug_highlight_signal));
          Lwt.return @@ Yojson.Safe.(`Null)
      | _ ->
          super#on_req_execute_command ~notify_back ~id ~workDoneToken cmd args

    method! on_req_code_action ~notify_back ~id params =
      Logs.app (fun m -> m "reqcodeaction");
      let uri = params.textDocument.uri in
      Lwt.return
        (Some [ `CodeAction (self#toggle_highlight_code_action ~uri ()) ])

    method! on_req_completion ~notify_back ~id ~uri ~pos ~ctx ~workDoneToken
        ~partialResultToken doc_state =
      Logs.app (fun m -> m "req completion");
      let st = self#get uri in

      (* TODO: how to handle reactive delay in propagating tokens?? *)
      let tokens = Lwt_react.S.value st.tokens in

      let to_token_strings ts =
        List.filter_map
          (fun (x : Bincaml_lsp.Raw_tokens.token_with_pos) ->
            let open Bincaml_lsp.Raw_tokens in
            match x.token with
            | Ok (TOK_ProcIdent (_, id)) -> Some id
            | _ -> None)
          ts
      in
      let tokens_under_cursor =
        tokens
        |> List.filter (fun (x : Bincaml_lsp.Raw_tokens.token_with_pos) ->
            let open Bincaml_lsp.Raw_tokens in
            lsprange_contains (lsprange_of_token x) pos)
        |> to_token_strings
      in
      List.iter
        (fun x -> Logs.app (fun m -> m "under tok = %s" x))
        tokens_under_cursor;
      match tokens_under_cursor with
      | [] -> Lwt.return None
      | under_cursor :: _ ->
          let matching_tokens =
            tokens |> to_token_strings
            |> List.filter (fun s -> String.starts_with ~prefix:under_cursor s)
          in
          List.iter
            (fun x -> Logs.app (fun m -> m "matching = %s" x))
            matching_tokens;
          Lwt.return
          @@ Some
               (`List
                  (List.map
                     (fun x ->
                       Linol.Lsp.Types.CompletionItem.create ~insertText:x
                         ~kind:Linol.Lsp.Types.CompletionItemKind.Method
                         ~labelDetails:
                           (Linol.Lsp.Types.CompletionItemLabelDetails.create
                              ~detail:"procedure" ())
                         ~label:x ())
                     matching_tokens))

    (* method! on_req_code_lens_resolve ~notify_back ~id code_lens = *)
    (*   Lwt.return code_lens *)
  end

(* Main code
   This is the code that creates an instance of the lsp server class
   and runs it as a task. *)
let run () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Bincaml_lsp.Lsp_logs.file_reporter ());
  Logs.info (fun m -> m "bincaml_lsp starting");
  Logs.app (fun m -> m "asd2");
  Logs.app (fun m -> m "asd2");

  let s = new lsp_server in
  let server =
    Linol_lwt.Jsonrpc2.create_stdio ~env:() (s :> Linol_lwt.Jsonrpc2.server)
  in
  let task =
    let shutdown () = s#get_status = `ReceivedExit in
    Linol_lwt.Jsonrpc2.run ~shutdown server
  in
  match Linol_lwt.run task with
  | () -> ()
  | exception e ->
      let e = Printexc.to_string e in
      Printf.eprintf "error: %s\n%!" e;
      exit 1

(* Finally, we actually run the server *)
let () = run ()
