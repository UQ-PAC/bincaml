type 'a diamond =
  | Leaf of 'a
  | Diamond of {
      value : 'a;
      left : 'a diamond;
      right : 'a diamond;
      merge : 'a diamond;
    }

type 'a diamond_level =
  | Left of { value : 'a; right : 'a diamond; merge : 'a diamond }
  | Right of { value : 'a; left : 'a diamond; merge : 'a diamond }
  | Merge of { value : 'a; left : 'a diamond; right : 'a diamond }

type 'a diamond_hole = 'a diamond_level list
(** A type describing the position of one unfilled ['a] cell within a
    ['a ]{!diamond}. *)

type 'a diamond_zipper = 'a diamond * 'a diamond_hole
(** A {!diamond_zipper} is made up of a {!diamond_hole} combined with a
    {!diamond} to "mount" at that hole. *)

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

let modify_head (f : 'a -> 'a) = function
  | Leaf x -> Leaf (f x)
  | Diamond x -> Diamond { x with value = f x.value }
