include Containers

exception
  ReplError of {
    msg : string;
    cmd : string;
    __FILE__ : string;
    __FUNCTION__ : string;
    __LINE__ : int;
  }

module HashHelper = struct
  let combine acc n = (acc * 65599) + n
  let combine2 acc n1 n2 = combine (combine acc n1) n2
  let combine3 acc n1 n2 n3 = combine (combine (combine acc n1) n2) n3

  let rec combinel acc n1 =
    match n1 with [] -> acc | h :: tl -> combinel (combine acc h) tl
end

module type PRINTABLE = sig
  type t

  val show : t -> string
end

module type TYPE = sig
  include PRINTABLE

  val equal : t -> t -> bool
end

module type ORD_TYPE = sig
  include TYPE

  val compare : t -> t -> int
end

module type HASH_TYPE = sig
  include ORD_TYPE

  val hash : t -> int
end

let identity x = x

module StringMap = Map.Make (String)

module Byte_slice = struct
  include Byte_slice

  let blit_to src dest dest_pos =
    Bytes.blit src.bs src.off dest dest_pos src.len
end

module Iter = struct
  include Iter

  (** combine two equal-length iterators to an iterator of pairs *)
  let zip i j = i |> Iter.map (fun i -> (i, Iter.head_exn @@ Iter.take 1 j))
end
