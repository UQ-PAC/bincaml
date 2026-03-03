
Run on basic irreducible loop example

  $ bincaml script basicssa.sexp
  bincaml: Error in (load-il ../../examples/irreducible_loop_1.il): Parse error:  ../../examples/irreducible_loop_1.il:20
           20 |     store le $stack #4:bv64 $R29:bv64 64 { .label = "%00000360" };
                    ^^^^^
            at Dune__exe__Script.of_cmd.(fun) bin/script.ml:64
  [123]

  $ cat before.il
  cat: before.il: No such file or directory
  [1]

  $ cat after.il
  cat: after.il: No such file or directory
  [1]

  $ diff after.il after_reparsed.il
  diff: after.il: No such file or directory
  diff: after_reparsed.il: No such file or directory
  [2]

The interpreter should give the same output for both

  $ diff  before_loop.txt after_loop.txt
  diff: before_loop.txt: No such file or directory
  diff: after_loop.txt: No such file or directory
  [2]



Similar example fixing up  a file already in DSA form

  $ diff  before_conds.txt after_conds.txt
  diff: before_conds.txt: No such file or directory
  diff: after_conds.txt: No such file or directory
  [2]


Multiple loops dependencies of loops etc are handled correctly

  $ diff ssa-multi-before.il ssa-multi-after.il
  diff: ssa-multi-before.il: No such file or directory
  diff: ssa-multi-after.il: No such file or directory
  [2]
