(load-il "examples/cntlm-simp-output.il")
(dump-il "before.il")
(run-transforms "cf-expressions" "intra-dead-store-elim")
(dump-il "after.il")
