(load-il "chc_call.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants")
(dump-il "chc_call_out.il")
