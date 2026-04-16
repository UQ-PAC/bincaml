(load-il "../../examples/irreducible_loop_1.il")
(run-transforms "ssa")
(run-transforms "cf-expressions")
(run-transforms "simplify")
(run-transforms "type-check")
(run-transforms "type-inference")
; (run-transforms "type-check") ; It does not type check currently, better idea around polar types within type system
(dump-il "after-type-inference-loops.il")
