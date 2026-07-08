  $ bincaml script ./cfa_reduction.sexp
  (load-il ./cfa_reduction.il)
  (run-transforms ssa)
  (run-transforms cfa-reduction)
  (dump-il ./out.il)
  $ cat ./out.il
  proc @f1(a:bv64)  -> (c:bv64) {  }
    
  
  [
     block %block [
       nop;
       var x_1:bv64 := a:bv64;
       var v:bool := booland(true);
       nop;
       var x_2:bv64 := x_1:bv64;
       guard bvult(x_2:bv64, 0x0:bv64);
       var x_3:bv64 := bvsub(x_2:bv64, 0x1:bv64);
       var v_1:bool := booland(boolor(v:bool), bvult(x_2:bv64, 0x0:bv64));
       nop;
       var x_4:bv64 := x_1:bv64;
       guard boolnot(bvult(x_4:bv64, 0x0:bv64));
       var x_5:bv64 := bvadd(x_4:bv64, 0x1:bv64);
       var v_2:bool := booland(boolor(v:bool), boolnot(bvult(x_4:bv64, 0x0:bv64)));
       var x_6:bv64 := if v_2:bool then x_5:bv64 else x_3:bv64;
       var c:bv64 := x_6:bv64;
       var v_3:bool := booland(boolor(v_2:bool, v_1:bool));
       return;
     ]
  ];
  prog entry @f1;
