
  $ cat << EOF | bincaml script -
  > (load-il "memassign.il")
  > (dump-il "memout.il")
  > EOF
  (load-il memassign.il)
  (dump-il memout.il)


  $ cat memout.il |  grep Global --before-context 1 --after-context 1
  type ilist = Cons of {head: bv64; tail: ilist} | Nil;
  var observable $Global_4325420_4325424:bv32 classification true;
  let $mul_2 (a:bv64), (b:bv64) : bv64 = (bvadd(b:bv64, bvmul(a:bv64, 0x2:bv64)));
  --
      .returnBlock = "main_return" }
    modifies $Global_4325420_4325424:bv32
    captures $Global_4325420_4325424:bv32
  
  --
     block %main_entry [
       $Global_4325420_4325424:bv32 := store  0x2a:bv32;
       goto (%main_return);
