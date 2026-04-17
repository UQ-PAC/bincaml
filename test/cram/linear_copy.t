  $ bincaml script linear_copy.sexp
  (load-il ../../examples/linear_copy.il)
  bincaml: [WARNING] global undeclared x_3. assuming mutable unshared
  bincaml: [WARNING] global undeclared y_3. assuming mutable unshared
  (dump-il before.il)
  (run-transforms linear-copy)
  (dump-il after.il)

  $ diff before.il after.il
  7,9c7,9
  <      (var c:bv64=o, var d:bv64=p) := call @loop(x=b:bv64, y=b:bv64);
  <      (var e:bv64=o) := call @cross(a=d:bv64, b=bvadd(d:bv64, 0x1:bv64));
  <      (var f:bv64 := bvadd(0x1:bv64, c:bv64), var g:bv64 := bvadd(0x1:bv64, e:bv64));
  ---
  >      (var c:bv64=o, var d:bv64=p) := call @loop(x=a:bv64, y=a:bv64);
  >      (var e:bv64=o) := call @cross(a=a:bv64, b=bvadd(a:bv64, 0x1:bv64));
  >      (var f:bv64 := bvadd(0x1:bv64, c:bv64), var g:bv64 := bvadd(0x1:bv64, a:bv64));
  11c11
  <      var z:bool := y:bool;
  ---
  >      var z:bool := x:bool;
  25,26c25,26
  <    block %f_c ( var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64) ) [
  <      var w_1:bv64 := y_3:bv64;
  ---
  >    block %f_c ( var y_3:bv64 := phi(%f_a -> x:bv64, %f_b -> x:bv64) ) [
  >      var w_1:bv64 := x:bv64;
  29,30c29,30
  <    block %f_d ( var y_4:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64) ) [
  <      (var w_2:bv64=o, var p:bv64=p) := call @g(x=y_4:bv64);
  ---
  >    block %f_d ( var y_4:bv64 := phi(%f_a -> x:bv64, %f_b -> x:bv64) ) [
  >      (var w_2:bv64=o, var p:bv64=p) := call @g(x=x:bv64);
  33,34c33,34
  <    block %f_return ( var w_3:bv64 := phi(%f_c -> w_1:bv64, %f_d -> w_2:bv64) ) [
  <      var o:bv64 := w_3:bv64;
  ---
  >    block %f_return ( var w_3:bv64 := phi(%f_c -> x:bv64, %f_d -> x:bv64) ) [
  >      var o:bv64 := x:bv64;
  45,46c45,46
  <    block %g_return ( var y_3:bv64 := phi(%g_a -> y_1:bv64, %g_b -> y_2:bv64) ) [
  <      (var o:bv64 := x:bv64, var p:bv64 := y_3:bv64);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_a -> x:bv64, %g_b -> x:bv64) ) [
  >      (var o:bv64 := x:bv64, var p:bv64 := x:bv64);
  60,61c60,61
  <      var x_2:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
  <      var y_2:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
  ---
  >      var x_2:bv64 := phi(%f_entry -> x:bv64, %f_a -> x_3:bv64),
  >      var y_2:bv64 := phi(%f_entry -> y:bv64, %f_a -> y:bv64)
  64c64
  <      var y_3:bv64 := y_2:bv64;
  ---
  >      var y_3:bv64 := y:bv64;
  68,70c68,70
  <      var x_4:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
  <      var y_4:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
  <    ) [ (var o:bv64 := x_4:bv64, var p:bv64 := y_4:bv64); return; ]
  ---
  >      var x_4:bv64 := phi(%f_entry -> x:bv64, %f_a -> x_3:bv64),
  >      var y_4:bv64 := phi(%f_entry -> y:bv64, %f_a -> y:bv64)
  >    ) [ (var o:bv64 := x_4:bv64, var p:bv64 := y:bv64); return; ]
  79c79
  <    block %ret ( var o_3:bv64 := phi(%a -> o_1:bv64, %b -> o_2:bv64) ) [
  ---
  >    block %ret ( var o_3:bv64 := phi(%a -> a:bv64, %b -> o_2:bv64) ) [
  [1]
