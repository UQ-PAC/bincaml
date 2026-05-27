
CHC procedure-call encoding — [main] calls [helper] which returns [x + 1],
then asserts the result is [6]. Full encoding (use-spec disabled): helper's
predicates are connected to its call site by an [enter] clause and an [exit]
premise, so Spacer's inference of helper's spec is informed by the actual
call.

  $ bincaml script chc_call.sexp
  (load-il chc_call.il)
  (run-transforms ssa)
  (run-transforms load-store-reduction)
  (run-transforms lambda-lifting)
  (run-transforms chc-infer-invariants)
  bincaml: [INFO] Submitting 6 predicates and 7 clauses to solver
  bincaml: [INFO] Solver returned sat; extracted 6 definitions
  (dump-il chc_call_out.il)

Both procedures get annotations. Helper gets a [requires] derived from how
it's actually called (x = 5) and an [ensures] derived from its body
(y = 6 in this call context):

  $ grep -E '^ *(requires|ensures)' chc_call_out.il
    requires eq(x:bv64, 0x5:bv64)
    ensures eq(y:bv64, 0x6:bv64)
    ensures eq(out:bv64, 0x6:bv64)

The full encoding ties helper's verification to its call site — these specs
are accurate for this program but specific to it. For the use of more general
specs that don't depend on the caller's argument values, see chc_spec.t.
