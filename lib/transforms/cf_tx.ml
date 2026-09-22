(** Intra-expression constant-folding *)

open Bincaml_util.Common
open Lang

let simplify_proc_exprs ?visit rewriter p =
  let blocks = Procedure.blocks_to_list p in
  List.fold_left
    (fun p e ->
      match e with
      | Procedure.Vert.Begin bid, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
          let stmts =
            Vector.map
              (Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:(rewriter ?visit))
              b.stmts
          in
          Procedure.update_block p bid { b with stmts }
      | _ -> p)
    p blocks

let simplify_proc_exprs_default ?visit p =
  simplify_proc_exprs ?visit Algsimp.alg_simp_rewriter p

let simplify_proc_exprs_readable_default ?visit p =
  simplify_proc_exprs ?visit Algsimp.readable p

let simplify_proc_spec_exprs ?visit rewriter p =
  let s = Procedure.specification p in
  let s =
    {
      s with
      requires = List.map (rewriter ?visit) s.requires;
      ensures = List.map (rewriter ?visit) s.ensures;
      rely = List.map (rewriter ?visit) s.rely;
      guarantee = List.map (rewriter ?visit) s.guarantee;
    }
  in
  Procedure.set_specification p s

let simplify_prog_spec_exprs rewriter ?visit (p : Program.t) =
  Program.map_procedures
    (fun _ proc -> simplify_proc_spec_exprs rewriter ?visit proc)
    p

let simplify_prog_exprs rewriter ?visit (p : Program.t) =
  let p =
    Program.map_procedures
      (fun _ proc -> simplify_proc_exprs rewriter ?visit proc)
      p
  in
  Program.map_decls
    Program.(
      fun id ->
        (function
        | Function { binding; attrib; definition } ->
            let definition =
              match definition with
              | Axiom b ->
                  let rw = rewriter ?visit b in
                  Axiom rw
              | Function b -> Function (rewriter ?visit b)
              | Uninterpreted -> Uninterpreted
            in
            Function { binding; attrib; definition }
        | o -> o))
    p

let to_smt (r : Expr.BasilExpr.rwinfo) =
  let open Lang.Expr_smt in
  let cexpr = Expr.BasilExpr.binexp ~op:`NEQ r.from r.into in
  let smt = snd @@ SMTLib2.assert_bexpr cexpr SMTLib2.empty in
  smt |> SMTLib2.to_sexp ~set_logic:false

let online_check visit (solver : Bincaml_util.Smt.Solver.t)
    (r : Expr.BasilExpr.rwinfo) =
  let open Bincaml_util.Smt in
  Solver.push solver;
  to_smt r |> Iter.iter (fun i -> Solver.add_command solver i);
  let res : Solver.result = Solver.check solver in
  (match res with
  | Sat ->
      let from = Solver.eval_expr solver (Expr_smt.SMTLib2.of_bexpr r.from) in
      let into = Solver.eval_expr solver (Expr_smt.SMTLib2.of_bexpr r.into) in
      visit (Some (from, into)) r
  | Unsat -> ()
  | Unknown -> visit None r);
  Solver.pop solver;
  ()

let online_check_all ?(debug = false) visit rws =
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log =
          (if debug then Bincaml_util.Smt.Config.printf_log
           else Bincaml_util.Smt.Config.quiet_log);
      }
  in
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
  let failures = ref [] in
  let visit (x : Expr.BasilExpr.rwinfo) =
    rewrites := x :: !rewrites;
    ()
  in
  let prog = simplify_prog_exprs Algsimp.alg_simp_rewriter ~visit x in
  let verror m e =
    failures := e :: !failures;
    print_error m e
  in
  online_check_all verror !rewrites;
  if not @@ List.is_empty !failures then raise (Failure "rewrite error");
  prog
