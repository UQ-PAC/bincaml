open Common

type e = BasilExpr.t
type proc = (Var.t, e) Procedure.t
type bloc = (Var.t, e) Block.t
type stmt = (Var.t, Var.t, e) Stmt.t

module Proc : sig
  type t = proc

  val compare : ('a, 'b) Procedure.t -> ('c, 'd) Procedure.t -> int
end

val equal_stmt :
  (Var.t, Var.t, BasilExpr.t) Stmt.t ->
  (Var.t, Var.t, BasilExpr.t) Stmt.t ->
  Ppx_deriving_runtime.bool

val compare_stmt :
  (Var.t, Var.t, BasilExpr.t) Stmt.t ->
  (Var.t, Var.t, BasilExpr.t) Stmt.t ->
  Ppx_deriving_runtime.int

val show_stmt : (Var.t, Var.t, BasilExpr.t) Stmt.t -> string

val pp_stmt :
  Containers.Format.formatter -> (Var.t, Var.t, BasilExpr.t) Stmt.t -> unit

type prog_spec = { rely : e list; guarantee : e list }
type func_type = Axiom of e | Uninterpreted | Function of e

type implicit_declaration =
  | VariantCase of {
      variant : string;
      belongs_to : Types.t;
      constructor : Var.t;
    }

type declaration =
  | Type of { binding : string; typ : Types.t }
  | Function of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      definition : func_type;
    }
  | Variable of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      classification : e option;
    }
  | Procedure of { definition : proc }

val decl_binding : declaration -> string
val pretty_proc : (Var.t, BasilExpr.t) Procedure.t -> Containers_pp.t
val pretty_declaration : declaration -> Containers_pp.t

type t

val get_id_by_name : string -> t -> ID.t
val set_entry_proc : ID.t -> t -> t
val set_spec : prog_spec -> t -> t
val set_attrib : Attrib.attrib_map -> t -> t
val spec : t -> prog_spec
val modulename : t -> string
val attrib : t -> Attrib.attrib_map
val entry_proc_exn : t -> proc
val entry_proc_opt : t -> proc option
val map_procedures : (ID.t -> proc -> proc) -> t -> t
val proc : t -> ID.t -> proc
val proc_opt : t -> ID.t -> proc option
val procs : t -> (ID.t * proc) Iter.t
val global_vars : t -> Var.t Iter.t
val global_constants : t -> Var.t Iter.t
val get_decl_by_name_id : string -> t -> (ID.t * declaration) option
val get_decl_by_name : string -> t -> declaration option
val get_proc_by_name : string -> t -> proc
val get_decl : ID.t -> t -> declaration option
val get_proc : ID.t -> t -> proc
val get_implicit_decl_by_name : string -> t -> implicit_declaration option
val declare_name : string -> t -> ID.t
val declare_name_exn : string -> t -> ID.t
val add_decl : ?attrib:'a Types.StringMap.t -> t -> declaration -> t
val remove_decl : t -> declaration -> t
val update_decl : ?attrib:'a Types.StringMap.t -> t -> declaration -> t
val add_proc : (Var.t, BasilExpr.t) Procedure.t -> t -> t

val update_proc :
  ID.t ->
  (proc option -> (Var.t, BasilExpr.t) Procedure.t option) ->
  t ->
  t

val output_proc_pretty :
  out_channel -> (Var.t, BasilExpr.t) Procedure.t -> unit

val prog_pretty : t -> Containers_pp.t
val declarations : t -> (ID.t * declaration) CCMap.iter
val filter_decls : (ID.t -> declaration -> bool) -> t -> t
val map_decls : (ID.t -> declaration -> declaration) -> t -> t
val filter_map_decls : (ID.t -> declaration -> declaration option) -> t -> t
val flat_map_decls : (ID.t -> declaration -> declaration Iter.t) -> t -> t
val pretty_to_chan : out_channel -> t -> unit

val decl_global :
  ?attrib:Attrib.t Types.StringMap.t ->
  ?classification:e option ->
  t ->
  Var.t ->
  t

val decl_typ : ?attrib:'a Types.StringMap.t -> t -> Types.t -> t

