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
module Lsp_state = Bincaml_lsp.Lsp_state

let run_command ?(quiet = true) ~notify_back command =
  let stdout, stderr, errcode = CCUnix.call ~stdin:(`Str "") "%s" command in

  let failed = errcode <> 0 in
  if (not quiet) || failed then (
    let verb = if failed then "failed" else "succeeded" in
    let type_ = Lsp.Types.MessageType.(if failed then Error else Info) in
    let message =
      Printf.sprintf "lsp subprocess %s: %s\n\nstderr:\n%s\n\nstdout:\n%s" verb
        command stderr stdout
    in
    Logs.app (fun m -> m "%s" message);
    let params = Lsp.Types.ShowMessageParams.create ~type_ ~message in
    notify_back#send_notification (Lsp.Server_notification.ShowMessage params))
  else Lwt.return ()

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
    val buffers : (Lsp.Types.DocumentUri.t, Lsp_state.state) Hashtbl.t =
      Hashtbl.create 32

    val mutable latest_uri : Lsp.Types.DocumentUri.t =
      Lsp.Types.DocumentUri.of_path "/"

    method get uri = Hashtbl.find buffers uri
    method spawn_query_handler f = Linol_lwt.spawn f

    (* We define here a helper method that will:
       - process a document
       - store the state resulting from the processing
       - return the diagnostics from the new state
    *)
    method private _on_doc ~(notify_back : Linol_lwt.Jsonrpc2.notify_back)
        ?(force = false) (uri : Lsp.Types.DocumentUri.t) (contents : string) =
      latest_uri <- uri;
      notify_back#set_uri uri;
      let st =
        match Hashtbl.find_opt buffers uri with
        | Some st ->
            st#update_contents ~force contents;
            st
        | None -> new Lsp_state.state ~notify_back ~uri contents
      in
      ignore @@ st#diagnostics;
      Hashtbl.replace buffers uri st

    (* We now override the [on_notify_doc_did_open] method that will be called
       by the server each time a new document is opened. *)
    method on_notif_doc_did_open ~notify_back d ~content : unit Linol_lwt.t =
      self#_on_doc ~notify_back d.uri content;
      Lwt.return ()

    (* Similarly, we also override the [on_notify_doc_did_change] method that will be called
       by the server each time a new document is opened. *)
    method on_notif_doc_did_change ~notify_back d changes ~old_content:_old
        ~new_content =
      self#_on_doc ~notify_back d.uri new_content;
      Lwt.return ()

    method! on_notif_doc_did_save ~notify_back saveparams =
      let docst = Hashtbl.find docs saveparams.textDocument.uri in
      Linol_lwt.spawn (fun () ->
          self#_on_doc ~notify_back ~force:true saveparams.textDocument.uri
            docst.content;
          Lwt.return ());
      Lwt.return ()

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

    method show_log_command ~uri () =
      Linol_lsp.Lsp.Types.Command.create ~command:"open-log-file"
        ~arguments:[ Linol_lsp.Lsp.Types.DocumentUri.yojson_of_t uri ]
        ~title:"Open LSP log file" ()

    method dump_graph_command ~uri ~name () =
      let title =
        Printf.sprintf "Generate and open graph for procedure '%s'" name
      in
      Linol_lsp.Lsp.Types.Command.create ~command:"procedure-graph" ~title
        ~arguments:
          [ Linol_lsp.Lsp.Types.DocumentUri.yojson_of_t uri; `String name ]
        ()

    method! config_list_commands =
      [ "toggle-highlight"; "open-log-file"; "procedure-graph" ]

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
          notify_back#set_uri uri;

          let st = self#get uri in
          st#toggle_debug_highlight;
          ignore @@ st#diagnostics;
          Lwt.return @@ Yojson.Safe.(`Null)
      | "open-log-file", Some [ uri ] ->
          let uri = Linol_lsp.Lsp.Types.DocumentUri.t_of_yojson uri in
          notify_back#set_uri uri;

          let log_file = Filename.quote Bincaml_lsp.Lsp_logs.temp_file in
          run_command ~notify_back (String.concat " " [ "xdg-open"; log_file ])
          |> Lwt.map (fun _ -> `Null)
      | "procedure-graph", Some [ uri; `String name ] -> begin
          let uri = Linol_lsp.Lsp.Types.DocumentUri.t_of_yojson uri in
          notify_back#set_uri uri;

          let st = self#get uri in
          let notify_error ~type_ message =
            let params = Lsp.Types.ShowMessageParams.create ~type_ ~message in
            notify_back#send_notification
              (Lsp.Server_notification.ShowMessage params)
            |> Lwt.map (fun _ -> `Null)
          in
          match st#ast with
          | Error e ->
              notify_error ~type_:Error
                "Cannot generate procedure graph because file has parse errors."
          | Ok ast -> (
              let procid = Lang.Program.get_id_by_name name ast in
              let procedure = Lang.Program.proc ast procid in
              match Lang.Procedure.graph procedure with
              | None ->
                  notify_error ~type_:Error
                    (Printf.sprintf "Procedure '%s' has no definition." name)
              | Some graph ->
                  let file_name = Filename.temp_file "bincaml_graph." ".dot" in
                  Out_channel.with_open_text file_name (fun oc ->
                      let fmt = Format.formatter_of_out_channel oc in
                      Lang.Viscfg.Dot.fprint_graph fmt graph;
                      Format.pp_print_flush fmt ());
                  let open Lwt.Syntax in
                  let* () =
                    run_command ~notify_back
                      (Filename.quote_command "dot"
                         [ "-O"; "-Tsvg"; file_name ])
                  in
                  let* () =
                    run_command ~notify_back
                      (Filename.quote_command "xdg-open" [ file_name ^ ".svg" ])
                  in
                  Lwt.return `Null)
        end
      | cmd, _ when List.mem cmd self#config_list_commands ->
          let message =
            "Code action command missing file context. Please invoke the \
             command from the contextual code actions."
          in
          let params =
            Lsp.Types.ShowMessageParams.create ~type_:Error ~message
          in
          notify_back#set_uri latest_uri;
          notify_back#send_notification
            (Lsp.Server_notification.ShowMessage params)
          |> Lwt.map (fun _ -> `Null)
      | _ ->
          super#on_req_execute_command ~notify_back ~id ~workDoneToken cmd args

    method! on_req_code_action ~notify_back ~id params =
      Logs.app (fun m -> m "reqcodeaction");
      let uri = params.textDocument.uri in
      let range = params.range in
      let make_action (command : Linol_lsp.Lsp.Types.Command.t) =
        Linol_lsp.Lsp.Types.CodeAction.create ~kind:Empty ~command
          ~title:command.title ()
      in

      let st = self#get uri in
      let lspsymbols = st#lspsymbols in
      let proc =
        Bincaml_lsp.Lsp_symbols.proc_lspsymbol_at_pos ~lspsymbols range.end_
      in

      List.flatten
        [
          (match proc with
          | Some proc -> [ self#dump_graph_command ~uri ~name:proc.name () ]
          | None -> []);
          [ self#show_log_command ~uri () ];
          [ self#toggle_highlight_command ~uri () ];
        ]
      |> List.map (fun cmd -> `CodeAction (make_action cmd))
      |> Option.some |> Lwt.return

    method! on_req_completion ~notify_back ~id ~uri ~pos ~ctx ~workDoneToken
        ~partialResultToken doc_state =
      Logs.app (fun m -> m "req completion");
      let st = self#get uri in

      let tokens = st#tokens in

      match
        Bincaml_lsp.Raw_tokens.token_at_pos tokens pos
        |> CCOption.flat_map Bincaml_lsp.Lsp_symbols.ident_of_token
      with
      | None -> Lwt.return None
      | Some { Bincaml_lsp.Lsp_symbols.text = prefix } ->
          let prefix = String.sub prefix 0 1 in
          let completions =
            st#completions
            |> List.filter (fun (comp : Linol_lwt.CompletionItem.t) ->
                String.starts_with ~prefix comp.label
                && comp.data
                   |> Option.map (fun data ->
                       let range = Linol.Lsp.Types.Range.t_of_yojson data in
                       not (Bincaml_lsp.Raw_tokens.lsprange_contains range pos))
                   |> Option.value ~default:true)
          in
          Lwt.return (Some (`List completions))

    method! config_symbol = Some (`Bool true)

    method! on_req_symbol ~notify_back ~id ~uri ~workDoneToken
        ~partialResultToken () =
      let st = self#get uri in
      Lwt.return (Some (`DocumentSymbol st#lspsymbols))

    method! config_hover = Some (`Bool true)

    method! on_req_hover ~notify_back ~id ~uri ~pos ~workDoneToken _doc =
      Logs.app (fun m -> m "req hover");
      let st = self#get uri in
      let tokens = st#tokens in
      let ident =
        Bincaml_lsp.Raw_tokens.token_at_pos tokens pos
        |> CCOption.flat_map Bincaml_lsp.Lsp_symbols.ident_of_token
      in
      (let open CCOption.Infix in
       let* ident = ident in
       let lspsymbols = st#lspsymbols in
       let* sym =
         Bincaml_lsp.Lsp_symbols.lspsymbol_of_ident ~lspsymbols ~lsppos:pos
           ident
         |> Iter.head
       in
       let detail =
         Option.value
           ~default:
             (Printf.sprintf
                "no information available for %s. please file a bug!" ident.text)
           sym.detail
       in
       let contents =
         `MarkupContent
           {
             Linol_lsp.Types.MarkupContent.value = detail;
             kind = Linol_lsp.Types.MarkupKind.Markdown;
           }
       in
       let hover = Linol_lsp.Types.Hover.create ~contents () in
       Some hover)
      |> function
      | Some x -> Lwt.return (Some x)
      | None -> Lwt.return None

    method! config_definition = Some (`Bool true)

    method! on_req_definition ~notify_back ~id ~uri ~pos ~workDoneToken
        ~partialResultToken _doc =
      Logs.app (fun m -> m "req definition");
      let st = self#get uri in
      let tokens = st#tokens in
      let ident =
        Bincaml_lsp.Raw_tokens.token_at_pos tokens pos
        |> CCOption.flat_map Bincaml_lsp.Lsp_symbols.ident_of_token
      in
      match ident with
      | None -> Lwt.return None
      | Some ident ->
          let lspsymbols = st#lspsymbols in
          let locations =
            Bincaml_lsp.Lsp_symbols.lspsymbol_of_ident ~lspsymbols ~lsppos:pos
              ident
            |> Iter.map (fun (sym : Bincaml_lsp.Lsp_symbols.symbol) ->
                Logs.app (fun m ->
                    m "%s"
                      (Linol_lsp.Types.DocumentSymbol.yojson_of_t sym
                      |> Yojson.Safe.to_string));
                Linol_lsp.Types.Location.create ~range:sym.selectionRange ~uri)
          in
          let locations = Iter.to_list locations in
          List.iter
            (fun l ->
              Logs.app (fun m ->
                  m "%s"
                    (Linol_lsp.Types.Location.yojson_of_t l
                    |> Yojson.Safe.to_string)))
            locations;
          Lwt.return (Some (`Location locations))

    (* method! on_req_code_lens_resolve ~notify_back ~id code_lens = *)
    (*   Lwt.return code_lens *)
  end

(* Main code
   This is the code that creates an instance of the lsp server class
   and runs it as a task. *)
let run () =
  Printexc.record_backtrace true;
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
