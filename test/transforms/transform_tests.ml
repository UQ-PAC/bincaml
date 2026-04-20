let () =
  let cntlm =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main (max: bv64) -> (evens: bv64, odds: bv64, i: bv64)
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    var i: bv64 := 0x0:bv64;
    var even: bv64 := 0x0:bv64;
    var odd: bv64 := 0x0:bv64;
    goto(%odd, %even, %exit);
  ];
  block %even [
    guard (booland(eq(bvand(0x1:bv64, i:bv64), 0x0:bv64), boolnot(eq(i:bv64, max:bv64))));
    var even: bv64 := bvadd(even:bv64, 0x1:bv64);
    var i: bv64 := bvadd(i:bv64, 0x1:bv64);
    goto(%odd, %even, %exit);
  ];
  block %odd [
    guard (booland(boolnot(eq(bvand(0x1:bv64, i:bv64), 0x0:bv64)), boolnot(eq(i:bv64, max:bv64))));
    var odd: bv64 := bvadd(odd:bv64, 0x1:bv64);
    var i: bv64 := bvadd(i:bv64, 0x1:bv64);
    goto(%even, %even, %exit);
  ];
  block %exit [
    guard (eq(i:bv64, max:bv64));
    return (even, odd, i);
  ]
];
    |}
  in
  let cntlm_dsa =
    Bincaml.Passes.PassManager.(run_transform cntlm.prog irreducible_loop)
  in

  let suite =
    List.map
      (QCheck_alcotest.to_alcotest ~speed_level:`Slow ~verbose:true)
      (Bincaml_transform_check.Transform_check
       .make_differential_test_cases_for_prog cntlm.prog cntlm_dsa)
  in
  Alcotest.run "transform tests" [ ("qcheck irreducible-loop", suite) ]
