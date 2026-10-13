

  $ bincaml load-il error_assert_type.il
  (run-transforms hindley-milner-elaborate)
  bincaml: Type error: bool <> 32 ℕ bv
           
           Related context:
           statement
           8 |     assert (1:bv32);
                          ^^^^^^^^
           
           prog script in error_assert_type.il: (progn (run-transforms hindley-milner-elaborate))
  [123]
