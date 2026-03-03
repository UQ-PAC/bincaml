(load-il "../../examples/loop.il")
(run-transforms "ssa")
(run-transforms "demoprint-dfg-ivalbits-product")
