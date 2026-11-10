(** Conversion from bincaml types to and from HM type inference environment *)

open Common
open Abstract_expr

exception TypeErr of string

open TypeExpr.Constructors

let curry_f st (args : TypeExpr.t list) (v : TypeExpr.t) =
  let args = List.rev args in
  List.fold_left (fun a p -> fun_type st p a) v args

let rec ty_of_basil st (t : Types.t) : TypeExpr.t =
  let t =
    match t with
    | Types.Boolean -> bool_type st
    | Types.Integer -> int_type st
    | Types.Bitvector i -> bv_type st i
    | Types.Unit -> unit_t st
    | Types.Top -> top_t st
    | Types.Nothing -> nothing_t st
    | Types.Map (a, b) -> map_type st (ty_of_basil st a) (ty_of_basil st b)
    | Types.Function (a, b) -> fun_type st (ty_of_basil st a) (ty_of_basil st b)
    | Types.NewType (ts, n) -> newtype st (List.map (ty_of_basil st) ts) n
    | Types.Record fields ->
        List.map (Pair.map_snd @@ ty_of_basil st) fields |> record_type st
    | Types.Variant fields ->
        List.map (Pair.map_snd (List.map (ty_of_basil st))) fields
        |> variant_type st
    | Types.Variable n ->
        (* names for type variables in ast are reserved *)
        tvar_existing st n
  in
  t

module Make_smart_constructors (S : sig
  val state : TypeExpr.state
end) =
struct
  let record_type = record_type S.state
  let map_type = map_type S.state
  let fun_type = fun_type S.state
  let nat_val_type = nat_val_type S.state
  let bv_type = bv_type S.state
  let bvunk = bvunk S.state
  let int_type = int_type S.state
  let bool_type = bool_type S.state
  let unit_t = unit_t S.state
  let top_t = top_t S.state
  let nothing_t = nothing_t S.state
  let ptr_typ_sub = ptr_typ_sub S.state
  let ptr_typ = ptr_typ S.state
  let curry_f = curry_f S.state
  let ty_of_basil = ty_of_basil S.state
end

module type Smart_constructors = module type of Make_smart_constructors (struct
  let state = TypeExpr.create_state ()
end)

let smart_constructors st : (module Smart_constructors) =
  (module Make_smart_constructors (struct
    let state = st
  end))

let is_record_type (i : TypeExpr.t) =
  match TypeExpr.unfix i with
  | RecordConstr (args, "<record>") -> Some args
  | _ -> None

let is_nat_val_type (i : TypeExpr.t) =
  match TypeExpr.unfix i with
  | TypeConstr ([ num ], "ℕ") -> (
      match TypeExpr.unfix num with
      | TypeConstr ([], num) -> Int.of_string num
      | _ -> None)
  | _ -> None

let type_to_string t = TypeExpr.to_string t
let plpos (l : Lexing.position) = Printf.sprintf "%s:%d" l.pos_fname l.pos_lnum

(** Type schemes; how values of the typing context are typed. *)
type scheme = Forall of TypeExpr.tvar list * TypeExpr.t

let scheme_to_string = function
  | Forall (tl, t) -> List.to_string ID.to_string tl ^ ". " ^ type_to_string t

let rec to_basil (t : TypeExpr.t) : Types.t =
  let wrapped t f =
    try f ()
    with TypeErr e ->
      raise (TypeErr ("error in " ^ (type_to_string @@ t) ^ ": " ^ e))
  in
  let open Types in
  wrapped t @@ fun () ->
  match TypeExpr.unfix t with
  | TypeConstr ([ a; b ], "->") ->
      let a = wrapped a @@ fun () -> to_basil a in
      let b = wrapped b @@ fun () -> to_basil b in
      Function (a, b)
  | TypeConstr ([ a; b ], "map") ->
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
  | TypeConstr (ts, o) -> NewType (List.map to_basil ts, o)
  | RecordConstr (fields, "<record>") ->
      let fields = List.map (Pair.map_snd to_basil) fields in
      Record fields
  | RecordConstr (fields, "<variant>") ->
      let fields =
        List.map
          (Pair.map_snd
          @@ TypeExpr.unfix %> function
             | TypeConstr (args, "variantcase") -> List.map to_basil args
             | _ -> failwith "variant with field that is not a constructor???")
          fields
      in
      Variant fields
  | Var o -> NewType ([], ID.to_string o)
  | o -> failwith ("invalid type: " ^ TypeExpr.to_string t)

let types_universe = "<types>"
let global_universe = "<global>"
