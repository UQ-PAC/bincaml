


  $ cat << EOF | bincaml script -
  > (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  > (list-procs)
  > (run-transform trim-procs-reachable ("@Sqrt"))
  > (list-procs)
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  (list-procs)
  ("@_fini", 1)
  ("@_init", 2)
  ("@__do_global_dtors_aux", 3)
  ("@register_tm_clones", 4)
  ("@frame_dummy", 5)
  ("@FUN_400660", 6)
  ("@Sqrt", 7)
  ("@_start", 8)
  ("@_dl_relocate_static_pie", 9)
  ("@call_weak_fn", 10)
  ("@main", 11)
  ("@.L_400650", 12)
  ("@FUN_400640", 13)
  ("@deregister_tm_clones", 14)
  ("@FUN_400620", 15)
  (run-transform trim-procs-reachable (@Sqrt))
  (list-procs)
  ("@Sqrt", 7)


  $ cat << EOF | bincaml script -
  > (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  > (run-transform set-main-proc "@main")
  > (run-transform trim-procs-reachable ())
  > (list-procs)
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  (run-transform set-main-proc @main)
  (run-transform trim-procs-reachable ())
  (list-procs)
  ("@Sqrt", 7)
  ("@main", 11)
