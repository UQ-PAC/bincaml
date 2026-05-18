
CHC loop-head annotation (Step 5) — run the full pipeline on a simple
counting loop ([i := 0; while i < 10: i := i + 1; assert i ≤ 20]) and
check that the inferred loop invariant is attached as an [assert] at the
loop head.

  $ bincaml script chc_loop.sexp
  (load-il chc_loop.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 8 predicates and 10 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 8 definitions
  (dump-il chc_loop_out.il)

The loop head block ([%loop]) keeps its phi node first, and the inferred
invariant is prepended as the next statement (so the phi target is in scope
when the assert is checked):

  $ awk '/block %loop \(/,/]/' chc_loop_out.il | head -5
     block %loop (
       var i_3:bv64 := phi(%loop_body -> i_5:bv64, %entry -> i_2:bv64)
     ) [
       assert boolor(eq(extract(64,4, i_3:bv64), 0x0:bv60),
        exists (x!3:bv64) :: (booland(eq(extract(64,4, x!3:bv64), 0x0:bv60),

The exit predicate's invariant is attached as an [ensures] clause on the
procedure spec:

  $ grep -c '^ *ensures' chc_loop_out.il
  1
