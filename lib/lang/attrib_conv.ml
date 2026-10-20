open Bincaml_util.Common

(** Private implementation helpers for (de)compression. *)
module Internal = struct
  (** We use {:https://github.com/mirage/decompress} in this module. Although
      {:https://github.com/xavierleroy/camlzip} is perhaps more commonly used,
      its Ocaml API requires reading from a {!in_channel} which would require
      writing to disk (or Unix pipes). *)

  (** These default constants are copied from:
      {:https://github.com/mirage/decompress/blob/d0e44781ed329c7ebde7bf6dbcbe547c87554303/bin/decompress.ml}
  *)

  let w = De.Lz77.make_window ~bits:15
  let q = De.Queue.create 1024
  let make_cfg = Gz.Higher.configuration Unknown (Fun.const Int32.zero)
  let buffer_size = 1024

  type compress_fns = { compress : bytes -> bytes; decompress : bytes -> bytes }
  (** Functions for compressing and decompressing bytes. Each function
      {i copies} its given bytes input. Each instance of {!compress_fns}
      operates over its own intermediate buffers. *)

  (** Makes a new instance of {!compress_fns} with input from the given bytes.
  *)
  let make_compress_fns () =
    let source = ref (CCByte_slice.create Bytes.empty) in
    let set_source bytes = source := CCByte_slice.create bytes in

    let in_buf = De.bigstring_create buffer_size
    and out_buf = De.bigstring_create buffer_size in

    let result = CCByte_buffer.create () in
    let get_result () = CCByte_buffer.contents_bytes result in

    let refill bs =
      let n_to_copy = min De.io_buffer_size (CCByte_slice.len !source) in
      for i = 0 to n_to_copy - 1 do
        bs.{i} <- CCByte_slice.get !source 0;
        CCByte_slice.consume !source 1
      done;
      n_to_copy
    and flush bs i =
      Iter.int_range ~start:0 ~stop:(i - 1)
      |> Iter.map (Bigarray.Array1.get bs)
      |> CCByte_buffer.append_iter result
    in

    {
      compress =
        (fun bytes ->
          set_source bytes;
          Gz.Higher.compress ~w ~q ~refill ~flush () make_cfg in_buf out_buf;
          get_result ());
      decompress =
        (fun bytes ->
          set_source bytes;
          (* ignore returned metadata but ensure it succeeded *)
          let _ : Gz.Higher.metadata =
            Gz.Higher.uncompress ~refill ~flush in_buf out_buf
            |> Result.map_err (fun (`Msg x) -> x)
            |> Result.get_or_failwith
          in
          get_result ());
    }

  (** Wrappers around {!Gz.Higher} functions to provide a [bytes -> bytes]
      interface. *)

  let compress bytes =
    let { compress; _ } = make_compress_fns () in
    compress bytes

  let decompress bytes =
    let { decompress; _ } = make_compress_fns () in
    decompress bytes
end

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

  let rec to_bytes : t -> bytes = function
    | `String s ->
        Base64.decode_exn s |> Bytes.unsafe_of_string |> Internal.decompress
    | `List parts ->
        (* Handle BASIL's output which is a list of b64 strings. *)
        let parts = List.map to_string parts in
        `String (String.concat "" parts) |> to_bytes
    | _ -> invalid_arg "expected `String (for bytes)"

  let of_bytes : bytes -> t =
   fun x ->
    `String (Internal.compress x |> Bytes.unsafe_to_string |> Base64.encode_exn)

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
