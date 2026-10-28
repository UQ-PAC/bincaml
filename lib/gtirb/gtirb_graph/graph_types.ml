(** Vertex and edge (relation) types for the GTIRB graph, and helper functions
    for constructing and querying them. *)

(** A vertex in the {!Gtirb_frontend.Gtirb_graph.t}.

    @canonical Gtirb_frontend.Gtirb_graph.vert *)
type vert = Uuid of UUID.t [@@deriving show { with_path = false }]

type block_data =
  | Proxy
  | Code of {
      size : int;
      decode : Gtirb_proto.CodeBlock.Gtirb.Proto.DecodeMode.t; [@opaque]
    }
  | Data of { size : int }
[@@deriving show { with_path = false }]

(** A relation between two {!vert}s.

    @canonical Gtirb_frontend.Gtirb_graph.relation

    An edge from [Uuid id -> Uuid id] (a self-loop) can be used for annotating
    data about [id] itself. These are the variants which end in [_data]. *)
type relation =
  | Unknown_edge_type
  | Function_has_name
  | Function_has_entry
  | Function_has_block
  | Block_data of block_data
  | Symbol_refers_to
  | Symbol_data of { name : string; at_end : bool; int_value : int option }
  | Symbol_is_forwarded_to
      (** Redirects one Symbol to another. This is useful to resolve
          indirections related to dynamic linking. For example, in ELF files it
          connects Symbols pointing to Procedure Linkage Table (PLT) entries to
          the function Symbols called in such entries. It also resolves indirect
          references via the Global Offset Table (GOT) used to resolve addresses
          of global variables at runtime. *)
[@@deriving show { with_path = false }]

(** {2 Helper functions} *)

let make_rel (kind : relation) (a, b) = (a, kind, b)
let make_uuid_rel (kind : relation) (a, b) = (Uuid a, kind, Uuid b)

let make_self_rel (kind : relation) a =
  let v = Uuid a in
  (v, kind, v)

(** {3 Derived functions} *)

let pp_vert = pp_vert
let show_vert = show_vert
let pp_relation = pp_relation
let show_relation = show_relation
