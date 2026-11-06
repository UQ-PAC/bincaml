(** {b NEWWWW} Vertex and edge (relation) types for the GTIRB graph, and helper
    functions for constructing and querying them. *)

type block_data =
  [ `Proxy | `Code of int * Gtirb_proto'.decode_mode | `Data of int ]
[@@deriving show { with_path = false }]
(** Information about a block. In the Code and Data variants, the int is the
    size. *)

type symbol_data = { name : string; at_end : bool; int_value : int option }
[@@deriving show { with_path = false }]

type control_flow_kind = [ `In_proc | `Out_of_proc ]
[@@deriving show { with_path = false }]

(** A relation between two UUIDs. For example, an edge [a -> b] with label
    [Function_has_entry] means that the function [a] has entry [b].

    Unless specified otherwise, these relations are binary relations.

    @canonical Gtirb_frontend.Gtirb_graph.relation *)
type relation =
  | Self_data  (** Self data about a particular UUID. *)
  | Function_has_name
      (** The UUID of a Symbol whose name field contains the name of the
          function.

          Note: There may be more than one gtirb::Symbol associated with the
          address(es) corresponding to the entry point(s) of a function. This
          table identifies a canonical gtirb::Symbol to be used for each
          function. Note that there is no function notion in the core GTIRB IR.
          A function's UUID is just a unique identifier that is consistently
          used across all function-related AuxData tables. *)
  | Function_has_entry
      (** This table identifies all gtirb::CodeBlocks that represent entry
          points to each function. A single function may have more than one
          entry point. Note that there is no function notion in the core GTIRB
          IR. A function's UUID is just a unique identifier that is consistently
          used across all function-related AuxData tables. *)
  | Function_has_block
  (*| Section_data of {
      name: string;
      flags: Gtirb_types.section_flag list
    }
  | Section_has_byteinterval *)
  | Symbol_refers_to
  | Symbol_is_forwarded_to
      (** Redirects one Symbol to another. This is useful to resolve
          indirections related to dynamic linking. For example, in ELF files it
          connects Symbols pointing to Procedure Linkage Table (PLT) entries to
          the function Symbols called in such entries. It also resolves indirect
          references via the Global Offset Table (GOT) used to resolve addresses
          of global variables at runtime. *)
  | Ipcfg
      (** {b Relation of [(src, tgt, is_cond, is_direct, edge_type)].} This
          corresponds directly to a control-flow edge in the original GTIRB
          IPCFG, along with its associated edge label. Edge types are
          {!Gtirb_proto'.edge_type}. *)
  | Control_flow_same_proc
      (** Derived relation between UUIDs if this control-flow is within the same
          procedure. *)
  | Control_flow_diff_proc
      (** Derived relation between UUIDs if this control-flow is {b not} within
          the same procedure. *)
[@@deriving show { with_path = false }, enum]

(** A Datalog literal. These can be parsed from a text format, so they can be
    used in queries. *)
type literal =
  | Uuid of UUID.t
  | Int of int
  | Bool of bool
  | Edge_type of Gtirb_proto'.edge_type
[@@deriving show { with_path = false }]

(** Datalog data value. These are more complex values and cannot be parsed. *)
type data =
  | Block_data of block_data
  | Symbol_data of symbol_data
  | Function_data of unit
[@@deriving show { with_path = false }]

(** Symbols used in the Datalog relations *)
type symbol = Data of data | Literal of literal | Relation of relation
[@@deriving show { with_path = false }]

let of_string =
  let relation_of_string =
    Bincaml_util.Enum.make_of_string ~min:min_relation ~max:max_relation
      ~of_int:relation_of_enum ~show:show_relation
  in
  2

(** {3 Derived functions} *)
