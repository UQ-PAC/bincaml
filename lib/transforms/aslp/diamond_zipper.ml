(** Functionality for representing and moving through {i positions} of a
    {!Diamond.diamond}. *)

open CCFun
open Diamond

(** {1 Zipper for diamond} *)

type skeleton = [ `L | `R | `P ] list
[@@deriving show { with_path = false }, eq]
(** The skeleton of a zipper is a path of steps. This can be used to reference a
    position within the {!Diamond.diamond}. *)

(**/**)

module Priv : sig
  type 'a zipper = private 'a diamond * skeleton

  val wrap : 'a diamond * skeleton -> 'a zipper

  val wrap_result :
    ('a diamond * skeleton, 'a diamond * skeleton) result ->
    ('a zipper, 'a zipper) result

  val unwrap : 'a zipper -> 'a diamond * skeleton

  val pp_zipper :
    (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a zipper -> unit

  val show_zipper : (Format.formatter -> 'a -> unit) -> 'a zipper -> string
end = struct
  type 'a zipper = 'a diamond * skeleton [@@deriving show]

  let wrap x = x
  let unwrap x = x
  let wrap_result x = CCResult.map2 wrap wrap x
end

(**/**)

open Priv

type 'a zipper = 'a Priv.zipper
(** A {!zipper} is a ['a ]{!Diamond.diamond} but with additional information
    about a "position" which points to a particular ['a] value within the
    diamond (called the focus). The focus can be moved around to point to
    different positions within the nested diamonds.

    This is a {b private type}, so users outside this module can coerce it to a
    [(diamond, skeleton)], but they cannot manually construct a {!zipper}. It
    is not possible

    This is not a traditional functional programming zipper, because it is not
    particularly efficient to move the focus. Also, every access to the focused
    value will traverse the diamond from the root. *)

(** Builds an empty zipper with the given value. *)
let empty value : 'a zipper = Priv.wrap (Leaf value, [])

(** Returns the subdiamond with the currently focused position as its value. *)
let rec subdiamond dia =
  dia |> Priv.unwrap |> function
  | dia, [] -> dia
  | Diamond { left = x }, `L :: rest
  | Diamond { right = x }, `R :: rest
  | Diamond { pred = x }, `P :: rest ->
      subdiamond (Priv.wrap (x, rest))
  | Leaf _, _ :: _ -> failwith "invariant violation: invalid zipper path"

(** Returns the skeleton path to the focused position in the zipper. *)
let skeleton x = snd (unwrap x)

(** Returns the single focused value of the zipper. *)
let focus : 'a zipper -> 'a = fun x -> last (subdiamond x)

(** Converts the given {!zipper} to a full {!Diamond.diamond}. *)
let to_diamond = fun x -> fst (unwrap x)

(** Converts the given {!Diamond.diamond} to a zipper, initially focused at
    {!Diamond.last}. *)
let of_diamond : 'a diamond -> 'a zipper = fun x -> Priv.wrap (x, [])

(** Iterates over all {!zipper} positions of the given diamond, {i backwards} in
    control-flow order. *)
let iter_zippers_backwards : 'a diamond -> 'a zipper Iter.t =
  let rec iter_paths_backwards path dia k =
    match dia with
    | Leaf x -> k path
    | Diamond { value; left; right; pred } ->
        k path;
        iter_paths_backwards (`L :: path) left k;
        iter_paths_backwards (`R :: path) right k;
        iter_paths_backwards (`P :: path) pred k
  in
  fun d -> iter_paths_backwards [] d |> Iter.map (fun p -> Priv.wrap (d, p))

(** {1 Movement functions}

    When moving around the nested diamonds, there is a notion of "level" and
    whether two positions are at the same nesting level. The rule is that two
    values are at the same level if they have the same {!constructor-Diamond} as
    their direct parent.

    This can be subtle, especially with nesting. In the diagram below, we number
    the depths of each value position. 0 is the outermost level ({!last}), and
    increasing numbers are {i deeper} (but not necessarily earlier in program
    order!).
    {v
         2
        / \
       2   2
        \ /
         1
        / \
       /   2
      /   / \
     1   2   2
      \   \ /
       \   1
        \ /
         0
    v} *)

(** Moves the zipper to a position in the same diamond level. That is, to the
    last position of an adjacent subdiamond (see the [1] positions in the
    diagram above). *)
let move_adjacent direction : 'a zipper -> ('a zipper, 'a zipper) result =
 fun z ->
  z |> Priv.unwrap
  |> ( function
  | (_, []) as zip -> Error zip
  | dia, _ :: rest -> Ok (dia, direction :: rest) )
  |> Priv.wrap_result

(** Moves the zipper to a position in the outer diamond level. That is, to the
    {!type-diamond.value} of the containing {!Diamond.diamond}. In control-flow
    terms, this is the next control-flow join point. *)
let move_out_of : 'a zipper -> ('a zipper, 'a zipper) result =
 fun z ->
  z |> Priv.unwrap
  |> ( function (_, []) as zip -> Error zip | dia, _ :: rest -> Ok (dia, rest) )
  |> Priv.wrap_result

(** Moves the zipper to a position in the inner diamond level. In control-flow
    terms, this is the left or right branch, or the split point. *)
let move_in_to direction : 'a zipper -> ('a zipper, 'a zipper) result =
  Priv.unwrap
  %> ( function
  | (Leaf _, _) as zip -> Error zip
  | (Diamond _ as dia), rest -> Ok (dia, direction :: rest) )
  %> Priv.wrap_result

(** {1 Modification functions} *)

(** Modifies the {!subdiamond} of the given {!zipper}. *)
let rec modify_subdiamond (f : 'a diamond -> 'a diamond) :
    'a zipper -> 'a zipper =
  Priv.unwrap
  %> ( function
  | dia, [] -> (f dia, [])
  | Leaf _, _ :: _ -> failwith "invariant violation: invalid zipper path"
  | Diamond dia, (`L :: rest as path) ->
      let left, _ =
        Priv.unwrap (modify_subdiamond f (Priv.wrap (dia.left, rest)))
      in
      (Diamond { dia with left }, path)
  | Diamond dia, (`R :: rest as path) ->
      let right, _ =
        Priv.unwrap (modify_subdiamond f (Priv.wrap (dia.right, rest)))
      in
      (Diamond { dia with right }, path)
  | Diamond dia, (`P :: rest as path) ->
      let pred, _ =
        Priv.unwrap (modify_subdiamond f (Priv.wrap (dia.pred, rest)))
      in
      (Diamond { dia with pred }, path) )
  %> Priv.wrap

let modify f = modify_subdiamond (Diamond.modify_last f)

(** Modifies the zipper by inserting a new diamond {i after} the current
    position in program order, using the given parameters to build the new
    {!module-Diamond.constructor-Diamond}. *)
let append_diamond ~left ~right ~value : 'a zipper -> 'a zipper =
  modify_subdiamond (fun pred -> Diamond { pred; left; right; value })
  %> move_in_to `P %> CCResult.to_opt
  %> CCOption.get_exn_or
       "unreachable: moving to `P must succeed because subdiamond is not a Leaf"

(** {1 Derived functions} *)

let equal_skeleton = equal_skeleton
let pp_zipper = pp_zipper
let show_zipper = show_zipper
let pp_skeleton = pp_skeleton
let show_skeleton = show_skeleton
