

non-existent command

  $ cat << EOF > test.sexp
  > (load-il "../../examples/irreducible_loop_1.il")
  > (non-command)
  > EOF

  $ bincaml script test.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (non-command)
  bincaml: Related context:
           test.sexp
           2 | (non-command)
                          ^
           Error: not a command: non-command
           
           
  [123]


run command without program loaded

  $ cat << EOF > test.sexp
  > (run-transform ssa)
  > EOF
  $ bincaml script test.sexp
  (run-transform ssa)
  bincaml: Related context:
           test.sexp
           1 | (run-transform ssa)
                                ^
           Exception Invalid_argument("no program loaded"): 
           
           
  [123]


run nonexistent transform

  $ cat << EOF > test.sexp
  > (load-il "../../examples/irreducible_loop_1.il")
  > (run-transform blah)
  > EOF
  $ bincaml script test.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transform blah)
  bincaml: Related context:
           test.sexp
           2 | (run-transform blah)
                                 ^
           Exception Invalid_argument("not found: blah"): 
           
           
  [123]


parse error file

  $ echo "a" > empty.il
  $ cat << EOF > test.sexp
  > (load-il "empty.il")
  > EOF
  $ bincaml script test.sexp
  (load-il empty.il)
  bincaml: Related context:
           next token
           1 | a
               ^
           
           command: load-il (empty.il)
           test.sexp
           1 | (load-il "empty.il")
                                 ^
           Input error: parse error
           
           
  [123]


