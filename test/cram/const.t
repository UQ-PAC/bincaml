  $ bincaml script const.sexp

  $ diff before.il after.il
  9,10c9,10
  <      call @f(inp=x_1:bv64);
  <      var out:bv64 := bvadd(x_1:bv64, y_1:bv64);
  ---
  >      call @f(inp=0x5:bv64);
  >      var out:bv64 := bvadd(0x5:bv64, 0x2a5:bv64);
  [1]
