open Lang
open Containers
open Fun

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
    Expr_gen.gen_bvexpr (1, wd)

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

let check_success_smt query =
  let stdout, stderr, _ = CCUnix.call ~stdin:(`Str query) "cvc5" in
  match String.lines (String.trim stdout) |> List.rev with
  | "success" :: _ -> true
  | e :: _
    when CCString.mem ~sub:"invalid argument '0' for 'size'"
           (String.lowercase_ascii e) ->
      QCheck.assume_fail ()
  | o :: _ -> failwith ("smt error: " ^ o)
  | o -> failwith stdout

let run_smt query =
  let stdout, stderr, _ = CCUnix.call ~stdin:(`Str query) "cvc5" in
  match String.trim stdout with
  | "unsat" -> `UNSAT
  | "sat" -> `SAT query
  | e -> `UNKNOWN (e, stdout ^ stderr)

let check_res res =
  match res with
  | `UNSAT -> true
  | `SAT q ->
      print_endline q;
      print_endline "";
      false
  | `UNKNOWN (e, stderr)
    when CCString.mem ~sub:"invalid argument '0' for 'size'"
           (String.lowercase_ascii e) ->
      QCheck.assume_fail ()
  | `UNKNOWN (e, stderr) -> failwith (e ^ "\n" ^ stderr)

let partial_eval_test =
  let open QCheck in
  Test.make ~name:"partial eval matches smt" ~count:300 ~max_fail:3
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
  check_res (run_smt (smt ^ "\n(exit)"))
(*let smt = Lang.Expr_smt.*)

let () = Printexc.record_backtrace true

module StringMap = Map.Make (String)
module SMT = Bincaml_util.Smt.Solver

let check_smt =
  let gen =
    let open QCheck.Gen in
    let* e = Expr_gen.gen_expr in
    let e = (Expr.BasilExpr.rewrite_typed_two Algsimp.drop_assoc) e in
    let smt = Expr_smt.SMTLib2.of_bexpr e in
    let parsed = Expr_smt.SMTLib2.expr_of_smt StringMap.empty smt in
    return (e, smt, parsed)
  in

  let arb =
    QCheck.make
      ~print:(fun (a, s, e) ->
        Expr.BasilExpr.to_string a ^ " -> " ^ Sexp.to_string s ^ " -> "
        ^ match e with None -> "none" | Some e -> Expr.BasilExpr.to_string e)
      gen
  in

  let valid_predicate (e, smt, p) =
    let check_p =
      Expr_smt.SMTLib2.of_bexpr
      @@ Expr.BasilExpr.boolnot (Expr.BasilExpr.binexp ~op:`EQ e e)
    in
    let query =
      "(set-logic QF_BV)\n(set-option :print-success true)\n"
      ^ Sexp.to_string
          (Expr_smt.SMTLib2.add_assert check_p Expr_smt.SMTLib2.empty |> fst)
      ^ "\n(exit)"
    in
    check_success_smt query
  in

  let roundtrip_predicate (e, smt, p) =
    p
    |> Option.exists
         (Expr.BasilExpr.rewrite_typed_two Algsimp.drop_assoc
         %> Expr.BasilExpr.equal e)
  in

  [
    QCheck.Test.make ~name:"expr smt roundtrip" ~count:1000 ~max_fail:1 arb
      roundtrip_predicate;
    QCheck.Test.make ~name:"expr valid smt" ~count:30 ~max_fail:1 arb
      valid_predicate;
  ]

let _ =
  let suite =
    List.map
      (QCheck_alcotest.to_alcotest ~long:true ~speed_level:`Slow ~verbose:true)
      (partial_eval_test :: check_smt)
  in
  Alcotest.run "smtlib exprs" [ ("bv", suite) ]
