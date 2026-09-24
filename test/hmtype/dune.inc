

(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_use_global.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_use_global.il.out (run bincaml load-il ./error_use_global.il)))
    (diff? ./error_use_global.il.expected ./error_use_global.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_hint_global.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_hint_global.il.out (run bincaml load-il ./error_hint_global.il)))
    (diff? ./error_hint_global.il.expected ./error_hint_global.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_declaration_disagreement.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_declaration_disagreement.il.out (run bincaml load-il ./error_declaration_disagreement.il)))
    (diff? ./error_declaration_disagreement.il.expected ./error_declaration_disagreement.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_assign_local.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_assign_local.il.out (run bincaml load-il ./error_assign_local.il)))
    (diff? ./error_assign_local.il.expected ./error_assign_local.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_assign_global.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_assign_global.il.out (run bincaml load-il ./error_assign_global.il)))
    (diff? ./error_assign_global.il.expected ./error_assign_global.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./error_assert_type.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./error_assert_type.il.out (run bincaml load-il ./error_assert_type.il)))
    (diff? ./error_assert_type.il.expected ./error_assert_type.il.out)
)))




(rule
 (alias runtest)
 (package bincaml)
 (deps %{bin:bincaml} ./decl_use_hint_disagree.il)
 (action
    (progn
    (with-accepted-exit-codes (or 0 (not 0))
    (with-outputs-to ./decl_use_hint_disagree.il.out (run bincaml load-il ./decl_use_hint_disagree.il)))
    (diff? ./decl_use_hint_disagree.il.expected ./decl_use_hint_disagree.il.out)
)))


