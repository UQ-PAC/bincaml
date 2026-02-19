# bincaml

lightweight binary exploration verification project implemented in ocaml.

status: very early stages work-in progress.

### Setup

Supports Linux (at least amd64) and MacOS (arm64) with OCaml 5.3.0.
Windows is explicitly not supported outside of WSL.

- enable frame pointers on opam switch for performance recording
- enable flambda for compiler optimisation (for release build only)

- Tests requrie smt solver CVC5 installed.

```bash
opam switch create bincaml ocaml-variants.5.3.0+options ocaml-option-flambda ocaml-option-fp
opam repository add pac https://github.com/uq-pac/opam-repository.git
opam install --deps-only --with-doc --with-test .
dune build
```


### Example

bincaml analyses il files produced by [basil](https://github.com/uq-pac/basil).
scripts (in addition to cli) are used to drive the tool, for example:

```lisp
; test.s
(load-il "examples/cntlm-simp-output.il")
(dump-il "before.il")
(run-transforms "cf-expressions" "intra-dead-store-elim")
(dump-il "after.il")
```

```diff
$ dune exec bincaml script test.s
$ diff before.il after.il | head
50d49
<       var R30_begin_p9main_4198208:bv64 := $R30:bv64;
55d53
<       var var1_4198208_bv64:bv64 := 0x0:bv64;
65,66c63
<       var var1_4198220_bv64:bv64 := 0x0:bv64;
<       $R29:bv64 := bvadd($R31:bv64, 0x0:bv64);
---
>       $R29:bv64 := $R31:bv64;
68,69d64
```
