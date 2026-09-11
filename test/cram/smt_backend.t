  $ bincaml script ./smt_backend.sexp
  (load-il ./smt_backend.il)
  (run-transforms ssa)
  (run-transforms cfa-reduction)
  (run-transforms inline-summaries)
  (dump-smt ./out.smt)
  (dump-il ./out.il)
  (live-smt)
  
  Failing Assertion: assert eq(y:bv64, bvmul(x:bv64, x:bv64))
  Belonging to procedure: @bad_square
  Counterexample:
  (define-fun trm () Bool true)
  
  Failing Assertion: assert boolnot(bvslt(x_1:bv64, 0x0:bv64))
  Belonging to procedure: @f3
  Counterexample:
  (define-fun trm () Bool false)
  Procedure @bad_square failed verification with:
  	 Smt.Solver.Unknown: 0
  	 Smt.Solver.Sat: 1
  	 Smt.Solver.Unsat: 0
  Procedure @f2 succeeded verification with:
  	 Smt.Solver.Unknown: 0
  	 Smt.Solver.Sat: 0
  	 Smt.Solver.Unsat: 2
  Procedure @f3 failed verification with:
  	 Smt.Solver.Unknown: 0
  	 Smt.Solver.Sat: 1
  	 Smt.Solver.Unsat: 1
  $ cvc5 ./out.smt --incremental
  "Verifying Procedure: @bad_square"
  sat
  "Verifying Procedure: @f3"
  sat
  unsat
  "Verifying Procedure: @f2"
  unsat
  unsat
