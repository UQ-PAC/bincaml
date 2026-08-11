open Common
open Containers
open Ops
open BasilExpr

type rwinfo = {
  from : t;
  into : t;
  __LINE__ : int option;
  __FILE__ : string option;
}

type rewrite = SomeInfo of { v : t; __LINE__ : int; __FILE__ : string } | Keep

let show_rwinfo to_string = function
  | { from; into } -> to_string from ^ " ~> " ^ to_string into

let[@inline] replace (here : Lexing.position) v =
  SomeInfo { v; __LINE__ = here.pos_lnum; __FILE__ = here.pos_fname }

let replace_opt = function Some v -> replace Lexing.dummy_pos v | None -> Keep
[@@inline always]

module Comb = struct
  let to_steady equal f x =
    let rec loop x =
      let n = f x in
      if equal n x then n else loop n
    in
    loop x

  let sequence (a : 'a -> rewrite) (b : 'a -> rewrite) e =
    match a e with Keep -> b e | e -> e

  let apply_fun in_body args =
    let args = args |> VarMap.of_list |> fun m v -> VarMap.find_opt v m in
    BasilExpr.substitute args in_body
end

open struct
  let type_of = unfix %> AbstractExpr.get_typ

  let msg_or ?err_to_string e =
    err_to_string
    |> Option.map (fun f -> f @@ e)
    |> Option.get_or ~default:"???"
end

let log_rw visit ?__LINE__ ?__FILE__ o e =
  Option.iter (fun f -> f { __LINE__; __FILE__; from = o; into = e }) visit;
  e

(** Substitute subexpression sbased on parameter *)
(** WARN: Should perform type-inference after a change is performed *)
let rewrite ?visit ?err_to_string ~(rw_fun : t abstract_expr -> rewrite)
    (expr : t) =
  let rw_alg e =
    let orig s = fix s in
    match rw_fun e with Keep -> orig e | SomeInfo { v } -> v
  in
  cata rw_alg expr

(** Substitute subexpression sbased on parameter *)
(** WARN: Should perform type-check after a change is performed *)
let rewrite_down ?err_to_string ?visit ~(rw_fun : t abstract_expr -> rewrite)
    (expr : t) =
  let rw_alg e =
    let orig s = fix s in
    match rw_fun e with
    | Keep -> orig e
    | SomeInfo { v; __LINE__; __FILE__ } -> v
  in
  rw_recurse_down ~f:rw_alg expr

let drop_attrib a =
  let a =
    rewrite ~rw_fun:(AbstractExpr.drop_attrib %> fix %> replace [%here]) a
  in
  a

(** {1 Typing}*)
let type_of e = AbstractExpr.get_typ (unfix e)

(** {1 Additional traversals}*)

let return_type_alg e = AbstractExpr.get_typ e

let fold_with_type (alg : 'e abstract_expr -> 'a) =
  zygo_l ~cata return_type_alg alg

let fold_with_type_r (alg : 'e abstract_expr -> 'a) =
  zygo ~cata return_type_alg alg

(** typed expression rewriter *)
let rewrite_typed (f : (t * Types.t) abstract_expr -> t option) (expr : t) =
  let rw_alg e =
    let orig s = fix @@ AbstractExpr.map fst s in
    match f e with Some e -> e | None -> orig e
  in
  fold_with_type rw_alg expr


(** typed rewriter that expands two layers deep into the expression *)
let rewrite_typed_two ?visit
    (f : (t abstract_expr * Types.t) abstract_expr -> rewrite) (expr : t) =
  let rw_alg e =
    let unfold = AbstractExpr.map (fun (e, t) -> (unfix e, t)) e in
    let orig s = fix @@ AbstractExpr.map fst s in
    match f unfold with
    (*| Some n ->
        Option.iter
        (fun f ->
            f { from = orig e; into = n; __LINE__ = None; __FILE__ = None })
        visit;
        n *)
    | SomeInfo { v; __LINE__; __FILE__ } ->
        log_rw visit ~__LINE__ ~__FILE__ (orig e) v
    | Keep -> orig e
  in
  fold_with_type rw_alg expr
(** {1 Smart Constructors} *)
