let lwt_reporter () =
  let buf_fmt ~like =
    let b = Buffer.create 512 in
    Fmt.with_buffer ~like b,
    fun () -> let m = Buffer.contents b in Buffer.reset b; m
  in
  let app_fmt = Format.formatter_of_out_channel (open_out "bincaml_lsp.out") in
  let dst_fmt = Format.formatter_of_out_channel (open_out "bincaml_lsp.err") in
  let app, app_flush = buf_fmt ~like:app_fmt in
  let dst, dst_flush = buf_fmt ~like:dst_fmt in
  let reporter = Logs_fmt.reporter ~app ~dst () in
  let report src level ~over k msgf =
    let k () =
      let write () = match level with
      | Logs.App -> Lwt_io.write Lwt_io.stdout (app_flush ())
      | _ -> Lwt_io.write Lwt_io.stderr (dst_flush ())
      in
      let unblock () = over (); Lwt.return_unit in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Deps.Logs.report src level ~over:(fun () -> ()) k msgf
  in
  { Deps.Logs.report = report }

let file_reporter () =
  let app = Format.formatter_of_out_channel (open_out "/home/rina/progs/obasil/lsp/bincaml_lsp.out") in
  let dst = Format.formatter_of_out_channel (open_out "/home/rina/progs/obasil/lsp/bincaml_lsp.err") in
  Logs.format_reporter ~app ~dst ()

