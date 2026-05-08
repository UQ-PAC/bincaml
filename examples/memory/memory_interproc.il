memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

prog entry @main;

proc @malloc(R0_in:bv64) -> (R0_out:bv64);
proc @free(R0_in:bv64) -> ();

// In future, realloc should actually copy the byte accross.
// For now that is ommitted from this test as the store expression
// locks up the interprocedural redundancy check forever.
proc @realloc(ptr_in:bv64) -> (ptr_out:bv64)
[
    block %realloc [
        // var x:bv8 := load le $mem ptr_in 8;
        call @free(ptr_in);
        var size: bv64 := 1:bv64;
        var (ptr_out:bv64) := call @malloc(size);
        // store le $mem ptr_out x 8;
        goto(%realloc_return);
    ];
    block %realloc_return [
        return;
    ];
];

proc @main () -> ()
[
    block %main_entry [
        var size: bv64 := 1:bv64;
        var (addr:bv64) := call @malloc(size);
        var (addr_2:bv64) := call @realloc(addr);
        goto(%main_return);
    ];
    block %main_return [
        assert neq(addr, addr_2);
        call @free(addr_2);
        return;
    ];
];
