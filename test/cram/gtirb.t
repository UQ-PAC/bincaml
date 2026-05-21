
  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
