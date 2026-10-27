open Bincaml_util.Common


open struct

  module Uuid = struct
        type t = string [@@deriving eq, ord]

        let of_bytes = String.of_bytes
        let of_string s = s
        let show t = Base64.encode_exn ~pad:false t
        let pp fmt t = Format.pp_print_string fmt (show t)
      end

end

(** @inline *)
include (Uuid : sig
include ORD_TYPE

val pp : Format.formatter -> t -> unit
val of_bytes : Bytes.t -> t
val of_string : String.t -> t
         end)

module Map = CCMap.Make (struct
    type nonrec t = t
  let compare = compare end)
module Set = CCSet.Make (
(struct
    type nonrec t = t
  let compare = compare end)
    )
