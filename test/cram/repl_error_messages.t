

non-existent command

  $ cat << EOF > test.sexp
  > (load-il "../../examples/irreducible_loop_1.il")
  > (non-command)
  > EOF

  $ bincaml script test.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (non-command)
  bincaml: Error: not a command: non-command
           Related context:
           test.sexp
           2 | (non-command)
                          ^
           
  [123]


run command without program loaded

  $ cat << EOF > test.sexp
  > (run-transform ssa)
  > EOF
  $ bincaml script test.sexp
  (run-transform ssa)
  bincaml: Exception Invalid_argument("no program loaded"): 
           Related context:
           test.sexp
           1 | (run-transform ssa)
                                ^
           
  [123]


run nonexistent transform

  $ cat << EOF > test.sexp
  > (load-il "../../examples/irreducible_loop_1.il")
  > (run-transform blah)
  > EOF
  $ bincaml script test.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transform blah)
  bincaml: Exception Invalid_argument("not found: blah"): 
           Related context:
           test.sexp
           2 | (run-transform blah)
                                 ^
           
  [123]


parse error file

  $ echo "a" > empty.il
  $ cat << EOF > test.sexp
  > (load-il "empty.il")
  > EOF
  $ bincaml script test.sexp
  (load-il empty.il)
  bincaml: Input error: parse error
           Related context:
           next token
           1 | a
               ^
           
           command: load-il (empty.il)
           test.sexp
           1 | (load-il "empty.il")
                                 ^
           
  [123]


