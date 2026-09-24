prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

var $g : bv64;

proc @main () -> ()
[
  block %main_entry [
    $g:bv32 := bvadd(bvadd(1:bv64,2:bv32), $g);
    return;
  ];
];
