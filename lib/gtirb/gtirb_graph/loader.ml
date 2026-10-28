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

let graph_of_module (m : Gtirb_proto.Module.Gtirb.Proto.Module.t) =
  let g = Graph.create () in

  let auxdata =
    m.aux_data
    |> List.filter_map (function k, Some v -> Some (k, v) | _ -> None)
    |> StringMap.of_list
  in

  edges_of_function_entries auxdata |> Iter.iter (Graph.add_edge_e g);
  edges_of_function_names auxdata |> Iter.iter (Graph.add_edge_e g);
  g
