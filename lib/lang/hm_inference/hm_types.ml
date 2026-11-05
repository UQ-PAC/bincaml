(** Conversion from bincaml types to and from HM type inference environment *)

open Common
open Abstract_expr

exception TypeErr of string

open struct
  let fix = TypeExpr.fix
end

(** Function type, takes two arguments: we always curry. *)
let fun_type st a b = fix st (TypeConstr ([ a; b ], "->"))

(** A type representing a number *)
let nat_val_type st i =
  let num = fix st (TypeExpr.ATyp.TypeConstr ([], Int.to_string i)) in
  fix st (TypeConstr ([ num ], "ℕ"))

(** A bitvector type parametric in its width *)
let bv_type st i = fix st (TypeConstr ([ nat_val_type st i ], "bv"))

(** Bitvector of arbitrary size *)
let bvunk st i = fix st (TypeConstr ([ i ], "bv"))

(** {2 Primitive types} *)

let map_type st k v = fix st (TypeConstr ([ k; v ], "map"))
let record_type st args = fix st (RecordConstr (args, "record"))

(** represent variants as a product of their cases *)
let variant_type st variants =
  let tuple_type st args = fix st (TypeConstr (args, "variantcase")) in
  let vs =
    List.map (fun (vname, args) -> (vname, tuple_type st args)) variants
  in
  fix st (RecordConstr (vs, "variant"))

let int_type st = fix st (TypeConstr ([], "int"))
let bool_type st = fix st (TypeConstr ([], "bool"))
let unit_t st = fix st (TypeConstr ([], "unit"))
let top_t st = fix st (TypeConstr ([], "top"))
let nothing_t st = fix st (TypeConstr ([], "nothing"))
let ptr_typ_sub st a b = fix st (TypeConstr ([ a; b ], "ptr"))
let ptr_typ st = bv_type st 64

let curry_f st (args : TypeExpr.t list) (v : TypeExpr.t) =
  List.fold_left (fun a p -> fun_type st p a) v args

let rec ty_of_basil st (t : Types.t) : TypeExpr.t =
  match t with
  | Types.Boolean -> bool_type st
  | Types.Integer -> int_type st
  | Types.Bitvector i -> bv_type st i
  | Types.Unit -> unit_t st
  | Types.Top -> top_t st
  | Types.Nothing -> nothing_t st
  | Types.Map (a, b) -> map_type st (ty_of_basil st a) (ty_of_basil st b)
  | Types.Function (a, b) -> fun_type st (ty_of_basil st a) (ty_of_basil st b)
  | Types.NewType (ts, n) ->
      fix st (TypeConstr (List.map (ty_of_basil st) ts, n))
  | Types.Record fields ->
      List.map (Pair.map_snd @@ ty_of_basil st) fields |> record_type st
  | Types.Variant fields ->
      List.map (Pair.map_snd (List.map (ty_of_basil st))) fields
      |> variant_type st
  | Types.Variable n ->
      (* names for type variables in ast are reserved *)
      fix st (Var (st.gen.decl_or_get n))

module Make_smart_constructors (S : sig
  val state : TypeExpr.state
end) =
struct
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
  | RecordConstr (args, "record") -> Some args
  | _ -> None

let is_nat_val_type (i : TypeExpr.t) =
  match TypeExpr.unfix i with
  | TypeConstr ([ num ], "ℕ") -> (
      match TypeExpr.unfix num with
      | TypeConstr ([], num) -> Int.of_string num
      | _ -> None)
  | _ -> None

(** Recursion algebra for printing types *)
let printer_alg = function
  | TypeExpr.ATyp.Var e -> "tvar:" ^ ID.to_string e
  | TypeConstr ([ l ], e) -> l ^ " " ^ e
  | TypeConstr ([ a; b ], "->") -> a ^ " -> " ^ b
  | TypeConstr ([], e) -> e
  | TypeConstr (ls, e) ->
      List.to_string ~start:"(" ~stop:")" ~sep:"," Fun.id ls ^ " " ^ e
  | RecordConstr (ls, e) ->
      List.to_string ~start:"{" ~stop:"}" ~sep:";"
        (Pair.to_string ~sep:":" Fun.id Fun.id)
        ls
      ^ " " ^ e

let type_to_string t = TypeExpr.cata printer_alg t
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
  | Var o -> NewType ([], ID.to_string o)

let types_universe = "<types>"
let global_universe = "<global>"
