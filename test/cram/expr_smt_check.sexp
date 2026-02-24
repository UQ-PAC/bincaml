
(load-il "../../examples/cntlm-output.il")
(run-transforms "cf-expressions-smtcheck")


(load-il "concat.il")
(dump-il "before.il")
(run-transforms "cf-expressions-smtcheck")
(dump-il "after.il")
