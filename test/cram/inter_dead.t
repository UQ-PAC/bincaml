
  $ bincaml script inter_dead.sexp
  (load-il inter_dead.il)
  (dump-il before.il)
  (run-transform ssa inter-dead-store-elim)
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
  proc @main(global_in:bv64, inp:bv64)  -> () {  }
    
  
  [
     block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
     block %main_entry [
       var a_1:bv64 := inp:bv64;
       (var a_2:bv64=out) := call @fun1(c=a_1:bv64, global_in=global_1:bv64);
       (var x_1:bv64=out) := call @fun1(c=a_2:bv64, global_in=global_1:bv64);
       (var a_3:bv64 := a_2:bv64, var x_2:bv64 := x_1:bv64);
       assert eq(x_2:bv64, bvadd(a_3:bv64, a_3:bv64));
       return;
     ]
  ];
  proc @fun1(c:bv64, global_in:bv64)  -> (out:bv64) {  }
    
  
  [
     block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
     block %fun1_entry [
       (var e_1:bv64=out2) := call @fun2(global_in=global_1:bv64);
       var out:bv64 := bvadd(c:bv64, e_1:bv64);
       return;
     ]
  ];
  proc @fun2(global_in:bv64)  -> (out2:bv64) {  }
    
  
  [
     block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
     block %fun2_entry [
       var g_1:bv64 := global_1:bv64;
       var out2:bv64 := bvadd(g_1:bv64, g_1:bv64);
       return;
     ]
  ];
  prog entry @main;

  $ diff inter.il intra.il
  1,2c1,3
  < proc @main(global_in:bv64, inp:bv64)  -> () {  }
  <   
  ---
  > var $global:bv64;
  > proc @main(inp:bv64)  -> () {  }
  >   captures $global:bv64
  5d5
  <    block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
  7,11c7,10
  <      var a_1:bv64 := inp:bv64;
  <      (var a_2:bv64=out) := call @fun1(c=a_1:bv64, global_in=global_1:bv64);
  <      (var x_1:bv64=out) := call @fun1(c=a_2:bv64, global_in=global_1:bv64);
  <      (var a_3:bv64 := a_2:bv64, var x_2:bv64 := x_1:bv64);
  <      assert eq(x_2:bv64, bvadd(a_3:bv64, a_3:bv64));
  ---
  >      (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
  >      (var a:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
  >      (var x:bv64=out) := call @fun1(c=a:bv64, d=b:bv64);
  >      assert eq(x:bv64, bvadd(a:bv64, a:bv64));
  15,16c14,15
  < proc @fun1(c:bv64, global_in:bv64)  -> (out:bv64) {  }
  <   
  ---
  > proc @fun1(c:bv64, d:bv64)  -> (out:bv64) {  }
  >   captures $global:bv64
  19d17
  <    block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
  21,22c19,20
  <      (var e_1:bv64=out2) := call @fun2(global_in=global_1:bv64);
  <      var out:bv64 := bvadd(c:bv64, e_1:bv64);
  ---
  >      (var e:bv64=out2) := call @fun2(f=d:bv64);
  >      var out:bv64 := bvadd(c:bv64, e:bv64);
  26,27c24,25
  < proc @fun2(global_in:bv64)  -> (out2:bv64) {  }
  <   
  ---
  > proc @fun2(f:bv64)  -> (out2:bv64) {  }
  >   captures $global:bv64
  30d27
  <    block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
  32,33c29,30
  <      var g_1:bv64 := global_1:bv64;
  <      var out2:bv64 := bvadd(g_1:bv64, g_1:bv64);
  ---
  >      var g:bv64 := $global;
  >      var out2:bv64 := bvadd(g:bv64, g:bv64);
  [1]
