  $ bincaml script loop_removal.sexp
  (load-il ./loop_removal.il)
  (run-transform irreducible-loops)
  bincaml: [INFO] found 4 loops, 0 irreducible
  bincaml: [INFO] found 4 loops, 0 irreducible
  (run-transform remove-loops)
  length: 1
  length: 1
  (run-transform ssa)
  (run-transform inline-summaries)
  (run-transform cfa-reduction)
  (run-transform simplify)
  (dump-il ./out.il)
  (dump-smt ./out.smt)
  (dump-boogie ./out.bpl)

  $ cvc5 ./out.smt --incremental
  "Verifying Procedure: @f1_good"
  unsat
  unsat
  "Verifying Procedure: @f1_bad"
  unsat
  sat

  $ boogie ./out.bpl
  ./out.bpl(50,5): Error: this assertion could not be proved
  Execution trace:
      ./out.bpl(42,3): b#block
  
  Boogie program verifier finished with 1 verified, 1 error
