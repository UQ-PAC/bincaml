(load-il "../../examples/copyprop.il")
(dump-il "before.il")
(run-transforms "linear-copy")
(dump-il "after.il")
