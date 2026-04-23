(load-il "../../examples/collapse_edge.il")
(dump-il "before.il")
(run-transforms "collapse-empty-blocks")
(dump-il "after.il")
