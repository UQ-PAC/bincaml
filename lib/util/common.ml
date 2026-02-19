(** {1 Standard library} *)

include Containers
include Fun

(** Common collections *)

module StringMap = Map.Make (String)
module IntMap = Map.Make (Int)
module StringSet = Set.Make (String)
module IntSet = Set.Make (Int)

(* Byte_slice extension for blitting to Bytes *)

module Byte_slice = struct
  include Byte_slice

  let blit_to src dest dest_pos =
    Bytes.blit src.bs src.off dest dest_pos src.len
end

include Mtypes
(** Types *)

(** {1 vars and ids} *)

module Types = Types
module Var = Var
module ID = ID
module IDMap = Map.Make (ID)
module VarMap = Map.Make (Var)
module IDSet = Set.Make (ID)
module VarSet = Set.Make (Var)

(** Values *)

module Bitvec = Bitvec
module PrimInt = Zint

let disable_backtrace_in f =
  let old = Printexc.backtrace_status () in
  Printexc.record_backtrace false;
  let r = f () in
  Printexc.record_backtrace old;
  r
