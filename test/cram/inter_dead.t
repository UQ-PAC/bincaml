
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
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
       (var a:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
       (var x:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       nop;
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2(f=d:bv64);
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
       return;
     ]
  ];
  prog entry @main;

  $ cat intra.il
  var $global:bv64;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
       (var a:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
       (var x:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2(f=d:bv64);
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
       return;
     ]
  ];
  prog entry @main;

  $ cat inter.il
  var $global:bv64;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       var a:bv64 := inp:bv64;
       (var a:bv64=out) := call @fun1(c=a:bv64);
       (var x:bv64=out) := call @fun1(c=a:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       return;
     ]
  ];
  proc @fun1(c:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := call @fun2();
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2()  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
       return;
     ]
  ];
  prog entry @main;

  $ diff inter.il intra.il
  7,9c7,9
  <      var a:bv64 := inp:bv64;
  <      (var a:bv64=out) := call @fun1(c=a:bv64);
  <      (var x:bv64=out) := call @fun1(c=a:bv64);
  ---
  >      (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
  >      (var a:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
  >      (var x:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
  14c14
  < proc @fun1(c:bv64)  -> (out:bv64) {  }
  ---
  > proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
  19c19
  <      (var e:bv64=out2) := call @fun2();
  ---
  >      (var e:bv64=out2) := call @fun2(f=d:bv64);
  24c24
  < proc @fun2()  -> (out2:bv64) {  }
  ---
  > proc @fun2(f:bv64)  -> (out2:bv64) {  }
  [1]
