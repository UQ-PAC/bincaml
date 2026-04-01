
  $ bincaml script gammavars.sexp

  $ diff before.il after.il
  1a2
  > var Gamma_$x:bool;
  3,7c4,8
  < proc @main()  -> (out:bv64) {  }
  <   modifies $x:bv64
  <   captures $x:bv64
  <   requires gamma($x:bv64)
  <   ensures gamma($x:bv64)
  ---
  > proc @main()  -> (Gamma_out:bool, out:bv64) {  }
  >   modifies Gamma_$x:bool, $x:bv64
  >   captures Gamma_$x:bool, $x:bv64
  >   requires Gamma_$x:bool
  >   ensures Gamma_$x:bool
  11,12c12,13
  <      ($x:bv64=out) := 
  <      call @f(z=$x:bv64);
  ---
  >      (Gamma_$x:bool=Gamma_out, $x:bv64=out) := 
  >      call @f(Gamma_z=Gamma_$x:bool, z=$x:bv64);
  15c16,19
  <    block %main_return [ var out:bv64 := $x:bv64; return; ]
  ---
  >    block %main_return [
  >      (var Gamma_out:bool := Gamma_$x:bool, var out:bv64 := $x:bv64);
  >      return;
  >    ]
  17,19c21,23
  < proc @f(z:bv64)  -> (out:bv64) {  }
  <   requires gamma(z:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(z:bv64)))
  ---
  > proc @f(Gamma_z:bool, z:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_z:bool
  >   ensures eq(Gamma_out:bool, old(Gamma_z:bool))
  23,25c27,30
  <      (var out:bv64=out) := 
  <      call @h(a=z:bv64, b=bvmul(z:bv64, z:bv64));
  <      var out:bv64 := out:bv64;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := 
  >      call @h(Gamma_a=Gamma_z:bool, Gamma_b=Gamma_z:bool, a=z:bv64,
  >         b=bvmul(z:bv64, z:bv64));
  >      (var Gamma_out:bool := Gamma_out:bool, var out:bv64 := out:bv64);
  29,31c34,36
  < proc @g(a:bv64)  -> (out:bv64) {  }
  <   requires gamma(a:bv64)
  <   ensures eq(gamma(out:bv64), old(gamma(a:bv64)))
  ---
  > proc @g(Gamma_a:bool, a:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires Gamma_a:bool
  >   ensures eq(Gamma_out:bool, old(Gamma_a:bool))
  35,37c40,43
  <      (var out:bv64=out) := 
  <      call @h(a=a:bv64, b=bvsub(a:bv64, 0x1:bv64));
  <      var out:bv64 := out:bv64;
  ---
  >      (var Gamma_out:bool=Gamma_out, var out:bv64=out) := 
  >      call @h(Gamma_a=Gamma_a:bool, Gamma_b=Gamma_a:bool, a=a:bv64,
  >         b=bvsub(a:bv64, 0x1:bv64));
  >      (var Gamma_out:bool := Gamma_out:bool, var out:bv64 := out:bv64);
  41,44c47,50
  < proc @h(a:bv64, b:bv64)  -> (out:bv64) {  }
  <   requires booland(gamma(a:bv64), gamma(b:bv64))
  <   ensures boolor(boolnot(booland(old(gamma(a:bv64)), old(gamma(b:bv64)))),
  <    gamma(out:bv64))
  ---
  > proc @h(Gamma_a:bool, Gamma_b:bool, a:bv64, b:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires booland(Gamma_a:bool, Gamma_b:bool)
  >   ensures boolor(boolnot(booland(old(Gamma_a:bool), old(Gamma_b:bool))),
  >    Gamma_out:bool)
  49c55
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  51c57
  <      var c:bv64 := b:bv64;
  ---
  >      (var Gamma_c:bool := Gamma_b:bool, var c:bv64 := b:bv64);
  55c61
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  57,58c63,64
  <      (var c:bv64=out) := 
  <      call @g(a=bvadd(a:bv64, b:bv64));
  ---
  >      (var Gamma_c:bool=Gamma_out, var c:bv64=out) := 
  >      call @g(Gamma_a=booland(Gamma_a:bool, Gamma_b:bool), a=bvadd(a:bv64, b:bv64));
  61c67,70
  <    block %h_return [ var out:bv64 := bvadd(c:bv64, 0x1:bv64); return; ]
  ---
  >    block %h_return [
  >      (var Gamma_out:bool := Gamma_c:bool, var out:bv64 := bvadd(c:bv64, 0x1:bv64));
  >      return;
  >    ]
  [1]
