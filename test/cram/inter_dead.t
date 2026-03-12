
  $ bincaml script inter_dead.sexp

  $ cat before.il
  var $global:bv64;
  prog entry @main;
  proc @main(inp:bv64)  -> () {  }
    captures $global:bv64
  
  [
     block %main_entry [
       (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
       (var a:bv64=out) := 
       call @fun1(c=a:bv64, d=b:bv64);
       (var x:bv64=out) := 
       call @fun1(c=a:bv64, d=b:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       assert eq(y:bv64, 0);
       nop;
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := 
       call @fun2(f=d:bv64);
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global:bv64;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
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
       (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
       (var a:bv64=out) := 
       call @fun1(c=a:bv64, d=b:bv64);
       (var x:bv64=out) := 
       call @fun1(c=a:bv64, d=b:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       assert eq(y:bv64, 0);
       return;
     ]
  ];
  proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := 
       call @fun2(f=d:bv64);
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2(f:bv64)  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global:bv64;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
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
       var a:bv64 := inp:bv64;
       (var a:bv64=out) := 
       call @fun1(c=a:bv64);
       (var x:bv64=out) := 
       call @fun1(c=a:bv64);
       assert eq(x:bv64, bvadd(a:bv64, a:bv64));
       assert eq(y:bv64, 0);
       return;
     ]
  ];
  proc @fun1(c:bv64)  -> (out:bv64) {  }
    captures $global:bv64
  
  [
     block %fun1_entry [
       (var e:bv64=out2) := 
       call @fun2();
       var out:bv64 := bvadd(c:bv64, e:bv64);
       return;
     ]
  ];
  proc @fun2()  -> (out2:bv64) {  }
    captures $global:bv64
  
  [
     block %fun2_entry [
       var g:bv64 := $global:bv64;
       var out2:bv64 := bvadd(g:bv64, g:bv64);
       return;
     ]
  ];

  $ diff inter.il intra.il
  8c8
  <      var a:bv64 := inp:bv64;
  ---
  >      (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
  10c10
  <      call @fun1(c=a:bv64);
  ---
  >      call @fun1(c=a:bv64, d=b:bv64);
  12c12
  <      call @fun1(c=a:bv64);
  ---
  >      call @fun1(c=a:bv64, d=b:bv64);
  18c18
  < proc @fun1(c:bv64)  -> (out:bv64) {  }
  ---
  > proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
  24c24
  <      call @fun2();
  ---
  >      call @fun2(f=d:bv64);
  29c29
  < proc @fun2()  -> (out2:bv64) {  }
  ---
  > proc @fun2(f:bv64)  -> (out2:bv64) {  }
  [1]
