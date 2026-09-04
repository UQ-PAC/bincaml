open Containers
(** Error printing *)

(** {2 Error Types} *)

type loc = int * int
(** A text token range; (beginchar, endchar) *)

type location = OffsetRange of loc | Token of Lexing.lexbuf

let show_location = function
  | OffsetRange (a, b) -> Printf.sprintf "char range (%d, %d)" a b
  | Token lexbuf ->
      let a, b = (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf) in
      Printf.sprintf "%s: from %d:%d to %d:%d" a.pos_fname a.pos_lnum a.pos_cnum
        b.pos_lnum b.pos_cnum

let loc_to_position = function
  | OffsetRange (begin_tok, end_tok) ->
      (Pp_loc.Position.of_offset begin_tok, Pp_loc.Position.of_offset end_tok)
  | Token lexbuf ->
      ( Pp_loc.Position.of_lexing @@ Lexing.lexeme_start_p lexbuf,
        Pp_loc.Position.of_lexing @@ Lexing.lexeme_end_p lexbuf )

type location_info = { range : location; description : string option }
(** A source location and what is at this location *)

type error_class =
  | Unhandled  (** Programmer error *)
  | Exception of exn  (** Programmer error *)
  | VerifierAlarm  (** Verification error *)

let show_error_class = function
  | Unhandled -> "programmer_error"
  | Exception exn -> "exception " ^ Printexc.to_string exn
  | VerifierAlarm -> "verification failure"

type error_info = {
  relevant_input_locations : location_info list;  (** Char offset ranges *)
  relevant_source_code_locations : Lexing.position list;
      (** bincaml source code location, if relevant *)
  message : string;  (** context message *)
  reason : error_class;  (** type or error *)
}

type error_context = {
  input : Pp_loc.Input.t option;
  messages : error_info list;
}

(** {2 Annotating error information} *)

(** Add source file to error context *)
let add_source_info ?input c =
  match input with Some _ -> { c with input } | _ -> c

let error_message ?here ?input_location message (reason : error_class) =
  {
    relevant_input_locations = Option.to_list input_location;
    relevant_source_code_locations = Option.to_list here;
    message;
    reason;
  }

let push_message err_info msg =
  { err_info with messages = msg :: err_info.messages }

let update_message ?here ?input_location ?input_file info =
  let top, messages =
    info.messages |> function
    | m :: t -> (m, t)
    | [] -> (error_message "error" Unhandled, [])
  in
  let n =
    {
      top with
      relevant_input_locations =
        Option.to_list input_location @ top.relevant_input_locations;
      relevant_source_code_locations =
        Option.to_list here @ top.relevant_source_code_locations;
    }
  in
  let info = add_source_info ?input:input_file info in
  { info with messages = n :: messages }

exception BincamlError of error_context

let raise_error ?here ?input_location message (reason : error_class) =
  let e = error_message ?here ?input_location message reason in
  raise (BincamlError { input = None; messages = [ e ] })

(** Run a function but add error information to an exception it throws *)
let protect_with_info mod_info f =
  try f ()
  with BincamlError info ->
    let bt = Printexc.get_raw_backtrace () in
    Printexc.raise_with_backtrace (BincamlError (mod_info info)) bt

(** Run a function but add error information to any exception it throws *)
let protect ?here ?input_location ?input_file f =
  try f () with
  | BincamlError info ->
      let bt = Printexc.get_raw_backtrace () in
      let new_err = update_message ?here ?input_location ?input_file info in
      Printexc.raise_with_backtrace (BincamlError new_err) bt
  | other ->
      let m =
        error_message ?here ?input_location "exception" (Exception other)
      in
      let bt = Printexc.get_raw_backtrace () in
      Printexc.raise_with_backtrace
        (BincamlError { input = input_file; messages = [ m ] })
        bt

(** {3 printer}*)

let format_ploc input =
 fun f ->
  Pp_loc.setup_highlight_tags f
    ~single_line_underline:
      {
        open_tag =
          (fun _ -> Format.ANSI_codes.string_of_style_list [ `Bold; `FG `Red ]);
        close_tag = (fun _ -> Format.ANSI_codes.string_of_style `Reset);
      }
    ();

  Pp_loc.pp ~input ~max_lines:5 f

let format_location_info ?input fmt { range; description } =
  let description = Option.get_or ~default:"" description in
  match input with
  | None -> Format.fprintf fmt "%s at " description
  | Some input ->
      Format.fprintf fmt "%s%a%a" description Format.pp_print_newline ()
        (format_ploc input)
        [ loc_to_position range ]

let pp_bincamlerr fmt { messages; input } =
  let format_message fmt
      {
        message;
        reason;
        relevant_input_locations;
        relevant_source_code_locations;
      } =
    let fmt_locations =
      Format.list ~sep:Format.newline (format_location_info ?input)
    in
    let message =
      Format.fprintf fmt "%s : %s%a%a" message (show_error_class reason)
        Format.newline () fmt_locations relevant_input_locations
    in
    message
  in
  let fmt_msgs = Format.list ~sep:Format.newline format_message in
  Format.fprintf fmt "%a" fmt_msgs messages

let () =
  Printexc.register_printer (function
    | BincamlError info -> Some (Format.asprintf "%a" pp_bincamlerr info)
    | _ -> None)
