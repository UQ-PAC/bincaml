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

  let next_state cmd state =
    match cmd with
    | Read _ -> state
    | Write { addr; bv } ->
        Bitvec.to_bytes bv
        |> Bytes.fold_left
             (fun (addr, state) c ->
               (Z.(addr + ~$1), IntegerMap.add addr c state))
             (addr, state)
        |> snd
end

module Spec : STM.Spec = struct end
