open Bincaml_util.Common
open Gtirb_proto
module OcamlResult = Result
open Ocaml_protoc_plugin
open IR.Gtirb.Proto
open ByteInterval.Gtirb.Proto
open Module.Gtirb.Proto
open Section.Gtirb.Proto
open CFG.Gtirb.Proto
open CodeBlock.Gtirb.Proto
module Result = OcamlResult

(* These could probably be simplified *)
(* OCaml representation of mid-evaluation code block  *)
type rectified_block = {
  ruuid : bytes;
  contents : bytes;
  opcodes : bytes list;
  address : int;
  size : int;
}
[@@deriving eq, ord, show { with_path = false }]

(* Wrapper for polymorphic code/data/not-set block pre-rectification  *)
type content_block = { block : Block.t; raw : bytes; address : int }

(* CONSTANTS  *)
let opcode_length = 4
let count_pos_args = ref 0

open struct
  (* ASL specifications are from the bundled ARM semantics in libASL. *)

  (* Protobuf spelunking  *)
  (*let text          = ".text"*)

  (* Byte & array manipulation convenience functions *)
  let _b_tl op n = Bytes.sub op n (Bytes.length op - n)
  let _b_hd op n = Bytes.sub op 0 n
  let b64_of_uuid uuid = Base64.encode_exn (Bytes.to_string uuid)

  let endian_reverse (opcode : bytes) : bytes =
    let len = Bytes.length opcode in
    let getrev i = Bytes.get opcode (len - 1 - i) in
    Bytes.init len getrev

  let do_block ~(need_flip : bool) ((b, c) : content_block * CodeBlock.t) :
      rectified_block =
    let cut_op contents i =
      let bytes = Bytes.sub contents (i * opcode_length) opcode_length in
      if need_flip then endian_reverse bytes else bytes
    in

    let size = c.size in
    let ruuid = c.uuid in
    let address = b.address in
    let num_opcodes = c.size / opcode_length in
    if size <> num_opcodes * opcode_length then
      Printf.eprintf
        "block size is not a multiple of opcode size (size %d): %s\n" size
        (b64_of_uuid ruuid);

    let contents = Bytes.sub b.raw b.block.offset size in
    let opcodes = List.init num_opcodes (cut_op contents) in

    { size; ruuid; contents; opcodes; address }

  module AD = Load_auxdata.Loaders

  module OCFG = struct
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
      let hash = Hash.poly

      let of_gtirb_label (label : EdgeLabel.t option) =
        match label with
        | None -> Nop
        | Some { conditional; direct; type' } -> (
            match type' with
            | EdgeType.Type_Branch ->
                Labeled { conditional; direct; typ = Type_Branch }
            | EdgeType.Type_Call ->
                Labeled { conditional; direct; typ = Type_Call }
            | EdgeType.Type_Fallthrough ->
                Labeled { conditional; direct; typ = Type_Fallthrough }
            | EdgeType.Type_Return ->
                Labeled { conditional; direct; typ = Type_Return }
            | EdgeType.Type_Syscall ->
                Labeled { conditional; direct; typ = Type_Syscall }
            | EdgeType.Type_Sysret ->
                Labeled { conditional; direct; typ = Type_Sysret })
    end

    module Vert = struct
      type t =
        | Internal of String.t  (** vertex in this procedure *)
        | External of String.t  (** vertex in another procedure *)
      [@@deriving eq, ord, show { with_path = false }]

      let hash = Hash.poly
    end

    module G = Graph.Persistent.Digraph.ConcreteLabeled (Vert) (Edge)
  end

  type temp_proc = {
    name : string;
    uuid : string; (* generic function UUID*)
    entries : StringSet.t; (* entry block uuids *)
    blocks : StringSet.t;
    code_blocks : rectified_block StringMap.t;
    cfg : OCFG.G.t;
  }

  let get_code_block_opcodes (m : Module.t) =
    let all_sects = m.sections in
    let intervals =
      List.flatten
      @@ List.map (fun (s : Section.t) -> s.byte_intervals) all_sects
    in

    let content_block (i : ByteInterval.t) (b : Block.t) : content_block =
      { block = b; raw = i.contents; address = i.address + b.offset }
    in

    let ival_blks : content_block list =
      List.flatten
      @@ List.map
           (fun i -> List.map (fun b -> content_block i b) i.blocks)
           intervals
    in

    let extract_code (b : content_block) =
      match b.block.value with
      | `Code (c : CodeBlock.t) -> Some (b, c)
      | _ -> None
    in
    let code_blocks = List.filter_map extract_code ival_blks in

    let need_flip =
      m.byte_order |> function ByteOrder.LittleEndian -> true | _ -> false
    in
    let rblocks = List.map (do_block ~need_flip) code_blocks in
    rblocks

  let load_gtirb infile =
    let bytes =
      let ic = open_in_bin infile in
      let len = in_channel_length ic in
      let magic = really_input_string ic 8 in
      let res = really_input_string ic (len - 8) in
      (* check for gtirb magic otherwise assume is raw protobuf *)
      let res =
        if String.starts_with ~prefix:"GTIRB" magic then res else magic ^ res
      in
      close_in ic;
      res
    in

    (* Pull out interesting code bits *)
    let gtirb =
      let raw = Reader.create bytes in
      IR.from_proto raw
    in

    let ir =
      match gtirb with
      | Ok a -> a
      | Error e ->
          failwith
            (Printf.sprintf "%s%s" "Could not reply request: "
               (Ocaml_protoc_plugin.Result.show_error e))
    in
    ir

  let cfg (c : CFG.t) (m : Module.t) =
    let blocks = get_code_block_opcodes m in
    let all_blocks =
      List.map (fun b -> (b.ruuid |> Bytes.to_string, b)) blocks
      |> StringMap.of_list
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
    let func_names = AD.function_names auxdata |> or_error StringMap.empty in
    let func_blocks = AD.function_blocks auxdata |> or_error StringMap.empty in
    let block_functions =
      func_blocks |> StringMap.to_iter
      |> Iter.flat_map (fun (func, blocks) ->
          StringSet.to_iter blocks |> Iter.map (fun b -> (b, func)))
      |> StringMap.of_iter
    in
    let block_member_of ~proc block =
      Option.(
        StringMap.get block block_functions
        >|= (fun b -> String.equal b proc)
        |> get_or ~default:false)
    in
    let func_entry_blocks =
      AD.function_entries auxdata |> or_error StringMap.empty
    in
    let make_temp_proc uuid name =
      let entries =
        StringMap.get uuid func_entry_blocks |> function
        | Some b -> b
        | None ->
            Logs.warn (fun m -> m "No entry blocks for proc: %s %s" uuid name);
            StringSet.empty
      in
      let blocks, code_blocks =
        StringMap.get uuid func_blocks |> function
        | Some b ->
            ( b,
              StringSet.to_iter b
              |> Iter.filter_map (fun id ->
                  StringMap.get id all_blocks |> fun a ->
                  Option.bind a (fun b -> Some (id, b)))
              |> StringMap.of_iter )
        | None ->
            Logs.warn (fun m -> m "No entry blocks for proc: %s %s" uuid name);
            (StringSet.empty, StringMap.empty)
      in
      { uuid; name; entries; blocks; code_blocks; cfg = OCFG.G.empty }
    in
    let procs = StringMap.mapi make_temp_proc func_names in
    let make_cfg (p : temp_proc) =
      let open CFG in
      let open Edge in
      let conv_vert e =
        if block_member_of ~proc:p.uuid e then OCFG.Vert.Internal e
        else External e
      in
      let edges =
        c.edges
        |> List.filter (fun { source_uuid; _ } ->
            block_member_of ~proc:p.uuid (source_uuid |> Bytes.to_string))
        |> List.map (fun { source_uuid; label; target_uuid } ->
            ( conv_vert @@ Bytes.to_string source_uuid,
              OCFG.Edge.of_gtirb_label label,
              conv_vert @@ Bytes.to_string target_uuid ))
      in
      let cfg =
        List.fold_left (fun cfg e -> OCFG.G.add_edge_e cfg e) p.cfg edges
      in
      { p with cfg }
    in
    let procs = StringMap.map make_cfg procs in
    procs
end

let load_gtirb filename = load_gtirb filename
