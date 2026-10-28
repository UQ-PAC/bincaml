(** Graph representation of all relations in a GTIRB file. *)

(** {2 Modules} *)

module Graph_dot = Graph_dot
module Loader = Loader

(** {2 Types} *)

type t = Graph_internal.t
(** The main graph type. *)

include Graph_types
