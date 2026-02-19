(** Intraprocedural analyses for programs not in ssa form. *)

open Lang
open Common
open Containers
open Lattice_types

module EvalExpr (V : ValueAbstraction) = struct
  type t

  let alg read e =
    let open Expr.AbstractExpr in
    match e with
    | RVar v -> read v
    | Constant c -> V.eval_const c
    | UnaryExpr (op, e) -> V.eval_unop op e
    | BinaryExpr (op, a, b) -> V.eval_binop op a b
    | ApplyIntrin (op, es) -> V.eval_intrin op es
    | _ -> failwith "unsupported"

  let eval read expr = V.E.cata (alg read) expr
end

module EvalExprWithType (V : TypedValueAbstraction) = struct
  type t

  let alg read e =
    let open Expr.AbstractExpr in
    let tt = V.E.type_alg (Expr.AbstractExpr.map snd e) in
    let r =
      match e with
      | RVar v -> read v
      | Constant c -> V.eval_const c tt
      | UnaryExpr (op, e) -> V.eval_unop op e tt
      | BinaryExpr (op, a, b) -> V.eval_binop op a b tt
      | ApplyIntrin (op, es) -> V.eval_intrin op es tt
      | _ -> failwith "unsupported"
    in
    (r, tt)

  let eval read expr =
    let open Expr.AbstractExpr in
    fst (V.E.cata (alg read) expr)
end

module EvalExprLog (V : TypedValueAbstraction) = struct
  type t

  module Eval = EvalExprWithType (V)

  let pretty_alg show_const show_unop show_binop show_intrin read e =
    let e_pretty = Expr.AbstractExpr.map fst e in
    let evaled = Eval.alg read (Expr.AbstractExpr.map snd e) in
    let pretty =
      let open Containers_pp in
      let eval_e = textpf "%s = " (V.show @@ fst evaled) in
      let print op lst =
        bracket " ("
          (eval_e
          ^ bracket "(" (text op ^ nest 2 (fill (text ";" ^ newline) lst)) ")")
          ")"
      in
      match e_pretty with
      | RVar v -> eval_e ^ text @@ V.E.Var.show v
      | Constant c -> eval_e ^ text @@ show_const c
      | UnaryExpr (op, e) -> print (show_unop op) [ e ]
      | BinaryExpr (op, a, b) -> print (show_binop op) [ a; b ]
      | ApplyIntrin (op, es) -> print (show_intrin op) es
      | _ -> failwith "unsupported"
    in
    (pretty, evaled)

  let eval show_const show_unop show_binop show_intrin read expr =
    let p, (v, _) =
      V.E.cata
        (pretty_alg show_const show_unop show_binop show_intrin read)
        expr
    in
    (v, p)
end

module EvalValueAbstraction
    (V : ValueAbstraction with module E = Expr.BasilExpr) =
struct
  type t

  module Eval = EvalExpr (V)

  let eval read expr = Eval.eval read expr
end

module ValueAbstractionIgnoringTypes (V : ValueAbstraction) = struct
  include V

  let eval_const op rt = eval_const op
  let eval_unop op arg rt = eval_unop op (fst arg)
  let eval_binop op arg1 arg2 rt = eval_binop op (fst arg1) (fst arg2)
  let eval_intrin op args rt = eval_intrin op (List.map fst args)
end

module EvalStmt
    (V : TypedValueAbstraction with module E = Expr.BasilExpr)
    (S : StateAbstraction with type val_t = V.t with type key_t = V.E.var) =
struct
  type t

  module EV = EvalExprWithType (V)

  let stmt_eval_fwd stmt dom =
    Stmt.map ~f_lvar:id
      ~f_rvar:(fun v -> S.read v dom)
      ~f_expr:(EV.eval (fun v -> S.read v dom))
      stmt

  let stmt_eval_rev stmt dom =
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
  include (
    struct
      module M = PatriciaTree.MakeMap (Var)

      type t = V.t M.t

      let name = V.name ^ "maplattice"
      let compare a b = M.reflexive_compare V.compare a b
      let bottom = M.empty
      let join a b = M.idempotent_union (fun v a b -> V.join a b) a b
      let equal a b = M.reflexive_equal V.equal a b

      let leq a b =
        M.reflexive_subset_domain_for_all2 (fun _ a b -> V.leq a b) a b

      let show m =
        Iter.from_iter (fun f -> M.iter (fun k v -> f (k, v)) m)
        |> Iter.to_string ~sep:", " (fun (k, v) ->
            Printf.sprintf "%s->%s" (Var.name k) (V.show v))

      let pretty v =
        let lst = M.to_list v in
        Containers_pp.(
          fill
            (text "," ^ newline)
            (List.map
               (fun (k, v) -> textpf "%s->%s" (Var.name k) (V.show v))
               lst))

      let to_iter m = Iter.from_iter (fun f -> M.iter (fun k v -> f (k, v)) m)
      let read (v : Var.t) m = M.find_opt v m |> Option.get_or ~default:V.bottom
      let update k v m = M.add k v m
      let widening a b = M.idempotent_union (fun v a b -> V.widening a b) a b

      type val_t = V.t
      type key_t = Var.t

      module V = V
    end :
      StateAbstraction with type val_t = V.t and type key_t = Var.t)

  type val_t = V.t
  type key_t = Var.t

  module V = V
end

module Forwards (D : Domain) = struct
  module AnalyseBlock = struct
    include D

    type edge = Procedure.G.edge

    let analyze (e : edge) (s : t) =
      match Procedure.G.E.label e with
      | Jump -> s
      | Block b -> begin
          assert (List.is_empty b.phis);
          Block.fold_forwards ~phi:(fun a _ -> a) ~f:D.transfer s b
        end
  end

  module A = Graph.ChaoticIteration.Make (Procedure.G) (AnalyseBlock)

  let name = D.name

  let analyse
      ?(widening_set = Graph.ChaoticIteration.Predicate (fun _ -> false))
      ?(widening_delay = 0) p =
    Trace_core.with_span ~__FILE__ ~__LINE__ D.name (fun _ ->
        Procedure.graph p
        |> Option.map (fun g ->
            A.recurse g (Procedure.topo_fwd p)
              (fun v -> D.init p)
              widening_set widening_delay))
    |> Option.get_or ~default:A.M.empty

  let print_dot fmt p analysis_result =
    Trace_core.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
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

module Backwards (D : Domain) = struct
  module AnalyseBlock = struct
    include D

    type edge = Procedure.G.edge

    let analyze (e : edge) (s : t) =
      match Procedure.G.E.label e with
      | Jump -> s
      | Block b -> begin
          assert (List.is_empty b.phis);
          Block.fold_backwards ~phi:(fun a _ -> a) ~f:D.transfer ~init:s b
        end
  end

  module A = Graph.ChaoticIteration.Make (Procedure.RevG) (AnalyseBlock)

  let name = D.name

  let analyse ~init
      ?(widening_set = Graph.ChaoticIteration.Predicate (fun _ -> false))
      ?(widening_delay = 0) p =
    Trace_core.with_span ~__FILE__ ~__LINE__ D.name (fun _ ->
        Procedure.graph p
        |> Option.map (fun g ->
            A.recurse g (Procedure.topo_rev p) init widening_set widening_delay))
    |> Option.get_or ~default:A.M.empty

  let print_dot fmt p analysis_result =
    Trace_core.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
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
