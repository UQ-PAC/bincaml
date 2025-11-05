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
let bv_unop = [ `BVNOT; `BVNEG ]
let bv_ops_partial = [ `BVSREM; `BVSDIV; `BVUREM; `BVUDIV; `BVSMOD ]

let bv_ops_total =
  [
    `BVADD;
    `BVASHR;
    `BVMUL;
    `BVSHL;
    `BVNAND;
    `BVXOR;
    `BVOR;
    `BVSUB;
    `BVLSHR;
    `BVAND;
  ]

module ExprGen = struct
  open QCheck.Gen

  let arb_width = int_range 1 62
  let arb_bv_op = oneofl bv_ops_total

  let arb_unop l =
    let* op = oneofl bv_unop in
    return (Expr.BasilExpr.unexp ~op l)

  let arb_binop_total l r =
    let* op = oneofl bv_ops_total in
    return (Expr.BasilExpr.binexp ~op l r)

  let arb_binop_partial l r =
    let* op = oneofl bv_ops_partial in
    return (Expr.BasilExpr.binexp ~op l r)

  let arb_bv ?(min = 0) w =
    let* v =
      QCheck.Gen.int_range min
        (Value.PrimQFBV.ones ~size:w |> Value.PrimQFBV.value |> Z.to_int)
    in
    return (Value.PrimQFBV.of_int ~size:w v)

  let arb_bvconst ?min w =
    let* c = arb_bv ?min w in
    return (Expr.BasilExpr.bvconst c)

  let shallow_expr =
    let* w = arb_width in
    sized
    @@ fix (fun self n ->
        match n with
        | 0 -> arb_bvconst w
        | 1 -> arb_bvconst ~min:1 w
        | n ->
            frequency
              [
                (1, arb_bvconst w);
                (2, self 0 >>= arb_unop);
                ( 2,
                  let* l = self 0 in
                  let* r = self 0 in
                  arb_binop_total l r );
                ( 2,
                  let* l = self 0 in
                  let* r = self 1 in
                  arb_binop_partial l r );
              ])

  let eval_expr =
    let* exp = shallow_expr in
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
    Test.make ~count:1000 ~max_fail:3 ExprGen.arb_bvexpr (fun (exp, evaled) ->
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
