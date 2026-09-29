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
     block %a [
       var yi_16:bv64 := 0x1:bv64;
       var j_13:bv64 := yi_16:bv64;
       var j_14:bv64 := j_13:bv64;
       var yi_17:bv64 := yi_16:bv64;
       var yi_18:bv64 := yi_17:bv64;
       var j_15:bv64 := j_14:bv64;
       goto (%exit);
     ];
     block %b [
       var yi_12:bv64 := 0x2:bv64;
       var yi_13:bv64 := 0x43:bv64;
       var j_10:bv64 := yi_13:bv64;
       var j_11:bv64 := j_10:bv64;
       var yi_14:bv64 := yi_13:bv64;
       var yi_15:bv64 := yi_14:bv64;
       var j_12:bv64 := j_11:bv64;
       goto (%exit);
     ];
     block %exit (
       var j_9:bv64 := phi(%b -> j_12:bv64, %a -> j_15:bv64),
       var yi_11:bv64 := phi(%b -> yi_15:bv64, %a -> yi_18:bv64)
     ) [ var x_3:bv64 := j_9:bv64; goto (%Return); ];
     block %Return [ nop; goto (%Return_1); ];
     block %Return_1 [ nop; goto (%Return_2); ];
     block %Return_2 [ nop; return; ]
  ];
  proc @g()  -> () {  }
    
  
  [
     block %entry [ goto (%b,%a); ];
     block %a [
       var ai_3:bv64 := 0x1:bv64;
       var j_13:bv64 := ai_3:bv64;
       var j_14:bv64 := j_13:bv64;
       var j_15:bv64 := j_14:bv64;
       goto (%exit);
     ];
     block %b [
       var bi_3:bv64 := 0x2:bv64;
       var j_10:bv64 := bi_3:bv64;
       var j_11:bv64 := j_10:bv64;
       var j_12:bv64 := j_11:bv64;
       goto (%exit);
     ];
     block %exit ( var j_9:bv64 := phi(%b -> j_12:bv64, %a -> j_15:bv64) ) [
       var x_3:bv64 := j_9:bv64;
       goto (%Return);
     ];
     block %Return [ nop; goto (%Return_1); ];
     block %Return_1 [ nop; goto (%Return_2); ];
     block %Return_2 [ nop; return; ]
  ];
  prog entry @f;
