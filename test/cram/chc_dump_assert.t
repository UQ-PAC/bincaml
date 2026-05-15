
CHC dump (Step 2) — exercise [assume], [assert], and the query clauses they
produce. The procedure has one assume, one assert that always holds, and one
assert that fails; the encoder treats them all syntactically and emits one
query per assertion.

  $ bincaml script chc_dump_assert.sexp
  (load-il chc_dump_assert.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (chc-dump-clauses chc_dump_assert_out.smt2)
  bincaml: [INFO] Dumping CHC clauses to chc_dump_assert_out.smt2

Each [assert] produces one query clause [(not (and ...))]; everything else is
a rule [(=> ... ...)]. The two asserts in the input give two queries:

  $ grep -c 'not (and ' chc_dump_assert_out.smt2
  2

Rule clauses cover the entry fact, the enter-to-entry-block connection, the
inter-block transition, and the return edge — four in total:

  $ grep -c '(=> (and ' chc_dump_assert_out.smt2
  3

  $ grep -c '(=> true ' chc_dump_assert_out.smt2
  1

The [assume] is conjoined to the premises rather than emitting a clause of
its own; the assumed equality appears in subsequent query/rule premises but
no extra assertion is produced for it.

  $ grep -c '^(assert ' chc_dump_assert_out.smt2
  6
