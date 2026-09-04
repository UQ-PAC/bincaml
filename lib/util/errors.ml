open Containers
(** Error printing *)

(** {2 Error Types} *)

type loc = int * int
(** A text token range; (beginchar, endchar) *)

type location =
  | OffsetRange of loc
  | Token of Lexing.lexbuf
  | Position of (Lexing.position * Lexing.position)
  | PPPosition of (Pp_loc.Position.t * Pp_loc.Position.t)

let show_location = function
  | OffsetRange (a, b) -> Printf.sprintf "char range (%d, %d)" a b
  | Token lexbuf ->
      let a, b = (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf) in
      Printf.sprintf "%s: from %d:%d to %d:%d" a.pos_fname a.pos_lnum a.pos_cnum
        b.pos_lnum b.pos_cnum
  | Position (a, b) ->
      Printf.sprintf "%s: from %d:%d to %d:%d" a.pos_fname a.pos_lnum a.pos_cnum
        b.pos_lnum b.pos_cnum
  | PPPosition (a, b) -> "position"

let loc_to_position = function
  | OffsetRange (begin_tok, end_tok) ->
      (Pp_loc.Position.of_offset begin_tok, Pp_loc.Position.of_offset end_tok)
  | Token lexbuf ->
      ( Pp_loc.Position.of_lexing @@ Lexing.lexeme_start_p lexbuf,
        Pp_loc.Position.of_lexing @@ Lexing.lexeme_end_p lexbuf )
  | Position (b, e) -> (Pp_loc.Position.of_lexing b, Pp_loc.Position.of_lexing e)
  | PPPosition (a, b) -> (a, b)

type location_info = { range : location; description : string option }
(** A source location and what is at this location *)

let location_loc ?msg a = { range = OffsetRange a; description = msg }
let location_lexing ?msg a = { range = Token a; description = msg }
let location_position ?msg a = { range = Position a; description = msg }

type error_class =
  | Unhandled  (** Programmer error *)
  | InputError  (** input error *)
  | Error  (** input error *)
  | Exception of exn  (** Programmer error *)
  | VerifierAlarm  (** Verification error *)

let show_error_class = function
  | Unhandled -> "programmer_error"
  | Exception exn -> "exception " ^ Printexc.to_string exn
  | VerifierAlarm -> "verification failure"
  | InputError -> "input error"
  | Error -> "error"

type extra_loc_info =
  | Sourcecode of Lexing.position  (** input file *)
  | OtherFile of {
      name : string;  (** informative name *)
      input : Pp_loc.Input.t;  (** input *)
      locations : location list;  (** locations to print *)
    }  (** contextual information *)

type error_info = {
  relevant_input_locations : location_info list;  (** Char offset ranges *)
  relevant_source_code_locations : extra_loc_info list;
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
let add_input ?input ?input_file ?input_channel c =
  let input =
    Option.or_ c.input
      ~else_:
        (Option.or_ input
           ~else_:
             (Option.or_
                (Option.map Pp_loc.Input.file input_file)
                ~else_:(Option.map Pp_loc.Input.in_channel input_channel)))
  in
  { c with input }

let error_message ?here ?input_location message (reason : error_class) =
  {
    relevant_input_locations = Option.to_list input_location;
    relevant_source_code_locations = Option.to_list here;
    message;
    reason;
  }

let push_message msg err_info =
  { err_info with messages = msg :: err_info.messages }

let update_message ?here ?input_location ?input info =
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
  let info = add_input ?input info in
  { info with messages = n :: messages }

exception BincamlError of error_context

let error ?here ?input_location ?input ?input_file ?input_channel message
    (reason : error_class) =
  let e = error_message ?here ?input_location message reason in
  let e =
    { input = None; messages = [ e ] }
    |> add_input ?input ?input_file ?input_channel
  in
  e

let reraise_error ?here ?input_location message (reason : error_class) =
  let bt = Printexc.get_raw_backtrace () in
  let e = error_message ?here ?input_location message reason in
  raise (BincamlError { input = None; messages = [ e ] }) bt

let raise_error ?here ?input_location message (reason : error_class) =
  let e = error_message ?here ?input_location message reason in
  raise (BincamlError { input = None; messages = [ e ] })

(** Run a function but add error information to an exception it throws *)
let protect_with_info mod_info f =
  try f ()
  with err -> (
    let bt = Printexc.get_raw_backtrace () in
    match mod_info err with
    | Some e -> Printexc.raise_with_backtrace (BincamlError e) bt
    | None -> Printexc.raise_with_backtrace err bt)

let error_of_exn ?here ?input_location ?input = function
  | BincamlError info ->
      let new_err = update_message ?here ?input_location ?input info in
      new_err
  | other ->
      let m =
        error_message ?here ?input_location "exception" (Exception other)
      in
      { input; messages = [ m ] }

(** Run a function but add error information to any exception it throws *)
let wrap_error ?here ?input_location ?input f =
  try f ()
  with e ->
    let bt = Printexc.get_raw_backtrace () in
    Printexc.raise_with_backtrace
      (BincamlError (error_of_exn ?here ?input_location ?input e))
      bt

(** Run a function but add error information to any exception it throws *)
let update_error info f =
  try f ()
  with BincamlError ex ->
    let bt = Printexc.get_raw_backtrace () in
    Printexc.raise_with_backtrace (BincamlError (info ex)) bt

(** {3 printer}*)

let format_location input =
 fun f l ->
  Pp_loc.setup_highlight_tags f
    ~single_line_underline:
      {
        open_tag =
          (fun _ -> Format.ANSI_codes.string_of_style_list [ `Bold; `FG `Red ]);
        close_tag = (fun _ -> Format.ANSI_codes.string_of_style `Reset);
      }
    ();

  Pp_loc.pp ~input ~max_lines:5 f (List.map loc_to_position l)

let format_location_info ?input fmt { range; description } =
  let description = Option.get_or ~default:"" description in
  match input with
  | None -> Format.fprintf fmt "%s at " description
  | Some input ->
      Format.fprintf fmt "%s%a%a" description Format.pp_print_newline ()
        (format_location input) [ range ]

let format_extra_location_info fmt = function
  | Sourcecode p ->
      let input = Pp_loc.Input.file p.pos_fname in
      let pos = Position (p, p) in
      Format.fprintf fmt "%s:%d:%d%a%a" p.pos_fname p.pos_lnum p.pos_cnum
        Format.newline () (format_location input) [ pos ]
  | OtherFile { name; input; locations } ->
      Format.fprintf fmt "%s%a%a" name Format.pp_print_newline ()
        (format_location input) locations

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
    let fmt_extra_locations =
      Format.list ~sep:Format.newline format_extra_location_info
    in
    Format.fprintf fmt "%s: %s%a%a" (show_error_class reason) message
      Format.newline () fmt_locations relevant_input_locations;
    Format.pp_force_newline fmt ();
    if List.is_empty relevant_source_code_locations |> not then begin
      Format.fprintf fmt "Related locations:";
      Format.pp_force_newline fmt ();
      Format.fprintf fmt "%a" fmt_extra_locations relevant_source_code_locations
    end
  in
  let fmt_msgs = Format.list ~sep:Format.newline format_message in
  Format.fprintf fmt "%a" fmt_msgs (List.rev messages)

let regprinter () =
  Printexc.register_printer (function
    | BincamlError info -> Some (Format.asprintf "%a" pp_bincamlerr info)
    | _ -> None)

let () = regprinter ()
