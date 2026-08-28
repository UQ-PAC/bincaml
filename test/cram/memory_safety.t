  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms ssa)
  >  (run-transforms split-memory-encoding)
  >  (run-transforms memory-specification)
  >  (run-transforms ssa)
  >  (run-transforms linear-const)
  >  (run-transforms linear-copy)
  >  (run-transforms hindley-milner-elaborate)
  >  (run-transforms dynamic-single-assignment)
  >  (dump-il after.il)
  >  (dump-boogie out.bpl)
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms split-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms hindley-milner-elaborate)
  bincaml: (run-transforms hindley-milner-elaborate): Lang__Hm_inference__Hm_types.TypeErr("type_error: tvar:a_2 bv <> memory_encoding : eq { .boogie = { .msg = \"Memory Error: Invalid Free\" } }(mem_encoding_out:memory_encoding,\n ($me_alloc_live_update)(mem_encoding_in:memory_encoding,\n    ($me_addr_alloc)(mem_encoding_in:memory_encoding, R0_in:bv64), 0x2:bv2))")
           
  [123]
  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.

  $ cat << EOF | bincaml script -
  >  (load-il ../../examples/memory/memory_safety.il)
  >  (run-transforms ssa)
  >  (run-transforms flat-memory-encoding)
  >  (run-transforms memory-specification)
  >  (run-transforms ssa)
  >  (run-transforms linear-const)
  >  (run-transforms linear-copy)
  >  (run-transforms "dynamic-single-assignment")
  >  (dump-il /tmp/blah.il)
  >  (log-level debug)
  >  (run-transforms hindley-milner-elaborate)
  >  (dump-il after.il)
  >  (dump-boogie out.bpl)
  > EOF
  (load-il ../../examples/memory/memory_safety.il)
  (run-transforms ssa)
  (run-transforms flat-memory-encoding)
  (run-transforms memory-specification)
  (run-transforms ssa)
  (run-transforms linear-const)
  (run-transforms linear-copy)
  (run-transforms dynamic-single-assignment)
  (dump-il /tmp/blah.il)
  (log-level debug)
  (run-transforms hindley-milner-elaborate)
  bincaml: [DEBUG] Starting hindley-milner-elaborate
  bincaml: [DEBUG] unify: :0 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 8 ℕ bv with 64 ℕ bv -> 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ bv with 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ with 8 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 with 8
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_16 with tvar:memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_17 with tvar:memory_encoding_1
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_18 with tvar:memory_encoding_2
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_19 with tvar:memory_encoding_3
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_20 with tvar:memory_encoding_4
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_21 with tvar:memory_encoding_5
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_22 with tvar:memory_encoding_6
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_23 with tvar:memory_encoding_7
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_24 with tvar:memory_encoding_8
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_25 with tvar:memory_encoding_9
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_26 with tvar:memory_encoding_10
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_27 with tvar:memory_encoding_11
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_28 with tvar:memory_encoding_12
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_29 with tvar:memory_encoding_13
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_30 with tvar:memory_encoding_14
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_31 with tvar:memory_encoding_15
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> 64 ℕ bv with 64 ℕ bv -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 2 ℕ bv with int -> memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 2 ℕ bv with memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> int with 64 ℕ bv -> memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> int with memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> int -> memory_encoding -> memory_encoding with 64 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 2 ℕ bv -> int -> memory_encoding -> memory_encoding with 2 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding -> bool with memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 8 ℕ bv with 64 ℕ bv -> 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ bv with 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ with 8 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 with 8
  bincaml: [DEBUG] unify: :0 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 8 ℕ bv with 64 ℕ bv -> 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ bv with 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ with 8 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 with 8
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_32 with tvar:memory_encoding_16
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_33 with tvar:memory_encoding_17
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_34 with tvar:memory_encoding_18
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_35 with tvar:memory_encoding_19
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_36 with tvar:memory_encoding_20
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_37 with tvar:memory_encoding_21
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_38 with tvar:memory_encoding_22
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_39 with tvar:memory_encoding_23
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_40 with tvar:memory_encoding_24
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_41 with tvar:memory_encoding_25
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_42 with tvar:memory_encoding_26
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_43 with tvar:memory_encoding_27
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_44 with tvar:memory_encoding_28
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_45 with tvar:memory_encoding_29
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_46 with tvar:memory_encoding_30
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_47 with tvar:memory_encoding_31
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> 64 ℕ bv with 64 ℕ bv -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 2 ℕ bv with int -> memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 2 ℕ bv with memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> int with 64 ℕ bv -> memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> int with memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> int -> memory_encoding -> memory_encoding with 64 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 2 ℕ bv -> int -> memory_encoding -> memory_encoding with 2 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding -> bool with memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] infer lib/lang/hm/elaboration.ml:80 ($me_can_allocate)(mem_encoding_in:memory_encoding, R0_out:bv64, R0_in:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_can_allocate
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_in:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_out:bv64
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_in:bv64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> tvar:memory_encoding_16 -> tvar:v
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> tvar:memory_encoding_16 -> tvar:v
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with tvar:memory_encoding_16 -> tvar:v
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with tvar:memory_encoding_16
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:memory_encoding_16 with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with tvar:v
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v with bool
  bincaml: [DEBUG] unify: :0 bool with bool
  bincaml: [DEBUG] infer lib/lang/hm/elaboration.ml:80 eq(($me_addr_offset)(mem_encoding_out:memory_encoding, R0_out:bv64), 0x0:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:170 ($me_addr_offset)(mem_encoding_out:memory_encoding, R0_out:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_addr_offset
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_out:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_out:bv64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> 64 ℕ bv with 64 ℕ bv -> tvar:memory_encoding_17 -> tvar:v_6
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with tvar:memory_encoding_17 -> tvar:v_6
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with tvar:memory_encoding_17
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:memory_encoding_17 with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with tvar:v_6
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_6 with 64 ℕ bv
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:171 0x0:bv64
  bincaml: [DEBUG] unify: :0 tvar:v_10 with 64 ℕ bv
  bincaml: [DEBUG] unify: :0 tvar:a bv -> tvar:a bv -> bool with 64 ℕ bv -> 64 ℕ bv -> tvar:v_5
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 tvar:a bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 tvar:a with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> bool with 64 ℕ bv -> tvar:v_5
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with tvar:v_5
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_5 with bool
  bincaml: [DEBUG] unify: :0 bool with bool
  bincaml: [DEBUG] infer lib/lang/hm/elaboration.ml:80 eq(($me_alloc_base)(mem_encoding_out:memory_encoding,
      ($me_addr_alloc)(mem_encoding_out:memory_encoding, R0_out:bv64)), R0_out:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:170 ($me_alloc_base)(mem_encoding_out:memory_encoding,
     ($me_addr_alloc)(mem_encoding_out:memory_encoding, R0_out:bv64))
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_alloc_base
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_out:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 ($me_addr_alloc)(mem_encoding_out:memory_encoding, R0_out:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_addr_alloc
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_out:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_out:bv64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> int with 64 ℕ bv -> memory_encoding -> tvar:v_15
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> int with memory_encoding -> tvar:v_15
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with tvar:v_15
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_15 with int
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> tvar:v_12
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> tvar:v_12
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with tvar:v_12
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_12 with 64 ℕ bv
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:171 R0_out:bv64
  bincaml: [DEBUG] unify: :0 tvar:a_1 bv -> tvar:a_1 bv -> bool with 64 ℕ bv -> 64 ℕ bv -> tvar:v_11
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 tvar:a_1 bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 tvar:a_1 with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> bool with 64 ℕ bv -> tvar:v_11
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with tvar:v_11
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_11 with bool
  bincaml: [DEBUG] unify: :0 bool with bool
  bincaml: [DEBUG] infer lib/lang/hm/elaboration.ml:80 ($me_allocate)(mem_encoding_in:memory_encoding, mem_encoding_out:memory_encoding,
     R0_out:bv64, R0_in:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_allocate
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_in:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_out:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_out:bv64
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_in:bv64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> tvar:v_20
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> memory_encoding -> tvar:v_20
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding -> bool with memory_encoding -> memory_encoding -> tvar:v_20
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> tvar:v_20
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with tvar:v_20
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_20 with bool
  bincaml: [DEBUG] unify: :0 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_60 with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_61 with memory_encoding
  bincaml: [DEBUG] <global>::$me_addr_alloc . 64 ℕ bv -> memory_encoding -> int, <global>::$me_addr_is_heap . 64 ℕ bv -> memory_encoding -> bool, <global>::$me_addr_offset . 64 ℕ bv -> memory_encoding -> 64 ℕ bv, <global>::$me_alloc_base . int -> memory_encoding -> 64 ℕ bv, <global>::$me_alloc_live . int -> memory_encoding -> 2 ℕ bv, <global>::$me_alloc_live_update . 2 ℕ bv -> int -> memory_encoding -> memory_encoding, <global>::$me_alloc_size . int -> memory_encoding -> 64 ℕ bv, <global>::$me_alloc_size_update . 64 ℕ bv -> int -> memory_encoding -> memory_encoding, <global>::$me_allocate . 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool, <global>::$me_can_allocate . 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool, <global>::$me_init_encoding . memory_encoding -> bool, <global>::$me_valid_access . 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool, <global>::$mem . 64 ℕ bv -> 8 ℕ bv, <types>::memory_encoding . memory_encoding, @double_free::mem_encoding_in . tvar:memory_encoding_22, @double_free::mem_encoding_out . tvar:memory_encoding_23, @free::R0_in . 64 ℕ bv, @free::mem_encoding_in . tvar:memory_encoding_18, @free::mem_encoding_out . tvar:memory_encoding_19, @invalid_free::mem_encoding_in . tvar:memory_encoding_24, @invalid_free::mem_encoding_out . tvar:memory_encoding_25, @main::mem_encoding_in . tvar:memory_encoding_20, @main::mem_encoding_out . tvar:memory_encoding_21, @malloc::R0_in . 64 ℕ bv, @malloc::R0_out . 64 ℕ bv, @malloc::mem_encoding_in . memory_encoding, @malloc::mem_encoding_out . memory_encoding, @memory_leak::mem_encoding_in . tvar:memory_encoding_30, @memory_leak::mem_encoding_out . tvar:memory_encoding_31, @out_of_bounds::mem_encoding_in . tvar:memory_encoding_28, @out_of_bounds::mem_encoding_out . tvar:memory_encoding_29, @use_after_free::mem_encoding_in . tvar:memory_encoding_26, @use_after_free::mem_encoding_out . tvar:memory_encoding_27
  bincaml: [DEBUG] unify: :0 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 8 ℕ bv with 64 ℕ bv -> 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ bv with 8 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 ℕ with 8 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 8 with 8
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_62 with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_63 with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_64 with tvar:memory_encoding_18
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_65 with tvar:memory_encoding_19
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_66 with tvar:memory_encoding_20
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_67 with tvar:memory_encoding_21
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_68 with tvar:memory_encoding_22
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_69 with tvar:memory_encoding_23
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_70 with tvar:memory_encoding_24
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_71 with tvar:memory_encoding_25
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_72 with tvar:memory_encoding_26
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_73 with tvar:memory_encoding_27
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_74 with tvar:memory_encoding_28
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_75 with tvar:memory_encoding_29
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_76 with tvar:memory_encoding_30
  bincaml: [DEBUG] unify: :0 tvar:memory_encoding_77 with tvar:memory_encoding_31
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> 64 ℕ bv with 64 ℕ bv -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 2 ℕ bv with int -> memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 2 ℕ bv with memory_encoding -> 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: :0 int -> memory_encoding -> 64 ℕ bv with int -> memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> 64 ℕ bv with memory_encoding -> 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> int with 64 ℕ bv -> memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> int with memory_encoding -> int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> int -> memory_encoding -> memory_encoding with 64 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 2 ℕ bv -> int -> memory_encoding -> memory_encoding with 2 ℕ bv -> int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding -> bool with memory_encoding -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv -> memory_encoding -> bool with 64 ℕ bv -> memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> bool with memory_encoding -> bool
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 bool with bool
  bincaml: [DEBUG] infer lib/lang/hm/elaboration.ml:80 eq { .boogie = { .msg = "Memory Error: Invalid Free" } }(mem_encoding_out:memory_encoding,
   ($me_alloc_live_update)(mem_encoding_in:memory_encoding,
      ($me_addr_alloc)(mem_encoding_in:memory_encoding, R0_in:bv64), 0x2:bv2))
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:170 mem_encoding_out:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:171 ($me_alloc_live_update)(mem_encoding_in:memory_encoding,
     ($me_addr_alloc)(mem_encoding_in:memory_encoding, R0_in:bv64), 0x2:bv2)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_alloc_live_update
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_in:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 ($me_addr_alloc)(mem_encoding_in:memory_encoding, R0_in:bv64)
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:182 $me_addr_alloc
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 mem_encoding_in:memory_encoding
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 R0_in:bv64
  bincaml: [DEBUG] unify: :0 64 ℕ bv -> memory_encoding -> int with 64 ℕ bv -> tvar:memory_encoding_18 -> tvar:v_31
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ bv with 64 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 ℕ with 64 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 64 with 64
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> int with tvar:memory_encoding_18 -> tvar:v_31
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with tvar:memory_encoding_18
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:memory_encoding_18 with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with tvar:v_31
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_31 with int
  bincaml: [DEBUG] infer lib/lang/hm/inference.ml:183 0x2:bv2
  bincaml: [DEBUG] unify: :0 tvar:v_35 with 2 ℕ bv
  bincaml: [DEBUG] unify: :0 2 ℕ bv -> int -> memory_encoding -> memory_encoding with 2 ℕ bv -> int -> memory_encoding -> tvar:v_28
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ bv with 2 ℕ bv
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 ℕ with 2 ℕ
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 2 with 2
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int -> memory_encoding -> memory_encoding with int -> memory_encoding -> tvar:v_28
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 int with int
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding -> memory_encoding with memory_encoding -> tvar:v_28
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with memory_encoding
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 memory_encoding with tvar:v_28
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:44 tvar:v_28 with memory_encoding
  bincaml: [DEBUG] unify: :0 tvar:a_2 bv -> tvar:a_2 bv -> bool with memory_encoding -> tvar:memory_encoding_19 -> tvar:v_26
  bincaml: [DEBUG] unify: lib/lang/hm_inference/unification.ml:60 tvar:a_2 bv with memory_encoding
  bincaml: [DEBUG] Raised at Lang__Hm__Inference.infer_expr.(fun) in file "lib/lang/hm/inference.ml", line 195, characters 22-78
  Called from Lang__Hm__Elaboration.infer_proc.ibool_list.(fun) in file "lib/lang/hm/elaboration.ml", line 80, characters 16-52
  Called from Stdlib__List.map in file "list.ml", line 83, characters 15-19
  Called from Lang__Hm__Elaboration.infer_proc in file "lib/lang/hm/elaboration.ml", line 88, characters 16-39
  Called from Lang__Hm__Elaboration.infer_decl in file "lib/lang/hm/elaboration.ml" (inlined), line 136, characters 19-49
  Called from Lang__Hm__Elaboration.infer_decl.(fun) in file "lib/lang/hm/elaboration.ml", line 263, characters 37-70
  Called from CCList.fold_map.aux in file "src/core/CCList.ml", line 197, characters 19-26
  Called from Lang__Hm__Elaboration.infer_program in file "lib/lang/hm/elaboration.ml", lines 277-278, characters 4-78
  Called from Lang__Hm.elaborate_prog in file "lib/lang/hm/hm.ml", line 233, characters 21-54
  Called from Bincaml__Passes.PassManager.run_transform.(fun) in file "lib/passes.ml", line 578, characters 16-20
  Called from Trace_core.with_current_span_set_to in file "src/core/trace_core.ml" (inlined), line 47, characters 16-20
  Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 74, characters 4-33
  Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 82, characters 4-40
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Bincaml__Script.run_transform in file "lib/script.ml", line 199, characters 18-65
  Called from Bincaml__Script.atom_cmd.(fun) in file "lib/script.ml", line 436, characters 23-32
  Called from Trace_core.with_current_span_set_to in file "src/core/trace_core.ml" (inlined), line 47, characters 16-20
  Called from Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 74, characters 4-33
  Re-raised at Trace_core.with_span_collector_ in file "src/core/trace_core.ml", line 82, characters 4-40
  Called from Bincaml__Script.of_chan_2 in file "lib/script.ml", line 472, characters 16-31
  
  bincaml: (run-transforms hindley-milner-elaborate): Lang__Hm_inference__Hm_types.TypeErr("type_error: tvar:a_2 bv <> memory_encoding : eq { .boogie = { .msg = \"Memory Error: Invalid Free\" } }(mem_encoding_out:memory_encoding,\n ($me_alloc_live_update)(mem_encoding_in:memory_encoding,\n    ($me_addr_alloc)(mem_encoding_in:memory_encoding, R0_in:bv64), 0x2:bv2))")
           
  [123]

  $ boogie out.bpl
  Error opening file "out.bpl": Could not find file '$TESTCASE_ROOT/out.bpl'.
