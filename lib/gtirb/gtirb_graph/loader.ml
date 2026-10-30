(** Loads information from a GTIRB IR into the graph. *)

open Bincaml_util.Common

open struct
  module UUIDMap = Load_auxdata.UUIDMap
  module UUIDSet = Load_auxdata.UUIDSet

  (** Local module alias for shortening module namespace paths. *)
  module Gtirb_proto' = struct
    module IR = Gtirb_proto.IR.Gtirb.Proto.IR
    module Symbol = Gtirb_proto.Symbol.Gtirb.Proto.Symbol
    module Module = Gtirb_proto.Module.Gtirb.Proto.Module
    module Section = Gtirb_proto.Section.Gtirb.Proto.Section
    module ByteInterval = Gtirb_proto.ByteInterval.Gtirb.Proto.ByteInterval
    module Block = Gtirb_proto.ByteInterval.Gtirb.Proto.Block
    module CFG = Gtirb_proto.CFG.Gtirb.Proto.CFG
    module Edge = Gtirb_proto.CFG.Gtirb.Proto.Edge
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
        (Graph_types.make_self_uuid_rel (Function_data ()) (fst pair)))

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
          Some Graph_types.(make_rel Symbol_refers_to (v uuid, v referent))
      | _ -> None)
  and datas =
    List.to_iter syms
    |> Iter.map (function
        | { Gtirb_proto'.Symbol.uuid; optional_payload; name; at_end } ->
        let int_value =
          match optional_payload with `Value i -> Some i | _ -> None
        in
        Graph_types.(
          make_self_rel (Symbol_data { name; at_end; int_value }) (v uuid)))
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
      Graph_types.(make_self_rel (Block_data data) (v uuid)))

let edges_of_proxy_blocks (uuids : bytes list) =
  uuids |> List.to_iter
  |> Iter.map (fun uuid ->
      Graph_types.(make_self_rel (Block_data `Proxy) (v uuid)))

(** {2 Control-flow graph information} *)

let edges_of_ipcfg (cfg : Gtirb_proto'.CFG.t) =
  List.to_iter cfg.edges
  |> Iter.filter_map (function
    | { Gtirb_proto'.Edge.source_uuid; target_uuid; label = None } -> None
    | { source_uuid; target_uuid; label = Some label } ->
        let src, tgt = Graph_types.(v source_uuid, v target_uuid) in
        Some (Graph_types.make_rel (Control_flow (`In_proc, label)) (src, tgt)))

(** Correct the inter-/intra-procedural labels on {!Graph_types.Control_flow}
    edges. This has to query other parts of the graph, so has to run as a
    post-process. *)
let fixup_ipcfg_edges g =
  Graph_query.to_edges_iter g
  |> Iter.filter_map (function
    | (src, Graph_types.Control_flow (_, label), tgt) as e ->
        Some (e, label, (src, tgt))
    | _ -> None)
  |> Iter.persistent
  |> Iter.fold
       (fun g (old_edge, label, (src, tgt)) ->
         let src_fun, tgt_fun =
           Graph_query.(function_of_block_exn g src, function_of_block_exn g tgt)
         in
         let flow_kind =
           if Graph_types.equal_vert src_fun tgt_fun then `In_proc
           else `Out_of_proc
         in
         Graph_query.replace_edge_e g old_edge
           (src, Control_flow (flow_kind, label), tgt))
       g

(** {2 Entry point} *)

let edges_of_module (m : Gtirb_proto'.Module.t) =
  let auxdata =
    m.aux_data
    |> List.filter_map (function k, Some v -> Some (k, v) | _ -> None)
    |> StringMap.of_list
  in

  (* TODO: do sections and byteintervals too *)
  let concrete_block_edges =
    let open Gtirb_proto' in
    List.to_iter m.Module.sections
    |> Iter.flat_map_l (fun s -> s.Section.byte_intervals)
    |> Iter.flat_map_l (fun bi -> bi.ByteInterval.blocks)
    |> edges_of_concrete_blocks
  in

  Iter.append_l
    [
      concrete_block_edges;
      edges_of_function_entries auxdata;
      edges_of_function_names auxdata;
      edges_of_function_blocks auxdata;
      edges_of_symbol_forwarding auxdata;
      edges_of_symbol_list m.symbols;
      edges_of_proxy_blocks m.proxies;
    ]

let edges_of_gtirb_ir (ir : Gtirb_proto'.IR.t) =
  Iter.append_l
    [
      Option.to_iter ir.cfg |> Iter.flat_map edges_of_ipcfg;
      List.to_iter ir.modules |> Iter.flat_map edges_of_module;
    ]

let graph_of_gtirb_ir ir =
  Graph_query.of_edges_iter (edges_of_gtirb_ir ir) |> fixup_ipcfg_edges
