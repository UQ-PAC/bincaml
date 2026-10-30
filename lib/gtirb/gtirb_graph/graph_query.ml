(** High-level functions for working with {!Gtirb_graph.t}. *)

(** {1 {!Iter.t} iterators for the graph} *)

let of_edges_iter it =
  let g = Graph_internal.create () in
  it |> Iter.iter (Graph_internal.add_edge_e g);
  g

let to_vertex_iter g = Iter.from_iter (Fun.flip Graph_internal.iter_vertex g)
let to_edges_iter g = Iter.from_iter (Fun.flip Graph_internal.iter_edges_e g)
let succs_iter g v = Iter.from_iter (fun k -> Graph_internal.iter_succ_e k g v)
let preds_iter g v = Iter.from_iter (fun k -> Graph_internal.iter_pred_e k g v)

(** {1 Query functions} *)

let function_of_block_exn bid g = Graph_internal.iter_pred_e
