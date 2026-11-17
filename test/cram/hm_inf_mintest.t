

Should correctly elaborate nested let expressions with shadowing

  $ echo 'let $f (x:bv64) : bool = bvult(x, 1:bv32);' > test.il
  $ cat << EOF | bincaml script -
  > (load-il "test.il")
  > (dump-il)
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test.il)
  (dump-il)
  let $f (x:bv64) : bool = (bvult(x:bv64, 0x1:bv32));(run-transforms hindley-milner-elaborate)
  bincaml: Type error: 32 <> 64
           
           Related context:
           infer expression
           1 | let $f (x:bv64) : bool = bvult(x, 1:bv32);
                                             ^^^^^^^^^^^
           
  [123]

Should identify type errors in cases options:

  $ echo 'let $f (x:bv64) : bv64 = true;' > test_cases.il
  $ cat << EOF | bincaml script -
  > (load-il "test_cases.il")
  > (dump-il)
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test_cases.il)
  (dump-il)
  let $f (x:bv64) : bv64 = (true);(run-transforms hindley-milner-elaborate)
  bincaml: Type error: 64 ℕ bv -> 64 ℕ bv <> bool
           
           
  [123]

