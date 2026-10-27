(** Graph representation of all relations in a GTIRB file. *)

open Bincaml_util.Common

open struct
  module UUIDMap = Load_auxdata.UUIDMap
  module UUIDSet = Load_auxdata.UUIDSet
end

(** {2 Types} *)

type vert = Self | Uuid of UUID.t [@@deriving show]

type relation =
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

(** {2 Graph functions} *)

(** @closed *)
module Graph :
  Graph.Sig.I
    with type V.t = vert
    with type V.label = vert
    with type E.t = vert * relation * vert
    with type E.label = relation =
  Graph.Imperative.Digraph.ConcreteLabeled
    (struct
      type t = vert
      (** @canonical Gtirb_frontend.Gtirb_graph.vert *)

      let compare = Stdlib.compare
      let hash = Hashtbl.hash
      let equal = Stdlib.( = )
    end)
    (struct
      type t = relation
      (** @canonical Gtirb_frontend.Gtirb_graph.edge *)

      let compare = Stdlib.compare
      let default = Unknown_edge_type
    end)

let make_rel (kind : relation) (a, b) = (a, kind, b)
let make_uuid_rel (kind : relation) (a, b) = (Uuid a, kind, Uuid b)

let edges_of_function_entries auxdata =
  let function_entries =
    Load_auxdata.Loaders.function_entries auxdata
    |> Result.to_option
    |> Option.get_exn_or "function_entries auxdata invalid"
  in
  UUIDMap.to_iter function_entries
  |> Iter.flat_map (fun (func, entries) ->
      UUIDSet.to_iter entries |> Iter.map (Pair.make func))
  |> Iter.map (make_uuid_rel Function_has_entry)

let edges_of_function_names auxdata =
  let function_names =
    Load_auxdata.Loaders.function_names auxdata
    |> Result.to_option
    |> Option.get_exn_or "function_names auxdata invalid"
  in
  UUIDMap.to_iter function_names |> Iter.map (make_uuid_rel Function_has_name)

let graph_of_module (m : Gtirb_proto.Module.Gtirb.Proto.Module.t) =
  let g = Graph.create () in

  let auxdata =
    m.aux_data
    |> List.filter_map (function k, Some v -> Some (k, v) | _ -> None)
    |> StringMap.of_list
  in

  edges_of_function_entries auxdata |> Iter.iter (Graph.add_edge_e g);
  edges_of_function_names auxdata |> Iter.iter (Graph.add_edge_e g)
