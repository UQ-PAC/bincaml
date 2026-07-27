  $ bincaml script ./smt_backend.sexp
  (load-il ./smt_backend.il)
  (run-transforms ssa)
  (run-transforms cfa-reduction)
  (run-transforms inline_summaries)
  (dump-smt ./out.smt)
  (dump-il ./out.il)
  $ cvc5 ./out.smt --incremental
  "Verifying Procedure: @bad_square"
  sat
  "Verifying Procedure: @f2"
  unsat
  unsat
  "Verifying Procedure: @f3"
  sat
  unsat
