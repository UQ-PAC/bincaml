  $ cat << EOF | bincaml script -
  > (load-gtirb "../../examples/gtirb/binsearch_sqrt.gtirb")
  > (dump-il gtirb-output.il)
  > (dump-il)
  > (load-il gtirb-output.il)
  > (dump-il "dumped.il")
  > EOF
  (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb)
  bincaml: (load-gtirb ../../examples/gtirb/binsearch_sqrt.gtirb): Failure("Failure(\"unsupported\")\nRaised at Stdlib.failwith in file \"stdlib.ml\", line 29, characters 17-33\nCalled from Transforms__Aslp.lift_opcode.(fun) in file \"lib/transforms/aslp/aslp.ml\", line 28, characters 10-71\nCalled from CCResult.guard_str_trace in file \"src/core/CCResult.ml\" (inlined), line 145, characters 31-37\nCalled from Transforms__Aslp.lift_opcode.(fun) in file \"lib/transforms/aslp/aslp.ml\", lines 27-29, characters 6-22\n\ncontext:opcode: 0xd503201f:bv32, address: 0x400828:bv64")
           
  [123]
  $ diff gtirb-output.il dumped.il
  diff: gtirb-output.il: No such file or directory
  diff: dumped.il: No such file or directory
  [2]
