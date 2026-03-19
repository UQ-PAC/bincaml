(load-il "../../examples/irreducible_loop_1.il")
(dump-il "before.il")
(run-transforms "remove-unreachable-block" "cf-expressions" "intra-dead-store-elim")
(run-transforms "simple-params")
(interp-out "before_loop.txt")
(run-transforms "simple-ssa")
(interp-out "after_loop.txt")
(dump-il "after.il")
(load-il "after.il")
(dump-il "after_reparsed.il")


; is already in ssa form
(load-il "../../examples/x-output.il")
(run-transforms "remove-unreachable-block" "cf-expressions" "intra-dead-store-elim")
(interp-out "before_conds.txt")
(run-transforms "simple-ssa")
(interp-out "after_conds.txt")


; multi ssa form

(load-il "ssa-multi-deps.il")
(run-transforms "remove-unreachable-block" "cf-expressions" "intra-dead-store-elim")
(dump-il "ssa-multi-before.il")
(run-transforms "ssa")
(dump-il "ssa-multi-after.il")

