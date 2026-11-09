(rule (targets bayat1.exe) (deps bayat1.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets bayat1.gtirb) (deps bayat1.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets bayat1.il) (deps bayat1.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets bayat2.exe) (deps bayat2.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets bayat2.gtirb) (deps bayat2.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets bayat2.il) (deps bayat2.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets eq.exe) (deps eq.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets eq.gtirb) (deps eq.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets eq.il) (deps eq.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets global_interproc_overlapping.exe) (deps global_interproc_overlapping.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets global_interproc_overlapping.gtirb) (deps global_interproc_overlapping.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets global_interproc_overlapping.il) (deps global_interproc_overlapping.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets indirect_overlapping.exe) (deps indirect_overlapping.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets indirect_overlapping.gtirb) (deps indirect_overlapping.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets indirect_overlapping.il) (deps indirect_overlapping.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets interproc_overlapping.exe) (deps interproc_overlapping.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets interproc_overlapping.gtirb) (deps interproc_overlapping.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets interproc_overlapping.il) (deps interproc_overlapping.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets interproc_pointer_arithmetic.exe) (deps interproc_pointer_arithmetic.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets interproc_pointer_arithmetic.gtirb) (deps interproc_pointer_arithmetic.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets interproc_pointer_arithmetic.il) (deps interproc_pointer_arithmetic.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets recursion.exe) (deps recursion.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets recursion.gtirb) (deps recursion.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets recursion.il) (deps recursion.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets split.exe) (deps split.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets split.gtirb) (deps split.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets split.il) (deps split.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets stackambiguity.exe) (deps stackambiguity.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stackambiguity.gtirb) (deps stackambiguity.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stackambiguity.il) (deps stackambiguity.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets stack_interproc_overlapping.exe) (deps stack_interproc_overlapping.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stack_interproc_overlapping.gtirb) (deps stack_interproc_overlapping.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stack_interproc_overlapping.il) (deps stack_interproc_overlapping.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets stack_reassignment.exe) (deps stack_reassignment.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stack_reassignment.gtirb) (deps stack_reassignment.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets stack_reassignment.il) (deps stack_reassignment.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

(rule (targets unsafe_pointer_arithmetic.exe) (deps unsafe_pointer_arithmetic.c) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets unsafe_pointer_arithmetic.gtirb) (deps unsafe_pointer_arithmetic.exe) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))
(rule (targets unsafe_pointer_arithmetic.il) (deps unsafe_pointer_arithmetic.gtirb) (mode promote) (enabled_if %{file-available:../../test/compile/runmake}) (action (run ../../test/compile/runmake %{targets})))

