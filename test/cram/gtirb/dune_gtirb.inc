
(rule
 (alias runtest)
 (package bincaml)
 (deps
  %{bin:bincaml}
  (source_tree  ../../../examples/gtirb)
  run.sh
  )
 (action
  (no-infer
   (progn
    (bash pwd)
    (bash "mkdir out")

    (concurrent

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/arrays_simple/clang/arrays_simple-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/arrays_simple/clang/arrays_simple-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/arrays_simple/clang/arrays_simple.gts"))
            (diff "../../../examples/gtirb/basil/arrays_simple/clang/arrays_simple-initial-gts.expected" "../../../examples/gtirb/basil/arrays_simple/clang/arrays_simple-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_read/clang/basic_arrays_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_read/clang/basic_arrays_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_read/clang/basic_arrays_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_read/clang/basic_arrays_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_read/clang/basic_arrays_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_read/clang_pic/basic_arrays_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_read/clang_pic/basic_arrays_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_read/clang_pic/basic_arrays_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_read/clang_pic/basic_arrays_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_read/clang_pic/basic_arrays_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_read/gcc/basic_arrays_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_read/gcc/basic_arrays_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_read/gcc/basic_arrays_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_read/gcc/basic_arrays_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_read/gcc/basic_arrays_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_read/gcc_pic/basic_arrays_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_read/gcc_pic/basic_arrays_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_read/gcc_pic/basic_arrays_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_read/gcc_pic/basic_arrays_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_read/gcc_pic/basic_arrays_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/clang/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/clang/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/clang/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/clang/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/clang/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/clang_O2/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/clang_O2/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/clang_O2/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/clang_O2/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/clang_O2/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/clang_pic/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/clang_pic/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/clang_pic/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/clang_pic/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/clang_pic/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/gcc/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/gcc/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/gcc/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/gcc/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/gcc/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/gcc_O2/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/gcc_O2/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/gcc_O2/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/gcc_O2/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/gcc_O2/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_arrays_write/gcc_pic/basic_arrays_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_arrays_write/gcc_pic/basic_arrays_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_arrays_write/gcc_pic/basic_arrays_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_arrays_write/gcc_pic/basic_arrays_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_arrays_write/gcc_pic/basic_arrays_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_assign/clang/basic_assign_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_assign/clang/basic_assign_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_assign/clang/basic_assign_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_assign/clang/basic_assign_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_assign/clang/basic_assign_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_assign/clang_pic/basic_assign_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_assign/clang_pic/basic_assign_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_assign/clang_pic/basic_assign_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_assign/clang_pic/basic_assign_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_assign/clang_pic/basic_assign_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_assign/gcc/basic_assign_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_assign/gcc/basic_assign_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_assign/gcc/basic_assign_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_assign/gcc/basic_assign_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_assign/gcc/basic_assign_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_assign/gcc_O2/basic_assign_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_assign/gcc_O2/basic_assign_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_assign/gcc_O2/basic_assign_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_assign/gcc_O2/basic_assign_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_assign/gcc_O2/basic_assign_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_assign/gcc_pic/basic_assign_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_assign/gcc_pic/basic_assign_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_assign/gcc_pic/basic_assign_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_assign/gcc_pic/basic_assign_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_assign/gcc_pic/basic_assign_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_increment/clang/basic_assign_increment-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_increment/clang/basic_assign_increment-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_increment/clang/basic_assign_increment.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_increment/clang/basic_assign_increment-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_increment/clang/basic_assign_increment-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_increment/clang_pic/basic_assign_increment-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_increment/clang_pic/basic_assign_increment-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_increment/clang_pic/basic_assign_increment.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_increment/clang_pic/basic_assign_increment-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_increment/clang_pic/basic_assign_increment-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_increment/gcc/basic_assign_increment-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_increment/gcc/basic_assign_increment-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_increment/gcc/basic_assign_increment.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_increment/gcc/basic_assign_increment-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_increment/gcc/basic_assign_increment-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_increment/gcc_O2/basic_assign_increment-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_increment/gcc_O2/basic_assign_increment-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_increment/gcc_O2/basic_assign_increment.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_increment/gcc_O2/basic_assign_increment-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_increment/gcc_O2/basic_assign_increment-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_assign_increment/gcc_pic/basic_assign_increment-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_assign_increment/gcc_pic/basic_assign_increment-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_assign_increment/gcc_pic/basic_assign_increment.gts"))
            (diff "../../../examples/gtirb/basil/basic_assign_increment/gcc_pic/basic_assign_increment-initial-gts.expected" "../../../examples/gtirb/basil/basic_assign_increment/gcc_pic/basic_assign_increment-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/clang/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/clang/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/clang/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/clang/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/clang/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/clang_O2/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/clang_O2/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/clang_O2/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/clang_O2/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/clang_O2/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/clang_pic/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/clang_pic/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/clang_pic/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/clang_pic/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/clang_pic/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/gcc/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/gcc/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/gcc/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/gcc/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/gcc/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/gcc_O2/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/gcc_O2/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/gcc_O2/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/gcc_O2/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/gcc_O2/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_caller/gcc_pic/basic_function_call_caller-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_caller/gcc_pic/basic_function_call_caller-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_caller/gcc_pic/basic_function_call_caller.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_caller/gcc_pic/basic_function_call_caller-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_caller/gcc_pic/basic_function_call_caller-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/clang/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/clang/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/clang/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/clang/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/clang/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/clang_O2/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/clang_O2/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/clang_O2/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/clang_O2/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/clang_O2/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/clang_pic/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/clang_pic/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/clang_pic/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/clang_pic/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/clang_pic/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/gcc/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/gcc/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/gcc/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/gcc/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/gcc/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/gcc_O2/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/gcc_O2/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/gcc_O2/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/gcc_O2/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/gcc_O2/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_function_call_reader/gcc_pic/basic_function_call_reader-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_function_call_reader/gcc_pic/basic_function_call_reader-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_function_call_reader/gcc_pic/basic_function_call_reader.gts"))
            (diff "../../../examples/gtirb/basil/basic_function_call_reader/gcc_pic/basic_function_call_reader-initial-gts.expected" "../../../examples/gtirb/basil/basic_function_call_reader/gcc_pic/basic_function_call_reader-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/clang/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/clang/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/clang/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/clang/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/clang/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/clang_O2/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/clang_O2/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/clang_O2/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/clang_O2/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/clang_O2/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/clang_pic/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/clang_pic/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/clang_pic/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/clang_pic/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/clang_pic/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/gcc/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/gcc/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/gcc/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/gcc/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/gcc/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/gcc_O2/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/gcc_O2/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/gcc_O2/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/gcc_O2/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/gcc_O2/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_read/gcc_pic/basic_lock_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_read/gcc_pic/basic_lock_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_read/gcc_pic/basic_lock_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_read/gcc_pic/basic_lock_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_read/gcc_pic/basic_lock_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/clang/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/clang/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/clang/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/clang/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/clang/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/clang_O2/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/clang_O2/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/clang_O2/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/clang_O2/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/clang_O2/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/clang_pic/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/clang_pic/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/clang_pic/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/clang_pic/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/clang_pic/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/gcc/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/gcc/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/gcc/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/gcc/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/gcc/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/gcc_O2/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/gcc_O2/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/gcc_O2/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/gcc_O2/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/gcc_O2/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_read/gcc_pic/basic_lock_security_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_read/gcc_pic/basic_lock_security_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_read/gcc_pic/basic_lock_security_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_read/gcc_pic/basic_lock_security_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_read/gcc_pic/basic_lock_security_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/clang/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/clang/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/clang/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/clang/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/clang/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/clang_O2/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/clang_O2/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/clang_O2/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/clang_O2/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/clang_O2/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/clang_pic/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/clang_pic/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/clang_pic/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/clang_pic/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/clang_pic/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/gcc/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/gcc/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/gcc/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/gcc/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/gcc/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/gcc_O2/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/gcc_O2/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/gcc_O2/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/gcc_O2/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/gcc_O2/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_security_write/gcc_pic/basic_lock_security_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_security_write/gcc_pic/basic_lock_security_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_security_write/gcc_pic/basic_lock_security_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_security_write/gcc_pic/basic_lock_security_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_security_write/gcc_pic/basic_lock_security_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_unlock/clang/basic_lock_unlock-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_unlock/clang/basic_lock_unlock-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_unlock/clang/basic_lock_unlock.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_unlock/clang/basic_lock_unlock-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_unlock/clang/basic_lock_unlock-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_unlock/clang_pic/basic_lock_unlock-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_unlock/clang_pic/basic_lock_unlock-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_unlock/clang_pic/basic_lock_unlock.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_unlock/clang_pic/basic_lock_unlock-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_unlock/clang_pic/basic_lock_unlock-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_unlock/gcc/basic_lock_unlock-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_unlock/gcc/basic_lock_unlock-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_unlock/gcc/basic_lock_unlock.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_unlock/gcc/basic_lock_unlock-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_unlock/gcc/basic_lock_unlock-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_unlock/gcc_O2/basic_lock_unlock-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_unlock/gcc_O2/basic_lock_unlock-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_unlock/gcc_O2/basic_lock_unlock.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_unlock/gcc_O2/basic_lock_unlock-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_unlock/gcc_O2/basic_lock_unlock-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_lock_unlock/gcc_pic/basic_lock_unlock-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_lock_unlock/gcc_pic/basic_lock_unlock-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_lock_unlock/gcc_pic/basic_lock_unlock.gts"))
            (diff "../../../examples/gtirb/basil/basic_lock_unlock/gcc_pic/basic_lock_unlock-initial-gts.expected" "../../../examples/gtirb/basil/basic_lock_unlock/gcc_pic/basic_lock_unlock-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_loop_assign/clang/basic_loop_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_loop_assign/clang/basic_loop_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_loop_assign/clang/basic_loop_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_loop_assign/clang/basic_loop_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_loop_assign/clang/basic_loop_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_loop_assign/clang_pic/basic_loop_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_loop_assign/clang_pic/basic_loop_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_loop_assign/clang_pic/basic_loop_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_loop_assign/clang_pic/basic_loop_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_loop_assign/clang_pic/basic_loop_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_loop_assign/gcc/basic_loop_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_loop_assign/gcc/basic_loop_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_loop_assign/gcc/basic_loop_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_loop_assign/gcc/basic_loop_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_loop_assign/gcc/basic_loop_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_loop_assign/gcc_O2/basic_loop_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_loop_assign/gcc_O2/basic_loop_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_loop_assign/gcc_O2/basic_loop_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_loop_assign/gcc_O2/basic_loop_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_loop_assign/gcc_O2/basic_loop_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_loop_assign/gcc_pic/basic_loop_assign-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_loop_assign/gcc_pic/basic_loop_assign-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_loop_assign/gcc_pic/basic_loop_assign.gts"))
            (diff "../../../examples/gtirb/basil/basic_loop_assign/gcc_pic/basic_loop_assign-initial-gts.expected" "../../../examples/gtirb/basil/basic_loop_assign/gcc_pic/basic_loop_assign-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_operation_evaluation/clang/basic_operation_evaluation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_operation_evaluation/clang/basic_operation_evaluation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_operation_evaluation/clang/basic_operation_evaluation.gts"))
            (diff "../../../examples/gtirb/basil/basic_operation_evaluation/clang/basic_operation_evaluation-initial-gts.expected" "../../../examples/gtirb/basil/basic_operation_evaluation/clang/basic_operation_evaluation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_operation_evaluation/gcc/basic_operation_evaluation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_operation_evaluation/gcc/basic_operation_evaluation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_operation_evaluation/gcc/basic_operation_evaluation.gts"))
            (diff "../../../examples/gtirb/basil/basic_operation_evaluation/gcc/basic_operation_evaluation-initial-gts.expected" "../../../examples/gtirb/basil/basic_operation_evaluation/gcc/basic_operation_evaluation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/clang/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/clang/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/clang/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/clang/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/clang/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/clang_O2/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/clang_O2/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/clang_O2/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/clang_O2/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/clang_O2/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/clang_pic/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/clang_pic/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/clang_pic/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/clang_pic/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/clang_pic/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/gcc/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/gcc/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/gcc/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/gcc/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/gcc/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/gcc_O2/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_O2/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/gcc_O2/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_O2/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_O2/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_read/gcc_pic/basic_sec_policy_read-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_pic/basic_sec_policy_read-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_read/gcc_pic/basic_sec_policy_read.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_pic/basic_sec_policy_read-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_read/gcc_pic/basic_sec_policy_read-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/clang/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/clang/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/clang/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/clang/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/clang/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/clang_O2/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/clang_O2/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/clang_O2/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/clang_O2/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/clang_O2/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/clang_pic/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/clang_pic/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/clang_pic/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/clang_pic/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/clang_pic/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/gcc/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/gcc/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/gcc/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/gcc/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/gcc/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/gcc_O2/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_O2/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/gcc_O2/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_O2/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_O2/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basic_sec_policy_write/gcc_pic/basic_sec_policy_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_pic/basic_sec_policy_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basic_sec_policy_write/gcc_pic/basic_sec_policy_write.gts"))
            (diff "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_pic/basic_sec_policy_write-initial-gts.expected" "../../../examples/gtirb/basil/basic_sec_policy_write/gcc_pic/basic_sec_policy_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicassign_gamma0/clang/basicassign_gamma0-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicassign_gamma0/clang/basicassign_gamma0-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicassign_gamma0/clang/basicassign_gamma0.gts"))
            (diff "../../../examples/gtirb/basil/basicassign_gamma0/clang/basicassign_gamma0-initial-gts.expected" "../../../examples/gtirb/basil/basicassign_gamma0/clang/basicassign_gamma0-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicassign_gamma0/clang_pic/basicassign_gamma0-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicassign_gamma0/clang_pic/basicassign_gamma0-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicassign_gamma0/clang_pic/basicassign_gamma0.gts"))
            (diff "../../../examples/gtirb/basil/basicassign_gamma0/clang_pic/basicassign_gamma0-initial-gts.expected" "../../../examples/gtirb/basil/basicassign_gamma0/clang_pic/basicassign_gamma0-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicassign_gamma0/gcc/basicassign_gamma0-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicassign_gamma0/gcc/basicassign_gamma0-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicassign_gamma0/gcc/basicassign_gamma0.gts"))
            (diff "../../../examples/gtirb/basil/basicassign_gamma0/gcc/basicassign_gamma0-initial-gts.expected" "../../../examples/gtirb/basil/basicassign_gamma0/gcc/basicassign_gamma0-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicassign_gamma0/gcc_O2/basicassign_gamma0-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicassign_gamma0/gcc_O2/basicassign_gamma0-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicassign_gamma0/gcc_O2/basicassign_gamma0.gts"))
            (diff "../../../examples/gtirb/basil/basicassign_gamma0/gcc_O2/basicassign_gamma0-initial-gts.expected" "../../../examples/gtirb/basil/basicassign_gamma0/gcc_O2/basicassign_gamma0-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicassign_gamma0/gcc_pic/basicassign_gamma0-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicassign_gamma0/gcc_pic/basicassign_gamma0-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicassign_gamma0/gcc_pic/basicassign_gamma0.gts"))
            (diff "../../../examples/gtirb/basil/basicassign_gamma0/gcc_pic/basicassign_gamma0-initial-gts.expected" "../../../examples/gtirb/basil/basicassign_gamma0/gcc_pic/basicassign_gamma0-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicfree/clang/basicfree-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicfree/clang/basicfree-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicfree/clang/basicfree.gts"))
            (diff "../../../examples/gtirb/basil/basicfree/clang/basicfree-initial-gts.expected" "../../../examples/gtirb/basil/basicfree/clang/basicfree-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/basicfree/gcc/basicfree-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/basicfree/gcc/basicfree-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/basicfree/gcc/basicfree.gts"))
            (diff "../../../examples/gtirb/basil/basicfree/gcc/basicfree-initial-gts.expected" "../../../examples/gtirb/basil/basicfree/gcc/basicfree-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/cjump/clang/cjump-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/cjump/clang/cjump-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/cjump/clang/cjump.gts"))
            (diff "../../../examples/gtirb/basil/cjump/clang/cjump-initial-gts.expected" "../../../examples/gtirb/basil/cjump/clang/cjump-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/cjump/clang_pic/cjump-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/cjump/clang_pic/cjump-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/cjump/clang_pic/cjump.gts"))
            (diff "../../../examples/gtirb/basil/cjump/clang_pic/cjump-initial-gts.expected" "../../../examples/gtirb/basil/cjump/clang_pic/cjump-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/cjump/gcc/cjump-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/cjump/gcc/cjump-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/cjump/gcc/cjump.gts"))
            (diff "../../../examples/gtirb/basil/cjump/gcc/cjump-initial-gts.expected" "../../../examples/gtirb/basil/cjump/gcc/cjump-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/cjump/gcc_pic/cjump-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/cjump/gcc_pic/cjump-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/cjump/gcc_pic/cjump.gts"))
            (diff "../../../examples/gtirb/basil/cjump/gcc_pic/cjump-initial-gts.expected" "../../../examples/gtirb/basil/cjump/gcc_pic/cjump-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/floatingpoint/clang/floatingpoint-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/floatingpoint/clang/floatingpoint-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/floatingpoint/clang/floatingpoint.gts"))
            (diff "../../../examples/gtirb/basil/floatingpoint/clang/floatingpoint-initial-gts.expected" "../../../examples/gtirb/basil/floatingpoint/clang/floatingpoint-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/floatingpoint/gcc/floatingpoint-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/floatingpoint/gcc/floatingpoint-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/floatingpoint/gcc/floatingpoint.gts"))
            (diff "../../../examples/gtirb/basil/floatingpoint/gcc/floatingpoint-initial-gts.expected" "../../../examples/gtirb/basil/floatingpoint/gcc/floatingpoint-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function/clang/function-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function/clang/function-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function/clang/function.gts"))
            (diff "../../../examples/gtirb/basil/function/clang/function-initial-gts.expected" "../../../examples/gtirb/basil/function/clang/function-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function/clang_pic/function-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function/clang_pic/function-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function/clang_pic/function.gts"))
            (diff "../../../examples/gtirb/basil/function/clang_pic/function-initial-gts.expected" "../../../examples/gtirb/basil/function/clang_pic/function-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function/gcc/function-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function/gcc/function-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function/gcc/function.gts"))
            (diff "../../../examples/gtirb/basil/function/gcc/function-initial-gts.expected" "../../../examples/gtirb/basil/function/gcc/function-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function/gcc_pic/function-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function/gcc_pic/function-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function/gcc_pic/function.gts"))
            (diff "../../../examples/gtirb/basil/function/gcc_pic/function-initial-gts.expected" "../../../examples/gtirb/basil/function/gcc_pic/function-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function1/clang/function1-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function1/clang/function1-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function1/clang/function1.gts"))
            (diff "../../../examples/gtirb/basil/function1/clang/function1-initial-gts.expected" "../../../examples/gtirb/basil/function1/clang/function1-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function1/clang_O2/function1-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function1/clang_O2/function1-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function1/clang_O2/function1.gts"))
            (diff "../../../examples/gtirb/basil/function1/clang_O2/function1-initial-gts.expected" "../../../examples/gtirb/basil/function1/clang_O2/function1-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function1/gcc/function1-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function1/gcc/function1-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function1/gcc/function1.gts"))
            (diff "../../../examples/gtirb/basil/function1/gcc/function1-initial-gts.expected" "../../../examples/gtirb/basil/function1/gcc/function1-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/function1/gcc_O2/function1-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/function1/gcc_O2/function1-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/function1/gcc_O2/function1.gts"))
            (diff "../../../examples/gtirb/basil/function1/gcc_O2/function1-initial-gts.expected" "../../../examples/gtirb/basil/function1/gcc_O2/function1-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functionpointer/clang/functionpointer-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functionpointer/clang/functionpointer-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functionpointer/clang/functionpointer.gts"))
            (diff "../../../examples/gtirb/basil/functionpointer/clang/functionpointer-initial-gts.expected" "../../../examples/gtirb/basil/functionpointer/clang/functionpointer-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functionpointer/clang_pic/functionpointer-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functionpointer/clang_pic/functionpointer-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functionpointer/clang_pic/functionpointer.gts"))
            (diff "../../../examples/gtirb/basil/functionpointer/clang_pic/functionpointer-initial-gts.expected" "../../../examples/gtirb/basil/functionpointer/clang_pic/functionpointer-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functionpointer/gcc/functionpointer-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functionpointer/gcc/functionpointer-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functionpointer/gcc/functionpointer.gts"))
            (diff "../../../examples/gtirb/basil/functionpointer/gcc/functionpointer-initial-gts.expected" "../../../examples/gtirb/basil/functionpointer/gcc/functionpointer-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functionpointer/gcc_O2/functionpointer-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functionpointer/gcc_O2/functionpointer-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functionpointer/gcc_O2/functionpointer.gts"))
            (diff "../../../examples/gtirb/basil/functionpointer/gcc_O2/functionpointer-initial-gts.expected" "../../../examples/gtirb/basil/functionpointer/gcc_O2/functionpointer-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functionpointer/gcc_pic/functionpointer-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functionpointer/gcc_pic/functionpointer-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functionpointer/gcc_pic/functionpointer.gts"))
            (diff "../../../examples/gtirb/basil/functionpointer/gcc_pic/functionpointer-initial-gts.expected" "../../../examples/gtirb/basil/functionpointer/gcc_pic/functionpointer-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functions_with_params/clang/functions_with_params-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functions_with_params/clang/functions_with_params-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functions_with_params/clang/functions_with_params.gts"))
            (diff "../../../examples/gtirb/basil/functions_with_params/clang/functions_with_params-initial-gts.expected" "../../../examples/gtirb/basil/functions_with_params/clang/functions_with_params-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/functions_with_params/gcc/functions_with_params-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/functions_with_params/gcc/functions_with_params-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/functions_with_params/gcc/functions_with_params.gts"))
            (diff "../../../examples/gtirb/basil/functions_with_params/gcc/functions_with_params-initial-gts.expected" "../../../examples/gtirb/basil/functions_with_params/gcc/functions_with_params-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifbranches/clang/ifbranches-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifbranches/clang/ifbranches-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifbranches/clang/ifbranches.gts"))
            (diff "../../../examples/gtirb/basil/ifbranches/clang/ifbranches-initial-gts.expected" "../../../examples/gtirb/basil/ifbranches/clang/ifbranches-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifbranches/clang_O2/ifbranches-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifbranches/clang_O2/ifbranches-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifbranches/clang_O2/ifbranches.gts"))
            (diff "../../../examples/gtirb/basil/ifbranches/clang_O2/ifbranches-initial-gts.expected" "../../../examples/gtirb/basil/ifbranches/clang_O2/ifbranches-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifbranches/gcc/ifbranches-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifbranches/gcc/ifbranches-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifbranches/gcc/ifbranches.gts"))
            (diff "../../../examples/gtirb/basil/ifbranches/gcc/ifbranches-initial-gts.expected" "../../../examples/gtirb/basil/ifbranches/gcc/ifbranches-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifbranches/gcc_O2/ifbranches-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifbranches/gcc_O2/ifbranches-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifbranches/gcc_O2/ifbranches.gts"))
            (diff "../../../examples/gtirb/basil/ifbranches/gcc_O2/ifbranches-initial-gts.expected" "../../../examples/gtirb/basil/ifbranches/gcc_O2/ifbranches-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/clang/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/clang/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/clang/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/clang/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/clang/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/clang_O2/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/clang_O2/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/clang_O2/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/clang_O2/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/clang_O2/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/clang_pic/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/clang_pic/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/clang_pic/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/clang_pic/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/clang_pic/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/gcc/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/gcc/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/gcc/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/gcc/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/gcc/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/gcc_O2/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/gcc_O2/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/gcc_O2/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/gcc_O2/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/gcc_O2/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/ifglobal/gcc_pic/ifglobal-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/ifglobal/gcc_pic/ifglobal-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/ifglobal/gcc_pic/ifglobal.gts"))
            (diff "../../../examples/gtirb/basil/ifglobal/gcc_pic/ifglobal-initial-gts.expected" "../../../examples/gtirb/basil/ifglobal/gcc_pic/ifglobal-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/indirect_call/clang/indirect_call-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/indirect_call/clang/indirect_call-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/indirect_call/clang/indirect_call.gts"))
            (diff "../../../examples/gtirb/basil/indirect_call/clang/indirect_call-initial-gts.expected" "../../../examples/gtirb/basil/indirect_call/clang/indirect_call-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/indirect_call/clang_pic/indirect_call-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/indirect_call/clang_pic/indirect_call-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/indirect_call/clang_pic/indirect_call.gts"))
            (diff "../../../examples/gtirb/basil/indirect_call/clang_pic/indirect_call-initial-gts.expected" "../../../examples/gtirb/basil/indirect_call/clang_pic/indirect_call-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/indirect_call/gcc/indirect_call-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/indirect_call/gcc/indirect_call-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/indirect_call/gcc/indirect_call.gts"))
            (diff "../../../examples/gtirb/basil/indirect_call/gcc/indirect_call-initial-gts.expected" "../../../examples/gtirb/basil/indirect_call/gcc/indirect_call-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/indirect_call/gcc_pic/indirect_call-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/indirect_call/gcc_pic/indirect_call-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/indirect_call/gcc_pic/indirect_call.gts"))
            (diff "../../../examples/gtirb/basil/indirect_call/gcc_pic/indirect_call-initial-gts.expected" "../../../examples/gtirb/basil/indirect_call/gcc_pic/indirect_call-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/clang/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/clang/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/clang/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/clang/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/clang/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/clang_O2/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/clang_O2/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/clang_O2/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/clang_O2/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/clang_O2/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/clang_pic/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/clang_pic/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/clang_pic/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/clang_pic/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/clang_pic/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/gcc/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/gcc/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/gcc/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/gcc/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/gcc/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/gcc_O2/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/gcc_O2/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/gcc_O2/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/gcc_O2/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/gcc_O2/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/initialisation/gcc_pic/initialisation-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/initialisation/gcc_pic/initialisation-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/initialisation/gcc_pic/initialisation.gts"))
            (diff "../../../examples/gtirb/basil/initialisation/gcc_pic/initialisation-initial-gts.expected" "../../../examples/gtirb/basil/initialisation/gcc_pic/initialisation-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/clang/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/clang/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/clang/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/clang/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/clang/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/clang_O2/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/clang_O2/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/clang_O2/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/clang_O2/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/clang_O2/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/clang_pic/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/clang_pic/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/clang_pic/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/clang_pic/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/clang_pic/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/gcc/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/gcc/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/gcc/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/gcc/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/gcc/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/gcc_O2/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/gcc_O2/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/gcc_O2/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/gcc_O2/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/gcc_O2/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/jumptable2/gcc_pic/jumptable2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/jumptable2/gcc_pic/jumptable2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/jumptable2/gcc_pic/jumptable2.gts"))
            (diff "../../../examples/gtirb/basil/jumptable2/gcc_pic/jumptable2-initial-gts.expected" "../../../examples/gtirb/basil/jumptable2/gcc_pic/jumptable2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local/clang/malloc_with_local-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local/clang/malloc_with_local-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local/clang/malloc_with_local.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local/clang/malloc_with_local-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local/clang/malloc_with_local-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local/clang_O2/malloc_with_local-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local/clang_O2/malloc_with_local-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local/clang_O2/malloc_with_local.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local/clang_O2/malloc_with_local-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local/clang_O2/malloc_with_local-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local/gcc/malloc_with_local-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local/gcc/malloc_with_local-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local/gcc/malloc_with_local.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local/gcc/malloc_with_local-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local/gcc/malloc_with_local-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local/gcc_O2/malloc_with_local-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local/gcc_O2/malloc_with_local-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local/gcc_O2/malloc_with_local.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local/gcc_O2/malloc_with_local-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local/gcc_O2/malloc_with_local-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local2/clang/malloc_with_local2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local2/clang/malloc_with_local2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local2/clang/malloc_with_local2.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local2/clang/malloc_with_local2-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local2/clang/malloc_with_local2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local2/gcc/malloc_with_local2-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local2/gcc/malloc_with_local2-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local2/gcc/malloc_with_local2.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local2/gcc/malloc_with_local2-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local2/gcc/malloc_with_local2-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local3/clang/malloc_with_local3-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local3/clang/malloc_with_local3-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local3/clang/malloc_with_local3.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local3/clang/malloc_with_local3-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local3/clang/malloc_with_local3-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local3/gcc/malloc_with_local3-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local3/gcc/malloc_with_local3-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local3/gcc/malloc_with_local3.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local3/gcc/malloc_with_local3-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local3/gcc/malloc_with_local3-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/malloc_with_local3/gcc_O2/malloc_with_local3-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/malloc_with_local3/gcc_O2/malloc_with_local3-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/malloc_with_local3/gcc_O2/malloc_with_local3.gts"))
            (diff "../../../examples/gtirb/basil/malloc_with_local3/gcc_O2/malloc_with_local3-initial-gts.expected" "../../../examples/gtirb/basil/malloc_with_local3/gcc_O2/malloc_with_local3-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/multi_malloc/clang/multi_malloc-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/multi_malloc/clang/multi_malloc-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/multi_malloc/clang/multi_malloc.gts"))
            (diff "../../../examples/gtirb/basil/multi_malloc/clang/multi_malloc-initial-gts.expected" "../../../examples/gtirb/basil/multi_malloc/clang/multi_malloc-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/multi_malloc/gcc/multi_malloc-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/multi_malloc/gcc/multi_malloc-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/multi_malloc/gcc/multi_malloc.gts"))
            (diff "../../../examples/gtirb/basil/multi_malloc/gcc/multi_malloc-initial-gts.expected" "../../../examples/gtirb/basil/multi_malloc/gcc/multi_malloc-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_x/clang/no_interference_update_x-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_x/clang/no_interference_update_x-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_x/clang/no_interference_update_x.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_x/clang/no_interference_update_x-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_x/clang/no_interference_update_x-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_x/clang_pic/no_interference_update_x-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_x/clang_pic/no_interference_update_x-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_x/clang_pic/no_interference_update_x.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_x/clang_pic/no_interference_update_x-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_x/clang_pic/no_interference_update_x-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_x/gcc/no_interference_update_x-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_x/gcc/no_interference_update_x-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_x/gcc/no_interference_update_x.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_x/gcc/no_interference_update_x-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_x/gcc/no_interference_update_x-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_x/gcc_O2/no_interference_update_x-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_x/gcc_O2/no_interference_update_x-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_x/gcc_O2/no_interference_update_x.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_x/gcc_O2/no_interference_update_x-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_x/gcc_O2/no_interference_update_x-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_x/gcc_pic/no_interference_update_x-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_x/gcc_pic/no_interference_update_x-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_x/gcc_pic/no_interference_update_x.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_x/gcc_pic/no_interference_update_x-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_x/gcc_pic/no_interference_update_x-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_y/clang/no_interference_update_y-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_y/clang/no_interference_update_y-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_y/clang/no_interference_update_y.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_y/clang/no_interference_update_y-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_y/clang/no_interference_update_y-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_y/clang_pic/no_interference_update_y-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_y/clang_pic/no_interference_update_y-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_y/clang_pic/no_interference_update_y.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_y/clang_pic/no_interference_update_y-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_y/clang_pic/no_interference_update_y-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_y/gcc/no_interference_update_y-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_y/gcc/no_interference_update_y-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_y/gcc/no_interference_update_y.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_y/gcc/no_interference_update_y-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_y/gcc/no_interference_update_y-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_y/gcc_O2/no_interference_update_y-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_y/gcc_O2/no_interference_update_y-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_y/gcc_O2/no_interference_update_y.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_y/gcc_O2/no_interference_update_y-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_y/gcc_O2/no_interference_update_y-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/no_interference_update_y/gcc_pic/no_interference_update_y-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/no_interference_update_y/gcc_pic/no_interference_update_y-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/no_interference_update_y/gcc_pic/no_interference_update_y.gts"))
            (diff "../../../examples/gtirb/basil/no_interference_update_y/gcc_pic/no_interference_update_y-initial-gts.expected" "../../../examples/gtirb/basil/no_interference_update_y/gcc_pic/no_interference_update_y-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/clang/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/clang/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/clang/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/clang/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/clang/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/clang_O2/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/clang_O2/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/clang_O2/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/clang_O2/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/clang_O2/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/clang_pic/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/clang_pic/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/clang_pic/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/clang_pic/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/clang_pic/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/gcc/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/gcc/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/gcc/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/gcc/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/gcc/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/gcc_O2/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/gcc_O2/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/gcc_O2/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/gcc_O2/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/gcc_O2/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/secret_write/gcc_pic/secret_write-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/secret_write/gcc_pic/secret_write-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/secret_write/gcc_pic/secret_write.gts"))
            (diff "../../../examples/gtirb/basil/secret_write/gcc_pic/secret_write-initial-gts.expected" "../../../examples/gtirb/basil/secret_write/gcc_pic/secret_write-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/switch/clang/switch-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/switch/clang/switch-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/switch/clang/switch.gts"))
            (diff "../../../examples/gtirb/basil/switch/clang/switch-initial-gts.expected" "../../../examples/gtirb/basil/switch/clang/switch-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/switch/clang_O2/switch-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/switch/clang_O2/switch-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/switch/clang_O2/switch.gts"))
            (diff "../../../examples/gtirb/basil/switch/clang_O2/switch-initial-gts.expected" "../../../examples/gtirb/basil/switch/clang_O2/switch-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/switch/gcc/switch-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/switch/gcc/switch-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/switch/gcc/switch.gts"))
            (diff "../../../examples/gtirb/basil/switch/gcc/switch-initial-gts.expected" "../../../examples/gtirb/basil/switch/gcc/switch-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/switch/gcc_O2/switch-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/switch/gcc_O2/switch-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/switch/gcc_O2/switch.gts"))
            (diff "../../../examples/gtirb/basil/switch/gcc_O2/switch-initial-gts.expected" "../../../examples/gtirb/basil/switch/gcc_O2/switch-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/syscall/clang/syscall-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/syscall/clang/syscall-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/syscall/clang/syscall.gts"))
            (diff "../../../examples/gtirb/basil/syscall/clang/syscall-initial-gts.expected" "../../../examples/gtirb/basil/syscall/clang/syscall-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/syscall/clang_O2/syscall-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/syscall/clang_O2/syscall-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/syscall/clang_O2/syscall.gts"))
            (diff "../../../examples/gtirb/basil/syscall/clang_O2/syscall-initial-gts.expected" "../../../examples/gtirb/basil/syscall/clang_O2/syscall-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/syscall/gcc/syscall-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/syscall/gcc/syscall-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/syscall/gcc/syscall.gts"))
            (diff "../../../examples/gtirb/basil/syscall/gcc/syscall-initial-gts.expected" "../../../examples/gtirb/basil/syscall/gcc/syscall-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/syscall/gcc_O2/syscall-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/syscall/gcc_O2/syscall-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/syscall/gcc_O2/syscall.gts"))
            (diff "../../../examples/gtirb/basil/syscall/gcc_O2/syscall-initial-gts.expected" "../../../examples/gtirb/basil/syscall/gcc_O2/syscall-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_conditional/clang/using_gamma_conditional-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_conditional/clang/using_gamma_conditional-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_conditional/clang/using_gamma_conditional.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_conditional/clang/using_gamma_conditional-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_conditional/clang/using_gamma_conditional-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_conditional/clang_O2/using_gamma_conditional-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_conditional/clang_O2/using_gamma_conditional-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_conditional/clang_O2/using_gamma_conditional.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_conditional/clang_O2/using_gamma_conditional-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_conditional/clang_O2/using_gamma_conditional-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_conditional/clang_pic/using_gamma_conditional-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_conditional/clang_pic/using_gamma_conditional-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_conditional/clang_pic/using_gamma_conditional.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_conditional/clang_pic/using_gamma_conditional-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_conditional/clang_pic/using_gamma_conditional-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_conditional/gcc/using_gamma_conditional-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_conditional/gcc/using_gamma_conditional-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_conditional/gcc/using_gamma_conditional.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_conditional/gcc/using_gamma_conditional-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_conditional/gcc/using_gamma_conditional-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_conditional/gcc_pic/using_gamma_conditional-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_conditional/gcc_pic/using_gamma_conditional-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_conditional/gcc_pic/using_gamma_conditional.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_conditional/gcc_pic/using_gamma_conditional-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_conditional/gcc_pic/using_gamma_conditional-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_write_z/clang/using_gamma_write_z-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_write_z/clang/using_gamma_write_z-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_write_z/clang/using_gamma_write_z.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_write_z/clang/using_gamma_write_z-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_write_z/clang/using_gamma_write_z-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_write_z/clang_pic/using_gamma_write_z-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_write_z/clang_pic/using_gamma_write_z-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_write_z/clang_pic/using_gamma_write_z.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_write_z/clang_pic/using_gamma_write_z-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_write_z/clang_pic/using_gamma_write_z-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_write_z/gcc/using_gamma_write_z-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_write_z/gcc/using_gamma_write_z-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_write_z/gcc/using_gamma_write_z.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_write_z/gcc/using_gamma_write_z-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_write_z/gcc/using_gamma_write_z-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_write_z/gcc_O2/using_gamma_write_z-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_write_z/gcc_O2/using_gamma_write_z-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_write_z/gcc_O2/using_gamma_write_z.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_write_z/gcc_O2/using_gamma_write_z-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_write_z/gcc_O2/using_gamma_write_z-initial-gts.expected.gen")
        )
  

        (progn
            (bash "mkdir -p $(dirname ../../../examples/gtirb/basil/using_gamma_write_z/gcc_pic/using_gamma_write_z-initial-gts.expected)")
            (with-stdout-to "../../../examples/gtirb/basil/using_gamma_write_z/gcc_pic/using_gamma_write_z-initial-gts.expected.gen" (bash "./run.sh ../../../examples/gtirb/basil/using_gamma_write_z/gcc_pic/using_gamma_write_z.gts"))
            (diff "../../../examples/gtirb/basil/using_gamma_write_z/gcc_pic/using_gamma_write_z-initial-gts.expected" "../../../examples/gtirb/basil/using_gamma_write_z/gcc_pic/using_gamma_write_z-initial-gts.expected.gen")
        )
  
    )
))))
