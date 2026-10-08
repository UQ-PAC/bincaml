(** Well-known attributes attached to IL files loaded from GTIRB. *)

open Bincaml_util.Common

(** {2 Symbol types} *)

type offset_sym = { name : string; offset : int64 }
[@@deriving show, protocol ~driver:(module Lang.Attrib_conv)]

type sized_sym = { name : string; address : int64; size : int64 }
[@@deriving show, protocol ~driver:(module Lang.Attrib_conv)]

type symbols = {
  external_functions : offset_sym list; [@default []]
  globals : sized_sym list; [@default []]
  func_entries : sized_sym list; [@default []]
  global_offsets : offset_sym list; [@default []]
}
[@@deriving show, protocol ~driver:(module Lang.Attrib_conv)]
(** [.symbols] attribute and its sub-attributes. *)

(** {2 Section type} *)

type section = {
  name : string;
  address : int64;
  size : int64;
  read_only : bool; [@default false]
  bytes : string;
}
[@@deriving show, protocol ~driver:(module Lang.Attrib_conv)]

(** {2 Combined GTIRB attributes} *)

type gtirb_attribs = {
  symbols : symbols;
  initial_memory : section list; [@default []]
}
[@@deriving show, protocol ~driver:(module Lang.Attrib_conv)]

(** {2 Derived printing functions} *)

let show_offset_sym = show_offset_sym
let pp_offset_sym = pp_offset_sym
let show_sized_sym = show_sized_sym
let pp_sized_sym = pp_sized_sym
let show_symbols = show_symbols
let pp_symbols = pp_symbols
let show_section = show_section
let pp_section = pp_section
let show_gtirb_attribs = show_gtirb_attribs
let pp_gtirb_attribs = pp_gtirb_attribs

(** {2 Derived {!Attrib.t} conversion functions} *)

let offset_sym_to_attrib_conv = offset_sym_to_attrib_conv
let offset_sym_of_attrib_conv_exn = offset_sym_of_attrib_conv_exn
let offset_sym_of_attrib_conv = offset_sym_of_attrib_conv
let sized_sym_to_attrib_conv = sized_sym_to_attrib_conv
let sized_sym_of_attrib_conv_exn = sized_sym_of_attrib_conv_exn
let sized_sym_of_attrib_conv = sized_sym_of_attrib_conv
let symbols_to_attrib_conv = symbols_to_attrib_conv
let symbols_of_attrib_conv_exn = symbols_of_attrib_conv_exn
let symbols_of_attrib_conv = symbols_of_attrib_conv
let section_to_attrib_conv = section_to_attrib_conv
let section_of_attrib_conv_exn = section_of_attrib_conv_exn
let section_of_attrib_conv = section_of_attrib_conv
let gtirb_attribs_to_attrib_conv = gtirb_attribs_to_attrib_conv
let gtirb_attribs_of_attrib_conv_exn = gtirb_attribs_of_attrib_conv_exn
let gtirb_attribs_of_attrib_conv = gtirb_attribs_of_attrib_conv
