prog entry @main;

var $global:bv64;

proc @main (inp:bv64) -> ()
[
    block %main_entry [
        (var a:bv64 := inp:bv64, var b:bv64 := inp:bv64);
        var (a:bv64) := call @fun1(a:bv64, b: bv64);
        var (x:bv64) := call @fun1(a:bv64, b: bv64);
        assert eq(x:bv64, bvadd(a:bv64, a:bv64));
        assert eq(y:bv64, 0);
        return ();
    ];
];

proc @fun1 (c:bv64, d:bv64) -> (out:bv64)
[
    block %fun1_entry [
        var (e:bv64) := call @fun2 (d:bv64);
        return (bvadd(c:bv64, e:bv64));
    ];
];

proc @fun2 (f:bv64) -> (out2:bv64)
[
    block %fun2_entry [
        var g:bv64 := $global:bv64;
        return (bvadd(g:bv64, g:bv64));
    ];
];
