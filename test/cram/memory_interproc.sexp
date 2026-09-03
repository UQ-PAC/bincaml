(load-il "../../examples/memory/memory_interproc.il")

(run-transforms "ssa")

(run-transforms "split-memory-encoding")
(run-transforms "memory-specification")

(run-transforms "ssa")

(run-transforms "linear-const")
(run-transforms "linear-copy")

(run-transforms "inter-function-summaries")

(dump-il "after.il")
(run-transforms dynamic-single-assignment)
(dump-boogie "out.bpl")
