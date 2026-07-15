(** Extra general-purpose library functions which are not in Containers or
    Stdlib. *)

(** {1 List functions} *)

(** Returns [Some (hd x, tl x)] if [x] is non-empty, otherwise returns [None].
*)
let uncons = function [] -> None | hd :: tl -> Some (hd, tl)

(** [span_while_some f xs] returns the longest prefix of [xs] where the elements
    yield [Some] when mapped through [f].

    These [Some] values are returned in the first tuple element. Upon reaching a
    value which yields [None], that value and values after it are returned in
    the second tuple element. *)
let span_while_some f =
  let rec step f rev_somes all =
    let x, rest = match all with [] -> (None, []) | hd :: tl -> (f hd, tl) in
    match x with
    | None -> (List.rev rev_somes, all)
    | Some x -> (step [@tailcall]) f (x :: rev_somes) rest
  in
  step f []

(** Groups successive list elements based on whether they are [Left] or [Right],
    maintaining relative order.

    [Left] and [Right] values within the returned list contain values like
    [('a * 'a list)] to represent a non-empty list. *)
let group_succ_either :
    ('a, 'b) Either.t list -> ('a * 'a list, 'b * 'b list) Either.t list =
  let[@tail_mod_cons] rec while_left xs =
    let xs, rest = span_while_some Either.find_left xs in
    match xs with
    | [] -> while_right rest (* in case the input list starts with Right *)
    | h :: xs -> Either.Left (h, xs) :: while_right rest
  and[@tail_mod_cons] while_right xs =
    let xs, rest = span_while_some Either.find_right xs in
    match xs with
    | [] -> []
    | h :: xs -> Either.Right (h, xs) :: while_left rest
  in
  while_left
