(load-il "./test.il")
(run-transforms "ssa")
(run-transforms "cfa-reduction")
(dump-smt "./out.smt")
(dump-il "./out.il")

