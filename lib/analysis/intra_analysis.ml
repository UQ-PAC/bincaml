(** Intraprocedural analyses for programs not in ssa form. *)

open Lang
open Common
open Containers

module type Lattice = sig
  val name : string

  type t

  val compare : t -> t -> int
  val show : t -> string
  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
  val widening : t -> t -> t
end

module type ValueAbstraction = sig
  include Lattice

  (** evaluate operators *)

  val eval_const : Lang.Ops.AllOps.const -> t
  val eval_unop : Lang.Ops.AllOps.unary -> t -> t
  val eval_binop : Lang.Ops.AllOps.binary -> t -> t -> t
  val eval_intrin : Lang.Ops.AllOps.intrin -> t list -> t
end

module type StateDomain = sig
  type t
  type val_t
  type key_t

  module V : Lattice with type t = val_t

  val show : t -> string
  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val read : key_t -> t -> val_t
  val update : key_t -> val_t -> t -> t
  val widening : t -> t -> t
end

module EvalValueAbstraction (V : ValueAbstraction) = struct
  type t

  let eval read expr =
    let open Expr.AbstractExpr in
    let eval_alg e =
      match e with
      | RVar v -> read v
      | Constant c -> V.eval_const c
      | UnaryExpr (op, e) -> V.eval_unop op e
      | BinaryExpr (op, a, b) -> V.eval_binop op a b
      | ApplyIntrin (op, es) -> V.eval_intrin op es
      | _ -> failwith "unsupported"
    in
    Lang.Expr.BasilExpr.cata eval_alg expr
end

module EvalStmt
    (V : ValueAbstraction)
    (S : StateDomain with type key_t = Var.t with type val_t = V.t) =
struct
  type t

  module EV = EvalValueAbstraction (V)

  let stmt_eval_fwd (stmt : Program.stmt) dom =
    Stmt.map ~f_lvar:id
      ~f_rvar:(fun v -> S.read v dom)
      ~f_expr:(EV.eval (fun v -> S.read v dom))
      stmt

  let stmt_eval_rev (stmt : Program.stmt) dom =
    Stmt.map ~f_lvar:(fun v -> S.read v dom) ~f_rvar:id ~f_expr:id stmt
end

