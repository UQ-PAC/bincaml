(** Conversion from bincaml types to and from HM type inference environment *)

open Common
open Abstract_expr

exception TypeErr of string

module Make (Ctx : TypeExpr.TypeContext) = struct
  type typ = Ctx.Typ.t [@@deriving eq, ord]

  (** Recursion algebra for printing types *)
  let printer_alg = function
    | TypeExpr.ATyp.Var e -> ID.to_string e
    | TypeConstr ([ l ], e) -> l ^ " " ^ e
    | TypeConstr ([ a; b ], "->") -> a ^ " -> " ^ b
    | TypeConstr ([], e) -> e
    | TypeConstr (ls, e) ->
        List.to_string ~start:"(" ~stop:")" ~sep:"," Fun.id ls ^ " " ^ e

  let type_to_string t = Ctx.Rec.cata printer_alg t

  let plpos (l : Lexing.position) =
    Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

  (** Type schemes; how values of the typing context are typed. *)
  type scheme = Forall of TypeExpr.tvar list * Ctx.Typ.t

  let scheme_to_string = function
    | Forall (tl, t) ->
        List.to_string ID.to_string tl ^ ". " ^ type_to_string (Ctx.Typ.find t)

  (** Function type, takes two arguments: we always curry. *)
  let fun_type a b = TypeExpr.ATyp.TypeConstr ([ a; b ], "->")

  (** A type representing a number *)
  let nat_val_type i =
    let num = Ctx.Typ.fix (TypeExpr.ATyp.TypeConstr ([], Int.to_string i)) in
    Ctx.Typ.TypeConstr ([ num ], "ℕ")

  let is_nat_val_type (i : Ctx.Typ.t) =
    match Ctx.Typ.unfix i with
    | TypeConstr ([ num ], "ℕ") -> (
        match Ctx.Typ.unfix num with
        | TypeConstr ([], num) -> Int.of_string num
        | _ -> None)
    | _ -> None

  (** A bitvector type parametric in its width *)
  let bv_type i =
    Ctx.Typ.(map_expr fix @@ TypeConstr ([ nat_val_type i ], "bv"))

  (** Bitvector of arbitrary size *)
  let bvunk i = Ctx.Typ.TypeConstr ([ i ], "bv")

  (** {2 Primitive types} *)

  let int_type = Ctx.Typ.TypeConstr ([], "int")
  let bool_type = Ctx.Typ.TypeConstr ([], "bool")
  let unit_t = Ctx.Typ.TypeConstr ([], "unit")
  let top_t = Ctx.Typ.TypeConstr ([], "top")
  let nothing_t = Ctx.Typ.TypeConstr ([], "nothing")
  let ptr_typ_sub a b = Ctx.Typ.TypeConstr ([ a; b ], "ptr")
  let ptr_typ = bv_type 64

  let rec to_basil (t : Ctx.Typ.t) : Types.t =
    let wrapped t f =
      try f ()
      with TypeErr e ->
        raise (TypeErr ("error in " ^ (type_to_string @@ t) ^ ": " ^ e))
    in
    let open Types in
    wrapped t @@ fun () ->
    match Ctx.Typ.unfix t with
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

  let rec ty_of_basil (t : Types.t) : Ctx.Typ.t =
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
      | Types.Variable n -> Var (Ctx.gen.fresh ~name:n ())
    in
    Ctx.Typ.fix e

  let curry (args : Ctx.Typ.t TypeExpr.ATyp.expr list)
      (v : Ctx.Typ.t TypeExpr.ATyp.expr) =
    List.fold_left
      (fun a p -> Ctx.Typ.fix @@ fun_type (Ctx.Typ.fix p) a)
      (Ctx.Typ.fix v) args

  let curry_f (args : Ctx.Typ.t list) (v : Ctx.Typ.t) =
    List.fold_left (fun a p -> Ctx.Typ.fix @@ fun_type p a) v args

  let types_universe = "<types>"
  let global_universe = "<global>"

  include Ctx
  (** XXX: TODO........... *)

  include Typ
end
