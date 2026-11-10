type tvar = Common.ID.t

val equal_tvar : tvar -> tvar -> Ppx_deriving_runtime.bool
val compare_tvar : tvar -> tvar -> Ppx_deriving_runtime.int

val pp_tvar :
  Ppx_deriving_runtime.Format.formatter -> tvar -> Ppx_deriving_runtime.unit

val show_tvar : tvar -> Ppx_deriving_runtime.string

module V : sig
  type t = { univ : string; v : string }

  val equal : t -> t -> Ppx_deriving_runtime.bool
  val compare : t -> t -> Ppx_deriving_runtime.int

  val pp :
    Ppx_deriving_runtime.Format.formatter -> t -> Ppx_deriving_runtime.unit

  val show : t -> Ppx_deriving_runtime.string
  val hash : t -> Common.Hash.hash
  val to_string : t -> string
  val local_univ : string
  val global_univ : string
  val proc_univ : tvar -> string
  val create : string -> string -> t
  val of_var : string -> Common.Var.t -> t
end

module TCtx : sig
  type key = V.t
  type 'a t = 'a Map.Make(V).t

  val empty : 'a t
  val add : key -> 'a -> 'a t -> 'a t
  val add_to_list : key -> 'a -> 'a list t -> 'a list t
  val update : key -> ('a option -> 'a option) -> 'a t -> 'a t
  val singleton : key -> 'a -> 'a t
  val remove : key -> 'a t -> 'a t

  val merge :
    (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t

  val union : (key -> 'a -> 'a -> 'a option) -> 'a t -> 'a t -> 'a t
  val cardinal : 'a t -> int
  val bindings : 'a t -> (key * 'a) list
  val min_binding : 'a t -> key * 'a
  val min_binding_opt : 'a t -> (key * 'a) option
  val max_binding : 'a t -> key * 'a
  val max_binding_opt : 'a t -> (key * 'a) option
  val choose : 'a t -> key * 'a
  val choose_opt : 'a t -> (key * 'a) option
  val find : key -> 'a t -> 'a
  val find_opt : key -> 'a t -> 'a option
  val find_first : (key -> bool) -> 'a t -> key * 'a
  val find_first_opt : (key -> bool) -> 'a t -> (key * 'a) option
  val find_last : (key -> bool) -> 'a t -> key * 'a
  val find_last_opt : (key -> bool) -> 'a t -> (key * 'a) option
  val iter : (key -> 'a -> unit) -> 'a t -> unit
  val fold : (key -> 'a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
  val map : ('a -> 'b) -> 'a t -> 'b t
  val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
  val filter : (key -> 'a -> bool) -> 'a t -> 'a t
  val filter_map : (key -> 'a -> 'b option) -> 'a t -> 'b t
  val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
  val split : key -> 'a t -> 'a t * 'a option * 'a t
  val is_empty : 'a t -> bool
  val mem : key -> 'a t -> bool
  val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
  val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
  val for_all : (key -> 'a -> bool) -> 'a t -> bool
  val exists : (key -> 'a -> bool) -> 'a t -> bool
  val to_seq : 'a t -> (key * 'a) Seq.t
  val to_rev_seq : 'a t -> (key * 'a) Seq.t
  val to_seq_from : key -> 'a t -> (key * 'a) Seq.t
  val add_seq : (key * 'a) Seq.t -> 'a t -> 'a t
  val of_seq : (key * 'a) Seq.t -> 'a t
  val get : key -> 'a t -> 'a option
  val get_or : key -> 'a t -> default:'a -> 'a

  val merge_safe :
    f:(key -> [ `Both of 'a * 'b | `Left of 'a | `Right of 'b ] -> 'c option) ->
    'a t ->
    'b t ->
    'c t

  val add_seq_with :
    f:(key -> 'a -> 'a -> 'a) -> 'a t -> (key * 'a) Seq.t -> 'a t

  val of_seq_with : f:(key -> 'a -> 'a -> 'a) -> (key * 'a) Seq.t -> 'a t
  val add_iter : 'a t -> (key * 'a) CCMap.iter -> 'a t

  val add_iter_with :
    f:(key -> 'a -> 'a -> 'a) -> 'a t -> (key * 'a) CCMap.iter -> 'a t

  val of_iter : (key * 'a) CCMap.iter -> 'a t
  val of_iter_with : f:(key -> 'a -> 'a -> 'a) -> (key * 'a) CCMap.iter -> 'a t
  val to_iter : 'a t -> (key * 'a) CCMap.iter
  val of_list : (key * 'a) list -> 'a t
  val of_list_with : f:(key -> 'a -> 'a -> 'a) -> (key * 'a) list -> 'a t
  val add_list : 'a t -> (key * 'a) list -> 'a t

  val add_list_with :
    f:(key -> 'a -> 'a -> 'a) -> 'a t -> (key * 'a) list -> 'a t

  val keys : 'a t -> key CCMap.iter
  val values : 'a t -> 'a CCMap.iter
  val to_list : 'a t -> (key * 'a) list

  val pp :
    ?pp_start:unit CCMap.printer ->
    ?pp_stop:unit CCMap.printer ->
    ?pp_arrow:unit CCMap.printer ->
    ?pp_sep:unit CCMap.printer ->
    key CCMap.printer ->
    'a CCMap.printer ->
    'a t CCMap.printer
end

module ATyp : sig
  type 'a expr = private
    | Var of tvar
    | TypeConstr of 'a list * string
    | RecordConstr of (string * 'a) list * string

  val equal_expr :
    ('a -> 'a -> Ppx_deriving_runtime.bool) ->
    'a expr ->
    'a expr ->
    Ppx_deriving_runtime.bool

  val compare_expr :
    ('a -> 'a -> Ppx_deriving_runtime.int) ->
    'a expr ->
    'a expr ->
    Ppx_deriving_runtime.int

  val pp_expr :
    (Ppx_deriving_runtime.Format.formatter -> 'a -> Ppx_deriving_runtime.unit) ->
    Ppx_deriving_runtime.Format.formatter ->
    'a expr ->
    Ppx_deriving_runtime.unit

  val show_expr :
    (Ppx_deriving_runtime.Format.formatter -> 'a -> Ppx_deriving_runtime.unit) ->
    'a expr ->
    Ppx_deriving_runtime.string

  val map_expr : ('a -> 'b) -> 'a expr -> 'b expr
  val fold_expr : ('a -> 'b -> 'a) -> 'a -> 'b expr -> 'a
  val hash : 'a Common.Hash.t -> 'a expr -> Common.Hash.hash
end

type t = nt UnionFind.elem Fix.HashCons.cell
and nt = T of t ATyp.expr [@@unboxed]

val equal : 'a Fix.HashCons.cell -> 'a Fix.HashCons.cell -> bool
val compare : 'a Fix.HashCons.cell -> 'a Fix.HashCons.cell -> int
val map_expr : ('a -> 'b) -> 'a ATyp.expr -> 'b ATyp.expr

module Hash_inner : sig
  type t = nt UnionFind.elem

  val hash : t -> int
  val equal : t -> t -> bool
end

module State : sig
  type state = { hcons : Hash_inner.t -> t; gen : Common.ID.generator }

  val create_state : unit -> state
end

type state = State.state = {
  hcons : Hash_inner.t -> t;
  gen : Common.ID.generator;
}

val create_state : unit -> state
val unfix : t -> t ATyp.expr
val fix : state -> t ATyp.expr -> t
val union : state -> t -> t -> t
val find : state -> nt UnionFind.elem Fix.HashCons.cell -> t
val merge : state -> (t ATyp.expr -> t ATyp.expr -> t ATyp.expr) -> t -> t -> t
val cata : ('a ATyp.expr -> 'a) -> t -> 'a

module Rec : (S : sig
                val state : state
              end)
  -> sig
  module O : sig
    type 'e expr = 'e ATyp.expr
    type nonrec t = t

    val fix : t expr -> t
    val unfix : t -> t expr
    val map_expr : ('b -> 'a) -> 'b expr -> 'a expr
  end

  type 'a alg = 'a ATyp.expr -> 'a
  type 'a coalg = 'a -> 'a ATyp.expr

  val cata : 'a alg -> t -> 'a
  val ana : 'a coalg -> 'a -> t

  val map_fold :
    f:('a -> t ATyp.expr -> 'a) ->
    alg:('a -> 'b ATyp.expr -> 'b) ->
    'a ->
    t ->
    'b

  val rw_recurse_down : f:(t ATyp.expr -> t) -> t -> t

  val mutu :
    ?cata:(('a * 'b) alg -> t -> 'a * 'b) ->
    (('a * 'b) ATyp.expr -> 'a) ->
    (('a * 'b) ATyp.expr -> 'b) ->
    (t -> 'a) * (t -> 'b)

  val zygo :
    ?cata:(('a * 'b) alg -> t -> 'a * 'b) ->
    'a alg ->
    (('a * 'b) ATyp.expr -> 'b) ->
    t ->
    'b

  val zygo_l :
    ?cata:(('b * 'a) alg -> t -> 'b * 'a) ->
    'a alg ->
    (('b * 'a) ATyp.expr -> 'b) ->
    t ->
    'b

  val map_fold2 :
    f:('a -> t ATyp.expr -> 'a) ->
    alg1:('a -> ('b * 'c) ATyp.expr -> 'b) ->
    alg2:'c alg ->
    'a ->
    t ->
    'b

  val para_f : (('a * 'b) ATyp.expr -> 'b) -> (t -> 'a) -> t -> 'b
  val para : ((t * 'a) ATyp.expr -> 'a) -> t -> 'a
  val cata_context : ((t ATyp.expr ATyp.expr * 'a) ATyp.expr -> 'a) -> t -> 'a
  val iter_children : (t ATyp.expr -> unit) -> t -> unit
  val children_iter : t -> t ATyp.expr Iter.t
end

val printer_alg : string ATyp.expr -> string
val to_string : t -> string

module Constructors : sig
  val fix : state -> t ATyp.expr -> t
  val fun_type : state -> t -> t -> t
  val nat_val_type : state -> int -> t
  val bv_type : state -> int -> t
  val bvunk : state -> t -> t
  val map_type : state -> t -> t -> t
  val record_type : state -> (string * t) list -> t
  val variant_type : state -> (string * t list) list -> t
  val int_type : state -> t
  val bool_type : state -> t
  val unit_t : state -> t
  val top_t : state -> t
  val nothing_t : state -> t
  val ptr_typ_sub : state -> t -> t -> t
  val ptr_typ : state -> t
  val newtype:  state -> t list -> string -> t
  val tvar_existing:  state -> string -> t
  val tvar_fresh :  state -> string -> t
  val make_type :  state -> (t) list -> string -> t
  val make_record_type :  state -> (string * t) list -> string -> t
end
