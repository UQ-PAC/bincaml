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

let pretty_phi show_lvar show_var v =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let lhs = show_lvar v.lhs in
  let rhs =
    List.map
      (function
        | bid, v -> (text @@ ID.to_string bid) ^ text " -> " ^ show_var v)
      v.rhs
  in
  lhs ^ text " := phi"
  ^ (bracket "(" (nest 2 (fill (text "," ^ newline) rhs))) ")"

let show_phi show_var =
  pretty_phi show_var show_var %> Containers_pp.Pretty.to_string ~width:80

let pretty show_lvar show_var show_expr ?(terminator = []) ?block_id b =
  Trace_core.with_span ~__FILE__ ~__LINE__ "pretty-block" @@ fun _ ->
  let open Containers_pp in
  let open Containers_pp.Infix in
  let phi =
    match b.phis with
    | [] -> []
    | o ->
        let phi = List.map (pretty_phi show_lvar show_var) o in
        [ bracket "(" (fill (text "," ^ newline) phi) ")" ]
  in
  let stmts =
    Vector.to_list b.stmts
    |> List.map (Stmt.pretty show_lvar show_var show_expr)
  in
  let stmts = phi @ stmts @ terminator |> List.map (fun i -> i ^ text ";") in
  let bracket' l d r : t =
    group (text l ^ nest (String.length l) d ^ nl ^ text r)
  in
  let stmts = bracket' "[" (nest 2 @@ nl ^ append_nl stmts) "]" in
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

let stmts_iter_i b = Vector.mapi (fun i j -> (i, j)) b.stmts |> Vector.to_iter
let stmts_iter b = Vector.to_iter b.stmts

let fold_forwards ~(phi : 'acc -> 'v phi list -> 'acc)
    ~(f : 'acc -> ('v, 'v, 'e) Stmt.t -> 'acc) (i : 'a) (b : ('v, 'e) t) : 'acc
    =
  Iter.fold f (phi i b.phis) (Vector.to_iter b.stmts)

let map_fold_forwards ~(phi : 'acc -> 'v phi list -> 'acc * 'v phi list)
    ~(f : 'acc -> ('v, 'v, 'e) Stmt.t -> 'acc * ('v, 'v, 'e) Stmt.t) (i : 'a)
    (b : ('v, 'e) t) : 'acc * ('v, 'e) t =
  let acc, phis = phi i b.phis in
  let acc, stmts =
    Iter.fold
      (fun (a, stmts) s ->
        let a, s' = f a s in
        (a, Iter.snoc stmts s'))
      (acc, Iter.empty) (Vector.to_iter b.stmts)
  in
  let stmts = Vector.of_iter stmts |> Vector.freeze in
  (acc, { phis; stmts })

let map ~phi f (b : ('v, 'e) t) : ('vv, 'ee) t =
  { stmts = Vector.map f b.stmts; phis = phi b.phis }

let flat_map ~phi f (b : ('v, 'e) t) : ('vv, 'ee) t =
  {
    stmts =
      Vector.to_iter b.stmts |> Iter.flat_map f |> Vector.of_iter
      |> Vector.freeze;
    phis = phi b.phis;
  }

let foldi_backwards ~(f : 'acc -> int * ('v, 'v, 'e) Stmt.t -> 'acc)
    ~(phi : 'acc -> 'v phi list -> 'acc) ~(init : 'a) (b : ('v, 'e) t) : 'acc =
  Iter.fold f init
    (Vector.to_iter_rev (Vector.mapi (fun i b -> (i, b)) b.stmts))
  |> fun e -> phi e b.phis

let fold_backwards ~(f : 'acc -> ('v, 'v, 'e) Stmt.t -> 'acc)
    ~(phi : 'acc -> 'v phi list -> 'acc) ~(init : 'a) (b : ('v, 'e) t) : 'acc =
  Iter.fold f init (Vector.to_iter_rev b.stmts) |> fun e -> phi e b.phis

let assigned_vars_iter b =
  let phi = List.to_iter b.phis |> Iter.map (fun b -> b.lhs) in
  let bls = stmts_iter b |> Iter.flat_map Stmt.iter_assigned in
  Iter.append phi bls

let read_vars_iter b =
  let phi =
    List.to_iter b.phis
    |> Iter.flat_map (fun b ->
        b.rhs |> List.to_iter |> Iter.map (fun (_, v) -> v))
  in
  let bls = stmts_iter b |> Iter.flat_map Stmt.free_vars_iter in
  Iter.append phi bls
