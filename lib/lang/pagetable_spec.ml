(** Private immplementation modules. *)
open struct
  module IntegerMap = Map.Make(Z)

  module Z = struct
    include Z
    let pp fmt z = Format.pp_print_string fmt (Z.to_string z)
  end

  module Bitvec = Common.Bitvec

end


module type _Sut = sig
  type sut
  val init_sut : unit -> sut
  val cleanup : sut -> unit

  (* we can't type the `run` function because it depends on `cmd` *)
end

module Pagetable_reference = struct

  type cmd =
    | Read of { addr: Z.t; nbytes: int }
    | Write of { addr: Z.t; bv: Bitvec.t }
  [@@deriving show { with_path = false }]

  type state = char IntegerMap.t
  let init_state = IntegerMap.empty

  let next_state cmd state =
    match cmd with
    | Read { addr; nbytes } -> state
    | Write { addr; bv } ->
      let bytes = Bitvec.to_bytes bv in
      snd @@ Bytes.fold_left (fun (addr, state) c -> Z.(addr + ~$8), IntegerMap.add addr c state)
      (addr, state) bytes
end
