prog entry @f3;

// A poorly implemented square function which
// just multiplies by 2, but is specified correctly.
// Should fail to verify (sat).
proc @bad_square(x:bv64) -> (y:bv64)
 requires bvsge(x, 0:bv64)
 ensures eq(y, bvmul(x, x))
[
 block %b1 [
  var y:bv64 := bvmul(x, 2:bv64);
  return;
 ];
];

// Uses bad_square correctly according to it's spec.
proc @f2(x:bv64) -> (z:bv64)
 requires bvsge(x, 0:bv64)
 ensures eq(z, bvadd(bvmul(x, x), 1:bv64))
[
 block %b1 [
  var (y:bv64) := call @bad_square(x);
  var z:bv64 := bvadd(y, 1:bv64);
  return;
 ];
];

// Uses bad_square incorrectly according to it's spec.
proc @f3(x:bv64) -> (z:bv64)
 requires bvsge(x, 0:bv64)
 ensures eq(z, bvadd(bvmul(bvadd(x, 1:bv64), bvadd(x, 1:bv64)), 1:bv64))
[
 block %b1 [
  var x:bv64 := bvadd(x, 1:bv64);
  var (y:bv64) := call @bad_square(x);
  var z:bv64 := bvadd(y, 1:bv64);
  return;
 ];
];
