let () =
  let cntlm =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h1, %h2);
  ];
  block %h1 [
    goto(%h2);
  ];
  block %h2 [
    goto(%h1, %h3);
  ];
  block %h3 [
    goto(%h2, %exit);
  ];
  block %exit [
    return ();
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
