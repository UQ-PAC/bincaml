(** Possibly-nested control flow diamonds.

    This is isomorphic to an annotated ternary tree. *)
type 'a diamond =
  | Leaf of 'a
  | Diamond of {
      value : 'a;
      left : 'a diamond;
      right : 'a diamond;
      merge : 'a diamond;
    }

type 'a diamond_step =
  | Left of { value : 'a; right : 'a diamond; merge : 'a diamond }
  | Right of { value : 'a; left : 'a diamond; merge : 'a diamond }
  | Merge of { value : 'a; left : 'a diamond; right : 'a diamond }

type 'a diamond_path = 'a diamond_step list
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

type 'a diamond_zipper = 'a diamond * 'a diamond_path
(** A {!diamond_zipper} is made up of a {!diamond_hole} combined with a
    {!diamond} to "mount" at that hole.

    A {!diamond_zipper} represents the same information as {!diamond}, but its
    structure allows to "move" the zipper around to focus on different points
    within the nested diamonds. *)

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

let move_to_adjacent :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | left, Left { value; right; merge } :: rest ->
      Ok (right, Right { value; left; merge } :: rest)
  | right, Right { value; left; merge } :: rest ->
      Ok (left, Left { value; right; merge } :: rest)
  | zip -> Error zip

let move_to_merge :
    'a diamond_zipper -> ('a diamond_zipper, 'a diamond_zipper) result =
  function
  | left, Left { value; right; merge } :: rest ->
      Ok (merge, Merge { value; left; right } :: rest)
  | right, Right { value; left; merge } :: rest ->
      Ok (merge, Merge { value; left; right } :: rest)
  | zip -> Error zip

let modify_diamond (f : 'a -> 'a) = function
  | Leaf x -> Leaf (f x)
  | Diamond x -> Diamond { x with value = f x.value }

let modify (f : 'a -> 'a) : 'a diamond_zipper -> 'a diamond_zipper = function
  | dia, path -> (modify_diamond f dia, path)
