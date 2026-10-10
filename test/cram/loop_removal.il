prog entry @f1_good;

// f1
// A simple loop example.
// Decrements x by 1 (initially > 200)
// until it hits 0.
proc @f1_good(x:int) -> (r:int)
[
 block %start [
  assume (intle(100,x));
  goto (%head);
 ];
 block %head [
  assert (intle(0,x));
  goto (%after, %body);
 ];
 block %body [
  guard (intlt(0,x));
  var x := intsub(x,1);
  goto (%head);
 ];
 block %after [
  guard (boolnot(intlt(0,x)));
  return (x);
 ];
];
 
// Decrements by 2, breaking invariant.
// Should fail.
proc @f1_bad(x:int) -> (r:int)
[
 block %start [
  assume (intle(100,x));
  goto (%head);
 ];
 block %head [
  assert (intle(0,x));
  goto (%after, %body);
 ];
 block %body [
  guard (intlt(0,x));
  var x := intsub(x,2);
  goto (%head);
 ];
 block %after [
  guard (boolnot(intlt(0,x)));
  return (x);
 ];
];

