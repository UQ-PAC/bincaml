
CHC invariant annotation (Step 4) — run the full pipeline ending in
[chc-infer-invariants] and check that the inferred postcondition appears as
an [ensures] clause in the dumped IR. The procedure returns [x + 1], so Spacer
should infer [exit⟨main⟩(x, out) ↔ out = x + 1].

  $ bincaml script chc_annotate.sexp
  (load-il chc_annotate.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 4 predicates and 4 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 4 definitions
  (dump-il chc_annotate_out.il)

The output IR carries an [ensures] clause relating [out] to [x]:

  $ grep -c '^ *ensures' chc_annotate_out.il
  1
  $ grep 'ensures' chc_annotate_out.il
    ensures eq(out:bv64, bvadd(0x1:bv64, x:bv64))

[enter⟨main⟩] is trivially true (no precondition to infer), so no [requires]
clause is added:

  $ grep '^ *requires' chc_annotate_out.il || echo "no requires"
  no requires
