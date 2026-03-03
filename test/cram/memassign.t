
  $ dune exec bincaml -- dump-il memassign.il --proc '@main_4196164' | grep Global --before-context 1 --after-context 1
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32;
    captures $Global_4325420_4325424:bv32;
  
  --
     block %main_entry [
        $Global_4325420_4325424:bv32 := store  0x2a:bv32;
        goto (%main_return);
