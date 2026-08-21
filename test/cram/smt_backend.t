  $ bincaml script ./smt_backend.sexp
  (load-il ./smt_backend.il)
  (run-transforms ssa)
  (run-transforms cfa-reduction)
  (run-transforms inline-summaries)
  (dump-smt ./out.smt)
  (dump-il ./out.il)
  (live-smt)
  
  Failing Assertion: assert boolnot(bvslt(x_1:bv64, 0x0:bv64))
  Belonging to procedure: @f3
  Counterexample:
  (define-fun trm () Bool false)
  
  Failing Assertion: assert eq(y:bv64, bvmul(x:bv64, x:bv64))
  Belonging to procedure: @bad_square
  Counterexample:
  (define-fun trm () Bool true)
  
  Procedure @bad_square verified with:
  3 succeeding assertions.
  1 failing assertions.
  0 unknown assertions.
  
  Procedure @f2 verified with:
  8 succeeding assertions.
  0 failing assertions.
  0 unknown assertions.
  
  Procedure @f3 verified with:
  7 succeeding assertions.
  1 failing assertions.
  0 unknown assertions.
  $ cvc5 ./out.smt --incremental
  "Verifying Procedure: @f3"
  sat
  unsat
  "Verifying Procedure: @f2"
  unsat
  unsat
  "Verifying Procedure: @bad_square"
  sat
