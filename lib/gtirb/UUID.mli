open Bincaml_util.Common
include ORD_TYPE

val pp : Format.formatter -> t -> unit
val of_bytes : Bytes.t -> t
val of_string : String.t -> t
