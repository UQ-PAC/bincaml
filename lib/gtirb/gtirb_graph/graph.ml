(** {2 Graph functions} *)

open Types

module Internal =
  Dependencies.Graph.Imperative.Digraph.ConcreteLabeled
    (struct
      type t = vert

      let compare = Stdlib.compare
      let hash = Hashtbl.hash
      let equal = Stdlib.( = )
    end)
    (struct
      type t = relation

      let compare = Stdlib.compare
      let default = Unknown_edge_type
    end)

include (
  Internal :
    Dependencies.Graph.Sig.I
      with type t = Internal.t
      with type V.t := vert
      with type vertex := vert
      with type V.label := vert
      with type E.t := vert * relation * vert
      with type E.label := relation
      with type E.vertex := vert)

(** {2 Helper functions} *)

let make_rel (kind : relation) (a, b) = (a, kind, b)
let make_uuid_rel (kind : relation) (a, b) = (Uuid a, kind, Uuid b)
