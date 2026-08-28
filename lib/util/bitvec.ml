open Containers

(* workaround: ZArith library doesn't like zero-length extracts *)
let checked_extract f v off len = if len > 0 then f v off len else Z.zero
let z_extract = checked_extract Z.extract
let z_signed_extract = checked_extract Z.signed_extract

type t = { w : int; v : Z.t }
(** Representation of bitvector with non-negative Z.t and an explicit size. *)

let show (b : t) = Printf.sprintf "0x%s:bv%d" (Z.format "%x" @@ b.v) b.w
let to_string v = show v
let pp fmt b = Format.pp_print_string fmt (show b)
let hash b = Hash.pair Int.hash Z.hash (b.w, b.v)
let ones ~(size : int) = { w = size; v = z_extract Z.minus_one 0 size }
let zero ~(size : int) = { w = size; v = Z.zero }
let empty = zero ~size:0
let is_zero b = Z.equal Z.zero b.v
let is_nonzero b = not (is_zero b)
let size (x : t) = match x with { w; _ } -> w
let value (b : t) : Z.t = match b with { v; _ } -> v
let to_signed_bigint b = z_signed_extract b.v 0 b.w
let to_unsigned_bigint b = z_extract b.v 0 b.w
let is_negative b = Z.lt (to_signed_bigint b) Z.zero
let equal a b = Int.equal a.w b.w && Z.equal a.v b.v
let true_bv = ones ~size:1
let false_bv = zero ~size:1
let max_value_unsigned size = ones ~size

(** [to_bytes v] converts a byte-aligned-width bitvector value to bytes with the
    length matching [length v]*)
let to_bytes v =
  assert (v.w mod 8 = 0);
  assert (v.w / 8 > 0);
  let bs = Bytes.init (v.w / 8) (fun _ -> Char.unsafe_chr 0) in
  let bits = Z.to_bits v.v in
  let len = min (String.length bits) (v.w / 8) in
  if len > 0 then Bytes.blit_string bits 0 bs 0 len;
  bs

(** Extracts a slice of the given bitvector. The slice is extracted from [lo]
    (inclusive) up to [hi] (exclusive). *)
let extract ~hi ~lo (b : t) =
  assert (0 <= lo);
  assert (lo <= hi);
  assert (hi <= b.w);
  { w = hi - lo; v = z_extract b.v lo (hi - lo) }

let compare a b =
  Int.compare a.w b.w |> function 0 -> Z.compare a.v b.v | o -> o

(** Smart constructor for {!t}. Extracts its bits from the two's complement
    representation of the given {!Z.t}, with negative numbers being treated as
    having an infinite number of [1]s to their left. *)
let create ~(size : int) (v : Z.t) : t =
  assert (size >= 0);
  { w = size; v = z_extract v 0 size }

let of_int ~(size : int) i = create ~size (Z.of_int i)
let one ~(size : int) = create ~size Z.one

let of_string i =
  let vty = String.split_on_char ':' i in
  let w, v =
    match vty with
    | [ v; ty ] -> (
        String.to_seq ty |> List.of_seq |> function
        | 'b' :: 'v' :: size ->
            let size =
              Z.of_string
                (String.concat "" (List.map (fun i -> String.make 1 i) size))
              |> Z.to_int
            in
            (size, Z.of_string v)
        | _ -> failwith "invalid format")
    | _ -> failwith "invalid format"
  in
  { w; v }

let size_is_equal a b = assert (size a = size b) [@@inline always]

let size_if_equal a b =
  if a.w = b.w then size a
  else failwith (Printf.sprintf "bv binop widths differ. a:%d, b:%d" a.w b.w)
[@@inline always]

let bind1 f a = create ~size:a.w (f ~size:a.w a.v) [@@inline always]
(*let bind1_signed f a = create ~size:a.w (f ~size:a.w a.v) [@@inline always]*)

(* wrap bv operation *)
let bind2 f a b =
  let size = size_if_equal a b in
  create ~size:a.w (f ~size a.v b.v)
[@@inline always]

let map2 f a b =
  let size = size_if_equal a b in
  f ~size a.v b.v
[@@inline always]

(** sign negation *)
let neg a = bind1 Fixed_width_arith.neg a

(** addition *)
let add a b = bind2 Fixed_width_arith.add a b

(** multiplication *)
let mul a b = bind2 Fixed_width_arith.mul a b

(** subtraction *)
let sub a b = bind2 Fixed_width_arith.sub a b

(** bitwise not *)
let bitnot a = bind1 Fixed_width_arith.bitnot a

(** bitwise and *)
let bitand a b = bind2 Fixed_width_arith.bitand a b

(** bitwise or *)
let bitor a b = bind2 Fixed_width_arith.bitor a b

(** bitwise exclusive or *)
let bitxor a b = bind2 Fixed_width_arith.bitxor a b

(** unsigned division *)
let udiv a b = bind2 Fixed_width_arith.udiv a b

(** unsigned remainder *)
let urem a b = bind2 Fixed_width_arith.urem a b

(** signed division *)
let sdiv a b = bind2 Fixed_width_arith.sdiv a b

(** Remainder with result sign following the dividend (a) sign. *)
let srem a b = bind2 Fixed_width_arith.srem a b

(** Remainder with result sign following the divisor (b) sign. *)
let smod a b = bind2 Fixed_width_arith.smod a b

(** unsigned less-than*)
let ult a b = map2 Fixed_width_arith.ult a b

(** unsigned greater-than*)
let ugt a b = map2 Fixed_width_arith.ugt a b

(** unsigned less-than-equals*)
let ule a b = map2 Fixed_width_arith.ule a b

(** unsigned greater-than-equals*)
let uge a b = map2 Fixed_width_arith.uge a b

(** signed less-than *)
let slt a b = map2 Fixed_width_arith.slt a b

(** signed greater-than *)
let sgt a b = map2 Fixed_width_arith.sgt a b

(** signed less-than-equals *)
let sle a b = map2 Fixed_width_arith.sle a b

(** signed greater-than-equals *)
let sge a b = map2 Fixed_width_arith.sge a b

(** arithmetic shift right *)
let ashr a b = bind2 Fixed_width_arith.ashr a b

(** logical shift right *)
let lshr a b = bind2 Fixed_width_arith.lshr a b

(** shift left *)
let shl a b = bind2 Fixed_width_arith.shl a b

(** extend [extension] zeros in msb position *)
let zero_extend ~(extension : int) b = create ~size:(b.w + extension) b.v

(** bitconcat *)
let concat a b =
  let wd = a.w + b.w in
  let a = zero_extend ~extension:(wd - a.w) a in
  let a = shl a (of_int ~size:a.w b.w) in
  let b = zero_extend ~extension:(wd - b.w) b in
  bitor a b

(* bitconcat a with itself n times *)
let repeat_bits ~(copies : int) a =
  List.init copies (fun _ -> a) |> List.fold_left concat empty

(* extend sign bit by [extension] bits *)
let sign_extend ~(extension : int) b =
  create ~size:(b.w + extension) @@ to_signed_bigint b

(* -(2^(size)) *)
let min_value_signed size = shl (one ~size) (of_int ~size (size - 1))

(* 2^(size-1) - 1 *)
let max_value_signed size = sub (min_value_signed size) (one ~size)
