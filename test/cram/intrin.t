


  $ cat << EOF | bincaml script -
  > (load-il "../../examples/memory/malloc_free.il")
  > (dump-il before.il)
  > (run-transforms "lift-intrinsics-aarch64")
  > (dump-il after.il)
  > (load-il after.il)
  > (dump-il after2.il)
  > EOF
  (load-il ../../examples/memory/malloc_free.il)
  (dump-il before.il)
  (run-transforms lift-intrinsics-aarch64)
  (dump-il after.il)
  (load-il after.il)
  (dump-il after2.il)

Added intrinsics

  $ diff before.il after.il
  19c19,20
  <      (var R0_3:bv64=R0_out) := call @malloc(R0_in=0x1:bv64) { .label = "1916_2" };
  ---
  >      ($mem:(bv64->bv8), var R0_3:bv64):= call @_malloc($mem, 0x1:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  32c33,34
  <      call @#free(R0_in=Exp14__5_22_1:bv64) { .label = "1964_2" };
  ---
  >      ($mem:(bv64->bv8)):= call @_free($mem, Exp14__5_22_1:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  [1]


Should survive round trip

  $ diff after.il after2.il

Different intrin specs

  $ cat << EOF | bincaml script -
  > (load-il "../../examples/memory/malloc_free_various.il")
  > (dump-il before.il)
  > (run-transforms "lift-intrinsics-aarch64")
  > (dump-il after.il)
  > (load-il after.il)
  > (dump-il after2.il)
  > EOF
  (load-il ../../examples/memory/malloc_free_various.il)
  (dump-il before.il)
  (run-transforms lift-intrinsics-aarch64)
  (dump-il after.il)
  (load-il after.il)
  (dump-il after2.il)

Added intrinsics

  $ diff before.il after.il
  38c38,39
  <      (var addr:bv64=R0_out) := call @malloc(R0_in=size:bv64);
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  41c42,43
  <      call @xfree(R0_in=addr:bv64);
  ---
  >      ($mem:(bv64->bv8)):= call @_free($mem, addr:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  53c55,56
  <      (var addr:bv64=R0_out) := call @zmalloc(R0_in=size:bv64);
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  56,57c59,62
  <      call @xfree(R0_in=addr:bv64);
  <      call @yfree(R0_in=addr:bv64);
  ---
  >      ($mem:(bv64->bv8)):= call @_free($mem, addr:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  >      ($mem:(bv64->bv8)):= call @_free($mem, addr:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  69,70c74,77
  <      (var addr:bv64=R0_out) := call @malloc(R0_in=size:bv64);
  <      call @free(R0_in=bvadd(addr:bv64, 0x1:bv64));
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  >      ($mem:(bv64->bv8)):= call @_free($mem, bvadd(addr:bv64, 0x1:bv64));
  >      ($stack:(bv64->bv8)):= call @_havoc();
  82c89,90
  <      (var addr:bv64=R0_out, var unrel:bv64=R1_out) := call @xmalloc(R0_in=size:bv64);
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8), var unrel:bv64):= call @_havoc();
  84c92,93
  <      call @free(R0_in=addr:bv64);
  ---
  >      ($mem:(bv64->bv8)):= call @_free($mem, addr:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  97c106,107
  <      (var addr:bv64=R0_out) := call @malloc(R0_in=size:bv64);
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  100c110,111
  <      call @#free(R0_in=addr:bv64);
  ---
  >      ($mem:(bv64->bv8)):= call @_free($mem, addr:bv64);
  >      ($stack:(bv64->bv8)):= call @_havoc();
  112c123,124
  <      (var addr:bv64=R0_out, var unrel:bv64=R1_out) := call @xmalloc(R0_in=size:bv64);
  ---
  >      ($mem:(bv64->bv8), var addr:bv64):= call @_malloc($mem, size:bv64);
  >      ($stack:(bv64->bv8), var unrel:bv64):= call @_havoc();
  [1]


Should survive round trip

  $ diff after.il after2.il
