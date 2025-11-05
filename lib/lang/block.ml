open Common
open Containers
open Expr
open Stmt

type 'var phi = { lhs : 'var; rhs : (ID.t * 'var) list }
[@@deriving eq, ord, show]
(** a phi node representing the join of incoming edges assigned to a lhs
    variable*)

module V = struct
  type 'a t = 'a Vector.ro_vector

  let equal e a b = Vector.equal e a b
  let compare e a b = Vector.compare e a b
end

type ('v, 'e) t = {
  phis : 'v phi list;
      (** List of phi nodes simultaneously assigning each input variable *)
  stmts : ('v, 'v, 'e) Stmt.t V.t;  (** statement list *)
}
[@@deriving eq, ord]

let pretty_phi show_var v =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let lhs = show_var v.lhs in
  let rhs =
    List.map
      (function
        | bid, v -> (text @@ ID.to_string bid) ^ text " -> " ^ show_var v)
      v.rhs
  in
  lhs ^ text " := phi" ^ (bracket "(" (fill (text ", ") rhs)) ")"

let pretty show_lvar show_var show_expr ?(terminator = []) ?block_id b =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let phi =
    match b.phis with
    | [] -> []
    | o ->
        let phi = List.map (pretty_phi show_var) o in
        [ bracket "(" (fill (text ",") phi) ")" ]
  in
  let stmts =
    Vector.to_list b.stmts
    |> List.map (Stmt.pretty show_lvar show_var show_expr)
  in
  let stmts = phi @ stmts @ terminator in
  let stmts =
    bracket "["
      (nest 2 @@ newline ^ append_l ~sep:(text ";" ^ newline) stmts)
      "]"
  in
  let name =
    Option.map
      (fun id -> text "block " ^ text (ID.to_string id) ^ text " ")
      block_id
  in
  let name = Option.get_or ~default:nil name in
  name ^ stmts

let to_string b =
  let tt f v = Containers_pp.text (f v) in
  let b =
    pretty (tt Var.to_string) (tt Var.to_string) (tt BasilExpr.to_string) b
  in
  Containers_pp.Pretty.to_string ~width:80 b

let stmts_iter b = Vector.to_iter b.stmts

let fold_forwards ~(phi : 'acc -> 'v phi list -> 'acc)
    ~(f : 'acc -> ('v, 'v, 'e) Stmt.t -> 'acc) (i : 'a) (b : ('v, 'e) t) : 'acc
    =
  Iter.fold f (phi i b.phis) (Vector.to_iter b.stmts)

let foldi_backwards ~(f : 'acc -> int * ('v, 'v, 'e) Stmt.t -> 'acc)
    ~(phi : 'acc -> 'v phi list -> 'acc) ~(init : 'a) (b : ('v, 'e) t) : 'acc =
  Iter.fold f init
    (Vector.to_iter_rev (Vector.mapi (fun i b -> (i, b)) b.stmts))
  |> fun e -> phi e b.phis

let fold_backwards ~(f : 'acc -> ('v, 'v, 'e) Stmt.t -> 'acc)
    ~(phi : 'acc -> 'v phi list -> 'acc) ~(init : 'a) (b : ('v, 'e) t) : 'acc =
  Iter.fold f init (Vector.to_iter_rev b.stmts) |> fun e -> phi e b.phis
