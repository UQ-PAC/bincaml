  $ bincaml script copyprop.sexp
  (load-il ../../examples/copyprop.il)
  (run-transforms ssa)
  (dump-il before.il)
  (run-transforms linear-copy)
  (dump-il after.il)

  $ diff before.il after.il
  7c7
  <      var z_1:bv64 := bvadd(0x1:bv64, y_1:bv64);
  ---
  >      var z_1:bv64 := bvadd(0x1:bv64, x:bv64);
  21,22c21,22
  <    block %f_c ( var y_4:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      var w_2:bv64 := y_4:bv64;
  ---
  >    block %f_c ( var y_4:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      var w_2:bv64 := x:bv64;
  25,26c25,26
  <    block %f_d ( var y_3:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      (var w_1:bv64=o, var p_1:bv64=p) := call @g(x=y_3:bv64);
  ---
  >    block %f_d ( var y_3:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      (var w_1:bv64=o, var p_1:bv64=p) := call @g(x=x:bv64);
  29,30c29,30
  <    block %f_return ( var w_3:bv64 := phi(%f_d -> w_1:bv64, %f_c -> w_2:bv64) ) [
  <      var o:bv64 := w_3:bv64;
  ---
  >    block %f_return ( var w_3:bv64 := phi(%f_d -> x:bv64, %f_c -> x:bv64) ) [
  >      var o:bv64 := x:bv64;
  41,42c41,42
  <    block %g_return ( var y_3:bv64 := phi(%g_b -> y_1:bv64, %g_a -> y_2:bv64) ) [
  <      (var o:bv64 := x:bv64, var p:bv64 := y_3:bv64);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_b -> x:bv64, %g_a -> x:bv64) ) [
  >      (var o:bv64 := x:bv64, var p:bv64 := x:bv64);
  [1]
