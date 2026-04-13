  $ bincaml script copyprop.sexp
  (load-il ../../examples/copyprop.il)
  (run-transforms ssa)
  (dump-il before.il)
  (run-transforms copy-prop)
  (dump-il after.il)

  $ diff before.il after.il
  12,13c12,13
  <    block %f_c ( let y_4:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      let w_2:bv64 := y_4;
  ---
  >    block %f_c ( let y_4:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      let w_2:bv64 := x;
  16,17c16,17
  <    block %f_d ( let y_3:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      (let w_1:bv64=o, let p_1:bv64=p) := call @g(x=y_3);
  ---
  >    block %f_d ( let y_3:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      (let w_1:bv64=o, let p_1:bv64=p) := call @g(x=x);
  20,21c20,21
  <    block %f_return ( let w_3:bv64 := phi(%f_d -> w_1:bv64, %f_c -> w_2:bv64) ) [
  <      var o:bv64 := w_3;
  ---
  >    block %f_return ( let w_3:bv64 := phi(%f_d -> x:bv64, %f_c -> x:bv64) ) [
  >      var o:bv64 := x;
  32,33c32,33
  <    block %g_return ( let y_3:bv64 := phi(%g_b -> y_1:bv64, %g_a -> y_2:bv64) ) [
  <      (var o:bv64 := x, var p:bv64 := y_3);
  ---
  >    block %g_return ( let y_3:bv64 := phi(%g_b -> x:bv64, %g_a -> x:bv64) ) [
  >      (var o:bv64 := x, var p:bv64 := x);
  [1]
