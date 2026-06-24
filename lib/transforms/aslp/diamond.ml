(** Possibly-nested control flow diamonds.

    The root, or top-level, value of a {!diamond} is the outermost ['a] value.

    This is isomorphic to an annotated ternary tree. *)
type 'a diamond =
  | Leaf of 'a
  | Diamond of {
      value : 'a;
      left : 'a diamond;
      right : 'a diamond;
      merge : 'a diamond;
    }
[@@deriving show]

(** {1 Zippers} *)

type 'a diamond_step =
  | Left of { value : 'a; right : 'a diamond; merge : 'a diamond }
  | Right of { value : 'a; left : 'a diamond; merge : 'a diamond }
  | Merge of { value : 'a; left : 'a diamond; right : 'a diamond }
[@@deriving show]

type 'a diamond_path = 'a diamond_step list [@@deriving show]
(** A type describing a {!diamond} with one missing {!diamond} child, called the
    "hole".

    For example, this tree (where [@] is the missing child)
    {v
       v
     / | \
    @  r  m
    v}
    would be represented by
    {v Left { value = v; right = r; merge = m } v}

    It is a {i path} because if the hole occurs inside a nested {!diamond}, then
    the path is a list of {!diamond_step} - starting from the hole and moving
    upwards until you get to the root.

    As a consequence of this, a {!diamond_path} of [[]] represents a {!diamond}
    which is all hole:
    {v @ v} *)

type 'a diamond_zipper = 'a diamond * 'a diamond_path [@@deriving show]
(** Conceptually, a {!diamond_zipper} is a ['a ]{!diamond} but with additional
    information about a "position" which points to a particular ['a] value
    within the diamond (called the focus). The focus can be moved around to
    point to different positions within the nested diamonds.

    This is implemented by deconstructing a {!diamond} into a {!diamond_path}
    which represents parts of the diamond {i above} the focus, and a {!diamond}
    which represents the focus and nested diamonds {i below} the focus. The
    focus is the root of the stored {!diamond}. *)

let empty_zipper value : 'a diamond_zipper = (Leaf value, [])

let rec of_zipper : 'a diamond_zipper -> 'a diamond = function
  | this, [] -> this
  | this, bot :: rest -> (
      match bot with
      | Left { value; right; merge } ->
          of_zipper (Diamond { value; left = this; right; merge }, rest)
      | Right { value; left; merge } ->
          of_zipper (Diamond { value; left; right = this; merge }, rest)
      | Merge { value; left; right } ->
          of_zipper (Diamond { value; left; right; merge = this }, rest))

(** Converts the given {!diamond} to a zipper, positioned at the entry/root
    value. *)
let to_zipper : 'a diamond -> 'a diamond_zipper = fun dmd -> (dmd, [])

(** {1 Movement functions} *)

let move_adjacent direction :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (_, []) as zip -> Error zip
  | left, Left { value; right; merge } :: rest
  | right, Right { value; left; merge } :: rest
  | merge, Merge { value; left; right } :: rest -> (
      match direction with
      | `L -> Ok (left, Left { value; right; merge } :: rest)
      | `R -> Ok (right, Right { value; left; merge } :: rest)
      | `M -> Ok (merge, Merge { value; left; right } :: rest))

let move_out_of :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (_, []) as zip -> Error zip
  | left, Left { value; right; merge } :: rest
  | right, Right { value; left; merge } :: rest
  | merge, Merge { value; left; right } :: rest ->
      Ok (Diamond { value; left; right; merge }, rest)

let move_in_to direction :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | (Leaf _, _) as zip -> Error zip
  | Diamond { value; left; right; merge }, rest -> (
      match direction with
      | `L -> Ok (left, Left { value; right; merge } :: rest)
      | `R -> Ok (right, Right { value; left; merge } :: rest)
      | `M -> Ok (merge, Merge { value; left; right } :: rest))

let move_to_end : 'a diamond_zipper -> 'a diamond_zipper = function
  | (Leaf _, _) as zip -> zip
  | zip -> (
      match move_in_to `M zip with
      | Ok x -> x
      | Error _ -> failwith "invariant violation :>")

let promote_to_diamond ~left ~right ~merge :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | Leaf value, path -> Ok (Diamond { value; left; right; merge }, path)
  | zip -> Error zip

(** {1 Modification functions} *)

(** Modifies the {i top-level} value of the given {!diamond} (doesn't modify any
    child diamonds). *)
let modify_diamond (f : 'a -> 'a) = function
  | Leaf x -> Leaf (f x)
  | Diamond x -> Diamond { x with value = f x.value }

(** Modifies the currently-focused value of the given {!diamond_zipper}. *)
let modify (f : 'a -> 'a) : 'a diamond_zipper -> 'a diamond_zipper = function
  | dia, path -> (modify_diamond f dia, path)

let root : 'a diamond_zipper -> 'a = function
  | Leaf value, _ | Diamond { value; _ }, _ -> value
