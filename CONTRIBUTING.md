
# Contributing to bincaml

This guide explains who to get started as a contributor.

# CookBook

### Standard Library

All files should import the util.common library which contains extensions to
the OCaml standard library in the `containers` library, this is done by
depending on the `bincaml.util` library and putting at the top of the file.

```
open Util.Common
```

Use the documentation for `containers` as a reference before the standard
library api docs (although it should be a superset).

Note that this library replaces the unsafe polymorphic equality operator `(=)` with `Int.Infix.(=)`,
for equality use the relevant monomorphic equality (e.g. for strings) `String.equal`, or `String.Infix.(=)`,
with the appropriate module in place of `String`.

[containers library documentation](https://c-cube.github.io/ocaml-containers/3.15/containers/index.html)

We also depend on [containers-data](https://c-cube.github.io/ocaml-containers/3.15/containers-data/index.html)

For common tasks, check whether these implement the neccessary functionality:

E.g.:

- file IO: `Containers.CCIO` module
- pretty printing: `Containers_pp`
- sexpr reading/writing: `Containers.Sexp`

We make as much use as possible of the following dependencies:

- [backtracking/ocamlgraph](https://ocaml.org/p/ocamlgraph) for graph algorithms
- [fpottier/fix](https://ocaml.org/p/fix) for fixpoints and memoisation
- [c-cube/containers-data](https://c-cube.github.io/ocaml-containers) for common persistent and imperative datastructures
- [c-cube/iter](https://c-cube.github.io/iter) efficient lazy iterators with
    minimal allocations, use these as an intermediate structure for composing transformations
    instead of `List` or `Seq`

Check whether these implement what you need before re-implementing standard algorithms.


### Implementing Analyses

1. An intraprocedural flow-insensitive single-pass analysis of an IR

Use `Procedure.fold_blocks_topo_fwd` or `Procedure.fold_blocks_topo_rev`.

To modify the procedure (returning a modified version, not modified in-place), use `Procedure.map_blocks_topo_fwd`.

2. An intraprocedural flow-sensitive analysis of a non-ssa IR form with

Use the Boundocle fixed point with widening (e.g. in reverse)

```ocaml
  Graph.ChaoticIteration.Make
    (Procedure.RevG)
    (struct
      open Procedure
      type vertex = RevG.E.vertex
      type edge = RevG.E.t
      type g = RevG.t
      type t = _
      let equal = _
      let join = _
      let widening a b = _

      let analyze (e : edge) data =
        match G.E.label e with Block b -> transfer_block_function d bata | _ -> data
    end)
```


3. For a simple forwards fixed-point over the call graph / block graph use `Fix.Fixpoint`

See also [documentation for fix](https://ocaml.org/p/fix/20250919/doc/fix/Fix/Fix/ForOrderedType/index.html)

```ocaml

module FixProp = Fix.Fix.ForOrderedType (Util.ID) (Domain:  sig
  type property = VS.t * VS.t

  val equal_property : property -> property -> bool
  val compare_property : property -> property -> int
  val bottom : VS.t * VS.t
  val equal : property -> property -> bool
  val compare : property -> property -> int
  val is_maximal : 'a -> bool
  val leq_join : property -> property -> property
  val to_string : property -> string
  val read : 'a * 'b -> 'a
  val written : 'a * 'b -> 'b
end)

(* transfer function for a node, e.g. id*)
let solve prog_proc =
  let equations (p : ID.t) (valuations : FixProp.valuation) =
      (* lookup block / proc id in prog_proc*)
      (* for successors, lookup their value in valuations *)
      _ in
  FixProp.lfp equations

```


### Testing

We have multiple kinds of testing

- property tests using quickcheck and alcotest
  - see `test/lang/expr_eval_qcheck.ml`
  - These define generators for values to randomly test inputs to a given function.

- expectation tests using `ppx_expect_nobase`: see `test/lang/expr_expect`
  - these assert the printed output matches a specific string
  - they can be created by writing

Expect tests can be created by writing

```
let%expect_test "example test" = print_endline "hello world"
```

Then running `dune test` will fail the test with a diff of the expected output. `dune promote` can then be used to set the result to the expected value.

```
$ dune test
File "test/lang/expr_eval_expect.ml", line 1, characters 0-0:
------ test/lang/expr_eval_expect.ml
++++++ test/lang/expr_eval_expect.ml.corrected
File "test/lang/expr_eval_expect.ml", line 67, characters 0-1:
 |
!|let%expect_test "example test" = print_endline "hello world";
!|  [%expect {| hello world |}]
$ dune promote
Promoting _build/default/test/lang/expr_eval_expect.ml.corrected to
  test/lang/expr_eval_expect.ml.
```

These should be used with care:

1. dont print too much information that will make the test fail with any unrelated change: be precise in what is under test
2. ensure the output is human-readable and clear

see also: [writeup on expect tests](https://blog.janestreet.com/the-joy-of-expect-tests/)


#### cram tests through dune

Example: see `test/lang/cram/`

These are expected output tests for a shell script.


They have the form

```
Ignored explanatory test

    $ echo "expected output for shell line"

    expected output

```

They have similar characteristics to expected output tests; prefer use the
shell to test some property of the cli rather than the fact it has a specific
output.

More details are available in the [dune manual](https://dune.readthedocs.io/en/stable/reference/cram.html).

#### unit tests using `alcotest`

[See manual](https://github.com/mirage/alcotest)



# OCaml

Install instrsuctions can be found on [ocaml.org](https://ocaml.org/install#linux_mac_bsd)

Ocaml is a somewhat niche langauge so we spend a few words on why and how we use it.

Cheifly it comes down to

- library availability: OCaml gets a lot of use in the formal methods / program
  analysis fields so there is a large corpus of open source implementations we
  can draw on
- functional programming: OCaml is a functional language with a strong static type system and good type inference
- simplicity of the language: while a functional langauge, OCaml is strict
  (expressions are evaluated immediately), and lacks a type-class system in favour of the module
  system. These make OCaml code usually very transparent to understand (although sometimes more verbose).
- good tooling: the build system; dune, the langauge server, the compiler are
  all fast and interactive and well suited to the research-code use case.

If you want more evangelism you can find it [here](https://xvw.lol/en/articles/why-ocaml.html).


### Learning OCaml

We recommend the textbook to Cornell's CS3110 functional programming course, which

It is available for free on their [website](https://cs3110.github.io/textbook/cover.html) and as [pdf](https://cs3110.github.io/textbook/ocaml_programming.pdf).

Also consider reviewing the [ocaml manual](https://ocaml.org/manual/5.3/index.html).

##### OCaml code search

opam package Search by type signature: [https://doc.sherlocode.com](https://doc.sherlocode.com)

full source search of opam reposotiry [https://sherlocode.com/](https://sherlocode.com/)


### Setting up ocaml:

We recommend you install the language server and dev setup packages:

```
opam install ocaml-lsp-server
opam install --deps-only --with-dev-setup .
```

`--with-dev-setup` includes `ocamlformat`, `odig`, `sherlodoc` this is useful for documentation search.

Use the following to build and open the documentation page for an installed package, here `containers`:

```
odig doc containers
```


## Repeating Module Interfaces

It is good practice to hide implementations by interfaces, however in practice this often requires
a significant amount of code rewriting to define the module and its interface separately.
Some tricks can be used to simplify this process.

The following post describes a trick to reduce this duplication: [https://www.craigfe.io/posts/the-intf-trick](https://www.craigfe.io/posts/the-intf-trick).

The following trick can also be used to write some code in a module that is not included in the outer module:

```
open struct
 type t = int

  let (v:t) = v + 1

end
```

