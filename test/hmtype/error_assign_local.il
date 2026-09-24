prog entry @main {
    .run = ["progn"; ["run-transforms"; "hindley-milner-elaborate"] ]
};

proc @main () -> ()
[
  block %main_entry [
    var l:bv64 := (1:bv32);
    return;
  ];
];
