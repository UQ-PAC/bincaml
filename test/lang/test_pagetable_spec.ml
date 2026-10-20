(** Private immplementation modules. *)
open struct
  module RefModel = Bincaml_util.Page_table.Naive

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
    | Read of { addr : Z.t; nbits : int }
    | Write of { addr : Z.t; bv : Bitvec.t }
  [@@deriving show { with_path = false }]

  let show_cmd = function
    | Read { addr; nbits } ->
        Printf.sprintf "read %x %d bits" (Z.to_int addr) nbits
    | Write { addr; bv } ->
        Printf.sprintf "write %x %s" (Z.to_int addr) (Bitvec.show bv)

  type state = RefModel.t
  (** The abstract model of the page table is a map of integer addresses to
      bytes. *)

  let init_state = RefModel.empty ()

  (** Precondition of page table commands. Addresses are non-negative and
      reads/writes are byte-sized and non-zero sized. *)
  let precond cmd _ =
    match cmd with
    | Read { addr; nbits } -> Z.(geq addr zero) && nbits > 0
    | Write { addr; bv } -> Z.(geq addr zero) && bv.w mod 8 == 0 && bv.w > 0

  (** Given an abstract state and a command, computes the abstract state after
      the command. *)
  let next_state cmd st =
    match cmd with
    | Read _ -> st
    | Write { addr; bv } -> RefModel.write_bv st ~addr bv

  (** Generates a non-negative {!Z.t} (currently up to int64 size). *)
  let arb_zint_nonneg =
    let open QCheck.Gen in
    let+ n = int_range 1 ((5 * 1024) + 400) in
    Z.of_int n

  let gen_addr st =
    let open QCheck.Gen in
    let* addr = arb_zint_nonneg in
    return @@ Z.(max zero addr)

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
    | Read { addr; nbits } ->
        Iter.map (fun nbits -> Read { addr; nbits }) (Shrink.int nbits)
    | Write { addr; bv } ->
        Iter.map (fun bv -> Write { addr; bv }) (shrink_bitvec bv)

  let arb_cmd st =
    let open QCheck.Gen in
    QCheck.make ~print:show_cmd ~shrink:shrink_cmd
    @@
    let* nbits = nat_small >|= Int.add 1 in
    let* addr = gen_addr st in
    oneof
      [
        return (Read { addr; nbits });
        (let+ v = arb_zint_nonneg in
         Write { addr; bv = Bitvec.create ~size:nbits v });
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
  type 'a STM.ty += PageTableTy : PageTable.t STM.ty

  let bitvec_show = (BitvecTy, Bitvec.to_string)
  let pt_ty = (PageTableTy, fun x -> "\n" ^ PageTable.show x)

  (** Performs a command on the concrete system under test and returns the
      result of the command. *)
  let run cmd sut =
    match cmd with
    | Read { addr; nbits } ->
        STM.Res (bitvec_show, PageTable.read_bv ~addr ~nbits sut)
    | Write { addr; bv } -> STM.Res (pt_ty, PageTable.write_bv sut ~addr bv)

  (** Postcondition for validating the returned value from {!run} aligns with
      that expected by the abstract operation.

      Note: does not validate the whole abstract state (and doesn't need to,
      because a later read could expose errors). *)
  let postcond cmd oldst res =
    match (cmd, res) with
    | Read { addr; nbits }, STM.Res ((BitvecTy, _), bv) ->
        bv.w = nbits
        && (Bitvec.equal bv @@ RefModel.read_bv oldst ~addr ~nbits:bv.w)
    | Write { addr; bv }, STM.Res ((PageTableTy, _), rst) ->
        let rp = PageTable.read_bv rst ~addr ~nbits:bv.w in
        Bitvec.equal bv rp
    | _ -> true
end
