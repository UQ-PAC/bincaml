(load-il "chc_mem.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants")
(dump-il "chc_mem_out.il")
