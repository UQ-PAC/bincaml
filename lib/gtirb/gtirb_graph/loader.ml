(** Loads information from a GTIRB IR into the *)

open Bincaml_util.Common

open struct
  module UUIDMap = Load_auxdata.UUIDMap
  module UUIDSet = Load_auxdata.UUIDSet
end

let edges_of_function_entries auxdata =
  let function_entries =
    Load_auxdata.Loaders.function_entries auxdata
    |> Result.to_option
    |> Option.get_exn_or "function_entries auxdata invalid"
  in
  UUIDMap.to_iter function_entries
  |> Iter.flat_map (fun (func, entries) ->
      UUIDSet.to_iter entries |> Iter.map (Pair.make func))
  |> Iter.map (Graph.make_uuid_rel Function_has_entry)

let edges_of_function_names auxdata =
  let function_names =
    Load_auxdata.Loaders.function_names auxdata
    |> Result.to_option
    |> Option.get_exn_or "function_names auxdata invalid"
  in
  UUIDMap.to_iter function_names
  |> Iter.map (Graph.make_uuid_rel Function_has_name)

let edges_of_symbol_forwarding auxdata =
  let symbol_forwarding =
    Load_auxdata.Loaders.symbol_forwarding auxdata
    |> Result.to_option
    |> Option.get_exn_or "symbol_forwarding auxdata invalid"
  in
  UUIDMap.to_iter symbol_forwarding
  |> Iter.map (Graph.make_uuid_rel Symbol_is_forwarded_to)

let edges_of_symbol_list (syms : Gtirb_proto.Symbol.Gtirb.Proto.Symbol.t list) =
  let module Symbol = Gtirb_proto.Symbol.Gtirb.Proto.Symbol in
  let referents =
    List.to_iter syms
    |> Iter.filter_map (function
      | { Symbol.uuid; optional_payload = `Referent_uuid referent; _ } ->
          Some
            (Graph.make_uuid_rel Symbol_refers_to
               UUID.(of_bytes uuid, of_bytes referent))
      | _ -> None)
  and datas =
    List.to_iter syms
    |> Iter.map (function { Symbol.uuid; optional_payload; name; at_end } ->
        let int_value =
          match optional_payload with `Value i -> Some i | _ -> None
        in
        Graph.make_self_rel
          (Symbol_data { name; at_end; int_value })
          (UUID.of_bytes uuid))
  in
  Iter.append datas referents

let graph_of_module (m : Gtirb_proto.Module.Gtirb.Proto.Module.t) =
  let g = Graph.create () in

  let auxdata =
    m.aux_data
    |> List.filter_map (function k, Some v -> Some (k, v) | _ -> None)
    |> StringMap.of_list
  in

  edges_of_function_entries auxdata |> Iter.iter (Graph.add_edge_e g);
  edges_of_function_names auxdata |> Iter.iter (Graph.add_edge_e g);
  edges_of_symbol_forwarding auxdata |> Iter.iter (Graph.add_edge_e g);
  edges_of_symbol_list m.symbols |> Iter.iter (Graph.add_edge_e g);
  g
