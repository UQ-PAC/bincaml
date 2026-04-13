  $ bincaml script const.sexp
  (load-il ../../examples/const.il)
  (run-transforms cf-expressions ssa)
  (dump-il before.il)
  (run-transforms linear-const)
  (dump-il after.il)

  $ diff before.il after.il
  8,9c8,9
  <      (let y_1:bv64=out) := call @f(inp=x_1);
  <      var out:bv64 := bvadd(x_1, y_1);
  ---
  >      (let y_1:bv64=out) := call @f(inp=0x5:bv64);
  >      var out:bv64 := bvadd(0x5:bv64, 0x2a5:bv64);
  [1]
