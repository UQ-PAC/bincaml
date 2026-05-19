open Bincaml_util.Common
open Gtirb_proto
module OcamlResult = Result
open Ocaml_protoc_plugin
open IR.Gtirb.Proto
open ByteInterval.Gtirb.Proto
open Module.Gtirb.Proto
open Section.Gtirb.Proto
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

  let do_module (m : Module.t) =
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

    (* Resolve polymorphic block variants to filter only code blocks *)
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

  let gtirb_to_gts infile =
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

    let modules' = List.map do_module ir.modules in
    modules'
end

let load_gtirb filename = gtirb_to_gts filename
