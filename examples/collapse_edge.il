prog entry @main;

proc @main(a:bv64) -> (c:bv64)
[
    block %inputs [ goto(%a); ];
    block %a [ goto(%b, %c); ];
    block %b [ goto(%c); ];
    block %c [ var b:bv64 := a:bv64; goto(%d); ];
    block %d [ goto(%e); ];
    block %e ( var c_1:bv64 := phi(%d -> b:bv64)) [
        var c:bv64 := c_1:bv64;
        goto(%f);
    ];
    block %f [ return; ];
];
