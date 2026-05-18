  $ bincaml script repeated_ssa.sexp
  (load-il repeated_ssa.il)
  (run-transforms ssa)
  (run-transforms ssa)
  (run-transforms ssa)
  (dump-il out.il)
  $ cat ./out.il
  proc @f()  -> () {  }
    
  
  [
     block %entry [ goto (%b,%a); ];
     block %a [ var yi_9:bv64 := 0x1:bv64; goto (%exit); ];
     block %b [
       var yi_7:bv64 := 0x2:bv64;
       var yi_8:bv64 := 0x43:bv64;
       goto (%exit);
     ];
     block %exit ( var j_3:bv64 := phi(%a -> yi_9:bv64, %b -> yi_8:bv64) ) [
       var x_3:bv64 := j_3:bv64;
       return;
     ]
  ];
  proc @g()  -> () {  }
    
  
  [
     block %entry [ goto (%b,%a); ];
     block %a [ var ai_3:bv64 := 0x1:bv64; goto (%exit); ];
     block %b [ var bi_3:bv64 := 0x2:bv64; goto (%exit); ];
     block %exit ( var j_3:bv64 := phi(%a -> ai_3:bv64, %b -> bi_3:bv64) ) [
       var x_3:bv64 := j_3:bv64;
       return;
     ]
  ];
  prog entry @f;
