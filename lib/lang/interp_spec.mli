(** Contains a subset of the {!Interp} module which is specified
    and able to be tested. *)

module PageTable : sig
  type t
  (*@ mutable model bytes : integer -> char *)

  val create : ?page_len:int -> ?use_random_init:Random.State.t -> unit -> t
  (*@ mem = create ?page_len ?use_random_init ()
  *)

  val write_bv : t -> addr:Z.t -> Util.Common.Bitvec.t -> unit
  (*@ write_bv mem ~addr bv
     modifies mem.bytes
  *)

  val read_bv : t -> addr:Z.t -> nbits:int -> Util.Common.Bitvec.t
  (*@ bv = read_bv mem ~addr ~nbits
      ensures 1 = 2
      ensures 1 = 2
  *)
end
