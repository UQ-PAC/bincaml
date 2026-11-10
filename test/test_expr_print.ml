open Containers

let rec test_print_1 ~(indent : int) ~(depth : int) () =
  Format.open_hvbox (indent + 2);

  Format.print_string "asd";
  Format.print_string "(";
  Format.print_break 0 (indent + 2);

  Format.print_string "larg,";
  Format.print_break 1 (indent + 2);

  if depth > 0 then begin
    let depth = depth - 1 in
    let indent = indent + 2 in
    test_print_1 ~indent ~depth ();
    Format.print_string ",";
    Format.print_break 1 (indent + 2)
  end;

  Format.print_string "larg";
  Format.print_string ")";

  Format.close_box ()

let%expect_test "depth 0" =
  let depth = 0 in
  Format.set_margin 5;
  test_print_1 ~indent:0 ~depth ();
  Format.print_flush ();
  [%expect {|
    asd(
      larg,
      larg)
    |}];

  Format.set_margin 100;
  test_print_1 ~indent:0 ~depth ();
  Format.print_flush ();
  [%expect {| asd(larg, larg) |}]

let%expect_test "depth 2" =
  let depth = 2 in
  Format.set_margin 100;
  Format.set_max_indent 100;
  test_print_1 ~indent:0 ~depth ();
  Format.print_flush ();
  [%expect {| asd(larg, asd(larg, asd(larg, larg), larg), larg) |}];

  Format.set_margin 100;
  test_print_1 ~indent:0 ~depth ();
  Format.print_flush ();
  [%expect {| asd(larg, asd(larg, asd(larg, larg), larg), larg) |}]

let%expect_test "vbox" =
  Format.open_vbox 2;
  Format.print_string "f(";
  Format.print_cut ();

  Format.open_vbox 2;
  Format.print_string "x1.1";
  Format.print_cut ();
  Format.print_string "x1.2";
  Format.print_cut ();
  Format.close_box ();

  Format.print_string "x2";
  Format.print_string ")";
  Format.print_flush ();
  [%expect {|
    f(
      x1.1
      x1.2
      x2)
    |}]

let%expect_test "type_curry" =
  let open Bincaml_util in
  let t =
    Types.(curry [ Bitvector 1; Bitvector 2; Bitvector 3 ] (Bitvector 4))
  in
  let t2 =
    Types.(
      Function
        ( Bitvector 1,
          Function (Bitvector 2, Function (Bitvector 3, Bitvector 4)) ))
  in
  print_endline (Types.to_string t);
  print_endline (Types.to_string t2);
  let a, b = Types.uncurry t2 in
  Printf.printf "%s -> %s\n"
    (List.to_string Types.to_string a)
    (Types.to_string b);
  Printf.printf "==  %s\n" (Types.to_string (Types.curry a b));
  [%expect
    {|
    ((bv1)->((bv2)->(bv3->bv4)))
    ((bv1)->((bv2)->(bv3->bv4)))
    bv1, bv2, bv3 -> bv4
    ==  ((bv1)->((bv2)->(bv3->bv4)))
    |}]
