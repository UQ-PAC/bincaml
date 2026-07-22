(load-il "examples/loop.il")
(dump-il "before.il")
(run-transforms "ssify-program")
(dump-il "after.il")