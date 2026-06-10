(load-il "chc_mem_call.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants")
(dump-il "chc_mem_call_out.il")