val referenced_vars_of_prog : t -> Var.t Iter.t
(** Iterates over global variables in the given program, including both read and
    assigned variables. Order is unspecified and may have duplicates. *)

val create_single_proc :
  ?name:string -> unit -> t * (Var.t, BasilExpr.t) Procedure.t

val empty : ?name:string -> unit -> t

module CallGraph : sig
  module Vert : sig
    type t =
      | ProcBegin of ID.t
      | ProcReturn of ID.t
      | ProcExit of ID.t
      | Entry
      | Return

    val pp :
      Ppx_deriving_runtime.Format.formatter -> t -> Ppx_deriving_runtime.unit

    val show : t -> Ppx_deriving_runtime.string
    val equal : t -> t -> Ppx_deriving_runtime.bool
    val compare : t -> t -> Ppx_deriving_runtime.int
    val hash : t -> Containers.Hash.hash
  end

  module Edge : sig
    type t = Proc of ID.t | Nop

    val pp :
      Ppx_deriving_runtime.Format.formatter -> t -> Ppx_deriving_runtime.unit

    val show : t -> Ppx_deriving_runtime.string
    val equal : t -> t -> Ppx_deriving_runtime.bool
    val compare : t -> t -> Ppx_deriving_runtime.int
    val default : t
  end

  module G : sig
    type t =
      Graph__Persistent.Digraph.ConcreteBidirectionalLabeled(Vert)(Edge).t

    module V : sig
      type t = Vert.t

      val compare : t -> t -> int
      val hash : t -> int
      val equal : t -> t -> bool

      type label = t

      val create : label -> t
      val label : t -> label
    end

    type vertex = Vert.t

    module E : sig
      type t = vertex * Edge.t * vertex

      val compare : t -> t -> int

      type vertex = Vert.t

      val src : t -> vertex
      val dst : t -> vertex

      type label = Edge.t

      val create : vertex -> label -> vertex -> t
      val label : t -> label
    end

    type edge = E.t

    val is_directed : bool
    val is_empty : t -> bool
    val nb_vertex : t -> int
    val nb_edges : t -> int
    val out_degree : t -> vertex -> int
    val in_degree : t -> vertex -> int
    val mem_vertex : t -> vertex -> bool
    val mem_edge : t -> vertex -> vertex -> bool
    val mem_edge_e : t -> edge -> bool
    val find_edge : t -> vertex -> vertex -> edge
    val find_all_edges : t -> vertex -> vertex -> edge list
    val succ : t -> vertex -> vertex list
    val pred : t -> vertex -> vertex list
    val succ_e : t -> vertex -> edge list
    val pred_e : t -> vertex -> edge list
    val iter_vertex : (vertex -> unit) -> t -> unit
    val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a
    val iter_edges : (vertex -> vertex -> unit) -> t -> unit
    val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a
    val iter_edges_e : (edge -> unit) -> t -> unit
    val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a
    val map_vertex : (vertex -> vertex) -> t -> t
    val iter_succ : (vertex -> unit) -> t -> vertex -> unit
    val iter_pred : (vertex -> unit) -> t -> vertex -> unit
    val fold_succ : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
    val fold_pred : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
    val iter_succ_e : (edge -> unit) -> t -> vertex -> unit
    val fold_succ_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
    val iter_pred_e : (edge -> unit) -> t -> vertex -> unit
    val fold_pred_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a
    val empty : t
    val add_vertex : t -> vertex -> t
    val remove_vertex : t -> vertex -> t
    val add_edge : t -> vertex -> vertex -> t
    val add_edge_e : t -> edge -> t
    val remove_edge : t -> vertex -> vertex -> t
    val remove_edge_e : t -> edge -> t
  end

  module Scc : sig
    val scc :
      Graph__Persistent.Digraph.ConcreteBidirectionalLabeled(Vert)(Edge).t ->
      int * (Vert.t -> int)

    val scc_array :
      Graph__Persistent.Digraph.ConcreteBidirectionalLabeled(Vert)(Edge).t ->
      Vert.t list array

    val scc_list :
      Graph__Persistent.Digraph.ConcreteBidirectionalLabeled(Vert)(Edge).t ->
      Vert.t list list
  end

  val make_call_graph : t -> G.t
end
