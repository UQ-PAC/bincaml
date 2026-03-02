var $x: bv32;
var $y: bv32;

prog entry @caller;

proc @callee () -> ()
  requires eq($x:bv32, 0x1:bv32);
  ensures eq($x:bv32, bvadd(old($x:bv32), $y:bv32));
[
  block %entry [
    assert eq($x:bv32, old($x:bv32));
    $x: bv32 := bvadd($x:bv32, $y:bv32);
    goto(%ret);
  ];
  block %ret [
    return ();
  ]
];

proc @caller () -> ()
[
  block %entry [
    $y: bv32 := 0x0:bv32;
    $x: bv32 := 0x1:bv32;
    call @callee ();
    goto(%ret);
  ];
  block %ret [
    return ();
  ]
];
