open Bincaml_util.Common
open Gtirb_proto
module OcamlResult = Result
open Ocaml_protoc_plugin
open IR.Gtirb.Proto
open ByteInterval.Gtirb.Proto
open Module.Gtirb.Proto
open Section.Gtirb.Proto
open CFG.Gtirb.Proto
module Result = OcamlResult
open Load_auxdata
module UUIDMap = UUIDMap
module UUIDSet = UUIDSet
module AD = Load_auxdata.Loaders
open Conf

(** {2 GTIRB Frontend Intermediate Representation} *)

(** edges just copied directly from gtirb protobuf CFG *)
module Edge = struct
  type edge_type =
    | Type_Branch
    | Type_Fallthrough
    | Type_Call
    | Type_Return
    | Type_Syscall
    | Type_Sysret
  [@@deriving eq, ord, show { with_path = false }]

  type t =
    | Labeled of { conditional : bool; direct : bool; typ : edge_type }
    | Nop
  [@@deriving eq, ord, show { with_path = false }]

  let default = Nop

  let of_gtirb_label (label : EdgeLabel.t option) =
    match label with
    | None -> Nop
    | Some { conditional; direct; type' } -> (
        match type' with
        | EdgeType.Type_Branch ->
            Labeled { conditional; direct; typ = Type_Branch }
        | EdgeType.Type_Call -> Labeled { conditional; direct; typ = Type_Call }
        | EdgeType.Type_Fallthrough ->
            Labeled { conditional; direct; typ = Type_Fallthrough }
        | EdgeType.Type_Return ->
            Labeled { conditional; direct; typ = Type_Return }
        | EdgeType.Type_Syscall ->
            Labeled { conditional; direct; typ = Type_Syscall }
        | EdgeType.Type_Sysret ->
            Labeled { conditional; direct; typ = Type_Sysret })
end

(** Vertices are block uuids internal to a procedure, external to the procedure
    (e.g. call and return targets), or stmt sequences with optional uuid (they
    are used to replace an external vertices with code)

    Note that here in contrast to bincaml vertices reprsent code and egdes
    represent jumps. *)
module Vert = struct
  type t =
    | Internal of UUID.t  (** vertex in this procedure *)
    | External of UUID.t  (** vertex in another procedure *)
    | Stmts of { uuid : UUID.t option; stmts : Lang.Program.stmt list }
  [@@deriving eq, ord, show { with_path = false }]

  let hash = Hash.poly
end

module G = Graph.Persistent.Digraph.ConcreteLabeled (Vert) (Edge)
(** OCamlgraph control-flow graph *)

