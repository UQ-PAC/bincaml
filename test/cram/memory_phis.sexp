(load-il "memory_phis.il")

(run-transforms "ssa")
(run-transforms "split-memory-encoding")
(run-transforms "memory-specification")

(run-transforms "ssa")

(run-transforms "linear-const")
(run-transforms "linear-copy")

(dump-il "after.il")
(dump-boogie "out.bpl")
