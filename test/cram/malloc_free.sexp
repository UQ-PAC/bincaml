(load-il "../../examples/memory/malloc_free.il")
(run-transforms "ssa" "split-memory-encoding")
(run-transforms "memory-specification" "dynamic-single-assignment")
(dump-boogie "good.bpl")

(load-il "../../examples/memory/malloc_free_oob.il")
(run-transforms "ssa" "split-memory-encoding")
(run-transforms "memory-specification" "dynamic-single-assignment")
(dump-boogie "bad.bpl")
