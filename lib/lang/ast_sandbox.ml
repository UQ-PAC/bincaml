module IntOps = struct
  type 'a t = [
    | `IntAdd of 'a * 'a
    | `IntLit of int
  ]
  [@@deriving eq, show]

  type 'a intops = 'a t

  let map_intops map f : [> 'a intops] -> [> 'b intops] = function
    | `IntAdd (x, y) -> `IntAdd (f x, f y)
    | `IntLit x -> `IntLit x
    | rest -> map f rest

  let rec map_only_intops f : 'a intops -> 'b intops = map_intops map_only_intops f

  let () = print_endline @@ show Format.pp_print_string @@ map_only_intops Int.to_string (`IntAdd (1, 2))

  let depth_intops depth : [> 'a intops] -> int = function
    | `IntAdd (x, y) -> 1 + max (depth x) (depth y)
    | `IntLit x -> 1
    | rest -> depth rest
end

module BvOps = struct
  type 'a t = [
    | `BvAdd of 'a * 'a
    | `BvLit of int * int
  ]
  [@@deriving eq, show]

  type 'a bvops = 'a t

  let map_bvops map f : [> 'a bvops] -> [> 'b bvops] = function
    | `BvAdd (x, y) -> `BvAdd (f x, f y)
    | `BvLit x -> `BvLit x
    | rest -> map f rest

  let rec map_only_bvops f : 'a bvops -> 'b bvops = map_bvops map_only_bvops f

  let depth_bvops depth : [> 'a bvops] -> int = function
    | `BvAdd (x, y) -> 1 + max (depth x) (depth y)
    | `BvLit x -> 1
    | rest -> depth rest
end


module IntrinOps = struct
  type ('a, 'b) t = [
    | `Intrin of 'b * 'a list
  ]
  [@@deriving eq, show]

  let map_intrins map f = function
    | `Intrin (op, xs) -> `Intrin (op, List.map f xs)
end

module AllOps = struct
  type 'a t = [
    | 'a IntOps.t
    | 'a BvOps.t
    | ('a, string) IntrinOps.t
  ]
  [@@deriving eq, show]

  type 'a allops = 'a t

  (* we probably can't generate these by module functor
     because they depend on structure of the polyvariant.
     this is probably fine. *)
  let rec map_allops f : 'a allops -> 'b allops = function
    | #IntOps.t as x -> IntOps.map_intops map_allops f x
    | #BvOps.t as x -> BvOps.map_bvops map_allops f x
    | #IntrinOps.t as x -> IntrinOps.map_intrins map_allops f x

  let rec depth_allops : 'a allops -> int = function
    | #IntOps.t as x -> IntOps.depth_intops depth_allops x
    | #BvOps.t as x -> BvOps.depth_bvops depth_allops x
end

let alg_all = function
  | #IntOps.t as x -> true
  | #BvOps.t as x -> true
  | #IntrinOps.t as x -> true
let alg_small : bool IntOps.t -> bool = alg_all

(* the module parameter is designed to be compatible
  with that produced by [@@ deriving eq, show]. *)
module Close (M : sig
  type 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  (* val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit *)
  (* val show : (Format.formatter -> 'a -> unit) -> 'a t -> string *)
  (* val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool *)
end) = struct

  type t = Fix of t M.t [@@unboxed]
  (* [@@deriving eq, show] *)

  let fix x = Fix x
  let unfix (Fix x) = x

  let ( >> ) = fun f g x -> g (f x)

  let rec cata : 'a. ('a M.t -> 'a) -> t -> 'a =
   fun alg x -> x |> unfix |> M.map (cata alg) |> alg

end

