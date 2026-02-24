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
  contents : string;
  mutable debug_highlight : bool;
}

let iter_tokens st : 'a list =
  let lexbuf = Lexing.from_string ~with_positions:true st.contents in
  Bincaml_lsp.Raw_tokens.extract_all_tokens lexbuf |> Iter.to_list

let process_some_input_file (contents : string) : state_after_processing =
  { contents; debug_highlight = false }

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
  Lsp.Types.Diagnostic.create ~message:(`String str) ~range ()

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
      let new_state = process_some_input_file contents in
      Hashtbl.replace buffers uri new_state;
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
    method! config_code_action_provider =
      let open Linol_lsp.Lsp.Types.CodeActionKind in
      `Bool true

    method! on_req_execute_command ~notify_back ~id ~workDoneToken cmd args =
      Logs.app (fun m -> m "execute");
      match (cmd, args) with
      | "toggle-highlight", Some [ uri ] ->
          let uri = Linol_lsp.Lsp.Types.DocumentUri.t_of_yojson uri in
          let st = self#get uri in
          st.debug_highlight <- not st.debug_highlight;

          notify_back#set_uri uri;
          let open Lwt.Syntax in
          let* diags =
            if st.debug_highlight then
              iter_tokens (self#get uri)
              |> Lwt_list.map_p (fun x -> x |> to_diagnostic |> Lwt.return)
            else Lwt.return []
          in
          let+ () = notify_back#send_diagnostic diags in
          Yojson.Safe.(`Null)
      | _ ->
          super#on_req_execute_command ~notify_back ~id ~workDoneToken cmd args

    method! on_req_code_action ~notify_back ~id params =
      Logs.app (fun m -> m "reqcodeaction");
      let uri = params.textDocument.uri in
      Lwt.return
        (Some [ `CodeAction (self#toggle_highlight_code_action ~uri ()) ])

    (* method! on_req_code_lens_resolve ~notify_back ~id code_lens = *)
    (*   Lwt.return code_lens *)
  end

(* Main code
   This is the code that creates an instance of the lsp server class
   and runs it as a task. *)
let run () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Bincaml_lsp.Logs.file_reporter ());
  (* Logs.set_reporter (Bincaml_lsp.Logs.lwt_reporter ()); *)
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
