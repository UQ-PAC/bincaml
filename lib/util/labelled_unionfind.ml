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

  val eq : t -> t -> bool
  val identity : t
  val compose : t -> t -> t
end

module Make (L : Label) = struct
  type 'a content = { body : 'a; parent : 'a edge option }

  and 'a edge = L.t * 'a t
  (** An edge into a node in the union find graph with a label *)

  and 'a t = 'a content ref
  (** A node in the union find graph *)

  (** Get the edge from a node to its parent. *)
  let rec find (v : 'a t) : 'a edge =
    match !v.parent with
    | Some (l1, v') ->
        let l2, v'' = find v' in
        let f = L.compose l2 l1 in
        let p = (f, v'') in
        v := { !v with parent = Some p };
        p
    | None -> (L.identity, v)

  (** Compose an edge with the parent edge of its target. *)
  let find_edge ((l1, v1) : 'a edge) : 'a edge =
    let l2, v2 = find v1 in
    (L.compose l2 l1, v2)

  (** [join v l v'] sets the parent of [v] to [v'] with label [l]. Panics if [v]
      is not a parent or a non-identity cycle would be formed. *)
  let join (v : 'a t) (l : L.t) (v' : 'a t) =
    assert (Option.is_none !v.parent);
    let l', p = find v' in
    if CCEqual.physical v p then assert (L.eq (L.compose l' l) L.identity)
    else v := { !v with parent = Some (L.compose l' l, p) }
end

(** A labelled union find that also tracks the standard union find subgraph
    given by identity edges. *)
module MakeEquiv (L : Label) = struct
  type 'a content = {
    body : 'a;
    parent : 'a edge option;
    eq_parent : 'a t option;
  }

  and 'a edge = L.t * 'a t
  (** An edge into a node in the union find graph with a label *)

  and 'a t = 'a content ref
  (** A node in the union find graph *)

  (** Get the edge from a node to its parent. *)
  let rec find (v : 'a t) : 'a edge =
    match !v.parent with
    | Some (l1, v') ->
        let l2, v'' = find v' in
        let f = L.compose l2 l1 in
        let p = (f, v'') in
        v := { !v with parent = Some p };
        p
    | None -> (L.identity, v)

  (** Get the parent up to standard (identity-edge) equivalence of a node. *)
  let rec find_eq (v : 'a t) : 'a t =
    match !v.eq_parent with
    | Some v' ->
        let p = find_eq v' in
        v := { !v with eq_parent = Some p };
        p
    | None -> v

  (** Compose an edge with the parent edge of its target. *)
  let find_edge ((l1, v1) : 'a edge) : 'a edge =
    let l2, v2 = find v1 in
    (L.compose l2 l1, v2)

  (** [join v l v'] sets the parent of [v] to [v'] with label [l]. Panics if [v]
      is not a parent or a non-identity cycle would be formed. *)
  let join (v : 'a t) (l : L.t) (v' : 'a t) =
    assert (Option.is_none !v.parent);
    let eq_parent =
      if L.eq l L.identity then Some (find_eq v') else !v.eq_parent
    in
    let l', p = find v' in
    if CCEqual.physical v p then assert (L.eq (L.compose l' l) L.identity)
    else v := { !v with parent = Some (L.compose l' l, p); eq_parent }

  (** [join_eq v v'] marks [v] equivalent to [v']. No labelled edges are added.
      If [v] and [v'] have the same labelled parent, they must have the same
      label to the parent, and a panic will occur otherwise. *)
  let join_eq (v : 'a t) (v' : 'a t) =
    let f, p = find v in
    let g, p' = find v' in
    if CCEqual.physical p p' then assert (L.eq f g);
    let p = find_eq v in
    let p' = find_eq v' in
    if not @@ CCEqual.physical p p' then p := { !p with eq_parent = Some p' }
end
