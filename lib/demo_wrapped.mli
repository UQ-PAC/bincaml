type 'a t
(*@ model size : int
    mutable model contents : 'a list *)

val to_size : 'a t -> int [@@projection_for size]
(*@ pure *)

val to_list : 'a t -> 'a list [@@projection_for contents]
(*@ pure *)

val make : int -> 'a -> 'a t
(*@ t = make i a
    checks i >= 0
    ensures t.size = i
    ensures t.contents = List.init i (fun _ -> a) *)

val get : 'a t -> int -> 'a
(*@ a = get t i
    checks 0 <= i < to_size t
    ensures a = List.nth t.contents i *)

val set : 'a t -> int -> 'a -> unit
(*@ set t i a
    requires 0 <= i < to_size t
    modifies t.contents
    ensures t.contents = List.mapi (fun j x -> if j = (i : integer) then a else x) (old t.contents) *)
