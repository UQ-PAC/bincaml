let () =
  let cntlm = Loader.Loadir.ast_of_fname "../../examples/irreducible_loop_1.il" in
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
