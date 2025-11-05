open Lang

let () = Printexc.record_backtrace true

let e =
  Ocaml_of_basil.Loadir.parse_expr_string
    "bvnand(bvnot(0x1c6a4ec2b:bv33), bvashr(bvudiv(0x1:bv33, \
     bvor(0x1633f1dbc:bv33, 0x1:bv33)), bvashr(0x3:bv33, 0x5222e27c:bv33)))"

let partial_and_full_eval s =
  let e = Ocaml_of_basil.Loadir.parse_expr_string s in
  print_endline "original: ";
  print_endline (Expr.BasilExpr.to_string e);
  print_endline "partial: ";
  print_endline @@ Expr.BasilExpr.to_string @@ Expr_eval.partial_eval_expr e;
  print_endline "eval: ";
  CCOption.pp Ops.AllOps.pp_const Format.std_formatter (Expr_eval.eval_expr e)

let%expect_test "shift_right negative bug" =
  partial_and_full_eval
    "bvnand(bvnot(0x1c6a4ec2b:bv33), bvashr(bvudiv(0x1:bv33, \
     bvor(0x1633f1dbc:bv33, 0x1:bv33)), bvashr(0x3:bv33, 0x5222e27c:bv33)))";
  [%expect
    {|
    original:
    bvnand(bvnot(0x1c6a4ec2b:bv33), bvashr(bvudiv(0x1:bv33, bvor(0x1633f1dbc:bv33, 0x1:bv33)), bvashr(0x3:bv33, 0x5222e27c:bv33)))
    partial:
    0x1ffffffff:bv33
    eval:
    Some `Bitvector (0x1ffffffff:bv33) |}]

let%expect_test "shift_right negative bug 2" =
  partial_and_full_eval
    "bvshl(bvneg(bvnot(0xa9c9:bv16)), bvashr(bvneg(0x6dbe:bv16), \
     bvnot(0x1ac0:bv16)))";
  [%expect.unreachable]
[@@expect.uncaught_exn
  {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)

  Invalid_argument("Z.shift_left: count argument must be positive")
  Raised by primitive operation at Z.shift_left in file "z.ml", line 180, characters 4-20
  Called from Lang__Value.PrimQFBV.shl in file "lib/lang/value.ml", line 150, characters 34-67
  Called from Lang__Expr_eval.eval_expr_alg in file "lib/lang/expr_eval.ml", line 41, characters 15-46
  Called from Lang__Expr_eval.partial_eval_alg in file "lib/lang/expr_eval.ml", line 82, characters 2-17
  Called from Lang__Expr.BasilExpr.rewrite.rw_alg in file "lib/lang/expr.ml", line 366, characters 12-20
  Called from Expr_eval_expect.partial_and_full_eval in file "test/lang/expr_eval_expect.ml", line 15, characters 47-76
  Called from Expr_eval_expect.(fun) in file "test/lang/expr_eval_expect.ml", lines 33-35, characters 2-26
  Called from Expect_test_nobase_collector.Make.Instance_io.exec in file "collector/expect_test_nobase_collector.ml", line 234, characters 12-19

  Trailing output
  ---------------
  original:
  bvshl(bvneg(bvnot(0xa9c9:bv16)), bvashr(bvneg(0x6dbe:bv16), bvnot(0x1ac0:bv16)))
  partial: |}]
