Logs should print conditionally on whether their source has the right level.

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info")
  > (log-level "info" "analysis.irreducible_loops")
  > (run-transforms "irreducible-loops")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (log-level info)
  (log-level info analysis.irreducible_loops)
  (run-transforms irreducible-loops)
  bincaml: [INFO] found 15 loops, 1 irreducible
  bincaml: [INFO] found 0 loops, 0 irreducible


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info")
  > (log-level "error" "analysis.irreducible_loops")
  > (run-transforms "irreducible-loops")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (log-level info)
  (log-level error analysis.irreducible_loops)
  (run-transforms irreducible-loops)

Some error messages for log configuration.

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level debug)
  > (log-level)
  > (run-transforms "irreducible-loops")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (log-level debug)
  (log-level)
  bincaml: Error: Expected at least one argument in cmd log-level
           
           
  [123]

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "blah")
  > (run-transforms "irreducible-loops")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (log-level blah)
  bincaml: Error: Incorrect log level option given, correct options are ["info", "quiet", "app", "error", "warning", "debug"] in cmd log-level
           
           
  [123]


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info" "nowheoijifsda")
  > (run-transforms "irreducible-loops")
  > EOF
  (load-il ../../examples/irreducible_loop_1.il)
  (log-level info nowheoijifsda)
  bincaml: Error: source nowheoijifsda not found in cmd log-level
           
           
  [123]
