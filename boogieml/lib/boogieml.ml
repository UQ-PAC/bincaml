open Containers

open struct
  let error_re =
    let e = {|(.+\.bpl)\(([0-9]+),([0-9]+)\): Error: (.*)|} in
    Re.Pcre.regexp e

  let related_loc =
    let e = {|(.+\.bpl)\(([0-9]+),([0-9]+)\): Related location: (.*)|} in
    Re.Pcre.regexp e

  let trace_loc =
    let e = {|Execution trace:\n((?:    .*\n)+)|} in
    Re.Pcre.regexp e

  let summary_loc =
    let e =
      {|Boogie program verifier finished with ([0-9]+) verified, ([0-9]+) errors|}
    in
    Re.Pcre.regexp e
end

type err_info = {
  msg : string;
  line : int;
  col : int;
  filename : string;
  related : err_info option;
  trace : string list;
}

type result = { errs : err_info list; verified_count : int; failed_count : int }

let line_of_err m =
  let input = Pp_loc.Input.file m.filename in
  let beginloc = Pp_loc.Position.of_line_col m.line m.col in
  let beginoff = Pp_loc.Position.to_offset input beginloc in
  let e =
    CCIO.with_in m.filename (fun i ->
        In_channel.seek i (Int64.of_int @@ beginoff);
        while
          match In_channel.input_char i with
          | Some '\n' -> false
          | None -> false
          | _ -> true
        do
          ()
        done;
        let p = In_channel.pos i |> Int64.to_int in
        p)
  in
  let eloc = Pp_loc.Position.of_offset e in
  [ (beginloc, Pp_loc.Position.shift eloc (-1)) ]

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

let format_error_info fmt (m : err_info) =
  let input = Pp_loc.Input.file m.filename in
  let ploc fmt loc =
    Pp_loc.setup_highlight_tags fmt
      ~single_line_underline:
        {
          open_tag =
            (fun _ ->
              Format.ANSI_codes.string_of_style_list [ `Bold; `FG `Red ]);
          close_tag = (fun _ -> Format.ANSI_codes.string_of_style `Reset);
        }
      ();
    Pp_loc.pp ~input fmt loc
  in
  let relatedloc fmt =
    match m.related with
    | Some e ->
        Format.fprintf fmt "@\nRelated: %s@\n" e.msg;
        ploc fmt (line_of_err e)
    | None -> ()
  in
  Format.fprintf fmt "Error: %s@\n" m.msg;
  ploc fmt (line_of_err m);

  Format.pp_open_vbox fmt 2;
  relatedloc fmt;

  (match m.trace with
  | [] -> ()
  | trace ->
      Format.fprintf fmt "@\nExecution trace:@\n";
      List.iter (Format.fprintf fmt "  %s@\n") trace);

  Format.pp_close_box fmt ();

  Format.pp_force_newline fmt ()

let format_result fmt r =
  Format.fprintf fmt
    "Boogie program verifier finished with %d verified, %d errors"
    r.verified_count r.failed_count;
  Format.pp_force_newline fmt ();
  Format.pp_force_newline fmt ();
  List.iter (format_error_info fmt) r.errs

let get_error msg =
  let r = Re.exec summary_loc msg in
  let n_ok = Re.Group.get r 1 |> Int.of_string_exn in
  let n_err = Re.Group.get r 2 |> Int.of_string_exn in
  let errs =
    let m = Re.all error_re msg in
    m
    |> List.map (fun g ->
        begin
          let filename = Re.Group.get g 1 in
          let line = Re.Group.get g 2 |> Int.of_string_exn in
          let col = Re.Group.get g 3 |> Int.of_string_exn in
          let emsg = Re.Group.get g 4 in
          let _, pos = Re.Group.offset g 0 in
          let trace =
            Re.exec_opt trace_loc ~pos msg
            |> Option.map (fun g -> Re.Group.get g 1)
            |> Option.map String.lines |> Option.get_or ~default:[]
            |> List.map String.trim
          in
          let rloc = Re.exec_opt related_loc ~pos msg in
          let related =
            Option.bind rloc (function
              | g when fst (Re.Group.offset g 0) - pos < 5 ->
                  let filename = Re.Group.get g 1 in
                  let line = Re.Group.get g 2 |> Int.of_string_exn in
                  let col = Re.Group.get g 3 |> Int.of_string_exn in
                  let msg = Re.Group.get g 4 in
                  Some { msg; line; col; filename; related = None; trace = [] }
              | _ -> None)
          in
          { msg = emsg; line; col; filename; related; trace }
        end)
  in
  { verified_count = n_ok; failed_count = n_err; errs }

let run_file ?(args = "") file =
  let ou, _, _ = CCUnix.call "boogie %s %s" file args in
  get_error ou

let run_boogie args =
  let ou, _, _ = CCUnix.call "boogie %s" args in
  get_error ou
