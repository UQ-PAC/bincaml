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
  let w = De.Lz77.make_window ~bits:15
  let o = De.bigstring_create De.io_buffer_size
  let i = De.bigstring_create De.io_buffer_size
  let q = De.Queue.create 4096

  let cfg =
    Gz.Higher.configuration Unknown (fun () -> Unix.time () |> Int32.of_float)

  let buffered_refill_flush input =
    let n_used = ref 0 in
    let out_buf = Buffer.create De.io_buffer_size in

    let refill bs =
      let n_to_copy = min De.io_buffer_size (Bytes.length input - !n_used) in
      Iter.int_range ~start:0 ~stop:(n_to_copy - 1)
      |> Iter.map (Int.add !n_used %> Bytes.get input)
      |> Iter.iteri (Bigarray.Array1.set bs);
      n_used := !n_used + n_to_copy;
      n_to_copy
    and flush bs i =
      Iter.to_buffer
        (Iter.int_range ~start:0 ~stop:(i - 1)
        |> Iter.map (Bigarray.Array1.get bs))
        out_buf
    in

    (refill, flush, out_buf)

  (** TODO: compress all bytes? this would be a convenient place to do it. *)
  let to_bytes : t -> bytes = function
    | `String s ->
        let decoded = Base64.decode_exn s |> Bytes.unsafe_of_string in
        let refill, flush, out_buf = buffered_refill_flush decoded in
        let _ : Gz.Higher.metadata =
          Gz.Higher.uncompress ~refill ~flush i o
          |> Result.map_err (fun (`Msg x) -> x)
          |> Result.get_or_failwith
        in
        Buffer.to_bytes out_buf
    | _ -> invalid_arg "expected `String"

  let of_bytes : bytes -> t =
   fun x ->
    let refill, flush, out_buf = buffered_refill_flush x in
    Gz.Higher.compress ~w ~q ~refill ~flush () cfg i o;
    let compressed = Buffer.to_bytes out_buf in
    `String (Base64.encode_exn (Bytes.unsafe_to_string compressed))

  (** TODO: null? or maybe make this unsup. *)
  let null : t = `Bitvector (Bitvec.zero ~size:0)

  let is_null : t -> bool = function `Bitvector { w = 0 } -> true | _ -> false
end

(** Custom parameters. We add a leading [.] to field names so it matches the
    attrib syntax. *)
module Parameters : Ppx_protocol_driver.Parameters = struct
  include Ppx_protocol_driver.Default_parameters

  let field_name s = "." ^ s
end

(** {2 Generated driver} *)

(** Below this is generated using the {!Ppx_protocol_driver.Make} module
    functor. *)

type t = Attrib.t
(** @canonical Lang.Attrib.t *)

include (
  Ppx_protocol_driver.Make (Driver) (Parameters) :
      Protocol_conv.Runtime.Driver with type t := Attrib.t)
(** @inline *)
