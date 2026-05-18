prog entry @f;

proc @f () -> ()
[
    block %a [
        goto(%b, %c);
    ];
    block %b [
        var x_1:bv64 := 0:bv64;
        goto(%d);
    ];
    block %c [
        var x_2:bv64 := 0:bv64;
        goto(%d);
    ];
    block %d (
        var x_3:bv64 := phi(
            %c -> x_2:bv64,
            %b -> x_1:bv64
        )
    ) [
        assert eq(x_3,0:bv64);
        return ();
    ];
];
