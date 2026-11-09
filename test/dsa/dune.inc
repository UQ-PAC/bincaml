(rule
 (targets bayat1.il)
 (deps bayat1.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets bayat2.il)
 (deps bayat2.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets eq.il)
 (deps eq.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets global_interproc_overlapping.il)
 (deps global_interproc_overlapping.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets indirect_overlapping.il)
 (deps indirect_overlapping.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets interproc_overlapping.il)
 (deps interproc_overlapping.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets interproc_pointer_arithmetic.il)
 (deps interproc_pointer_arithmetic.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets recursion.il)
 (deps recursion.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets split.il)
 (deps split.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets stackambiguity.il)
 (deps stackambiguity.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets stack_interproc_overlapping.il)
 (deps stack_interproc_overlapping.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets stack_reassignment.il)
 (deps stack_reassignment.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

(rule
 (targets unsafe_pointer_arithmetic.il)
 (deps unsafe_pointer_arithmetic.c)
 (enabled_if %{file-available:../../test/compile/runmake})
 (mode promote)
 (action
  (run ../../test/compile/runmake %{targets})))

