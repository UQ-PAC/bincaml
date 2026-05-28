(load-il "../../examples/memory/malloc_free.il")
(run-transforms "ssa" "split-memory-encoding")
(run-transforms "memory-specification" "flatten-phis")
(dump-boogie "good.bpl")

(load-il "../../examples/memory/malloc_free_oob.il")
(run-transforms "ssa" "split-memory-encoding")
(run-transforms "memory-specification" "flatten-phis")
(dump-boogie "bad.bpl")
