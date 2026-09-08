let%expect_test "a" =
  print_endline "b";
  [%expect {| b |}]
