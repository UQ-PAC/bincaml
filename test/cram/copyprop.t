  $ bincaml script copyprop.sexp

  $ diff before.il after.il
  9c9
  <      var z_1:bv64 := bvadd(0x1:bv64, y_1);
  ---
  >      var z_1:bv64 := bvadd(0x1:bv64, x);
  24,25c24,25
  <    block %f_c ( var y_4:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  <      var w_2:bv64 := y_4;
  ---
  >    block %f_c ( var y_4:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  >      var w_2:bv64 := x;
  28c28
  <    block %f_d ( var y_3:bv64 := phi(%f_b -> y_1:bv64, %f_a -> y_2:bv64) ) [
  ---
  >    block %f_d ( var y_3:bv64 := phi(%f_b -> x:bv64, %f_a -> x:bv64) ) [
  30c30
  <      call @g(x=y_3);
  ---
  >      call @g(x=x);
  33,34c33,34
  <    block %f_return ( var w_3:bv64 := phi(%f_d -> w_1:bv64, %f_c -> w_2:bv64) ) [
  <      var o:bv64 := w_3;
  ---
  >    block %f_return ( var w_3:bv64 := phi(%f_d -> x:bv64, %f_c -> x:bv64) ) [
  >      var o:bv64 := x;
  45,46c45,46
  <    block %g_return ( var y_3:bv64 := phi(%g_b -> y_1:bv64, %g_a -> y_2:bv64) ) [
  <      (var o:bv64 := x, var p:bv64 := y_3);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_b -> x:bv64, %g_a -> x:bv64) ) [
  >      (var o:bv64 := x, var p:bv64 := x);
  [1]
