
prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

var $g : bv32;

proc @main () -> ()
[
  block %main_entry [
    $g:bv64 := bvadd(1:bv64, $g:bv64);
    return;
  ];
];
