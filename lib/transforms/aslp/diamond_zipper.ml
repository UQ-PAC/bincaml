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
type ('a, 'd) step =
  | Left of { value : 'a; right : 'd; pred : 'd }
  | Right of { value : 'a; left : 'd; pred : 'd }
  | Pred of { value : 'a; left : 'd; right : 'd }
[@@deriving show { with_path = false }]

type 'a path = ('a, 'a diamond) step list [@@deriving show]
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

module Lazy = struct
  type 'a lazy_diamond_cell =
    | Leaf of 'a
    | Diamond of {
        pred : 'a lazy_diamond;
        left : 'a lazy_diamond;
        right : 'a lazy_diamond;
        value : 'a;
      }

  and 'a lazy_diamond = 'a lazy_diamond_cell Lazy.t

  type 'a lazy_step = ('a, 'a lazy_diamond) step
  type 'a lazy_path = 'a lazy_step Seq.t
  type 'a lazy_zipper = LazyZipper of 'a lazy_diamond * 'a lazy_path

  (** structure is unchanged! but each value position is augmented with "all of
      the context". *)
  let rec g : 'a zipper -> 'a zipper diamond = function
    | Zipper (Leaf _, path) as zip -> Leaf zip
    | Zipper (Diamond _, _) as zip ->
        let left = zip |> move_in_to `L |> Result.get_ok |> g
        and right = zip |> move_in_to `R |> Result.get_ok |> g
        and pred = zip |> move_in_to `P |> Result.get_ok |> g in
        Diamond { value = zip; left; right; pred }

  (** Steps out by one step *)
  let h : 'a zipper -> (_ step * 'a zipper) option = function
    | Zipper (_, []) -> None
    | Zipper (_, step :: _) as zip -> (
        let moved_out = move_out_of zip |> Result.get_ok in
        match step with
        | Left _ ->
            let right = move_adjacent `R zip |> Result.get_ok |> g
            and pred = move_adjacent `P zip |> Result.get_ok |> g in
            Some (Left { value = zip; right; pred }, moved_out)
        | Right _ ->
            let left = move_adjacent `L zip |> Result.get_ok |> g
            and pred = move_adjacent `P zip |> Result.get_ok |> g in
            Some (Right { value = zip; left; pred }, moved_out)
        | Pred _ ->
            let left = move_adjacent `L zip |> Result.get_ok |> g
            and right = move_adjacent `R zip |> Result.get_ok |> g in
            Some (Pred { value = zip; left; right }, moved_out))
  (** It's kind of like putting each value into itself *)

  (** structure is unchanged! but each value position is augmented with "all of
      the context". *)
  let rec g : 'a zipper -> 'a zipper lazy_diamond = function
    | Zipper (Leaf _, path) as zip -> lazy (Leaf zip)
    | Zipper (Diamond _, _) as zip ->
        let left = zip |> move_in_to `L |> Result.get_ok |> g
        and right = zip |> move_in_to `R |> Result.get_ok |> g
        and pred = zip |> move_in_to `P |> Result.get_ok |> g in
        lazy (Diamond { value = zip; left; right; pred })

  (** Steps out by one step *)
  let h : 'a zipper -> ('a zipper lazy_step * 'a zipper) option = function
    | Zipper (_, []) -> None
    | Zipper (_, step :: _) as zip -> (
        let moved_out = move_out_of zip |> Result.get_ok in
        match step with
        | Left _ ->
            let right = move_adjacent `R zip |> Result.get_ok |> g
            and pred = move_adjacent `P zip |> Result.get_ok |> g in
            Some (Left { value = zip; right; pred }, moved_out)
        | Right _ ->
            let left = move_adjacent `L zip |> Result.get_ok |> g
            and pred = move_adjacent `P zip |> Result.get_ok |> g in
            Some (Right { value = zip; left; pred }, moved_out)
        | Pred _ ->
            let left = move_adjacent `L zip |> Result.get_ok |> g
            and right = move_adjacent `R zip |> Result.get_ok |> g in
            Some (Pred { value = zip; left; right }, moved_out))
  (** It's kind of like putting each value into itself *)

  let duplicate : 'a zipper -> 'a zipper lazy_zipper =
   fun zip ->
    let dia = g zip and path = CCSeq.unfold h zip in
    LazyZipper (dia, path)
end

(** Implementation details for BFS iteration. *)
module Bfs_internal = struct
  let rec ktree_of_diamond (d, dia) =
   fun () ->
    match dia with
    | Leaf x -> `Node ((d, x), [])
    | Diamond { value; left; right; pred } ->
        let children =
          List.map ktree_of_diamond [ (`L, left); (`R, right); (`P, pred) ]
        in
        `Node ((d, value), children)

  let rec ktree_of_path (`S, path) : _ CCKTree.t =
   fun () ->
    match path with
    | [] -> `Nil
    | step :: rest ->
        let value, x1, x2 =
          match step with
          | Pred { value; left; right } -> (value, (`L, left), (`R, right))
          | Left { value; right; pred } -> (value, (`R, right), (`P, pred))
          | Right { value; left; pred } -> (value, (`L, left), (`P, pred))
        in
        let children = List.map ktree_of_diamond [ x1; x2 ] in
        `Node ((`S, value), ktree_of_path (`S, rest) :: children)

  let ktree_of_zipper (Zipper (dia, path)) : _ CCKTree.t =
    ktree_of_diamond (`Root, dia) %> function
    | `Node (x, children) ->
        `Node
          ( x,
            ktree_of_path (`S, path)
            :: (children
                 : (unit -> [ `Node of _ * 'b list ] as 'b) list
                 :> _ CCKTree.t list) )

  let rec scan_ktree (f : 'acc -> 'a -> 'acc) acc (tree : 'a CCKTree.t) :
      'acc CCKTree.t =
   fun () ->
    match tree () with
    | `Nil -> `Nil
    | `Node (x, children) ->
        let acc = f acc x in
        `Node (acc, List.map (scan_ktree f acc) children)

  (* Additional () inside the map function defers running [move] until needed. *)

  let rec bfs_tree_step q : ('a * 'a CCSimple_queue.t) option =
    match CCSimple_queue.pop q with
    | None -> None
    | Some (tree, q) -> (
        match tree () with
        | `Nil -> bfs_tree_step q
        | `Node (x, children) -> Some (x, CCSimple_queue.add_list q children))
end

(** Iterates over all {!zipper} positions of the given zipper, {i breadth-first}
    through the diamond structure starting from the current position. *)
let iter_bfs st : 'a Iter.t = 2

(** {1 Derived functions} *)

let pp_zipper = pp_zipper
let show_zipper = show_zipper
let pp_step = pp_step
let show_step = show_step
let pp_path = pp_path
let show_path = show_path
