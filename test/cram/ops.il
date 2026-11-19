
prog entry @main ;


proc @main () -> ()
[
    block %main_entry [
        var ia:int := 1;
        var ib:int := 2;
        var i:int := ia .+ ib;
        var i := ia .* ib;
        var i := ia ./ ib;
        var p:bool := ia .<= ib;
        var p:bool := ia .< ib;
        var p:bool := ia .>= ib;
        var p:bool := ia .> ib;

        var a:bv64 := 1:bv64;
        var b:bv64 := 5:bv64;
        var n:bv64 := a + b;
        var n:bv64 := a - b;
        var n:bv64 := a * b;
        var n:bv64 := a / b;

        var p:bool := a <u b;
        var p:bool := a <=u b;
        var p:bool := a < b;
        var p:bool := a <= b;

        var n:bv64 := a << b;
        var n:bv64 := a >> b;
        var n:bv64 := a >>> b;

        var n:bv64 := a &&& b;
        var n:bv64 := a ||| b;

        var ba:bool := true;
        var bb:bool := false;
        var p:bool := (true && false);
        var p:bool := (ba || bb);

        var p:bool := ba ==> bb;
        var p:bool := ba <=> bb;
        var p:bool := ba == bb;
        var p:bool := a == b;
        var p:bool := a <> b;
        var p:bool := true <> false;
        var p:bool := true == false;
        var p:bool := 1 == 2;
        var p:bool := 1 <> 2;
        var p:bool := ((ia == ib) && true);
        var p:bool := 1:bv64 <> 2:bv64;


        // no precedence rulse: have to bracket everything
        var n1:bv64 := a + b * a / b + b;
        var n2:bv64 := (a + (b * (a / b)) + b);
        assert(n1 <> n2);

        return ();
    ];
];
