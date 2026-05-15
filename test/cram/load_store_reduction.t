
Load/store reduction — addressed loads and stores are eliminated by the
`load-store-reduction` pass. The pipeline runs `ssa → load-store-reduction →
lambda-lifting` and the dumped IR must contain no `store le`/`load le`
syntax (i.e. no `Instr_Store` or `Instr_Load` nodes).

  $ bincaml script load_store_reduction.sexp
  (load-il load_store_reduction.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (dump-il load_store_reduction_out.il)

The input has one addressed store and one addressed load:

  $ grep -c -E '(store|load) le ' load_store_reduction.il
  2

After the pipeline, no addressed store/load instructions remain:

  $ grep -E '(store|load) le ' load_store_reduction_out.il || echo "no load/store instructions"
  no load/store instructions

The reduction introduces uninterpreted `load64_le`/`store64_le` function
declarations:

  $ grep -c -E 'let (load|store)64_le' load_store_reduction_out.il
  2
