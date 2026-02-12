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
let bind1 f a = create ~size:a.w (f a.v) [@@inline always]
let bind1_signed f a = create ~size:a.w (f a.v) [@@inline always]

(* wrap bv operation *)
let bind2 f a b =
  size_is_equal a b;
  create ~size:a.w (f a.v b.v)
[@@inline always]

(* wrap signed bv operation *)
let bind2_signed f a b =
  size_is_equal a b;
  create ~size:a.w (f (to_signed_bigint a) (to_signed_bigint b))
[@@inline always]

let map2 f a b =
  size_is_equal a b;
  f a.v b.v
[@@inline always]

let neg a = bind1_signed Z.neg a
let add a b = bind2 Z.add a b
let mul a b = bind2 Z.mul a b
let sub a b = bind2 Z.sub a b
let bitnot a = bind1 Z.lognot a
let bitand a b = bind2 Z.logand a b
let bitor a b = bind2 Z.logor a b
let bitxor a b = bind2 Z.logxor a b
let udiv a b = if is_zero b then ones ~size:a.w else bind2 Z.div a b
let urem a b = if is_zero b then a else bind2 Z.rem a b

(** Signed division.

    From Z3: https://z3prover.github.io/api/html/group__capi.html

    It is defined in the following way:
    - The floor of t1/t2 if t2 is different from zero, and t1*t2 >= 0.
    - The ceiling of t1/t2 if t2 is different from zero, and t1*t2 < 0. If t2 is
      zero, then the result is undefined. *)
let sdiv a b =
  if a.w = 0 then a
  else begin
    assert (is_nonzero b);
    bind2_signed Z.div a b
  end

(** Remainder with result sign following the dividend (a) sign. *)
let srem a b =
  if a.w = 0 then a
  else begin
    assert (is_nonzero b);
    bind2_signed Z.rem a b
  end

(** Remainder with result sign following the divisor (b) sign. *)
let smod a b =
  size_is_equal a b;
  if a.w = 0 then a
  else begin
    assert (is_nonzero b);
    let w = a.w and a, b = (to_signed_bigint a, to_signed_bigint b) in
    let remainder = Z.rem a b and wanted_sign = Z.sign b in
    match (Z.sign remainder, wanted_sign) with
    | 1, -1 -> create ~size:w Z.(remainder - abs b)
    | -1, 1 -> create ~size:w Z.(remainder + abs b)
    | _ -> create ~size:w remainder
  end

let ult a b = map2 Z.lt a b
let ugt a b = map2 Z.gt a b
let ule a b = map2 Z.leq a b
let uge a b = map2 Z.geq a b

let map2_signed f a b =
  size_is_equal a b;
  f (to_signed_bigint a) (to_signed_bigint b)

let slt a b = map2_signed Z.lt a b
let sgt a b = map2_signed Z.gt a b
let sle a b = map2_signed Z.leq a b
let sge a b = map2_signed Z.geq a b

let ashr a b =
  (* guard avoids overflows in second int argument of shift: should always fit in int*)
  if Z.gt b.v (Z.of_int a.w) then
    if Z.testbit a.v (a.w - 1) then ones ~size:a.w else zero ~size:a.w
  else create ~size:a.w @@ Z.shift_right (to_signed_bigint a) (Z.to_int b.v)

let lshr a b =
  (* guard avoids overflows in second int argument of shift: should always fit in int*)
  if Z.gt b.v (Z.of_int a.w) then zero ~size:a.w
  else
    create ~size:a.w
    @@ Z.shift_right_trunc (to_unsigned_bigint a) (Z.to_int b.v)

let zero_extend ~(extension : int) b = create ~size:(b.w + extension) b.v

let sign_extend ~(extension : int) b =
  create ~size:(b.w + extension) @@ to_signed_bigint b

let shl a b =
  (* shift left by a very large number will OOM. guard against that. *)
  if Z.(geq b.v (of_int a.w)) then create ~size:a.w Z.zero
  else create ~size:a.w @@ Z.shift_left (to_unsigned_bigint a) (Z.to_int b.v)

let concat a b =
  let wd = a.w + b.w in
  let a = zero_extend ~extension:(wd - a.w) a in
  let a = shl a (of_int ~size:a.w b.w) in
  let b = zero_extend ~extension:(wd - b.w) b in
  bitor a b

let repeat_bits ~(copies : int) a =
  List.init copies (fun _ -> a) |> List.fold_left concat empty
