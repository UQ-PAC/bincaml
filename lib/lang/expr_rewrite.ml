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

open struct
  let type_of = unfix %> AbstractExpr.get_typ


    let msg_or ?err_to_string e =
        err_to_string
        |> Option.map (fun f -> f @@ e)
        |> Option.get_or ~default:"???"

  let log_rw visit ?__LINE__ ?__FILE__ o e =
    Option.iter
      (fun f ->
        let a = type_of o in
        let b = type_of e in
        if not @@ Types.equal a b then
          raise
            (Failure
               ("ill-typed rewrite " ^ Types.to_string a ^ " ~> "
              ^ Types.to_string b ^ " "
               ^ Option.get_or ~default:"" __FILE__
               ^ ":" ^ Option.get_or ~default:""
               @@ Option.map Int.to_string __LINE__));
        f { __LINE__; __FILE__; from = o; into = e })
      visit;
    e
end

(** substitute subexpression sbased on parameter *)
let rewrite ?visit ?err_to_string ~(rw_fun : t abstract_expr -> rewrite)
    (expr : t) =
  let rw_alg e =
    let orig s = fix s in
    match rw_fun e with
    | SomeInfo { v; __LINE__; __FILE__ }
      when Types.equal (type_of v) (type_of (orig e)) ->
        log_rw visit ~__LINE__ ~__FILE__ (fix e) v
    | SomeInfo { v; __LINE__; __FILE__ } ->
        failwith
        @@ Printf.sprintf "improper rewrite type: attempt to rewrite %s into %s"
             (msg_or ?err_to_string (orig e))
             (msg_or ?err_to_string v)
    | Keep -> orig e
  in
  cata rw_alg expr

(** substitute subexpression sbased on parameter *)
let rewrite_down ?err_to_string ?visit ~(rw_fun : t abstract_expr -> rewrite) (expr : t) =
  let rw_alg e =
    let orig s = fix s in
    match rw_fun e with
    | SomeInfo { v; __LINE__; __FILE__ }
      when Types.equal (type_of v) (type_of (orig e)) ->
        log_rw visit ~__LINE__ ~__FILE__ (fix e) v
    | SomeInfo { v; __LINE__; __FILE__ } ->
        failwith
        @@ Printf.sprintf "improper rewrite type: attempt to rewrite %s into %s"
             (msg_or ?err_to_string (orig e))
             (msg_or ?err_to_string v)
    | Keep -> orig e
  in
  rw_recurse_down ~f:rw_alg expr


let drop_attrib a =
let a =
    rewrite ~rw_fun:(AbstractExpr.drop_attrib %> fix %> replace [%here]) a
in
a
