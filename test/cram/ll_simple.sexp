(load-il "ll_simple.il")
(dump-il "before_ll.il")
(run-transforms "lambda-lifting")
(dump-il "after_ll.il")
