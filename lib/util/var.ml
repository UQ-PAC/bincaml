open Containers
open Mtypes

type declaration_scope = Local | Global [@@deriving show, eq, ord]

open struct
  module V = struct
    type t = {
      name : string;
      typ : Types.t;
      pure : bool;
      scope : declaration_scope;
    }
    [@@deriving eq, ord]

    let show (v : t) : string = Printf.sprintf "%s:%s" v.name (Types.show v.typ)

    let hash v =
      Hash.(
        combine4 (Hash.string v.name) (Hash.poly v.typ) (Hash.bool v.pure)
          (Hash.poly v.scope))
  end
end

(** variables are interned *)

module H = Fix.HashCons.ForHashedTypeWeak (V)

include (
  struct
    type t = V.t Fix.HashCons.cell

    let create name ?(pure = true) ?(scope = Local) typ =
      H.make { name; typ; pure; scope }

    let to_int (v : V.t Fix.HashCons.cell) = v.id

    let show v =
      Printf.sprintf "{id=%d ; data=%s}" (Fix.HashCons.id v)
        (V.show (Fix.HashCons.data v))

    let equal (a : t) (b : t) : bool = Fix.HashCons.equal a b
    let compare (a : t) (b : t) : int = Fix.HashCons.compare a b
    let pp fmt v = Format.pp_print_string fmt (show v)
    let to_string v = V.show (Fix.HashCons.data v)
    let pretty v = Containers_pp.text (to_string v)
    let name (e : t) = (Fix.HashCons.data e).name
    let scope (e : t) = (Fix.HashCons.data e).scope
    let typ (e : t) = (Fix.HashCons.data e).typ
    let pure (e : t) = (Fix.HashCons.data e).pure
    let hash (a : t) = Fix.HashCons.hash a
  end :
    sig
      type t

      val to_int : t -> int

      include HASH_TYPE with type t := t
      include PRETTY with type t := t

      val create :
        string -> ?pure:bool -> ?scope:declaration_scope -> Types.t -> t

      val pp : Format.formatter -> t -> unit
      val to_string : t -> string
      val name : t -> string
      val scope : t -> declaration_scope
      val typ : t -> Types.t
      val pure : t -> bool
      val hash : t -> int
    end)

let is_local (v : t) = equal_declaration_scope (scope v) Local
let is_global (v : t) = equal_declaration_scope (scope v) Global
let to_string_il_rvar v = to_string v

let to_string_il_lvar v =
  match scope v with Local -> "var " ^ to_string v | Global -> to_string v

let to_decl_string_il v =
  let decl_n = match typ v with Types.Map _ -> "memory" | _ -> "var" in
  decl_n ^ " " ^ to_string v

module Decls = struct
  include Hashtbl

  type 'v t = (string, 'v) Hashtbl.t

  let find_opt m name = Hashtbl.find_opt m name
  let empty () : 'v t = Hashtbl.create 30

  let add m (v : 'v) =
    let d = find_opt m (name v) in
    match d with
    | Some e when equal e v -> ()
    | Some _ ->
        failwith @@ "Already declared diff var with that name: " ^ name v
    | None -> Hashtbl.add m (name v) v
end
