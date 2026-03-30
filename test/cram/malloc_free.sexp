(load-il "../../examples/memory/malloc_free.il")
(run-transforms "memory-encoding")
(run-transforms "memory-specification")
(dump-boogie "good.bpl")

(load-il "../../examples/memory/malloc_free_oob.il")
(run-transforms "memory-encoding")
(run-transforms "memory-specification")
(dump-boogie "bad.bpl")
