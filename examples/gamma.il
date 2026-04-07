prog entry @main;

var $x:bv64;

proc @main () -> (out:bv64)
    requires gamma($x:bv64)
    ensures gamma($x:bv64)
[
    block %main_entry [
        ($x:bv64) := call @f($x:bv64);
        goto(%main_return);
    ];
    block %main_return [
        return ($x:bv64);
    ];
];

proc @f (z:bv64) -> (out:bv64)
    requires gamma(z:bv64)
    ensures eq(gamma(out:bv64), old(gamma(z:bv64)))
[
    block %f_body [
        var (out:bv64) := call @h(z:bv64, bvmul(z:bv64, z:bv64));
        return (out:bv64);
    ];
];

proc @g(a:bv64) -> (out:bv64)
    requires gamma(a:bv64)
    ensures eq(gamma(out:bv64), old(gamma(a:bv64)))
[
    block %g_body [
        var (out:bv64) := call @h(a:bv64, bvsub(a:bv64, 1:bv64));
        return (out:bv64);
    ];
];

proc @h(a:bv64, b:bv64) -> (out:bv64)
    // Need b low since @g needs b low.
    requires booland(gamma(a:bv64), gamma(b:bv64))
    // want boolimplies(booland(old(gamma(a:bv64)), old(gamma(b:bv64))), gamma(out:bv64))
    ensures boolor(boolnot(booland(old(gamma(a:bv64)), old(gamma(b:bv64)))), gamma(out:bv64))
[
    block %h_entry [
        goto (%h_1, %h_2);
    ];
    block %h_1 [
        assert gamma(a:bv64);
        guard eq(a:bv64, 0:bv64);
        var c:bv64 := b:bv64;
        goto (%h_return);
    ];
    block %h_2 [
        assert gamma(a:bv64);
        guard boolnot(eq(a:bv64, 0:bv64));
        var (c:bv64) := call @g(bvadd(a:bv64, b:bv64));
        goto (%h_return);
    ];
    block %h_return [
        return (bvadd(c:bv64, 1:bv64));
    ];
];
