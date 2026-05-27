
CHC use-spec mode — [helper] declares [requires]/[ensures], so the pass
verifies its body against the spec independently and uses the spec (not the
helper's [enter]/[exit] predicates) at the call site in [main].

  $ bincaml script chc_spec.sexp
  (load-il chc_spec.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 6 predicates and 9 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 6 definitions
  (dump-il chc_spec_out.il)

Helper's user-provided spec is preserved as-is (no duplicated inferred
clauses). Main has no user spec, so its inferred [ensures] is attached:

  $ grep -E '^ *(requires|ensures)' chc_spec_out.il
    requires bvult(x:bv64, 0x100:bv64)
    ensures eq(y:bv64, bvadd(x:bv64, 0x1:bv64))
    ensures eq(out:bv64, 0x6:bv64)

Use-spec mode means main's assertion was verified using helper's [ensures]
(not by inlining helper's body): the proof goes through even though main
calls helper with [x = 5], which satisfies [bvult(x, 0x100)], and the
postcondition [y = x + 1] gives [z = 6].
