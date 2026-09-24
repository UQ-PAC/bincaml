
prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

var $g : bv25;

proc @main () -> ()
[
  block %main_entry [
    var $g:bv64 := (1:bv32);
    return;
  ];
];
