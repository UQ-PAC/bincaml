open Common

module Logger = struct
  let c = Mtime_clock.counter ()

  let time_stamp_tag : Mtime.span Logs.Tag.def =
    Logs.Tag.def "stamp" ~doc:"Relative monotonic time stamp" Mtime.Span.pp

  let time_stamp () =
    Logs.Tag.(empty |> add time_stamp_tag (Mtime_clock.count c))

  let reporter ppf =
    let report src level ~over k msgf =
      let _ = src in
      let k _ =
        over ();
        k ()
      in
      let with_stamp h tags k ppf fmt =
        let stamp =
          match tags with
          | None -> None
          | Some tags -> Logs.Tag.find time_stamp_tag tags
        in
        let dt =
          match stamp with
          | None -> 0.
          | Some s -> Mtime.Span.to_float_ns s /. 1000000.0
        in
        Format.kfprintf k ppf
          ("%a[%+05.0f ms] @[" ^^ fmt ^^ "@]@.")
          Logs.pp_header (level, h) dt
      in
      msgf @@ fun ?header ?tags fmt -> with_stamp header tags k ppf fmt
    in
    { Logs.report }
end

let reporter ppf =
  let report src level ~over k msgf =
    let k _ =
      over ();
      k ()
    in
    let with_stamp h _tags k ppf fmt =
      Format.kfprintf k ppf
        ("%a (%s) @[" ^^ fmt ^^ "@]@.")
        Logs.pp_header (level, h) (Logs.Src.name src)
    in
    msgf @@ fun ?header ?tags fmt -> with_stamp header tags k ppf fmt
  in
  { Logs.report }
