open Common

module Logger = struct
  let c = Mtime_clock.counter ()

  let time_stamp_tag : Mtime.span Logs.Tag.def =
    Logs.Tag.def "time-stamp" ~doc:"Relative monotonic time stamp" Mtime.Span.pp

  let file_name_tag : string Logs.Tag.def =
    Logs.Tag.def "file" ~doc:"File name: Get by __POS__" String.pp

  let time_stamp () =
     Logs.Tag.(empty |> add time_stamp_tag (Mtime_clock.count c))

  let stamps (file, col, _, _) =
    Logs.Tag.add file_name_tag (file^":"^Int.to_string col)
      (Logs.Tag.add time_stamp_tag (Mtime_clock.count c) Logs.Tag.empty)

  let reporter ppf =
    let report src level ~over k msgf =
      let _ = src in
      let k _ =
        over ();
        k ()
      in
      let with_stamp h tags k ppf fmt =
        let time_stamp =
          match tags with
          | None -> None
          | Some tags -> Logs.Tag.find time_stamp_tag tags
        in
        let dt =
          match time_stamp with
          | None -> 0.
          | Some s -> Mtime.Span.to_float_ns s /. 1000000.0
        in
        let file_name_stamp =
          match tags with
          | None -> None
          | Some tags -> Logs.Tag.find file_name_tag tags
        in
        let file = match file_name_stamp with None -> "" | Some s -> s ^ " " in
        Format.kfprintf k ppf
          ("%a[%s%+05.0f ms] @[" ^^ fmt ^^ "@]@.")
          Logs.pp_header (level, h) file dt
      in
      msgf @@ fun ?header ?tags fmt -> with_stamp header tags k ppf fmt
    in
    { Logs.report }
end
