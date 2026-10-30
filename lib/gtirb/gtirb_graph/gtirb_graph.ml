(** Graph representation of all relations in a GTIRB file. *)

(** {2 Modules} *)

module Graph_internal = Graph_internal
module Graph_dot = Graph_dot
module Graph_types = Graph_types
module Loader = Loader

(** {2 Types} *)

type t = Graph_internal.t
(** The main graph type. *)

include Graph_types
