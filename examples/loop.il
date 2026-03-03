prog entry @main ;

var $R0 : bv64;
var $R1 : bv64;


proc @main () -> () [
  block %entry  [
    $R0 := 0:bv64;
    $R1 := 0:bv64;
    goto (%loop);
  ];
  block %loop [
    goto (%loop_true, %loop_false);
  ];
  block %loop_true [
    guard (bvult($R0, 10:bv64));
    $R1 := bvadd($R1, $R0);
    $R0 := bvadd($R0, 1:bv64);
    goto (%loop);
  ];
  block %loop_false [
    guard (bvuge($R0, 10:bv64));
    return ();
  ];

];
