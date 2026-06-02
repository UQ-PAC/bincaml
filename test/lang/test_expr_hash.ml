open Lang
open Expr

let%expect_test "hash" =
  let peq s a = if a then s ^ " equal" else s ^ "not equal" in
  let a0 = Loader.Loadir.parse_expr_string "bvnot(1:bv64)" in
  let a = ExprHashCons.of_expr a0 in
  let b0 = Loader.Loadir.parse_expr_string "bvnot(0x1:bv64)" in
  let b = ExprHashCons.of_expr b0 in
  let m =
    Printf.sprintf "%s =\n%s\n" (ExprHashCons.show_dbg a)
      (ExprHashCons.show_dbg b)
  in
  print_endline @@ peq "basilexpr " (BasilExpr.equal a0 b0);
  print_endline @@ peq m (ExprHashCons.equal a b);
  print_endline
  @@ peq "basilattrdrop "
       (BasilExpr.equal (BasilExpr.drop_attrib a0) (BasilExpr.drop_attrib b0));
  [%expect
    {|
    basilexpr not equal
    1:883721435:311146716=bvnot(0x1:bv64: bv64): bv64==UnaryExpr {attrib = {  }; op = `BVNOT; arg = 0; typ = bv64} =
    1:883721435:311146716=bvnot(0x1:bv64: bv64): bv64==UnaryExpr {attrib = {  }; op = `BVNOT; arg = 0; typ = bv64}
     equal
    basilattrdrop  equal
    |}]
