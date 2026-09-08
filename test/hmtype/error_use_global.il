<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> d041a1d5 (glob expect test)
=======
>>>>>>> f2b818f3 (more tests)
prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

var $g : bv25;

proc @main () -> ()
[
  block %main_entry [
<<<<<<< HEAD
<<<<<<< HEAD
    $g:bv32 := bvadd(1:bv64, $g);
=======
    var $g:bv32 := bvadd(1:bv32; $g);
>>>>>>> d041a1d5 (glob expect test)
=======
    $g:bv32 := bvadd(1:bv64, $g);
>>>>>>> f2b818f3 (more tests)
    return;
  ];
];
