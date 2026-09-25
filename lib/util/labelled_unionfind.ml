(** A union find data structure where edges between nodes have labels. This is
    described in {:https://doi.org/10.1145/3729298} but we differ by not
    requiring labels to form a group.

    In a usual union find, unified nodes may be thought of as equivalent. With
    labels, we may instead think of a node c with parent p under label f as
    being the image of p under the function f. If that parent is itself a
    function of another node p', then c is the image of the composite of the two
    functions of p'.

    We require that labels are only composable and have identities. This creates
    the possibly annoying requirement that only parent nodes can have edges
    added out of them. However, it permits many more types of labels to be used!
    If we wanted to support joining any two nodes together we would need a way
    to invert a label (so that we could add an edge from the parent of one cell
    after composing with the inverse), but it is often the case that labels we
    are interested have no inverse (e.g. linear functions on bitvectors have no
    inverse iff the coefficient is even). *)

(** The type of labels to be put onto a graph. Labels must be composable,
    composition should be associative and an identity label should be known.
    That is, a labelling is a monoid. *)
module type Label = sig
  type t

  val equal : t -> t -> bool
  val identity : t
  val compose : t -> t -> t
end

module Make (L : Label) = struct
  type 'a content = { mutable body : 'a; mutable parent : 'a edge option }

  and 'a edge = L.t * 'a t
  (** An edge into a node in the union find graph with a label *)

  and 'a t = 'a content ref
  (** A node in the union find graph *)

  (** Create a new node with the given contents and no edges *)
  let make body = ref { body; parent = None }

  (** Get the contents of a node ({b not} the contents of the parent node) *)
  let get (n : 'a t) : 'a = !n.body

  (** Replace the contents of this node ({b not} the contents of the parent
      node) *)
  let set (body : 'a) (n : 'a t) : unit = !n.body <- body

  (** Map the contents of this node with a function ({b not} the contents of the
      parent node) *)
  let update (f : 'a -> 'a) (n : 'a t) : unit = !n.body <- f !n.body

  (** Get the edge from a node to its parent. *)
  let rec find (v : 'a t) : 'a edge =
    match !v.parent with
    | Some (l1, v') ->
        let l2, v'' = find v' in
        let f = L.compose l2 l1 in
        let p = (f, v'') in
        !v.parent <- Some p;
        p
    | None -> (L.identity, v)

  (** Compose an edge with the parent edge of its target. *)
  let find_edge ((l1, v1) : 'a edge) : 'a edge =
    let l2, v2 = find v1 in
    (L.compose l2 l1, v2)

  let is_parent (v : 'a t) : bool = Option.is_none !v.parent

  (** [join v l v'] sets the parent of [v] to [v'] with label [l]. Panics if [v]
      is not a parent or a non-identity cycle would be formed. *)
  let join (v : 'a t) (l : L.t) (v' : 'a t) =
    assert (Option.is_none !v.parent);
    let l', p = find v' in
    if CCEqual.physical v p then assert (L.equal (L.compose l' l) L.identity)
    else !v.parent <- Some (L.compose l' l, p)
end

(** A labelled union find that also tracks the standard union find subgraph
    given by identity edges. *)
module MakeEquiv (L : Label) = struct
  type 'a content = {
    mutable body : 'a;
    mutable parent : 'a edge option;
    mutable eq_parent : 'a t option;
  }

  and 'a edge = L.t * 'a t
  (** An edge into a node in the union find graph with a label *)

  and 'a t = 'a content ref
  (** A node in the union find graph *)

  (** Create a new node with the given contents and no edges *)
  let make (body : 'a) : 'a t = ref { body; parent = None; eq_parent = None }

  (** Get the contents of a node ({b not} the contents of the parent node) *)
  let get (n : 'a t) : 'a = !n.body

  (** Replace the contents of this node ({b not} the contents of the parent
      node) *)
  let set (body : 'a) (n : 'a t) : unit = !n.body <- body

  (** Map the contents of this node with a function ({b not} the contents of the
      parent node) *)
  let update (f : 'a -> 'a) (n : 'a t) : unit = !n.body <- f !n.body

  (** Get the edge from a node to its parent. *)
  let rec find (v : 'a t) : 'a edge =
    match !v.parent with
    | Some (l1, v') ->
        let l2, v'' = find v' in
        let f = L.compose l2 l1 in
        let p = (f, v'') in
        !v.parent <- Some p;
        p
    | None -> (L.identity, v)

  (** Get the parent up to standard (identity-edge) equivalence of a node. *)
  let rec find_eq (v : 'a t) : 'a t =
    match !v.eq_parent with
    | Some v' ->
        let p = find_eq v' in
        !v.eq_parent <- Some p;
        p
    | None -> v

  (** Compose an edge with the parent edge of its target. *)
  let find_edge ((l1, v1) : 'a edge) : 'a edge =
    let l2, v2 = find v1 in
    (L.compose l2 l1, v2)

  let is_parent (v : 'a t) : bool = Option.is_none !v.parent
  let is_eq_parent (v : 'a t) : bool = Option.is_none !v.eq_parent

  (** [join v l v'] sets the parent of [v] to [v'] with label [l]. Panics if [v]
      is not a parent or a non-identity cycle would be formed. *)
  let join (v : 'a t) (l : L.t) (v' : 'a t) =
    assert (Option.is_none !v.parent);
    let eq_parent =
      if L.equal l L.identity then Some (find_eq v') else !v.eq_parent
    in
    let l', p = find v' in
    if CCEqual.physical v p then assert (L.equal (L.compose l' l) L.identity)
    else (
      !v.parent <- Some (L.compose l' l, p);
      !v.eq_parent <- eq_parent)

  (** [join_eq v v'] marks [v] equivalent to [v']. No labelled edges are added.
      If [v] and [v'] have the same labelled parent, they must have the same
      label to the parent, and a panic will occur otherwise. *)
  let join_eq (v : 'a t) (v' : 'a t) =
    let f, p = find v in
    let g, p' = find v' in
    if CCEqual.physical p p' then assert (L.equal f g);
    let p = find_eq v in
    let p' = find_eq v' in
    if not @@ CCEqual.physical p p' then !p.eq_parent <- Some p'
end

module type VisVertex = sig
  include Graph.Sig.COMPARABLE

  val show : t -> string
end

module type VisLabel = sig
  include Label

  val compare : t -> t -> int
  val show : t -> string
end

module VisLabelledGraph (V : VisVertex) (L : VisLabel) = struct
  module Vert = V

  module Edge = struct
    include L

    let default = L.identity
  end

  module G = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)

  module Dot = Graph.Graphviz.Dot (struct
    include G
    open Vert
    open Edge

    let default_vertex_attributes _ = []
    let graph_attributes _ = []
    let default_edge_attributes _ = []
    let get_subgraph _ = None

    let edge_attributes (_, f, _) =
      if L.equal f L.identity then []
      else
        let n = L.show f in
        [ `Label n ]

    let vertex_attributes v =
      let n = Vert.show v in
      [ `Shape `Box; `Fontname "Mono"; `Label n ]

    let vertex_name v = CCString.replace ~sub:"#" ~by:"hash" @@ Vert.show v
  end)
end

module MakeVis (V : VisVertex) (L : VisLabel) = struct
  include VisLabelledGraph (V) (L)
  module UF = Make (L)

  let make_graph edges nodes =
    let open UF in
    Iter.fold
      (fun g (n : V.t t) ->
        (match !n.parent with
          | Some (f, n') -> G.add_edge_e g (get n, f, get n')
          | None -> g)
        |> fun g ->
        List.fold_left
          (fun g (n' : V.t t) -> G.add_edge_e g (get n, L.identity, get n'))
          g (edges n))
      G.empty nodes
end

module MakeEquivVis (V : VisVertex) (L : VisLabel) = struct
  include VisLabelledGraph (V) (L)
  module UF = MakeEquiv (L)

  let make_graph edges nodes =
    let open UF in
    Iter.fold
      (fun g (n : V.t t) ->
        (match !n.parent with
          | Some (f, n') -> G.add_edge_e g (get n, f, get n')
          | None -> g)
        |> fun g ->
        List.fold_left
          (fun g (n' : V.t t) -> G.add_edge_e g (get n, L.identity, get n'))
          g (edges n))
      G.empty nodes
end
