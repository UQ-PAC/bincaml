var $x: bv32;
var $y: bv32;

prog entry @caller;

proc @callee () -> ()
[
  block %entry [
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
