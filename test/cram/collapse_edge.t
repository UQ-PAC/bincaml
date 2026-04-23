  $ bincaml script collapse_edge.sexp
  (load-il ../../examples/collapse_edge.il)
  (dump-il before.il)
  (run-transforms collapse-empty-blocks)
  (dump-il after.il)

  $ diff before.il after.il
  5,10c5,6
  <    block %inputs [ goto (%a); ];
  <    block %a [ goto (%c,%b); ];
  <    block %b [ goto (%c); ];
  <    block %c [ var b:bv64 := a:bv64; goto (%d); ];
  <    block %d [ goto (%e); ];
  <    block %e ( var c_1:bv64 := phi(%d -> b:bv64) ) [
  ---
  >    block %c [ var b:bv64 := a:bv64; goto (%e); ];
  >    block %e ( var c_1:bv64 := phi(%c -> b:bv64) ) [
  [1]
