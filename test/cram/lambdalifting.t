
Lambda lifting – minimal hand-crafted example.

$x is read+written by @callee and @caller; $y is read-only in @callee but
written by @caller.  After the pass:

  $ ../../bin/main.exe script ll_simple.sexp
  (load-il ll_simple.il)
  (dump-il before_ll.il)
  (run-transforms lambda-lifting)
  (run-transforms type-check)
  (dump-il after_ll.il)

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
  9,10c6,9
  <    block %entry [ $x:bv32 := bvadd($x, $y); goto (%ret); ];
  <    block %ret [ nop; return; ]
  ---
  >    block %inputs [ (var x:bv32 := x_in, var y:bv32 := y_in); goto (%entry); ];
  >    block %entry [ var x:bv32 := bvadd(x, y); goto (%ret); ];
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ var x_out:bv32 := x; return; ]
  12,14c11,12
  < proc @caller()  -> () {  }
  <   modifies $x:bv32, $y:bv32
  <   captures $x:bv32, $y:bv32
  ---
  > proc @caller(x_in:bv32, y_in:bv32)  -> (x_out:bv32, y_out:bv32) {  }
  >   
  16a15
  >    block %inputs [ (var x:bv32 := x_in, var y:bv32 := y_in); goto (%entry); ];
  18,20c17,19
  <      $y:bv32 := 0x0:bv32;
  <      $x:bv32 := 0x1:bv32;
  <      call @callee();
  ---
  >      var y:bv32 := 0x0:bv32;
  >      var x:bv32 := 0x1:bv32;
  >      (var x:bv32=x_out) := call @callee(x_in=x, y_in=y);
  23c22,23
  <    block %ret [ nop; return; ]
  ---
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ (var x_out:bv32 := x, var y_out:bv32 := y); return; ]
  [1]




Lambda lifting – requires/ensures/body Old expressions.
Checks that Old(e) in the body and ensures becomes e[g -> in_param(g)], and that
all global refs in requires (not just those under Old) become in-params.

  $ ../../bin/main.exe script ll_spec.sexp
  (load-il ll_spec.il)
  (dump-il before_ll_spec.il)
  (run-transforms lambda-lifting)
  (run-transforms type-check)
  (dump-il after_ll_spec.il)

  $ diff before_ll_spec.il after_ll_spec.il
  1,2d0
  < var $x:bv32;
  < var $y:bv32;
  4,8c2,4
  < proc @callee()  -> () {  }
  <   modifies $x:bv32
  <   captures $x:bv32, $y:bv32
  <   requires eq($x, 0x1:bv32)
  <   ensures eq($x, bvadd(old($x), $y))
  ---
  > proc @callee(x_in:bv32, y_in:bv32)  -> (x_out:bv32) {  }
  >   requires eq(x_in, 0x1:bv32)
  >   ensures eq(x_out, bvadd(x_in, y_in))
  11,16c7,10
  <    block %entry [
  <      assert eq($x, old($x));
  <      $x:bv32 := bvadd($x, $y);
  <      goto (%ret);
  <    ];
  <    block %ret [ nop; return; ]
  ---
  >    block %inputs [ (var x:bv32 := x_in, var y:bv32 := y_in); goto (%entry); ];
  >    block %entry [ assert eq(x, x_in); var x:bv32 := bvadd(x, y); goto (%ret); ];
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ var x_out:bv32 := x; return; ]
  18,20c12,13
  < proc @caller()  -> () {  }
  <   modifies $x:bv32, $y:bv32
  <   captures $x:bv32, $y:bv32
  ---
  > proc @caller(x_in:bv32, y_in:bv32)  -> (x_out:bv32, y_out:bv32) {  }
  >   
  22a16
  >    block %inputs [ (var x:bv32 := x_in, var y:bv32 := y_in); goto (%entry); ];
  24,26c18,20
  <      $y:bv32 := 0x0:bv32;
  <      $x:bv32 := 0x1:bv32;
  <      call @callee();
  ---
  >      var y:bv32 := 0x0:bv32;
  >      var x:bv32 := 0x1:bv32;
  >      (var x:bv32=x_out) := call @callee(x_in=x, y_in=y);
  29c23,24
  <    block %ret [ nop; return; ]
  ---
  >    block %ret [ nop; goto (%returns); ];
  >    block %returns [ (var x_out:bv32 := x, var y_out:bv32 := y); return; ]
  [1]




Lambda lifting – real example (irreducible_loop_1.il).
Verifies the pass completes without error, all top-level globals are removed,
and @main_1876 acquires the expected _in parameters.

  $ ../../bin/main.exe script ll_real.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transforms lambda-lifting)
  (run-transforms type-check)
  (dump-il after_ll_real.il)

  $ grep "^var" after_ll_real.il || echo "no top-level globals"
  no top-level globals

  $ head -4 after_ll_real.il
  prog entry @main_1876;
  proc @main_1876(CF_in:bv1, NF_in:bv1, R0_in:bv64, R1_in:bv64, R29_in:bv64,
     R30_in:bv64, R31_in:bv64, VF_in:bv1, ZF_in:bv1, mem_in:(bv64->bv8),
     stack_in:(bv64->bv8))
