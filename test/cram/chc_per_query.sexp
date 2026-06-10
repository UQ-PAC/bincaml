(load-il "chc_per_query.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants-per-query")
(dump-il "chc_per_query_out.il")
