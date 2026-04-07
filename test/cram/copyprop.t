  $ bincaml script copyprop.sexp

  $ diff before.il after.il
  13,14c13,14
  <    block %f_return ( var y_3:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      var o:bv64 := y_3;
  ---
  >    block %f_return ( var y_3:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      var o:bv64 := x;
  25,26c25,26
  <    block %g_return ( var y_3:bv64 := phi(%g_b -> y_1:bv64, %g_a -> y_2:bv64) ) [
  <      (var o:bv64 := x, var p:bv64 := y_3);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_b -> x:bv64, %g_a -> x:bv64) ) [
  >      (var o:bv64 := x, var p:bv64 := x);
  [1]
