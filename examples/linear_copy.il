prog entry @main;

proc @main(a:bv64, x:bool) -> ()
[
    block %main [
        (var b:bv64) := call @f(a:bv64);
        (var c:bv64, var d:bv64) := call @loop(b:bv64, b:bv64);
        (var e:bv64) := call @cross(d:bv64, bvadd(d:bv64, 1:bv64));
        (var f:bv64 := bvadd(1:bv64, c:bv64), var g:bv64 := bvadd(1:bv64, e:bv64));
        (var y:bool) := call @bool_id(x:bool);
        var z:bool := y:bool;
        return;
    ];
];

proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
        goto (%f_a, %f_b);
    ];
    block %f_a [
        var y_1:bv64 := x;
        goto (%f_c, %f_d);
    ];
    block %f_b [
        (var y_2:bv64, var z:bv64) := call @g(x);
        goto (%f_c, %f_d);
    ];
    block %f_c (
        var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        var w_1:bv64 := y_3:bv64;
        goto (%f_return);
    ];
    block %f_d (
        var y_4:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        (var w_2:bv64, var p:bv64) := call @g(y_4);
        goto (%f_return);
    ];
    block %f_return (
        var w_3:bv64 := phi(%f_c -> w_1:bv64, %f_d -> w_2:bv64)
    ) [
        return (w_3:bv64);
    ];
];

proc @g(x:bv64) -> (o:bv64, p:bv64)
[
    block %g_entry [
        goto (%g_a, %g_b);
    ];
    block %g_a [
        var y_1:bv64 := x;
        goto (%g_return);
    ];
    block %g_b [
        (var y_2:bv64) := call @f(x);
        goto (%g_return);
    ];
    block %g_return (
        var y_3:bv64 := phi(%g_a -> y_1:bv64, %g_b -> y_2:bv64)
    ) [
        return (x:bv64, y_3:bv64);
    ];
];

proc @loop(x:bv64, y:bv64) -> (o:bv64, p:bv64)
[
    block %entry [
        var x_1:bv64 := bvadd(x:bv64, 1:bv64);
        var y_1:bv64 := bvadd(y:bv64, 1:bv64);
        goto(%a, %ret);
    ];
    block %a (
        var x_2:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
        var y_2:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
    ) [
        var x_3:bv64 := bvadd(x_2:bv64, 1:bv64);
        var y_3:bv64 := y_2;
        goto(%a, %ret);
    ];
    block %ret (
        var x_4:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64),
        var y_4:bv64 := phi(%f_entry -> y_1:bv64, %f_a -> y_3:bv64)
    ) [
        (var o:bv64 := x_4:bv64, var p:bv64 := y_4:bv64);
        return;
    ];
];

proc @cross(a:bv64, b:bv64) -> (o:bv64)
[
    block %entry [
        goto(%a, %b);
    ];
    block %a [
        var o_1:bv64 := a:bv64;
        goto(%ret);
    ];
    block %b [
        var o_2:bv64 := bvsub(b:bv64, 1:bv64);
        goto(%ret);
    ];
    block %ret (
        var o_3:bv64 := phi(%a -> o_1:bv64, %b -> o_2:bv64)
    ) [
        return (o_3:bv64);
    ];
];

proc @bool_id(a:bool) -> (o:bool)
[
    block %entry [
        return (a:bool);
    ];
];
