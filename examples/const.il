prog entry @main;

proc @main() -> (out:bv64)
[
    block %main_entry [
        var x:bv64 := 5:bv64;
        (var y:bv64) := call @f(x:bv64);
        return (bvadd(x, y));
    ];
];

proc @f(inp:bv64) -> (out:bv64)
[
    block %body [
        var a:bv64 := bvmul(2:bv64, bvadd(inp:bv64, 1:bv64));
        var b:bv64 := bvmul(bvadd(a:bv64, 1:bv64), 2:bv64);
        var c:bv64 := bvmul(2:bv64, bvadd(1:bv64, b:bv64));
        var d:bv64 := bvmul(bvadd(1:bv64, c:bv64), 2:bv64);
        var e:bv64 := bvadd(d:bv64, 1:bv64);
        var f:bv64 := bvadd(1:bv64, e:bv64);
        var g:bv64 := bvmul(f:bv64, 2:bv64);
        var h:bv64 := bvmul(3:bv64, g:bv64);
        var i:bv64 := h:bv64;
        return (bvadd(i:bv64, 5:bv64));
    ];
];
