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
    Expr_gen.gen_bvexpr (2, wd)

  let arb_bvexpr = QCheck.make ~print:Expr.BasilExpr.to_string eval_expr

  let arb_partial_eval_bvexpr =
    QCheck.make ~print:(fun (e, p) ->
        Printf.sprintf "%s ~> %s"
          (Expr.BasilExpr.to_string e)
          (Expr.BasilExpr.to_string (Lazy.force p)))
    @@
    let open QCheck.Gen in
    let* exp = eval_expr in
    let partial = lazy (Expr_eval.partial_eval_expr exp) in
    return (exp, partial)
end

let run_smt query =
  let stdout, stderr, _ = CCUnix.call ~stdin:(`Str query) "cvc5" in
  match String.trim stdout with
  | "unsat" -> `UNSAT
  | "sat" -> `SAT query
  | e -> `UNKNOWN (e, stderr)

let partial_eval_test =
  let open QCheck in
  Test.make ~name:"partial eval test" ~count:1000 ~max_fail:3
    EvalExprGen.arb_partial_eval_bvexpr
  @@ fun (exp, evaled) ->
  let evaled =
    try Lazy.force evaled
    with exc ->
      Printf.printf "exc: %s\n%s\n" (Printexc.to_string exc)
        (Expr.BasilExpr.to_string exp);
      raise exc
  in

  let comparison =
    Expr.BasilExpr.boolnot (Expr.BasilExpr.binexp ~op:`EQ exp evaled)
  in
  let smt =
    comparison |> Expr_smt.SMTLib2.check_sat_bexpr |> Iter.map Sexp.to_string
    |> String.concat_iter ~sep:"\n"
  in
  let res = run_smt smt in
  (*let smt = Lang.Expr_smt.*)
  match res with
  | `UNSAT -> true
  | `SAT q ->
      print_endline q;
      print_endline "";
      false
  | `UNKNOWN (e, stderr)
    when CCString.mem ~sub:"invalid argument '0' for 'size'"
           (String.lowercase_ascii e) ->
      assume_fail ()
  | `UNKNOWN (e, stderr) -> failwith (e ^ "\n" ^ stderr)

let () = Printexc.record_backtrace true

let _ =
  let suite = List.map QCheck_alcotest.to_alcotest [ partial_eval_test ] in
  Alcotest.run "smteval cvc qcheck" [ ("bv", suite) ]
