prog entry @main;

proc @main(x:bv64) -> (out:bv64)
[
  block %entry [
    assume eq(x:bv64, 0x1:bv64);
    var a:bv64 := bvadd(x:bv64, 0x1:bv64);
    assert eq(a:bv64, 0x2:bv64);
    assert eq(a:bv64, 0x0:bv64);
    goto(%exit);
  ];
  block %exit [
    return (a:bv64);
  ]
];
