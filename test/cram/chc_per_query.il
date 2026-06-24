prog entry @main;

var $i: bv64;

proc @main() -> ()
[
  block %entry [
    $i := 0x0:bv64;
    goto(%loop);
  ];
  block %loop [
    goto(%loop_body, %loop_exit);
  ];
  block %loop_body [
    guard (bvult($i, 0xa:bv64));
    $i := bvadd($i, 0x1:bv64);
    goto(%loop);
  ];
  block %loop_exit [
    guard (bvuge($i, 0xa:bv64));
    assert bvule($i, 0x14:bv64);
    assert bvule($i, 0x5:bv64);
    return ();
  ]
];
