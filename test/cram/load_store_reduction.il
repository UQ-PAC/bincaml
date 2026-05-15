var $mem: (bv64 -> bv8);

prog entry @main;

proc @main () -> ()
[
  block %entry [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x10:bv64 0x42:bv64 64;
    var x:bv64 := load le $mem:(bv64->bv8) 0x10:bv64 64;
    goto(%exit);
  ];
  block %exit [
    return ();
  ]
];
