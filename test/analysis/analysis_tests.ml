let () =
  let open Alcotest in
  run "Static Analysis"
    (Lattice_collections.tests @ Test_irreducible_loops.tests)
