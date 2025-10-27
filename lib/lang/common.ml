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
  val hash : t -> int
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

(* module type X = sig *)
(*   include Graph.Sig.G *)
(**)
(*   val vertex_name : V.t -> string *)
(* end *)
(**)
(* let f (type t v e) (make_name : v -> string) *)
(*     (module G : Graph.Sig.G with type t = t and type V.t = v and type E.t = e) : *)
(*     (module X with type t = t and type V.t = v and type E.t = e) = *)
(*   let module M = struct *)
(*     include G *)
(**)
(*     let vertex_name = make_name *)
(*   end in *)
(*   (module M) *)
