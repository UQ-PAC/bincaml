(** Ocamlgraph representation of the GTIRB graph. Use higher-level functions if
    possible! *)

open Graph_types

include
  Graph.Imperative.Digraph.ConcreteBidirectionalLabeled
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
