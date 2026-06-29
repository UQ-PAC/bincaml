prog entry @main;

proc @helper(x:bv64) -> (y:bv64)
[
  block %entry [
    return (bvadd(x:bv64, 0x1:bv64));
  ]
];

proc @main() -> (out:bv64)
[
  block %entry [
    (var z:bv64) := call @helper(0x5:bv64);
    assert eq(z:bv64, 0x6:bv64);
    return (z:bv64);
  ]
];
