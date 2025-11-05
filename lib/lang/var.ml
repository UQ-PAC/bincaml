open Common
open ContainersLabels
open Value
open Types

type declaration_scope = Local | Global [@@deriving show, eq, ord]

module V = struct
  type t = {
    name : string;
    typ : Types.t;
    pure : bool;
    scope : declaration_scope;
  }
  [@@deriving eq, ord]

  let show (v : t) : string = Printf.sprintf "%s:%s" v.name (Types.show v.typ)
  let pp fmt (b : t) : unit = Format.pp_print_string fmt (show b)
  let var name ?(pure = true) ?(scope = Local) typ = { name; typ; pure; scope }
  let hash v = Hashtbl.hash v
end

module H = Fix.HashCons.ForHashedTypeWeak (V)

type t = V.t Fix.HashCons.cell

let show v =
  Printf.sprintf "{id=%d ; data=%s}" (Fix.HashCons.id v)
    (V.show (Fix.HashCons.data v))

let pp fmt v = Format.pp_print_string fmt (show v)
let to_string v = V.show (Fix.HashCons.data v)

let create name ?(pure = true) ?(scope = Local) typ =
  H.make { name; typ; pure; scope }

let name (e : t) = (Fix.HashCons.data e).name
let scope (e : t) = (Fix.HashCons.data e).scope
let typ (e : t) = (Fix.HashCons.data e).typ
let pure (e : t) = (Fix.HashCons.data e).pure
let compare (a : t) (b : t) = Fix.HashCons.compare a b
let equal (a : t) (b : t) = Fix.HashCons.equal a b
let hash (a : t) = Fix.HashCons.hash a
let is_local (v : t) = equal_declaration_scope (scope v) Local
let is_global (v : t) = equal_declaration_scope (scope v) Global

let to_string_il_rvar v =
  if match typ v with Types.Map _ -> true | _ -> false then name v
  else to_string v

let to_string_il_lvar v =
  if match typ v with Types.Map _ -> true | _ -> false then name v
  else
    match scope v with Local -> "var " ^ to_string v | Global -> to_string v

let to_decl_string_il v =
  let decl_n = match typ v with Types.Map _ -> "memory" | _ -> "var" in
  decl_n ^ " " ^ to_string v

module Set = CCHashSet.Make (V)
(**FIXME: these do not use the hash-consign*)

module Bindings = CCHashTrie.Make (V)

module Decls = struct
  include Hashtbl

  type 'v t = (string, 'v) Hashtbl.t

  let find_opt m name = Hashtbl.find_opt m name
  let empty () : 'v t = Hashtbl.create 30

  let add m (v : 'v) =
    let d = find_opt m (name v) in
    match d with
    | Some e when equal e v -> ()
    | Some e ->
        failwith @@ "Already declared diff var with that name: " ^ name v
    | None -> Hashtbl.add m (name v) v
end
