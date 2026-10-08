open Bincaml_util.Common

(** Defined conversion functions to/from Bincaml attributes. *)
module Driver = struct
  type t = Attrib.t

  let to_string_hum : t -> string = Attrib.to_string

  let to_list : t -> t list = function
    | `List xs -> xs
    | _ -> invalid_arg "expected `List"

  let of_list : t list -> t = fun xs -> `List xs
  let is_list : t -> bool = function `List _ -> true | _ -> false

  let to_alist : t -> (string * t) list = function
    | `Assoc map -> StringMap.bindings map
    | _ -> invalid_arg "expected `Assoc"

  let of_alist : (string * t) list -> t =
   fun xs -> `Assoc (StringMap.of_list xs)

  let is_alist : t -> bool = function `Assoc _ -> true | _ -> false

  let to_char : t -> char = function
    | `Integer n -> Z.to_int n |> Char.chr
    | _ -> invalid_arg "expected `Integer"

  let of_char : char -> t = fun n -> `Integer (Z.of_int (Char.code n))

  let to_int : t -> int = function
    | `Integer n -> Z.to_int n
    | _ -> invalid_arg "expected `Integer"

  let of_int : int -> t = fun n -> `Integer (Z.of_int n)

  let to_int32 : t -> int32 = function
    | `Integer n -> Z.to_int32 n
    | _ -> invalid_arg "expected `Integer"

  (** TODO: should these be unsigned or signed?? *)
  let of_int32 : int32 -> t = fun n -> `Integer (Z.of_int32 n)

  let to_int64 : t -> int64 = function
    | `Integer n -> Z.to_int64 n
    | _ -> invalid_arg "expected `Integer"

  let of_int64 : int64 -> t = fun n -> `Integer (Z.of_int64 n)

  let to_nativeint : t -> nativeint = function
    | `Integer n -> Z.to_nativeint n
    | _ -> invalid_arg "expected `Integer"

  let of_nativeint : nativeint -> t = fun n -> `Integer (Z.of_nativeint n)
  let to_float : t -> float = fun _ -> invalid_arg "float unsupported"
  let of_float : float -> t = fun _ -> invalid_arg "float unsupported"

  let to_string : t -> string = function
    | `String s -> s
    | _ -> invalid_arg "expected `String"

  let of_string : string -> t = fun s -> `String s
  let is_string : t -> bool = function `String _ -> true | _ -> false

  let to_bool : t -> bool = function
    | `Bool b -> b
    | _ -> invalid_arg "expected `Bool"

  let of_bool : bool -> t = fun b -> `Bool b

  (** TODO: compress all bytes? this would be a convenient place to do it. *)
  let to_bytes : t -> bytes = fun x -> to_string x |> Bytes.unsafe_of_string

  let of_bytes : bytes -> t = fun x -> Bytes.to_string x |> of_string

  (** TODO: null? or maybe make this unsup. *)
  let null : t = `Bitvector (Bitvec.zero ~size:0)

  let is_null : t -> bool = function `Bitvector { w = 0 } -> true | _ -> false
end

(** {2 Generated driver} *)

(** Below this is generated using the {!Ppx_protocol_driver.Make} module
    functor. *)

type t = Attrib.t
(** @canonical Lang.Attrib.t *)

include (
  Ppx_protocol_driver.Make (Driver) (Ppx_protocol_driver.Default_parameters) :
      Protocol_conv.Runtime.Driver with type t := Attrib.t)
(** @inline *)
