open Containers
open Mtypes

type scope = LocalConst | LocalVar | GlobalVar | GlobalConst | GlobalVarShared
[@@deriving show, eq, ord]

open struct
  module V = struct
    type t = { name : string; typ : Types.t; scope : scope }
    [@@deriving eq, ord, show]

    let hash v =
      Hash.(combine3 (Hash.string v.name) (Hash.poly v.scope) (Hash.poly v.typ))
  end
end

(** variables are interned *)

module H = Fix.HashCons.ForHashedTypeWeak (V)

include (
  struct
    type t = V.t Fix.HashCons.cell

    let create name ?(scope = LocalVar) typ =
      (* disallow creating local const as its too hard to have declaration order *)
      match scope with
      | LocalConst -> H.make { name; typ; scope = LocalVar }
      | _ -> H.make { name; typ; scope }

    let copy ?name ?scope ?typ (v : t) =
      let v = Fix.HashCons.data v in
      H.make
        {
          name = Option.get_or ~default:v.name name;
          typ = Option.get_or ~default:v.typ typ;
          scope = Option.get_or ~default:v.scope scope;
        }

    let to_int (v : V.t Fix.HashCons.cell) = v.id
    let show v = V.show (Fix.HashCons.data v)
    let equal (a : t) (b : t) : bool = Fix.HashCons.equal a b
    let compare (a : t) (b : t) : int = Fix.HashCons.compare a b
    let name (e : t) = (Fix.HashCons.data e).name
    let scope (e : t) = (Fix.HashCons.data e).scope
    let typ (e : t) = (Fix.HashCons.data e).typ
    let hash (a : t) = Fix.HashCons.hash a
    let to_string v = name v ^ ":" ^ Types.to_string @@ typ v
    let pp fmt v = Format.pp_print_string fmt (to_string v)
    let pretty v = Containers_pp.text (to_string v)
  end :
    sig
      type t

      val to_int : t -> int

      include HASH_TYPE with type t := t
      include PRETTY with type t := t

      val create : string -> ?scope:scope -> Types.t -> t
      val pp : Format.formatter -> t -> unit
      val to_string : t -> string
      val name : t -> string
      val scope : t -> scope
      val typ : t -> Types.t
      val hash : t -> int
      val copy : ?name:string -> ?scope:scope -> ?typ:Types.t -> t -> t
    end)

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

module Decls = struct
  include Hashtbl

  type 'v t = (string, 'v) Hashtbl.t

  let find_opt m name = Hashtbl.find_opt m name
  let empty () : 'v t = Hashtbl.create 30

  (*let add m vn v =
    let d = find_opt m (name vn) in
    match d with
    | Some e when equal e v -> ()
    | Some _ ->
        failwith @@ "Already declared diff var with that name: " ^ name v
    | None -> Hashtbl.add m (name vn) v
    *)
end
