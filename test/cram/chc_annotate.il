prog entry @main;

proc @main(x:bv64) -> (out:bv64)
[
  block %entry [
    var a:bv64 := bvadd(x:bv64, 0x1:bv64);
    goto(%exit);
  ];
  block %exit [
    return (a:bv64);
  ]
];
