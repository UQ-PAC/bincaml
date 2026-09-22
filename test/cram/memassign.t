
  $ cat << EOF | bincaml script -
  > (load-il "memassign.il")
  > (dump-il "memout.il")
  > EOF
  (load-il memassign.il)
  (dump-il memout.il)


  $ cat memout.il |  grep Global -B 1 -A 1
  var observable $Global_4325420_4325424:bv32 classification true;
  type uninterpSort = UninterpSort;
  --
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32
    captures $Global_4325420_4325424:bv32
  
  --
         .originalLabel = "SFN4dpBgSO2bPUu0fyDluw==" } [
       $Global_4325420_4325424:bv32 := store  0x2a:bv32 { .label = "4196176_0" };
       goto (%main_return);
