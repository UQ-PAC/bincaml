(load-il "chc_loop.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants")
(dump-il "chc_loop_out.il")
