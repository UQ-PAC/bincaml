(** Intraprocedural analyses for programs not in ssa form. *)

open Lang
open Common
open Containers

module type ValDomain = sig
  val name : string

  type t

  val show : t -> string
  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val widening : t -> t -> t
  (*val eval : ('c, 'v, 'e, 'f, 'g, t * Types.t) Expr.AbstractExpr.t -> t*)
end

module type StateDomain = sig
  type edge = Procedure.G.edge
  type t
  type val_t
  type key_t

  val show : t -> string
  val bottom : t
  val join : t -> t -> t
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val read : key_t -> t -> val_t
  val update : key_t -> val_t -> t -> t
  val widening : t -> t -> t
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

module MapState (V : ValDomain) = struct
  type edge = Procedure.G.edge

  module M = Map.Make (Var)

  type val_t = V.t
  type key_t = Var.t
  type t = val_t M.t

  let show m =
    M.to_iter m
    |> Iter.to_string ~sep:", " (fun (k, v) ->
        Printf.sprintf "%s->%s" (Var.name k) (V.show v))

  let bottom = M.empty
  let join a b = M.union (fun v a b -> Some (V.join a b)) a b
  let equal a b = M.equal V.equal a b
  let compare a b = M.compare V.compare a b
  let read (v : Var.t) m = M.get_or ~default:V.bottom v m
  let update k v m = M.add k v m
  let widening a b = join a b
end

module type Analysis = sig
  include StateDomain

  val name : string
  val tf_stmt : t -> Program.stmt -> t
end

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
