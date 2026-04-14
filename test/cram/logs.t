Logs should print conditionally on whether their source has the right level.

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info")
  > (log-level "info" "analysis.irreducible_loops")
  > (run-transforms "irreducible-loops")
  > EOF
  [INFO] (application) Starting irreducible-loops
  [INFO] (analysis.irreducible_loops) found 15 loops, 1 irreducible
  [INFO] (analysis.irreducible_loops) found 0 loops, 0 irreducible


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info")
  > (log-level "error" "analysis.irreducible_loops")
  > (run-transforms "irreducible-loops")
  > EOF
  [INFO] (application) Starting irreducible-loops

Some error messages for log configuration.

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level)
  > (run-transforms "irreducible-loops")
  > EOF
  bincaml: Error in log-level: Expected at least one argument at Dune__exe__Script.of_cmd.(fun).make_error bin/script.ml:88
  [123]

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "blah")
  > (run-transforms "irreducible-loops")
  > EOF
  bincaml: Error in log-level: Incorrect log level option given, correct options are ["info", "quiet", "app", "error", "warning", "debug"] at Dune__exe__Script.of_cmd.(fun).make_error bin/script.ml:88
  [123]


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/irreducible_loop_1.il")
  > (log-level "info" "nowheoijifsda")
  > (run-transforms "irreducible-loops")
  > EOF
  bincaml: Error in log-level: source nowheoijifsda not found at Dune__exe__Script.of_cmd.(fun).make_error bin/script.ml:88
  [123]
