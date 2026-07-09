
  $ bincaml script gammavars.sexp
  (load-il ../../examples/gamma.il)
  (dump-il before.il)
  (run-transforms gamma-vars)
  (dump-il after.il)

  $ diff before.il after.il
  34,37c34,37
  < proc @h(a:bv64, b:bv64)  -> (out:bv64) {  }
  <   requires booland(gamma(a:bv64), gamma(b:bv64))
  <   ensures boolor(boolnot(booland(old(gamma(a:bv64)), old(gamma(b:bv64)))),
  <    gamma(out:bv64))
  ---
  > proc @h(Gamma_a:bool, Gamma_b:bool, a:bv64, b:bv64)  -> (Gamma_out:bool, out:bv64) {  }
  >   requires booland(Gamma_a:bool, Gamma_b:bool)
  >   ensures boolor(boolnot(booland(old(Gamma_a:bool), old(Gamma_b:bool))),
  >    Gamma_out:bool)
  42c42
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  44c44
  <      var c:bv64 := b:bv64;
  ---
  >      (var Gamma_c:bool := Gamma_b:bool, var c:bv64 := b:bv64);
  48c48
  <      assert gamma(a:bv64);
  ---
  >      assert Gamma_a:bool;
  50c50,51
  <      (var c:bv64=out) := call @g(a=bvadd(a:bv64, b:bv64));
  ---
  >      (var Gamma_c:bool=Gamma_out, var c:bv64=out) := call @g(Gamma_a=booland(Gamma_a:bool,
  >          Gamma_b:bool), a=bvadd(a:bv64, b:bv64));
  53c54,57
  <    block %h_return [ var out:bv64 := bvadd(c:bv64, 0x1:bv64); return; ]
  ---
  >    block %h_return [
  >      (var Gamma_out:bool := Gamma_c:bool, var out:bv64 := bvadd(c:bv64, 0x1:bv64));
  >      return;
  >    ]
  [1]
