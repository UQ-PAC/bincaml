  $ bincaml script ./cfa_reduction.sexp
  (load-il ./cfa_reduction.il)
  (run-transforms ssa)
  (run-transforms cfa-reduction)
  (run-transforms simplify)
  (dump-il ./out.il)
  $ cat ./out.il
  proc @f1(a:bv64)  -> (c:bv64) {  }
    
  
  [
     block %block [
       var v:bool := true;
       var v_2:bool := booland(v:bool, boolnot(bvult(a:bv64, 0x0:bv64)));
       var x_6:bv64 := if v_2:bool then bvadd(a:bv64, 0x1:bv64) else bvsub(a:bv64,
        0x1:bv64);
       var c:bv64 := x_6:bv64;
       return;
     ]
  ];
  prog entry @f1;
