prog entry @f1;

proc @f1(a:bv64) -> (c:bv64)
[
 block %a [
  var x:bv64 := a;
  goto(%b, %c);
 ];
 block %b [
  guard(bvuge(x,0:bv64));
  var x := bvadd(x:bv64,1:bv64);
  goto(%exit);
 ];
 block %c [
  guard(bvult(x,0:bv64));
  var x := bvsub(x:bv64,1:bv64);
  goto(%exit);
 ];
 block %exit [
  var c:bv64 := x;
  return;
 ];
];
