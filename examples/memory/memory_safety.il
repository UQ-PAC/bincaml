memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

prog entry @main;

// Unspecified malloc/free procedures. Specified by
// memory specification + encoding transform.
proc @malloc(R0_in:bv64) -> (R0_out:bv64);
proc @free(R0_in:bv64) -> ();

// Valid memory operations. Allocates 2 bytes,
// stores/loads to the allocated space, and frees.
proc @main () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        store le $mem bvadd(addr,0:bv64) 0xff:bv8 8;
        var temp:bv8 := load le $mem bvadd(addr,0:bv64) 8;

        call @free(addr);

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

// Double free example. Calls free on address twice.
proc @double_free () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        store le $mem bvadd(addr,0:bv64) 0xff:bv8 8;
        var temp:bv8 := load le $mem bvadd(addr,0:bv64) 8;

        call @free(addr);
        call @free(addr);

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

// Example of freeing a valid address which is not at the
// base of an allocation.
proc @invalid_free () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        call @free(bvadd(addr,1:bv64));

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

// Example of loading memory after free.
proc @use_after_free () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        store le $mem bvadd(addr,0:bv64) 0xff:bv8 8;
        call @free(addr);
        var temp:bv8 := load le $mem bvadd(addr,0:bv64) 8;

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

// Example reading at offset 4 of a 2 byte allocation.
proc @out_of_bounds () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        store le $mem bvadd(addr,4:bv64) 0xff:bv8 8;
        var temp:bv8 := load le $mem bvadd(addr,4:bv64) 8;

        call @free(addr);

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

// Example of catching a memory leak (unfreed addr).
proc @memory_leak () -> () { .entrypoint=true; }
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        store le $mem bvadd(addr,0:bv64) 0xff:bv8 8;
        var temp:bv8 := load le $mem bvadd(addr,0:bv64) 8;

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

