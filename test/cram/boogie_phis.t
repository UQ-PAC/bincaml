  $ bincaml script boogie_phis.sexp
  (load-il boogie_phis.il)
  (dump-il out.il)
  (dump-boogie out.bpl)

  $ cat ./out.il
  proc @f()  -> () {  }
    
  
  [
     block %a [ goto (%b,%c); ];
     block %c [ var x_2:bv64 := 0x0:bv64; goto (%d); ];
     block %b [ var x_1:bv64 := 0x0:bv64; goto (%d); ];
     block %d ( var x_3:bv64 := phi(%c -> x_2:bv64, %b -> x_1:bv64) ) [
       assert eq(x_3:bv64, 0x0:bv64);
       nop;
       return;
     ]
  ];
  prog entry @f;

  $ cat ./out.bpl
  
  
  procedure p$f();
  implementation p$f() {
    var x_2: bv64;
    var x_3: bv64;
    var x_1: bv64;
    b#a:
      goto b#b, b#c;
    b#b:
      x_1 := 0bv64;
      x_3 := x_1;
      goto b#d;
    b#c:
      x_2 := 0bv64;
      x_3 := x_2;
      goto b#d;
    b#d:
      assert (x_3 == 0bv64);
      assert true;
      return;
  }
