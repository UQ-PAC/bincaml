(load-il "inter_dead.il")
(dump-il "before.il")
(run-transform "inter-dead-store-elim")
(dump-il "inter.il")

(load-il "inter_dead.il")
(run-transform "intra-dead-store-elim")
(dump-il "intra.il")
