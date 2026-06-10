prog entry @main;

var $mem: (bv64 -> bv8);
var $j: bv8;

proc @foo() -> ()
[
  block %entry [
    $j := 0x0:bv8;
    goto(%loop);
  ];
  block %loop [
    goto(%loop_body, %loop_exit);
  ];
  block %loop_body [
    guard (bvult($j, 0x5:bv8));
    var cur:bv8 := load le $mem 0x100:bv64 8;
    $mem := store le $mem 0x100:bv64 bvadd(cur:bv8, 0x1:bv8) 8;
    $j := bvadd($j, 0x1:bv8);
    goto(%loop);
  ];
  block %loop_exit [
    guard (bvuge($j, 0x5:bv8));
    return ();
  ]
];

proc @main() -> ()
[
  block %entry [
    $mem := store le $mem 0x100:bv64 0x20:bv8 8;
    call @foo ();
    var v:bv8 := load le $mem 0x100:bv64 8;
    assert eq(v:bv8, 0x25:bv8);
    return ();
  ]
];
