(load-il "examples/x-output.il")
(dump-il "before.il")
(run-transforms "ssify-program")
(dump-il "after.il")