(** A vertex in the {!Gtirb_frontend.Gtirb_graph.t}.

    @canonical Gtirb_frontend.Gtirb_graph.vert *)
type vert =
  | Self
      (** An edge from [Uuid id -> Self] is used for annotating data about [id]
          itself. There are no self-loops between [Self]. *)
  | Uuid of UUID.t
[@@deriving show { with_path = false }]

type block_data =
  | Proxy
  | Code of {
      size : int;
      decode : Gtirb_proto.CodeBlock.Gtirb.Proto.DecodeMode.t; [@opaque]
    }
  | Data of { size : int }
[@@deriving show { with_path = false }]

(** @canonical Gtirb_frontend.Gtirb_graph.relation *)
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

(** {3 Derived functions} *)

let pp_vert = pp_vert
let show_vert = show_vert
let pp_relation = pp_relation
let show_relation = show_relation
