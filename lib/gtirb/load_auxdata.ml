open Bincaml_util.Common
open Angstrom

(** Decoders for standard gtirb aux data sections
    {{:https://grammatech.github.io/gtirb/md__aux_data.html} AuxData}. See also:
    {{:https://grammatech.github.io/gtirb/python/_modules/gtirb/serialization.html#SetCodec}
     Python implementation}.

    Ported from
    {{:https://github.com/UQ-PAC/BASIL/blob/tv-rewrites/src/main/scala/gtirb/AuxDecoder.scala#L28-L28}
     BASIL implementation}. *)

module UUIDMap = Map.Make (UUID)
module UUIDSet = Set.Make (UUID)

module AuxDataTypes = struct
  let str =
    LE.any_int64 >>= fun len ->
    take_bigstring (Int64.to_int len) >>= Bigstringaf.to_string %> return

  let bool = any_int8 >>= function 0 -> return true | _ -> return false

  let repeat times r =
    Iter.int_range ~start:0 ~stop:(Int64.to_int times - 1)
    |> Iter.map (fun _ -> r)
    |> Iter.to_list

  let sequence value =
    let* len = LE.any_int64 >>= Int64.to_int %> return in
    count len value

  let uuid =
    count 16 any_char >>= fun s -> return (String.of_list s |> UUID.of_string)

  let pair a b =
    let* a = a in
    let* b = b in
    return (a, b)

  let map key value =
    let kv = pair key value in
    LE.any_int64 >>= fun i -> count (Int64.to_int i) kv

  let triple a b c =
    let* a = a in
    let* b = b in
    let* c = c in
    return (a, b, c)

  let quad a b c d =
    let* a = a in
    let* b = b in
    let* c = c in
    let* d = d in
    return (a, b, c, d)

  let quintuple a b c d e =
    let* a = a in
    let* b = b in
    let* c = c in
    let* d = d in
    let* e = e in
    return (a, b, c, d, e)

  let offset =
    let* uuid = uuid in
    let* len = LE.any_int64 in
    return (uuid, len)

  let uuid_set = sequence uuid >>= UUIDSet.of_list %> return
  let uuid_map v = map uuid v >>= UUIDMap.of_list %> return
end

open AuxDataTypes

type 'a aux_section = { name : string; decoder : 'a t }

let load a (ad : Gtirb_proto.AuxData.Gtirb.Proto.AuxData.t StringMap.t) =
  let open Result in
  let* d =
    StringMap.find_opt a.name ad
    |> Option.to_result ("could not find aux section: " ^ a.name)
  in
  let b = d.data |> Bytes.to_string in
  Angstrom.parse_string ~consume:All a.decoder b

module Loaders = struct
  let section_properties =
    let decoder = uuid_map (sequence (pair LE.any_int64 LE.any_int64)) in
    { name = "sectionProperties"; decoder } |> load

  (** The UUID of a gtrb::Symbol whose name field contains the name of the
      function.

      There may be more than one gtirb::Symbol associated with the address(es)
      corresponding to the entry point(s) of a function. This table identifies a
      canonical gtirb::Symbol to be used for each function. Note that there is
      no function notion in the core GTIRB IR. A function's UUID is just a
      unique identifier that is consistently used across all function-related
      AuxData tables. *)
  let function_names =
    let decoder = uuid_map uuid in
    { name = "functionNames"; decoder } |> load

  let symbol_forwarding =
    let decoder = uuid_map uuid in
    { name = "symbolForwarding"; decoder } |> load

  (** The CodeBlock to which a [DT_INIT] entry in an ELF file's .dynamic section
      refers *)
  let elf_dynamic_init = load { name = "elfDynamicInit"; decoder = uuid }

  (** The CodeBlock to which a [DT_FINI] entry in an ELF file's .dynamic section
      refers. *)
  let elf_dynamic_fini = load { name = "elfDynamicFini"; decoder = uuid }

  (** The string value which the [DT_SONAME] entry in an ELF file's .dynamic
      section contains. *)
  let elf_soname = load { name = "elfSoname"; decoder = str }

  (**Stack executable flag specified by [PT_GNU_STACK] segment in ELF files. *)
  let elf_stackexec = load { name = "elfStackExec"; decoder = bool }

  (**The size of the [PT_GNU_STACK] segment in ELF files, which may influence
     the runtime stack size in certain environments. *)
  let elf_stacksize = load { name = "elfStackSize"; decoder = LE.any_int64 }

  (** The set of UUIDs of all the blocks (gtirb::CodeBlock) in the function.

      This table identifies all of the gtirb::CodeBlocks that belong to each
      function. These do not necessarily have to be contiguous in the address
      space. Note that there is no function notion in the core GTIRB IR. A
      function's UUID is just a unique identifier that is consistently used
      across all function-related AuxData tables. *)
  let function_blocks =
    let decoder = uuid_map uuid_set in
    { name = "functionBlocks"; decoder } |> load

  (** The set of UUIDs of all the entry blocks (gtirb::CodeBlock) for the
      function.

      This table identifies all gtirb::CodeBlocks that represent entry points to
      each function. A single function may have more than one entry point. Note
      that there is no function notion in the core GTIRB IR. A function's UUID
      is just a unique identifier that is consistently used across all
      function-related AuxData tables. *)
  let function_entries =
    let decoder = uuid_map uuid_set in
    { name = "functionEntries"; decoder } |> load

  (** Maps the gtirb::UUID of a gtirb::DataBlock -> The type of the data,
      expressed as a std::string containing a C++ type specifier.

      An entry in this table indicates that the given gtirb::DataBlock contains
      content that exhibits the given C++ type. *)
  let types = load { name = "types"; decoder = uuid_map str }

  (** Maps the gtirb::UUID of a gtirb::CodeBlock, gtirb::DataBlock, or
      gtirb::Section -> Alignment requirements for the block/data
      object/section.

      An entry in this table indicates that the given object's address is
      required to be evenly divisible by the alignment value. Typically the
      alignment value is a power of 2. *)
  let alignment = load { name = "alignment"; decoder = uuid_map LE.any_int64 }

  (** The gtirb::Offset of a comment -> A comment string relevant to the
      specified offset in the specified GTIRB entry.

      The gtirb::Offset refers to the UUID of an entity in memory and a byte
      offset within that entity to indicate the point at which the comment
      applies. Comments can contain arbitrary content and are likely generated
      by analysis tools. They often do not (but may) represent comments present
      in the original source code of the binary. *)
  let comments =
    load { name = "comments"; decoder = sequence (pair offset str) }

  (** Padding here may be 0's or it may be valid instructions. An entry in this
      table indicates that an analysis has determined that at the given
      gtirb::Offset (UUID of an entity in memory and byte offset into that
      entity) and length of bytes indicated constitute content that is unused by
      the program and is only present to ensure alignment of neighboring
      objects. Note: some disassemblers may still create a gtirb::CodeBlock or
      gtirb::DataBlock for the same portion of address space that a padding
      entry covers. *)
  let padding =
    load { name = "padding"; decoder = sequence (pair offset LE.any_int64) }

  let elf_symbol_table_idx_info =
    {
      name = "elfSymbolTabIdxInfo";
      decoder = uuid_map (sequence (pair str LE.any_int64));
    }
    |> load

  (** On ELF targets only: Map from symbols to their type, binding, and
      visibility categories. *)
  let elf_symbol_info =
    {
      name = "elfSymbolInfo";
      decoder = uuid_map (quintuple LE.any_int64 str str str LE.any_int64);
    }
    |> load
end
