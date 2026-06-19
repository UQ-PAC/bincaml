open Containers
open Mtypes



type scope = LocalConst | LocalVar | GlobalVar | GlobalConst | GlobalVarShared
[@@deriving show, eq, ord]

type t = { name : ID.t; typ : Types.t; scope : scope }
[@@deriving eq, ord, show]

let hash v =
    Hash.(combine3 (ID.hash v.name) (Hash.poly v.scope) (Hash.poly v.typ))


let copy ?name ?scope ?typ (v : t) =
    {
        name = Option.get_or ~default:v.name name;
        typ = Option.get_or ~default:v.typ typ;
        scope = Option.get_or ~default:v.scope scope;
    }

let to_int (v : t) = ID.index (v.name)
let name (e : t) = ID.name @@ e.name
let scope (e : t) = e.scope
let typ (e : t) = e.typ
let to_string v = name v ^ ":" ^ Types.to_string @@ typ v
let pp fmt v = Format.pp_print_string fmt (to_string v)
let pretty v = Containers_pp.text (to_string v)


let is_local (v : t) =
  match scope v with LocalVar -> true | LocalConst -> true | _ -> false

let is_global (v : t) =
  match scope v with
  | GlobalVar -> true
  | GlobalConst -> true
  | GlobalVarShared -> true
  | _ -> false

let is_mutable (v : t) =
  match scope v with GlobalVar -> true | LocalVar -> true | _ -> false

let is_constant (v : t) =
  match scope v with LocalConst -> true | GlobalConst -> true | _ -> false

let is_pure (v : t) = is_constant v

let is_shared (v : t) =
  match scope v with GlobalVarShared -> true | _ -> false

let to_string_il_rvar v = to_string v

let to_string_il_lvar v =
  match scope v with
  | LocalVar -> "var " ^ to_string v
  | LocalConst -> "let " ^ to_string v
  | GlobalVar -> to_string v
  | GlobalVarShared -> to_string v
  | GlobalConst -> "let " ^ to_string v

let to_decl_string_il v =
  let modifiers = if is_shared v then "observable " else "" in
  "var " ^ modifiers ^ to_string v

(** Variable Generators *)


type generator = {
  fresh: ?name:string -> ?scope:scope -> Types.t -> t;
  (** generate a fresh unique name optional string prefix hint *)
  with_name: string -> ?scope:scope -> Types.t -> t;
  (** Create or return  variable with name*)
  create_exn: string -> ?scope:scope -> Types.t -> t;
  (** Create variable or throw exception if it was previously declared *)
  generator: ID.generator;
  (** The internal ID generator this closes over *)
}


type ('t, 'a, 'g) any_gen = {
  call: 'a -> 't;
  (** Create variable or throw exception if it was previously declared *)
  inner: 'g
}


let create name ?(scope = LocalVar) typ =
    (* disallow creating local const as its too hard to have declaration order *)
    match scope with
    | LocalConst -> { name; typ; scope = LocalVar }
    | _ -> { name; typ; scope }

let to_gen (a:generator) = 
  let call = function 
    | `Fresh (g: (string option* scope option * Types.t)) -> let (name, scope, typ) = g in a.fresh ?name ?scope typ 
    | `WithName  (g : (string * scope option * Types.t))  -> let (name, scope, typ) = g in a.with_name name ?scope typ 
    | `CreateExn g -> let (name, scope, typ) = g in a.create_exn name ?scope typ in
   {
    call;
    inner=a
  }


let fresh (id_gen: ID.generator) name ?scope typ =
  let name = id_gen.fresh ~name () in
  create name ?scope typ

let with_name (id_gen: ID.generator) name ?scope typ =
  let name = id_gen.decl_or_get name in
  create name ?scope typ

let create_exn (id_gen: ID.generator) name ?scope typ =
  let name = id_gen.decl_exn name in
  create name ?scope typ


let mk_gen ?id_generator ?(default_name="v") () =
  let id_gen = Option.get_or ~default:(ID.make_gen ()) id_generator in

  let fresh ?name ?scope typ =
    let name = Option.get_or ~default:default_name name in
    fresh id_gen name ?scope typ
  in

  {
    fresh ;
    with_name= with_name id_gen;
    create_exn = create_exn id_gen;
    generator=id_gen;
  }


