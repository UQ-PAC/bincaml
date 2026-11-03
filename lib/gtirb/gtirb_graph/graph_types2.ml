(** {b NEWWWW} Vertex and edge (relation) types for the GTIRB graph, and helper
    functions for constructing and querying them. *)

type block_data =
  [ `Proxy | `Code of int * Gtirb_proto'.decode_mode | `Data of int ]
[@@deriving show { with_path = false }]
(** Information about a block. In the Code and Data variants, the int is the
    size. *)

type symbol_data = { name : string; at_end : bool; int_value : int option }
[@@deriving show { with_path = false }]

(** A relation between two UUIDs. For example, an edge [a -> b] with label
    [Function_has_entry] means that the function [a] has entry [b].

    @canonical Gtirb_frontend.Gtirb_graph.relation *)
type relation =
  | Self_data
      (** Self data about a particular UUID. *)
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
      (** A control-flow edge in the original GTIRB IPCFG. *)
  | Control_flow
      (** {b Ternary relation of [(SRC, TGT, CONTROL_FLOW_KIND)].} May be inter- or intra-procedural. *)
[@@deriving show { with_path = false }]

type data =
  | Block_data of block_data
  | Symbol_data of symbol_data
  | Function_data of unit
  | Control_flow_data of Gtirb_proto'.edge_label
[@@deriving show { with_path = false }]

type literal =
  | Uuid of UUID.t
  | Control_flow_kind of [`In_proc | `Out_of_proc]
[@@deriving show { with_path = false }]

(** Symbols used in the Datalog relations, including unary symbols (literals) and relation names. *)
type symbol =
  | Data of data
  | Literal of literal
  | Relation of relation
[@@deriving show { with_path = false }]

(** {3 Derived functions} *)
