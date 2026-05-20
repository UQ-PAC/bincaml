open Bincaml_util.Common

type t = string [@@deriving eq, ord]

let of_bytes = String.of_bytes
let of_string s = s
let show t = Base64.encode_exn ~pad:false t
let pp fmt t = Format.pp_print_string fmt (show t)
