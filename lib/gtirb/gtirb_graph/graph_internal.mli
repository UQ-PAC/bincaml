open Graph_types

type t
(** @canonical Gtirb_frontend.Gtirb_graph.t *)

type vertex = vert
type edge = vert * relation * vert

include
  Graph.Sig.I
    with type t := t
     and type V.t = vert
     and type V.label = vert
     and type E.t = vert * relation * vert
     and type E.label = relation
     and type vertex := vert
     and type edge := vert * relation * vert
