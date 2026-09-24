prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

var $g : bv32;
var $h : bv64;

proc @main () -> ()
[
  block %main_entry [
    $h:bv64 := bvadd(1:bv64, $g:bv64);
    return;
  ];
];
