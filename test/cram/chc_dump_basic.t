
CHC dump (Step 1) — encode a simple two-block straight-line procedure as a
system of constrained Horn clauses and write the SMT-LIB file to disk. No
solver invocation; the test only checks that the dump is well-formed.

  $ bincaml script chc_dump_basic.sexp
  (load-il chc_dump_basic.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (chc-dump-clauses chc_dump_basic_out.smt2)
  bincaml: [INFO] Dumping CHC clauses to chc_dump_basic_out.smt2

The dump starts with a HORN set-logic line and ends with a check-sat:

  $ head -n1 chc_dump_basic_out.smt2
  (set-logic HORN)
  $ tail -n1 chc_dump_basic_out.smt2
  (check-sat)

Predicate declarations are emitted for both procedure-level predicates
(enter/exit) and each block:

  $ grep -c '^(declare-fun ' chc_dump_basic_out.smt2
  4

Clauses are emitted as universally-quantified implications:

  $ grep -c '^(assert (forall ' chc_dump_basic_out.smt2
  4
