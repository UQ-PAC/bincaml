(** Vertex and edge (relation) types for the GTIRB graph, and helper functions
    for constructing and querying them. *)

(** A vertex in the {!Gtirb_frontend.Gtirb_graph.t}.

    @canonical Gtirb_frontend.Gtirb_graph.vert *)
type vert = Uuid of UUID.t [@@deriving show { with_path = false }]

(** Data stored by a UUID of a particular kind.*)
type self_data =
  | Block_data of
      [ `Proxy | `Code of int * Gtirb_types.decode_mode | `Data of int ]
      (** Information about a block. In the Code and Data variants, the int is
          the size. *)
  | Symbol_data of { name : string; at_end : bool; int_value : int option }
  | Function_data of unit
[@@deriving show { with_path = false }]

(** A relation between two {!vert}s. For example, an edge [a -> b] with label
    [Function_has_entry] means that the function [a] has entry [b].

    @canonical Gtirb_frontend.Gtirb_graph.relation

    An edge from [Uuid id -> Uuid id] (a self-loop) can be used for annotating
    data about [id] itself. The {!Data} variant is used for this purpose. *)
type relation =
  | Self of self_data
      (** Self data about a particular UUID. This edge must only appear on
          self-loops. *)
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
  | Control_flow of Gtirb_types.edge_label
      (** A (possibly inter-procedural) control-flow edge. *)
  | Unknown_edge_type
      (** Edge of unknown type. This should never occur and is only needed to
          define the default ocamlgraph edge type. *)
[@@deriving show { with_path = false }]

(** {2 Helper functions} *)

let make_rel (kind : relation) (a, b) = (a, kind, b)
let make_uuid_rel (kind : relation) (a, b) = (Uuid a, kind, Uuid b)

let make_self_rel (kind : self_data) a =
  let v = Uuid a in
  (v, Self kind, v)

(** {3 Derived functions} *)

let pp_vert = pp_vert
let show_vert = show_vert
let pp_self_data = pp_self_data
let show_self_data = show_self_data
let pp_relation = pp_relation
let show_relation = show_relation
