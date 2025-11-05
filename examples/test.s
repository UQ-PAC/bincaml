(load-il "examples/cat.il")
(write-proc-il "@p9main_4198208" "before1.il")
(run-transforms "cf-expressions" "intra-dead-store-elim")
(write-proc-il "@p9main_4198208" "after1.il")
