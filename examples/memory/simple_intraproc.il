memory shared $mem : (bv64 -> bv8);
memory $stack : (bv64 -> bv8);

prog entry @main;

proc @malloc(R0_in:bv64)  -> (R0_out:bv64) { .name = "malloc" }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)
;
proc @free(R0_in:bv64)  -> () { .name = "free" }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)
;

proc @free_wrapper(R0_in:bv64)
   -> (R0_out:bv64) { .name = "free_wrapper"; }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)
[
    block %free_wrapper_entry [
        call @free(R0_in:bv64);
        goto(%free_wrapper_return);
    ];
    block %free_wrapper_return [
        var temp:bv64 := 10:bv64;
        assume bvuge(temp,10:bv64);
        return(temp);
    ];
];

proc @main () -> ()
[
    block %main_entry [
        var size:bv64 := 2:bv64;
        var (addr:bv64) := call @malloc(size);

        // Store our address on stack
        store le $stack 0:bv64 addr 64;

        // Write 0xff to the address allocated
        store le $mem addr 0xff:bv8 8;

        var (r:bv64) := call @free_wrapper(addr);
        var (r:bv64) := call @free_wrapper(addr);

        goto(%main_return);
    ];
    block %main_return [
        return ();
    ];
];