let tf_forwards st (read_st : 'a -> Var.t -> 'b) (s : Program.stmt)
    (eval : ('b * Types.t) Expr.BasilExpr.abstract_expr -> 'b) tf_stmt =
  let open Expr in
  let open AbstractExpr in
  let alg e = match e with RVar e -> (read_st st) e | o -> eval o in
  tf_stmt
  @@ Stmt.map ~f_rvar:(read_st st) ~f_lvar:id
       ~f_expr:(BasilExpr.fold_with_type alg)
       s

module MapState (V : Lattice) = struct
  open struct
    module M = PatriciaTree.MakeMap (Var)
  end

  module V = V

  type val_t = V.t
  type key_t = Var.t
  type t = val_t M.t

  let to_iter m = Iter.from_iter (fun f -> M.iter (fun k v -> f (k, v)) m)

  let show m =
    Iter.from_iter (fun f -> M.iter (fun k v -> f (k, v)) m)
    |> Iter.to_string ~sep:", " (fun (k, v) ->
        Printf.sprintf "%s->%s" (Var.name k) (V.show v))

  let bottom = M.empty
  let join a b = M.idempotent_union (fun v a b -> V.join a b) a b
  let equal a b = M.reflexive_equal V.equal a b
  let compare a b = M.reflexive_compare V.compare a b
  let read (v : Var.t) m = M.find_opt v m |> Option.get_or ~default:V.bottom
  let update k v m = M.add k v m
  let widening a b = join a b
end

module type Analysis = sig
  include StateDomain

  val name : string
  val tf_stmt : t -> Program.stmt -> t
end

module type Transfer = sig
  type t

  val transfer : Program.stmt -> t -> t
end

(*
module type ForwardStmtTransfer = sig
  type t

  val do_assume :
    (Var.t -> t) -> Program.e -> is_guard:bool -> (Var.t * t) Iter.t

  val do_assert : (Var.t -> t) -> Program.e -> (Var.t * t) Iter.t
  val transfer : (Var.t, t, t) Stmt.t -> (Var.t * t) Iter.t
end

module type ReverseStmtTransfer = sig
  type t

  val do_assume :
    (Var.t -> t) -> Program.e -> is_guard:bool -> (Var.t * t) Iter.t

  val do_assert : (Var.t -> t) -> Program.e -> (Var.t * t) Iter.t
  val transfer : (t, Var.t, Program.e) Stmt.t -> (Var.t * t) Iter.t
end

module StateTransferFwd
    (S : StateDomain with type key_t = Var.t)
    (V : ValueAbstraction with type t = S.V.t)
    (SF : ForwardStmtTransfer with type t = S.val_t with type v = S.key_t) =
struct
  type t = S.t

  module EV = EvalValueAbstraction (V)

  let transfer (stmt : Program.stmt) dom =
    Stmt.map ~f_lvar:id
      ~f_rvar:(fun v -> S.read v dom)
      ~f_expr:(EV.eval (fun v -> S.read v dom))
      stmt
    |> SF.transfer
    |> Iter.fold (fun m (v, d) -> StateDomain.update v d m) dom
end

module StateTransferRev
    (V : ValueAbstraction)
    (SF : ReverseStmtTransfer with type t = V.t) =
struct
  open struct
    module StateDomain = MapState (V)
    module EV = EvalValueAbstraction (V)
  end

  type t = StateDomain.t

  let do_assume read e ~is_guard = SF.do_assume read e ~is_guard
  let do_assert read e = SF.do_assert read e

  let transfer (stmt : Program.stmt) dom =
    (match stmt with
      | Stmt.Instr_Assume { body; branch } ->
          SF.do_assume (fun v -> StateDomain.read v dom) ~is_guard:branch body
      | Stmt.Instr_Assert { body } ->
          SF.do_assert (fun v -> StateDomain.read v dom) body
      | stmt ->
          Stmt.map
            ~f_lvar:(fun v -> StateDomain.read v dom)
            ~f_rvar:id ~f_expr:id stmt
          |> SF.transfer)
    |> Iter.fold (fun m (v, d) -> StateDomain.update v d m) dom
end
*)

module Forwards (D : Analysis) = struct
  module AnalyseBlock = struct
    include D

    type edge = Procedure.G.edge

    let analyze (e : edge) (s : t) =
      match Procedure.G.E.label e with
      | Jump -> s
      | Block b -> begin
          assert (List.is_empty b.phis);
          Block.fold_forwards ~phi:(fun a _ -> a) ~f:D.tf_stmt s b
        end
  end

  module A = Graph.ChaoticIteration.Make (Procedure.G) (AnalyseBlock)

  let name = D.name

  let analyse ~init
      ?(widening_set = Graph.ChaoticIteration.Predicate (fun _ -> false))
      ?(widening_delay = 0) p =
    Trace.with_span ~__FILE__ ~__LINE__ D.name (fun _ ->
        Procedure.graph p
        |> Option.map (fun g ->
            A.recurse g (Procedure.topo_fwd p) init widening_set widening_delay))
    |> Option.get_or ~default:A.M.empty

  let print_dot fmt p analysis_result =
    Trace.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
    let to_dot graph =
      let r =
       fun v -> Option.get_or ~default:D.bottom (A.M.find_opt v analysis_result)
      in
      let (module M : Viscfg.ProcPrinter) =
        Viscfg.dot_labels (fun v -> Some (D.show (r v)))
      in
      M.fprint_graph fmt graph
    in
    Option.iter to_dot (Procedure.graph p)
end

module Backwards (D : Analysis) = struct
  module AnalyseBlock = struct
    include D

    type edge = Procedure.G.edge

    let analyze (e : edge) (s : t) =
      match Procedure.G.E.label e with
      | Jump -> s
      | Block b -> begin
          assert (List.is_empty b.phis);
          Block.fold_backwards ~phi:(fun a _ -> a) ~f:D.tf_stmt ~init:s b
        end
  end

  module A = Graph.ChaoticIteration.Make (Procedure.RevG) (AnalyseBlock)

  let name = D.name

  let analyse ~init
      ?(widening_set = Graph.ChaoticIteration.Predicate (fun _ -> false))
      ?(widening_delay = 0) p =
    Trace.with_span ~__FILE__ ~__LINE__ D.name (fun _ ->
        Procedure.graph p
        |> Option.map (fun g ->
            A.recurse g (Procedure.topo_rev p) init widening_set widening_delay))
    |> Option.get_or ~default:A.M.empty

  let print_dot fmt p analysis_result =
    Trace.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
    let to_dot graph =
      let r =
       fun v -> Option.get_or ~default:D.bottom (A.M.find_opt v analysis_result)
      in
      let (module M : Viscfg.ProcPrinter) =
        Viscfg.dot_labels (fun v -> Some (D.show (r v)))
      in
      M.fprint_graph fmt graph
    in
    Option.iter to_dot (Procedure.graph p)
end
