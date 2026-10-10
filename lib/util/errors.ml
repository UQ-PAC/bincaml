open Containers
(** Error printing *)

(** {2 Error Types} *)

type loc = int * int
(** A text token range; (beginchar, endchar) *)

(** Information about some location in text or file *)
type location =
  | OffsetRange of loc  (** Character offset range *)
  | Lexbuf of Lexing.lexbuf
      (** Lexbuf mid-parsing (use last token as position) *)
  | Lexing of (Lexing.position * Lexing.position option)
  | PPPosition of (Pp_loc.Position.t * Pp_loc.Position.t)
      (** PP_loc position range *)
  | Everything  (** whole file *)

(** Pretty-print a location numerically, without a known input file *)
let show_location = function
  | OffsetRange (a, b) -> Printf.sprintf "char range (%d, %d)" a b
  | Lexbuf lexbuf ->
      let a, b = (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf) in
      Printf.sprintf "%s: from %d:%d to %d:%d" a.pos_fname a.pos_lnum a.pos_cnum
        b.pos_lnum b.pos_cnum
  | Lexing (a, b) ->
      let b =
        match b with
        | Some b -> Printf.sprintf " to %d:%d" b.pos_lnum b.pos_cnum
        | _ -> ""
      in
      Printf.sprintf "%s: from %d:%d%s" a.pos_fname a.pos_lnum a.pos_cnum b
  | PPPosition (a, b) -> "PPPosition ?" (* cannot convert back *)
  | Everything -> "file"

let loc_to_position = function
  | OffsetRange (begin_tok, end_tok) ->
      Some
        (Pp_loc.Position.of_offset begin_tok, Pp_loc.Position.of_offset end_tok)
  | Lexbuf lexbuf ->
      Some
        ( Pp_loc.Position.of_lexing @@ Lexing.lexeme_start_p lexbuf,
          Pp_loc.Position.of_lexing @@ Lexing.lexeme_end_p lexbuf )
  | Lexing (b, Some e) ->
      Some (Pp_loc.Position.of_lexing b, Pp_loc.Position.of_lexing e)
  | PPPosition (a, b) -> Some (a, b)
  | _ -> None

type ref_file =
  | Input of Pp_loc.Input.t
  | SourceFile  (** The input file *)
  | RawString of string  (** just string content *)

type error_context_info = {
  description : string option;  (** What is this object? Why is it relevant? *)
  loc : location;  (** Location in relevant 'file'. *)
  input : ref_file;  (** 'file' we are referring to. *)
}
(** A source location and what is at this location *)

let location ?msg a =
  { loc = OffsetRange a; description = msg; input = SourceFile }

let location_loc ?msg ?(input = SourceFile) a =
  { loc = OffsetRange a; description = msg; input }

let location_lexing ?msg ?(input = SourceFile) a =
  { loc = Lexbuf a; description = msg; input }

let location_position ?msg ?(input = SourceFile) a =
  { loc = Lexing a; description = msg; input }

let location_pp_position ?msg ?(input = SourceFile) a =
  { loc = PPPosition a; description = msg; input }

let context_callsite msg (loc : Lexing.position) =
  let input = Input (Pp_loc.Input.file loc.pos_fname) in
  { description = Some msg; input; loc = Lexing (loc, None) }

let context_message ?msg content =
  { loc = Everything; description = msg; input = RawString content }

type error_class =
  | Unhandled  (** Undefined output for some case *)
  | InputError  (** Input program malformed *)
  | TypeError  (** Type error *)
  | Error  (** Programmer error *)
  | Exception of exn  (** Programmer error; wrapper for other exceptions *)
  | VerifierAlarm  (** Verification error *)

let show_error_class = function
  | Unhandled -> "Programmer error"
  | Exception exn -> "Exception " ^ Printexc.to_string exn
  | VerifierAlarm -> "Verification failure"
  | InputError -> "Input error"
  | TypeError -> "Type error"
  | Error -> "Error"

