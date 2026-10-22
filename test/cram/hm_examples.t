
Should correctly elaborate nested let expressions with shadowing

  $ echo 'let $f (x:bv64) : bool = let x : bool = true in x;' > test.il
  $ cat << EOF | bincaml script -
  > (load-il "test.il")
  > (run-transforms "hindley-milner-elaborate")
  > (dump-il)
  > EOF
  (load-il test.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il)
  let $f (x:bv64) : bool = (let x  : bool =(true) in (x:bool));

Should identify type errors in cases options:

  $ echo 'let $f (x:bv64) : bv64 = if eq(x, 0:bv64) then 1:bv64 else true;' > test_cases.il
  $ cat << EOF | bincaml script -
  > (load-il "test_cases.il")
  > (run-transforms "hindley-milner-elaborate")
  > (dump-il)
  > EOF
  (load-il test_cases.il)
  (run-transforms hindley-milner-elaborate)
  bincaml: (run-transforms hindley-milner-elaborate): Lang__Hm_inference__Hm_types.TypeErr("type_error: bool <> 64 \226\132\149 bv : if eq(x:bv64, 0x0:bv64) then 0x1:bv64 else true : fun (x:bv64) :: (if eq(x:bv64, 0x0:bv64) then 0x1:bv64 else true)")
           
  [123]
