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

(** {1 Basic functions} *)

let empty value : 'a diamond = Leaf value

(** Returns the last value of the diamond in control-flow order. That is, the
    outermost ['a] value. *)
let last = function Leaf value | Diamond { value } -> value

let modify_last f = function
  | Leaf x -> Leaf (f x)
  | Diamond ({ value = x } as dia) -> Diamond { dia with value = f x }

(** Returns the first value of the diamond in control-flow order. That is, the
    entry point. This is the innermost ['a] value following only [pred] links.
*)
let rec first = function Leaf x -> x | Diamond { pred } -> first pred

(** {1 Structural transformations} *)

(** Maps the given function over the {!diamond} structure, processing values
    {i forwards} in control-flow order. *)
let rec map_forwards f = function
  | Leaf x -> Leaf (f x)
  | Diamond { value; left; right; pred } ->
      let pred = map_forwards f pred
      and left = map_forwards f left
      and right = map_forwards f right in
      let value = f value in
      Diamond { value; left; right; pred }

(** Maps the given function over the {!diamond} structure, processing values
    {i backwards} in control-flow order. *)
let rec map_backwards f = function
  | Leaf x -> Leaf (f x)
  | Diamond { value; left; right; pred } ->
      let value = f value in
      let left = map_backwards f left
      and right = map_backwards f right
      and pred = map_backwards f pred in
      Diamond { value; left; right; pred }

(** Iterates over the {!diamond} structure, processing values {i forwards} in
    control-flow order. *)
let rec iter_backwards : 'a diamond -> 'a Iter.t = function
  | Leaf x -> fun k -> k x
  | Diamond { value; left; right; pred } ->
      fun k ->
        k value;
        iter_backwards left k;
        iter_backwards right k;
        iter_backwards pred k

(** Iterates over the {!diamond} structure, processing values {i backwards} in
    control-flow order. *)
let rec iter_backwards : 'a diamond -> 'a Iter.t = function
  | Leaf x -> fun k -> k x
  | Diamond { value; left; right; pred } ->
      fun k ->
        iter_backwards pred k;
        iter_backwards left k;
        iter_backwards right k;
        k value

(** Folds the given functions over the {!diamond} structure, processing values
    {i forwards} in control-flow order. *)
let rec cata ~(leaf : 'a -> 'b)
    ~(diamond : pred:'b -> left:'b -> right:'b -> value:'a -> 'b) dia : 'b =
  match dia with
  | Leaf x -> leaf x
  | Diamond { value; left; right; pred } ->
      let pred = cata ~leaf ~diamond pred
      and left = cata ~leaf ~diamond left
      and right = cata ~leaf ~diamond right in
      diamond ~pred ~left ~right ~value

(** Enumerates each value in the {!diamond} with the result of [f value],
    processing values {i forwards} in control-flow order. *)
let enumerate : ('a -> 'b) -> 'a diamond -> ('b * 'a) diamond =
 fun f dia -> map_forwards (fun x -> (f x, x)) dia

(** Combines each value in the {!diamond} with the values of its successors in
    control-flow order.

    A [pred] node has two successors, and a [left] or [right] node has one
    successor. *)
let affix_successors : 'a diamond -> ('a * 'a list) diamond =
 fun dia ->
  let leaf x = Leaf (x, []) in
  let diamond ~pred ~left ~right ~value =
    let add_succ x = modify_last (CCPair.map_snd (List.append x)) in

    let l, r = (fst (first left), fst (first right)) in
    let pred = pred |> add_succ [ l; r ]
    and left = left |> add_succ [ value ]
    and right = right |> add_succ [ value ] in
    Diamond { pred; left; right; value = (value, []) }
  in
  cata ~leaf ~diamond dia

(** Enumerates each value in the {!diamond} with the result of [f value], as
    well as the enumerated value from each of its control-flow successors. *)
let enumerate_with_successors :
    ('a -> 'b) -> 'a diamond -> ('b * 'b list * 'a) diamond =
 fun f dia ->
  dia |> enumerate f |> affix_successors
  |> map_forwards (fun ((id, x), succs) -> (id, List.map fst succs, x))

(** {1 Derived functions} *)

let equal_diamond = equal_diamond
let pp_diamond = pp_diamond
let show_diamond = show_diamond
