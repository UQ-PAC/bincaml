(load-il "../../examples/linear_copy.il")
(dump-il "before.il")
(run-transforms "linear-copy" "cf-expressions")
(dump-il "after.il")
