open Containers
open Fun

module type IFace = sig
  type t
  type elt

  val create : unit -> t
  val cardinal : t -> int
  val non_empty : t -> bool
  val add : t -> elt -> unit
  val add_list : t -> elt list -> unit
  val add_iter : t -> elt Iter.t -> unit
  val pop : t -> elt
end

module MakeMutHeap (D : CCMutHeap.RANKED) = struct
  module M = CCMutHeap.Make (D)

  let create = M.create
  let cardinal = M.size
  let non_empty = M.is_empty %> not
  let add = M.insert
  let add_list q ls = List.iter (function d -> M.insert q d) ls
  let add_iter q is = Iter.iter (function d -> M.insert q d) is

  let pop q =
    let r = M.remove_min q in
    r
end

module Make (D : Heap.TOTAL_ORD) = struct
  module PQ = Heap.Make_from_compare (D)

  type t = PQ.t ref
  type elt = D.t

  let create () : t = ref PQ.empty
  let cardinal (q : t) = PQ.size !q
  let non_empty (q : t) = not @@ PQ.is_empty !q
  let add (q : t) d = q := PQ.add !q d
  let add_list q (ls : D.t list) = q := PQ.add_list !q ls
  let add_iter q (is : D.t Iter.t) = q := PQ.add_iter !q is

  let pop (q : t) =
    let q', d = PQ.take_exn !q in
    q := q';
    while non_empty q && D.compare (PQ.find_min_exn !q) d = 0 do
      q := fst @@ PQ.take_exn !q
    done;
    d
end

module OfIntPqueue (D : sig
  type t

  val to_int : t -> int
end) =
struct
  module PQ = IntPQueue.Plain

  type elt = D.t
  type t = elt PQ.t

  let create = PQ.create
  let cardinal = PQ.cardinal
  let non_empty pq = not @@ PQ.is_empty pq
  let add q d = PQ.add q d (D.to_int d)
  let add_list q ls = List.iter (function d -> PQ.add q d (D.to_int d)) ls
  let add_iter q is = Iter.iter (function d -> PQ.add q d (D.to_int d)) is
  let pop q = PQ.extract q |> Option.get_exn_or "empty queue"
end
