(** Intra-expression constant-folding *)

open Bincaml_util.Common
open Lang
open Expr_eval

let simplify_proc_exprs ?visit p =
  let blocks = Procedure.blocks_to_list p in

  let open Procedure.Edge in
  List.fold_left
    (fun p e ->
      match e with
      | Procedure.Vert.Begin bid, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
          let stmts =
            Vector.map
              (Stmt.map ~f_lvar:id ~f_rvar:id
                 ~f_expr:(Algsimp.alg_simp_rewriter ?visit))
              b.stmts
          in
          Procedure.update_block p bid { b with stmts }
      | _ -> p)
    p blocks

let simplify_prog_exprs ?visit (p : Program.t) =
  let procs =
    ID.Map.map (fun proc -> simplify_proc_exprs ?visit proc) p.procs
  in
  { p with procs }

let to_smt (r : Expr.BasilExpr.rwinfo) =
  let open Lang.Expr_smt in
  let cexpr = Expr.BasilExpr.binexp ~op:`NEQ r.from r.into in
  let smt = snd @@ SMTLib2.assert_bexpr cexpr SMTLib2.empty in
  smt |> SMTLib2.to_sexp ~set_logic:false

let online_check visit (solver : Bincaml_util.Solver.solver)
    (r : Expr.BasilExpr.rwinfo) =
  let open Bincaml_util in
  let _ = solver.command (Solver.push 1) in
  to_smt r |> Iter.iter (fun i -> ignore @@ solver.command i);
  let res : Solver.result = Solver.check solver in
  (match res with
  | Sat ->
      let from =
        Solver.get_expr solver (fst @@ Expr_smt.SMTLib2.of_bexpr r.from)
      in
      let into =
        Solver.get_expr solver (fst @@ Expr_smt.SMTLib2.of_bexpr r.into)
      in
      visit (Some (from, into)) r
  | Unsat -> ()
  | Unknown -> visit None r);
  let _ = solver.command (Solver.pop 1) in
  ()

let online_check_all visit rws =
  let solver = Bincaml_util.Solver.new_solver Bincaml_util.Solver.cvc5 in
  List.iter (online_check visit solver) rws

let print_error model (rw : Expr.BasilExpr.rwinfo) =
  let m =
    model
    |> Option.map (function a, b ->
        "  counterexample: " ^ Sexp.to_string a ^ " != " ^ Sexp.to_string b)
    |> Option.get_or ~default:""
  in
  Printf.fprintf stdout "%s\n\n"
  @@ "unsound rewrite "
  ^ Option.get_or ~default:"" rw.__FILE__
  ^ ":"
  ^ Option.get_or ~default:"" (Option.map Int.to_string rw.__LINE__)
  ^ "\n   "
  ^ Expr.BasilExpr.show_rwinfo rw
  ^ "\n" ^ m

(*
let write_smt_checks ls fname =
  let smt = List.fold_left to_smt Lang.Expr_smt.SMTLib2.empty ls in
  let sexp = Lang.Expr_smt.SMTLib2.to_sexp smt in
  Sexp.to_file_iter fname sexp;
  ()

*)

let simplify_prog_with_smt_check x =
  let rewrites = ref [] in
  let visit (x : Expr.BasilExpr.rwinfo) =
    rewrites := x :: !rewrites;
    ()
  in
  let prog = simplify_prog_exprs ~visit x in
  online_check_all print_error !rewrites;
  prog
