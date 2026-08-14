(* ocamlobjinfo *)

open Bos

let ocamlobjinfo = Cmd.v "ocamlobjinfo"

let source_possibilities file =
  let default = [ file ] in
  let generated =
    if Astring.String.is_suffix ~affix:"-gen" file then
      let pos = String.length file - 4 in
      [ Astring.String.take ~max:pos file ]
    else []
  in
  let pp =
    if Astring.String.is_suffix ~affix:".pp.ml" file then
      let pos = String.length file - 5 in
      [ Astring.String.take ~max:pos file ^ "ml" ]
    else []
  in
  pp @ default @ generated

let source_possibilities file =
  let file = Fpath.(v file) in
  match Astring.String.cut ~sep:"__" Fpath.(filename (rem_ext file)) with
  (* filename has `__`. this is probably a dune-generated file, whose path is fully described by the filename. *)
  | Some (_lib_name, rest) ->
      let parts =
        Astring.String.cuts ~sep:"__" rest |> List.map String.uncapitalize_ascii
      in
      let ext = Fpath.get_ext file in
      source_possibilities (Astring.String.concat ~sep:"/" parts ^ ext)
      @ source_possibilities
          (Astring.String.concat ~sep:"/"
             (parts
             @ [ List.nth parts (List.length parts - 1) ^ Fpath.get_ext file ]))
  | None ->
      (* this is probably an original source file, whose path may be copied into a different subtree. *)
      let segs = Fpath.segs file in
      let rec tails = function
        | [] -> [ [] ]
        | _ :: rest as xs -> xs :: tails rest
      in
      let possibilities =
        tails segs
        |> List.map (String.concat Fpath.dir_sep)
        |> List.filter (fun x -> String.length x <> 0)
      in
      List.concat_map source_possibilities possibilities

let get_source file srcdirs =
  let cmd = Cmd.(ocamlobjinfo % p file) in
  let lines_res =
    Worker_pool.submit ("Ocamlobjinfo " ^ Fpath.to_string file) cmd None
  in
  let lines =
    match lines_res with
    | Ok l -> String.split_on_char '\n' l.output
    | Error e ->
        Logs.err (fun m ->
            m "Error finding source for module %a: %s" Fpath.pp file
              (Printexc.to_string e));
        []
  in
  let f =
    List.filter_map
      (fun line ->
        let affix = "Source file: " in
        if Astring.String.is_prefix ~affix line then
          let name =
            String.sub line (String.length affix)
              (String.length line - String.length affix)
          in
          let name =
            String.sub line (String.length affix)
              (String.length line - String.length affix)
          in
          let possibilities =
            List.map
              (fun dir ->
                List.map
                  (fun poss -> Fpath.(dir // v poss))
                  (source_possibilities name))
              srcdirs
            |> List.flatten
          in
          List.find_opt
            (fun f ->
              Logs.debug (fun m -> m "src: checking %a" Fpath.pp f);
              Sys.file_exists (Fpath.to_string f))
            possibilities
        else None)
      lines
  in
  match f with
  | [] -> None
  | x :: _ :: _ ->
      Logs.warn (fun m -> m "Multiple source files found for %a" Fpath.pp file);
      Some x
  | x :: _ -> Some x