module D = Graph.Graphviz.Dot (struct
  include G

  let edge_attributes (_, e, _) =
    let n =
      Containers_pp.Pretty.to_string ~width:50
        (Containers_pp.text @@ Edge.show e)
    in
    [ `Label n ]

  let default_edge_attributes _ = []
  let get_subgraph _ = None
  let default_vertex_attributes _ = []
  let graph_attributes _ = []

  let vertex_name (v : Vert.t) =
    ("v"
    ^
    match v with
    | Stmts { uuid = Some uuid } -> "stmts:" ^ UUID.show uuid
    | Stmts { stmts } -> "stmts:" ^ Int.to_string @@ Hashtbl.hash stmts
    | Internal e -> UUID.show e
    | External e -> "External" ^ UUID.show e)
    |> String.replace ~sub:"/" ~by:"_"
    |> String.replace ~sub:"+" ~by:"__"

  let vertex_attributes v =
    let n =
      match v with
      | Vert.Internal n -> UUID.show n
      | External e -> "External:" ^ UUID.show e
      | Stmts { uuid; stmts } ->
          (Option.to_iter uuid |> Iter.to_string UUID.show)
          ^ "\\r"
          ^ List.to_string ~sep:"\\r" Lang.Program.show_stmt stmts
    in
    [ `Fontname "Mono"; `Label n ]
end)

type block = Gtirb.block [@@deriving eq, ord, show { with_path = false }]
(** code/data block with absolute address *)

type temp_proc = {
  name : string;
  id : ID.t;
  uuid : UUID.t; (* generic function UUID*)
  entries : UUIDSet.t; (* entry block uuids *)
  blocks : UUIDSet.t; (* UUIDs of blocks internal to this procedure *)
  code_blocks : Gtirb.block UUIDMap.t;  (** block definitions *)
  cfg : G.t;
}
(** Gfir procedure; basic blocks containing sequences of opcodes or statemetns
*)

let endian_reverse (opcode : string) : string =
  let len = String.length opcode in
  let getrev i = String.get opcode (len - 1 - i) in
  String.init len getrev

(** Load a prodobuf gtirb module into a set of temp_procs *)
let gtirb_to_cfg prog (c : CFG.t) (m : Module.t) =
  let blocks = Gtirb.get_code_block_opcodes m in

  let sym =
    m.symbols
    |> List.map (fun (s : Symbol.Gtirb.Proto.Symbol.t) ->
        (UUID.of_bytes s.uuid, s.name))
    |> UUIDMap.of_list
  in
  let all_blocks =
    List.map (fun (b : Gtirb.block) -> (b.uuid, b)) blocks |> UUIDMap.of_list
  in
  let auxdata =
    m.aux_data |> StringMap.of_list |> StringMap.filter_map (fun _ v -> v)
  in
  let or_error default = function
    | Ok e -> e
    | Error msg ->
        Logs.warn (fun m -> m "load:gtirb %s" msg);
        default
  in
  let func_names =
    AD.function_names auxdata |> or_error UUIDMap.empty
    |> UUIDMap.filter_map (fun _ u -> UUIDMap.find_opt u sym)
  in
  let func_blocks = AD.function_blocks auxdata |> or_error UUIDMap.empty in
  let block_functions =
    func_blocks |> UUIDMap.to_iter
    |> Iter.flat_map (fun (func, blocks) ->
        UUIDSet.to_iter blocks |> Iter.map (fun b -> (b, func)))
    |> UUIDMap.of_iter
  in
  let block_member_of ~proc block =
    Option.(
      UUIDMap.get block block_functions
      >|= (fun b -> UUID.equal b proc)
      |> get_or ~default:false)
  in
  let func_entry_blocks =
    AD.function_entries auxdata |> or_error UUIDMap.empty
  in
  let make_temp_proc uuid (name : string) =
    let entries =
      UUIDMap.get uuid func_entry_blocks |> function
      | Some b -> b
      | None ->
          Logs.warn (fun m ->
              m "No entry blocks for proc: %s %s" (UUID.show uuid) name);
          UUIDSet.empty
    in
    let blocks, code_blocks =
      UUIDMap.get uuid func_blocks |> function
      | Some b ->
          ( b,
            UUIDSet.to_iter b
            |> Iter.filter_map (fun id ->
                UUIDMap.get id all_blocks |> fun a ->
                Option.bind a (fun b -> Some (id, b)))
            |> UUIDMap.of_iter )
      | None ->
          Logs.warn (fun m ->
              m "No entry blocks for proc: %s %s" (UUID.show uuid) name);
          (UUIDSet.empty, UUIDMap.empty)
    in
    let id = Lang.Program.declare_name ("@" ^ name) prog in
    { uuid; name; id; entries; blocks; code_blocks; cfg = G.empty }
  in
  let procs = UUIDMap.mapi make_temp_proc func_names in
  let make_cfg (p : temp_proc) =
    let conv_vert e =
      if block_member_of ~proc:p.uuid e then Vert.Internal e else External e
    in
    let module E = Edge in
    let edges =
      Gtirb_proto.CFG.Gtirb.Proto.Edge.(
        c.edges
        |> List.filter (fun { source_uuid; _ } ->
            block_member_of ~proc:p.uuid (UUID.of_bytes source_uuid))
        |> List.map (fun { source_uuid; label; target_uuid } ->
            ( conv_vert @@ UUID.of_bytes source_uuid,
              E.of_gtirb_label label,
              conv_vert @@ UUID.of_bytes target_uuid )))
    in
    let cfg = List.fold_left (fun cfg e -> G.add_edge_e cfg e) p.cfg edges in
    { p with cfg }
  in
  let procs = UUIDMap.map make_cfg procs in
  procs
