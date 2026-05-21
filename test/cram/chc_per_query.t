
Per-query mode (Step 8) — run the per-query variant on a loop with two
post-loop assertions: one provable ([i ≤ 20]) and one not ([i ≤ 5]). The
default mode would fail on the unprovable assertion and abort without
annotating anything; per-query mode issues one solver call per query, so the
provable one still drives invariant inference for the loop while the
unprovable one only produces a warning.

  $ bincaml script chc_per_query.sexp
  (load-il chc_per_query.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (run-transforms chc-infer-invariants-per-query)
  bincaml: [INFO] Per-query mode: 8 predicates, 9 normal clauses, 2 queries
  bincaml: [INFO] Query 1/2: sat (8 definitions, 4 non-trivial)
  bincaml: [WARNING] Query 2/2: unsat — assertion not provable
  bincaml: [INFO] Per-query mode: 1/2 queries succeeded; extracted invariants for 4 predicates
  (dump-il chc_per_query_out.il)

The loop invariant inferred from the successful query (the same one
chc_loop.t produces in default mode) is attached as an [assert] at the loop
head:

  $ awk '/block %loop \(/,/]/' chc_per_query_out.il | head -5
     block %loop (
       var i_3:bv64 := phi(%loop_body -> i_5:bv64, %entry -> i_2:bv64)
     ) [
       assert eq(extract(64,4, i_3:bv64), 0x0:bv60);
       goto (%loop_exit,%loop_body);
