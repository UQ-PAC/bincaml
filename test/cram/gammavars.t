
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
  <   requires gamma(z)
  <   ensures eq(gamma(out), old(gamma(z)))
  ---
  > proc @f(Gamma_z:bool, z:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_z
  >   ensures eq(Gamma_out, old(Gamma_z))
  18,19c24,26
  <      (var out:bv64=out) := call @h(a=z, b=bvmul(z, z));
  <      var out:bv64 := out;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := call @h(Gamma_a=Gamma_z,
  >         Gamma_b=Gamma_z, a=z, b=bvmul(z, z));
  >      (var Gamma_out:bool := Gamma_out, var out:bv64 := out);
  23,25c30,32
  < proc @g(a:bv64)  -> (out:bv64) {  }
  <   requires gamma(a)
  <   ensures eq(gamma(out), old(gamma(a)))
  ---
  > proc @g(Gamma_a:bool, a:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_a
  >   ensures eq(Gamma_out, old(Gamma_a))
  29,30c36,38
  <      (var out:bv64=out) := call @h(a=a, b=bvsub(a, 0x1:bv64));
  <      var out:bv64 := out;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := call @h(Gamma_a=Gamma_a,
  >         Gamma_b=Gamma_a, a=a, b=bvsub(a, 0x1:bv64));
  >      (var Gamma_out:bool := Gamma_out, var out:bv64 := out);
  34,36c42,44
  < proc @h(a:bv64, b:bv64)  -> (out:bv64) {  }
  <   requires booland(gamma(a), gamma(b))
  <   ensures boolor(boolnot(booland(old(gamma(a)), old(gamma(b)))), gamma(out))
  ---
  > proc @h(Gamma_a:bool, Gamma_b:bool, a:bv64, b:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires booland(Gamma_a, Gamma_b)
  >   ensures boolor(boolnot(booland(old(Gamma_a), old(Gamma_b))), Gamma_out)
  41c49
  <      assert gamma(a);
  ---
  >      assert Gamma_a;
  43c51
  <      var c:bv64 := b;
  ---
  >      (var Gamma_c:bool := Gamma_b, var c:bv64 := b);
  47c55
  <      assert gamma(a);
  ---
  >      assert Gamma_a;
  49c57,58
  <      (var c:bv64=out) := call @g(a=bvadd(a, b));
  ---
  >      (var Gamma_c:bool=Gamma_out, var c:bv64=out) := call @g(Gamma_a=booland(Gamma_a,
  >          Gamma_b), a=bvadd(a, b));
  52c61,64
  <    block %h_return [ var out:bv64 := bvadd(c, 0x1:bv64); return; ]
  ---
  >    block %h_return [
  >      (var Gamma_out:bool := Gamma_c, var out:bv64 := bvadd(c, 0x1:bv64));
  >      return;
  >    ]
  53a66
  > var Gamma_$x:bool;
  [1]
