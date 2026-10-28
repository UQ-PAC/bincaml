(** Graph representation of all relations in a GTIRB file. *)

(** {2 Modules} *)

module Graph = Graph
module Graph_dot = Graph_dot
module Loader = Loader

(** {2 Types} *)

type t = Graph.t
(** The main graph type. *)

include Types
