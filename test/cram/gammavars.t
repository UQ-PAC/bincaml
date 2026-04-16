
  $ bincaml script gammavars.sexp
  (load-il ../../examples/gamma.il)
  (dump-il before.il)
  (run-transforms gamma-vars)
  bincaml: [ERROR] global Gamma_$x:bool should have global sigil $
  (dump-il after.il)

  $ diff before.il after.il
  2,6c2,6
  < proc @main()  -> (out:bv64) {  }
  <   modifies $x:bv64
  <   captures $x:bv64
  <   requires gamma($x)
  <   ensures gamma($x)
  ---
  > proc @main()  -> (Gamma_out:bool, out:bv64) {  }
  >   modifies Gamma_$x:bool, $x:bv64
  >   captures Gamma_$x:bool, $x:bv64
  >   requires Gamma_$x
  >   ensures Gamma_$x
  9,10c9,16
  <    block %main_entry [ ($x:bv64=out) := call @f(z=$x); goto (%main_return); ];
  <    block %main_return [ var out:bv64 := $x; return; ]
  ---
  >    block %main_entry [
  >      (Gamma_$x:bool=Gamma_out, $x:bv64=out) := call @f(Gamma_z=Gamma_$x, z=$x);
  >      goto (%main_return);
  >    ];
  >    block %main_return [
  >      (var Gamma_out:bool := Gamma_$x, var out:bv64 := $x);
  >      return;
  >    ]
  12,14c18,20
  < proc @f(z:bv64)  -> (out:bv64) {  }
  <   requires gamma(z:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(z:bv64)))
  ---
  > proc @f(Gamma_z:bool, z:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_z:bool
  >   ensures eq(Gamma_out:bool, old(Gamma_z:bool))
  18,19c24,26
  <      (var out:bv64=out) := call @h(a=z:bv64, b=bvmul(z:bv64, z:bv64));
  <      var out:bv64 := out:bv64;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := call @h(Gamma_a=Gamma_z:bool,
  >         Gamma_b=Gamma_z:bool, a=z:bv64, b=bvmul(z:bv64, z:bv64));
  >      (var Gamma_out:bool := Gamma_out:bool, var out:bv64 := out:bv64);
  23,25c30,32
  < proc @g(a:bv64)  -> (out:bv64) {  }
  <   requires gamma(a:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(a:bv64)))
  ---
  > proc @g(Gamma_a:bool, a:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_a:bool
  >   ensures eq(Gamma_out:bool, old(Gamma_a:bool))
  29,30c36,38
  <      (var out:bv64=out) := call @h(a=a:bv64, b=bvsub(a:bv64, 0x1:bv64));
  <      var out:bv64 := out:bv64;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := call @h(Gamma_a=Gamma_a:bool,
  >         Gamma_b=Gamma_a:bool, a=a:bv64, b=bvsub(a:bv64, 0x1:bv64));
  >      (var Gamma_out:bool := Gamma_out:bool, var out:bv64 := out:bv64);
  34,37c42,45
  < proc @h(a:bv64, b:bv64)  -> (out:bv64) {  }
  <   requires booland(gamma(a:bv64), gamma(b:bv64))
  <   ensures boolor(boolnot(booland(old(gamma(a:bv64)), old(gamma(b:bv64)))),
  <    gamma(out:bv64))
  ---
  > proc @h(Gamma_a:bool, Gamma_b:bool, a:bv64, b:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires booland(Gamma_a:bool, Gamma_b:bool)
  >   ensures boolor(boolnot(booland(old(Gamma_a:bool), old(Gamma_b:bool))),
  >    Gamma_out:bool)
  42c50
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  44c52
  <      var c:bv64 := b:bv64;
  ---
  >      (var Gamma_c:bool := Gamma_b:bool, var c:bv64 := b:bv64);
  48c56
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  50c58,59
  <      (var c:bv64=out) := call @g(a=bvadd(a:bv64, b:bv64));
  ---
  >      (var Gamma_c:bool=Gamma_out, var c:bv64=out) := call @g(Gamma_a=booland(Gamma_a:bool,
  >          Gamma_b:bool), a=bvadd(a:bv64, b:bv64));
  53c62,65
  <    block %h_return [ var out:bv64 := bvadd(c:bv64, 0x1:bv64); return; ]
  ---
  >    block %h_return [
  >      (var Gamma_out:bool := Gamma_c:bool, var out:bv64 := bvadd(c:bv64, 0x1:bv64));
  >      return;
  >    ]
  54a67
  > var Gamma_$x:bool;
  [1]
