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
open Conf

(** code/data block with absolute address *)
type block =
  | Proxy of UUID.t
  | Data of { uuid : UUID.t; contents : string; address : int; size : int }
  | Code of {
      uuid : UUID.t;
      contents : string;
      address : int;
      size : int;
      opcodes : string list;
    }
[@@deriving eq, ord, show { with_path = false }]

let address = function
  | Proxy uuid -> None
  | Data { address } -> Some address
  | Code { address } -> Some address

let uuid = function
  | Proxy uuid -> uuid
  | Data { uuid } -> uuid
  | Code { uuid } -> uuid

type content_block = { block : Block.t; raw : bytes; address : int }
(** Code/data/empty block of raw bytes, with absolute address *)

let endian_reverse (opcode : string) : string =
  let len = String.length opcode in
  let getrev i = String.get opcode (len - 1 - i) in
  String.init len getrev

let chop_block_opcodes ~(need_flip : bool) block : block option =
  let open Option in
  let contents size () =
    if Bytes.length block.raw = 0 then String.empty
    else (
      Logs.debug (fun m -> m "%d : %d" (Bytes.length block.raw) size);
      String.of_bytes @@ Bytes.sub block.raw block.block.offset size)
  in
  (* all blocks that have uuid defined  *)
  let* uuid, size, opcodes, contents =
    match block.block.value with
    | `Code b -> (
        match b.decode_mode with
        | ARM_Thumb ->
            Logs.warn (fun m -> m "ARM thumb not supported");
            Some (UUID.of_bytes b.uuid, b.size, None, contents b.size ())
        | All_Default ->
            Some
              ( UUID.of_bytes b.uuid,
                b.size,
                Some conf.opcode_length,
                contents b.size () ))
    | `Data b -> Some (UUID.of_bytes b.uuid, b.size, None, contents b.size ())
    | `not_set -> None
  in

  let address = block.address in
  let opcodes =
    let* opcode_length = opcodes in

    let cut_op contents i =
      let bytes = String.sub contents (i * opcode_length) opcode_length in
      if need_flip then endian_reverse bytes else bytes
    in
    let num_opcodes = size / opcode_length in
    if size <> num_opcodes * opcode_length then
      Logs.err (fun m ->
          m "block size is not a multiple of opcode size (size %d): %s\n" size
            (UUID.show uuid));

    let opcodes = List.init num_opcodes (cut_op contents) in
    Some opcodes
  in

  match opcodes with
  | Some opcodes -> Some (Code { size; uuid; contents; opcodes; address })
  | None -> Some (Data { size; uuid; contents; address })

(* convert code blocks in module into blocks containing opcode sequences *)
let get_code_block_opcodes (m : Module.t) =
  let all_sects = m.sections in
  let intervals =
    List.flatten @@ List.map (fun (s : Section.t) -> s.byte_intervals) all_sects
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

  let need_flip =
    m.byte_order |> function ByteOrder.LittleEndian -> true | _ -> false
  in
  let rblocks = List.filter_map (chop_block_opcodes ~need_flip) ival_blks in
  rblocks

let of_channel ic =
  let bytes =
    let magic = really_input_string ic 8 in
    let res = CCIO.read_all_bytes ic |> Bytes.unsafe_to_string in
    (* check for gtirb magic otherwise assume is raw protobuf *)
    let res =
      if String.starts_with ~prefix:"GTIRB" magic then res else magic ^ res
    in
    res
  in

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


let of_file fname =
  let c = open_in_bin fname in
  let r = of_channel c in
  close_in c;
  r
