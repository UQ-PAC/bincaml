(** Private immplementation modules. *)
open struct
  module IntegerMap = Map.Make (Z)

  module Z = struct
    include Z

    let pp fmt z = Format.pp_print_string fmt (Z.to_string z)
  end

  module Bitvec = Util.Bitvec
end

module Model = struct
  type cmd =
    | Read of { addr : Z.t; nbytes : int }
    | Write of { addr : Z.t; bv : Bitvec.t }
  [@@deriving show { with_path = false }]

  type state = char IntegerMap.t
  (** The abstract model of the page table is a map of integer addresses to
      bytes. *)

  let init_state = IntegerMap.empty

  let next_state cmd st =
    match cmd with
    | Read _ -> st
    | Write { addr; bv } ->
        Bitvec.to_bytes bv |> Bytes.to_seq
        |> Seq.fold_lefti (fun st i c -> IntegerMap.add Z.(addr + ~$i) c st) st

  let read_byte ~addr st =
    IntegerMap.find_opt addr st |> Option.value ~default:'\x00'

  (** Generates a non-negative {!Z.t} (currently up to int64 size). *)
  let arb_posint =
    let open QCheck.Gen in
    let+ n = int64 in
    Z.of_int64_unsigned n

  let gen_addr st =
    let open QCheck.Gen in
    let* addr =
      match IntegerMap.bindings st |> List.map fst with
      | [] -> arb_posint
      | addrs -> oneof [ oneofl addrs; arb_posint ]
    in
    let+ fuzz = QCheck.Gen.int_range (-10) 10 in
    Z.(max zero @@ (addr + ~$fuzz))

  let arb_cmd st =
    let open QCheck.Gen in
    QCheck.make ~print:show_cmd
    @@
    let* nbytes = small_nat in
    let* addr = gen_addr st in
    oneof
      [
        return (Read { addr; nbytes });
        (let+ v = arb_posint in
         Write { addr; bv = Bitvec.create ~size:(nbytes * 8) v });
      ]
end

module Spec : STM.Spec = struct
  include Model

  open struct
    module PageTable = Lang.Interp.PageTable
  end

  type sut = PageTable.t

  let init_sut () = PageTable.create ~page_len:9 ?use_random_init:None ()
  let cleanup _ = ()

  let precond cmd _ =
    match cmd with
    | Read { addr; _ } -> Z.(geq addr zero)
    | Write { addr; bv } -> Z.(geq addr zero) && bv.w mod 8 == 0

  type 'a STM.ty += BitvecTy : Bitvec.t STM.ty

  let bitvec_show = (BitvecTy, Bitvec.to_string)

  let run cmd sut =
    match cmd with
    | Read { addr; nbytes } ->
        STM.Res (bitvec_show, PageTable.read_bv ~addr ~nbits:(nbytes * 8) sut)
    | Write { addr; bv } -> STM.Res (STM.unit, PageTable.write_bv sut ~addr bv)

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

