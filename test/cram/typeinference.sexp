(load-il "../../examples/irreducible_loop_1.il")
(run-transforms "ssa")
(run-transforms "cf-expressions")
(run-transforms "simplify")
(run-transforms "type-check")
(run-transforms "type-inference")
(run-transforms "type-check")
(dump-il "after-type-inference-loops.il")
(load-il "after-type-inference-loops.il") ; It does not currently parse as types have two different types, this will be fixed with ADT type stuff
