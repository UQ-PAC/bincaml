open Containers

(** Fixed-width bitvector operations on strictly positive arbitrary width Z.t
    integers *)

(* workaround: ZArith library doesn't like zero-length extracts *)
let checked_extract f v off len = if len > 0 then f v off len else Z.zero
let z_extract = checked_extract Z.extract
let z_signed_extract = checked_extract Z.signed_extract

(** Representation of bitvector with non-negative Z.t and an explicit size. *)

let show b = Printf.sprintf "0x%s" (Z.format "%x" @@ b)
let to_string v = show v
let pp fmt b = Format.pp_print_string fmt (show b)
let hash b = Z.hash b
let ones ~(size : int) = z_extract Z.minus_one 0 size
let zero = Z.zero
let empty = zero
let is_zero b = Z.equal Z.zero b
let is_nonzero b = not (is_zero b)
let to_signed_bigint ~size b = z_signed_extract b 0 size
let to_unsigned_bigint ~size b = z_extract b 0 size
let is_negative ~size b = Z.lt (to_signed_bigint ~size b) Z.zero
let equal a b = Z.equal a b
let true_bv = ones ~size:1
let false_bv = zero
let max_value_unsigned size = ones ~size

(** [to_bytes v] converts a byte-aligned-width bitvector value to bytes with the
    length matching [length v]*)
let to_bytes ~size v =
  assert (size mod 8 = 0);
  assert (size / 8 > 0);
  let bs = Bytes.init (size / 8) (fun _ -> Char.unsafe_chr 0) in
  let bits = Z.to_bits v in
  let len = min (String.length bits) (size / 8) in
  if len > 0 then Bytes.blit_string bits 0 bs 0 len;
  bs

(** Extracts a slice of the given bitvector. The slice is extracted from [lo]
    (inclusive) up to [hi] (exclusive). *)
let extract ~hi ~lo (b : Z.t) =
  assert (0 <= lo);
  assert (lo <= hi);
  z_extract b lo (hi - lo)

let compare a b = Z.compare a b

(** Smart constructor for {!t}. Extracts its bits from the two's complement
    representation of the given {!Z.t}, with negative numbers being treated as
    having an infinite number of [1]s to their left. *)
let create ~(size : int) (v : Z.t) : Z.t =
  assert (size >= 0);
  z_extract v 0 size

let of_int ~(size : int) i = create ~size (Z.of_int i)
let of_bool i = create ~size:1 (if i then Z.one else Z.zero)
let one ~(size : int) = create ~size Z.one
let bind1 ~size f a = create ~size (f a) [@@inline always]
let bind1_signed ~size f a = create ~size (f a) [@@inline always]

(* wrap bv operation *)
let bind2 ~size f a b = create ~size (f a b) [@@inline always]

(* wrap signed bv operation *)
let bind2_signed ~size f (a : Z.t) (b : Z.t) =
  create ~size (f (to_signed_bigint ~size a) (to_signed_bigint ~size b))
[@@inline always]

let map2 f a b = f a b [@@inline always]
let neg ~size a = bind1_signed ~size Z.neg a
let add ~size a b = bind2 ~size Z.add a b
let mul ~size a b = bind2 ~size Z.mul a b
let sub ~size a b = bind2 ~size Z.sub a b
let bitnot ~size a = bind1 ~size Z.lognot a
let bitand ~size a b = bind2 ~size Z.logand a b
let bitor ~size a b = bind2 ~size Z.logor a b
let bitxor ~size a b = bind2 ~size Z.logxor a b
let udiv ~size a b = if is_zero b then ones ~size else bind2 ~size Z.div a b
let urem ~size a b = if is_zero b then a else bind2 ~size Z.rem a b

(** Signed division.

    From Z3: https://z3prover.github.io/api/html/group__capi.html

    It is defined in the following way:
    - The floor of t1/t2 if t2 is different from zero, and t1*t2 >= 0.
    - The ceiling of t1/t2 if t2 is different from zero, and t1*t2 < 0. If t2 is
      zero, then the result is undefined. *)
let sdiv ~size (a : Z.t) b =
  if size = 0 then a
  else begin
    assert (is_nonzero b);
    bind2_signed ~size Z.div a b
  end

(** Remainder with result sign following the dividend (a) sign. *)
let srem ~size a b =
  if size = 0 then a
  else begin
    assert (is_nonzero b);
    bind2_signed ~size Z.rem a b
  end

(** Remainder with result sign following the divisor (b) sign. *)
let smod ~size a b =
  if size = 0 then a
  else begin
    assert (is_nonzero b);
    let w = size
    and a, b = (to_signed_bigint ~size a, to_signed_bigint ~size b) in
    let remainder = Z.rem a b and wanted_sign = Z.sign b in
    match (Z.sign remainder, wanted_sign) with
    | 1, -1 -> create ~size:w Z.(remainder - abs b)
    | -1, 1 -> create ~size:w Z.(remainder + abs b)
    | _ -> create ~size:w remainder
  end

let ult ~size a b = map2 Z.lt a b
let ugt ~size a b = map2 Z.gt a b
let ule ~size a b = map2 Z.leq a b
let uge ~size a b = map2 Z.geq a b
let truthy a = not @@ Z.equal Z.zero a

let map2_signed ~size f a b =
  f (to_signed_bigint ~size a) (to_signed_bigint ~size b)

let slt ~size a b = map2_signed ~size Z.lt a b
let sgt ~size a b = map2_signed ~size Z.gt a b
let sle ~size a b = map2_signed ~size Z.leq a b
let sge ~size a b = map2_signed ~size Z.geq a b

let ashr ~size a b =
  (* guard avoids overflows in second int argument of shift: should always fit in int*)
  if Z.gt b (Z.of_int size) then
    if Z.testbit a (size - 1) then ones ~size else zero
  else create ~size @@ Z.shift_right (to_signed_bigint ~size a) (Z.to_int b)

let lshr ~size a b =
  (* guard avoids overflows in second int argument of shift: should always fit in int*)
  if Z.gt b (Z.of_int size) then zero
  else
    create ~size
    @@ Z.shift_right_trunc (to_unsigned_bigint ~size a) (Z.to_int b)

let sign_extend ~(extension : int) ~size b =
  create ~size:(size + extension) @@ to_signed_bigint ~size b

let shl ~(size : int) a b =
  (* shift left by a very large number will OOM. guard against that. *)
  if Z.geq b (Z.of_int size) then zero
  else create ~size @@ Z.shift_left (to_unsigned_bigint ~size a) (Z.to_int b)

let concat ~size_a ~size_b a b =
  let wd = size_a + size_b in
  let a = shl ~size:wd a (of_int ~size:size_a size_b) in
  bitor ~size:wd a b

let repeat_bits ~size ~(copies : int) a =
  List.init copies (fun _ -> a)
  |> List.fold_left (concat ~size_a:size ~size_b:size) empty
