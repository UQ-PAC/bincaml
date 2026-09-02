#!/usr/bin/env bash


cat << EOF | dune exec bincaml script -
  (load-il "../../examples/memory/memory_interproc.il")
  (dump-il)
  (log-level debug)
  (run-transforms "hindley-milner-elaborate")
  (dump-il bflat.il)
  (run-transforms "ssa")
  (dump-il flat.il)
  (run-transforms "flat-memory-encoding")
  (dump-il)
  (run-transforms "hindley-milner-elaborate")
  (run-transforms "memory-specification")
  (run-transforms "hindley-milner-elaborate")
  (run-transforms "ssa")
  (run-transforms "linear-const")
  (run-transforms "hindley-milner-elaborate")
  (run-transforms "linear-copy")
  (run-transforms "inter-function-summaries")
  (run-transforms "hindley-milner-elaborate")
  (run-transforms "dynamic-single-assignment")
  (log-level debug)
  (run-transforms "hindley-milner-elaborate")
  (dump-il "after.il")
  (dump-boogie "out.bpl")
EOF
