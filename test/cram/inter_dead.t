
  $ bincaml script inter_dead.sexp
  (load-il inter_dead.il)
  (dump-il before.il)
  (run-transform inter-dead-store-elim)
  (dump-il inter.il)
  (load-il inter_dead.il)
  (run-transform intra-dead-store-elim)
  (dump-il intra.il)

  $ cat before.il
  var $global:bv64;
  prog entry @main;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       (var a:bv64 := inp, var b:bv64 := inp);
       (var a:bv64=out) := call @fun1(c=a, d=b);
       (var x:bv64=out) := call @fun1(c=a, d=b);
       assert eq(x, bvadd(a, a));
       nop;
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2(f=d);
       var out:bv64 := bvadd(c, e);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g, g);
       return;
     ]
  ];

  $ cat intra.il
  var $global:bv64;
  prog entry @main;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       (var a:bv64 := inp, var b:bv64 := inp);
       (var a:bv64=out) := call @fun1(c=a, d=b);
       (var x:bv64=out) := call @fun1(c=a, d=b);
       assert eq(x, bvadd(a, a));
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2(f=d);
       var out:bv64 := bvadd(c, e);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g, g);
       return;
     ]
  ];

  $ cat inter.il
  var $global:bv64;
  prog entry @main;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       var a:bv64 := inp;
       (var a:bv64=out) := call @fun1(c=a);
       (var x:bv64=out) := call @fun1(c=a);
       assert eq(x, bvadd(a, a));
       return;
     ]
  ];
  proc @fun1(c:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2();
       var out:bv64 := bvadd(c, e);
       return;
     ]
  ];
  proc @fun2()  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g, g);
       return;
     ]
  ];

  $ diff inter.il intra.il
  8,10c8,10
  <      var a:bv64 := inp;
  <      (var a:bv64=out) := call @fun1(c=a);
  <      (var x:bv64=out) := call @fun1(c=a);
  ---
  >      (var a:bv64 := inp, var b:bv64 := inp);
  >      (var a:bv64=out) := call @fun1(c=a, d=b);
  >      (var x:bv64=out) := call @fun1(c=a, d=b);
  15c15
  < proc @fun1(c:bv64)  -> (out:bv64) {  }
  ---
  > proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
  20c20
  <      (var e:bv64=out2) := call @fun2();
  ---
  >      (var e:bv64=out2) := call @fun2(f=d);
  25c25
  < proc @fun2()  -> (out2:bv64) {  }
  ---
  > proc @fun2(f:bv64)  -> (out2:bv64) {  }
  [1]
