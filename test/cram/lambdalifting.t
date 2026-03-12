
Lambda lifting – minimal hand-crafted example.

$x is read+written by @callee and @caller; $y is read-only in @callee but
written by @caller.  After the pass:

  $ ../../bin/main.exe script ll_simple.sexp

  $ diff before_ll.il after_ll.il
  1,2d0
  < var $x:bv32;
  < var $y:bv32;
  4,6c2,3
  < proc @callee()  -> () {  }
  <   modifies $x:bv32
  <   captures $x:bv32, $y:bv32
  ---
  > proc @callee(x_in:bv32, y_in:bv32)  -> (x_out:bv32) {  }
  >   
  9,10c6,12
  <    block %entry [ $x:bv32 := bvadd($x:bv32, $y:bv32); goto (%ret); ];
  <    block %ret [ nop; return; ]
  ---
  >    block %inputs [
  >      (var x:bv32 := x_in:bv32, var y:bv32 := y_in:bv32);
  >      goto (%entry);
  >    ];
  >    block %entry [ var x:bv32 := bvadd(x:bv32, y:bv32); goto (%ret); ];
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ var x_out:bv32 := x:bv32; return; ]
  12,14c14,15
  < proc @caller()  -> () {  }
  <   modifies $x:bv32, $y:bv32
  <   captures $x:bv32, $y:bv32
  ---
  > proc @caller(x_in:bv32, y_in:bv32)  -> (x_out:bv32, y_out:bv32) {  }
  >   
  16a18,21
  >    block %inputs [
  >      (var x:bv32 := x_in:bv32, var y:bv32 := y_in:bv32);
  >      goto (%entry);
  >    ];
  18,21c23,26
  <      $y:bv32 := 0x0:bv32;
  <      $x:bv32 := 0x1:bv32;
  <      
  <      call @callee();
  ---
  >      var y:bv32 := 0x0:bv32;
  >      var x:bv32 := 0x1:bv32;
  >      (var x:bv32=x_out) := 
  >      call @callee(x_in=x:bv32, y_in=y:bv32);
  24c29,33
  <    block %ret [ nop; return; ]
  ---
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [
  >      (var x_out:bv32 := x:bv32, var y_out:bv32 := y:bv32);
  >      return;
  >    ]
  [1]




Lambda lifting – requires/ensures/body Old expressions.
Checks that Old(e) in the body and ensures becomes e[g -> in_param(g)], and that
all global refs in requires (not just those under Old) become in-params.

  $ ../../bin/main.exe script ll_spec.sexp

  $ diff before_ll_spec.il after_ll_spec.il
  1,2d0
  < var $x:bv32;
  < var $y:bv32;
  4,8c2,4
  < proc @callee()  -> () {  }
  <   modifies $x:bv32
  <   captures $x:bv32, $y:bv32
  <   requires eq($x:bv32, 0x1:bv32)
  <   ensures eq($x:bv32, bvadd(old($x:bv32), $y:bv32))
  ---
  > proc @callee(x_in:bv32, y_in:bv32)  -> (x_out:bv32) {  }
  >   requires eq(x_in:bv32, 0x1:bv32)
  >   ensures eq(x_out:bv32, bvadd(x_in:bv32, y_in:bv32))
  10a7,10
  >    block %inputs [
  >      (var x:bv32 := x_in:bv32, var y:bv32 := y_in:bv32);
  >      goto (%entry);
  >    ];
  12,13c12,13
  <      assert eq($x:bv32, old($x:bv32));
  <      $x:bv32 := bvadd($x:bv32, $y:bv32);
  ---
  >      assert eq(x:bv32, x_in:bv32);
  >      var x:bv32 := bvadd(x:bv32, y:bv32);
  16c16,17
  <    block %ret [ nop; return; ]
  ---
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ var x_out:bv32 := x:bv32; return; ]
  18,20c19,20
  < proc @caller()  -> () {  }
  <   modifies $x:bv32, $y:bv32
  <   captures $x:bv32, $y:bv32
  ---
  > proc @caller(x_in:bv32, y_in:bv32)  -> (x_out:bv32, y_out:bv32) {  }
  >   
  22a23,26
  >    block %inputs [
  >      (var x:bv32 := x_in:bv32, var y:bv32 := y_in:bv32);
  >      goto (%entry);
  >    ];
  24,27c28,31
  <      $y:bv32 := 0x0:bv32;
  <      $x:bv32 := 0x1:bv32;
  <      
  <      call @callee();
  ---
  >      var y:bv32 := 0x0:bv32;
  >      var x:bv32 := 0x1:bv32;
  >      (var x:bv32=x_out) := 
  >      call @callee(x_in=x:bv32, y_in=y:bv32);
  30c34,38
  <    block %ret [ nop; return; ]
  ---
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [
  >      (var x_out:bv32 := x:bv32, var y_out:bv32 := y:bv32);
  >      return;
  >    ]
  [1]




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
