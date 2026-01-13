module type PRINTABLE = sig
  type t

  val show : t -> string
end

module type TYPE = sig
  include PRINTABLE

  val equal : t -> t -> bool
end

module type PRETTY = sig
  include PRINTABLE

  val pretty : t -> Containers_pp.t
end

module type ORD_TYPE = sig
  include TYPE

  val compare : t -> t -> int
end

module type HASH_TYPE = sig
  include ORD_TYPE

  val hash : t -> int
end
