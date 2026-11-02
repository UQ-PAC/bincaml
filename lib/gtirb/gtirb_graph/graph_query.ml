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

let succs_iter g v =
  Iter.from_iter (fun k -> Graph_internal.iter_succ_e k g v)
  |> Iter.map (fun (_, e, v) -> (e, v))

let preds_iter g v =
  Iter.from_iter (fun k -> Graph_internal.iter_pred_e k g v)
  |> Iter.map (fun (v, e, _) -> (v, e))

(** {1 Query functions} *)

(** Returns the value of the {!Iter.t}, if it has exactly one value, or [None]
    if it has no values. If it has more than one value, raises an exception with
    the given message. *)
let one_or_none ?(msgf = Fun.const "expected at most one item in Iter")
    (it : 'a Iter.t) =
  let cell = ref None in
  let f x =
    match !cell with None -> cell := Some x | Some _ -> failwith (msgf ())
  in
  it f;
  !cell

(** Returns the unique value of the {!Iter.t}, if it has exactly one value.
    Otherwise, raises an exception with the given message. *)
let singular ?(msgf = Fun.const "expected exactly one item in Iter")
    (it : 'a Iter.t) =
  match one_or_none ~msgf it with None -> failwith (msgf ()) | Some x -> x

let err_of_vertex msg v () =
  Printf.sprintf "unexpected cardinality in %s of %s" msg
    (Graph_types.show_vert v)

let control_flow_edges g =
  to_edges_iter g
  |> Iter.filter_map (function
    | (_, Graph_types.Control_flow (a, b), _) as e -> Some (e, (a, b))
    | _ -> None)

(** Gets the (unique) function vertex which contains the given block vertex, or
    [None] if the block is a proxy block. *)
let function_of_block g v =
  preds_iter g v
  |> Iter.filter_map (function
    | func, Function_has_block -> Some (Some func)
    | _, Self (Block_data `Proxy) -> Some None
    | _ -> None)
  |> singular ~msgf:(err_of_vertex "function_of_block" v)

(** Gets the symbol vertex which is the name of the given function vertex. *)
let function_name g v =
  succs_iter g v
  |> Iter.filter_map (function
    | Function_has_name, name -> Some name
    | _ -> None)
  |> singular ~msgf:(err_of_vertex "function_name" v)

(** Gets the symbol vertex which is forwarding {i target} of the given symbol
    vertex. *)
let symbol_forwarded_to g v =
  succs_iter g v
  |> Iter.filter_map (function
    | Symbol_is_forwarded_to, sym -> Some sym
    | _ -> None)
  |> one_or_none ~msgf:(err_of_vertex "symbol_forwarded_to" v)

(** Gets the self data associated with this vertex. *)
let self_data g v =
  succs_iter g v
  |> Iter.filter_map (function Self data, _ -> Some data | _ -> None)
  |> singular ~msgf:(err_of_vertex "self_data" v)
