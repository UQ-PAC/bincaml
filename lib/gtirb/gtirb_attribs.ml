open Bincaml_util.Common

type offset_sym = { name : string; offset : int64 }
type sized_sym = { name : string; address : int64; size : int64 }

let offset_sym_to_attrib { name; offset } : Lang.Attrib.t =
  let offset = `Integer (Z.of_int64 offset) in
  `Assoc (StringMap.singleton name offset)

(** [.symbols] attribute and its sub-attributes. *)
type symbols =
  | Symbols of {
      external_functions : offset_sym list;
      globals : sized_sym list;
      func_entries : sized_sym list;
      global_offsets : offset_sym list;
    }

type section =
  | Section of {
      name : string;
      address : int64;
      size : int64;
      read_only : bool;
      bytes : string;
    }

type gtirb_attribs = { symbols : symbols; initial_memory : section list }

let symbols_to_attrib (syms : Gtirb_proto.Symbol.Gtirb.Proto.Symbol.t list) :
    Lang.Attrib.t =
  `List
    (syms
    |> List.map (fun { Gtirb_proto.Symbol.Gtirb.Proto.Symbol.name } ->
        { name; offset = 0L }) (* TODO: fix offset by getting referent block *)
    |> List.map offset_sym_to_attrib)

let sections_to_attrib (secs : Gtirb_proto.Section.Gtirb.Proto.Section.t list) :
    Lang.Attrib.t =
  `List []

let module_to_attrib (m : Gtirb_proto.Module.Gtirb.Proto.Module.t) :
    Lang.Attrib.t =
  `Assoc
    (StringMap.of_list
       [
         (".symbols", symbols_to_attrib m.symbols);
         (".initial_memory", sections_to_attrib m.sections);
       ])
