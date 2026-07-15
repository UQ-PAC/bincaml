(** Conversion from bincaml types to and from HM type inference environment *)

open Common
open Abstract_expr

exception TypeErr of string

module Make (T : TypeExpr.TypeContext) = struct
  module Ctx = T
  include Ctx
  include TypeExpr
  include Typ

  type typ = T.Typ.t [@@deriving eq, ord]

  (** Recursion algebra for printing types *)
  let printer_alg = function
    | Var e -> ID.to_string e
    | TypeConstr ([ l ], e) -> l ^ " " ^ e
    | TypeConstr ([ a; b ], "->") -> a ^ " -> " ^ b
    | TypeConstr ([], e) -> e
    | TypeConstr (ls, e) ->
        List.to_string ~start:"(" ~stop:")" ~sep:"," Fun.id ls ^ " " ^ e

  let type_to_string t = Rec.cata printer_alg t

  let plpos (l : Lexing.position) =
    Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

  (** Type schemes; how values of the typing context are typed. *)
  type scheme = Forall of tvar list * t

  let scheme_to_string = function
    | Forall (tl, t) ->
        List.to_string ID.to_string tl ^ ". " ^ type_to_string (find t)

  (** Function type, takes two arguments: we always curry. *)
  let fun_type a b = TypeConstr ([ a; b ], "->")

  (** A type representing a number *)
  let nat_val_type i =
    let num = fix (TypeConstr ([], Int.to_string i)) in
    TypeConstr ([ num ], "ℕ")

  let is_nat_val_type (i : t) =
    match unfix i with
    | TypeConstr ([ num ], "ℕ") -> (
        match unfix num with
        | TypeConstr ([], num) -> Int.of_string num
        | _ -> None)
    | _ -> None

  (** A bitvector type parametric in its width *)
  let bv_type i = map_expr fix @@ TypeConstr ([ nat_val_type i ], "bv")

  (** Bitvector of arbitrary size *)
  let bvunk i = TypeConstr ([ i ], "bv")

  (** {2 Primitive types} *)

  let int_type = TypeConstr ([], "int")
  let bool_type = TypeConstr ([], "bool")
  let unit_t = TypeConstr ([], "unit")
  let top_t = TypeConstr ([], "top")
  let nothing_t = TypeConstr ([], "nothing")
  let ptr_typ_sub a b = TypeConstr ([ a; b ], "ptr")
  let ptr_typ = bv_type 64

  let rec to_basil (t : t) : Types.t =
    let wrapped t f =
      try f ()
      with TypeErr e ->
        raise (TypeErr ("error in " ^ (type_to_string @@ t) ^ ": " ^ e))
    in
    let open Types in
    wrapped t @@ fun () ->
    match unfix t with
    | TypeConstr ([ a; b ], "->") ->
        let a = wrapped a @@ fun () -> to_basil a in
        let b = wrapped b @@ fun () -> to_basil b in
        Map (a, b)
    | TypeConstr ([ w ], "bv") -> (
        match is_nat_val_type w with
        | Some i -> Bitvector i
        | None -> raise (TypeErr ("bitvector unresolved: " ^ type_to_string t)))
    | TypeConstr ([], "unit") -> Unit
    | TypeConstr ([], "bool") -> Boolean
    | TypeConstr ([], "int") -> Integer
    | TypeConstr ([], "top") -> Top
    | TypeConstr ([], "nothing") -> Nothing
    | TypeConstr ([], o) -> Sort (o, [])
    | _ -> failwith "not impl"

  let rec ty_of_basil (t : Types.t) : t =
    let e =
      match t with
      | Types.Boolean -> bool_type
      | Types.Integer -> int_type
      | Types.Bitvector i -> bv_type i
      | Types.Unit -> unit_t
      | Types.Top -> top_t
      | Types.Nothing -> nothing_t
      | Types.Map (a, b) -> fun_type (ty_of_basil a) (ty_of_basil b)
      | Types.Sort (n, _) -> TypeConstr ([], n)
      | Types.Struct _ -> failwith "unsupp"
      | Types.Pointer { lower; upper } ->
          ptr_typ_sub (ty_of_basil lower) (ty_of_basil upper)
      | Types.Variable n -> Var (gen.fresh ~name:n ())
    in
    fix e

  let curry (args : t expr list) (v : t expr) =
    List.fold_left (fun a p -> fix @@ fun_type (fix p) a) (fix v) args

  let curry_f (args : t list) (v : t) =
    List.fold_left (fun a p -> fix @@ fun_type p a) v args

  let types_universe = "<types>"
  let global_universe = "<global>"
end
