(** Intra-expression constant-folding *)

open Bincaml_util.Common
open Lang
open Expr_eval

let simplify_proc_exprs p =
  let blocks = Procedure.blocks_to_list p in

  let open Procedure.Edge in
  List.fold_left
    (fun p e ->
      match e with
      | Procedure.Vert.Begin bid, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
          let stmts =
            Vector.map
              (Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:Algsimp.alg_simp_rewriter)
              b.stmts
          in
          Procedure.update_block p bid { b with stmts }
      | _ -> p)
    p blocks

let simplify_prog_exprs (p : Program.t) =
  let procs = ID.Map.map (fun proc -> simplify_proc_exprs proc) p.procs in
  { p with procs }
