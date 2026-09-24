

  $ bincaml load-il error_assert_type.il
  (run-transforms hindley-milner-elaborate)
  bincaml: Type error: type_error: bool <> 32 ℕ bv
           
           Related context:
           statement
           9 |     assert (1:bv32);
                          ^^^^^^^^
           
  [123]
