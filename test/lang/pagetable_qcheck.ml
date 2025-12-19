
module Pagetable_sequential = STM_sequential.Make (Pagetable_spec.Spec)

let _ =
  QCheck_base_runner.run_tests ~verbose:true
    [ Pagetable_sequential.agree_test ~count:1000 ~name:"STM sequential tests" ]
