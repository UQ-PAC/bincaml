  $ bincaml script linear_copy.sexp
  (load-il ../../examples/linear_copy.il)
  bincaml: [WARNING] global undeclared x_3. assuming mutable unshared
  bincaml: [WARNING] global undeclared y_3. assuming mutable unshared
  (dump-il before.il)
  (run-transforms linear-copy cf-expressions)
  bincaml: [WARNING] Invariants not satisfied during 'linear-copy'. Needs [SSA] but only have [].
  (dump-il after.il)

  $ diff before.il after.il
  7,9c7,11
  <      (var c:bv64=o, var d:bv64=p) := call @loop(x=b:bv64, y=b:bv64);
  <      (var e:bv64=o) := call @cross(a=d:bv64, b=bvadd(d:bv64, 0x1:bv64));
  <      (var f:bv64 := bvadd(0x1:bv64, c:bv64), var g:bv64 := bvadd(0x1:bv64, e:bv64));
  ---
  >      (var c:bv64=o, var d:bv64=p) := call @loop(x=a:bv64, y=a:bv64);
  >      (var e:bv64=o) := call @cross(a=bvadd(a:bv64, 0x1:bv64),
  >         b=bvadd(a:bv64, 0x2:bv64));
  >      (var f:bv64 := bvadd(0x1:bv64, c:bv64),
  >       var g:bv64 := bvadd(0x1:bv64, a:bv64, 0x1:bv64));
  11c13
  <      var z:bool := y:bool;
  ---
  >      var z:bool := x:bool;
  25,26c27,28
  <    block %f_c ( var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64) ) [
  <      var w_1:bv64 := y_3:bv64;
  ---
  >    block %f_c ( var y_3:bv64 := phi(%f_a -> x:bv64, %f_b -> x:bv64) ) [
  >      var w_1:bv64 := x:bv64;
  29,30c31,32
  <    block %f_d ( var y_4:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64) ) [
  <      (var w_2:bv64=o, var p:bv64=p) := call @g(x=y_4:bv64);
  ---
  >    block %f_d ( var y_4:bv64 := phi(%f_a -> x:bv64, %f_b -> x:bv64) ) [
  >      (var w_2:bv64=o, var p:bv64=p) := call @g(x=x:bv64);
  33,34c35,36
  <    block %f_return ( var w_3:bv64 := phi(%f_c -> w_1:bv64, %f_d -> w_2:bv64) ) [
  <      var o:bv64 := w_3:bv64;
  ---
  >    block %f_return ( var w_3:bv64 := phi(%f_c -> x:bv64, %f_d -> x:bv64) ) [
  >      var o:bv64 := x:bv64;
  45,46c47,48
  <    block %g_return ( var y_3:bv64 := phi(%g_a -> y_1:bv64, %g_b -> y_2:bv64) ) [
  <      (var o:bv64 := x:bv64, var p:bv64 := y_3:bv64);
  ---
  >    block %g_return ( var y_3:bv64 := phi(%g_a -> x:bv64, %g_b -> x:bv64) ) [
  >      (var o:bv64 := x:bv64, var p:bv64 := x:bv64);
  61c63
  <      var y_2:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
  ---
  >      var y_2:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_1:bv64)
  64c66
  <      var y_3:bv64 := y_2:bv64;
  ---
  >      var y_3:bv64 := bvadd(y:bv64, 0x1:bv64);
  69,70c71,75
  <      var y_4:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
  <    ) [ (var o:bv64 := x_4:bv64, var p:bv64 := y_4:bv64); return; ]
  ---
  >      var y_4:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_1:bv64)
  >    ) [
  >      (var o:bv64 := x_4:bv64, var p:bv64 := bvadd(y:bv64, 0x1:bv64));
  >      return;
  >    ]
  79c84
  <    block %ret ( var o_3:bv64 := phi(%a -> o_1:bv64, %b -> o_2:bv64) ) [
  ---
  >    block %ret ( var o_3:bv64 := phi(%a -> a:bv64, %b -> o_2:bv64) ) [
  [1]
