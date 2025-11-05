open Lang
open Expr_eval
open Containers

let identity x = x

let simplify_proc_exprs p =
  let blocks = Procedure.blocks_to_list p in

  let open Procedure.Edge in
  List.iter
    (function
      | Procedure.Vert.Begin id, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
          let stmts =
            Vector.map
              (Stmt.map ~f_lvar:identity ~f_rvar:identity
                 ~f_expr:Algsimp.alg_simp_rewriter)
              b.stmts
          in
          Procedure.update_block p id { b with stmts }
      | _ -> ())
    blocks

let simplify_prog_exprs (p : Program.t) =
  ID.Map.iter (fun id proc -> simplify_proc_exprs proc) p.procs
