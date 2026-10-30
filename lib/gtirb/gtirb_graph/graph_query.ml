(** High-level functions for working with {!Gtirb_graph.t}. *)

open Graph_types

let of_edges_iter it =
  let g = Graph_internal.create () in
  it |> Iter.iter (Graph_internal.add_edge_e g);
  g

let replace_edge_e g (old_edge : Graph_internal.edge)
    (new_edge : Graph_internal.edge) =
  Graph_internal.remove_edge_e g old_edge;
  Graph_internal.add_edge_e g new_edge;
  g

(** {1 {!Iter.t} iterators for the graph} *)

let to_vertex_iter g = Iter.from_iter (Fun.flip Graph_internal.iter_vertex g)
let to_edges_iter g = Iter.from_iter (Fun.flip Graph_internal.iter_edges_e g)
let succs_iter g v = Iter.from_iter (fun k -> Graph_internal.iter_succ_e k g v)
let preds_iter g v = Iter.from_iter (fun k -> Graph_internal.iter_pred_e k g v)

(** {1 Query functions} *)

(** Returns the unique value of the {!Iter.t}, if it has exactly one value.
    Otherwise, raises an exception with the given message. *)
let singular ?(msg = "expected exactly one item in Iter") (it : 'a Iter.t) =
  let cell = ref None in
  let f x =
    match !cell with None -> cell := Some x | Some _ -> failwith msg
  in
  it f;
  match !cell with None -> failwith msg | Some x -> x

(** Gets the (unique) function UUID which contains the given block UUID, or
    [None] if the block is a proxy block. *)
let function_of_block_exn g v =
  preds_iter g v
  |> Iter.filter_map (function
    | func, Function_has_block, _ -> Some (Some func)
    | _, Self (Block_data `Proxy), _ -> Some None
    | _ -> None)
  |> singular
