(** {2 Ocamlgraph functions}

    Be careful with using these! *)

open Graph_types

include
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
