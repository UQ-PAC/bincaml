  $ bincaml script ./typepass.sexp
  bincaml: Error in (load-il ../../examples/cat.il): Parse error:  ../../examples/cat.il:52
           52 |   ensures eq($_PC:bv64, old($R30:bv64));
                  ^^^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]
