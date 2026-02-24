(load-il "../../examples/irreducible_loop_1.il")
(run-transforms "lambda-lifting")
(run-transforms "type-check")
(dump-il "after_ll_real.il")