type error_info = {
  message : string;  (** Error message *)
  reason : error_class;  (** Type of error *)
  input : Pp_loc.Input.t option;
      (** Input corresponding to [SourceFile] (the bincaml il) *)
  error_context : error_context_info list;  (** List of context information *)
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

let error_message ?here ?input ?ctx_info message (reason : error_class) =
  let here =
    Option.map (context_callsite "Bincaml source") here |> Option.to_list
  in
  { error_context = here @ Option.to_list ctx_info; input; message; reason }

let add_error_context ?ctx_info ?input info =
  let n =
    { info with error_context = Option.to_list ctx_info @ info.error_context }
  in
  let info = add_input ?input n in
  info

exception BincamlError of error_info

let error ?here ?ctx_info ?input ?input_file ?input_channel message
    (reason : error_class) =
  error_message ?here ?ctx_info message reason
  |> add_input ?input ?input_file ?input_channel

let reraise_error ?here ?ctx_info message (reason : error_class) =
  let bt = Printexc.get_raw_backtrace () in
  let e =
    error_message ?here ?ctx_info message reason
    |> add_error_context
         ?ctx_info:(Option.map (context_callsite "rethrown from") here)
  in
  Printexc.raise_with_backtrace (BincamlError e) bt

let raise_error ?here ?ctx_info message (reason : error_class) =
  let e =
    error_message ?ctx_info message reason
    |> add_error_context
         ?ctx_info:(Option.map (context_callsite "thrown from") here)
  in
  raise (BincamlError e)

(** Run a function but add error information to an exception it throws *)
let protect_with_info mod_info f =
  try f ()
  with err -> (
    let bt = Printexc.get_raw_backtrace () in
    match mod_info err with
    | Some e -> Printexc.raise_with_backtrace (BincamlError e) bt
    | None -> Printexc.raise_with_backtrace err bt)

let error_of_exn ?ctx_info ?input = function
  | BincamlError info ->
      let new_err = add_error_context ?ctx_info ?input info in
      new_err
  | other ->
      let m = error_message ?ctx_info "exception" (Exception other) in
      m

(** Run a function but add error information to any exception it throws *)
let wrap_error ?here ?ctx_info ?input f =
  try f ()
  with e ->
    let bt = Printexc.get_raw_backtrace () in
    Printexc.raise_with_backtrace
      (BincamlError (error_of_exn ?ctx_info ?input e))
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

  let ps = List.filter_map loc_to_position l in
  if not @@ List.is_empty ps then Pp_loc.pp ~input ~max_lines:5 f ps
  else
    Format.list ~sep:Format.newline
      (fun f a -> Format.fprintf f "%s" @@ show_location a)
      f l

let format_context_info ?source fmt { loc; input; description; _ } =
  let description = Option.get_or ~default:"" description in
  match (input, source) with
  | Input input, _ | SourceFile, Some input ->
      Format.fprintf fmt "%s%a%a" description Format.pp_print_newline ()
        (format_location input) [ loc ]
  | _ -> Format.fprintf fmt "%s at " description

(*
let format_extra_location_info fmt = function
  | Sourcecode p ->
      let input = Pp_loc.Input.file p.pos_fname in
      let pos = Position (p, p) in
      Format.fprintf fmt "%s:%d:%d%a%a" p.pos_fname p.pos_lnum p.pos_cnum
        Format.newline () (format_location input) [ pos ]
  | OtherFile { name; input; locations } -> (
      try
        Format.fprintf fmt "%s%a%a" name Format.pp_print_newline ()
          (format_location input) locations
      with Sys_error _ ->
        Format.fprintf fmt "\"%s\" (error: no such file)" name) *)

let pp_bincamlerr fmt { message; reason; error_context; input } =
  let fmt_locations =
    Format.list ~sep:Format.newline (format_context_info ?source:input)
  in
  Format.fprintf fmt "%s: %s%a" (show_error_class reason) message Format.newline
    ();
  Format.pp_force_newline fmt ();
  if List.is_empty error_context |> not then begin
    Format.fprintf fmt "Related context:";
    Format.pp_force_newline fmt ();
    Format.fprintf fmt "%a" fmt_locations error_context
  end

let () =
  Printexc.register_printer (function
    | BincamlError info -> Some (Format.asprintf "%a" pp_bincamlerr info)
    | _ -> None)

let to_result f =
  try Ok (f ())
  with BincamlError e -> Error (Format.asprintf "%a" pp_bincamlerr e)
