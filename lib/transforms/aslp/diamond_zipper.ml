(** Functionality for representing and moving through {i positions} of a
    {!Diamond.diamond}. *)

open CCFun
open Diamond

(** {1 Zippers}

    A zipper is a concept in functional programming (especially, Haskell) that
    allows for efficient stepwise movement through a recursive algebraic data
    type.

    Functionally, a zipper for some data type ['a t] acts similarly to ['a t],
    but augmented with the ability to point to one ['a] element, called the
    focus.

    A desirable property of zippers is that they should allow for efficient
    (usually, [O(1)]) movement to adjacent positions within the data structure.
    In practice, this leads to zippers storing an "inside-out" view of the data
    structure. For example, a list zipper is made up of two lists, one of which
    is reversed:
    {v
    [1; 2; 3; 4; 5; 6]
              ^ pointer

    { before = [3, 2, 1]; focus_and_after = [4, 5, 6] }
    v}
    In trees, this manifests as storing a bottom-up path to the focus. In this
    module, this is visible in {!path}.

    {2 Resources}

    There are lots of resources on zippers. The idea of a zipper was first
    described by
    {{:https://gallium.inria.fr/~huet/PUBLIC/zip.pdf} Huet in 1993}. In this
    module, we represent a zipper as a "one-hole context" combined with a
    subtree. This is described by
    {{:http://strictlypositive.org/diff.pdf} McBride}.

    This module was mostly implemented by following the
    {{:https://wiki.haskell.org/Zipper} Haskell wiki} (if reading this, be aware
    that our inner nodes store values). If you enjoy Tony Morris's teaching
    style, he has
    {{:https://www.youtube.com/watch?v=HqHdgBXOOsE} a talk on YouTube} (the
    first 10 minutes are most relevant). *)

open Diamond

(** {1 Preliminaries} *)

(** Moving one step through the {!Diamond.diamond}. Each variant records the
    direction of the step, as well as the paths {i not} taken. This allows the
    {!Diamond.diamond} to be reconstructed when moving "back" through a path. *)
type 'a step =
  | Left of { value : 'a; right : 'a diamond; pred : 'a diamond }
  | Right of { value : 'a; left : 'a diamond; pred : 'a diamond }
  | Pred of { value : 'a; left : 'a diamond; right : 'a diamond }
[@@deriving show { with_path = false }]

type 'a path = 'a step list [@@deriving show]
(** A type describing a path to a "hole" in a {!Diamond.diamond}, with the
    ability to reconstruct the full {!Diamond.diamond} when the hole is filled.

    For example, this diamond (where [@] is the missing child)
    {v
      p
     / \
    @   r
     \ /
      v
    v}
    would be represented by
    {v [ Left { value = v; right = r; pred = p } ] v}

    It is a list when the hole occurs inside a nested {!Diamond.diamond}, the
    path is made up of multiple {!step} - starting from the hole and moving
    upwards until you get to the root.

    As one consequence of this, a {!path} of [[]] represents a
    {!Diamond.diamond} which is all hole:
    {v @ v} *)

(** {1 Zipper for diamond} *)

(** Conceptually, a {!zipper} is a ['a ]{!Diamond.diamond} but with additional
    information about a "position" which points to a particular ['a] value
    within the diamond (called the focus). The focus can be moved around to
    point to different positions within the nested diamonds.

    This is implemented by deconstructing a {!Diamond.diamond} into a {!path}
    which represents parts of the diamond {i above} the focus, and a
    {!Diamond.diamond} which represents the focus and nested diamonds {i below}
    the focus. The focus is the root of the stored {!Diamond.diamond}. *)
type 'a zipper = Zipper of 'a diamond * 'a path [@@deriving show]

(** Builds an empty zipper with the given value. *)
let empty value : 'a zipper = Zipper (Leaf value, [])

(** Returns the single focused value of the zipper. [focus x] is equivalent to
    {!Diamond.last}[ ]{!subdiamond}[ x]. *)
let focus (Zipper (this, _)) = last this

(** Returns the subdiamond terminated by the currently focused position. *)
let subdiamond (Zipper (this, _)) = this

(** Returns the path of the given zipper. The path is the sequence of steps
    leading to the focused subdiamond, inside-out. *)
let path (Zipper (_, path)) = path

(** Converts the given {!zipper} to a full {!Diamond.diamond}. *)
let to_diamond : 'a zipper -> 'a diamond = function
  | Zipper (this, path) ->
      List.fold_left
        (fun this step ->
          match (this, step) with
          | left, Left { value; right; pred }
          | right, Right { value; left; pred }
          | pred, Pred { value; left; right } ->
              Diamond { value; left; right; pred })
        this path

(** Converts the given {!Diamond.diamond} to a zipper, initially focused at
    {!last}. *)
let of_diamond : 'a diamond -> 'a zipper = fun d -> Zipper (d, [])

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
  function
  | Zipper (_, []) as zip -> Error zip
  | Zipper (left, Left { value; right; pred } :: rest)
  | Zipper (right, Right { value; left; pred } :: rest)
  | Zipper (pred, Pred { value; left; right } :: rest) -> (
      match direction with
      | `L -> Ok (Zipper (left, Left { value; right; pred } :: rest))
      | `R -> Ok (Zipper (right, Right { value; left; pred } :: rest))
      | `P -> Ok (Zipper (pred, Pred { value; left; right } :: rest)))

(** Moves the zipper to a position in the outer diamond level. That is, to the
    {!type-diamond.value} of the containing {!Diamond.diamond}. In control-flow
    terms, this is the next control-flow join point. *)
let move_out_of : 'a zipper -> ('a zipper, 'a zipper) result = function
  | Zipper (_, []) as zip -> Error zip
  | Zipper (pred, Pred { value; left; right } :: rest)
  | Zipper (left, Left { value; right; pred } :: rest)
  | Zipper (right, Right { value; left; pred } :: rest) ->
      Ok (Zipper (Diamond { value; left; right; pred }, rest))

(** Moves the zipper to a position in the inner diamond level. In control-flow
    terms, this is the left or right branch, or the split point. *)
let move_in_to direction : 'a zipper -> ('a zipper, 'a zipper) result = function
  | Zipper (Leaf _, _) as zip -> Error zip
  | Zipper (Diamond { value; left; right; pred }, rest) -> (
      match direction with
      | `L -> Ok (Zipper (left, Left { value; right; pred } :: rest))
      | `R -> Ok (Zipper (right, Right { value; left; pred } :: rest))
      | `P -> Ok (Zipper (pred, Pred { value; left; right } :: rest)))

(** {1 Modification functions} *)

(** Modifies the {!subdiamond} of the given {!zipper}. *)
let modify_subdiamond (f : 'a diamond -> 'a diamond) : 'a zipper -> 'a zipper =
  function
  | Zipper (d, path) -> Zipper (f d, path)

(** Modifies the {!focus} of the given {!zipper}. *)
let modify f = modify_subdiamond (Diamond.modify_last f)

(** Modifies the zipper by inserting a new diamond {i after} the current
    position in program order, using the given parameters to build the new
    {!module-Diamond.constructor-Diamond}. *)
let append_diamond ~left ~right ~value : 'a zipper -> 'a zipper =
  modify_subdiamond (fun pred -> Diamond { pred; left; right; value })
  %> move_in_to `P %> CCResult.to_opt
  %> CCOption.get_exn_or
       "unreachable: moving to `P will succeed because subdiamond is not a Leaf"

(** {1 Iteration functions} *)

(** Iterates over {!zipper} positions within the {!subdiamond} of the current
    zipper, {i backwards} in control-flow order. *)
let iter_subzippers_backwards zip : 'a zipper Iter.t =
 fun k ->
  let rec recurse = function
    | Ok (Zipper (Leaf _, _) as zip) -> k zip
    | Ok (Zipper (Diamond _, _) as zip) ->
        k zip;
        recurse (move_in_to `L zip);
        recurse (move_in_to `R zip);
        recurse (move_in_to `P zip)
    | Error _ -> ()
  in
  recurse (Ok zip)

(** Iterates over all {!zipper} positions of the given diamond, {i backwards} in
    control-flow order. *)
let iter_zippers_backwards : 'a diamond -> 'a zipper Iter.t =
 fun d k -> iter_subzippers_backwards (of_diamond d) k
(* [k] parameter ensures [of_diamond] is not run until it is needed. *)

(** {1 Breadth-first iteration} *)

(** Implementation details for BFS iteration. *)
module Bfs_internal = struct
  (** A {!CCKTree.pset} that ignores all adds and always returns that every
      value is not in the set. *)
  let noop_pset : _ CCKTree.pset =
    object (this)
      method add _ = this
      method mem _ = false
    end

  type from_direction =
    [ `In of [ `P | `L | `R ] | `Out of [ `P | `L | `R ] | `Initial ]
  (** Direction which a BFS traversal {i came from}. [`In] and [`Out] record the
      field that was moved in to or out of. *)

  type to_direction = [ `In of [ `P | `L | `R ] | `Out ]
  (** Direction which a BFS traversal is {i going to}. *)

  (** Moves in a BFS direction. This is not quite the same as the usual move
      functions. In particular, moving to the [`M] point is only allowed when
      currently at a [`P] point. *)
  let move (d : to_direction) zip : from_direction * _ result =
    match (d, zip) with
    | (`In d as from), _ -> (from, move_in_to d zip)
    | `Out, Zipper (_, Pred _ :: _) -> (`Out `P, move_out_of zip)
    | `Out, Zipper (_, Left _ :: _) -> (`Out `L, move_out_of zip)
    | `Out, Zipper (_, Right _ :: _) -> (`Out `R, move_out_of zip)
    | `Out, Zipper (_, []) -> (`Initial, Error zip)

  (** [directions from] returns valid adjacent directions, given that the
      current zipper was reached from the direction [from]. [from] is used to
      avoid going backwards. For example, if we have just gone [`In], we mustn't
      go back [`Out]. *)
  let directions : from_direction -> to_direction list = function
    | `Initial -> [ `Out; `In `L; `In `R; `In `P ]
    | `In d -> [ `In `L; `In `R; `In `P ]
    | `Out `P -> [ `Out; `In `L; `In `R ]
    | `Out `L -> [ `Out; `In `R; `In `P ]
    | `Out `R -> [ `Out; `In `L; `In `P ]
  (* Order of this list controls iteration order within a BFS level. *)

  (** Converts the given [zip] into a tree. If this is being called recursively,
      [from] should be set to the direction which led to [zip] to avoid cyclic
      backtracking. In the initial call, it should be set to [`Initial] to
      include all starting directions. *)
  let rec to_ktree from zip : 'a zipper CCKTree.t =
   fun () -> `Node (zip, to_ktree_successors from zip)

  and to_ktree_successors from zip : 'a zipper CCKTree.t list =
    directions from
    |> List.map (fun d () ->
        match move d zip with
        | d, Ok zip -> to_ktree d zip ()
        | _, Error _ -> `Nil)
  (* Additional () inside the map function defers running [move] until needed. *)
end

(** Iterates over all {!zipper} positions of the given zipper, {i breadth-first}
    through the diamond structure starting from the current position. *)
let iter_bfs st =
  CCKTree.bfs ~pset:Bfs_internal.noop_pset (Bfs_internal.to_ktree `Initial st)
  |> Iter.of_seq

(** {1 Derived functions} *)

let pp_zipper = pp_zipper
let show_zipper = show_zipper
let pp_step = pp_step
let show_step = show_step
let pp_path = pp_path
let show_path = show_path
