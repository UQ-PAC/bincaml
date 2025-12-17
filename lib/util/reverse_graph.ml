module type GraphSig = sig
  type t

  module V : Graph.Sig.VERTEX

  type vertex = V.t

  module E : sig
    type t

    val compare : t -> t -> int

    type vertex = V.t

    val src : t -> vertex
    val dst : t -> vertex

    type label

    val create : vertex -> label -> vertex -> t
    val label : t -> label
  end

  type edge = E.t

  val iter_vertex : (vertex -> unit) -> t -> unit
  val iter_succ : (vertex -> unit) -> t -> vertex -> unit
  val iter_pred : (vertex -> unit) -> t -> vertex -> unit
  val fold_pred_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
  val fold_succ_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
end

module RevG (G : GraphSig) = struct
  type t = G.t
  type vertex = G.vertex
  type edge = G.edge

  module E = struct
    include G.E

    let src = G.E.dst
    let dst = G.E.src
  end

  module V = G.V

  let iter_vertex = G.iter_vertex
  let iter_succ = G.iter_pred
  let iter_pred = G.iter_succ
  let fold_pred_e = G.fold_succ_e
  let fold_succ_e = G.fold_pred_e
end
