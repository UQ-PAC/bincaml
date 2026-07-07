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
