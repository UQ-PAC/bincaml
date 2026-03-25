(load-il "examples/cntlm-output.il")
(run-transforms "cf-expressions-smtcheck" "intra-dead-store-elim")
(run-transforms "ssa")
(run-transforms "demo-dfg-bool-analysis")
