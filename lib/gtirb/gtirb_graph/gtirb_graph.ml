(** Graph representation of all relations in a GTIRB file. *)

(** {2 Modules} *)

module Graph_internal = Graph_internal
module Graph_dot = Graph_dot
module Graph_types = Graph_types
module Graph_types2 = Graph_types2
module Graph_query = Graph_query
module Loader = Loader

(** {2 Types} *)

type t = Graph_internal.t
(** The main graph type. *)

include Graph_types
(** @inline *)
