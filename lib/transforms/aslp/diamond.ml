(** Possibly-nested control-flow diamonds. This is enough to represent the
    runtime control flow emitted by the ASLp lifter, and the explicit structure
    helps with manipulation and analysis of ASLp's output. *)

(** {1 Diamonds} *)

(** Possibly-nested control flow diamonds.

    When thought of as a control-flow graph, the outermost [value] is the
    {b last} one in program order. Following the [pred] links will take you
    {b backwards} in program order until you reach the (unique) entry of the
    CFG.
    {v
       ⋱   ⋰
        pred
       /    \
    left   right
       \    /
        value
    v}

    This is isomorphic to an annotated ternary tree. However, for the
    control-flow interpretation, it is easier to think of it as {i nested}
    control-flow diamonds. In the diagram above, [pred], [left], and [right]
    could all be their own diamonds (but [value] is terminal).

    This diamond is "upside-down" in a sense. You could imagine an alternative
    diamond which has left/right/{i succ} fields, where the outermost value is
    the {i first} in program order. This might even seem more natural, but the
    current encoding (with [pred]) leads to much simpler branch switching and PC
    handling. This is because branch switching and PC insertion are both
    concerned with what happens at the {i end} of a control-flow diamond. The
    "upside-down" view makes the control-flow join values conveniently
    accessible. *)
type 'a diamond =
  | Leaf of 'a
  | Diamond of {
      pred : 'a diamond;
      left : 'a diamond;
      right : 'a diamond;
      value : 'a;
    }
[@@deriving show { with_path = false }, eq]

let empty value : 'a diamond = Leaf value

(** Returns the last value of the diamond in control-flow order. That is, the
    outermost ['a] value. *)
let last = function Leaf value | Diamond { value } -> value

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
    module, this is visible in {!diamond_path}.

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

(** {2 Preliminaries} *)

(** Moving one step through the {!diamond}. Each variant records the direction
    of the step, as well as the paths {i not} taken. This allows the {!diamond}
    to be reconstructed when moving "back" through a path. *)
type 'a diamond_step =
  | Left of { value : 'a; right : 'a diamond; pred : 'a diamond }
  | Right of { value : 'a; left : 'a diamond; pred : 'a diamond }
  | Pred of { value : 'a; left : 'a diamond; right : 'a diamond }
[@@deriving show { with_path = false }]

type 'a diamond_path = 'a diamond_step list [@@deriving show]
(** A type describing a path to a "hole" in a {!diamond}, with the ability to
    reconstruct the full {!diamond} when the hole is filled.

    For example, this diamond (where [@] is the missing child)
    {v
      p
     / \
    @   r
     \ /
      v
    v}
    would be represented by
    {v Left { value = v; right = r; pred = p } v}

    It is a list when the hole occurs inside a nested {!diamond}, the path is
    made up of multiple {!diamond_step} - starting from the hole and moving
    upwards until you get to the root.

    As one consequence of this, a {!diamond_path} of [[]] represents a
    {!diamond} which is all hole:
    {v @ v} *)

(** {2 Zipper for diamond} *)

type 'a diamond_zipper = 'a diamond * 'a diamond_path [@@deriving show]
(** Conceptually, a {!diamond_zipper} is a ['a ]{!diamond} but with additional
    information about a "position" which points to a particular ['a] value
    within the diamond (called the focus). The focus can be moved around to
    point to different positions within the nested diamonds.

    This is implemented by deconstructing a {!diamond} into a {!diamond_path}
    which represents parts of the diamond {i above} the focus, and a {!diamond}
    which represents the focus and nested diamonds {i below} the focus. The
    focus is the root of the stored {!diamond}. *)

(** Builds an empty zipper with the given value. *)
let empty_zipper value : 'a diamond_zipper = (Leaf value, [])

(** Returns the single focused value of the zipper. *)
let focus : 'a diamond_zipper -> 'a = function this, _ -> last this

(** Returns the subdiamond terminated by the currently focused position. *)
let subdiamond : 'a diamond_zipper -> 'a diamond = function this, _ -> this

(** Converts the given {!diamond_zipper} to a full {!diamond}. *)
let of_zipper : 'a diamond_zipper -> 'a diamond =
 fun (this, path) ->
  List.fold_left
    (fun this step ->
      match (this, step) with
      | left, Left { value; right; pred }
      | right, Right { value; left; pred }
      | pred, Pred { value; left; right } ->
          Diamond { value; left; right; pred })
    this path

(** Converts the given {!diamond} to a zipper, initially focused at {!last}. *)
let to_zipper : 'a diamond -> 'a diamond_zipper = fun dmd -> (dmd, [])

(** {2 Movement functions}

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
let move_adjacent direction :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (_, []) as zip -> Error zip
  | left, Left { value; right; pred } :: rest
  | right, Right { value; left; pred } :: rest
  | pred, Pred { value; left; right } :: rest -> (
      match direction with
      | `L -> Ok (left, Left { value; right; pred } :: rest)
      | `R -> Ok (right, Right { value; left; pred } :: rest)
      | `P -> Ok (pred, Pred { value; left; right } :: rest))

(** Moves the zipper to a position in the outer diamond level. That is, to the
    {!type-diamond.value} of the containing {!diamond}. In control-flow terms,
    this is the next control-flow join point. *)
let move_out_of :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (_, []) as zip -> Error zip
  | left, Left { value; right; pred } :: rest
  | right, Right { value; left; pred } :: rest
  | pred, Pred { value; left; right } :: rest ->
      Ok (Diamond { value; left; right; pred }, rest)

(** Moves the zipper to a position in the inner diamond level. In control-flow
    terms, this is the left or right branch, or the split point. *)
let move_in_to direction :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (Leaf _, _) as zip -> Error zip
  | Diamond { value; left; right; pred }, rest -> (
      match direction with
      | `L -> Ok (left, Left { value; right; pred } :: rest)
      | `R -> Ok (right, Right { value; left; pred } :: rest)
      | `P -> Ok (pred, Pred { value; left; right } :: rest))

(** {2 Modification functions} *)

(** Modifies the zipper by inserting a new diamond {i after} the current
    position in program order, using the given parameters to build the new
    {!constructor-Diamond}. *)
let append_diamond ~left ~right ~value : 'a diamond_zipper -> 'a diamond_zipper
    = function
  | dia, path -> (dia, Pred { value; left; right } :: path)

(** Modifies the value at the {!focus} of the given {!diamond_zipper}. *)
let modify (f : 'a -> 'a) : 'a diamond_zipper -> 'a diamond_zipper = function
  | Leaf x, path -> (Leaf (f x), path)
  | Diamond x, path -> (Diamond { x with value = f x.value }, path)

(** {1 Debugging} *)

let rec map f = function
  | Leaf x -> Leaf (f x)
  | Diamond { value; left; right; pred } ->
      let value = f value in
      let left = map f left and right = map f right and pred = map f pred in
      Diamond { value; left; right; pred }

type skeleton = unit diamond * [ `L | `R | `P ] list
[@@deriving show { with_path = false }, eq]

let skeleton : 'a diamond_zipper -> skeleton = function
  | this, path ->
      ( map (Fun.const ()) this,
        List.map (function Left _ -> `L | Right _ -> `R | Pred _ -> `P) path )

let rec cata ~(leaf : 'a -> 'b)
    ~(diamond : pred:'b -> left:'b -> right:'b -> value:'b -> 'b) dia : 'b =
  match dia with
  | Leaf x -> leaf x
  | Diamond { value; left; right; pred } ->
      let pred = cata ~leaf ~diamond pred
      and left = cata ~leaf ~diamond left
      and right = cata ~leaf ~diamond right
      and value = leaf value in
      diamond ~pred ~left ~right ~value

(** {1 Derived functions} *)

let equal_diamond = equal_diamond
let equal_skeleton = equal_skeleton
let pp_diamond = pp_diamond
let show_diamond = show_diamond
let pp_diamond_step = pp_diamond_step
let show_diamond_step = show_diamond_step
let pp_diamond_path = pp_diamond_path
let show_diamond_path = show_diamond_path
let pp_diamond_zipper = pp_diamond_zipper
let show_diamond_zipper = show_diamond_zipper
let pp_skeleton = pp_skeleton
let show_skeleton = show_skeleton
