
CHC inference over memory -- a loop that stores the counter into memory each
iteration ([while i < 10: mem[0x100] := i; i := i + 1]) then loads it back and
asserts [i <= 20]. This test is just to make sure that loop invariant inference
works in the presence of memory, and that loads and stores are maintained in the
annotated program. The invariants themselves do not involve memory.

  $ bincaml script chc_mem.sexp
  (load-il chc_mem.il)
  (run-transforms ssa)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 10 predicates and 12 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 10 definitions
  (dump-il chc_mem_out.il)

The inferred loop invariant is attached as an [assert] at the loop head, just
as in the memory-free case (chc_loop.t):

  $ awk '/block %loop \(/,/]/' chc_mem_out.il | head -5
     block %loop (
       var i_3:bv64 := phi(%loop_body -> i_5:bv64, %entry -> i_2:bv64)
     ) [
       assert eq(extract(64,4, i_3:bv64), 0x0:bv60);
       goto (%loop_exit,%loop_body);

The annotated output is the original program: the [$mem] global and the
addressed [store le]/[load le] instructions are preserved:

  $ grep -E '(store|load) le ' chc_mem_out.il
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 i_4:bv64 64;
       var x_1:bv64 := load le $mem:(bv64->bv8) 0x100:bv64 64;
