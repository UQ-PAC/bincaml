(** Private immplementation modules. *)
open struct
  module IntegerMap = Map.Make (Z)

  module Z = struct
    include Z

    let pp fmt z = Format.pp_print_string fmt (Z.to_string z)
  end

  module Bitvec = Bincaml_util.Bitvec
  module Shrink = QCheck.Shrink
  module Gen = QCheck.Gen
end

(** Abstract reference model for the page table, along with associated
    operations. *)
module Model = struct
  type cmd =
    | Read of { addr : Z.t; nbytes : int }
    | Write of { addr : Z.t; bv : Bitvec.t }
  [@@deriving show { with_path = false }]

  type state = char IntegerMap.t
  (** The abstract model of the page table is a map of integer addresses to
      bytes. *)

  let init_state = IntegerMap.empty

  (** Precondition of page table commands. Addresses are non-negative and
      reads/writes are byte-sized and non-zero sized. *)
  let precond cmd _ =
    match cmd with
    | Read { addr; nbytes } -> Z.(geq addr zero) && nbytes > 0
    | Write { addr; bv } -> Z.(geq addr zero) && bv.w mod 8 == 0 && bv.w > 0

  (** Given an abstract state and a command, computes the abstract state after
      the command. *)
  let next_state cmd st =
    match cmd with
    | Read _ -> st
    | Write { addr; bv } ->
        Bitvec.to_bytes bv |> Bytes.to_seq
        |> Seq.fold_lefti (fun st i c -> IntegerMap.add Z.(addr + ~$i) c st) st

  let read_byte ~addr st =
    IntegerMap.find_opt addr st |> Option.value ~default:'\x00'

  (** Generates a non-negative {!Z.t} (currently up to int64 size). *)
  let arb_zint_nonneg =
    let open QCheck.Gen in
    let+ n = int64 in
    Z.of_int64_unsigned n

  let gen_addr st =
    let open QCheck.Gen in
    let* addr =
      match IntegerMap.bindings st |> List.map fst with
      | [] -> arb_zint_nonneg
      | addrs -> oneof [ oneof_list addrs; arb_zint_nonneg ]
    in
    let+ fuzz = int_range (-10) 10 in
    Z.(max zero @@ (addr + ~$fuzz))

  let is_digit = function '0' .. '9' -> true | _ -> false

  let shrink_zint : Z.t Shrink.t =
   fun x ->
    Z.to_int64_unsigned x |> Shrink.int64
    |> Iter.map Z.of_int64_unsigned
    |> Iter.filter (Z.gt x)

  let shrink_bitvec : Bitvec.t Shrink.t =
   fun bv ->
    Shrink.int bv.w
    |> Iter.map (fun size -> size / 8 * 8)
    |> Iter.filter (fun x -> x < bv.w)
    |> Iter.map (fun size -> Bitvec.create ~size bv.v)

  let shrink_cmd : cmd Shrink.t = function
    | Read { addr; nbytes } ->
        Iter.map (fun nbytes -> Read { addr; nbytes }) (Shrink.int nbytes)
    | Write { addr; bv } ->
        Iter.map (fun bv -> Write { addr; bv }) (shrink_bitvec bv)

  let arb_cmd st =
    let open QCheck.Gen in
    QCheck.make ~print:show_cmd ~shrink:shrink_cmd
    @@
    let* nbytes = nat_small >|= Int.add 1 in
    let* addr = gen_addr st in
    oneof
      [
        return (Read { addr; nbytes });
        (let+ v = arb_zint_nonneg in
         Write { addr; bv = Bitvec.create ~size:(nbytes * 8) v });
      ]
end

(** Concrete system under test for the page table. *)
module Spec : STM.Spec = struct
  include Model

  open struct
    module PageTable = Lang.Interp.PageTable
  end

  type sut = PageTable.t

  (** Initialises a page table of all zeros. All zeros ensures it initially
      matches with the abstract model. *)
  let init_sut () = PageTable.create ~page_len:9 ?use_random_init:None ()

  let cleanup _ = ()

  type 'a STM.ty += BitvecTy : Bitvec.t STM.ty

  let bitvec_show = (BitvecTy, Bitvec.to_string)

  (** Performs a command on the concrete system under test and returns the
      result of the command. *)
  let run cmd sut =
    match cmd with
    | Read { addr; nbytes } ->
        let nbits = nbytes * 8 in
        STM.Res (bitvec_show, PageTable.read_bv ~addr ~nbits sut)
    | Write { addr; bv } -> STM.Res (STM.unit, PageTable.write_bv sut ~addr bv)

  (** Postcondition for validating the returned value from {!run} aligns with
      that expected by the abstract operation.

      Note: does not validate the whole abstract state (and doesn't need to,
      because a later read could expose errors). *)
  let postcond cmd oldst res =
    match (cmd, res) with
    | Read { addr; nbytes }, STM.Res ((BitvecTy, _), bv) ->
        bv.w = nbytes * 8
        && Bitvec.to_bytes bv |> Bytes.to_seq
           |> Seq.fold_lefti
                (fun ok i c -> ok && read_byte ~addr:Z.(addr + ~$i) oldst = c)
                true
    | Write _, STM.Res ((STM.Unit, _), ()) -> true
    | _ -> false
end
