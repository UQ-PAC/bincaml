
  $ cat << EOF | bincaml script -
  > (load-il "ops.il")
  > (run-transforms hindley-milner-elaborate)
  > (dump-il)
  > (run-transforms ssa linear-copy linear-const cf-expressions)
  > (dump-il)
  > EOF
  (load-il ops.il)
  (run-transforms hindley-milner-elaborate)
  (dump-il)
  proc @main()  -> () {  }
    
  
  [
     block %main_entry [
       var ia:int := 1;
       var ib:int := 2;
       var i:int := intadd(ia:int, ib:int);
       var i:int := intmul(ia:int, ib:int);
       var i:int := intdiv(ia:int, ib:int);
       var p:bool := intle(ia:int, ib:int);
       var p:bool := intlt(ia:int, ib:int);
       var a:bv64 := 0x1:bv64;
       var b:bv64 := 0x5:bv64;
       var n:bv64 := bvadd(a:bv64, b:bv64);
       var n:bv64 := bvsub(a:bv64, b:bv64);
       var n:bv64 := bvmul(a:bv64, b:bv64);
       var n:bv64 := bvsdiv(a:bv64, b:bv64);
       var p:bool := bvult(a:bv64, b:bv64);
       var p:bool := bvule(a:bv64, b:bv64);
       var p:bool := bvslt(a:bv64, b:bv64);
       var p:bool := bvsle(a:bv64, b:bv64);
       var n:bv64 := bvshl(a:bv64, b:bv64);
       var n:bv64 := bvashr(a:bv64, b:bv64);
       var n:bv64 := bvlshr(a:bv64, b:bv64);
       var n:bv64 := bvand(a:bv64, b:bv64);
       var n:bv64 := bvor(a:bv64, b:bv64);
       var ba:bool := true;
       var bb:bool := false;
       var p:bool := booland(true, false);
       var p:bool := boolor(ba:bool, bb:bool);
       var p:bool := implies(ba:bool, bb:bool);
       var p:bool := eq(ba:bool, bb:bool);
       var p:bool := eq(ba:bool, bb:bool);
       var p:bool := eq(a:bv64, b:bv64);
       var p:bool := neq(a:bv64, b:bv64);
       var p:bool := neq(true, false);
       var p:bool := eq(true, false);
       var p:bool := eq(1, 2);
       var p:bool := neq(1, 2);
       var p:bool := booland(eq(ia:int, ib:int), true);
       var p:bool := neq(0x1:bv64, 0x2:bv64);
       var n1:bv64 := bvadd(a:bv64,
        bvmul(b:bv64, bvsdiv(a:bv64, bvadd(b:bv64, b:bv64))));
       var n2:bv64 := bvadd(a:bv64,
        bvadd(bvmul(b:bv64, bvsdiv(a:bv64, b:bv64)), b:bv64));
       assert neq(n1:bv64, n2:bv64);
       return;
     ]
  ];
  prog entry @main;(run-transforms ssa linear-copy linear-const cf-expressions)
  (dump-il)
  proc @main()  -> () {  }
    
  
  [
     block %main_entry [
       var ia_1:int := 1;
       var ib_1:int := 2;
       var i_1:int := intadd(ia_1:int, ib_1:int);
       var i_2:int := intmul(ia_1:int, ib_1:int);
       var i_3:int := intdiv(ia_1:int, ib_1:int);
       var p_1:bool := intle(ia_1:int, ib_1:int);
       var p_2:bool := intlt(ia_1:int, ib_1:int);
       var a_1:bv64 := 0x1:bv64;
       var b_1:bv64 := 0x5:bv64;
       var n_1:bv64 := 0x6:bv64;
       var n_2:bv64 := 0xfffffffffffffffc:bv64;
       var n_3:bv64 := 0x5:bv64;
       var n_4:bv64 := 0x0:bv64;
       var p_3:bool := true;
       var p_4:bool := true;
       var p_5:bool := true;
       var p_6:bool := true;
       var n_5:bv64 := 0x20:bv64;
       var n_6:bv64 := 0x0:bv64;
       var n_7:bv64 := 0x0:bv64;
       var n_8:bv64 := 0x1:bv64;
       var n_9:bv64 := 0x5:bv64;
       var ba_1:bool := true;
       var bb_1:bool := false;
       var p_7:bool := false;
       var p_8:bool := boolor(ba_1:bool, bb_1:bool);
       var p_9:bool := boolor(bb_1:bool, boolnot(ba_1:bool));
       var p_10:bool := eq(ba_1:bool, bb_1:bool);
       var p_11:bool := eq(ba_1:bool, bb_1:bool);
       var p_12:bool := false;
       var p_13:bool := true;
       var p_14:bool := true;
       var p_15:bool := false;
       var p_16:bool := false;
       var p_17:bool := true;
       var p_18:bool := booland(eq(ia_1:int, ib_1:int), true);
       var p_19:bool := true;
       var n1_1:bv64 := 0x1:bv64;
       var n2_1:bv64 := 0x6:bv64;
       (var n1_2:bv64 := n1_1:bv64, var n2_2:bv64 := n2_1:bv64);
       assert neq(n1_1:bv64, n2_1:bv64);
       goto (%Return);
     ];
     block %Return [ nop; return; ]
  ];
  prog entry @main { .invariants = [ "SSA"; "Params" ] };
