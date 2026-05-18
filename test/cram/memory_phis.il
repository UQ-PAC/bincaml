memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

proc @malloc(R0_in:bv64) -> (R0_out:bv64);
proc @free(R0_in:bv64) -> ();

prog entry @no_memory_leak;

proc @no_memory_leak () -> () { .entrypoint=true; }
[
    block %a [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%b, %c);
    ];
    block %b [
        call @free(addr);
        goto(%d);
    ];
    block %c [
        call @free(addr);
        goto(%d);
    ];
    block %d [
        return ();
    ];
];

proc @memory_leak () -> () { .entrypoint=true; }
[
    block %a [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%b, %c);
    ];
    block %b [
        call @free(addr);
        goto(%d);
    ];
    block %c [
        goto(%d);
    ];
    block %d [
        return ();
    ];
];

proc @no_null_pointer () -> () { .entrypoint=true; }
[
    block %a [
        var addr:bv64 := 0:bv64;
        goto(%b, %c);
    ];
    block %b [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%d);
    ];
    block %c [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%d);
    ];
    block %d [
        store le $mem addr 0xff:bv8 8;
        call @free(addr);
        return ();
    ];
];

proc @null_pointer () -> () { .entrypoint=true; }
[
    block %a [
        var addr:bv64 := 0:bv64;
        goto(%b, %c);
    ];
    block %b [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%d);
    ];
    block %c [
        // Oops, forgot to allocate in a branch ...
        // var (addr:bv64) := call @malloc(1:bv64);
        goto(%d);
    ];
    block %d [
        // ... resulting in writing to potentially unallocated memory
        store le $mem addr 0xff:bv8 8;

        // ... and also in freeing a null pointer
        call @free(addr);
        return ();
    ];
];

proc @control_flow () -> () { .entrypoint=true; }
[
    block %a [
        // Simulate a malloc that can fail, returning 0
        goto(%b, %c);
    ];
    block %b [
        var (addr:bv64) := call @malloc(1:bv64);
        goto(%d);
    ];
    block %c [
        var addr:bv64 := 0:bv64;
        goto(%d);
    ];
    block %d [
        // Branch on if the allocation was successful.
        // Only use it if it was.
        goto(%e, %f);
    ];
    block %e [
        guard(neq(addr, 0:bv64));
        store le $mem addr 0xff:bv8 8;
        call @free(addr);
        goto(%g);
    ];
    block %f [
        guard(eq(addr, 0:bv64));
        // allocation failed :(
        // cannot do anything here.
        goto(%g);
    ];
    block %g [
        return ();
    ];
];
