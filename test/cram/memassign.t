
  $ dune exec bincaml -- dump-il memassign.il --proc '@main_4196164' | grep Global
    modifies $Global_4325420_4325424:bv32;
    captures $Global_4325420_4325424:bv32;
        $Global_4325420_4325424:bv32 := 0x2a:bv32;
