(* The sp domain for postcondition inference *)
(* Assumes SSA form *)

open Lang
open Common
open Expr

module type FunctionSummaryAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
end

module Domain (S : FunctionSummaryAnnotation) = struct
  let name = "SP domain"

  type t = Program.e

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let top = BasilExpr.boolconst false
  let bottom = BasilExpr.boolconst true
  let join a b = BasilExpr.applyintrin ~op:`AND [ a; b ]
  let leq a b = failwith "leq not implemented"
  let widening a b = top

  let simplify =
    let open AbstractExpr in
    let open BasilExpr in
    let rw = BasilExpr.rewrite ~rw_fun:(function _ -> Keep) in
    rw % rw

  let substitute_vars (a : (Var.t * t) list) (p : t) : t =
    BasilExpr.substitute
      (fun v ->
        List.find_map (fun (v', e) -> Option.return_if (Var.equal v v') e) a)
      p
    |> simplify

  let substitute_var_names (a : (string * t) list) (p : t) : t =
    BasilExpr.substitute
      (fun v ->
        List.find_map
          (fun (v', e) -> Option.return_if (String.equal (Var.name v) v') e)
          a)
      p
    |> simplify

  let transfer (p : t) (stmt : Program.stmt) : t =
    let open Stmt in
    let o = match stmt with
    (* Rule for assign needs no existential as we assume SSA. *)
    | Instr_Assign (a : (Var.t * BasilExpr.t) list) ->
        a
        |> List.map (function a, b ->
            BasilExpr.binexp ~op:`EQ (BasilExpr.rvar a) b)
        |> List.fold_left (fun a p -> join a p) p
    | Instr_Assume { body; branch = false } -> join p body
    | Instr_Assert { body } -> join p body
    | Instr_Call { lhs; procid; args } ->
        let sub s =
          s
          |> substitute_var_names (StringMap.to_list args)
          |> substitute_var_names
               (StringMap.to_list lhs
               |> List.map (fun (i, v) -> (i, BasilExpr.rvar v)))
        in
        let r =
          List.fold_left (fun a b -> join a (sub b)) top (S.ensures procid)
        in
        join p r
    | Instr_Store
        {
          lhs;
          rhs;
          value;
          addr = Addr { addr : 'e; size : int; endian : endian };
        } ->
        join p
          (BasilExpr.binexp ~op:`EQ value
             (BasilExpr.binexp
                ~op:(`Load (endian, size))
                (BasilExpr.rvar lhs) addr))
    | s ->
        failwith
          (Printf.sprintf "uh oh: %s"
          @@ Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty s)
          in
          print_endline "\n-------------------";
          print_endline @@ BasilExpr.to_string o;
          o

  let init proc = bottom

  let transfer_phi (a : t) (b : Var.t Block.phi) : t =
    failwith "transfer_phi not implemented"

  let to_pred =
    Algsimp.Comb.to_steady Expr.BasilExpr.equal Algsimp.alg_simp_rewriter
end

module IntraDomain = Domain (struct
  let requires = const []
  let ensures = const []
end)

module IntraAnalysis = Intra_analysis.Forwards (IntraDomain)

let%test "magic" = false
