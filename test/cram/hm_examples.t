
Should correctly elaborate nested let expressions with shadowing

  $ echo 'let $f (x:bv64) : bool = let x : bool = true in x;' > test.il
  $ cat << EOF | bincaml script -
  > (load-il "test.il")
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test.il)
  (run-transforms hindley-milner-elaborate)

Should identify type errors in cases options:

  $ echo 'let $f (x:bv64) : bv64 = if eq(x, 0:bv64) then 1:bv64 else true;' > test_cases.il
  $ cat << EOF | bincaml script -
  > (load-il "test_cases.il")
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test_cases.il)
  (run-transforms hindley-milner-elaborate)
  bincaml: Type error: bool <> 64 ℕ bv
           
           Related context:
           declaration
           1 | let $f (x:bv64) : bv64 = if eq(x, 0:bv64) then 1:bv64 else true;
                   ^^
           
  [123]



Should produce errors

  $ echo 'let $f (x:bv64) : bool = booland(true, bvult(x, 1:bv32));' > test.il
  $ cat << EOF | bincaml script -
  > (load-il "test.il")
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test.il)
  (run-transforms hindley-milner-elaborate)
  bincaml: Type error: 32 <> 64
           
           Related context:
           infer expression
           1 | let $f (x:bv64) : bool = booland(true, bvult(x, 1:bv32));
                                                           ^^^^^^^^^^^
           
           infer expression
           1 | let $f (x:bv64) : bool = booland(true, bvult(x, 1:bv32));
                                               ^^^^^^^^^^^^^^^^^^^^^^^^
           
           declaration
           1 | let $f (x:bv64) : bool = booland(true, bvult(x, 1:bv32));
                   ^^
           
  [123]



Should identify type errors in cases options:

  $ echo 'let $f (x:bv64) : bv64 = (true);' > test_cases.il
  $ cat << EOF | bincaml script -
  > (load-il "test_cases.il")
  > (dump-il)
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il test_cases.il)
  (dump-il)
  let $f (x:bv64) : bv64 = (true);(run-transforms hindley-milner-elaborate)
  bincaml: Type error: 64 ℕ bv <> bool
           
           Related context:
           declaration
           1 | let $f (x:bv64) : bv64 = (true);
                   ^^
           
  [123]


typefail example

  $ cat << EOF | bincaml script -
  > (load-il "incorrect_types.il")
  > (run-transforms "hindley-milner-elaborate")
  > EOF
  (load-il incorrect_types.il)
  bincaml: [WARNING] type conflict: int, <bitvector at construction of zero_extend(32, 2)
  bincaml: [WARNING] type conflict: int, <bitvector at construction of zero_extend(32, 2)
  bincaml: [WARNING] type conflict: int, <bitvector at construction of sign_extend(32, 2)
  bincaml: [WARNING] type conflict: int, <bitvector at construction of sign_extend(32, 2)
  (run-transforms hindley-milner-elaborate)
  bincaml: Type error: 32 ℕ bv <> int
           
           Related context:
           infer expression
           19 |     $NF: bool := eq(1, 0x1:bv32) { .label = "%00000408" };
                                   ^^^^^^^^^^^^^
           
           statement
           19 |     $NF: bool := eq(1, 0x1:bv32) { .label = "%00000408" };
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
           
           procedure
           15 | proc @main_1876 () -> ()
                     ^^^^^^^^^^
           
  [123]
