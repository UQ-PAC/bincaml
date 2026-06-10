
CHC memory invariants across a call — [main] writes mem[0x100] = 0x20, calls
[foo] which loops five times incrementing mem[0x100] by one each iteration,
then asserts mem[0x100] = 0x25. [foo] has no user spec, so the pass infers its
[requires]/[ensures] (full encoding) and a loop invariant — all expressed over
the [$mem] global.

  $ bincaml script chc_mem_call.sexp
  (load-il chc_mem_call.il)
  (run-transforms ssa)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 17 predicates and 19 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 17 definitions
  (dump-il chc_mem_call_out.il)

[foo] gets a memory postcondition — after the call mem[0x100] holds 0x25 (the
initial 0x20 plus five increments), expressed via [get] (map access) over the
original [$mem]:

  $ grep -E '^ *ensures' chc_mem_call_out.il
    ensures eq(get($mem, 0x100:bv64), 0x25:bv8)

The annotated output is the original program: the [$mem] global and the
addressed [store le]/[load le] instructions are preserved:

  $ grep -E '(store|load) le ' chc_mem_call_out.il
       var cur_1:bv8 := load le $mem:(bv64->bv8) 0x100:bv64 8;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 bvadd(cur_1:bv8,
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 0x20:bv8 8;
       var v_1:bv8 := load le $mem:(bv64->bv8) 0x100:bv64 8;

The inferred loop-head invariant (a large Spacer formula, not pinned here)
relates the counter to [get($mem, 0x100)] across the 0x20..0x25 progression:

  $ awk '/block %loop \(/,/\];/' chc_mem_call_out.il | grep -F -q 'get($mem' && echo "memory referenced in loop invariant"
  memory referenced in loop invariant
