
CHC memory invariants across a call -- [main] writes a secret value to
mem[0x100], calls [foo] which loops five times incrementing mem[0x100] by one
each iteration, then asserts mem[0x100] = secret + 5. [foo] has no user spec, so
the pass infers its [requires]/[ensures] (full encoding) and a loop invariant --
all expressed over the [$mem] global. Because the initial value is not a
constant, the inferred invariants are relational and refer to the
procedure-entry memory via [old($mem)].

  $ bincaml script chc_mem_call.sexp
  (load-il chc_mem_call.il)
  (run-transforms ssa)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 17 predicates and 19 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 17 definitions
  (dump-il chc_mem_call_out.il)

[foo] gets a relational memory postcondition -- after the call mem[0x100] holds
its entry value plus five, expressed via [get] (map access) over the original
[$mem] and its entry version [old($mem)]:

  $ grep -E '^ *ensures' chc_mem_call_out.il
    ensures eq(get($mem, 0x100:bv64), bvadd(0x5:bv8, get(old($mem), 0x100:bv64)))

The annotated output is the original program: the [$mem] global and the
addressed [store le]/[load le] instructions are preserved:

  $ grep -E '(store|load) le ' chc_mem_call_out.il
       var cur_1:bv8 := load le $mem:(bv64->bv8) 0x100:bv64 8;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 bvadd(cur_1:bv8,
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 secret_1:bv8 8;
       var v_1:bv8 := load le $mem:(bv64->bv8) 0x100:bv64 8;

The inferred loop-head invariant (a large Spacer formula, not pinned here)
relates the counter to both the current [get($mem, 0x100)] and the entry value
[get(old($mem), 0x100)]:

  $ awk '/block %loop \(/,/\];/' chc_mem_call_out.il | grep -F -q 'get($mem' && echo "current memory referenced in loop invariant"
  current memory referenced in loop invariant
  $ awk '/block %loop \(/,/\];/' chc_mem_call_out.il | grep -F -q 'get(old($mem' && echo "old memory referenced in loop invariant"
  old memory referenced in loop invariant
