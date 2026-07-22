(load-il "../examples/cntlm-simp-output.il")
(dump-il "before.il")
(run-transforms "ssify-program")
(dump-il "after.il")