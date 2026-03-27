open Lang
open Containers

(* let () = Printexc.record_backtrace true *)

let e =
  Loader.Loadir.parse_expr_string
    "bvnand(bvnot(0x1c6a4ec2b:bv33), bvashr(bvudiv(0x1:bv33, \
     bvor(0x1633f1dbc:bv33, 0x1:bv33)), bvashr(0x3:bv33, 0x5222e27c:bv33)))"

let partial_and_full_eval s =
  let e = Loader.Loadir.parse_expr_string s in
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
    bvnand(bvnot(0x1c6a4ec2b:bv33),
     bvashr(bvudiv(0x1:bv33, bvor(0x1633f1dbc:bv33, 0x1:bv33)),
      bvashr(0x3:bv33, 0x5222e27c:bv33)))
    partial:
    0x1ffffffff:bv33
    eval:
    Some `Bitvector (0x1ffffffff:bv33)
    |}]

let%expect_test "shift_right negative bug 2" =
  partial_and_full_eval
    "bvshl(bvneg(bvnot(0xa9c9:bv16)), bvashr(bvneg(0x6dbe:bv16), \
     bvnot(0x1ac0:bv16)))";
  [%expect
    {|
    original:
    bvshl(bvneg(bvnot(0xa9c9:bv16)), bvashr(bvneg(0x6dbe:bv16), bvnot(0x1ac0:bv16)))
    partial:
    0x0:bv16
    eval:
    Some `Bitvector (0x0:bv16) |}]

let%expect_test "oom" =
  let _ =
    "boolnot(eq(bvlshr(bvsrem(bvor(0x1148eddde:bv33, 0xc3140fb6:bv33), \
     bvor(bvadd(0x8434f25b:bv33, 0x29774afc:bv33), 0x1:bv33)), \
     bvsrem(bvneg(0x19853c892:bv33), bvor(bvsub(0x89f237c8:bv33, \
     0x1c4effe96:bv33), 0x1:bv33))), 0x0:bv33))"
  in
  let s2 =
    "bvsmod(bvand(bvshl(0x2236652f8b6b4b3a:bv62, 0x33b2d13023f607b5:bv62), \
     0x2104bfbd0e7bebd1:bv62), bvor(0x7ea57bb7d5942bd:bv62, 0x1:bv62))"
  in
  let exp = Loader.Loadir.parse_expr_string s2 in
  CCOption.pp Ops.AllOps.pp_const Format.std_formatter (Expr_eval.eval_expr exp);
  [%expect {| Some `Bitvector (0x0:bv62) |}]

let%expect_test "concat" =
  let s = "bvconcat(0x0:bv36, 0x0:bv22)" in
  let exp = Loader.Loadir.parse_expr_string s in
  CCOption.pp Ops.AllOps.pp_const Format.std_formatter (Expr_eval.eval_expr exp);
  [%expect {| Some `Bitvector (0x0:bv58) |}]
