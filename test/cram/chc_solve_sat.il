prog entry @main;

proc @main() -> (out:bv64)
[
  block %entry [
    var a:bv64 := 0x1:bv64;
    assert eq(a:bv64, 0x1:bv64);
    return (a:bv64);
  ]
];
