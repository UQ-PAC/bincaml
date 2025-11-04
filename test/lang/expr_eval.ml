open Lang
open Containers

(** `Extract (hi, lo); `SignExtend n; `ZeroExtend n; `Integer i; `Bitvector z;
    `Forall; `Old; `INTNEG; `Exists; `IMPLIES; `INTLE; `AND; `OR; `INTLT;

    `BoolNOT; *)

(*
let int_ops = [ `INTDIV; `INTADD; `INTMOD; `INTMUL; `INTSUB ]
let rel_bv_ops = [ `NEQ; `EQ; `BVULT; `BVSLE; `BVULE; `BVSLT ]
let bv_other_ops = [ `BVConcat ]
*)

module EvalExprGen = struct
  let eval_expr =
    let open QCheck.Gen in
    let* wd = Expr_gen.gen_width in
    let* exp = Expr_gen.gen_bvexpr (5, wd) in
    let evaled = Expr_eval.partial_eval_expr exp in
    return (exp, evaled)

  let arb_bvexpr =
    QCheck.make
      ~print:(fun (e, evaled) ->
        Printf.sprintf "%s ~> %s"
          (Expr.BasilExpr.to_string e)
          (Expr.BasilExpr.to_string evaled))
      eval_expr
end

let run_smt query =
  let stdout, stderr, _ = CCUnix.call ~stdin:(`Str query) "cvc5" in
  match String.trim stdout with
  | "unsat" -> `UNSAT
  | "sat" -> `SAT query
  | e -> `UNKNOWN (e, stderr)

let test =
  QCheck.(
    Test.make ~count:1000 ~max_fail:3 EvalExprGen.arb_bvexpr (fun (exp, evaled) ->
        let comparison =
          Expr.BasilExpr.boolnot (Expr.BasilExpr.binexp ~op:`EQ exp evaled)
        in
        let smt = Expr_smt.SMTLib2.check_sat_bexpr comparison in
        let smt = Iter.map Sexp.to_string smt in
        let smt = String.concat_iter ~sep:"\n" smt in
        let res = run_smt smt in
        (*let smt = Lang.Expr_smt.*)
        match res with
        | `UNSAT -> true
        | `SAT q ->
            print_endline q;
            print_endline "";
            false
        | `UNKNOWN (e, stderr) -> failwith (e ^ "\n" ^ stderr)))

let _ = QCheck_base_runner.run_tests_main [ test ]
