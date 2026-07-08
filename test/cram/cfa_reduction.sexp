(load-il "./cfa_reduction.il")
(run-transforms "ssa")
(run-transforms "cfa-reduction")
(run-transforms "simplify")
(dump-il "./out.il")

