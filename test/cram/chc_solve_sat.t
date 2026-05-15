
CHC solver invocation (Step 3) — run the full pipeline on a trivially
provable assertion ([var a := 1; assert a = 1]) and confirm Z3/Spacer
returns sat. No model extraction yet; only the solver result matters.

  $ bincaml script chc_solve_sat.sexp
  (load-il chc_solve_sat.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (chc-solve)
  bincaml: [INFO] Submitting 3 predicates and 4 clauses to solver
  bincaml: [INFO] Solver returned sat
  sat
