  $ bincaml script repeated_ssa.sexp
  (load-il repeated_ssa.il)
  (run-transforms ssa)
  (dump-il ssa-0.il)
  (run-transforms ssa)
  (dump-il ssa-1.il)
  (load-il repeated_ssa.il)
  (run-transforms ssa)
  (dump-il repeated-0.il)
  (run-transforms reconstruct-ssa)
  (dump-il repeated-1.il)
  (run-transforms reconstruct-ssa)
  (dump-il repeated-2.il)

Raw construction leads to lots of ugly renaming:
  $ diff ./ssa-0.il ./ssa-1.il
  7,8c7,10
  <      var yi_4:bv64 := 0x1:bv64;
  <      var j_3:bv64 := yi_4:bv64;
  ---
  >      var yi_9:bv64 := 0x1:bv64;
  >      var j_7:bv64 := yi_9:bv64;
  >      var j_8:bv64 := j_7:bv64;
  >      var yi_10:bv64 := yi_9:bv64;
  12,14c14,18
  <      var yi_2:bv64 := 0x2:bv64;
  <      var yi_3:bv64 := 0x43:bv64;
  <      var j_2:bv64 := yi_3:bv64;
  ---
  >      var yi_6:bv64 := 0x2:bv64;
  >      var yi_7:bv64 := 0x43:bv64;
  >      var j_5:bv64 := yi_7:bv64;
  >      var j_6:bv64 := j_5:bv64;
  >      var yi_8:bv64 := yi_7:bv64;
  18,21c22,26
  <      var j_1:bv64 := phi(%b -> j_2:bv64, %a -> j_3:bv64),
  <      var yi_1:bv64 := phi(%b -> yi_3:bv64, %a -> yi_4:bv64)
  <    ) [ var x_1:bv64 := j_1:bv64; goto (%Return); ];
  <    block %Return [ nop; return; ]
  ---
  >      var yi_5:bv64 := phi(%b -> yi_8:bv64, %a -> yi_10:bv64),
  >      var j_4:bv64 := phi(%b -> j_6:bv64, %a -> j_8:bv64)
  >    ) [ var x_2:bv64 := j_4:bv64; goto (%Return); ];
  >    block %Return [ nop; goto (%Return_1); ];
  >    block %Return_1 [ nop; return; ]
  29,30c34,36
  <      var ai_1:bv64 := 0x1:bv64;
  <      var j_3:bv64 := ai_1:bv64;
  ---
  >      var ai_2:bv64 := 0x1:bv64;
  >      var j_7:bv64 := ai_2:bv64;
  >      var j_8:bv64 := j_7:bv64;
  34,35c40,42
  <      var bi_1:bv64 := 0x2:bv64;
  <      var j_2:bv64 := bi_1:bv64;
  ---
  >      var bi_2:bv64 := 0x2:bv64;
  >      var j_5:bv64 := bi_2:bv64;
  >      var j_6:bv64 := j_5:bv64;
  38,39c45,46
  <    block %exit ( var j_1:bv64 := phi(%b -> j_2:bv64, %a -> j_3:bv64) ) [
  <      var x_1:bv64 := j_1:bv64;
  ---
  >    block %exit ( var j_4:bv64 := phi(%b -> j_6:bv64, %a -> j_8:bv64) ) [
  >      var x_2:bv64 := j_4:bv64;
  42c49,50
  <    block %Return [ nop; return; ]
  ---
  >    block %Return [ nop; goto (%Return_1); ];
  >    block %Return_1 [ nop; return; ]
  [1]

These should produce no diff:
  $ diff ./repeated-0.il ./repeated-1.il
  $ diff ./repeated-1.il ./repeated-2.il
