prog entry @f;

proc @f () -> ()
[
    block %entry [
        goto(%a, %b);
    ];
    block %a [
        var yi:bv64 := 1:bv64;
        goto(%exit);
    ];
    block %b [
        var yi:bv64 := 2:bv64;
        var yi:bv64 := 67:bv64;
        goto(%exit);
    ];
    block %exit (
        var j:bv64 := phi(%a -> yi:bv64, %b -> yi:bv64)
    ) [
        // var j:bv64 := yi;
        var x:bv64 := j;
        return ();
    ];
];

proc @g () -> ()
[
    block %entry [
        goto(%a, %b);
    ];
    block %a [
        var ai:bv64 := 1:bv64;
        goto(%exit);
    ];
    block %b [
        var bi:bv64 := 2:bv64;
        goto(%exit);
    ];
    block %exit (
        var j:bv64 := phi(%a -> ai:bv64, %b -> bi:bv64)
    ) [
        // var j:bv64 := bvadd(ai,bi);
        var x:bv64 := j;
        return ();
    ];
];

