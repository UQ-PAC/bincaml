prog entry @f;


proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
        var x_1:bv64 := x:bv64;
        goto(%f_a, %f_ret);
    ];
    block %f_a (
        var x_2:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64)
    ) [
        var x_3:bv64 := bvadd(x_2:bv64, 1:bv64);
        goto(%f_a, %f_ret);
    ];
    block %f_ret (
        var x_4:bv64 := phi(%f_entry -> x_1:bv64, %f_a -> x_3:bv64)
    ) [
        var o:bv64 := x_4:bv64;
        return;
    ];
];
