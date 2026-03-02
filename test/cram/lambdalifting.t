
Lambda lifting – minimal hand-crafted example.

$x is read+written by @callee and @caller; $y is read-only in @callee but
written by @caller.  After the pass:

  $ ../../bin/main.exe script ll_simple.sexp

  $ cat before_ll.il
  var $x:bv32;
  var $y:bv32;
  prog entry @caller;
  proc @callee()  -> () {  }
    modifies $x:bv32;
    captures $x:bv32, $y:bv32;
  
  [
     block %entry [ $x:bv32 := bvadd($x:bv32, $y:bv32); goto (%ret); ];
     block %ret [ nop; return; ]
  ];
  proc @caller()  -> () {  }
    modifies $x:bv32, $y:bv32;
    captures $x:bv32, $y:bv32;
  
  [
     block %entry [
        $y:bv32 := 0x0:bv32;
        $x:bv32 := 0x1:bv32;
        
        call @callee();
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];




  $ cat after_ll.il
  prog entry @caller;
  proc @callee(x_in:bv32, $y:bv32)  -> ($x:bv32) {  }
    
  
  [
     block %ll_init [ $x:bv32 := x_in:bv32; goto (%entry); ];
     block %entry [ $x:bv32 := bvadd($x:bv32, $y:bv32); goto (%ret); ];
     block %ret [ nop; return; ]
  ];
  proc @caller(x_in:bv32, y_in:bv32)  -> ($x:bv32, $y:bv32) {  }
    
  
  [
     block %ll_init [
        ($x:bv32 := x_in:bv32, $y:bv32 := y_in:bv32);
        goto (%entry);
     ];
     block %entry [
        $y:bv32 := 0x0:bv32;
        $x:bv32 := 0x1:bv32;
        ($x:bv32=$x) := 
        call @callee($x_in=$x:bv32, $y=$y:bv32);
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];





Lambda lifting – requires/ensures/body Old expressions.
Checks that Old(e) in the body and ensures becomes e[g -> in_param(g)], and that
all global refs in requires (not just those under Old) become in-params.

  $ ../../bin/main.exe script ll_spec.sexp

  $ cat before_ll_spec.il
  var $x:bv32;
  var $y:bv32;
  prog entry @caller;
  proc @callee()  -> () {  }
    modifies $x:bv32;
    captures $x:bv32, $y:bv32;
    requires eq($x:bv32, 0x1:bv32);
    ensures eq($x:bv32, bvadd(old($x:bv32), $y:bv32));
  
  [
     block %entry [
        assert eq($x:bv32, old($x:bv32));
        $x:bv32 := bvadd($x:bv32, $y:bv32);
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];
  proc @caller()  -> () {  }
    modifies $x:bv32, $y:bv32;
    captures $x:bv32, $y:bv32;
  
  [
     block %entry [
        $y:bv32 := 0x0:bv32;
        $x:bv32 := 0x1:bv32;
        
        call @callee();
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];

  $ cat after_ll_spec.il
  prog entry @caller;
  proc @callee(x_in:bv32, $y:bv32)  -> ($x:bv32) {  }
    requires eq(x_in:bv32, 0x1:bv32);
    ensures eq($x:bv32, bvadd(x_in:bv32, $y:bv32));
  
  [
     block %ll_init [ $x:bv32 := x_in:bv32; goto (%entry); ];
     block %entry [
        assert eq($x:bv32, x_in:bv32);
        $x:bv32 := bvadd($x:bv32, $y:bv32);
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];
  proc @caller(x_in:bv32, y_in:bv32)  -> ($x:bv32, $y:bv32) {  }
    
  
  [
     block %ll_init [
        ($x:bv32 := x_in:bv32, $y:bv32 := y_in:bv32);
        goto (%entry);
     ];
     block %entry [
        $y:bv32 := 0x0:bv32;
        $x:bv32 := 0x1:bv32;
        ($x:bv32=$x) := 
        call @callee($x_in=$x:bv32, $y=$y:bv32);
        goto (%ret);
     ];
     block %ret [ nop; return; ]
  ];

Lambda lifting – real example (irreducible_loop_1.il).
Verifies the pass completes without error, all top-level globals are removed,
and @main_1876 acquires the expected _in parameters.

  $ ../../bin/main.exe script ll_real.sexp

  $ grep "^var" after_ll_real.il || echo "no top-level globals"
  no top-level globals

  $ head -4 after_ll_real.il
  prog entry @main_1876;
  proc @main_1876(CF_in:bv1, NF_in:bv1, R0_in:bv64, R1_in:bv64, R29_in:bv64,
     R30_in:bv64, R31_in:bv64, VF_in:bv1, ZF_in:bv1, mem_in:(bv64->bv8),
     stack_in:(bv64->bv8))
