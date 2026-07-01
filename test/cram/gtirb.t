  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/gtirb/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
  > (dump-il "dumped.il")
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  bincaml: (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb): Failure("unsupported")
           
  [123]
  $ diff gtirb-output.il dumped.il
  diff: gtirb-output.il: No such file or directory
  diff: dumped.il: No such file or directory
  [2]
