open Common
open Containers
open Expr
open Stmt

(*
type 'var sigma = { rhs : 'var; lhs : (ID.t * 'var) list }
[@@deriving eq, ord, show]
*)

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
  attrib : Attrib.attrib_map;
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
  let bracket' ~n l d r : t = group (text l ^ nest n (nl ^ d) ^ nl ^ text r) in
  let phi =
    match b.phis with
    | [] -> nil
    | o ->
        let phi = List.map (pretty_phi show_lvar show_var) o in
        bracket' ~n:2 "("
          (append_l ~sep:(text "," ^ nl) (List.map group phi))
          ") "
  in
  let stmts =
    Vector.to_list b.stmts
    |> List.map (Stmt.pretty show_lvar show_var show_expr)
  in
  let stmts = stmts @ terminator |> List.map (fun i -> i ^ text ";") in
  let stmts = phi ^ bracket' ~n:2 "[" (append_nl stmts) "]" in
  let attrib = Expr.BasilExpr.pretty_attr b.attrib in
  let name =
    Option.map
      (fun id -> text "block " ^ text (ID.to_string id) ^ attrib ^ text " ")
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
  (acc, { phis; stmts; attrib = b.attrib })

let map ~phi f (b : ('v, 'e) t) : ('vv, 'ee) t =
  { stmts = Vector.map f b.stmts; phis = phi b.phis; attrib = b.attrib }

(** Modify stmt list by creating a mutable copy of the underlying vector *)
let fmap_stmts_copy (f : (('a, 'a, 'b) Stmt.t, 'mut) Vector.t -> unit) b =
  let v = Vector.copy b.stmts in
  f v;
  { b with stmts = Vector.freeze v }

let clear_stmts (b : ('v, 'e) t) =
  { b with stmts = Vector.create () |> Vector.freeze }

(** prepend statements to block statement list (copies underlying vector) *)
let prepend_stmts (b : ('v, 'e) t) (nstmts : ('v, 'v, 'e) Stmt.t list) :
    ('v, 'e) t =
  let stmts = Vector.create () in
  Vector.append_list stmts nstmts;
  Vector.append stmts b.stmts;
  let stmts = Vector.freeze stmts in
  { b with stmts }

(** append statements to block statement list (copies underlying vector) *)
let append_stmts (b : ('v, 'e) t) (stmt : ('v, 'v, 'e) Stmt.t list) :
    ('vv, 'ee) t =
  fmap_stmts_copy (fun v -> Vector.append_list v stmt) b

let flat_map ?(rev = false) ~phi f (b : ('v, 'e) t) : ('vv, 'ee) t =
  let it = if rev then Vector.to_iter_rev else Vector.to_iter in
  let ot e = (if rev then Iter.rev e else e) |> Vector.of_iter in
  {
    stmts = it b.stmts |> Iter.flat_map f |> ot |> Vector.freeze;
    phis = phi b.phis;
    attrib = b.attrib;
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

(** free variables, also known as live variables. Given the initial free
    variables init following this block*)
let free_vars ?(init = VarSet.empty) (b : (Var.t, BasilExpr.t) t) =
  (* live vars transfer function for a statement *)
  fold_backwards
    ~f:Stmt.(fun init -> free_vars ~init)
    ~phi:(fun a phis ->
      List.fold_left
        (fun acc ->
          (function
          | { lhs; rhs } ->
              VarSet.remove lhs acc |> fun l ->
              VarSet.add_list l (List.map snd rhs)))
        a phis)
    ~init b
