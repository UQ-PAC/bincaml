  $ bincaml script repeated_ssa.sexp
  (load-il repeated_ssa.il)
  (run-transforms ssa)
  (run-transforms ssa)
  (run-transforms ssa)
  (dump-il out.il)

Raw construction leads to lots of ugly renaming:
  $ diff ./ssa-0.il ./ssa-1.il

These should produce no diff:
  $ diff ./repeated-0.il ./repeated-1.il
  $ diff ./repeated-1.il ./repeated-2.il
