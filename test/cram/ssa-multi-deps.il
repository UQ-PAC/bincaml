


var $R0: bv64;

prog entry @main ;

proc @main () -> ()
[
  block %e [
    goto (%e1, %e2, %e3);
  ];
  block %e1 [
    $R0 := 1:bv64;
    goto (%e2);
  ];
  block %e2 [
    goto (%e4, %e1);
  ];
  block %e3 [
    $R0 := 3:bv64;
    goto (%e4, %e1);
  ];
  block %e4 [
    return ();
  ]
];
