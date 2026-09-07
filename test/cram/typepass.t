  $ bincaml script ./typepass.sexp
  (load-il ../../examples/cat.il)
  (run-transforms type-check)
  bincaml: Exception Failure("Check failed: @main_4197696"): exception
           
           Related context:
           ./typepass.sexp
           2 | (run-transforms "type-check")
                                          ^
           
  Paramters for the function has a type mismatch: type of bvadd(0x1:bv24, 0x4:bv64) != type of $_PC:bv64 (bv24 != bv64) at statement 9 in %main_entry
  bv64 is not a bitvector type in bvadd at statement 9 in %main_entry
  [123]
