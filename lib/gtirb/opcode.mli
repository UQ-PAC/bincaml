open Bincaml_util.Common

type t

val to_int : t -> Int32.t

val to_hex_string : t -> string
(** Convert to hex string format [0xffffffff] *)

val to_le_bytes : t -> string
(** Convert to little-endian bytes string *)

val to_be_bytes : t -> string
(** Convert to little-endian bytes string *)

val pp : Format.formatter -> t -> unit
(** The same as {! to_hex_string } *)

val of_be_bytes : string -> t
(** get opcode from big-endian byte string *)

val pp_bytes_le : t -> string
(** Pretty-print {! to_le_bytes} *)

val parse : int -> string -> (t list, string) result
(** Parse block of n opcodes *)

val parse_exn : int -> string -> t list
(** Parse block of n opcodes *)
