(** Graph representation of all relations in a GTIRB file. *)

type vert = Self | Uuid of UUID.t [@@deriving show]

type edge =
  | Unknown_edge_type
  | Function_has_name
  | Function_has_entry
  | Function_has_block
  | Symbol_refers_to
  | Symbol_data of { name : string; at_end : bool; value : int option }
  | Symbol_is_forwarded_to
      (** Redirects one Symbol to another. This is useful to resolve
          indirections related to dynamic linking. For example, in ELF files it
          connects Symbols pointing to Procedure Linkage Table (PLT) entries to
          the function Symbols called in such entries. It also resolves indirect
          references via the Global Offset Table (GOT) used to resolve addresses
          of global variables at runtime. *)
[@@deriving show]

(** @closed *)
module Graph :
  Graph.Sig.I
    with type V.t = vert
    with type V.label = vert
    with type E.t = vert * edge * vert
    with type E.label = edge =
  Graph.Imperative.Digraph.ConcreteLabeled
    (struct
      type t = vert
      (** @canonical Gtirb_frontend.Gtirb_graph.vert *)

      let compare = Stdlib.compare
      let hash = Hashtbl.hash
      let equal = Stdlib.(=)
    end)
    (struct
      type t = edge
      (** @canonical Gtirb_frontend.Gtirb_graph.edge *)

      let compare = Stdlib.compare
      let default = Unknown_edge_type
    end)

let add_function_entries auxdata g =
  let function_entries = Load_auxdata.Loaders.function_entries auxdata in
  2





  let graph_of_module (m : Gtirb_proto.Module.Gtirb.Proto.Module.t) =
    2
