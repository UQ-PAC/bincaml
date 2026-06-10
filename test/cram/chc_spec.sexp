(load-il "chc_spec.il")
(run-transforms "ssa")
(run-transforms "chc-infer-invariants")
(dump-il "chc_spec_out.il")
