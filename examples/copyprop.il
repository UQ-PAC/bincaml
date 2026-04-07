prog entry @f;

proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
        goto (%f_a, %f_b);
    ];
    block %f_a [
        var y:bv64 := x;
        goto (%f_return);
    ];
    block %f_b [
        (var y:bv64, var z:bv64) := call @g(x);
        goto (%f_return);
    ];
    block %f_return [
        return (y:bv64);
    ];
];

proc @g(x:bv64) -> (o:bv64, p:bv64)
[
    block %g_entry [
        goto (%g_a, %g_b);
    ];
    block %g_a [
        var y:bv64 := x;
        goto (%g_return);
    ];
    block %g_b [
        (var y:bv64) := call @f(x);
        goto (%g_return);
    ];
    block %g_return [
        return (x:bv64, y:bv64);
    ];
];
