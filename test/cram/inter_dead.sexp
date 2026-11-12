(load-il "inter_dead.il")
(dump-il "before.il")
(run-transforms "ssa" "inter-dead-store-elim")
(dump-il "inter.il")

(load-il "inter_dead.il")
(run-transforms "intra-dead-store-elim")
(dump-il "intra.il")
