open Containers
open Mtypes

type access_tag = Const | Shared | None [@@deriving show, eq, ord]
type scope_tag = Global of string | Local of string [@@deriving show, eq, ord]

type t = { name : ID.t; scope : scope_tag; typ : Types.t; tags : access_tag }
[@@deriving eq, ord, show]

let hash v =
  Hash.(combine3 (ID.hash v.name) (Hash.poly v.tags) (Hash.poly v.typ))

(*
let copy ?name ?scope ?typ (v : t) =
    {
        name = Option.get_or ~default:v.name name;
        typ = Option.get_or ~default:v.typ typ;
        scope = Option.get_or ~default:v.scope scope;
    } *)

let to_int (v : t) = ID.index v.name
let id v = v.name
let tags (e : t) = e.tags
let typ (e : t) = e.typ
let is_local (v : t) = match v.scope with Local _ -> true | Global _ -> false
let is_global (v : t) = match v.scope with Global _ -> true | Local _ -> false
let name (e : t) = if is_global e then "$" ^ ID.name e.name else ID.name e.name
let to_string v = name v ^ ":" ^ Types.to_string @@ typ v
let pp fmt v = Format.pp_print_string fmt (to_string v)
let pretty v = Containers_pp.text (to_string v)
let is_const (v : t) = match v.tags with Const -> true | _ -> false
let access (v : t) = v.tags
let is_shared (v : t) = match v.tags with Shared -> true | _ -> false
let to_string_il_rvar v = to_string v

let to_string_il_lvar v =
  match (v.scope, v.tags) with
  | _, Const -> "let " ^ to_string v
  | Local _, _ -> "var " ^ to_string v
  | Global _, None -> to_string v
  | Global _, Shared -> to_string v

let to_decl_string_il v =
  let modifiers = if is_shared v then "observable " else "" in
  "var " ^ modifiers ^ to_string v

(** Variable Generators *)

type generator = {
  scope : scope_tag;
  fresh : ?name:string -> ?access:access_tag -> Types.t -> t;
      (** generate a fresh unique name optional string prefix hint *)
  with_name : string -> ?access:access_tag -> Types.t -> t;
      (** Create or return variable with name*)
  create_exn : string -> ?access:access_tag -> Types.t -> t;
      (** Create variable or throw exception if it was previously declared *)
  generator : ID.generator;  (** The internal ID generator this closes over *)
}

type ('t, 'a, 'g) any_gen = {
  call : 'a -> 't;
      (** Create variable or throw exception if it was previously declared *)
  inner : 'g;
}

open struct
  let force_sigil sigil s : string =
    match String.chop_prefix ~pre:sigil s with Some s -> s | None -> s

  let create name id_gen ?(access = None) typ =
    (* disallow creating local const as its too hard to have declaration order *)
    { name; scope = id_gen; typ; tags = access }

  let fresh gt (gen : ID.generator) sgl name ?access typ =
    let name = force_sigil sgl name in
    let name = gen.fresh ~name () in
    create name gt ?access typ

  let with_name gt (id_gen : ID.generator) sgl name ?access typ =
    let name = force_sigil sgl name in
    let name = id_gen.decl_or_get name in
    create name gt ?access typ

  let create_exn gt (id_gen : ID.generator) sgl name ?access typ =
    let name = force_sigil sgl name in
    let name = id_gen.decl_exn name in
    create name gt ?access typ
end

let mk_gen ?id_generator ?(req_sigil = Option.None) ?(scope = `Local)
    ?(default_name = "v") () =
  let id_gen = Option.get_or ~default:(ID.make_gen ()) id_generator in
  let gt =
    match scope with
    | `Local -> Local ""
    | `Global -> Global ""
  in
  let sgl =
    match (req_sigil, scope) with
    | Some s, _ -> s
    | None, `Local -> ""
    | None, `Global -> "$"
  in

  let fresh ?name ?access typ =
    let name = Option.get_or ~default:default_name name in
    fresh gt id_gen sgl name ?access typ
  in

  {
    scope = gt;
    fresh;
    with_name = with_name gt id_gen sgl;
    create_exn = create_exn gt id_gen sgl;
    generator = id_gen;
  }
