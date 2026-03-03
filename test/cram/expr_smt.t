

Should output no errors

  $  bincaml script expr_smt_check.sexp 
  bincaml: Error in (load-il ../../examples/cntlm-output.il): Parse error:  ../../examples/cntlm-output.il:58
           58 |     store le $stack bvadd($R31:bv64, 0x0:bv64) $R29:bv64 64 { .comment = "op: 0xa9007bfd" };
                    ^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]

Check concat rewrites work

  $ diff before.il after.il
  diff: before.il: No such file or directory
  diff: after.il: No such file or directory
  [2]

