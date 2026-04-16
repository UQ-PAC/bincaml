  $ bincaml script copyprop.sexp
  (load-il ../../examples/copyprop.il)
  (run-transforms ssa)
  (dump-il before.il)
  (run-transforms copy-prop)
  (dump-il after.il)

  $ diff before.il after.il
  11,12c11,12
  <    block %f_c ( var y_4:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      var w_2:bv64 := y_4;
  ---
  >    block %f_c ( var y_4:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      var w_2:bv64 := x;
  15,16c15,16
  <    block %f_d ( var y_3:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      (var w_1:bv64=o, var p_1:bv64=p) := call @g(x=y_3);
  ---
  >    block %f_d ( var y_3:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      (var w_1:bv64=o, var p_1:bv64=p) := call @g(x=x);
  19,20c19,20
  <    block %f_return ( var w_3:bv64 := phi(%f_d -> w_1:bv64, %f_c -> w_2:bv64) ) [
  <      var o:bv64 := w_3;
  ---
  >    block %f_return ( var w_3:bv64 := phi(%f_d -> x:bv64, %f_c -> x:bv64) ) [
  >      var o:bv64 := x;
  31,32c31,32
  <    block %g_return ( var y_3:bv64 := phi(%g_b -> y_1:bv64, %g_a -> y_2:bv64) ) [
  <      (var o:bv64 := x, var p:bv64 := y_3);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_b -> x:bv64, %g_a -> x:bv64) ) [
  >      (var o:bv64 := x, var p:bv64 := x);
  [1]
