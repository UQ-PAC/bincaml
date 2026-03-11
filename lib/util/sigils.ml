(** sigils constants

    Bincaml uses sigils to avoid ambiguity between identifier types. *)

open Containers

let sigil_local = None
let sigil_global = Some '$'
let sigil_block = Some '%'
let sigil_proc = Some '@'
let sigil_attrib = Some '.'

let apply_sigil sigil n =
  match Option.map String.of_char sigil with
  | Some req_sigil when String.prefix ~pre:req_sigil n -> n
  | Some req_sigil -> req_sigil ^ n
  | None -> n

let drop_sigil sigil n =
  let open Option in
  sigil >|= String.of_char
  >>= (fun pre -> String.chop_prefix ~pre n)
  |> Option.get_or ~default:n

let has_sigil sigil n =
  Option.for_all
    (fun s -> String.starts_with ~prefix:(String.of_char s) n)
    sigil
