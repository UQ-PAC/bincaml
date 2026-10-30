(** Loads information from a GTIRB IR into the graph. *)

open Bincaml_util.Common

open struct
  module UUIDMap = Load_auxdata.UUIDMap
  module UUIDSet = Load_auxdata.UUIDSet

  (** Local module alias for shortening module namespace paths. *)
  module Gtirb_proto' = struct
    module Symbol = Gtirb_proto.Symbol.Gtirb.Proto.Symbol
    module Module = Gtirb_proto.Module.Gtirb.Proto.Module
    module Section = Gtirb_proto.Section.Gtirb.Proto.Section
    module ByteInterval = Gtirb_proto.ByteInterval.Gtirb.Proto.ByteInterval
    module Block = Gtirb_proto.ByteInterval.Gtirb.Proto.Block
    module CFG = Gtirb_proto.CFG.Gtirb.Proto.CFG
  end
end

(** {2 Helper functions} *)

(** Helper function for generating graph edges from an auxdata field of type
    [std::map<gtirb::UUID, std::set<gtirb::UUID>>] (that is, a {!UUIDSet.t}
    {!UUIDMap.t} in ocaml). *)
let edges_of_uuid_multimap auxdata_scheme rel_kind auxdata =
  Load_auxdata.load_exn auxdata_scheme auxdata
  |> UUIDMap.to_iter
  |> Iter.flat_map (fun (k, vs) -> UUIDSet.to_iter vs |> Iter.map (Pair.make k))
  |> Iter.map (Graph_types.make_uuid_rel rel_kind)

(** {2 Function information} *)

let edges_of_function_entries =
  edges_of_uuid_multimap Load_auxdata.Loaders.function_entries
    Function_has_entry

let edges_of_function_blocks =
  edges_of_uuid_multimap Load_auxdata.Loaders.function_blocks Function_has_block

let edges_of_function_names auxdata =
  let function_names = Load_auxdata.(load_exn Loaders.function_names) auxdata in
  UUIDMap.to_iter function_names
  |> Iter.flat_map (fun pair ->
      Iter.doubleton
        (Graph_types.make_uuid_rel Function_has_name pair)
        (Graph_types.make_self_rel (Function_data ()) (fst pair)))

let edges_of_symbol_forwarding auxdata =
  let symbol_forwarding =
    Load_auxdata.(load_exn Loaders.symbol_forwarding) auxdata
  in
  UUIDMap.to_iter symbol_forwarding
  |> Iter.map (Graph_types.make_uuid_rel Symbol_is_forwarded_to)

(** {2 Symbol information} *)

let edges_of_symbol_list (syms : Gtirb_proto'.Symbol.t list) =
  let referents =
    List.to_iter syms
    |> Iter.filter_map (function
      | {
          Gtirb_proto'.Symbol.uuid;
          optional_payload = `Referent_uuid referent;
          _;
        } ->
          Some
            (Graph_types.make_uuid_rel Symbol_refers_to
               UUID.(of_bytes uuid, of_bytes referent))
      | _ -> None)
  and datas =
    List.to_iter syms
    |> Iter.map (function
        | { Gtirb_proto'.Symbol.uuid; optional_payload; name; at_end } ->
        let int_value =
          match optional_payload with `Value i -> Some i | _ -> None
        in
        Graph_types.make_self_rel
          (Symbol_data { name; at_end; int_value })
          (UUID.of_bytes uuid))
  in
  Iter.append datas referents

(** {2 Section and block information} *)

let edges_of_concrete_blocks (bs : Gtirb_proto'.Block.t Iter.t) =
  bs
  |> Iter.filter_map (function { Gtirb_proto'.Block.value } ->
      (match value with
      | `not_set -> None
      | `Code { uuid; size; decode_mode } ->
          Some (uuid, `Code (size, decode_mode))
      | `Data { uuid; size } -> Some (uuid, `Data size)))
  |> Iter.map (fun (uuid, data) ->
      Graph_types.make_self_rel (Block_data data) (UUID.of_bytes uuid))

let edges_of_proxy_blocks (uuids : bytes list) =
  uuids |> List.to_iter
  |> Iter.map (fun uuid ->
      Graph_types.make_self_rel (Block_data `Proxy) (UUID.of_bytes uuid))

(** {2 Entry point} *)

let graph_of_module (m : Gtirb_proto'.Module.t) =
  let g = Graph_internal.create () in

  let auxdata =
    m.aux_data
    |> List.filter_map (function k, Some v -> Some (k, v) | _ -> None)
    |> StringMap.of_list
  in

  edges_of_function_entries auxdata |> Iter.iter (Graph_internal.add_edge_e g);
  edges_of_function_names auxdata |> Iter.iter (Graph_internal.add_edge_e g);
  edges_of_function_blocks auxdata |> Iter.iter (Graph_internal.add_edge_e g);
  edges_of_symbol_forwarding auxdata |> Iter.iter (Graph_internal.add_edge_e g);
  edges_of_symbol_list m.symbols |> Iter.iter (Graph_internal.add_edge_e g);
  edges_of_proxy_blocks m.proxies |> Iter.iter (Graph_internal.add_edge_e g);

  (* TODO: do sections and byteintervals too *)
  let open Gtirb_proto' in
  List.to_iter m.Module.sections
  |> Iter.flat_map_l (fun s -> s.Section.byte_intervals)
  |> Iter.flat_map_l (fun bi -> bi.ByteInterval.blocks)
  |> edges_of_concrete_blocks
  |> Iter.iter (Graph_internal.add_edge_e g);

  g
