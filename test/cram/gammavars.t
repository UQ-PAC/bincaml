
  $ bincaml script gammavars.sexp
  (load-il ../../examples/gamma.il)
  (dump-il before.il)
  (run-transforms gamma-vars)
  bincaml: [ERROR] global Gamma_$x:bool should have global sigil $
  (dump-il after.il)
  bincaml: Input error: parse error
           Related context:
           next token
           3 |   modifies Gamma_$x:bool, $x:bv64
                          ^^^^^^^^
           
           gammavars.sexp
           4 | (dump-il "after.il")
                                 ^
           
  [123]

  $ diff before.il after.il
  1,55d0
  < var $x:bv64;
  < proc @main()  -> (out:bv64) {  }
  <   modifies $x:bv64
  <   captures $x:bv64
  <   requires gamma($x)
  <   ensures gamma($x)
  < 
  < [
  <    block %main_entry [ ($x:bv64=out) := call @f(z=$x); goto (%main_return); ];
  <    block %main_return [ var out:bv64 := $x; return; ]
  < ];
  < proc @f(z:bv64)  -> (out:bv64) {  }
  <   requires gamma(z:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(z:bv64)))
  < 
  < [
  <    block %f_body [
  <      (var out:bv64=out) := call @h(a=z:bv64, b=bvmul(z:bv64, z:bv64));
  <      var out:bv64 := out:bv64;
  <      return;
  <    ]
  < ];
  < proc @g(a:bv64)  -> (out:bv64) {  }
  <   requires gamma(a:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(a:bv64)))
  < 
  < [
  <    block %g_body [
  <      (var out:bv64=out) := call @h(a=a:bv64, b=bvsub(a:bv64, 0x1:bv64));
  <      var out:bv64 := out:bv64;
  <      return;
  <    ]
  < ];
  < proc @h(a:bv64, b:bv64)  -> (out:bv64) {  }
  <   requires booland(gamma(a:bv64), gamma(b:bv64))
  <   ensures boolor(boolnot(booland(old(gamma(a:bv64)), old(gamma(b:bv64)))),
  <    gamma(out:bv64))
  < 
  < [
  <    block %h_entry [ goto (%h_2,%h_1); ];
  <    block %h_1 [
  <      assert gamma(a:bv64);
  <      guard eq(a:bv64, 0x0:bv64);
  <      var c:bv64 := b:bv64;
  <      goto (%h_return);
  <    ];
  <    block %h_2 [
  <      assert gamma(a:bv64);
  <      guard boolnot(eq(a:bv64, 0x0:bv64));
  <      (var c:bv64=out) := call @g(a=bvadd(a:bv64, b:bv64));
  <      goto (%h_return);
  <    ];
  <    block %h_return [ var out:bv64 := bvadd(c:bv64, 0x1:bv64); return; ]
  < ];
  < prog entry @main;
  \ No newline at end of file
  [1]
