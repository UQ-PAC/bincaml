open Containers

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
