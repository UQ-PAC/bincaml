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

(** {1 {!Iter.t} iterators for the graph} *)

let of_edges_iter it =
  let g = create () in
  it |> Iter.iter (add_edge_e g);
  g

let to_vertex_iter g = Iter.from_iter (Fun.flip iter_vertex g)
let to_edges_iter g = Iter.from_iter (Fun.flip iter_edges_e g)
let succs_iter g v = Iter.from_iter (fun k -> iter_succ_e k g v)
let preds_iter g v = Iter.from_iter (fun k -> iter_pred_e k g v)
