  $ bincaml script ./typepass.sexp
  bincaml: Error in (load-il ../../examples/cat.il): Parse error:  ../../examples/cat.il:61
           61 |     store le $stack bvadd($R31:bv64, 0xfffffffffffffff0:bv64) $R29:bv64 64 { .comment = "op: 0xa9bf7bfd" };
                    ^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]
