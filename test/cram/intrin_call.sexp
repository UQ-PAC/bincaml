(load-il "../../examples/memory/malloc_free.il")
(run-transforms "intrin-call")
(dump-il "after.il")
